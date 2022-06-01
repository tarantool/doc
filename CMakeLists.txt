cmake_minimum_required(VERSION 2.8.12)

project(tarantool-doc)

# Set ldoc executable
set(LUA_EXECUTABLE /usr/bin/lua)
set(LDOC_PATH /usr/local/ldoc/ldoc.lua)
set(LDOC_EXECUTABLE "${LUA_EXECUTABLE} ${LDOC_PATH}")

set(PYTHON3_EXECUTABLE "python3")

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})
set(CMAKE_INCLUDE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${CMAKE_INCLUDE_PATH})

include(FindOptionalPackage)
include(FindPackageMessage)

include(cmake/FindSphinx.cmake)
find_package(Sphinx REQUIRED)
find_package(LATEX)

# Get version
set (PACKAGE_VERSION "")
set (TARANTOOL_VERSION "")

# Try to get version from VERSION file
set(VERSION_FILE_ORIG "${PROJECT_SOURCE_DIR}/VERSION")
set(VERSION_FILE "${PROJECT_BINARY_DIR}/VERSION")
if (EXISTS "${VERSION_FILE_ORIG}")
    file (STRINGS "${VERSION_FILE_ORIG}" TARANTOOL_VERSION)
elseif (EXISTS "${VERSION_FILE}")
    file (STRINGS "${VERSION_FILE}" TARANTOOL_VERSION)
endif()

if (NOT TARANTOOL_VERSION)
    message (FATAL_ERROR "Unable to retrieve version from git or ${VERSION_FILE} file.")
endif()

# Split full version (git describe --long) to get components
string(REPLACE "-" "." TARANTOOL_VERSION_LIST ${TARANTOOL_VERSION})
string(REPLACE "." ";" TARANTOOL_VERSION_LIST ${TARANTOOL_VERSION_LIST})
LIST(GET TARANTOOL_VERSION_LIST 0 CPACK_PACKAGE_VERSION_MAJOR)
LIST(GET TARANTOOL_VERSION_LIST 1 CPACK_PACKAGE_VERSION_MINOR)
LIST(GET TARANTOOL_VERSION_LIST 2 CPACK_PACKAGE_VERSION_PATCH)

set(PACKAGE_VERSION "${CPACK_PACKAGE_VERSION_MAJOR}")
set(PACKAGE_VERSION "${PACKAGE_VERSION}.${CPACK_PACKAGE_VERSION_MINOR}")
set(PACKAGE_VERSION "${PACKAGE_VERSION}.${CPACK_PACKAGE_VERSION_PATCH}")

find_package_message(TARANTOOL_VERSION
    "Tarantool version is ${TARANTOOL_VERSION} (${PACKAGE_VERSION})"
    "${PACKAGE_VERSION}")

set(SPHINX_OUTPUT_DIR              "${CMAKE_CURRENT_BINARY_DIR}/output")

set(SPHINX_BUILD_LOCALE_DIR        "${SPHINX_OUTPUT_DIR}/_locale_build/")

set(SPHINX_BUILD_SINGLEHTML_DIR    "${SPHINX_OUTPUT_DIR}/doctrees/single/en/")
set(SPHINX_BUILD_SINGLEHTML_RU_DIR "${SPHINX_OUTPUT_DIR}/doctrees/single/ru/")

set(SPHINX_BUILD_HTML_DIR          "${SPHINX_OUTPUT_DIR}/_html_en/")
set(SPHINX_BUILD_HTML_RU_DIR       "${SPHINX_OUTPUT_DIR}/_html_ru/")

set(SPHINX_BUILD_HTML_OLD_DIR          "${SPHINX_OUTPUT_DIR}/_html_old_en/")
set(SPHINX_BUILD_HTML_RU_OLD_DIR       "${SPHINX_OUTPUT_DIR}/_html_old_ru/")

set(SPHINX_BUILD_LATEX_DIR         "${SPHINX_OUTPUT_DIR}/_latex_en/")
set(SPHINX_BUILD_LATEX_RU_DIR      "${SPHINX_OUTPUT_DIR}/_latex_ru/")

set(SPHINX_BUILD_JSON_EN_DIR       "${SPHINX_OUTPUT_DIR}/doctrees/json/en/")
set(SPHINX_BUILD_JSON_RU_DIR       "${SPHINX_OUTPUT_DIR}/doctrees/json/ru")

