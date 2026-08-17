#!/usr/bin/env python3
"""
check_hrc_rsid.py
=================

Compare the rsID reported by the raw HRC r1.1 reference VCF against the TopMed
`rs_dbSNP` value, for the variants that map between the two datasets. Purpose: decide
whether an HRC-specific rsID column is needed in merge_hrc_topmed.py — if the two agree
for every mapped SNP, it is redundant (HRC-by-RSID search can use `rs_dbSNP` +
`Mapped_in_HRC=Y`).

INPUTS
    hrc_vcf     Raw HRC VCF (standard 8-col: CHROM POS ID REF ALT QUAL FILTER INFO),
                hg19/GRCh37, chromosome as bare '18'. Header/'#'' lines are skipped.
                The rsID is the ID column (col 3); '.' means none.
    topmed_vcf  TopMed WGSA-output VCF with a NAMED-COLUMN header row. Must contain:
                chr_hg19, pos_hg19, ref_hg19, alt_hg19, ref_hg19=ref_hg38, rs_dbSNP.

MATCHING
    SNPs only (single-base REF and ALT; indels and multiallelic rows skipped). A TopMed
    row is compared only when ref_hg19=ref_hg38 == 'Y' and its hg19 key
    (chr_hg19, pos_hg19, ref_hg19, alt_hg19) is present in the HRC VCF.

COMPARISON
    rsIDs are normalised to token sets (split on ; , |, '.'/'' dropped). rs_dbSNP often
    lists several ids, so an HRC id is a genuine "miss" only when it is NOT among them:
      - HRC has no rsID                    -> "hrc_none"    (nothing to search by)
      - HRC id(s) all present in rs_dbSNP  -> "hrc_covered" (searchable via rs_dbSNP)
      - HRC id(s) absent from rs_dbSNP     -> "hrc_absent"  (genuine miss; written to TSV)
    The TSV lists each miss with the HRC id(s) not found in rs_dbSNP.

USAGE
    python3 check_hrc_rsid.py <hrc_vcf> <topmed_vcf> [diff_out.tsv]

EXAMPLE
    python3 check_hrc_rsid.py /path/HRC.r1-1/18.vcf \\
        /path/wgsa_add/output/tm-20251208/chr18.vcf hrc_rsid_diff_chr18.tsv
"""

import sys
import os
import time

SEPARATORS = str.maketrans({';': ' ', ',': ' ', '|': ' '})


def is_snp(ref, alt):
    return len(ref) == 1 and len(alt) == 1 and ref.isalpha() and alt.isalpha()


def norm_chr(value):
    """Bare chromosome token: 'chr18' -> '18', '18' -> '18', 'chrX' -> 'X'."""
    v = str(value).strip()
    if v[:3].lower() == 'chr':
        v = v[3:]
    return v.upper() if v.upper() in ('X', 'Y', 'M', 'MT') else v


def rsid_tokens(value):
    """Set of rsID tokens, with '.'/'' treated as none."""
    if value is None:
        return set()
    toks = value.translate(SEPARATORS).split()
    return {t for t in toks if t and t != '.'}


def build_hrc_rsid_lookup(hrc_vcf):
    """(chr, pos, ref, alt) -> raw ID string, SNPs only. '#'' lines skipped."""
    lookup = {}
    rows = 0
    with open(hrc_vcf) as f:
        for line in f:
            if line.startswith('#'):
                continue
            fields = line.rstrip('\n').split('\t')
            if len(fields) < 5:
                continue
            chrom, pos, vid, ref, alt = fields[0], fields[1], fields[2], fields[3], fields[4]
            if ',' in alt or not is_snp(ref, alt):
                continue
            lookup[(norm_chr(chrom), pos, ref.upper(), alt.upper())] = vid
            rows += 1
    return lookup, rows


