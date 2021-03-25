Writing about code
==================

When writing articles, you have to format code specially, separating it from other text.
This document will guide you through typical cases when it is recommended to use code highlighting.

Defining what code is
---------------------

It is not difficult to recognize the code snippet in the text. First of all, it is probably code
if the expression contains characters that ordinary words do not have - ``_, {}, [ ], .``.
Also, you should format the expression as code if it fits at least one of the items in the list below:

*   attribute names, values and class names,
*   constant values for attributes,
*   method and function names,
*   language keywords,
*   data types,
*   error messages,
*   URL for localhost and intranet,
*   port number,
*   package names,
*   CLI app names.

**Items we don't format as code**

*   names of products, organizations and services, for example, Tarantool, memtx, vinyl
*   well-established terms such as stdin and stdout

Code-blocks and inline code
---------------------------

If you have to choose between inline code and code-block highlighting, pay attention
to the following guidelines:

Code snippets
~~~~~~~~~~~~~
Use code-blocks when you have to highlight multiple lines of code. Also, use it if your code snippet
contains a standalone element that is not a part of the article's text. In code-blocks, you can enable
syntax highlighting if you specify the language for the snippet. Note that in code-blocks you can write
comments and translate them.

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

Inline code
~~~~~~~~~~~
Use inline code when you need to wrap a short snippet of code in text, such as variable name
or function definition. Keep in mind that inline code doesn't have syntax highlighting.

To format some inline text as ``code``, enclose it with double ````` characters
or use the ``:code:`` role:

..  literalinclude:: _includes/inline-code.rst
    :language: rst

Both options produce the same output:

..  include:: _includes/inline-code.rst


Notes on using inline-code
^^^^^^^^^^^^^^^^^^^^^^^^^^

*   If you have expressions such as ``id==4``, you should format the whole expression as code inline.
    Also,you can use the words 'equals', 'doesn't equal' or other similar words without formatting expression as code.
    Both variants are correct.

*   Inline code can be used to highlight expressions that are hard to read, for example,
    words containing ``il``, ``Il`` or ``O0``.


Highlighting variables in code
------------------------------

If you need to mark up a placeholder inside code inline, use the ``:samp:`` role,
like this:

..  literalinclude:: _includes/samp.rst
    :language: rst

And you will get this:

..  include:: _includes/samp.rst

If you need to highlight a replaceable code in the code-block, use the following syntax:

    ``..  cssclass:: highlight``
    ``..  parsed-literal:: ``

And you will get this: