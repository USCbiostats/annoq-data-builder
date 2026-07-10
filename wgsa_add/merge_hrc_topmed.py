#!/usr/bin/env python3
"""
merge_hrc_topmed.py
===================

WHAT:
    Merges HRC (v5) annotation data into TopMed chromosome VCF files by adding
    two new columns: 'Mapped_in_HRC' and 'HRC_rs_dbSNP151'. For variants that map
    into HRC it also compares 11 Uniprot columns between the two datasets and records
    per-column match statistics in merge_hrc_topmed_stats.json.

WHERE:
    - Parameter 1 (hrc_dir):    Directory containing HRC .vcf files (e.g. v5/)
    - Parameter 2 (topmed_dir): Directory containing TopMed .vcf files (e.g. tm-20251208/)
    - Parameter 3 (output_dir): Directory for final merged chromosome files

WHEN:
    Run after both HRC and TopMed annotation pipelines have produced their
    per-chromosome .vcf output files.

WHY:
    To determine which TopMed variants also exist in the HRC dataset (Mapped_in_HRC=Y)
    and carry over the HRC rs_dbSNP151 identifier (HRC_rs_dbSNP151).

HOW:
    For each chromosome .vcf file found in the TopMed directory:
      1. Find the matching HRC file (same filename) in the HRC directory.
      2. Build an in-memory lookup dictionary from the HRC file keyed on
         (chr, pos, ref, alt) -> rs_dbSNP151.
      3. Stream through each row of the TopMed file:
         - If ref_hg19=ref_hg38 == 'Y':
             Look up (chr_hg19, pos_hg19, ref_hg19, alt_hg19) in the HRC dict.
             * Found:     Mapped_in_HRC = 'Y'; HRC_rs_dbSNP151 = HRC rs_dbSNP151 value
             * Not found: Mapped_in_HRC = 'N'; HRC_rs_dbSNP151 = ''
         - If ref_hg19=ref_hg38 == 'N':
             Mapped_in_HRC = '.'; HRC_rs_dbSNP151 = ''
      4. Write the augmented row (original columns + 2 new columns) to the output file.

Usage:
    python3 merge_hrc_topmed.py <hrc_dir> <topmed_dir> <output_dir>

Example:
    python3 merge_hrc_topmed.py \
        /path/to/wgsa_add/output/v5 \
        /path/to/wgsa_add/output/tm-20251208 \
        /path/to/output/merged
"""

import sys
import os
import glob
import time
import json


# The 11 Uniprot-related columns compared between the matched HRC and TopMed variant
# when Mapped_in_HRC == 'Y'. Uniprot data is added upstream by the Part-2
# add_panther_enhancer step, so these columns are present in properly-annotated VCFs.
UNIPROT_COMPARE_COLS = [
    'Uniprot_acc',
    'Uniprot_entry',
    'Uniprot_mapped_to_0_flanking_region',
    'Uniprot_mapped_to_10000_flanking_region',
    'Uniprot_mapped_to_20000_flanking_region',
    'Uniprot_mapped_to_ANNOVAR_ensembl_Gene_ID',
    'Uniprot_mapped_to_ANNOVAR_refseq_Gene_ID',
    'Uniprot_mapped_to_SnpEff_ensembl_Gene_ID',
    'Uniprot_mapped_to_SnpEff_refseq_Gene_ID',
    'Uniprot_mapped_to_VEP_ensembl_Gene_ID',
    'Uniprot_mapped_to_VEP_refseq_Gene_ID',
]


def build_hrc_lookup(hrc_file):
    """
    Read the HRC file and build a dictionary keyed on (chr, pos, ref, alt).
    Values are a dict: {'rs_dbSNP151': ..., <each present UNIPROT_COMPARE_COLS>: ...}.

    The key columns (chr, pos, ref, alt) and rs_dbSNP151 are required; if any is
    missing the lookup cannot be built and an empty dict is returned.

    Returns a tuple of (lookup_dict, hrc_row_count) where hrc_row_count is the
    number of data rows read from the HRC file.
    """
    lookup = {}
    line_count = 0
    with open(hrc_file, 'r') as f:
        header_line = f.readline().rstrip('\n')
        headers = header_line.split('\t')
        col_idx = {name: i for i, name in enumerate(headers)}

        required = ['chr', 'pos', 'ref', 'alt', 'rs_dbSNP151']
        missing_required = [col for col in required if col not in col_idx]
        if missing_required:
            print(f"  WARNING: Required column(s) {missing_required} not found in "
                  f"HRC file {hrc_file}; skipping this chromosome")
            return lookup, line_count

        chr_i = col_idx['chr']
        pos_i = col_idx['pos']
        ref_i = col_idx['ref']
        alt_i = col_idx['alt']
        rs_i = col_idx['rs_dbSNP151']
        # Uniprot columns to carry for the comparison (only those present in this HRC file)
        uniprot_indices = {col: col_idx[col] for col in UNIPROT_COMPARE_COLS if col in col_idx}
        missing_uniprot = [col for col in UNIPROT_COMPARE_COLS if col not in col_idx]
        if missing_uniprot:
            print(f"  NOTE: {len(missing_uniprot)} Uniprot column(s) absent from HRC file; "
                  f"treated as empty in the comparison: {missing_uniprot}")

        for line in f:
            fields = line.rstrip('\n').split('\t')
            key = (fields[chr_i], fields[pos_i], fields[ref_i], fields[alt_i])
            entry = {'rs_dbSNP151': fields[rs_i] if rs_i < len(fields) else ''}
            for col, idx in uniprot_indices.items():
                entry[col] = fields[idx] if idx < len(fields) else ''
            lookup[key] = entry
            line_count += 1

        print(f"  Loaded {line_count} variants into HRC lookup")

    return lookup, line_count


