..  _http-module:

Module http
===========


..  module:: http.client

The ``http`` module, specifically the ``http.client`` submodule,
provides the functionality of an HTTP client with support for HTTPS and keepalive.
The HTTP client uses the `libcurl <https://curl.haxx.se/libcurl/>`_ library under the hood and
takes into account the `environment variables <https://curl.haxx.se/libcurl/c/libcurl-env.html>`_ libcurl understands.


.. _http_client_instance:

HTTP client instance
--------------------

.. _http_client_instance_default:

Default client
~~~~~~~~~~~~~~

The ``http.client`` submodule provides the default HTTP client instance:

..  literalinclude:: /code_snippets/test/http_client/default_client_get_test.lua
    :language: lua
    :lines: 1

In this case, you need to make requests using the dot syntax, for example:

..  literalinclude:: /code_snippets/test/http_client/default_client_get_test.lua
    :language: lua
    :lines: 2


.. _creating_client:

Creating a client
~~~~~~~~~~~~~~~~~

If you need to configure specific HTTP client options, use the :ref:`http.client.new() <http-new>` function to create the client instance:

..  literalinclude:: /code_snippets/test/http_client/get_test.lua
    :language: lua
    :lines: 1

In this case, you need to make requests using the colon syntax, for example:

..  literalinclude:: /code_snippets/test/http_client/get_test.lua
    :language: lua
    :lines: 2

All the examples in this section use the HTTP client created using ``http.client.new()``.


.. _making_requests:

Making requests
---------------

The :ref:`client instance <http_client_instance>` enables you to make HTTP requests.

.. _request_http_method:

HTTP method
~~~~~~~~~~~

The main way of making HTTP requests is the :ref:`request <client_object-request>` method, which accepts the following arguments:

*   An HTTP method, such as ``GET``, ``POST``, ``PUT``, and so on.
*   A request URL. You can use the :ref:`uri <uri-module>` module to construct a URL from its components.
*   (Optional) a request body for the ``POST``, ``PUT``, and ``PATCH`` methods.
*   (Optional) request options, such as request headers, SSL settings, and so on.

The example below shows how to make the ``GET`` request to the ``https://httpbin.org/get`` URL:

..  literalinclude:: /code_snippets/test/http_client/request_test.lua
    :language: lua
    :lines: 1-2

In addition to ``request``, the HTTP client provides the API for particular HTTP methods:
:ref:`get <client_object-get>`, :ref:`post <client_object-post>`, :ref:`put <client_object-put>`, and so on.
For example, you can replace the request above by calling ``get`` as follows:

..  literalinclude:: /code_snippets/test/http_client/get_test.lua
    :language: lua
    :lines: 1-2



.. _request_query_parameters:

Query parameters
~~~~~~~~~~~~~~~~

To add query string parameters, use the :ref:`params <request_options-params>` option exposed by the :ref:`request_options <request_options>` object:

..  literalinclude:: /code_snippets/test/http_client/get_add_query_params_test.lua
    :language: lua
    :lines: 1-5

In the example above, the requested URL is ``https://httpbin.org/get?page=1``.

.. NOTE::

    If a parameter name or value contains a reserved character (for example, ``&`` or ``=``),
    the HTTP client `encodes <https://en.wikipedia.org/wiki/URL_encoding>`_ a query string.


.. _request_headers:

Headers
~~~~~~~

To add headers to the request, use the :ref:`headers <request_options-headers>` option:

..  literalinclude:: /code_snippets/test/http_client/get_add_header_test.lua
    :language: lua
    :lines: 1-8


.. _request_cookies:

Cookies
~~~~~~~

You can add cookies to the request using the :ref:`headers <request_options-headers>` option:

..  literalinclude:: /code_snippets/test/http_client/get_add_cookie_test.lua
    :language: lua
    :lines: 1-7

To learn how to obtain cookies passed in the ``Set-Cookie`` response header, see :ref:`Response cookies <response_cookies>`.



.. _request_body:

Body
~~~~

.. _request_serialization:

Serialization
*************

The HTTP client automatically serializes the content in a specific format when sending a request based on the specified ``Content-Type`` header.
By default, the client uses the ``application/json`` content type and sends data serialized as JSON:

