.. _http-module:

-------------------------------------------------------------------------------
                          Module http
-------------------------------------------------------------------------------

.. module:: http.client

===============================================================================
                                   Overview
===============================================================================

The ``http`` module, specifically the ``http.client`` submodule,
provides the functionality of an HTTP client with support for HTTPS and keepalive.
It uses routines in the `libcurl <https://curl.haxx.se/libcurl/>`_ library.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``http`` functions.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`http.client.new()              | Create an HTTP client instance  |
    | <http-new>`                          |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`client_object:request()        | Perform an HTTP request         |
    | <client_object-request>`             |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`client_object:stat()           | Get a table with statistics     |
    | <client_object-stat>`                |                                 |
    +--------------------------------------+---------------------------------+

.. _http-new:

.. function:: new([options])

    Construct a new HTTP client instance.

    :param table options: integer settings which are passed to libcurl.

    The two possible options are ``max_connections`` and ``max_total_connections``.

    ``max_connections`` is the maximum number of entries in the cache.
    It affects libcurl `CURLMOPT_MAXCONNECTS <https://curl.haxx.se/libcurl/c/CURLMOPT_MAXCONNECTS.html>`_.
    The default is -1.

    ``max_total_connections`` is the maximum number of active connections.
    It affects libcurl  `CURLMOPT_MAX_TOTAL_CONNECTIONS <https://curl.haxx.se/libcurl/c/CURLMOPT_MAX_TOTAL_CONNECTIONS.html>`_.
    It is ignored if the curl version is less than 7.30.
    The default is 0, which allows libcurl to scale accordingly to easily handles count.
    
    The default option values are usually good enough but in rare cases it
    might be good to set them. In that case here are two tips.

    1. You may want to control the maximum number of sockets that a particular HTTP client uses simultaneously.
       If a system passes many requests to distinct hosts, then libcurl cannot reuse sockets.
       In this case setting ``max_total_connections`` may be useful,
       since it causes curl to avoid creating too many sockets which would not be used anyway.

    2. Do not set ``max_connections`` less than ``max_total_connections``
       unless you are confident about your actions.
       When ``max_connections`` is less then ``max_total_connections``, in some cases
       libcurl will not reuse sockets for requests that are going to the same host.
       If the limit is reached and a new request occurs, then 
       libcurl will first create a new socket, send the request, wait for the first connection
       to be free, and close it, in order to avoid exceeding the ``max_connections`` cache size.
       In the worst case, libcurl will create a new socket for every request,
       even if all requests are going to the same host.
       See `this Tarantool issue on github <https://github.com/tarantool/tarantool/issues/3945>`_
       for details.

    :return: a new HTTP client instance
    :rtype:  userdata

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> http_client = require('http.client').new({max_connections = 5})
        ---
        ...