def process_chromosome(hrc_file, topmed_file, output_file):
    """
    Process a single chromosome:
      - Build HRC lookup
      - Stream TopMed file, add 2 new columns, write output

    Returns a dict of statistics for this chromosome.
    """
    print(f"  Building HRC lookup from: {os.path.basename(hrc_file)}")
    start = time.time()
    hrc_lookup, hrc_rows = build_hrc_lookup(hrc_file)
    print(f"  HRC lookup built in {time.time() - start:.1f}s")

    # Counters for summary
    total_rows = 0
    mapped_y = 0
    mapped_n = 0
    mapped_dot = 0

    # Per-column exact-match counts for the Uniprot comparison (denominator = mapped_y)
    uniprot_match_counts = {col: 0 for col in UNIPROT_COMPARE_COLS}

    start = time.time()
    with open(topmed_file, 'r') as fin, \
         open(output_file, 'w') as fout:

        # Read and write header
        header_line = fin.readline().rstrip('\n')
        headers = header_line.split('\t')
        col_idx = {name: i for i, name in enumerate(headers)}

        # Write output header with new columns
        fout.write(header_line + '\t' + 'Mapped_in_HRC' + '\t' + 'HRC_rs_dbSNP151' + '\n')

        # Get column indices for TopMed file
        ref_eq_i = col_idx.get('ref_hg19=ref_hg38')
        chr_hg19_i = col_idx.get('chr_hg19')
        pos_hg19_i = col_idx.get('pos_hg19')
        ref_hg19_i = col_idx.get('ref_hg19')
        alt_hg19_i = col_idx.get('alt_hg19')

        # TopMed-side indices for the Uniprot columns (compared when Mapped_in_HRC == 'Y')
        topmed_uniprot_indices = {col: col_idx.get(col) for col in UNIPROT_COMPARE_COLS}

        for line in fin:
            fields = line.rstrip('\n').split('\t')
            total_rows += 1

            ref_eq_val = fields[ref_eq_i] if ref_eq_i is not None and ref_eq_i < len(fields) else ''

            if ref_eq_val == 'Y':
                # Use hg19 coordinates to look up in HRC
                chr_hg19 = fields[chr_hg19_i] if chr_hg19_i is not None and chr_hg19_i < len(fields) else ''
                pos_hg19 = fields[pos_hg19_i] if pos_hg19_i is not None and pos_hg19_i < len(fields) else ''
                ref_hg19 = fields[ref_hg19_i] if ref_hg19_i is not None and ref_hg19_i < len(fields) else ''
                alt_hg19 = fields[alt_hg19_i] if alt_hg19_i is not None and alt_hg19_i < len(fields) else ''

                key = (chr_hg19, pos_hg19, ref_hg19, alt_hg19)
                hrc_entry = hrc_lookup.get(key)

                if hrc_entry is not None:
                    Mapped_in_HRC = 'Y'
                    hrc_rs = hrc_entry.get('rs_dbSNP151', '')
                    mapped_y += 1

                    # Compare the 11 Uniprot columns (exact string match) between the
                    # TopMed row and the matched HRC variant; tally per-column matches.
                    for col in UNIPROT_COMPARE_COLS:
                        tm_idx = topmed_uniprot_indices[col]
                        tm_val = fields[tm_idx] if tm_idx is not None and tm_idx < len(fields) else ''
                        hrc_val = hrc_entry.get(col, '')
                        if tm_val == hrc_val:
                            uniprot_match_counts[col] += 1
                else:
                    Mapped_in_HRC = 'N'
                    hrc_rs = ''
                    mapped_n += 1
            else:
                # ref_hg19=ref_hg38 is 'N' (or anything else)
                Mapped_in_HRC = '.'
                hrc_rs = ''
                mapped_dot += 1

            fout.write(line.rstrip('\n') + '\t' + Mapped_in_HRC + '\t' + hrc_rs + '\n')

    elapsed = time.time() - start

    # Percentage of HRC rows relative to TopMed rows
    hrc_vs_topmed_pct = (hrc_rows / total_rows * 100) if total_rows else 0.0

    print(f"  Processed {hrc_rows} HRC rows")
    print(f"  Processed {total_rows} TopMed rows in {elapsed:.1f}s")
    print(f"  HRC rows vs TopMed rows: {hrc_rows} / {total_rows} = {hrc_vs_topmed_pct:.2f}%")
    print(f"  Results: mapped_Y={mapped_y}, mapped_N={mapped_n}, mapped_dot={mapped_dot}")

    # Per-column Uniprot match stats (denominator = Mapped_in_HRC == 'Y' variants)
    uniprot_comparison = {
        'compared_variants_mapped_Y': mapped_y,
        'columns': {
            col: {
                'matches': uniprot_match_counts[col],
                'match_pct': round(uniprot_match_counts[col] / mapped_y * 100, 4) if mapped_y else 0.0,
            }
            for col in UNIPROT_COMPARE_COLS
        },
    }
    print("  Uniprot matches (of {} Mapped_in_HRC=Y): ".format(mapped_y)
          + ", ".join("{}={}".format(col, uniprot_match_counts[col]) for col in UNIPROT_COMPARE_COLS))

    return {
        'hrc_rows': hrc_rows,
        'topmed_rows': total_rows,
        'hrc_vs_topmed_pct': round(hrc_vs_topmed_pct, 4),
        'mapped_Y': mapped_y,
        'mapped_N': mapped_n,
        'mapped_dot': mapped_dot,
        'uniprot_comparison': uniprot_comparison,
    }


