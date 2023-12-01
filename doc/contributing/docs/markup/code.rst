Writing about code
==================

When writing articles, you need to format code specially, separating it from
other text. This document will guide you through typical cases when
it is recommended to use code highlighting.

Defining what code is
---------------------

In general, code is any text, processed by a machine. It is also probably code
if the expression contains characters that ordinary words do not have,
such as ``_, {}, [ ], .``.
Also, you should format the expression as code if it fits at least one
of the items in the list below:

*   parts of a programming language: names of classes, variables, and functions,
    short expressions, data types and so on,
*   multiline fragments of application logs,
*   example link which the reader will not open: ``example.com``, ``https://example.com:80``,
*   parts of URL, like port number,
*   package names,
*   CLI app names.

Items we don't format as code:

*   names of products, organizations and services, for example, Tarantool,
    memtx, vinyl
*   well-established terms such as stdin and stdout

Keep in mind that grammar doesn't apply to code, even inline.

*   Correct: "use ``shellcheck`` to analyze your Bash code".
*   Incorrect: "``shellcheck`` your Bash code". Please do not use code
    as a verb.
*   Even worse: "shellcheck your Bash code". There's no such word in English
    and we don't explain what to use.
*   Cursed: "try ``shellchecking`` your Bash code". There's no such word
    and no such application.

Code blocks and inline code
---------------------------

If you have to choose between inline code and code block highlighting,
pay attention to the following guidelines:

Code snippets
~~~~~~~~~~~~~

Use code blocks when you have to highlight multiple lines of code.
Also, use it if your code snippet contains a standalone element
that is not a part of the article's text.

For code snippets, we use the ``code-block:: language``
`directive <https://www.sphinx-doc.org/en/master/usage/restructuredtext/directives.html#directive-code-block>`_.
You can enable syntax highlighting if you specify the language for the snippet.
The most commonly used highlighting languages are:

*   ``tarantoolsession`` -- interactive Tarantool session,
    where command lines start with ``tarantool>`` prompt.
*   ``console`` -- interactive console session, where command lines
    start with ``$`` or ``#``.
*   ``lua``, ``bash`` or ``c`` for programming languages.
*   ``text`` for cases when we want the code block to have no highlighting.

Sphinx uses the Pygments library for highlighting source code.
For a complete list of possible languages, see the
`list of Pygments lexers <https://pygments.org/docs/lexers/>`_.

For example, a code snippet in Lua:

    ..  literalinclude:: _includes/lua.rst
        :language: rst

Lua syntax is highlighted in the output:

    ..  include:: _includes/lua.rst

Note that in code blocks you can write comments and translate them:

    ..  literalinclude:: _includes/comment.rst
        :language: rst

Inline code
~~~~~~~~~~~

Use inline code when you need to wrap a short snippet of code in text, such as
variable name or function definition. Keep in mind that inline code
doesn't have syntax highlighting.

To format some inline text as ``code``, enclose it with double ````` characters
or use the ``:code:`` role:

    ..  literalinclude:: _includes/inline-code.rst
        :language: rst

Both options produce the same output:

    ..  include:: _includes/inline-code.rst


Notes on using inline-code
^^^^^^^^^^^^^^^^^^^^^^^^^^

*   If you have expressions such as ``id==4``, you should format the whole
    expression as code inline. Also, you can use the words "equals",
    "doesn't equal" or other similar words without formatting expression
    as code. Both variants are correct.

*   Inline code can be used to highlight expressions that are hard to read,
    for example, words containing ``il``, ``Il`` or ``O0``.


Highlighting variables in code
------------------------------

If you need to mark up a placeholder inside code inline, use the ``:samp:`` or
our custom ``:extsamp:`` role, like this:

    ..  literalinclude:: _includes/samp.rst
        :language: rst

And you will get this:

    ..  include:: _includes/samp.rst

Notice two backslashes before the curly brackets in the first line.
They are needed to escape curly brackets from Lua syntax.

As you can see, ``:extsamp:`` extends the abilities of ``:samp:``.
It allows you to highlight placeholders in both italics and bold
and avoid escaping curly brackets.
``:extsamp:`` has the following syntax:

*   ``{*{element}*}`` for *italic*
*   ``{**{element}**}`` for **bold**

If you need to mark up a placeholder in code block, use
the following syntax:

    ..  literalinclude:: _includes/highlight.rst
        :language: rst

The output will look like this:

    .. include:: _includes/highlight.rst

Formatting file and directory names
-----------------------------------

If you need to highlight some file standalone name or path to file in text, use
the ``:file:`` role.
You can use curly braces inside this role
to mark up a replaceable part:

    .. literalinclude:: _includes/file.rst
        :language: rst

And you will get this:

    ..  include:: _includes/file.rst
