#!/usr/bin/env python3

"""This script adds and removes one message id and a correspondent message
string in order to provoke gettext treat this file as changed. Useful for
limiting the length of msg_id and msg_str lines in .po files.

Usage:

    ./fake_msg.py add  # add msg_id
    make update-po
    ./fake_msg.py rm  # remove msg_id
"""

import os
import argparse
import re


parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument('action', type=str, choices=['add', 'rm'],
                    help='action to perform on po files (add, rm)')

fake_lines = '\n\nmsgid "fake_message"\nmsgstr "fake_translation"\n'
fake_lines_commented = '\n\n#~ msgid "fake_message"\n#~ msgstr "fake_translation"\n'
fake_lines_lone = '\n#~ msgid "fake_message"\n#~ msgstr "fake_translation"\n'
pattern_list = [
    "# .*?\nmsgid \"\"\nmsgstr \"\"\n.*?\n\n",
    "#,.*?\nmsgid \"\"\nmsgstr \"\"\n.*?\n\n",
    "msgid \"\"\nmsgstr \"\"\n.*?\n\n",
]


def remove_meta(file):
    with open(file, "r+") as f:
        d = f.read()
        for pattern_meta in pattern_list:
            d = re.sub(pattern_meta, '', d)
            d = re.sub(pattern_meta, '\n', d, flags=re.DOTALL)
        f.seek(0)
        f.write(d)
        f.truncate()


def process_po_files(action) -> int:
    counter = 0
    for path, folders, files in os.walk('ru/LC_MESSAGES'):
        for file in files:
            if os.path.splitext(file)[1] == '.po':

                file_path = os.path.join(path, file)
                remove_meta(file_path)

                if action == 'add':

                    with open(file_path, 'a') as f:
                        f.write(fake_lines)
                    counter += 1

                elif action == 'rm':

                    with open(file_path, "r+") as f:
                        s = f.read()
                        d = s.replace(fake_lines, '').replace(fake_lines_commented, '').replace(fake_lines_lone, '')

                        if d != s:
                            f.seek(0)
                            f.write(d)
                            f.truncate()
                            counter += 1
    return counter


if __name__ == "__main__":

    args = parser.parse_args()
    number = process_po_files(args.action)

    print(f"Processed {number} files")
