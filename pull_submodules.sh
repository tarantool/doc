#!/bin/bash

set -x

mkdir -p ~/.ssh/
ssh-keyscan github.com >> ~/.ssh/known_hosts
git submodule init
git submodule update
git pull --recurse-submodules
git submodule update --remote --merge

project_root=$(pwd)
echo "${project_root}"
cartridge_root="${project_root}/modules/cartridge"
rst_src="${project_root}/modules/cartridge/build.luarocks/build.rst"
rst_dest="${project_root}/doc/book/cartridge"
pot_src="${project_root}/modules/cartridge/build.luarocks/build.rst/locale"
pot_dest="${project_root}/locale/book/cartridge"
po_src="${project_root}/modules/cartridge/build.luarocks/build.rst/locale/ru/LC_MESSAGES"
po_dest="${project_root}/locale/ru/LC_MESSAGES/book/cartridge"
cartridge_cli_root="${project_root}/modules/cartridge-cli"
cartridge_cli_dest="${rst_dest}/cartridge_cli"
cartridge_cli_index_dest="${cartridge_cli_dest}/index.rst"
monitoring_root="${project_root}/modules/metrics/doc/monitoring"
monitoring_dest="${project_root}/doc/book"
monitoring_grafana_root="${project_root}/modules/grafana-dashboard/doc/monitoring"
luatest_root="${project_root}/modules/luatest/"
luatest_dest="${project_root}/doc/reference/reference_rock/luatest"

cartridge_kubernetes_root="${project_root}/modules/tarantool-operator/doc/cartridge_kubernetes_guide"
cartridge_kubernetes_dest="${rst_dest}/"

cd "${luatest_root}"
ldoc --ext=rst --dir=rst --toctree="API" .
cd "${luatest_dest}"
yes | cp -fa "${luatest_root}/rst/." "${luatest_dest}"
yes | cp "${luatest_root}/README.rst" "${luatest_dest}"

mkdir -p "${monitoring_dest}"
yes | cp -rf "${monitoring_root}" "${monitoring_dest}/"
yes | cp -rf "${monitoring_grafana_root}" "${monitoring_dest}/"

mkdir -p "${cartridge_cli_dest}"
yes | cp -rf "${cartridge_cli_root}/README.rst" "${cartridge_cli_index_dest}"

mkdir -p "${cartridge_kubernetes_dest}"
yes | cp -rf "${cartridge_kubernetes_root}" "${cartridge_kubernetes_dest}"

cd "${cartridge_root}" || exit
tarantoolctl rocks install \
  https://raw.githubusercontent.com/tarantool/LDoc/tarantool/ldoc-scm-2.rockspec \
  --server=http://rocks.moonscript.org
CMAKE_DUMMY_WEBUI=true tarantoolctl rocks make

cd "${rst_src}" || exit
mkdir -p "${rst_dest}"
find . -iregex '.*\.\(rst\|png\)$' -exec cp -r --parents {} "${rst_dest}" \;

cd "${pot_src}" || exit
mkdir -p "${pot_dest}"
find . -name '*.pot' -exec cp -r --parents {} "${pot_dest}" \;

cd "${po_src}" || exit
mkdir -p "${po_dest}"
find . -name '*.po' -exec cp -r --parents {} "${po_dest}" \;

sed -i -e '/Cartridge CLI<cartridge_cli\/index>/a\' -e '\ \ \ Cartridge Kubernetes guide<cartridge_kubernetes_guide/index>' "${rst_dest}/index.rst"
