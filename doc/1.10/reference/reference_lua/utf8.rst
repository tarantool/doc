-------------------------------------------------------------------------------
                            Module `utf8`
-------------------------------------------------------------------------------

Tarantool's module for handling UTF-8 strings includes some functions
which are compatible with ones in
`Lua 5.3 <https://www.lua.org/manual/5.3/manual.html#6.5>`_
but Tarantool has much more. For example, because internally
Tarantool contains a complete copy of the
"International Components For Unicode" library,
there are comparison functions which understand the default ordering
for Cyrillic (Capital Letter Zhe Ж = Small Letter Zhe ж)
and Japanese (Hiragana A あ = Katakana A ア).

The functions are :ref:`lower <utf8-islower>` and :ref:`upper <utf8-isupper>` for case conversions,
:ref:`casecmp <utf8-casecmp>` and :ref:`cmp <utf8-cmp>` for comparisons,
:ref:`isalpha <utf8-isalpha>` and :ref:`isdigit <utf8-isdigit>` and :ref:`islower <utf8-islower>` and :ref:`isupper <utf8-isupper>` for determining character types,
:ref:`sub <utf8-sub>` for substrings,
:ref:`length <utf8-length>` for length in characters,
and :ref:`next <utf8-next>` as a tool for character-at-a-time iterations.

The module is fully built-in so require('utf8') is not necessary.

.. module:: utf8

.. _utf8-casecmp:

.. function:: casecmp(UTF8-string, utf8-string)

    :param UTF8-string string: a string encoded with UTF-8
    :return: -1 meaning "less", 0 meaning "equal", +1 meaning "greater"
    :rtype: number

    Compare two strings with the Default Unicode Collation Element Table
    (DUCET) for the
    `Unicode Collation Algorithm <http://www.unicode.org/Public/UCA/10.0.0/allkeys.txt>`_.
    Thus 'å' is less than 'B', even though the code-point value of å (229) is greater
    than the code-point value of B (66), because the algorithm depends on
    the values in the Collation Element Table, not the code values.

    The comparison is done with primary weights. Therefore the
    elements which affect secondary or later weights (such as "case"
    in Latin or Cyrillic alphabets, or "kana differentiation" in Japanese)
    are ignored. If asked "is this like a Microsoft case-insensitive
    accent-insensitive collation" we tend to answer "yes", though the
    Unicode Collation Algorithm is far more sophisticated than those
    terms imply.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> utf8.casecmp('é','e'),utf8.casecmp('E','e')
        ---
        - 0
        - 0
        ...

.. _utf8-char:

.. function:: char(code-point [, code-point ...])

    :param code-point number: a Unicode code point value, repeatable
    :return: a UTF-8 string
    :rtype: string

    The code-point number is the value that corresponds to a character
    in the
    `Unicode Character Database <http://www.unicode.org/Public/5.2.0/ucd/UnicodeData.txt>`_
    This is not the same as the byte values of the encoded character,
    because the UTF-8 encoding scheme is more complex than a simple
    copy of the code-point number.

    Another way to construct a string with Unicode characters is
    with the \\u{hex-digits} escape mechanism, for example 
    '\\u{41}\\u{42}' and utf8.char(65,66) both produce the string 'AB'.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> utf8.char(229)
        ---
        - å
        ...

.. _utf8-cmp:

.. function:: cmp(UTF8-string, utf8-string)

    :param UTF8-string string: a string encoded with UTF-8
    :return: -1 meaning "less", 0 meaning "equal", +1 meaning "greater"
    :rtype: number

    Compare two strings with the Default Unicode Collation Element Table
    (DUCET) for the
    `Unicode Collation Algorithm <http://www.unicode.org/Public/UCA/10.0.0/allkeys.txt>`_.
    Thus 'å' is less than 'B', even though the code-point value of å (229) is greater
    than the code-point value of B (66), because the algorithm depends on
    the values in the Collation Element Table, not the code values.

    The comparison is done with all weights, and upper case comes before lower case.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> utf8.cmp('é','e'),utf8.cmp('E','e')
        ---
        - 1
        - 1
        ...

.. _utf8-isalpha:

.. function:: isalpha(UTF8-character)

    :param UTF8-character string-or-number: a single UTF8 character, expressed as a one-byte string or a code point value
    :return: true or false
    :rtype: boolean

    Return true if the input character is an "alphabetic-like" character, otherwise return false.
    Generally speaking a character will be considered alphabetic-like provided it
    is typically used within a word, as opposed to a digit or punctuation.
    It does not have to be a character in an alphabet. Thus utf8.isalpha('漢') is true,
    and utf8.isalpha('あ') is true, but '漢' and 'あ' are neither upper-case nor lower-case.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> utf8.isalpha('Ж'),utf8.isalpha('å'),utf8.isalpha('9')
        ---
        - true
        - true
        - false
        ...

