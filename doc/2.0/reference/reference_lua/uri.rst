-------------------------------------------------------------------------------
                            Module `uri`
-------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

A "URI" is a "Uniform Resource Identifier".
The `IETF standard <https://www.ietf.org/rfc/rfc2396.txt>`_
says a URI string looks like this:

.. code-block:: text

    [scheme:]scheme-specific-part[#fragment]

A common type, a hierarchical URI, looks like this:

.. code-block:: text

    [scheme:][//authority][path][?query][#fragment]

For example the string ``'https://tarantool.org/x.html#y'``
has three components:

* ``https`` is the scheme,
* ``tarantool.org/x.html`` is the path,
* ``y`` is the fragment.

Tarantool's URI module provides routines which convert URI strings into their
components, or turn components into URI strings.

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
    :return: URI-components-table. Possible components are fragment, host,
             login, password, path, query, scheme, service.
    :rtype: Table

    **Example:**

    .. code-block:: tarantoolsession

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

.. function:: format(URI-components-table[, include-password])

    :param URI-components-table: a series of name:value pairs, one for each
                                 component
    :param include-password: boolean. If this is supplied and is ``true``, then
                             the password component is rendered in clear text,
                             otherwise it is omitted.
    :return: URI-string. Thus uri.format() is the reverse of uri.parse().
    :rtype: string

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> uri.format({host = 'x.html', scheme = 'http', fragment = 'y'})
        ---
        - http://x.html#y
        ...

.. _Universally unique identifier: https://en.wikipedia.org/wiki/Universally_unique_identifier
.. _syscall: https://en.wikipedia.org/wiki/Syscall
