..  _varbinary-module:

Module varbinary
================

.. _varbinary-module-overview:

Overview
--------

The ``varbinary`` module provides functions that convert `URI <https://en.wikipedia.org/wiki/Uniform_Resource_Identifier>`_ strings into their
components, or turn components into URI strings, for example:

..  literalinclude:: /code_snippets/test/uri/uri_parse_test.lua
    :language: lua
    :lines: 1-21

You can also use this module to encode and decode arbitrary strings using the specified encoding options.


.. _varbinary-module-api-reference:

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
        *   -   :ref:`varbinary.is() <varbinary_is>`
            -   Check that the argument is a varbinary object

        *   -   :ref:`varbinary.new() <varbinary_new>`
            -   Create a varbinary object

        *   -   **Metamethods**
            -

        *   -   :ref:`varbinary_object.__eq <varbinary_eq>`
            -   Encoding options that use unreserved symbols defined in RFC 3986

        *   -   :ref:`varbinary_object.__len <varbinary_len>`
            -   Encoding options that use unreserved symbols defined in RFC 3986

        *   -   :ref:`varbinary_object.__tostring <varbinary_tostring>`
            -   Encoding options that use unreserved symbols defined in RFC 3986


.. module:: varbinary

..  _varbinary-module-api-reference-functions:

Functions
~~~~~~~~~

.. _varbinary-new:

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


.. _varbinary_is:

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


..  _varbinary-module-api-reference-metamethods:

Metamethods
~~~~~~~~~~~

.. _varbinary_eq:

.. function:: __eq

    Encoding options that use unreserved symbols defined in RFC 3986.
    These are default options used to encode and decode using the :ref:`uri.escape() <uri-escape>`
    and :ref:`uri.unescape() <uri-unescape>` functions, respectively.

    **See also:** :ref:`uri_encoding_opts <uri_encoding_opts>`

    :rtype: table

.. _varbinary_len:

.. function:: __len

    Options used to encode the ``path`` URI component.

    **See also:** :ref:`uri_encoding_opts <uri_encoding_opts>`

    :rtype: table

.. _varbinary_tostring:

.. function:: __tostring

    Options used to encode specific ``path`` parts.

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
