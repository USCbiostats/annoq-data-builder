#!/usr/bin/env python3
"""
merge_hrc_topmed.py
===================

WHAT:
    Merges HRC (v5) annotation data into TopMed chromosome VCF files by adding
    two new columns: 'Mapped_in_hrc' and 'HRC_rs_dbSNP151'.

WHERE:
    - Parameter 1 (hrc_dir):    Directory containing HRC .vcf files (e.g. v5/)
    - Parameter 2 (topmed_dir): Directory containing TopMed .vcf files (e.g. tm-20251208/)
    - Parameter 3 (output_dir): Directory for final merged chromosome files

WHEN:
    Run after both HRC and TopMed annotation pipelines have produced their
    per-chromosome .vcf output files.

WHY:
    To determine which TopMed variants also exist in the HRC dataset (Mapped_in_hrc=Y)
    and carry over the HRC rs_dbSNP151 identifier (HRC_rs_dbSNP151).

HOW:
    For each chromosome .vcf file found in the TopMed directory:
      1. Find the matching HRC file (same filename) in the HRC directory.
      2. Build an in-memory lookup dictionary from the HRC file keyed on
         (chr, pos, ref, alt) -> rs_dbSNP151.
      3. Stream through each row of the TopMed file:
         - If ref_hg19=ref_hg38 == 'Y':
             Look up (chr_hg19, pos_hg19, ref_hg19, alt_hg19) in the HRC dict.
             * Found:     Mapped_in_hrc = 'Y'; HRC_rs_dbSNP151 = HRC rs_dbSNP151 value
             * Not found: Mapped_in_hrc = 'N'; HRC_rs_dbSNP151 = ''
         - If ref_hg19=ref_hg38 == 'N':
             Mapped_in_hrc = '.'; HRC_rs_dbSNP151 = ''
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


def build_hrc_lookup(hrc_file):
    """
    Read the HRC file and build a dictionary keyed on (chr, pos, ref, alt).
    Values are the rs_dbSNP151 identifier.

    The key columns (chr, pos, ref, alt) and rs_dbSNP151 are required; if any is
    missing the lookup cannot be built and an empty dict is returned.
    """
    lookup = {}
    with open(hrc_file, 'r') as f:
        header_line = f.readline().rstrip('\n')
        headers = header_line.split('\t')
        col_idx = {name: i for i, name in enumerate(headers)}

        required = ['chr', 'pos', 'ref', 'alt', 'rs_dbSNP151']
        missing_required = [col for col in required if col not in col_idx]
        if missing_required:
            print(f"  WARNING: Required column(s) {missing_required} not found in "
                  f"HRC file {hrc_file}; skipping this chromosome")
            return lookup

        chr_i = col_idx['chr']
        pos_i = col_idx['pos']
        ref_i = col_idx['ref']
        alt_i = col_idx['alt']
        rs_i = col_idx['rs_dbSNP151']

        line_count = 0
        for line in f:
            fields = line.rstrip('\n').split('\t')
            key = (fields[chr_i], fields[pos_i], fields[ref_i], fields[alt_i])
            lookup[key] = fields[rs_i] if rs_i < len(fields) else ''
            line_count += 1

        print(f"  Loaded {line_count} variants into HRC lookup")

    return lookup


def process_chromosome(hrc_file, topmed_file, output_file):
    """
    Process a single chromosome:
      - Build HRC lookup
      - Stream TopMed file, add 2 new columns, write output
    """
    print(f"  Building HRC lookup from: {os.path.basename(hrc_file)}")
    start = time.time()
    hrc_lookup = build_hrc_lookup(hrc_file)
    print(f"  HRC lookup built in {time.time() - start:.1f}s")

    # Counters for summary
    total_rows = 0
    mapped_y = 0
    mapped_n = 0
    mapped_dot = 0

    start = time.time()
    with open(topmed_file, 'r') as fin, \
         open(output_file, 'w') as fout:

        # Read and write header
        header_line = fin.readline().rstrip('\n')
        headers = header_line.split('\t')
        col_idx = {name: i for i, name in enumerate(headers)}

        # Write output header with new columns
        fout.write(header_line + '\t' + 'Mapped_in_hrc' + '\t' + 'HRC_rs_dbSNP151' + '\n')

        # Get column indices for TopMed file
        ref_eq_i = col_idx.get('ref_hg19=ref_hg38')
        chr_hg19_i = col_idx.get('chr_hg19')
        pos_hg19_i = col_idx.get('pos_hg19')
        ref_hg19_i = col_idx.get('ref_hg19')
        alt_hg19_i = col_idx.get('alt_hg19')

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
                hrc_rs = hrc_lookup.get(key)

                if hrc_rs is not None:
                    Mapped_in_hrc = 'Y'
                    mapped_y += 1
                else:
                    Mapped_in_hrc = 'N'
                    hrc_rs = ''
                    mapped_n += 1
            else:
                # ref_hg19=ref_hg38 is 'N' (or anything else)
                Mapped_in_hrc = '.'
                hrc_rs = ''
                mapped_dot += 1

            fout.write(line.rstrip('\n') + '\t' + Mapped_in_hrc + '\t' + hrc_rs + '\n')

    elapsed = time.time() - start
    print(f"  Processed {total_rows} TopMed rows in {elapsed:.1f}s")
    print(f"  Results: mapped_Y={mapped_y}, mapped_N={mapped_n}, mapped_dot={mapped_dot}")


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

        process_chromosome(hrc_file, topmed_file, output_file)
        print()

    print("Done.")


if __name__ == '__main__':
    main()
