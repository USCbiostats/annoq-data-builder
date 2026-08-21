#!/usr/bin/env python3
"""
merge_hrc_topmed.py
===================

WHAT:
    Adds HRC-mapping columns to TopMed per-chromosome WGSA-output VCFs by checking each
    TopMed variant's hg19 coordinates against the raw HRC r1.1 reference VCF. Four columns
    are appended:
      - chr_pos              (basic info) : hg38 'chr:pos', ALWAYS populated.
      - Mapped_in_HRC        (hg19 info)  : 'Y' / 'N' / '.'  (see below).
      - HRC_chr_pos          (hg19 info)  : hg19 'chr:pos'            when Mapped_in_HRC=='Y', else '.'.
      - HRC_chr_pos_ref_alt  (hg19 info)  : hg19 'chr:posREF>ALT'     when Mapped_in_HRC=='Y', else '.'.
                                            (e.g. 18:10005A>T — A=ref, T=alt)

    SNPs only. Indels and multiallelic rows in the HRC reference are ignored, so no TopMed
    indel can map to HRC (it becomes 'N').

    NOTE: the HRC rsID is intentionally NOT carried. A chr18 comparison showed the HRC ID
    column never provides an rsID that TopMed's own `rs_dbSNP` lacks (it is a less complete
    subset), so HRC-by-RSID search in api-v2 uses `rs_dbSNP` filtered to `Mapped_in_HRC='Y'`.

WHERE:
    - Parameter 1 (hrc_dir):    Directory with the raw HRC r1.1 reference VCFs, one per
                                chromosome (e.g. 18.vcf). Standard VCF columns, positional:
                                CHROM POS ID REF ALT QUAL FILTER INFO. hg19/GRCh37, bare
                                chromosome ('18'). '#'-prefixed header lines are skipped.
    - Parameter 2 (topmed_dir): Directory with TopMed WGSA-output .vcf files (a named-column
                                header row; needs chr, pos, chr_hg19, pos_hg19, ref_hg19,
                                alt_hg19, ref_hg19=ref_hg38).
    - Parameter 3 (output_dir): Directory for the merged chromosome files.

WHEN:
    Run immediately AFTER WGSA and BEFORE the Part-2 PANTHER/enhancer step. Because it runs
    before the Uniprot columns are added, NO Uniprot comparison is performed (removed).

WHY:
    To mark which TopMed variants exist in HRC r1.1 (Mapped_in_HRC='Y') and record their
    hg19 coordinate identifiers, which api-v2 uses to serve HRC-mode search.

HOW:
    For each TopMed chromosome file, find the matching HRC reference VCF (by chromosome),
    build a set of HRC SNP keys (chr, pos, ref, alt) in hg19 space, then stream the TopMed
    file. For each row with ref_hg19=ref_hg38 == 'Y', look up
    (chr_hg19, pos_hg19, ref_hg19, alt_hg19):
      * Found     -> Mapped_in_HRC='Y' and the two HRC_* hg19 identifiers.
      * Not found -> Mapped_in_HRC='N', HRC_* = '.'.
    ref_hg19=ref_hg38 != 'Y'  ->  Mapped_in_HRC='.', HRC_* = '.'.
    chr_pos (hg38) is written for every row.

Usage:
    python3 merge_hrc_topmed.py <hrc_dir> <topmed_dir> <output_dir>

Example:
    python3 merge_hrc_topmed.py \\
        /path/to/raw_hrc \\
        /path/to/wgsa_add/output/tm-20251208 \\
        /path/to/output/merged
"""

import sys
import os
import glob
import time
import json


# Columns appended to every TopMed row, in output order.
NEW_COLUMNS = ['chr_pos', 'Mapped_in_HRC', 'HRC_chr_pos', 'HRC_chr_pos_ref_alt']

# VCF missing-value placeholder, written instead of an empty string for any of the
# appended columns that has no value.
#
# This is load-bearing, not cosmetic.  HRC_chr_pos and HRC_chr_pos_ref_alt are the LAST
# two columns of the row and are unset for every variant with Mapped_in_HRC != 'Y' (the
# majority).  Writing '' there leaves the line ending in two empty tab-separated fields,
# and Java's String.split(regex) DISCARDS trailing empty fields -- so the Part 3 module
# (add_panther_enhancer) counted 724 fields against a 726-column header, failed its
# field-count check in Snp's constructor, and rejected every such variant with
# "Unable to create SNP information for ...".  Part 3 rewrites '.' to '' during its
# cleanup pass, so the final output is unchanged.
MISSING = '.'


