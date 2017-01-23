cmake_minimum_required(VERSION 2.8.12)

project(tarantool-doc)

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
    message (FATAL_ERROR "Unable to retrive version from git or ${VERSION_FILE} file.")
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

set(SPHINX_BUILD_SINGLEHTML_DIR    "${CMAKE_CURRENT_BINARY_DIR}/_single_build/")
set(SPHINX_BUILD_HTML_DIR          "${CMAKE_CURRENT_BINARY_DIR}/_html_build/")
set(SPHINX_BUILD_LATEX_DIR       "${CMAKE_CURRENT_BINARY_DIR}/_latex_build/")

set(SPHINX_BUILD_SINGLEHTML_RU_DIR "${CMAKE_CURRENT_BINARY_DIR}/_single_ru_build/")
set(SPHINX_BUILD_HTML_RU_DIR       "${CMAKE_CURRENT_BINARY_DIR}/_html_ru_build/")
set(SPHINX_BUILD_LATEX_RU_DIR       "${CMAKE_CURRENT_BINARY_DIR}/_latex_ru_build/")

set(SPHINX_BUILD_LOCALE_DIR        "${CMAKE_CURRENT_BINARY_DIR}/_locale_build/")

set(SPHINX_OUTPUT_DIR              "${CMAKE_CURRENT_BINARY_DIR}/output")
set(SPHINX_EN_HTML_DIR             "${SPHINX_OUTPUT_DIR}/en/")
set(SPHINX_RU_HTML_DIR             "${SPHINX_OUTPUT_DIR}/ru/")

add_custom_target(update-submodules ALL COMMENT "Update submodules")
add_custom_command(TARGET update-submodules PRE_BUILD
    COMMAND git submodule update --init --recursive
)
add_custom_command(TARGET update-submodules PRE_BUILD
    COMMAND git fetch
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/rocks"
)
add_custom_command(TARGET update-submodules PRE_BUILD
    COMMAND git checkout origin/gh-pages
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/rocks"
)
add_custom_target(sphinx-html ALL
    COMMAND "${SPHINX_EXECUTABLE}"
        -b html
        -d "${SPHINX_BUILD_HTML_DIR}"
        -c html/
        "${CMAKE_CURRENT_SOURCE_DIR}"
        "${SPHINX_EN_HTML_DIR}"
    COMMENT "Building HTML documentation with Sphinx"
    DEPENDS update-submodules
)

add_custom_target(sphinx-singlehtml ALL
    COMMAND "${SPHINX_EXECUTABLE}"
        -b singlehtml
        -d "${SPHINX_BUILD_SINGLEHTML_DIR}"
        -c singlehtml/
        "${CMAKE_CURRENT_SOURCE_DIR}"
        "${SPHINX_EN_HTML_DIR}"
        doc/singlehtml.rst
    COMMENT "Building HTML documentation with Sphinx"
    DEPENDS update-submodules
)

add_custom_target(sphinx-html-ru ALL
    COMMAND "${SPHINX_EXECUTABLE}"
        -b html
        -d "${SPHINX_BUILD_HTML_RU_DIR}"
        -c html/
        "${CMAKE_CURRENT_SOURCE_DIR}"
        "${SPHINX_RU_HTML_DIR}"
        -Dlanguage=ru
    COMMENT "Building HTML documentation with Sphinx"
    DEPENDS update-submodules
)

add_custom_target(sphinx-singlehtml-ru ALL
    COMMAND "${SPHINX_EXECUTABLE}"
        -b singlehtml
        -d "${SPHINX_BUILD_SINGLEHTML_RU_DIR}"
        -c singlehtml/
        "${CMAKE_CURRENT_SOURCE_DIR}"
        "${SPHINX_RU_HTML_DIR}"
        doc/singlehtml.rst
        -Dlanguage=ru
    COMMENT "Building HTML documentation with Sphinx"
    DEPENDS update-submodules
)

add_custom_target(sphinx-update-pot
    COMMAND "${SPHINX_EXECUTABLE}"
        -b gettext
        -d "${SPHINX_BUILD_LOCALE_DIR}"
        -c locale/
        "${CMAKE_CURRENT_SOURCE_DIR}"
        "${CMAKE_CURRENT_SOURCE_DIR}/locale"
    COMMENT "Generate localization templates"
)

