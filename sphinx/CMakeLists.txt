find_package(Sphinx REQUIRED)
#find_program(MKDIR mkdir)

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/conf.py.in"
    "${CMAKE_CURRENT_SOURCE_DIR}/conf.py")

set(SPHINX_BUILD_SINGLEHTML_DIR "${PROJECT_BINARY_DIR}/sphinx/_single_build/")
set(SPHINX_BUILD_HTML_DIR   "${PROJECT_BINARY_DIR}/sphinx/_html_build/")
set(SPHINX_BUILD_LOCALE_DIR "${PROJECT_BINARY_DIR}/sphinx/_locale_build/")
set(SPHINX_HTML_DIR  "${PROJECT_BINARY_DIR}/www/output/doc/")
set(SPHINX_RU_HTML_DIR  "${PROJECT_BINARY_DIR}/www/output/doc/ru/")

#add_custom_command(OUTPUT ${MKDIR} -p ${SPHINX_BUILD_DIR})
#add_custom_command(OUTPUT ${MKDIR} -p ${SPHINX_HTML_DIR})

add_custom_target(sphinx-html ALL
#    DEPENDS ${SPHINX_BUILD_DIR} ${SPHINX_HTML_DIR}
    COMMAND "${SPHINX_EXECUTABLE}"
        -b html
        -d "${SPHINX_BUILD_SINGLEHTML_DIR}"
        -c html/
        "${PROJECT_SOURCE_DIR}/sphinx"
        "${SPHINX_HTML_DIR}"
    COMMENT "Building HTML documentation with Sphinx"
)

add_custom_target(sphinx-singlehtml ALL
    COMMAND "${SPHINX_EXECUTABLE}"
        -b singlehtml
        -d "${SPHINX_BUILD_HTML_DIR}"
        -c singlehtml/
        "${PROJECT_SOURCE_DIR}/sphinx"
        "${SPHINX_HTML_DIR}"
        singlehtml.rst
    COMMENT "Building HTML documentation with Sphinx"
)

add_custom_target(sphinx-html-ru ALL
#    DEPENDS ${SPHINX_BUILD_DIR} ${SPHINX_HTML_DIR}
    COMMAND "${SPHINX_EXECUTABLE}"
        -b html
        -d "${SPHINX_BUILD_HTML_DIR}"
        -c html/
        "${PROJECT_SOURCE_DIR}/sphinx"
        "${SPHINX_RU_HTML_DIR}"
        -Dlanguage=ru
    COMMENT "Building HTML documentation with Sphinx"
)

add_custom_target(sphinx-singlehtml-ru ALL
    COMMAND "${SPHINX_EXECUTABLE}"
        -b singlehtml
        -d "${SPHINX_BUILD_SINGLEHTML_DIR}"
        -c singlehtml/
        "${PROJECT_SOURCE_DIR}/sphinx"
        "${SPHINX_RU_HTML_DIR}"
        singlehtml.rst
        -Dlanguage=ru
    COMMENT "Building HTML documentation with Sphinx"
)

add_custom_target(sphinx-update-pot
    COMMAND "${SPHINX_EXECUTABLE}"
        -b gettext
        -d "${SPHINX_BUILD_LOCALE_DIR}"
        -c locale/
        "${PROJECT_SOURCE_DIR}/sphinx"
        "${PROJECT_SOURCE_DIR}/sphinx/locale"
    COMMENT "Generate localization templates"
)

add_custom_target(sphinx-update-po
    COMMAND "${SPHINX_INTL_EXECUTABLE}"
        update
        -p ${PROJECT_SOURCE_DIR}/sphinx/locale
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/sphinx
    COMMENT "Regenerate localization files from templates"
    DEPENDS sphinx-update-pot
)
