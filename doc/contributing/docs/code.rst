================================================================================
What is code and how to format it
================================================================================

When writing articles, you have to format code specially, separating it from other text.
This document will guide you through typical cases when it is recommended to use code highlighting.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Defining what code is
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It is not difficult to recognize the code snippet in the text. First of all, it is probably code
if the expression contains characters that ordinary words do not have - ``_, {}, [ ], .``.
Also, you should format the expression as code if it fits at least one of the items in the list below:

* attribute names, values and class names,
* constant values for attributes,
* method and function name,
* data types,
* error messages,
* URL for localhost and intranet,
* port number,
* package names,
* CLI app names,
* language keywords.

**Items we don't format as code**
* names of products, organizations and services, for example, "Tarantool"
* memtx, vynyl
* well-established terms such as stdin and stdout

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Code-blocks and inline code
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you have to choose between inline code and code-block highlighting, pay attention
to the following guidelines:

Use inline code when you need to wrap a short snippet of code in text, such as variable name
or function definition. Keep in mind that inline code doesn't have syntax highlighting.
If you need to mark up a placeholder inside code inline, use the ``:samp:`` role.

Use code-blocks when you have to highlight multiple lines of code. Also, use it if your code snippet
contains a standalone element that is not a part of the article's text. In code-blocks, you can enable
syntax highlighting if you specify the language for the snippet.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Notes on using inline-code
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* If you have expressions such as ``id==4``, you should format the whole expression as code inline.
Also, you can use the words 'equals', 'doesn't equal' or other similar words without formatting
expression as code. Both variants are correct.
* Inline code can be used to highlight expressions that are hard to read, for example,
words containing ``il``, ``Il`` or ``O0``.