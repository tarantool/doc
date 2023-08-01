..  _uri-module:

Module uri
==========

.. _uri-module-overview:

Overview
--------

The URI module provides functions that convert `URI <https://en.wikipedia.org/wiki/Uniform_Resource_Identifier>`_ strings into their
components, or turn components into URI strings, for example:

..  literalinclude:: /code_snippets/test/uri/uri_parse_test.lua
    :language: lua
    :lines: 1-21

You can also use this module to encode and decode arbitrary strings using the specified encoding options.


.. _uri-module-api-reference:

API Reference
-------------

Below is a list of ``uri`` functions, properties, and related objects.

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 35 65

        *   -   **Functions**
            -

        *   -   :ref:`uri.parse() <uri-parse>`
            -   Get a table of URI components

        *   -   :ref:`uri.format() <uri-format>`
            -   Construct a URI from the specified components

        *   -   :ref:`uri.escape() <uri-escape>`
            -   Encode a string using the specified encoding options

        *   -   :ref:`uri.unescape() <uri-unescape>`
            -   Decode a string using the specified encoding options

        *   -   **Properties**
            -

        *   -   :ref:`uri.RFC3986 <uri-rfc3986>`
            -   Encoding options that use unreserved symbols defined in RFC 3986

        *   -   :ref:`uri.PATH <uri-path>`
            -   Options used to encode the ``path`` URI component

        *   -   :ref:`uri.PATH_PART <uri-path-part>`
            -   Options used to encode specific ``path`` parts

        *   -   :ref:`uri.QUERY <uri-query>`
            -   Options used to encode the ``query`` URI component

        *   -   :ref:`uri.QUERY_PART <uri-query-part>`
            -   Options used to encode specific ``query`` parts

        *   -   :ref:`uri.FRAGMENT <uri-fragment>`
            -   Options used to encode the ``fragment`` URI component

        *   -   :ref:`uri.FORM_URLENCODED <uri-form-url-encoded>`
            -   Options used to encode ``application/x-www-form-urlencoded`` form parameters

        *   -   **Related objects**
            -

        *   -   :ref:`uri_components <uri_components>`
            -   URI components

        *   -   :ref:`uri_encoding_opts <uri_encoding_opts>`
            -   URI encoding options


.. module:: uri

..  _uri-module-api-reference-functions:

Functions
~~~~~~~~~

.. _uri-parse:

.. function:: parse(uri-string)

    Parse a URI string into components.

    **See also:** :ref:`uri.format() <uri-format>`

    :param string uri-string: a URI string
    :return: a URI components table (see :ref:`uri_components <uri_components>`)

    :rtype: table

    **Example:**

    ..  literalinclude:: /code_snippets/test/uri/uri_parse_test.lua
        :language: lua
        :lines: 1-11


.. _uri-format:

.. function:: format(uri_components[, include_password])

    Construct a URI from the specified components.

    **See also:** :ref:`uri.parse() <uri-parse>`

    :param table uri_components: a series of ``name=value`` pairs, one for each
                                 component (see :ref:`uri_components <uri_components>`)
    :param boolean include_password: specify whether the password component is rendered in clear text;
                                     otherwise, it is omitted
    :return: URI string
    :rtype: string

    **Example:**

    ..  literalinclude:: /code_snippets/test/uri/uri_parse_test.lua
        :language: lua
        :lines: 1-2,13-21



.. _uri-escape:

.. function:: escape(string[, uri_encoding_opts])

    **Since:** :doc:`2.11.0 </release/2.11.0>`

    Encode a string using the specified encoding options.

    By default, ``uri.escape()`` uses encoding options defined by the :ref:`uri.RFC3986 <uri-rfc3986>` table.
    If required, you can customize encoding options using the ``uri_encoding_opts`` optional parameter, for example:

    *   Pass the predefined set of options targeted for encoding a specific URI part (for example, :ref:`uri.PATH <uri-path>` or :ref:`uri.QUERY <uri-query>`).

    *   Pass custom encoding options using the :ref:`uri_encoding_opts <uri_encoding_opts>` object.

    :param string: a string to encode
    :param table uri_encoding_opts: encoding options (optional, see :ref:`uri_encoding_opts <uri_encoding_opts>`)
    :return: an encoded string

    :rtype: string

    **Example 1:**

    This example shows how to encode a string using the default encoding options.

    ..  literalinclude:: /code_snippets/test/uri/uri_escape_test.lua
        :language: lua
        :lines: 1-8

    **Example 2:**

    This example shows how to encode a string using the :ref:`uri.FORM_URLENCODED <uri-form-url-encoded>` encoding options.

    ..  literalinclude:: /code_snippets/test/uri/uri_escape_test.lua
        :language: lua
        :lines: 1-2,16-21

    **Example 3:**

    This example shows how to encode a string using custom encoding options.

    ..  literalinclude:: /code_snippets/test/uri/uri_escape_test.lua
        :language: lua
        :lines: 1-2,29-38


.. _uri-unescape:

.. function:: unescape(string[, uri_encoding_opts])

    **Since:** :doc:`2.11.0 </release/2.11.0>`

    Decode a string using the specified encoding options.

    By default, ``uri.escape()`` uses encoding options defined by the :ref:`uri.RFC3986 <uri-rfc3986>` table.
    If required, you can customize encoding options using the ``uri_encoding_opts`` optional parameter, for example:

    *   Pass the predefined set of options targeted for encoding a specific URI part (for example, :ref:`uri.PATH <uri-path>` or :ref:`uri.QUERY <uri-query>`).

    *   Pass custom encoding options using the :ref:`uri_encoding_opts <uri_encoding_opts>` object.

    :param string: a string to decode
    :param table uri_encoding_opts: encoding options (optional, see :ref:`uri_encoding_opts <uri_encoding_opts>`)
    :return: a decoded string

    :rtype: string

    **Example 1:**

    This example shows how to decode a string using the default encoding options.

    ..  literalinclude:: /code_snippets/test/uri/uri_escape_test.lua
        :language: lua
        :lines: 1-2,9-14

    **Example 2:**

    This example shows how to decode a string using the :ref:`uri.FORM_URLENCODED <uri-form-url-encoded>` encoding options.

    ..  literalinclude:: /code_snippets/test/uri/uri_escape_test.lua
        :language: lua
        :lines: 1-2,22-27

    **Example 3:**

    This example shows how to decode a string using custom encoding options.

    ..  literalinclude:: /code_snippets/test/uri/uri_escape_test.lua
        :language: lua
        :lines: 1-2,29-32,39-44


..  _uri-module-api-reference-properties:

Properties
~~~~~~~~~~

.. _uri-rfc3986:

.. data:: RFC3986

    Encoding options that use unreserved symbols defined in RFC 3986.
    These are default options used to encode and decode using the :ref:`uri.escape() <uri-escape>`
    and :ref:`uri.unescape() <uri-unescape>` functions, respectively.

    **See also:** :ref:`uri_encoding_opts <uri_encoding_opts>`

    :rtype: table

.. _uri-path:

.. data:: PATH

    Options used to encode the ``path`` URI component.

    **See also:** :ref:`uri_encoding_opts <uri_encoding_opts>`

    :rtype: table

.. _uri-path-part:

.. data:: PATH_PART

    Options used to encode specific ``path`` parts.

    **See also:** :ref:`uri_encoding_opts <uri_encoding_opts>`

    :rtype: table

.. _uri-query:

.. data:: QUERY

    Options used to encode the ``query`` URI component.

    **See also:** :ref:`uri_encoding_opts <uri_encoding_opts>`

    :rtype: table

.. _uri-query-part:

.. data:: QUERY_PART

    Options used to encode specific ``query`` parts.

    **See also:** :ref:`uri_encoding_opts <uri_encoding_opts>`

    :rtype: table

.. _uri-fragment:

.. data:: FRAGMENT

    Options used to encode the ``fragment`` URI component.

    **See also:** :ref:`uri_encoding_opts <uri_encoding_opts>`

    :rtype: table

.. _uri-form-url-encoded:

.. data:: FORM_URLENCODED

    Options used to encode ``application/x-www-form-urlencoded`` form parameters.

    **See also:** :ref:`uri_encoding_opts <uri_encoding_opts>`

    :rtype: table


..  _uri-module-api-reference-objects:

Related objects
~~~~~~~~~~~~~~~

.. _uri_components:

uri_components
**************


..  class:: uri_components

    URI components.
    The ``uri_components`` object is used in the following functions:

    *   The :ref:`uri.parse() <uri-parse>` function returns the ``uri_components`` object.
    *   The :ref:`uri.format() <uri-format>` function accepts the ``uri_components`` object as an argument.


    ..  _uri_components-scheme:

    .. data:: scheme

        A URI scheme.

        **Examples:** ``https``, ``http``

    ..  _uri_components-login:

    .. data:: login

        A user name, which is a part of the ``userinfo`` subcomponent.

    ..  _uri_components-password:

    .. data:: password

        A password, which is a part of the ``userinfo`` subcomponent.

    ..  _uri_components-host:

    .. data:: host

        A host subcomponent.

        **Example:** ``www.tarantool.io``

    ..  _uri_components-service:

    .. data:: service

        A service subcomponent.
        This property might return different values depending on the used URI scheme, for example:

        *   If the ``https`` or ``http`` scheme is used, ``service`` returns the port value.
        *   If the Unix domain socket is used, ``service`` returns the socket path.

        **Examples:** ``3301``, ``/tmp/unix.sock``

    ..  _uri_components-path:

    .. data:: path

        A path component.

        **Example:** ``/doc/latest/reference/reference_lua/http/``

    ..  _uri_components-query:

    .. data:: query

        A query component.

        **Example:** ``key1=value1&key2=value2``

    ..  _uri_components-fragment:

    .. data:: fragment

        A fragment component.

        **Example:** ``api-reference``

    ..  _uri_components-ipv4:

    .. data:: ipv4

        An IPv4 address.

        **Example:** ``127.0.0.1``

    ..  _uri_components-ipv6:

    .. data:: ipv6

        An IPv6 address.

        **Example:** ``2a00:1148:b0ba:2016:12bf:48ff:fe78:fd10``

    ..  _uri_components-unix:

    .. data:: unix

        A Unix domain socket.

        **Example:** ``/tmp/unix.sock``


.. _uri_encoding_opts:

uri_encoding_opts
*****************


..  class:: uri_encoding_opts

    **Since:** :doc:`2.11.0 </release/2.11.0>`

    URI encoding options.
    These options can be passed to the :ref:`uri.escape() <uri-escape>` and :ref:`uri.unescape() <uri-unescape>` functions.

    **Example:**

    The example below shows how to encode a string using custom encoding options.

    ..  literalinclude:: /code_snippets/test/uri/uri_escape_test.lua
        :language: lua
        :lines: 1-2,29-38

    .. NOTE::

        The ``uri`` module also provides several sets of predefined options targeted for encoding a specific URI part (for example, :ref:`uri.PATH <uri-path>` or :ref:`uri.QUERY <uri-query>`).

    ..  _uri_encoding_opts-plus:

    .. data:: plus

        Enable encoding of ``+`` as the space character.
        By default, this property is set to ``false``.

        :rtype: boolean

    ..  _uri_components-unreserved:

    .. data:: unreserved

        Specify a Lua pattern defining unreserved symbols that are not encoded.

        :rtype: table

        **Example:** ``'a-zA-Z0-9%-._~'``