..  literalinclude:: /code_snippets/test/http_client/post_json_test.lua
    :language: lua
    :lines: 1-6

The body for the request above might look like this:

.. code-block:: console

    {
        "user_id": 123,
        "user_name": "John Smith"
    }

To send data in the YAML or MsgPack format, set the ``Content-Type`` header explicitly to ``application/yaml`` or ``application/msgpack``, for example:

..  literalinclude:: /code_snippets/test/http_client/post_yaml_test.lua
    :language: lua
    :lines: 1-10

In this case, the request body is serialized to YAML:

.. code-block:: console

    user_id: 123
    user_name: John Smith


.. _request_form_parameters:

Form parameters
***************

To send form parameters using the ``application/x-www-form-urlencoded`` type,
use the :ref:`params <request_options-params>` option:

..  literalinclude:: /code_snippets/test/http_client/post_form_params_test.lua
    :language: lua
    :lines: 1-5


.. _request_streaming_upload:

Streaming upload
****************

The HTTP client supports chunked writing of request data.
This can be achieved as follows:

1.  Set the :ref:`chunked <request_options-chunked>` option to ``true``.
    In this case, a request method returns :ref:`io_object <io_object>` instead of :ref:`response_object <response_object>`.
2.  Use the :ref:`io_object.write() <io_object-write>` method to write a chunk of data.
3.  Call the :ref:`io_object.finish() <io_object-finish>` method to finish writing data and make a request.

The example below shows how to upload data in two chunks:

..  literalinclude:: /code_snippets/test/http_client/post_stream_test.lua
    :language: lua
    :lines: 1-10



.. _receiving_responses:

Receiving responses
-------------------

All methods that are used to :ref:`make an HTTP request <making_requests>` (``request``, ``get``, ``post``, etc.) receive :ref:`response_object <response_object>`.
``response_object`` exposes the API required to get a response body and obtain response parameters, such as a status code, headers, and so on.

.. _response_status_code:

Status code
~~~~~~~~~~~

To get a response's status code and text, use the :ref:`response_object.status <response_object-status>` and :ref:`response_object.reason <response_object-reason>` options, respectively:

..  literalinclude:: /code_snippets/test/http_client/get_test.lua
    :language: lua
    :lines: 1-3


.. _response_headers:

Headers
~~~~~~~

The :ref:`response_object.headers <response_object-headers>` option returns a set of response headers.
The example below shows how to obtain the ``ETag`` header value:

..  literalinclude:: /code_snippets/test/http_client/get_header_test.lua
    :language: lua
    :lines: 1-3


.. _response_cookies:

Cookies
~~~~~~~

To obtain response cookies, use :ref:`response_object.cookies <response_object-cookies>`.
This option returns a Lua table where a cookie name is the key.
The value is an array of two elements where the first one is the cookie value and the second one is an array with the cookie's options.

The example below shows how to obtain the ``session_id`` cookie value:

..  literalinclude:: /code_snippets/test/http_client/get_cookies_test.lua
    :language: lua
    :lines: 1-3


.. _response_body:

Response body
~~~~~~~~~~~~~

.. _response_deserialization:

Deserialization
***************

The HTTP client can deserialize response data to a Lua object based on the ``Content-Type`` response header value.
To deserialize data, call the :ref:`response_object.decode() <response_object-decode>` method.
In the example below, the JSON response is deserialized into a Lua object:

..  literalinclude:: /code_snippets/test/http_client/get_json_test.lua
    :language: lua
    :lines: 1-4

The following content types are supported out of the box:

* ``application/json``
* ``application/msgpack``
* ``application/yaml``

If the response doesn't have the ``Content-Type`` header, the client uses ``application/json``.

To deserialize other content types, you need to provide a custom deserializer
using the :ref:`client_object.decoders <client_object-decoders>` property.
In the example below, ``application/xml`` responses are decoded using the
``luarapidxml`` library:

..  literalinclude:: /code_snippets/test/http_client/get_xml_test.lua
    :language: lua
    :lines: 1-12

The output for the code sample above should look as follows:

.. code-block:: console

    'title' value: Sample Slide Show