def is_snp(ref, alt):
    """True for a single-base substitution (SNP)."""
    return len(ref) == 1 and len(alt) == 1 and ref.isalpha() and alt.isalpha()


def norm_chr(value):
    """Normalise a chromosome field value: 'chr18'->'18', '18'->'18', 'chrX'->'X'."""
    v = str(value).strip()
    if v[:3].lower() == 'chr':
        v = v[3:]
    return v.upper() if v.upper() in ('X', 'Y', 'M', 'MT') else v


def chr_from_filename(path):
    """Extract the bare chromosome token from a filename: '18.vcf'->'18',
    'chr18_5000.vcf'->'18', 'chrX.vcf'->'X'. Returns None if not found."""
    base = os.path.basename(path).split('.')[0]
    if base[:3].lower() == 'chr':
        base = base[3:]
    token = ''
    for ch in base:
        if ch.isdigit():
            token += ch
        elif ch.upper() in ('X', 'Y', 'M'):
            token += ch.upper()
        else:
            break
    return token or None


def build_hrc_lookup(hrc_file):
    """
    Read a raw HRC VCF and build a set of SNP keys (chr, pos, ref, alt) in hg19 space.
    Standard VCF columns are positional (CHROM=0, POS=1, ID=2, REF=3, ALT=4); '#' header
    lines, indels and multiallelic rows are skipped.

    Returns (key_set, snp_row_count).
    """
    keys = set()
    count = 0
    with open(hrc_file, 'r') as f:
        for line in f:
            if line.startswith('#'):
                continue
            fields = line.rstrip('\n').split('\t')
            if len(fields) < 5:
                continue
            chrom, pos, ref, alt = fields[0], fields[1], fields[3], fields[4]
            if ',' in alt or not is_snp(ref, alt):
                continue
            keys.add((norm_chr(chrom), pos, ref.upper(), alt.upper()))
            count += 1
    print(f"  Loaded {count} HRC SNP variants into lookup")
    return keys, count


def process_chromosome(hrc_file, topmed_file, output_file):
    """
    Build the HRC SNP key set, stream the TopMed file, append the four new columns, and
    write the output. Returns a dict of per-chromosome statistics.
    """
    print(f"  Building HRC lookup from: {os.path.basename(hrc_file)}")
    start = time.time()
    hrc_keys, hrc_rows = build_hrc_lookup(hrc_file)
    print(f"  HRC lookup built in {time.time() - start:.1f}s")

    total_rows = 0
    mapped_y = 0
    mapped_n = 0
    mapped_dot = 0

    start = time.time()
    with open(topmed_file, 'r') as fin, open(output_file, 'w') as fout:
        header_line = fin.readline().rstrip('\n')
        col_idx = {name: i for i, name in enumerate(header_line.split('\t'))}
        fout.write(header_line + '\t' + '\t'.join(NEW_COLUMNS) + '\n')

        chr_i = col_idx.get('chr')
        pos_i = col_idx.get('pos')
        ref_eq_i = col_idx.get('ref_hg19=ref_hg38')
        chr_hg19_i = col_idx.get('chr_hg19')
        pos_hg19_i = col_idx.get('pos_hg19')
        ref_hg19_i = col_idx.get('ref_hg19')
        alt_hg19_i = col_idx.get('alt_hg19')

        def get(fields, i):
            return fields[i] if i is not None and i < len(fields) else ''

        for line in fin:
            fields = line.rstrip('\n').split('\t')
            total_rows += 1

            # chr_pos (hg38) — always populated
            chrom = get(fields, chr_i)
            pos = get(fields, pos_i)
            chr_pos = f"{chrom}:{pos}" if chrom and pos else MISSING

            mapped = MISSING
            hrc_chr_pos = MISSING
            hrc_chr_pos_ref_alt = MISSING

            if get(fields, ref_eq_i) == 'Y':
                c19 = get(fields, chr_hg19_i)
                p19 = get(fields, pos_hg19_i)
                r19 = get(fields, ref_hg19_i)
                a19 = get(fields, alt_hg19_i)

                if (norm_chr(c19), p19, r19.upper(), a19.upper()) in hrc_keys:
                    mapped = 'Y'
                    hrc_chr_pos = f"{c19}:{p19}"
                    hrc_chr_pos_ref_alt = f"{c19}:{p19}{r19}>{a19}"
                    mapped_y += 1
                else:
                    mapped = 'N'
                    mapped_n += 1
            else:
                mapped = MISSING
                mapped_dot += 1

            # append in NEW_COLUMNS order: chr_pos, Mapped_in_HRC, HRC_chr_pos, HRC_chr_pos_ref_alt
            fout.write(line.rstrip('\n') + '\t' + chr_pos + '\t' + mapped + '\t'
                       + hrc_chr_pos + '\t' + hrc_chr_pos_ref_alt + '\n')

    elapsed = time.time() - start
    hrc_vs_topmed_pct = (hrc_rows / total_rows * 100) if total_rows else 0.0

    print(f"  Processed {total_rows} TopMed rows in {elapsed:.1f}s")
    print(f"  HRC SNP rows vs TopMed rows: {hrc_rows} / {total_rows} = {hrc_vs_topmed_pct:.2f}%")
    print(f"  Results: mapped_Y={mapped_y}, mapped_N={mapped_n}, mapped_dot={mapped_dot}")

    return {
        'hrc_snp_rows': hrc_rows,
        'topmed_rows': total_rows,
        'hrc_vs_topmed_pct': round(hrc_vs_topmed_pct, 4),
        'mapped_Y': mapped_y,
        'mapped_N': mapped_n,
        'mapped_dot': mapped_dot,
    }