set(SPHINX_EN_HTML_DIR             "${SPHINX_OUTPUT_DIR}/html/en/")
set(SPHINX_EN_AUTOBUILD_DIR        "${SPHINX_OUTPUT_DIR}/html_auto/en/")
set(SPHINX_RU_AUTOBUILD_DIR        "${SPHINX_OUTPUT_DIR}/html_auto/ru/")
set(SPHINX_RU_HTML_DIR             "${SPHINX_OUTPUT_DIR}/html/ru/")
set(SPHINX_EN_HTML_OLD_DIR         "${SPHINX_OUTPUT_DIR}/html_old/en/")
set(SPHINX_RU_HTML_OLD_DIR         "${SPHINX_OUTPUT_DIR}/html_old/ru/")
set(SPHINX_EN_JSON_DIR             "${SPHINX_OUTPUT_DIR}/json/_build_en/json")
set(SPHINX_RU_JSON_DIR             "${SPHINX_OUTPUT_DIR}/json/_build_ru/json")

set(SPHINX_BUILD_EPUB_DIR          ${SPHINX_OUTPUT_DIR}/_epub_en/)
set(SPHINX_BUILD_EPUB_RU_DIR       ${SPHINX_OUTPUT_DIR}/_epub_ru/)
set(SPHINX_EN_EPUB_DIR             ${SPHINX_OUTPUT_DIR}/epub/en/)
set(SPHINX_RU_EPUB_DIR             ${SPHINX_OUTPUT_DIR}/epub/ru/)