def main():
    if len(sys.argv) not in (3, 4):
        print("Usage: python3 check_hrc_rsid.py <hrc_vcf> <topmed_vcf> [diff_out.tsv]")
        sys.exit(1)

    hrc_vcf = sys.argv[1]
    topmed_vcf = sys.argv[2]
    diff_out = sys.argv[3] if len(sys.argv) == 4 else 'hrc_rsid_diff.tsv'

    for path in (hrc_vcf, topmed_vcf):
        if not os.path.isfile(path):
            print(f"ERROR: file not found: {path}")
            sys.exit(1)

    print(f"Building HRC rsID lookup from: {hrc_vcf}")
    start = time.time()
    hrc_lookup, hrc_rows = build_hrc_rsid_lookup(hrc_vcf)
    print(f"  {hrc_rows} HRC SNP rows loaded in {time.time() - start:.1f}s")

    total = 0
    considered_Y = 0        # ref_hg19=ref_hg38 == 'Y' SNP rows
    mapped = 0              # of those, present in HRC
    counts = {'hrc_covered': 0, 'hrc_absent': 0, 'hrc_none': 0}

    start = time.time()
    with open(topmed_vcf) as fin, open(diff_out, 'w') as fout:
        header = fin.readline().rstrip('\n').split('\t')
        col = {name: i for i, name in enumerate(header)}
        required = ['chr_hg19', 'pos_hg19', 'ref_hg19', 'alt_hg19', 'ref_hg19=ref_hg38', 'rs_dbSNP']
        missing = [c for c in required if c not in col]
        if missing:
            print(f"ERROR: TopMed file missing required column(s): {missing}")
            sys.exit(1)

        fout.write('\t'.join(['chr_hg19', 'pos_hg19', 'ref_hg19', 'alt_hg19',
                              'hrc_rsid', 'topmed_rs_dbSNP',
                              'hrc_ids_absent_from_rs_dbSNP']) + '\n')

        def get(fields, name):
            i = col[name]
            return fields[i] if i < len(fields) else ''

        for line in fin:
            fields = line.rstrip('\n').split('\t')
            total += 1

            if get(fields, 'ref_hg19=ref_hg38') != 'Y':
                continue
            c19 = get(fields, 'chr_hg19')
            p19 = get(fields, 'pos_hg19')
            r19 = get(fields, 'ref_hg19')
            a19 = get(fields, 'alt_hg19')
            if not is_snp(r19, a19):
                continue
            considered_Y += 1

            hrc_id = hrc_lookup.get((norm_chr(c19), p19, r19.upper(), a19.upper()))
            if hrc_id is None:
                continue
            mapped += 1

            tm_rs = get(fields, 'rs_dbSNP')
            hrc_set = rsid_tokens(hrc_id)
            tm_set = rsid_tokens(tm_rs)

            if not hrc_set:
                # HRC has no rsID at this site — nothing to search by.
                counts['hrc_none'] += 1
                continue

            # rs_dbSNP often lists several ids; the HRC id is a genuine "miss" only if
            # it is NOT among them. A subset (all HRC ids present in rs_dbSNP) is fine.
            missing = hrc_set - tm_set
            if not missing:
                counts['hrc_covered'] += 1
                continue

            counts['hrc_absent'] += 1
            fout.write('\t'.join([c19, p19, r19, a19, hrc_id, tm_rs,
                                  ';'.join(sorted(missing))]) + '\n')

    elapsed = time.time() - start
    print(f"  Scanned {total} TopMed rows in {elapsed:.1f}s")
    print()
    hrc_with_id = counts['hrc_covered'] + counts['hrc_absent']
    print("=== HRC rsID vs TopMed rs_dbSNP (mapped SNPs only) ===")
    print(f"  TopMed rows scanned                        : {total}")
    print(f"  ref_hg19=ref_hg38=='Y' SNP rows            : {considered_Y}")
    print(f"  mapped to HRC (compared)                   : {mapped}")
    print(f"    HRC has an rsID                          : {hrc_with_id}")
    print(f"      HRC id(s) present in rs_dbSNP (OK)     : {counts['hrc_covered']}")
    print(f"      HRC id(s) ABSENT from rs_dbSNP (miss)  : {counts['hrc_absent']}")
    print(f"    HRC has no rsID                          : {counts['hrc_none']}")
    print()
    print("Note: rs_dbSNP may list several ids; an HRC id is a 'miss' only if it is not")
    print("among them — i.e. that HRC rsID cannot be found via an rs_dbSNP search.")
    print()
    if mapped == 0:
        print("VERDICT: no mapped SNPs to compare — check inputs / chromosome match.")
    elif counts['hrc_absent'] == 0:
        print(f"VERDICT: every HRC rsID is present in rs_dbSNP for all {hrc_with_id} id-bearing SNPs —")
        print("         rs_dbSNP + Mapped_in_HRC=Y fully covers HRC rsID search; no HRC rsID column needed.")
    else:
        print(f"VERDICT: {counts['hrc_absent']} of {hrc_with_id} id-bearing mapped SNPs have an HRC rsID")
        print(f"         absent from rs_dbSNP (genuine misses) — see {diff_out}")


if __name__ == '__main__':
    main()
