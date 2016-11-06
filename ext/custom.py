# -*- coding: utf-8 -*-
"""
    .ext.custom
    ~~~~~~~~~~~~
"""

import re

from docutils import nodes, utils
from docutils.parsers.rst import roles

from sphinx.builders.linkcheck import CheckExternalLinksBuilder

import xml.etree.ElementTree as ET

def add_jinja_filters(app):
    # app.builder.templates.environment.filters['cleantitle'] = (
    #     lambda x: ''.join(ET.fromstring('<p>' + x + '</p>').itertext())
    # )
    def is_documentation(x):
        # print(x, x.startswith('doc/'))
        return x.startswith('doc/') or x == 'doc'
    app.builder.templates.environment.tests['documentation'] = is_documentation

_emphtext_re = re.compile('({\*{.+?}\*}|{\*\*{.+?}\*\*})')

def emph_literal_role(typ, rawtext, text, lineno, inliner,
                      options={}, content=[]):
    text = utils.unescape(text)
    pos = 0
    retnode = nodes.literal(role=typ.lower(), classes=[typ])
    # italic + bold
    for m in _emphtext_re.finditer(text):
        if m.start() > pos:
            txt = text[pos:m.start()]
            retnode += nodes.Text(txt, txt)
        emphtext = m.group(1)
        if emphtext[1:3] == '*{':
            emphtext = emphtext[3:-3]
            retnode += nodes.emphasis(emphtext, emphtext)
        elif emphtext[1:3] == '**':
            emphtext = emphtext[4:-4]
            retnode += nodes.strong(emphtext, emphtext)
        else:
            raise Exception('bad emph text: "%s"' % emphtext)
        pos = m.end()
    if pos < len(text):
        retnode += nodes.Text(text[pos:], text[pos:])
    return [retnode], []

def setup(app):
    '''
    Adds extra jinja filters.
    '''
    if not isinstance(app.builder, CheckExternalLinksBuilder):
        app.connect("builder-inited", add_jinja_filters)
    app.add_object_type('confval', 'confval', objname='configuration value',
                        indextemplate='pair: %s; configuration value')
    app.add_object_type('errcode', 'errcode', objname='error code value',
                        indextemplate='pair: %s; error code value')
    roles.register_local_role('extsamp', emph_literal_role)

    return {'version': '0.0.2', 'parallel_read_safe': True}
