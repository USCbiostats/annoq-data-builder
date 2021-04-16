from config.base import ROOT_DIR, dir_path, file_path
import pickle
import json
import shutil
from os import mkdir, path as ospath
import argparse
from intervaltree import IntervalTree


def main():
    parser = parse_arguments()
    output_dir = ospath.join(ROOT_DIR, parser.output_dir)
    pickle_file = ospath.join(ROOT_DIR, parser.pickle_file)

    with open(pickle_file, 'rb') as f:
        thawed = pickle.load(f)

        # write whole file (too long to open)
        write_to_json(thawed, ospath.join(output_dir, 'all.json'))

        # write each high level dict key, panther data, anno_tree, etc,
        for key, val in thawed.items():
            write_to_json(val, ospath.join(output_dir, key+'.json'))


def parse_arguments():
    parser = argparse.ArgumentParser(description='Visualizing the panther data',
                                     epilog='I hope this works!')
    parser.add_argument('-o', '--output', dest='output_dir', required=True,
                        type=dir_path, help='Output folder')

    parser.add_argument('-p', '--pickle', dest='pickle_file', required=True,
                        type=file_path, help='Input pickle file')

    return parser.parse_args()


def create_working_dir(directory):
    try:
        if ospath.exists(directory):
            shutil.rmtree(directory)
        mkdir(directory)
        print(directory + "(temp work output directory) created")
    except:
        print('json path exists')


# Just dumping it as string until we find something else


class NonPantherEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, IntervalTree):
            return str(obj)
        # Let the base class default method raise the TypeError
        return json.JSONEncoder.default(self, obj)


def write_to_json(data, output_file):
    with open(output_file, 'w', encoding='utf-8') as outfile:
        json.dump(data, outfile, cls=NonPantherEncoder,
                  ensure_ascii=False, indent=4)


def write_to_txt(data, output_file):
    with open(output_file, 'w') as f:
        f.write(data)


if __name__ == "__main__":
    main()
