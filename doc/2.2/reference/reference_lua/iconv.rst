.. _iconv-module:

-------------------------------------------------------------------------------
                          Module `iconv`
-------------------------------------------------------------------------------

.. module:: iconv

===============================================================================
                                   Overview
===============================================================================

The ``iconv`` module provides a way to convert a string with
one encoding to a string with another encoding, for example from ASCII
to UTF-8. It is based on the POSIX iconv routines.

An exact list of the available encodings may depend on environment.
Typically the list includes ASCII, BIG5, KOI8R, LATIN8, MS-GREEK, SJIS,
and about 100 others. For a complete list, type ``iconv --list`` on a
terminal.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``iconv`` functions.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`iconv.new()                    | Create an iconv instance        |
    | <iconv-new>`                         |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`iconv.converter()              | Perform conversion on a string  |
    | <iconv-converter>`                   |                                 |
    +--------------------------------------+---------------------------------+

.. _iconv-new:

.. function:: new(to, from)

    Construct a new iconv instance.

    :param string to: the name of the encoding that we will convert to.
    :param string from: the name of the encoding that we will convert from.

    :return: a new iconv instance -- in effect, a callable function
    :rtype:  userdata

    If either parameter is not a valid name, there will be an error message.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> converter = require('iconv').new('UTF8', 'ASCII')
        ---
        ...

.. _iconv-converter:

.. function:: converter(input-string)

        Convert.

        :param string input-string: the string to be converted (the "from" string)

        :return: the string that results from the conversion (the "to" string)

        If anything in input-string cannot be converted, there will be an error message
        and the result string will be unchanged.

    **Example:**

    We know that the Unicode code point for "Д" (CYRILLIC CAPITAL LETTER DE)
    is hexadecimal 0414 according to the character database of Unicode_.
    Therefore that is what it will look like in UTF-16.
    We know that Tarantool typically uses the UTF-8 character set.
    So make a from-UTF-8-to-UTF-16 converter,
    use string.hex('Д') to show what Д's encoding looks like in the UTF-8 source,
    and use string.hex('Д'-after-conversion) to show what it looks like in the UTF-16 target.
    Since the result is 0414, we see that iconv conversion works.
    (Different iconv implementations might use different names, for example UTF-16BE instead of UTF16BE.)

    .. code-block:: tarantoolsession

        tarantool> string.hex('Д')
        ---
        - d094
        ...

        tarantool> converter = require('iconv').new('UTF16BE', 'UTF8')
        ---
        ...

        tarantool> utf16_string = converter('Д')
        ---
        ...

        tarantool> string.hex(utf16_string)
        ---
        - '0414'
        ...

.. _Unicode: http://www.unicode.org/Public/UCD/latest/ucd/UnicodeData.txt.

