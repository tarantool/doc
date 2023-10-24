#! /usr/bin/env python3

import os
import subprocess


modules_dir = 'modules'
modules = {
    'grafana-dashboard': 'INPUT_GRAFANA',
    'luatest': 'INPUT_LUATEST',
    'metrics': 'INPUT_METRICS',
    'tntcxx': 'INPUT_CPP_DRIVER',
}
workdir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'modules')


def main():
    """
    set -x

    mkdir -p ~/.ssh/
    ssh-keyscan github.com >> ~/.ssh/known_hosts
    git submodule update --init
    git fetch --recurse-submodules
    git submodule update --remote --checkout
    """

    in_ci = os.environ.get("CI")
    if not in_ci:
        mkdir_p("~/.ssh/")
        commands = "set -ex ;" \
                   "ssh-keyscan github.com >> ~/.ssh/known_hosts ;" \
                   "git submodule update --init ;" \
                   "git fetch --recurse-submodules"

        subprocess.check_call(commands, shell=True)

    for directory, git_ref_variable in modules.items():
        git_ref = os.environ.get(git_ref_variable, 'origin/master')
        checkout_submodule(directory, git_ref)


def checkout_submodule(directory, git_ref='origin/master'):
    print(f'Checking out {directory} module into {git_ref}')
    path = os.path.join(workdir, directory)
    print(path)
    subprocess.check_call('set -ex ; git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"', shell=True,
                          cwd=path)
    git_checkout = f'set -ex ; git remote update ; git checkout {git_ref}'
    subprocess.check_call(git_checkout, shell=True,
                          cwd=path)


def mkdir_p(path):
    """
    Creates a directory with subdirectories, just like `mkdir -p path`
    """
    import pathlib
    pathlib.Path(path).mkdir(parents=True, exist_ok=True)


if __name__ == "__main__":
    main()
