import argparse
from pathlib import Path
import pandas as pd


def main():
    parser = parse_arguments()

    paths = Path(parser.in_dir).glob("*.json")
    df = pd.DataFrame([pd.read_json(p, typ="series") for p in paths])
    df = df.append(df.sum(numeric_only=True), ignore_index=True)
    df.to_csv(parser.out_file)


def parse_arguments():
    parser = argparse.ArgumentParser(description='Adding all the counts')
    parser.add_argument('-f', dest='in_dir', required=True)
    parser.add_argument('-o', dest='out_file', required=True)

    return parser.parse_args()


if __name__ == "__main__":
    main()

# python3 add_counts.py  -f ../../../annoq-data/counts/HRC_03_07_19 -o ../../../annoq-data/enh_counts.csv