def extract_chr_from_filename(filename):
    """Extract chromosome identifier from filename like chr21_test.vcf -> chr21"""
    base = os.path.basename(filename)
    # Handle patterns like chr1.vcf, chr21_test.vcf, chrX.vcf etc.
    # Extract everything up to the first non-chromosome character after 'chr'
    if base.startswith('chr'):
        # Find where the chromosome number/letter ends
        rest = base[3:]  # after 'chr'
        chr_id = ''
        for ch in rest:
            if ch.isdigit() or ch in ('X', 'Y', 'M', 'x', 'y', 'm'):
                chr_id += ch
            else:
                break
        return 'chr' + chr_id
    return None


def main():
    if len(sys.argv) != 4:
        print("Usage: python3 merge_hrc_topmed.py <hrc_dir> <topmed_dir> <output_dir>")
        print()
        print("  hrc_dir:    Directory with HRC .vcf files (parameter 1)")
        print("  topmed_dir: Directory with TopMed .vcf files (parameter 2)")
        print("  output_dir: Directory for merged output files (parameter 3)")
        sys.exit(1)

    hrc_dir = sys.argv[1]
    topmed_dir = sys.argv[2]
    output_dir = sys.argv[3]

    # Validate directories
    if not os.path.isdir(hrc_dir):
        print(f"ERROR: HRC directory does not exist: {hrc_dir}")
        sys.exit(1)
    if not os.path.isdir(topmed_dir):
        print(f"ERROR: TopMed directory does not exist: {topmed_dir}")
        sys.exit(1)

    os.makedirs(output_dir, exist_ok=True)

    # Find TopMed VCF files
    topmed_files = sorted(glob.glob(os.path.join(topmed_dir, '*.vcf')))
    if not topmed_files:
        print(f"ERROR: No .vcf files found in TopMed directory: {topmed_dir}")
        sys.exit(1)

    # Build index of HRC files by chromosome
    hrc_files = glob.glob(os.path.join(hrc_dir, '*.vcf'))
    hrc_by_chr = {}
    for hf in hrc_files:
        chr_id = extract_chr_from_filename(hf)
        if chr_id:
            hrc_by_chr[chr_id] = hf

    print(f"Found {len(topmed_files)} TopMed file(s) and {len(hrc_files)} HRC file(s)")
    print()

    # Collect per-chromosome statistics
    stats_by_chr = {}

    # Process each chromosome
    for topmed_file in topmed_files:
        basename = os.path.basename(topmed_file)
        chr_id = extract_chr_from_filename(topmed_file)
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

    # Write statistics JSON file
    stats_file = os.path.join(output_dir, 'merge_hrc_topmed_stats.json')
    with open(stats_file, 'w') as sf:
        json.dump(stats_by_chr, sf, indent=2)
    print(f"Wrote per-chromosome statistics to: {stats_file}")

    print("Done.")


if __name__ == '__main__':
    main()
