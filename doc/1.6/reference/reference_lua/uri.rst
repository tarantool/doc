-------------------------------------------------------------------------------
                            Module `uri`
-------------------------------------------------------------------------------

A "URI" is a "Uniform Resource Identifier".
The `IETF standard <https://www.ietf.org/rfc/rfc2396.txt>`_
says a URI string looks like this: |br|
[scheme:]scheme-specific-part[#fragment] |br|
A common type, a hierarchical URI, looks like this: |br|
[scheme:][//authority][path][?query][#fragment] |br|
For example the string `'https://tarantool.org/x.html#y'`
has three components: https is the scheme, tarantool.org/x.html is the path, and y is the fragment.
Tarantool's URI module provides a routine which
converts URI strings into their components.

.. module:: uri

.. _uri-parse:

.. function:: parse(URI-string)

    :param URI-string: a Uniform Resource Identifier
    :returns: URI-components-table. Possible components are fragment, host, login, password, path, query, scheme, service.
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

.. _Universally unique identifier: https://en.wikipedia.org/wiki/Universally_unique_identifier
.. _syscall: https://en.wikipedia.org/wiki/Syscall
