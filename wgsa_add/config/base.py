import argparse
from os.path import isdir, isfile, join, dirname
import os


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


ROOT_DIR = project_dir('..')
