import sys
import os

from sphinx.highlighting import lexers
from pygments.lexers.web import PhpLexer


lexers['php'] = PhpLexer(startinline=True)
lexers['php-annotations'] = PhpLexer(startinline=True)


sys.path.insert(0, os.path.abspath('..'))

# -- General configuration ------------------------------------------------

master_doc = 'index'

extensions = [
    'myst_parser',
    'sphinx.ext.todo',
    'sphinx.ext.imgmath',
    'sphinx.ext.ifconfig',
    'sphinx.ext.intersphinx',
    'sphinx.ext.extlinks',
    'sphinx_panels',
    'sphinxcontrib.plantuml',
    'ext.custom',
    'ext.LuaDomain',
    'ext.LuaLexer',
    'ext.TapLexer',
    'ext.TarantoolSessionLexer',
    'ext.DropdownList',
    'ext.WebPageSection',
    'ext.WebPageButtons',
    'ext.ModuleBlock',
    'ext.DownloadPageBlock',
    'ext.CustomHTMLTranslator',
    'ext.CustomJSONBuilder',
]

extlinks = {
    'tarantool-issue': ('https://github.com/tarantool/tarantool/issues/%s', 'gh-'),
    'tarantool-ee-issue': ('https://github.com/tarantool/tarantool-ee/issues/%s', 'gh-'),
    'tarantool-release': ('https://github.com/tarantool/tarantool/releases/%s', 'v. '),
    'tt-release': ('https://github.com/tarantool/tt/releases/v%s', 'v. '),
    'doc-issue': ('https://github.com/tarantool/doc/issues/%s', 'doc-'),
    'tarantool-sec-issue': ('https://github.com/tarantool/security/issues/%s', 'ghs-'),
}

default_role = 'code'

plantuml_output_format = 'svg_img'
imgmath_image_format = 'svg'

primary_domain = 'lua'
source_suffix = {
    '.rst': 'restructuredtext',
    '.md': 'markdown',
}

project = u'Tarantool'

# |release| The full version, including alpha/beta/rc tags.
release = "2.11.1"
# |version| The short X.Y version.
version = '.'.join(release.split('.')[0:2])

exclude_patterns = [
    '_build',
    'archive/*',
    'book/connectors/__*',
    'how-to/using_package_manager.rst',
    'how-to/using_docker.rst',
    'reference/configuration/cfg_*',
    'images',
    'book/cartridge/cartridge_overview.rst',
    'book/cartridge/CONTRIBUTING.rst',
    'book/cartridge/topics',
    'book/cartridge/cartridge_api/modules/cartridge.test-helpers.rst',
    'reference/reference_rock/luatest/README.rst',
    'reference/reference_rock/luatest/modules/luatest.rst',
    '**/_includes/*'
]

base_url = "https://tarantool.io/"
# -- Options for HTML output ----------------------------------------------
html_theme           = 'tarantool'
html_theme_path      = ['../_theme']
html_theme_options   = {
    'base_url': base_url
}
html_static_path     = ['../_static']
html_show_sphinx     = False
html_show_copyright  = False
html_domain_indices  = False
html_use_modindex    = False
html_use_index       = True
html_use_smartypants = True
html_compact_lists   = True
html_copy_source     = False
html_use_opensearch  = base_url

html_context = {
    'website': {
        'index'       : True,
        'download/download'    : True,
        'download/download_16' : True,
        'download/download_20' : True,
        'careers'     : True,
        'benchmark'   : True,
        'try'         : True,
        'rocks'       : True,
        'doc/' + version + '/index' : True,
        'download-page' : True,
        'download/os-instalation' : True, # FIXME Delete
        'download/connectors' : True,
        'download/connectors_16' : True,
        'download/connectors_20' : True,
        'download/rocks' : True,
        'download/rocks_16' : True,
        'download/rocks_20' : True,
        # Helper webpages
        '404'            : True,
        # Internal webpages
        'genindex'       : True,
        'lua-modindex'   : True,
        'search'         : True,
    },
    'packages': {
        # 1.6
        'download/os-installation/1.6/ubuntu' : True,
        'download/os-installation/1.6/amazon-linux' : True,
        'download/os-installation/1.6/building-from-source' : True,
        'download/os-installation/1.6/debian' : True,
        'download/os-installation/1.6/docker-hub' : True,
        'download/os-installation/1.6/fedora' : True,
        'download/os-installation/1.6/freebsd' : True,
        'download/os-installation/1.6/os-x' : True,
        'download/os-installation/1.6/rhel-centos-6-7' : True,
        # 1.10
        'download/os-installation/1.10/ubuntu' : True,
        'download/os-installation/1.10/amazon-linux' : True,
        'download/os-installation/1.10/building-from-source' : True,
        'download/os-installation/1.10/debian' : True,
        'download/os-installation/1.10/docker-hub' : True,
        'download/os-installation/1.10/fedora' : True,
        'download/os-installation/1.10/freebsd' : True,
        'download/os-installation/1.10/os-x' : True,
        'download/os-installation/1.10/rhel-centos-6-7' : True,
        'download/os-installation/1.10/snappy-package' : True,
        # 2.2
        'download/os-installation/2.2/ubuntu' : True,
        'download/os-installation/2.2/amazon-linux' : True,
        'download/os-installation/2.2/building-from-source' : True,
        'download/os-installation/2.2/debian' : True,
        'download/os-installation/2.2/docker-hub' : True,
        'download/os-installation/2.2/fedora' : True,
        'download/os-installation/2.2/freebsd' : True,
        'download/os-installation/2.2/os-x' : True,
        'download/os-installation/2.2/rhel-centos-6-7' : True,
        'download/os-installation/2.2/snappy-package' : True
    },
    'wp_local': True,
    'versions': ['1.6', '1.10', '2.2', '2.3'],
}

# Tarantool has extended Sphinx so that there are four new roles:
# * :codenormal:`text`     displays text as monospace
# * :codebold:`text`       displays text as monospace bold
# * :codeitalic:`text`     displays text as monospace italic
# * :codebolditalic:`text` displays text as monospace italic bold
#
# The effect on HTML output is defined in _static/sphinx_design.css
# (which is the css file designated in _templates/layout.html).

with open('../prolog.rst', 'r') as prolog:
    rst_prolog = prolog.read()


# Intersphinx configuration
intersphinx_mapping = {
    'tarantoolc': ('http://tarantool.github.io/tarantool-c/', None)
}

latex_elements = {
    'fontenc': r'\usepackage[T1,T2A]{fontenc}',
    'hyperref': r'\usepackage[pdftex,pagebackref=true,backref=true,bookmarksopenlevel=1,colorlinks=true,linkcolor=blue,filecolor=magenta,urlcolor=cyan]{hyperref}',
    'extraclassoptions': 'openany',
}

intersphinx_cache_limit = 0

# Localization options
language = 'en'
locale_dirs = ['./locale']
gettext_additional_targets = ['literal-block']
gettext_compact = False
gettext_location = True

# Linkcheck options
linkcheck_ignore = [
    r'http://localhost(:\d+)?',
    r'http://127\.0\.0\.1(:\d+)?',
    r'https?://github\.com',
    r'https?://www.tarantool.io/en/doc/latest/reference/reference_lua/box_slab/.*#.*',
]