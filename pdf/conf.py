exec(open('../conf.py').read())

locale_dirs = ['../locale']

# Grouping the document tree into LaTeX files. List of tuples
# (source start file, target name, title, author, documentclass
# [howto/manual]).
latex_documents = [
 ('pdf_toc', 'tarantool.tex', u'Tarantool Documentation', u'', 'manual'),
]

extensions = [
    'myst_parser',
    'sphinx.ext.todo',
    'sphinx.ext.imgmath',
    'sphinx.ext.ifconfig',
    'sphinx.ext.intersphinx',
    'sphinx.ext.extlinks',
    'sphinxcontrib.plantuml',
    'sphinxcontrib.rsvgconverter',
    'ext.custom',
    'ext.LuaDomain',
    'ext.LuaLexer',
    'ext.TapLexer',
    'ext.TarantoolSessionLexer',
    'ext.DropdownList',
    'ext.WebPageSection',
    'ext.WebPageButtons',
    'ext.ModuleBlock',
    'ext.DownloadPageBlock'
]