.. _response_decompressing:

Decompressing
*************

The HTTP client can automatically decompress a response body based on the ``Content-Encoding`` header value.
To enable this capability, pass the required formats using the
:ref:`request_options.accept_encoding <request_options-accept_encoding>` option:

..  literalinclude:: /code_snippets/test/http_client/get_gzip_test.lua
    :language: lua
    :lines: 1-3


.. _response_streaming_download:

Streaming download
******************

The HTTP client supports chunked reading of request data.
This can be achieved as follows:

1.  Set the :ref:`chunked <request_options-chunked>` option to ``true``.
    In this case, a request method returns :ref:`io_object <io_object>` instead of :ref:`response_object <response_object>`.
2.  Use the :ref:`io_object.read() <io_object-read>` method to read data in chunks of a specified length or
    up to a specific delimiter.
3.  Call the :ref:`io_object.finish() <io_object-finish>` method to finish reading data.

The example below shows how to get chunks of a JSON response sequentially instead of waiting for the entire response:

..  literalinclude:: /code_snippets/test/http_client/get_stream_test.lua
    :language: lua
    :lines: 1-13


.. _response_redirect:

Redirects
~~~~~~~~~

By default, the HTTP client redirects to a URL provided in the ``Location`` header of a ``3xx`` response.
If required, you can disable redirection using the :ref:`follow_location <request_options-follow_location>` option:

..  literalinclude:: /code_snippets/test/http_client/get_cookies_test.lua
    :language: lua
    :lines: 1-2



.. _http-module-api-reference:

API Reference
-------------

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 35 65

        *   -   **Functions**
            -

        *   -   :ref:`http.client.new() <http-new>`
            -   Create an HTTP client instance

        *   -   **Objects**
            -

        *   -   :ref:`client_options <client_options>`
            -   Configuration options of the client

        *   -   :ref:`client_object <client_object>`
            -   An HTTP client instance

        *   -   :ref:`request_options <request_options>`
            -   Options passed to a request

        *   -   :ref:`response_object <response_object>`
            -   A response object

        *   -   :ref:`io_object <io_object>`
            -   An IO object used to read/write data in chunks



..  _http-new:

http.client.new()
~~~~~~~~~~~~~~~~~

..  function:: new([options])

    Create an HTTP client instance.

    :param table options: configuration options of the client (see :ref:`client_options <client_options>`)

    :return: a new HTTP client instance (see :ref:`client_object <client_object>`)
    :rtype:  userdata

    **Example**

    ..  literalinclude:: /code_snippets/test/http_client/get_test.lua
        :language: lua
        :lines: 1


..  _client_options:

client_options
~~~~~~~~~~~~~~

..  class:: client_options

    Configuration options of the client.
    These options can be passed to the :ref:`http.client.new() <http-new>` function.

    ..  _client_options-max_connections:

    .. data:: max_connections

        Specifies the maximum number of entries in the cache.
        This option affects libcurl `CURLMOPT_MAXCONNECTS <https://curl.haxx.se/libcurl/c/CURLMOPT_MAXCONNECTS.html>`_.
        The default is ``-1``.

        **Example**

        ..  code-block:: lua

            local http_client = require('http.client').new({max_connections = 5})

        **Note**

        Do not set ``max_connections`` to less than ``max_total_connections`` unless you are confident about your actions.
        If ``max_connections`` is less than ``max_total_connections``,
        libcurl doesn't reuse sockets in some cases for requests that go to the same host.
        If the limit is reached and a new request occurs, then
        libcurl creates a new socket first, sends the request, waits for the first connection
        to be free, and closes it to avoid exceeding the ``max_connections`` cache size.
        In the worst case, libcurl creates a new socket for every request,
        even if all requests go to the same host.


    ..  _client_options-max_total_connections:

    .. data:: max_total_connections

        Specifies the maximum number of active connections.
        This option affects libcurl `CURLMOPT_MAX_TOTAL_CONNECTIONS <https://curl.haxx.se/libcurl/c/CURLMOPT_MAX_TOTAL_CONNECTIONS.html>`_.

        **Note**

        You may want to control the maximum number of sockets that a particular HTTP client uses simultaneously.
        If a system passes many requests to distinct hosts, then libcurl cannot reuse sockets.
        In this case, setting ``max_total_connections`` may be useful
        since it causes curl to avoid creating too many sockets, which would not be used anyway.



