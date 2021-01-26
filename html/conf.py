exec(open('../conf.py').read())

locale_dirs = ['../locale']

exclude_patterns += [  # noqa
    'singlehtml.rst',
    'dev_guide/index.rst',
    'book/index.rst',
    'book/box/index.rst',
    'book/faq.rst',
    'book/intro.rst'
]
