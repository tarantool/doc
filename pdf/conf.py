exec(open('../conf.py').read())

master_doc = 'singlehtml'

locale_dirs = ['../locale']

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