add_custom_target(sphinx-update-po
    COMMAND "${SPHINX_INTL_EXECUTABLE}"
        update
        -p ${CMAKE_CURRENT_SOURCE_DIR}/locale
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Regenerate localization files from templates"
    DEPENDS sphinx-update-pot
)

add_custom_target(sphinx-linkcheck
    COMMAND "${SPHINX_EXECUTABLE}"
        -b linkcheck
        -d "${SPHINX_BUILD_HTML_DIR}"
        -c html
        "${CMAKE_CURRENT_SOURCE_DIR}"
        "${SPHINX_BUILD_HTML_DIR}"
    COMMENT "Linkcheck filter"
)

if (LATEX_FOUND)
    add_custom_target(sphinx-pdf-ru ALL COMMENT "PDF generation")
    add_custom_command(TARGET sphinx-pdf-ru
        COMMAND "${SPHINX_EXECUTABLE}"
            -b latex
            -d "${SPHINX_BUILD_LATEX_RU_DIR}"
            -c singlehtml
            "${CMAKE_CURRENT_SOURCE_DIR}"
            "${SPHINX_BUILD_LATEX_RU_DIR}"
            -Dlanguage=ru
    )
    add_custom_command(TARGET sphinx-pdf-ru
        COMMAND "${PDFLATEX_COMPILER}" -interaction nonstopmode Tarantool.tex
        WORKING_DIRECTORY ${SPHINX_BUILD_LATEX_RU_DIR}
    )
    add_custom_command(TARGET sphinx-pdf-ru
        COMMAND ${CMAKE_COMMAND} -E make_directory ${SPHINX_RU_HTML_DIR}/doc/)
    add_custom_command(TARGET sphinx-pdf-ru
        COMMAND ${CMAKE_COMMAND} -E copy ${SPHINX_BUILD_LATEX_RU_DIR}/Tarantool.pdf
                                         ${SPHINX_RU_HTML_DIR}/doc/)

    add_custom_target(sphinx-pdf ALL COMMENT "PDF generation")
    add_custom_command(TARGET sphinx-pdf
        COMMAND "${SPHINX_EXECUTABLE}"
            -b latex
            -d "${SPHINX_BUILD_LATEX_DIR}"
            -c singlehtml
            "${CMAKE_CURRENT_SOURCE_DIR}"
            "${SPHINX_BUILD_LATEX_DIR}"
    )

    add_custom_command(TARGET sphinx-pdf
        COMMAND "${PDFLATEX_COMPILER}" -interaction nonstopmode Tarantool.tex
        WORKING_DIRECTORY ${SPHINX_BUILD_LATEX_DIR}
    )
    add_custom_command(TARGET sphinx-pdf
        COMMAND ${CMAKE_COMMAND} -E make_directory ${SPHINX_EN_HTML_DIR}/doc/)
    add_custom_command(TARGET sphinx-pdf
        COMMAND ${CMAKE_COMMAND} -E copy ${SPHINX_BUILD_LATEX_DIR}/Tarantool.pdf
                                         ${SPHINX_EN_HTML_DIR}/doc/)
endif()

add_custom_target(sphinx-webserver
    COMMAND screen -dmS sphinx-webserver python ${CMAKE_CURRENT_SOURCE_DIR}/ext/WebPageServer.py 8000
    WORKING_DIRECTORY ${SPHINX_OUTPUT_DIR})

set(STATIC_FILES
    .nojekyll
    CNAME
    robots.txt
    _downloads/license.docx
    _downloads/license_eng.docx
    _downloads/terms.docx
    _downloads/terms_eng.docx
)

add_custom_target(copy-static ALL COMMENT "Copy static files")
foreach(FILE_PATH ${STATIC_FILES})
    get_filename_component(FILE_DIR ${FILE_PATH} DIRECTORY)
    add_custom_command(TARGET copy-static PRE_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory
                                 ${SPHINX_OUTPUT_DIR}/${FILE_DIR})
    add_custom_command(TARGET copy-static PRE_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
                                 ${CMAKE_CURRENT_SOURCE_DIR}/${FILE_PATH}
                                 ${SPHINX_OUTPUT_DIR}/${FILE_PATH}
    )
endforeach()
