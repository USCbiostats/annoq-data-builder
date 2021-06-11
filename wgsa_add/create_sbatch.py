import argparse

parser = argparse.ArgumentParser(description='Create slurm jobs')
parser.add_argument('-t', '--template_file', dest='template_file', required=True)
parser.add_argument('-i', '--in_file', dest='in_file', required=True)
parser.add_argument('-o', '--out_dir', dest='in_dir', required=True)

args = parser.parse_args()

with open(args.template_file) as fp:
    # make column names
    template = fp.read().rstrip()

    print(template.format(in_file=args.in_file, out_dir=args.out_dir))
