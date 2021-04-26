import argparse
from os.path import isdir, isfile, join, dirname
import os
import json
import pickle


def file_path(path):
    if isfile(path):
        return path
    else:
        raise argparse.ArgumentTypeError(
            f"{path} is not a valid path")


def dir_path(path):
    if isdir(path):
        return path
    else:
        raise argparse.ArgumentTypeError(
            f"{path} is not a valid directory")


def project_dir(base):
    """Absolute path to a file from current directory."""
    return os.path.abspath(
        join(dirname(__file__), base).replace('\\', '/')
    )


ROOT_DIR = project_dir('.')


def load_json(filepath):
    with open(filepath) as f:
        return json.load(f)


def load_pickle(filepath):
    with open(filepath, 'rb') as f:
        return pickle.load(f)
