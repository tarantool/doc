exec(open('../conf.py').read())

master_doc = 'singlehtml'

locale_dirs = ['../locale']

extensions = [
    'sphinx.ext.todo',
    'sphinx.ext.imgmath',
    'sphinx.ext.ifconfig',
    'sphinx.ext.intersphinx',
    'sphinxcontrib.rsvgconverter',
    'ext.custom',
    'ext.LuaDomain',
    'ext.LuaLexer',
    'ext.TapLexer',
    'ext.TarantoolSessionLexer',
    'ext.DropdownList',
    'ext.WebPageSection',
    'ext.WebPageButtons',
    # 'ext.WebPageMap',
    'ext.ModuleBlock',
    'ext.DownloadPageBlock'
]