..  _client_object:

client_object
~~~~~~~~~~~~~

..  class:: client_object

    An HTTP client instance that exposes the API for :ref:`making requests <making_requests>`.
    To create the client, call :ref:`http.client.new() <http-new>`.

    ..  _client_object-request:

    ..  method:: request(method, url, body, opts)

        Make an HTTP request and receive a response.

        :param string method: a request HTTP method. Possible values: ``GET``, ``POST``, ``PUT``, ``PATCH``, ``OPTIONS``, ``HEAD``, ``DELETE``, ``TRACE``, ``CONNECT``.
        :param string url: a request URL, for example, ``https://httpbin.org/get``
        :param string body: a request body (see :ref:`Body <request_body>`)
        :param table opts: request options (see :ref:`request_options <request_options>`)

        :return:

            This method returns one of the following objects:

            *   :ref:`response_object <response_object>`
            *   :ref:`io_object <io_object>` if :ref:`request_options.chunked <request_options-chunked>` is set to ``true``

        :rtype: table

        **Example**

        ..  literalinclude:: /code_snippets/test/http_client/request_test.lua
            :language: lua
            :lines: 1-2

        **See also:** :ref:`Making requests <making_requests>`, :ref:`Receiving responses <receiving_responses>`


    ..  _client_object-get:

    ..  method:: get(url, opts)

        Make a ``GET`` request and receive a response.

        :param string url: a request URL, for example, ``https://httpbin.org/get``
        :param table opts: request options (see :ref:`request_options <request_options>`)

        :return:

            This method might return one of the following objects:

            *   :ref:`response_object <response_object>`
            *   :ref:`io_object <io_object>` if :ref:`request_options.chunked <request_options-chunked>` is set to ``true``

        :rtype: table

        **Example**

        ..  literalinclude:: /code_snippets/test/http_client/get_test.lua
            :language: lua
            :lines: 1-2

        **See also:** :ref:`Making requests <making_requests>`, :ref:`Receiving responses <receiving_responses>`


    ..  _client_object-post:

    ..  method:: post(url, body, opts)

        Make a ``POST`` request and receive a response.

        :param string url: a request URL, for example, ``https://httpbin.org/post``
        :param string body: a request body (see :ref:`Body <request_body>`)
        :param table opts: request options (see :ref:`request_options <request_options>`)

        :return:

            This method might return one of the following objects:

            *   :ref:`response_object <response_object>`
            *   :ref:`io_object <io_object>` if :ref:`request_options.chunked <request_options-chunked>` is set to ``true``

        :rtype: table

        **Example**

        ..  literalinclude:: /code_snippets/test/http_client/post_json_test.lua
            :language: lua
            :lines: 1-6

        **See also:** :ref:`Making requests <making_requests>`, :ref:`Receiving responses <receiving_responses>`


    ..  _client_object-put:

    ..  method:: put(url, body, opts)

        Make a ``PUT`` request and receive a response.

        :param string url: a request URL, for example, ``https://httpbin.org/put``
        :param string body: a request body (see :ref:`Body <request_body>`)
        :param table opts: request options (see :ref:`request_options <request_options>`)

        :return:

            This method might return one of the following objects:

            *   :ref:`response_object <response_object>`
            *   :ref:`io_object <io_object>` if :ref:`request_options.chunked <request_options-chunked>` is set to ``true``

        :rtype: table

        **See also:** :ref:`Making requests <making_requests>`, :ref:`Receiving responses <receiving_responses>`


    ..  _client_object-patch:

    ..  method:: patch(url, body, opts)

        Make a ``PATCH`` request and receive a response.

        :param string url: a request URL, for example, ``https://httpbin.org/patch``
        :param string body: a request body (see :ref:`Body <request_body>`)
        :param table opts: request options (see :ref:`request_options <request_options>`)

        :return:

            This method might return one of the following objects:

            *   :ref:`response_object <response_object>`
            *   :ref:`io_object <io_object>` if :ref:`request_options.chunked <request_options-chunked>` is set to ``true``

        :rtype: table

        **See also:** :ref:`Making requests <making_requests>`, :ref:`Receiving responses <receiving_responses>`


    ..  _client_object-delete:

    ..  method:: delete(url, opts)

        Make a ``DELETE`` request and receive a response.

        :param string url: a request URL, for example, ``https://httpbin.org/delete``
        :param table opts: request options (see :ref:`request_options <request_options>`)

        :return:

            This method might return one of the following objects:

            *   :ref:`response_object <response_object>`
            *   :ref:`io_object <io_object>` if :ref:`request_options.chunked <request_options-chunked>` is set to ``true``

        :rtype: table

        **See also:** :ref:`Making requests <making_requests>`, :ref:`Receiving responses <receiving_responses>`


    ..  _client_object-head:

    ..  method:: head(url, opts)

        Make a ``HEAD`` request and receive a response.

        :param string url: a request URL, for example, ``https://httpbin.org/get``
        :param table opts: request options (see :ref:`request_options <request_options>`)

        :return:

            This method might return one of the following objects:

            *   :ref:`response_object <response_object>`
            *   :ref:`io_object <io_object>` if :ref:`request_options.chunked <request_options-chunked>` is set to ``true``

        :rtype: table

        **See also:** :ref:`Making requests <making_requests>`, :ref:`Receiving responses <receiving_responses>`


    ..  _client_object-options:

    ..  method:: options(url, opts)

        Make an ``OPTIONS`` request and receive a response.

        :param string url: a request URL, for example, ``https://httpbin.org/get``
        :param table opts: request options (see :ref:`request_options <request_options>`)

        :return:

            This method might return one of the following objects:

            *   :ref:`response_object <response_object>`
            *   :ref:`io_object <io_object>` if :ref:`request_options.chunked <request_options-chunked>` is set to ``true``

        :rtype: table

        **See also:** :ref:`Making requests <making_requests>`, :ref:`Receiving responses <receiving_responses>`


    ..  _client_object-trace:

    ..  method:: trace(url, opts)

        Make a ``TRACE`` request and receive a response.

        :param string url: a request URL, for example, ``https://httpbin.org/get``
        :param table opts: request options (see :ref:`request_options <request_options>`)

        :return:

            This method might return one of the following objects:

            *   :ref:`response_object <response_object>`
            *   :ref:`io_object <io_object>` if :ref:`request_options.chunked <request_options-chunked>` is set to ``true``

        :rtype: table

        **See also:** :ref:`Making requests <making_requests>`, :ref:`Receiving responses <receiving_responses>`


    ..  _client_object-connect:

    ..  method:: connect(url, opts)

        Make a ``CONNECT`` request and receive a response.

        :param string url: a request URL, for example, ``server.example.com:80``
        :param table opts: request options (see :ref:`request_options <request_options>`)

        :return:

            This method might return one of the following objects:

            *   :ref:`response_object <response_object>`
            *   :ref:`io_object <io_object>` if :ref:`request_options.chunked <request_options-chunked>` is set to ``true``

        :rtype: table

        **See also:** :ref:`Making requests <making_requests>`, :ref:`Receiving responses <receiving_responses>`


    .. _client_object-stat:

    .. function:: stat()

        Get a table with statistics for the HTTP client:

        * ``active_requests`` -- the number of currently executing requests
        * ``sockets_added`` -- the total number of sockets added into an event loop
        * ``sockets_deleted`` -- the total number of sockets deleted from an event loop
        * ``total_requests`` -- the total number of requests
        * ``http_200_responses`` -- the total number of requests that returned HTTP ``200 OK`` responses
        * ``http_other_responses`` -- the total number of requests that returned non-``200 OK`` responses
        * ``failed_requests`` -- the total number of failed requests, including system, curl, and HTTP errors


    .. _client_object-decoders:

    .. data:: decoders

        **Since:** :doc:`2.11.0 </release/2.11.0>`

        Decoders used to deserialize response data based on the ``Content-Type`` header value.
        Learn more from :ref:`Deserialization <response_deserialization>`.

