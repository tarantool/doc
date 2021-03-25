#! /usr/bin/env python3
import argparse
from glob import glob
from polib import pofile, POFile

parser = argparse.ArgumentParser(description='Cleanup PO and POT files')
parser.add_argument('extension', type=str, choices=['po', 'pot', 'both'],
                    help='cleanup files with extension: po, pot or both')


def cleanup_files(extension):
    mask = f'**/*.{extension}'
    for file_path in glob(mask, recursive=True):
        print(f'cleanup {file_path}')
        po_file: POFile = pofile(file_path)
        po_file.header = ''
        po_file.metadata = {}
        po_file.metadata_is_fuzzy = False
        po_file.save()


if __name__ == "__main__":

    args = parser.parse_args()

    if args.extension in ['po', 'both']:
        cleanup_files('po')

    if args.extension in ['pot', 'both']:
        cleanup_files('pot')
