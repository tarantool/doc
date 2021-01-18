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
    'sphinx.ext.todo',
    'sphinx.ext.imgmath',
    'sphinx.ext.ifconfig',
    'sphinx.ext.intersphinx',
    'ext.custom',
    'ext.LuaDomain',
    'ext.LuaLexer',
    'ext.TapLexer',
    'ext.TarantoolSessionLexer',
    'ext.DropdownList',
    'ext.WebPageSection',
    'ext.WebPageButtons',
    'ext.WebPageMap',
    'ext.ModuleBlock',
    'ext.DownloadPageBlock',
    'ext.CustomHTMLTranslator',
    'ext.CustomJSONBuilder',
]


imgmath_image_format = 'svg'

primary_domain = 'lua'
source_suffix = '.rst'

project = u'Tarantool'

# |release| The full version, including alpha/beta/rc tags.
release = "1.10.4"
# |version| The short X.Y version.
version = '.'.join(release.split('.')[0:2])

exclude_patterns = [
    '_build',
    'archive/*',
    'book/connectors/__*',
    'book/replication/*_1.rst',
    'book/replication/*_2.rst',
    'book/box/engines/vinyl.rst',
    'getting_started/getting_started_go.rst',
    'getting_started/getting_started_php.rst',
    'getting_started/getting_started_python.rst',
    'getting_started/using_package_manager.rst',
    'getting_started/using_docker.rst',
    'dev_guide/box_protocol.rst',
    'dev_guide/internals.rst',
    'reference/configuration/cfg_*',
    'reference/reference_lua/jit.rst',
    'images'
]

base_url = "https://tarantool.org/"
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
        # 1.9
        'download/os-installation/1.9/ubuntu' : True,
        'download/os-installation/1.9/amazon-linux' : True,
        'download/os-installation/1.9/building-from-source' : True,
        'download/os-installation/1.9/debian' : True,
        'download/os-installation/1.9/docker-hub' : True,
        'download/os-installation/1.9/fedora' : True,
        'download/os-installation/1.9/freebsd' : True,
        'download/os-installation/1.9/os-x' : True,
        'download/os-installation/1.9/rhel-centos-6-7' : True,
        'download/os-installation/1.9/snappy-package' : True,
        # 2.0
        'download/os-installation/2.0/ubuntu' : True,
        'download/os-installation/2.0/amazon-linux' : True,
        'download/os-installation/2.0/building-from-source' : True,
        'download/os-installation/2.0/debian' : True,
        'download/os-installation/2.0/docker-hub' : True,
        'download/os-installation/2.0/fedora' : True,
        'download/os-installation/2.0/freebsd' : True,
        'download/os-installation/2.0/os-x' : True,
        'download/os-installation/2.0/rhel-centos-6-7' : True,
        'download/os-installation/2.0/snappy-package' : True
    },
    'wp_local': True,
    'versions': ['1.6', '1.10', '2.0'],
}

# Tarantool has extended Sphinx so that there are four new roles:
# * :codenormal:`text`     displays text as monospace
# * :codebold:`text`       displays text as monospace bold
# * :codeitalic:`text`     displays text as monospace italic
# * :codebolditalic:`text` displays text as monospace italic bold
#
# The effect on HTML output is defined in _static/sphinx_design.css
# (which is the css file designated in _templates/layout.html).
rst_prolog = """
.. role:: codenormal
   :class: ccode

.. role:: codebold
   :class: ccodeb

.. role:: codeitalic
   :class: ccodei

.. role:: codebolditalic
   :class: ccodebi

.. role:: codegreen
   :class: ccodegreen

.. role:: codered
   :class: ccodered

.. role:: codeblue
   :class: ccodeblue

.. role:: currentversion
   :class: current-version

.. role:: specialtext
   :class: special-text

.. |nbsp| unicode:: 0xA0

.. |br| raw:: html

    <br />
"""

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
gettext_location = False