.. class:: client_object

    .. _client_object-request:

    .. method:: request(method, url, body, opts)

        If ``http_client`` is an HTTP client instance, ``http_client:request()`` will
        perform an HTTP request and, if there is a successful connection,
        will return a table with connection information.

        :param string method: HTTP method, for example 'GET' or 'POST' or 'PUT'
        :param string url: location, for example 'https://tarantool.org/doc'
        :param string body: optional initial message, for example 'My text string!'
        :param table opts: table of connection options, with any of these
         components:

          * ``ca_file`` -- path to an SSL certificate file to verify the peer with
          * ``ca_path`` -- path to a directory holding one or more certificates to
            verify the peer with
          * ``headers`` -- table of HTTP headers
          * ``keepalive_idle`` -- delay, in seconds, that the operating system
            will wait while the connection is idle before sending keepalive
            probes. See also
            `CURLOPT_TCP_KEEPIDLE <https://curl.haxx.se/libcurl/c/CURLOPT_TCP_KEEPIDLE.html>`_
            and the note below about keepalive_interval.
          * ``keepalive_interval`` -- the interval, in seconds, that the operating
            system will wait between sending keepalive probes. See also
            `CURLOPT_TCP_KEEPINTVL <https://curl.haxx.se/libcurl/c/CURLOPT_TCP_KEEPINTVL.html>`_.
            If both ``keepalive_idle`` and ``keepalive_interval`` are set, then
            Tarantool will also set HTTP keepalive headers: ``Connection:Keep-Alive``
            and ``Keep-Alive:timeout=<keepalive_idle>``.
            Otherwise Tarantool will send ``Connection:close``
          * ``low_speed_limit`` -- set the "low speed limit" -- the average
            transfer speed in bytes per second that the transfer should be below
            during "low speed time" seconds for the library to consider it to be
            too slow and abort. See also
            `CURLOPT_LOW_SPEED_LIMIT <https://curl.haxx.se/libcurl/c/CURLOPT_LOW_SPEED_LIMIT.html>`_
          * ``low_speed_time`` -- set the "low speed time" -- the time that the
            transfer speed should be below the "low speed limit" for the library
            to consider it too slow and abort. See also
            `CURLOPT_LOW_SPEED_TIME <https://curl.haxx.se/libcurl/c/CURLOPT_LOW_SPEED_TIME.html>`_
          * ``max_header_name_len`` -- the maximal length of a header name. If a header
            name is bigger than this value, it is truncated to this length.
            The default value is '32'.
          * ``follow_location`` -- when the option is set to ``true`` (default)
            and the response has a 3xx code, the HTTP client will automatically issue
            another request to a location that a server sends in the ``Location``
            header. If the new response is 3xx again, the HTTP client will
            issue still another request and so on in a loop until a non-3xx response
            will be received. This last response will be returned as a result.
            Setting this option to ``false`` allows to disable this behavior.
            In this case, the HTTP client will return a 3xx response itself.
          * ``no_proxy`` -- a comma-separated list of hosts that do not require proxies, or '*', or ''.
            Set :samp:`no_proxy = {host} [, {host} ...]` to specify
            hosts that can be reached without requiring a proxy, even if ``proxy`` has
            been set to a non-blank value and/or if a proxy-related environment variable
            has been set.
            Set ``no__proxy = '*'`` to specify that all hosts can be reached
            without requiring a proxy, which is equivalent to setting ``proxy=''``.
            Set ``no_proxy = ''`` to specify that no hosts can be reached
            without requiring a proxy, even if a proxy-related environment variable
            (HTTP_PROXY) is used.
            If ``no_proxy`` is not set, then a proxy-related environment variable
            (HTTP_PROXY) may be used. See also
            `CURLOPT_NOPROXY <https://curl.haxx.se/libcurl/c/CURLOPT_NOPROXY.html>`_
          * ``proxy`` -- a proxy server host or IP address, or ''.
            If ``proxy`` is a host or IP address, then it may begin with a scheme,
            for example ``https://`` for an https proxy or ``http://`` for an http proxy.
            If ``proxy`` is set to '' an empty string, then proxy use is disabled,
            and no proxy-related environment variable will be used.
            If ``proxy`` is not set, then a proxy-related environment variable may be used, such as
            HTTP_PROXY or HTTPS_PROXY or FTP_PROXY, or ALL_PROXY if the
            protocol can be any protocol. See also
            `CURLOPT_PROXY <https://curl.haxx.se/libcurl/c/CURLOPT_PROXY.html>`_
          * ``proxy_port`` -- a proxy server port.
            The default is 443 for an https proxy and 1080 for a non-https proxy.
            See also
            `CURLOPT_PROXYPORT <https://curl.haxx.se/libcurl/c/CURLOPT_PROXYPORT.html>`_
          * ``proxy_user_pwd`` -- a proxy server user name and/or password.
            Format: :samp:`proxy_user_pwd = {user_name}:`
            or :samp:`proxy_user_pwd = :{password}`
            or :samp:`proxy_user_pwd = {user_name}:{password}`. See also
            `CURLOPT_USERPWD <https://curl.haxx.se/libcurl/c/CURLOPT_USERPWD.html>`_
          * ``ssl_cert`` -- path to a SSL client certificate file. See also
            `CURLOPT_SSLCERT <https://curl.haxx.se/libcurl/c/CURLOPT_SSLCERT.html>`_
          * ``ssl_key`` -- path to a private key file for a TLS and SSL client
            certificate. See also
            `CURLOPT_SSLKEY <https://curl.haxx.se/libcurl/c/CURLOPT_SSLKEY.html>`_
          * ``timeout`` -- number of seconds to wait for a curl API read request
            before timing out
          * ``unix_socket`` -- a socket name to use instead of an Internet address,
            for a local connection. The Tarantool server must be built with
            ``libcurl`` 7.40 or later. See the :ref:`second example <http-example2>`
            later in this section.
          * ``verbose`` -- set on/off verbose mode
          * ``verify_host`` -- set on/off verification of the certificate's name
            (CN) against host. See also
            `CURLOPT_SSL_VERIFYHOST <https://curl.haxx.se/libcurl/c/CURLOPT_SSL_VERIFYHOST.html>`_
          * ``verify_peer`` -- set on/off verification of the peer's SSL
            certificate. See also
            `CURLOPT_SSL_VERIFYPEER <https://curl.haxx.se/libcurl/c/CURLOPT_SSL_VERIFYPEER.html>`_
          * ``accept_encoding`` -- enables automatic decompression of HTTP responses
            by setting the contents of the `Accept-Encoding: header` sent in an 
            HTTP request and enabling decoding of a response when the `Content-Encoding: header` 
            is received. This option specifies what encoding to use.
            It can be an empty string which means the `Accept-Encoding: header` will
            contain all supported built-in encodings. Four encodings are supported: `identity`, 
            meaning non-compressed, `deflate` which requests the server to compress its 
            response using the zlib algorithm, `gzip` which requests the gzip algorithm and `br` 
            which is brotli. Provide them in the string as a comma-separated list of accepted 
            encodings, like: ``"br, gzip, deflate"``. 
            For details of the option, refer to `CURLOPT_ACCEPT_ENCODING <https://curl.haxx.se/libcurl/c/CURLOPT_ACCEPT_ENCODING.html>`_

        :return: connection information, with all of these components:

          * ``status`` -- HTTP response status
          * ``reason`` -- HTTP response status text
          * ``headers`` -- a Lua table with normalized HTTP headers
          * ``body`` -- response body
          * ``proto`` -- protocol version

        :rtype: table

        The ``cookies`` component contains a Lua table where the key is a cookie
        name. The value is an array of two elements where the first one is the
        cookie value and the second one is an array with the cookie’s options.
        Possible options are: "Expires", "Max-Age", "Domain", "Path", "Secure",
        "HttpOnly", "SameSite". Note that an option is a string with '='
        splitting the option's name and its value.
        `Here <https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies>`_
        you can find more info.

        **Example**

        You can use cookies information like this:

        .. code-block:: tarantoolsession

            tarantool> require('http.client').get('https://www.tarantool.io/en/').cookies
            ---
            - csrftoken:
              - bWJVkBybvX9LdJ8uLPOTVrit5P3VbRjE3potYVOuUnsSjYT5ahghDV06tXRkfnOl
              - - Max-Age=31449600
                - Path=/
            ...

            tarantool> cookies = require('http.client').get('https://www.tarantool.io/en/').cookies
            ---
            ...

            tarantool> options = cookies['csrftoken'][2]
            ---
            ...

            tarantool> for _, option in ipairs(options) do
                     > if option:startswith('csrftoken cookie's Max-Age = ') then
                     > print(option)
                     > end
                     > end

            csrftoken cookie's Max-Age = 31449600
            ---
            ...

            tarantool>

        The following "shortcuts" exist for requests:

        * ``http_client:get(url, options)`` -- shortcut for
          ``http_client:request("GET", url, nil, opts)``
        * ``http_client:post (url, body, options)`` -- shortcut for
          ``http_client:request("POST", url, body, opts)``
        * ``http_client:put(url, body, options)`` -- shortcut for
          ``http_client:request("PUT", url, body, opts)``
        * ``http_client:patch(url, body, options)`` -- shortcut for
          ``http_client:request("PATCH", url, body, opts)``
        * ``http_client:options(url, options)`` -- shortcut for
          ``http_client:request("OPTIONS", url, nil, opts)``
        * ``http_client:head(url, options)`` -- shortcut for
          ``http_client:request("HEAD", url, nil, opts)``
        * ``http_client:delete(url, options)`` -- shortcut for
          ``http_client:request("DELETE", url, nil, opts)``
        * ``http_client:trace(url, options)`` -- shortcut for
          ``http_client:request("TRACE", url, nil, opts)``
        * ``http_client:connect:(url, options)`` -- shortcut for
          ``http_client:request("CONNECT", url, nil, opts)``

        Requests may be influenced by environment variables, for example
        users can set up an http proxy by setting
        :samp:`HTTP_PROXY={proxy}` before initiating any requests,
        unless a ``proxy`` connection option has priority.
        See the web page document
        `Environment variables libcurl understands <https://curl.haxx.se/libcurl/c/libcurl-env.html>`_.

    .. _client_object-stat:

    .. function:: stat()

        The ``http_client:stat()`` function returns a table with statistics:

        * ``active_requests`` -- number of currently executing requests
        * ``sockets_added`` -- total number of sockets added into an event loop
        * ``sockets_deleted`` -- total number of sockets sockets from an event loop
        * ``total_requests`` -- total number of requests
        * ``http_200_responses`` -- total number of requests which have returned
          code HTTP 200
        * ``http_other_responses`` -- total number of requests which have not
          returned code HTTP 200
        * ``failed_requests`` -- total number of requests which have failed
          including system errors, curl errors, and HTTP errors

.. _http-example1:

**Example 1:**

Connect to an HTTP server, look at the size of the response for a 'GET' request,
and look at the statistics for the session.

.. code-block:: tarantoolsession

    tarantool> http_client = require('http.client').new()
    ---
    ...
    tarantool> r = http_client:request('GET','http://tarantool.org')
    ---
    ...
    tarantool> string.len(r.body)
    ---
    - 21725
    ...
    tarantool> http_client:stat()
    ---
    - total_requests: 1
      sockets_deleted: 2
      failed_requests: 0
      active_requests: 0
      http_other_responses: 0
      http_200_responses: 1
      sockets_added: 2

.. _http-example2:

**Example 2:**

Start two Tarantool instances on the same computer.

On the first Tarantool instance, listen on a Unix socket:

.. code-block:: lua

    box.cfg{listen='/tmp/unix_domain_socket.sock'}

On the second Tarantool instance, send via ``http_client``:

.. code-block:: lua

    box.cfg{}
    http_client = require('http.client').new({5})
    http_client:put('http://localhost/','body',{unix_socket = '/tmp/unix_domain_socket.sock'})

Terminal #1 will show an error message: "Invalid MsgPack".
This is not useful but demonstrates the syntax and demonstrates
that was sent was received.