set(LDOC_CARTRIDGE_SOURCE_DIR      "${CMAKE_CURRENT_SOURCE_DIR}/modules/cartridge")
set(LDOC_CARTRIDGE_DEST_DIR        "${CMAKE_CURRENT_SOURCE_DIR}/doc/book/cartridge/cartridge_api")
set(LDOC_CARTRIDGE_CLI_DEST_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/doc/book/cartridge/cartridge_cli")

add_custom_target(html ALL
    COMMAND "${SPHINX_EXECUTABLE}"
        -b html
        -d "${SPHINX_BUILD_HTML_DIR}"
        -c html/
        -q
        "${CMAKE_CURRENT_SOURCE_DIR}/doc"
        "${SPHINX_EN_HTML_DIR}"
    COMMENT "Building HTML documentation with Sphinx"
)

add_custom_target(json ALL
    COMMAND "${SPHINX_EXECUTABLE}"
        -b json
        -d "${SPHINX_BUILD_JSON_EN_DIR}"
        -c html/
        -q
        "${CMAKE_CURRENT_SOURCE_DIR}/doc"
        "${SPHINX_EN_JSON_DIR}"
        -D language=en
    COMMENT "Building English JSON documentation with Sphinx"
)

add_custom_target(singlehtml ALL
    COMMAND "${SPHINX_EXECUTABLE}"
        -b singlehtml
        -d "${SPHINX_BUILD_SINGLEHTML_DIR}"
        -c singlehtml/
        -q
        "${CMAKE_CURRENT_SOURCE_DIR}/doc"
        "${SPHINX_EN_HTML_DIR}"
    COMMENT "Building HTML single-page documentation with Sphinx"
)

add_custom_target(singlehtml-website
    COMMAND "${SPHINX_EXECUTABLE}"
        -b singlehtml
        -d "${SPHINX_BUILD_SINGLEHTML_DIR}"
        -c singlehtml/
        -A rel_path=true
        "${CMAKE_CURRENT_SOURCE_DIR}/doc"
        "${SPHINX_EN_HTML_DIR}"
    COMMENT "Building HTML single-page documentation with Sphinx"
)

add_custom_target(autobuild
    COMMAND sphinx-autobuild
        -b html
        -d "${SPHINX_BUILD_HTML_DIR}"
        -c html/
        --host 0.0.0.0
        --port 8000
        -A nolang_path=true
        "${CMAKE_CURRENT_SOURCE_DIR}/doc"
        "${SPHINX_EN_AUTOBUILD_DIR}"
    COMMENT "Build & Live-reload on http://127.0.0.1:8000"
)

add_custom_target(autobuild-ru
    COMMAND sphinx-autobuild
        -b html
        -d "${SPHINX_BUILD_HTML_DIR}"
        -c html/
        --host 0.0.0.0
        --port 8000
        -D language=ru
        -A nolang_path=true
        "${CMAKE_CURRENT_SOURCE_DIR}/doc"
        "${SPHINX_RU_AUTOBUILD_DIR}"
    COMMENT "Build & Live-reload on http://127.0.0.1:8000"
)

add_custom_target(html-ru ALL
    COMMAND "${SPHINX_EXECUTABLE}"
        -b html
        -d "${SPHINX_BUILD_HTML_RU_DIR}"
        -c html/
        -q
        "${CMAKE_CURRENT_SOURCE_DIR}/doc"
        "${SPHINX_RU_HTML_DIR}"
        -D language=ru
    COMMENT "Building Russian HTML documentation with Sphinx"
)

add_custom_target(html-old-ru ALL
    COMMAND "${SPHINX_EXECUTABLE}"
        -b html
        -d "${SPHINX_BUILD_HTML_RU_OLD_DIR}"
        -c html/
        "${CMAKE_CURRENT_SOURCE_DIR}/doc"
        "${SPHINX_RU_HTML_OLD_DIR}"
        -D language=ru -D master_doc=singlehtml
    COMMENT "Building Russian HTML documentation with Sphinx"
)

add_custom_target(html-old ALL
    COMMAND "${SPHINX_EXECUTABLE}"
        -b html
        -d "${SPHINX_BUILD_HTML_OLD_DIR}"
        -c html/
        "${CMAKE_CURRENT_SOURCE_DIR}/doc"
        "${SPHINX_EN_HTML_OLD_DIR}"
        -D language=en -D master_doc=singlehtml
    COMMENT "Building English HTML documentation with Sphinx"
)

add_custom_target(json-ru ALL
    COMMAND "${SPHINX_EXECUTABLE}"
        -b json
        -d "${SPHINX_BUILD_JSON_RU_DIR}"
        -c html/
        -q
        "${CMAKE_CURRENT_SOURCE_DIR}/doc"
        "${SPHINX_RU_JSON_DIR}"
        -D language=ru
    COMMENT "Building Russian JSON documentation with Sphinx"
)

add_custom_target(singlehtml-ru ALL
    COMMAND "${SPHINX_EXECUTABLE}"
        -b singlehtml
        -d "${SPHINX_BUILD_SINGLEHTML_RU_DIR}"
        -c singlehtml/
        -D language=ru
        "${CMAKE_CURRENT_SOURCE_DIR}/doc"
        "${SPHINX_RU_HTML_DIR}"
    COMMENT "Building Russian HTML single-page documentation with Sphinx"
)

add_custom_target(singlehtml-ru-website
    COMMAND "${SPHINX_EXECUTABLE}"
        -b singlehtml
        -d "${SPHINX_BUILD_SINGLEHTML_RU_DIR}"
        -c singlehtml/
        -D language=ru
        -A rel_path=true
        "${CMAKE_CURRENT_SOURCE_DIR}/doc"
        "${SPHINX_RU_HTML_DIR}"
    COMMENT "Building Russian HTML single-page documentation with Sphinx"
)

add_custom_target(update-pot
    COMMAND "${SPHINX_EXECUTABLE}"
        -b gettext
        -d "${SPHINX_BUILD_LOCALE_DIR}"
        -c locale/
        -q
        "${CMAKE_CURRENT_SOURCE_DIR}/doc"
        "${CMAKE_CURRENT_SOURCE_DIR}/locale/en/"
    COMMENT "Update translation sources"
)

add_custom_target(update-po-raw
    COMMAND "${SPHINX_INTL_EXECUTABLE}"
        update
        -p "${CMAKE_CURRENT_SOURCE_DIR}/locale/en/"
        -d "${CMAKE_CURRENT_SOURCE_DIR}/locale/"
        -l "ru"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/locale
    COMMENT "Regenerate localization files from templates"
    DEPENDS update-pot
)

add_custom_target(update-po
    COMMAND make
        update-po-raw
        cleanup-po
)

add_custom_target(cleanup-po
    COMMAND "${PYTHON3_EXECUTABLE}"
        cleanup.py
        po
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/locale
    COMMENT "Cleanup and rearrange PO files"
)

add_custom_target(cleanup-pot
    COMMAND "${PYTHON3_EXECUTABLE}"
        cleanup.py
        pot
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/locale
    COMMENT "Cleanup and rearrange POT files"
)

add_custom_target(linkcheck
    COMMAND "${SPHINX_EXECUTABLE}"
        -b linkcheck
        -d "${SPHINX_BUILD_HTML_DIR}"
        -c html
        -q
        "${CMAKE_CURRENT_SOURCE_DIR}/doc"
        "${SPHINX_BUILD_HTML_DIR}"
    COMMENT "Linkcheck filter"
)

add_custom_target(submodules
    COMMAND cd modules/cartridge-cli && lua /usr/local/ldoc/ldoc.lua
        --dir=${LDOC_CARTRIDGE_CLI_DEST_DIR}
        --ext=rst
        README.md
    COMMENT "Generate cartridge-cli rst from lua sources"
)

add_custom_target(epub ALL
    COMMAND "${SPHINX_EXECUTABLE}"
        -b epub
        -d "${SPHINX_BUILD_EPUB_DIR}"
        -c epub/
        -q
        "${CMAKE_CURRENT_SOURCE_DIR}/doc"
        "${SPHINX_EN_EPUB_DIR}"
    COMMENT "Building English epub with Sphinx"
)

add_custom_target(epub-ru ALL
    COMMAND "${SPHINX_EXECUTABLE}"
        -b epub
        -d "${SPHINX_BUILD_EPUB_RU_DIR}"
        -c epub/
        -q
        -D language=ru
        "${CMAKE_CURRENT_SOURCE_DIR}/doc"
        "${SPHINX_RU_EPUB_DIR}"
    COMMENT "Building Russian epub with Sphinx"
)

add_custom_target(pull-modules ALL
    COMMAND /usr/bin/env python3
        ./pull_submodules.py
    COMMENT "Update submodules to their latest commits"
)

add_custom_target(build-modules ALL
    COMMAND /usr/bin/env bash
        ./build_submodules.sh
    COMMENT "Rebuild and copy content from submodules"
)



if (LATEX_FOUND)
    add_custom_target(pdf-ru ALL COMMENT "PDF generation")
    add_custom_command(TARGET pdf-ru
        COMMAND "${SPHINX_EXECUTABLE}"
            -b latex
            -d "${SPHINX_BUILD_LATEX_RU_DIR}"
            -c pdf
            "${CMAKE_CURRENT_SOURCE_DIR}/doc"
            "${SPHINX_BUILD_LATEX_RU_DIR}"
            -D language=ru
    )
    add_custom_command(TARGET pdf-ru
        COMMAND "${PDFLATEX_COMPILER}" -interaction nonstopmode Tarantool.tex || true
        WORKING_DIRECTORY ${SPHINX_BUILD_LATEX_RU_DIR}
    )
    add_custom_command(TARGET pdf-ru
        COMMAND "${PDFLATEX_COMPILER}" -interaction nonstopmode Tarantool.tex || true
        WORKING_DIRECTORY ${SPHINX_BUILD_LATEX_RU_DIR}
    )

    add_custom_target(pdf ALL COMMENT "PDF generation")
    add_custom_command(TARGET pdf
        COMMAND "${SPHINX_EXECUTABLE}"
            -b latex
            -d "${SPHINX_BUILD_LATEX_DIR}"
            -c pdf
            "${CMAKE_CURRENT_SOURCE_DIR}/doc"
            "${SPHINX_BUILD_LATEX_DIR}"
    )
    add_custom_command(TARGET pdf
        COMMAND "${PDFLATEX_COMPILER}" -interaction nonstopmode Tarantool.tex || true
        WORKING_DIRECTORY ${SPHINX_BUILD_LATEX_DIR}
    )
    add_custom_command(TARGET pdf
        COMMAND "${PDFLATEX_COMPILER}" -interaction nonstopmode Tarantool.tex || true
        WORKING_DIRECTORY ${SPHINX_BUILD_LATEX_DIR}
    )
endif()
