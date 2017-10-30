# -*- coding: utf-8 -*-

import sys
reload(sys)
sys.setdefaultencoding('utf8')

import os

sys.path.insert(0, os.path.abspath('..'))

# -- General configuration ------------------------------------------------

master_doc = 'doc/1.6/index'
# master_doc = 'index'

extensions = [
    'sphinx.ext.todo',
    'sphinx.ext.ifconfig',
    'sphinx.ext.intersphinx',
    'sphinx.ext.imgconverter',
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
    'ext.DownloadPageBlock'
]
primary_domain = 'lua'
source_suffix = '.rst'

project = u'Tarantool'

# |release| The full version, including alpha/beta/rc tags.
release = "1.6.9"
# |version| The short X.Y version.
version = '.'.join(release.split('.')[0:2])

exclude_patterns = [
    '_build',
    'doc/1.6/book/connectors/__*',
    'doc/1.6/book/replication/*_1.rst',
    'doc/1.6/book/replication/*_2.rst',
    'doc/1.6/book/admin.rst',
    'doc/1.6/book/box/box_introspection.rst',
    'doc/1.6/book/cookbook.rst',
    'doc/1.6/book/box/vinyl.rst',
    'doc/1.6/dev_guide/box_protocol.rst',
    'doc/1.6/dev_guide/internals.rst',
    'doc/1.6/reference/configuration/cfg_*',
    'doc/1.6/reference/reference_lua/jit.rst',
    'doc/1.6/reference/reference_lua/os.rst',
    'doc/1.6/reference/reference_lua/net_box_1.6.rst',
    'CNAME',
    'robots.txt',
    '_downloads/license.docx',
    '_downloads/license_eng.docx',
    '_downloads/terms.docx',
    '_downloads/terms_eng.docx',
    'images',
    'tarantool-io/social-icons.rst',
    'tarantool-io/integrate-data-source.rst'
    'tarantool-io/jumbo-form.rst',
    'tarantool-io/main-form.rst',
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
        'developers'   : True,
        'download/download'    : True,
        'download/download_16' : True,
        'download/download_18' : True,
        'careers'     : True,
        'benchmark'   : True,
        'try'         : True,
        'rocks'       : True,
        'doc/' + version + '/index' : True,
        'download-page' : True,
        'download/os-instalation' : True, # FIXME Delete
        'download/connectors' : True,
        'download/connectors_16' : True,
        'download/connectors_18' : True,
        'download/rocks' : True,
        'download/rocks_16' : True,
        'download/rocks_18' : True,
        # Helper webpages
        '404'            : True,
        # Internal webpages
        'genindex'       : True,
        'lua-modindex'   : True,
        'search'         : True,
    },
    'tarantool_io': {
        # Tarantool-io pages
        'index': True,
        'challenge': True,
        'news-and-press': True,
        'about': True,
        'blog': True,
        'features': True,
        'product/enterprise': True,
        'product/unwired-iiot': True,
        'live-demo': True,
        'careers': True,
        'support': True,
        'contact': True,
        'press/iiot-released': True,
        'press/replication-for-mysql': True,
        'press/tarantool-expands': True,
        'press/tarantool-partners-waviot': True,
        'press/tarantool-supports-sql': True,
        'press/tarantool-unviels-replication': True,
        'press/veon-migrates': True,
    },
    'packages': {
        # 1.6
        'download/os-installation/1.6/ubuntu' : True,
        'download/os-installation/1.6/amazon-linux' : True,
        'download/os-installation/1.6/building-from-source' : True,
        'download/os-installation/1.6/debian-jessie-and-newer' : True,
        'download/os-installation/1.6/debian-wheezy' : True,
        'download/os-installation/1.6/docker-hub' : True,
        'download/os-installation/1.6/fedora' : True,
        'download/os-installation/1.6/freebsd' : True,
        'download/os-installation/1.6/microsoft-azure' : True,
        'download/os-installation/1.6/os-x' : True,
        'download/os-installation/1.6/rhel-centos-6-7' : True,
        # 1.7
        'download/os-installation/1.7/ubuntu' : True,
        'download/os-installation/1.7/amazon-linux' : True,
        'download/os-installation/1.7/building-from-source' : True,
        'download/os-installation/1.7/debian-jessie-and-newer' : True,
        'download/os-installation/1.7/debian-wheezy' : True,
        'download/os-installation/1.7/docker-hub' : True,
        'download/os-installation/1.7/fedora' : True,
        'download/os-installation/1.7/freebsd' : True,
        'download/os-installation/1.7/microsoft-azure' : True,
        'download/os-installation/1.7/os-x' : True,
        'download/os-installation/1.7/rhel-centos-6-7' : True,
        'download/os-installation/1.7/snappy-package' : True,
        # 1.8
        'download/os-installation/1.8/ubuntu' : True,
        'download/os-installation/1.8/amazon-linux' : True,
        'download/os-installation/1.8/building-from-source' : True,
        'download/os-installation/1.8/debian-jessie-and-newer' : True,
        'download/os-installation/1.8/debian-wheezy' : True,
        'download/os-installation/1.8/docker-hub' : True,
        'download/os-installation/1.8/fedora' : True,
        'download/os-installation/1.8/freebsd' : True,
        'download/os-installation/1.8/microsoft-azure' : True,
        'download/os-installation/1.8/os-x' : True,
        'download/os-installation/1.8/rhel-centos-6-7' : True,
        'download/os-installation/1.8/snappy-package' : True
    },
    'wp_local': True,
    'versions': ['1.6', '1.7', '1.8'],
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
    'fontenc': r'\usepackage[T1,T2A]{fontenc}'
}

intersphinx_cache_limit = 0

# Localization options
language = 'en'
locale_dirs = ['./locale']
gettext_additional_targets = ['literal-block']
