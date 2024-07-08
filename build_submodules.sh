#!/bin/bash

set -xe -o pipefail -o nounset

project_root=$(pwd)

# Translations
po_dest="${project_root}/locale/ru/LC_MESSAGES"


# Copy Building Tarantool Docs guide
cp README.rst doc/contributing/docs/_includes/README.rst

# Luatest
luatest_root="${project_root}/modules/luatest"
luatest_dest="${project_root}/doc/reference/reference_rock/luatest"

# Generate Luatest docs
cd "${luatest_root}"
ldoc --ext=rst --dir=rst --toctree="API" .

# Copy Luatest docs to the right place
cd "${luatest_dest}"
cp -fa "${luatest_root}/rst/." "${luatest_dest}"
cp "${luatest_root}/README.rst" "${luatest_dest}"
mkdir -p "${luatest_dest}/_includes/"
mv -fv "${luatest_dest}/index.rst" "${luatest_dest}/_includes/"

# Tarantool C++ connector
tntcxx_root="${project_root}/modules/tntcxx"
tntcxx_howto_dest="${project_root}/doc/how-to"
tntcxx_api_dest="${project_root}/doc/book/connectors"

# Copy Tarantool C++ connector docs to the right places
mkdir -p "${tntcxx_api_dest}/cxx/"
mkdir -p "${tntcxx_howto_dest}/_includes"
cp -rfv "${tntcxx_root}/doc/tntcxx_getting_started.rst" "${tntcxx_howto_dest}/getting_started_cxx.rst"
cp -rfv "${tntcxx_root}/examples/" "${tntcxx_howto_dest}/_includes/examples/"
cp -rfv "${tntcxx_root}/doc/tntcxx_api.rst" "${tntcxx_api_dest}/cxx/"
