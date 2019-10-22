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

set(SPHINX_OUTPUT_DIR              "${CMAKE_CURRENT_BINARY_DIR}/output")

set(SPHINX_BUILD_LOCALE_DIR        "${SPHINX_OUTPUT_DIR}/_locale_build/")

set(SPHINX_BUILD_SINGLEHTML_DIR    "${SPHINX_OUTPUT_DIR}/_single_build/")
set(SPHINX_BUILD_SINGLEHTML_RU_DIR "${SPHINX_OUTPUT_DIR}/_single_ru_build/")

set(SPHINX_BUILD_HTML_DIR          "${SPHINX_OUTPUT_DIR}/_html_build/")
set(SPHINX_BUILD_HTML_RU_DIR       "${SPHINX_OUTPUT_DIR}/singlehtml/")

set(SPHINX_BUILD_LATEX_DIR         "${SPHINX_OUTPUT_DIR}/_latex_build/")
set(SPHINX_BUILD_LATEX_RU_DIR      "${SPHINX_OUTPUT_DIR}/singlehtml-ru/")

set(SPHINX_BUILD_JSON_EN_DIR       "${SPHINX_OUTPUT_DIR}/json/_build_en/doctrees")
set(SPHINX_BUILD_JSON_RU_DIR       "${SPHINX_OUTPUT_DIR}/json/_build_ru/doctrees")

set(SPHINX_EN_HTML_DIR             "${SPHINX_OUTPUT_DIR}/html/en/")
set(SPHINX_RU_HTML_DIR             "${SPHINX_OUTPUT_DIR}/html/ru/")
set(SPHINX_EN_JSON_DIR             "${SPHINX_OUTPUT_DIR}/json/_build_en/json")
set(SPHINX_RU_JSON_DIR             "${SPHINX_OUTPUT_DIR}/json/_build_ru/json")

add_custom_target(html ALL
    COMMAND "${SPHINX_EXECUTABLE}"
        -b html
        -d "${SPHINX_BUILD_HTML_DIR}"
        -c html/
        "${CMAKE_CURRENT_SOURCE_DIR}"
        "${SPHINX_EN_HTML_DIR}"
    COMMENT "Building HTML documentation with Sphinx"
)

add_custom_target(json ALL
    COMMAND "${SPHINX_EXECUTABLE}"
        -b json
        -d "${SPHINX_BUILD_JSON_EN_DIR}"
        -c html/
        "${CMAKE_CURRENT_SOURCE_DIR}"
        "${SPHINX_EN_JSON_DIR}"
        -D language=en
    COMMENT "Building English JSON documentation with Sphinx"
)

add_custom_target(singlehtml ALL
    COMMAND "${SPHINX_EXECUTABLE}"
        -b singlehtml
        -d "${SPHINX_BUILD_SINGLEHTML_DIR}"
        -c singlehtml/
        "${CMAKE_CURRENT_SOURCE_DIR}"
        "${SPHINX_EN_HTML_DIR}"
        singlehtml.rst
    COMMENT "Building HTML single-page documentation with Sphinx"
)

add_custom_target(html-ru ALL
    COMMAND "${SPHINX_EXECUTABLE}"
        -b html
        -d "${SPHINX_BUILD_HTML_RU_DIR}"
        -c html/
        "${CMAKE_CURRENT_SOURCE_DIR}"
        "${SPHINX_RU_HTML_DIR}"
        -D language=ru
    COMMENT "Building Russian HTML documentation with Sphinx"
)

add_custom_target(json-ru ALL
    COMMAND "${SPHINX_EXECUTABLE}"
        -b json
        -d "${SPHINX_BUILD_JSON_RU_DIR}"
        -c html/
        "${CMAKE_CURRENT_SOURCE_DIR}"
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
        "${CMAKE_CURRENT_SOURCE_DIR}"
        "${SPHINX_RU_HTML_DIR}"
        singlehtml.rst
    COMMENT "Building Russian HTML single-page documentation with Sphinx"
)

add_custom_target(update-pot
    COMMAND "${SPHINX_EXECUTABLE}"
        -b gettext
        -d "${SPHINX_BUILD_LOCALE_DIR}"
        -c locale/
        "${CMAKE_CURRENT_SOURCE_DIR}"
        "${CMAKE_CURRENT_SOURCE_DIR}/locale"
    COMMENT "Generate localization templates"
)

add_custom_target(update-po
    COMMAND "${SPHINX_INTL_EXECUTABLE}"
        update
        -p ${CMAKE_CURRENT_SOURCE_DIR}/locale
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Regenerate localization files from templates"
    DEPENDS update-pot
)

add_custom_target(linkcheck
    COMMAND "${SPHINX_EXECUTABLE}"
        -b linkcheck
        -d "${SPHINX_BUILD_HTML_DIR}"
        -c html
        "${CMAKE_CURRENT_SOURCE_DIR}"
        "${SPHINX_BUILD_HTML_DIR}"
    COMMENT "Linkcheck filter"
)

if (LATEX_FOUND)
    add_custom_target(pdf-ru ALL COMMENT "PDF generation")
    add_custom_command(TARGET pdf-ru
        COMMAND "${SPHINX_EXECUTABLE}"
            -b latex
            -d "${SPHINX_BUILD_LATEX_RU_DIR}"
            -c singlehtml
            "${CMAKE_CURRENT_SOURCE_DIR}"
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
    add_custom_command(TARGET pdf-ru
        COMMAND ${CMAKE_COMMAND} -E make_directory ${SPHINX_RU_HTML_DIR})
    add_custom_command(TARGET pdf-ru
        COMMAND ${CMAKE_COMMAND} -E copy ${SPHINX_BUILD_LATEX_RU_DIR}Tarantool.pdf
                                         ${SPHINX_RU_HTML_DIR})

    add_custom_target(pdf ALL COMMENT "PDF generation")
    add_custom_command(TARGET pdf
        COMMAND "${SPHINX_EXECUTABLE}"
            -b latex
            -d "${SPHINX_BUILD_LATEX_DIR}"
            -c singlehtml
            "${CMAKE_CURRENT_SOURCE_DIR}"
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
    add_custom_command(TARGET pdf
        COMMAND ${CMAKE_COMMAND} -E make_directory ${SPHINX_EN_HTML_DIR})
    add_custom_command(TARGET pdf
        COMMAND ${CMAKE_COMMAND} -E copy ${SPHINX_BUILD_LATEX_DIR}Tarantool.pdf
                                         ${SPHINX_EN_HTML_DIR})
endif()
