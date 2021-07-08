# -*- coding: utf-8 -*-
# This lexer was submitted to Pygments in December 2014 by Matt Layman.
# Because it has not yet been merged into the main Pygments project, it is
# included in tappy as an extension to Pygments.
"""
    pygments.lexers.tap
    ~~~~~~~~~~~~~~~~~~~

    Lexer for the Test Anything Protocol (TAP).

    :copyright: Copyright 2006-2014 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

from pygments.lexer import bygroups, RegexLexer
from pygments.token import Comment, Generic, Keyword, Name, Number, Text

__all__ = ['TAPLexer']


class TAPLexer(RegexLexer):
    """
    For Test Anything Protocol (TAP) output.

    .. versionadded:: 2.1
    """
    name = 'TAP'
    aliases = ['tap']
    filenames = ['*.tap']

    tokens = {
        'root': [
            (r'^TAP version \d+\n', Name.Namespace), # A TAP version may be specified.
            (r'^1..\d+', Keyword.Declaration, 'plan'), # Specify a plan with a plan line.
            (r'^(not ok)([^\S\n]*)(\d*)', bygroups(Generic.Error, Text, Number.Integer), 'test'), # A test failure
            (r'^(ok)([^\S\n]*)(\d*)', bygroups(Keyword.Reserved, Text, Number.Integer), 'test'), # A test success
            (r'^#.*\n', Comment), # Diagnostics start with a hash.
            (r'^Bail out!.*\n', Generic.Error), # TAP's version of an abort statement.
            (r'^.*\n', Text), # TAP ignores any unrecognized lines.
        ],
        'plan': [
            (r'[^\S\n]+', Text), # Consume whitespace (but not newline).
            (r'#', Comment, 'directive'), # A plan may have a directive with it.
            (r'\n', Comment, '#pop'), # Or it could just end.
            (r'.*\n', Generic.Error, '#pop'), # Anything else is wrong.
        ],
        'test': [
            (r'[^\S\n]+', Text), # Consume whitespace (but not newline).
            (r'#', Comment, 'directive'), # A test may have a directive with it.
            (r'\S+', Text),
            (r'\n', Text, '#pop'),
        ],
        'directive': [
            (r'[^\S\n]+', Comment), # Consume whitespace (but not newline).
            (r'(?i)\bTODO\b', Comment.Preproc), # Extract todo items.
            (r'(?i)\bSKIP\S*', Comment.Preproc), # Extract skip items.
            (r'\S+', Comment),
            (r'\n', Comment, '#pop:2'),
        ],
    }

def setup(app):
    app.add_lexer('tap', TAPLexer)
