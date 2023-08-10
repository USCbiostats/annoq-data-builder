import argparse
import json

from tools.base import load_json, write_to_json

def remove_labels(json_data):
    # Find indices of cols that end with "_list"
    list_indices = [i for i, col in enumerate(json_data["cols"]) if col.endswith("_list")]

    # Remove those cols
    json_data["cols"] = [col for i, col in enumerate(json_data["cols"]) if i not in list_indices]

    # Remove corresponding values in data arrays
    for key in json_data["data"]:
        json_data["data"][key] = [val for i, val in enumerate(json_data["data"][key]) if i not in list_indices]

    return json_data


def main(): 
  parser = argparse.ArgumentParser()
  parser.add_argument('-i', dest='in_json', required=True)
  parser.add_argument('-o', dest='out_json', required=True)
  args = parser.parse_args()
  json_data = load_json(args.in_json)
  json_data = remove_labels(json_data)

  write_to_json(json_data, args.out_json, indent=2)


if __name__ == "__main__":
    main()

#python3 -m tools.panther_data_cleaner -i ../annoq-data/enhancer/panther_data.json -o ../annoq-data/enhancer/panther_no_labels_data.json