def main():
    if len(sys.argv) != 4:
        print("Usage: python3 merge_hrc_topmed.py <hrc_dir> <topmed_dir> <output_dir>")
        print()
        print("  hrc_dir:    Directory with raw HRC r1.1 .vcf files (parameter 1)")
        print("  topmed_dir: Directory with TopMed WGSA-output .vcf files (parameter 2)")
        print("  output_dir: Directory for merged output files (parameter 3)")
        sys.exit(1)

    hrc_dir = sys.argv[1]
    topmed_dir = sys.argv[2]
    output_dir = sys.argv[3]

    if not os.path.isdir(hrc_dir):
        print(f"ERROR: HRC directory does not exist: {hrc_dir}")
        sys.exit(1)
    if not os.path.isdir(topmed_dir):
        print(f"ERROR: TopMed directory does not exist: {topmed_dir}")
        sys.exit(1)

    os.makedirs(output_dir, exist_ok=True)

    topmed_files = sorted(glob.glob(os.path.join(topmed_dir, '*.vcf')))
    if not topmed_files:
        print(f"ERROR: No .vcf files found in TopMed directory: {topmed_dir}")
        sys.exit(1)

    # Index raw HRC files by chromosome (filenames like 18.vcf, chrX.vcf, ...)
    hrc_files = glob.glob(os.path.join(hrc_dir, '*.vcf'))
    hrc_by_chr = {}
    for hf in hrc_files:
        chr_id = chr_from_filename(hf)
        if chr_id:
            hrc_by_chr[chr_id] = hf

    print(f"Found {len(topmed_files)} TopMed file(s) and {len(hrc_files)} HRC file(s)")
    print()

    stats_by_chr = {}

    for topmed_file in topmed_files:
        basename = os.path.basename(topmed_file)
        chr_id = chr_from_filename(topmed_file)
        print(f"Processing {basename} (chromosome: {chr_id})")

        if chr_id is None:
            print(f"  SKIP: Could not extract chromosome from filename: {basename}")
            continue

        hrc_file = hrc_by_chr.get(chr_id)
        if hrc_file is None:
            print(f"  SKIP: No matching HRC file for chromosome {chr_id}")
            continue

        output_file = os.path.join(output_dir, basename)
        chr_stats = process_chromosome(hrc_file, topmed_file, output_file)
        chr_stats['topmed_file'] = basename
        chr_stats['hrc_file'] = os.path.basename(hrc_file)
        stats_by_chr[chr_id] = chr_stats
        print()

    stats_file = os.path.join(output_dir, 'merge_hrc_topmed_stats.json')
    with open(stats_file, 'w') as sf:
        json.dump(stats_by_chr, sf, indent=2)
    print(f"Wrote per-chromosome statistics to: {stats_file}")

    print("Done.")


if __name__ == '__main__':
    main()
