#!/bin/bash

set -x

mkdir -p ~/.ssh/
ssh-keyscan github.com >> ~/.ssh/known_hosts
git submodule update --init
git fetch --recurse-submodules
git submodule update --remote --checkout