.. _utf8-isdigit:

.. function:: isdigit(UTF8-character)

    :param UTF8-character string-or-number: a single UTF8 character, expressed as a one-byte string or a code point value
    :return: true or false
    :rtype: boolean

    Return true if the input character is a digit, otherwise return false.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> utf8.isdigit('Ж'),utf8.isdigit('å'),utf8.isdigit('9')
        ---
        - false
        - false
        - true
        ...

.. _utf8-islower:

.. function:: islower(UTF8-character)

    :param UTF8-character string-or-number: a single UTF8 character, expressed as a one-byte string or a code point value
    :return: true or false
    :rtype: boolean

    Return true if the input character is lower case, otherwise return false.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> utf8.islower('Ж'),utf8.islower('å'),utf8.islower('9')
        ---
        - false
        - true
        - false
        ...

.. _utf8-isupper:

.. function:: isupper(UTF8-character)

    :param UTF8-character string-or-number: a single UTF8 character, expressed as a one-byte string or a code point value
    :return: true or false
    :rtype: boolean

    Return true if the input character is upper case, otherwise return false.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> utf8.isupper('Ж'),utf8.isupper('å'),utf8.isupper('9')
        ---
        - true
        - false
        - false
        ...

.. _utf8-length:

.. function:: length(UTF8-string [, start-byte [, end-byte]])

    :param UTF8-string string: a string encoded with UTF-8
    :param start-byte integer: byte position of the first character
    :param end-byte integer: byte position where to stop
    :return: the number of characters in the string, or between start and end
    :rtype: number, or error if the input string is not valid UTF-8

    Byte positions for start and end can be negative, which indicates
    "calculate from end of string" rather than "calculate from start of string".

    If an error occurs, the error return will include the byte position
    where the not-valid UTF-8 character was found, as a second value.

    UTF-8 is a variable-size encoding scheme. Typically
    a simple Latin letter takes one byte, a Cyrillic letter
    takes two bytes, a Chinese/Japanese character takes three
    bytes, and the maximum is four bytes.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> utf8.len('G'),utf8.len('ж'),utf8.len('あ')
        ---
        - 1
        - 1
        - 1
        ...

        tarantool> string.len('G'),string.len('ж'),string.len('あ')
        ---
        - 1
        - 2
        - 3
        ...

.. _utf8-lower:

.. function:: lower(UTF8-string)

    :param UTF8-string string: a string encoded with UTF-8
    :return: the same string, lower case
    :rtype: string, or error if the input string is not valid UTF-8

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> utf8.lower('ÅΓÞЖABCDEFG')
        ---
        - åγþжabcdefg
        ...

.. _utf8-next:

.. function:: next(UTF8-string [, start-byte])

    :param UTF8-string string: a string encoded with UTF-8
    :param start-byte integer: byte position where to start within the string, default is 1
    :return: byte position of the next character and the code point value of the next character
    :rtype: table, or error if the input string is not valid UTF-8

    The 'next' function is often used in a loop to get one character
    at a time from a UTF-8 string.

    **Example:**

    .. code-block:: tarantoolsession

        In the string 'åa' the first character is 'å', it starts
        at position 1, it takes two bytes to store so the
        character after it will be at position 3, its Unicode
        code point value is (decimal) 229.

        tarantool> utf8.next('åa', 1)
        ---
        - 3
        - 229
        ...

.. _utf8-sub:

.. function:: sub(UTF8-string [, start-character [, end-character]])

    :param UTF8-string string: a string encoded as UTF-8
    :param start-character number: the position of the first character
    :param end-character number: the position of the last character
    :return: a UTF-8 string, the "substring" of the input value
    :rtype: string

    Character positions for start and end can be negative, which indicates
    "calculate from end of string" rather than "calculate from start of string".

    The default value for start-character is 1, and the default value
    for end-character is the length of the input string. Therefore, saying
    utf8.sub('abc') will return 'abc', the same as the input string.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> utf8.sub('åγþжabcdefg', 5, 8)
        ---
        - abcd
        ...

.. _utf8-upper:

.. function:: upper(UTF8-string)

    :param UTF8-string string: a string encoded with UTF-8
    :return: the same string, upper case
    :rtype: string, or error if the input string is not valid UTF-8

    Warning: in rare cases the upper-case result may be longer
    than the lower-case input, for example utf8.upper('ß') is 'SS'.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> utf8.upper('åγþжabcdefg')
        ---
        - ÅΓÞЖABCDEFG
        ...
