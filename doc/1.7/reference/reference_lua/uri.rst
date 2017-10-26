-------------------------------------------------------------------------------
                            Module `uri`
-------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

A "URI" is a "Uniform Resource Identifier".
The `IETF standard <https://www.ietf.org/rfc/rfc2396.txt>`_
says a URI string looks like this: |br|
[scheme:]scheme-specific-part[#fragment] |br|
A common type, a hierarchical URI, looks like this: |br|
[scheme:][//authority][path][?query][#fragment] |br|
For example the string `'https://tarantool.org/x.html#y'`
has three components: https is the scheme, tarantool.org/x.html is the path,
and y is the fragment. Tarantool's URI module provides routines which
convert URI strings into their components,
or turn components into URI strings.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``uri`` functions.

    .. container:: table

        .. rst-class:: left-align-column-1
        .. rst-class:: left-align-column-2

        +--------------------------------------+---------------------------------+
        | Name                                 | Use                             |
        +======================================+=================================+
        | :ref:`uri.parse()                    | Get a table of URI components   |
        | <uri-parse>`                         |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`uri.format()                   | Construct a URI from components |
        | <uri-format>`                        |                                 |
        +--------------------------------------+---------------------------------+

.. module:: uri

.. _uri-parse:

.. function:: parse(URI-string)

    :param URI-string: a Uniform Resource Identifier
    :return: URI-components-table. Possible components are fragment, host, login, password, path, query, scheme, service.
    :rtype: Table

    **Example:**

    .. code-block:: none

        tarantool> uri = require('uri')
        ---
        ...

        tarantool> uri.parse('http://x.html#y')
        ---
        - host: x.html
          scheme: http
          fragment: y
        ...

.. _uri-format:

.. function:: format(URI-components-table)

    :param URI-components-table: a series of name:value pairs, one for each component
    :return: URI-string. Thus uri.format() is the reverse of uri.parse().
    :rtype: string

    **Example:**

    .. code-block:: none

        tarantool> uri.format({host = 'x.html', scheme = 'http', fragment = 'y'})
        ---
        - http://x.html#y
        ...

.. _Universally unique identifier: https://en.wikipedia.org/wiki/Universally_unique_identifier
.. _syscall: https://en.wikipedia.org/wiki/Syscall
