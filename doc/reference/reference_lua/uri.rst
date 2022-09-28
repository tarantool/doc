-------------------------------------------------------------------------------
                            Module uri
-------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

*URI* stands for *Uniform Resource Identifier* - a sequence of characters that
identifies a logical or physical resource.
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

Tarantool's URI module provides functions that convert URI strings into their
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

    Parse a URI string into components. Possible components are:

    *   ``fragment``
    *   ``host``
    *   ``ipv4``
    *   ``ipv6``
    *   ``login``
    *   ``password``
    *   ``path``
    *   ``query``
    *   ``scheme``
    *   ``service``
    *   ``unix``

    ``uri.parse()`` is the reverse of :ref:`uri.format() <uri-format>`.

    :param URI-string: a Uniform Resource Identifier
    :return: URI components table.

    :rtype: Table

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> uri = require('uri')
        ---
        ...

        tarantool> uri.parse('scheme://login:password@host:service'..
        '/path1/path2/path3?q1=v1&q2=v2&q3=v3:1|v3:2#fragment')
        ---
        - login: login
          params:
            q1:
            - v1
            q2:
            - v2
            q3:
            - v3:1|v3:2
          service: service
          fragment: fragment
          password: password
          scheme: scheme
          query: q1=v1&q2=v2&q3=v3:1|v3:2
          host: host
          path: /path1/path2/path3
        ...

.. _uri-format:

.. function:: format(URI-components-table[, include-password])

    Form a URI string from its components. Possible components are:

    *   ``fragment``
    *   ``host``
    *   ``ipv4``
    *   ``ipv6``
    *   ``login``
    *   ``password``
    *   ``path``
    *   ``query``
    *   ``scheme``
    *   ``service``
    *   ``unix``

    ``uri.format()`` is the reverse of :ref:`uri.parse() <uri-parse>`.

    :param URI-components-table: a series of ``name=value`` pairs, one for each
                                 component
    :param include-password: boolean. If this is supplied and is ``true``, then
                             the password component is rendered in clear text,
                             otherwise it is omitted.
    :return: URI string
    :rtype: string

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> uri.format({scheme='scheme', login='login', password='password', host='host',
        service='service', path='/path1/path2/path3', query='q1=v1&q2=v2&q3=v3'})
        ---
        - scheme://login@host:service/path1/path2/path3
        ...