..  _request_options:

request_options
~~~~~~~~~~~~~~~

..  class:: request_options

    Options passed to a request method (:ref:`request <client_object-request>`, :ref:`get <client_object-get>`, :ref:`post <client_object-post>`, and so on).

    **See also:** :ref:`Making requests <making_requests>`

    ..  _request_options-ca_file:

    .. data:: ca_file

        The path to an SSL certificate file to verify the peer with.

        :rtype: string

    ..  _request_options-ca_path:

    .. data:: ca_path

        The path to a directory holding one or more certificates to verify the peer with.

        :rtype: string

    ..  _request_options-chunked:

    .. data:: chunked

        **Since:** :doc:`2.11.0 </release/2.11.0>`

        Specifies whether an HTTP client should return the full response (:ref:`response_object <response_object>`) or
        an IO object (:ref:`io_object <io_object>`) used for streaming download/upload.

        :rtype: boolean

        **See also:** :ref:`Streaming download <response_streaming_download>`, :ref:`Streaming upload <request_streaming_upload>`

    ..  _request_options-headers:

    .. data:: headers

        A table of :ref:`HTTP headers <request_headers>` passed to a request.

        :rtype: table

    ..  _request_options-params:

    .. data:: params

        **Since:** :doc:`2.11.0 </release/2.11.0>`

        A table of parameters passed to a request.
        The behavior of this option depends on the request type, for example:

        *   For a :ref:`GET <client_object-get>` request, this option specifies :ref:`query string parameters <request_query_parameters>`.
        *   For a :ref:`POST <client_object-post>` request, this option specifies :ref:`form parameters <request_form_parameters>` to be sent using the ``application/x-www-form-urlencoded`` type.

        :rtype: table

    ..  _request_options-keepalive_idle:

    .. data:: keepalive_idle

        A delay (in seconds) the operating system waits while the connection is idle before sending keepalive probes.

        :rtype: integer

        **See also:** `CURLOPT_TCP_KEEPIDLE <https://curl.haxx.se/libcurl/c/CURLOPT_TCP_KEEPIDLE.html>`_, :ref:`keepalive_interval <request_options-keepalive_interval>`


    ..  _request_options-keepalive_interval:

    .. data:: keepalive_interval

        The interval (in seconds) the operating system waits between sending keepalive probes.
        If both :ref:`keepalive_idle <request_options-keepalive_idle>` and ``keepalive_interval`` are set,
        then Tarantool also sets the HTTP keepalive headers: ``Connection:Keep-Alive`` and ``Keep-Alive:timeout=<keepalive_idle>``.
        Otherwise, Tarantool sends ``Connection:close``.

        :rtype: integer

        **See also:** `CURLOPT_TCP_KEEPINTVL <https://curl.haxx.se/libcurl/c/CURLOPT_TCP_KEEPINTVL.html>`_


    ..  _request_options-low_speed_limit:

    .. data:: low_speed_limit

        The average transfer speed in bytes per second that the transfer should be below
        during "low speed time" seconds for the library to consider it to be too slow and abort.

        :rtype: integer

        **See also:** `CURLOPT_LOW_SPEED_LIMIT <https://curl.haxx.se/libcurl/c/CURLOPT_LOW_SPEED_LIMIT.html>`_


    ..  _request_options-low_speed_time:

    .. data:: low_speed_time

        The time that the transfer speed should be below the "low speed limit" for the library to consider it too slow and abort.

        :rtype: integer

        **See also:** `CURLOPT_LOW_SPEED_TIME <https://curl.haxx.se/libcurl/c/CURLOPT_LOW_SPEED_TIME.html>`_


    ..  _request_options-max_header_name_len:

    .. data:: max_header_name_len

        The maximum length of a header name.
        If a header name length exceeds this value, it is truncated to this length.
        The default value is ``32``.

        :rtype: integer


    ..  _request_options-follow_location:

    .. data:: follow_location

        Specify whether the HTTP client follows redirect URLs provided in the ``Location`` header for ``3xx`` responses.
        When a non-``3xx`` response is received, the client returns it as a result.
        If you set this option to ``false``, the client returns the first ``3xx`` response.

        :rtype: boolean

        **See also:** :ref:`Redirects <response_redirect>`


    ..  _request_options-no_proxy:

    .. data:: no_proxy

        A comma-separated list of hosts that do not require proxies, or ``*``, or ``''``.

        *   Set :samp:`no_proxy = {host} [, {host} ...]` to specify
            hosts that can be reached without requiring a proxy, even if ``proxy`` is
            set to a non-blank value and/or if a proxy-related environment variable has been set.
        *   Set ``no__proxy = '*'`` to specify that all hosts can be reached
            without requiring a proxy, which is equivalent to setting ``proxy=''``.
        *   Set ``no_proxy = ''`` to specify that no hosts can be reached
            without requiring a proxy, even if a proxy-related environment variable
            (``HTTP_PROXY``) is used.

        If ``no_proxy`` is not set, then a proxy-related environment variable
        (``HTTP_PROXY``) may be used.

        :rtype: string

        **See also:** `CURLOPT_NOPROXY <https://curl.haxx.se/libcurl/c/CURLOPT_NOPROXY.html>`_


    ..  _request_options-proxy:

    .. data:: proxy

        A proxy server host or IP address, or ``''``.

        *   If ``proxy`` is a host or IP address, then it may begin with a scheme,
            for example, ``https://`` for an HTTPS proxy or ``http://`` for an HTTP proxy.
        *   If ``proxy`` is set to ``''`` an empty string, then proxy use is disabled,
            and no proxy-related environment variable is used.
        *   If ``proxy`` is not set, then a proxy-related environment variable may be used, such as
            ``HTTP_PROXY`` or ``HTTPS_PROXY`` or ``FTP_PROXY``, or ``ALL_PROXY`` if the
            protocol can be any protocol.

        :rtype: string

        **See also:** `CURLOPT_PROXY <https://curl.haxx.se/libcurl/c/CURLOPT_PROXY.html>`_


    ..  _request_options-proxy_port:

    .. data:: proxy_port

        A proxy server port.
        The default is ``443`` for an HTTPS proxy and ``1080`` for a non-HTTPS proxy.

        :rtype: integer

        **See also:** `CURLOPT_PROXYPORT <https://curl.haxx.se/libcurl/c/CURLOPT_PROXYPORT.html>`_


    ..  _request_options-proxy_user_pwd:

    .. data:: proxy_user_pwd

        A proxy server username and password.
        This option might have one of the following formats:

        *   :samp:`proxy_user_pwd = {user_name}:`
        *   :samp:`proxy_user_pwd = :{password}`
        *   :samp:`proxy_user_pwd = {user_name}:{password}`

        :rtype: string

        **See also:** `CURLOPT_USERPWD <https://curl.haxx.se/libcurl/c/CURLOPT_USERPWD.html>`_


    ..  _request_options-ssl_cert:

    .. data:: ssl_cert

        A path to an SSL client certificate file.

        :rtype: string

        **See also:** `CURLOPT_SSLCERT <https://curl.haxx.se/libcurl/c/CURLOPT_SSLCERT.html>`_


    ..  _request_options-ssl_key:

    .. data:: ssl_key

        A path to a private key file for a TLS and SSL client certificate.

        :rtype: string

        **See also:** `CURLOPT_SSLKEY <https://curl.haxx.se/libcurl/c/CURLOPT_SSLKEY.html>`_


    ..  _request_options-timeout:

    .. data:: timeout

        The number of seconds to wait for a curl API read request before timing out.
        The default timeout is set to infinity (``36586400100`` seconds).

        :rtype: integer


    ..  _request_options-unix_socket:

    .. data:: unix_socket

        A socket name to use instead of an Internet address for a local connection.

        :rtype: string

        **Example:** ``/tmp/unix_domain_socket.sock``


    ..  _request_options-verbose:

    .. data:: verbose

        Turn on/off a verbose mode.

        :rtype: boolean


    ..  _request_options-verify_host:

    .. data:: verify_host

        Enable verification of the certificate's name (CN) against the specified host.

        :rtype: integer

        **See also:** `CURLOPT_SSL_VERIFYHOST <https://curl.haxx.se/libcurl/c/CURLOPT_SSL_VERIFYHOST.html>`_

    ..  _request_options-verify_peer:

    .. data:: verify_peer

        Set on/off verification of the peer's SSL certificate.

        :rtype: integer

        **See also:** `CURLOPT_SSL_VERIFYPEER <https://curl.haxx.se/libcurl/c/CURLOPT_SSL_VERIFYPEER.html>`_


    ..  _request_options-accept_encoding:

    .. data:: accept_encoding

        Enable :ref:`decompression <response_decompressing>` of an HTTP response data
        based on the specified ``Accept-Encoding`` request header.
        You can pass the following values to this option:

        *   ``''`` -- if an empty string is passed, the ``Accept-Encoding`` contains all
            the supported encodings (``identity``, ``deflate``, ``gzip``, and ``br``).
        *   ``br, gzip, deflate`` -- a comma-separated list of encodings passed in ``Accept-Encoding``.

        :rtype: string

        **See also:** `CURLOPT_ACCEPT_ENCODING <https://curl.haxx.se/libcurl/c/CURLOPT_ACCEPT_ENCODING.html>`_




