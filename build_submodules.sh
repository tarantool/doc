#!/bin/bash

set -x

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

tntcxx_root="${project_root}/modules/tntcxx"
tntcxx_gs_dest="${project_root}/doc/getting_started/"
tntcxx_api_dest="${project_root}/doc/book/connectors/"

cp README.rst doc/contributing/docs/_includes/README.rst

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

mkdir -p "${tntcxx_api_dest}/cxx/"
yes | cp -rf "${tntcxx_root}/doc/tntcxx_getting_started.rst" "${tntcxx_gs_dest}/getting_started_cxx.rst"
yes | cp -rf "${tntcxx_root}/examples/" "${tntcxx_gs_dest}/_includes/examples"
yes | cp -rf "${tntcxx_root}/doc/tntcxx_api.rst" "${tntcxx_api_dest}/cxx/"

cd "${cartridge_root}" || exit
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
