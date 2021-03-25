Writing about code
==================

Code snippets
-------------

For code snippets, we use the ``code-block:: language``
`directive <https://www.sphinx-doc.org/en/master/usage/restructuredtext/directives.html#directive-code-block>`_
with an appropriate highlighting language.
The most commonly used highlighting languages are:

*   ``tarantoolsession``—interactive Tarantool session,
    where command lines start with ``tarantlool>`` prompt.
*   ``console``—interactive console session, where command lines start with ``$`` or ``#``.
*   ``lua``, ``bash`` or ``c`` for programming languages.
*   ``text`` for cases when we want the code block to have no highlighting.

Sphinx uses the Pygments library for highlighing source code.
For a complete list of possible languages, see the
`list of Pygments lexers <https://pygments.org/docs/lexers/>`_.

For example, a code snippet in Lua:

..  literalinclude:: _includes/lua.rst
    :language: rst

Lua syntax is highlighted in the output:

..  include:: _includes/lua.rst

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Inline code
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To format some inline text as ``code``, enclose it with double ````` characters
or use the ``:code:`` role:

..  literalinclude:: _includes/inline-code.rst
    :language: rst

Both options produce the same output:

..  include:: _includes/inline-code.rst

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Highlighting variables in code
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you need to highlight variables in code inline, use the ``:samp:`` role,
like this:

..  literalinclude:: _includes/samp.rst
    :language: rst

And you will get this:

..  include:: _includes/samp.rst