.. _response_object:

response_object
~~~~~~~~~~~~~~~

..  class:: response_object

    A response object returned by a request method (:ref:`request <client_object-request>`, :ref:`get <client_object-get>`, :ref:`post <client_object-post>`, and so on).

    **See also:** :ref:`io_object <io_object>`

    ..  _response_object-status:

    .. data:: status

        A response status code.

        :rtype: integer

        **See also:** :ref:`Status code <response_status_code>`

    ..  _response_object-reason:

    .. data:: reason

        A response status text.

        :rtype: string

        **See also:** :ref:`Status code <response_status_code>`


    ..  _response_object-headers:

    .. data:: headers

        Response headers.

        :rtype: table

        **See also:** :ref:`Headers <response_headers>`


    ..  _response_object-cookies:

    .. data:: cookies

        Response cookies.
        The value is an array of two elements where the first one is the
        cookie value and the second one is an array with the cookie's options.

        :rtype: table

        **See also:** :ref:`Cookies <response_cookies>`

    ..  _response_object-body:

    .. data:: body

        A response body.
        Use :ref:`decode <response_object-decode>` to decode the response body.

        :rtype: table

        **See also:** :ref:`Response body <response_body>`


    ..  _response_object-proto:

    .. data:: proto

        An HTTP protocol version.

        :rtype: string


    ..  _response_object-decode:

    .. function:: decode()

        **Since:** :doc:`2.11.0 </release/2.11.0>`

        Decode the response body to a Lua object based on the content type.

        :return: a decoded body
        :rtype: table

        **See also:** :ref:`Deserialization <response_deserialization>`




