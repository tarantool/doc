.. _string-module:

-------------------------------------------------------------------------------
                            Module `string`
-------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

.. module:: string

The :code:`string` module has everything in the
`standard Lua string library <https://www.lua.org/pil/20.html>`_, and some
Tarantool extensions.

In this section we only discuss the additional functions
that the Tarantool developers have added.

Below is a list of all additional ``string`` functions.

    .. container:: table

        .. rst-class:: left-align-column-1
        .. rst-class:: left-align-column-2

        +--------------------------------------+---------------------------------+
        | Name                                 | Use                             |
        +======================================+=================================+
        | :ref:`string.ljust()                 | Left-justify a string           |
        | <string-ljust>`                      |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`string.rjust()                 | Right-justify a string          |
        | <string-rjust>`                      |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`string.hex()                   | Get the hexadecimal value of a  |
        | <string-hex>`                        | string                          |
        +--------------------------------------+---------------------------------+
        | :ref:`string.startswith()            | Check if a string starts with   |
        | <string-startswith>`                 | a given substring               |
        +--------------------------------------+---------------------------------+
        | :ref:`string.endswith()              | Check if a string ends with a   |
        | <string-endswith>`                   | given substring                 |
        +--------------------------------------+---------------------------------+
        | :ref:`string.lstrip()                | Remove spaces on the left of a  |
        | <string-lstrip>`                     | string                          |
        +--------------------------------------+---------------------------------+
        | :ref:`string.rstrip()                | Remove spaces on the right of a |
        | <string-rstrip>`                     | string                          |
        +--------------------------------------+---------------------------------+
        | :ref:`string.strip()                 | Remove spaces on the left and   |
        | <string-strip>`                      | right of a string               |
        +--------------------------------------+---------------------------------+

.. _string-ljust:

.. function:: ljust(input-string, width [, pad-character])

    Return the string left-justified in a string of length ``width``.

    :param input-string: (string) the string to left-justify
    :param width: (integer) the width of the string after left-justifying
    :param pad-character: (string) a single character, default = 1 space

    :Return: left-justified string (unchanged if width <= string length)
    :Rtype: string

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> string = require('string')
        ---
        ...
        tarantool> string.ljust(' A', 5)
        ---
        - ' A   '
        ...

.. _string-rjust:

.. function:: rjust(input-string, width [, pad-character])

    Return the string right-justified in a string of length ``width``.

    :param input-string: (string) the string to right-justify
    :param width: (integer) the width of the string after right-justifying
    :param pad-character: (string) a single character, default = 1 space

    :Return: right-justified string (unchanged if width <= string length)
    :Rtype: string

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> string = require('string')
        ---
        ...
        tarantool> string.rjust('', 5, 'X')
        ---
        - 'XXXXX'
        ...

.. _string-hex:

.. function:: hex(input-string)

    Return the hexadecimal value of the input string.

    :param input-string: (string) the string to process

    :Return: hexadecimal, 2 hex-digit characters for each input character
    :Rtype: string

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> string = require('string')
        ---
        ...
        tarantool> string.hex('ABC ')
        ---
        - '41424320'
        ...

.. _string-startswith:

.. function:: startswith(input-string, start-string [, start-pos [, end-pos]])

    Return True if ``input-string`` starts with ``start-string``, otherwise return
    False.

    :param input-string: (string) the string where ``start-string`` should be looked for
    :param start-string: (string) the string to look for
    :param start-pos: (integer) position: where to start looking within ``input-string``
    :param end-pos: (integer) position: where to end looking within ``input-string``

    :Return: true or false
    :Rtype: boolean

    ``start-pos`` and ``end-pos`` may be negative, meaning the position should
    be calculated from the end of the string.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> string = require('string')
        ---
        ...
        tarantool> string.startswith(' A', 'A', 2, 5)
        ---
        - true
        ...

.. _string-endswith:

.. function:: endswith(input-string, end-string [, start-pos [, end-pos]])

    Return True if ``input-string`` ends with ``end-string``, otherwise return
    False.

    :param input-string: (string) the string where ``end-string`` should be looked for
    :param end-string: (string) the string to look for
    :param start-pos: (integer) position: where to start looking within ``input-string``
    :param end-pos: (integer) position: where to end looking within ``input-string``

    :Return: true or false
    :Rtype: boolean

    ``start-pos`` and ``end-pos`` may be negative, meaning the position should
    be calculated from the end of the string.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> string = require('string')
        ---
        ...
        tarantool> string.endswith('Baa', 'aa')
        ---
        - true
        ...

.. _string-split:

.. function:: split(input-string [, split-string])

    Split ``input-string`` into one or more output strings
    in a table. The places to split are the places where
    ``split-string`` occurs.

    :param input-string: (string) the string to split
    :param split-string: (string) the string to find within ``input-string``.
                         Default = space.

    :Return: table of strings that were split from ``input-string``
    :Rtype: table

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fiber = require('string')
        ---
        ...
        tarantool> string.split("A*BXX C", "XX")
        ---
        - - A*B
          - ' C'
        ...

.. _string-lstrip:

.. function:: lstrip(input-string)

    Return the value of the input string, but without spaces on the left.

    :param input-string: (string) the string to process

    :Return: result after stripping spaces from input string
    :Rtype: string

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> string = require('string')
        ---
        ...
        tarantool> string.lstrip(' ABC ')
        ---
        - 'ABC '
        ...

.. _string-rstrip:

.. function:: rstrip(input-string)

    Return the value of the input string, but without spaces on the right.

    :param input-string: (string) the string to process

    :Return: result after stripping spaces from input string
    :Rtype: string

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> string = require('string')
        ---
        ...
        tarantool> string.rstrip(' ABC ')
        ---
        - ' ABC'
        ...

.. _string-strip:

.. function:: strip(input-string)

    Return the value of the input string, but without spaces on the left or the right.

    :param input-string: (string) the string to process

    :Return: result after stripping spaces from input string
    :Rtype: string

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> string = require('string')
        ---
        ...
        tarantool> string.strip(' ABC ')
        ---
        - ABC
        ...


