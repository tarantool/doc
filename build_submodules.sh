#!/bin/bash

set -xe -o pipefail -o nounset

project_root=$(pwd)

# Translations
po_dest="${project_root}/locale/ru/LC_MESSAGES"


# Copy Building Tarantool Docs guide
cp README.rst doc/contributing/docs/_includes/README.rst


# Cartridge
cartridge_root="${project_root}/modules/cartridge"

# Build Cartridge to extract docs
cd "${cartridge_root}" || exit
CMAKE_DUMMY_WEBUI=true tarantoolctl rocks make

# Copy Cartridge docs, including diagrams and images
cartridge_rst_src="${cartridge_root}/build.luarocks/build.rst"
cartridge_rst_dest="${project_root}/doc/book/cartridge"
cd "${cartridge_rst_src}" || exit
mkdir -p "${cartridge_rst_dest}"
find . -iregex '.*\.\(rst\|png\|puml\|svg\)$' -exec cp -r --parents {} "${cartridge_rst_dest}" \;

# Copy translation templates
cartridge_pot_src="${cartridge_root}/build.luarocks/build.rst/locale"
cartridge_pot_dest="${project_root}/locale/book/cartridge"
cd "${cartridge_pot_src}" || exit
mkdir -p "${cartridge_pot_dest}"
find . -name '*.pot' -exec cp -rv --parents {} "${cartridge_pot_dest}" \;

# Copy translations
cartridge_po_src="${cartridge_root}/build.luarocks/build.rst/locale/ru/LC_MESSAGES"
cartridge_po_dest="${po_dest}/book/cartridge"
cd "${cartridge_po_src}" || exit
mkdir -p "${cartridge_po_dest}"
find . -name '*.po' -exec cp -rv --parents {} "${cartridge_po_dest}" \;


# Cartridge CLI
cartridge_cli_root="${project_root}/modules/cartridge-cli/doc"
cartridge_cli_dest="${cartridge_rst_dest}/cartridge_cli"
cartridge_cli_po_dest="${po_dest}/book/cartridge/cartridge_cli"

# Copy Cartridge CLI docs, including diagrams and images
mkdir -p "${cartridge_cli_dest}"
cd ${cartridge_cli_root} || exit
find . -iregex '.*\.\(rst\|png\|puml\|svg\)$' -exec cp -rv --parents {} "${cartridge_cli_dest}" \;

# Copy translations
mkdir -p "${cartridge_cli_po_dest}"
cd "${cartridge_cli_root}/locale/ru/LC_MESSAGES/doc/" || exit
find . -name '*.po' -exec cp -rv --parents {} "${cartridge_cli_po_dest}" \;

# Add Cartridge Kubernetes guide to the Cartridge toctree right after Cartridge CLI
sed -i -e '/Cartridge CLI <cartridge_cli\/index>/a\' -e '\ \ \ Cartridge Kubernetes guide <cartridge_kubernetes_guide/index>' "${cartridge_rst_dest}/index.rst"


# Monitoring
# monitoring_root="${project_root}/modules/metrics/doc/monitoring"
# monitoring_dest="${project_root}/doc/book"
# monitoring_grafana_root="${project_root}/modules/grafana-dashboard/doc/monitoring"

# # Copy monitoring docs to the right destination
# mkdir -p "${monitoring_dest}"
# cp -rfv "${monitoring_root}" "${monitoring_dest}/"
# cp -rfv "${monitoring_grafana_root}" "${monitoring_dest}/"


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


# Kubernetes operator
cartridge_kubernetes_root="${project_root}/modules/tarantool-operator/doc/cartridge_kubernetes_guide"
cartridge_kubernetes_dest="${cartridge_rst_dest}/"

# Copy Kubernetes operator docs to the right place
mkdir -p "${cartridge_kubernetes_dest}"
cp -rfv "${cartridge_kubernetes_root}" "${cartridge_kubernetes_dest}"


# Tarantool C++ connector
# tntcxx_root="${project_root}/modules/tntcxx"
# tntcxx_gs_dest="${project_root}/doc/getting_started"
# tntcxx_api_dest="${project_root}/doc/book/connectors"

# Copy Tarantool C++ connector docs to the right places
# mkdir -p "${tntcxx_api_dest}/cxx/"
# mkdir -p "${tntcxx_gs_dest}/_includes"
# cp -rfv "${tntcxx_root}/doc/tntcxx_getting_started.rst" "${tntcxx_gs_dest}/getting_started_cxx.rst"
# cp -rfv "${tntcxx_root}/examples/" "${tntcxx_gs_dest}/_includes/examples/"
# cp -rfv "${tntcxx_root}/doc/tntcxx_api.rst" "${tntcxx_api_dest}/cxx/"