.. _io_object:

io_object
~~~~~~~~~

..  class:: io_object

    **Since:** :doc:`2.11.0 </release/2.11.0>`

    An IO object used to read or write data in chunks.
    To get an IO object instead of the full response (:ref:`response_object <response_object>`), you need to set the :ref:`chunked <request_options-chunked>` request option to ``true``.

    .. _io_object-read:

    .. function:: read(chunk[, timeout])
                  read(delimiter[, timeout])
                  read({chunk = chunk, delimiter = delimiter}[, timeout])

        Read request data in chunks of a specified length or up to a specific delimiter.

        :param integer chunk: the maximum number of bytes to read
        :param string delimiter: the delimiter used to stop reading data
        :param integer timeout: the number of seconds to wait. The default is ``10``.
        :return: A chunk of read data. Returns an empty string if there is nothing more to read.
        :rtype: string

        **See also:** :ref:`Streaming download <response_streaming_download>`


    .. _io_object-write:

    .. function:: write(data[, timeout])

        Write the specified chunk of data.

        :param table data: data to be written
        :param integer timeout: the number of seconds to wait. The default is ``10``.

        **See also:** :ref:`Streaming upload <request_streaming_upload>`

    .. _io_object-finish:

    .. function:: finish([timeout])

        Finish reading or writing data.

        :param integer timeout: the number of seconds to wait. The default is ``10``.

        **See also:** :ref:`Streaming download <response_streaming_download>`, :ref:`Streaming upload <request_streaming_upload>`
