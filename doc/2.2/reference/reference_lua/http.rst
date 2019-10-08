.. _http-module:

-------------------------------------------------------------------------------
                          Module `http`
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

    :param table options: the maximum number of entries in the connection cache.

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

          * ``ca_file`` - path to an SSL certificate file to verify the peer with
          * ``ca_path`` - path to a directory holding one or more certificates to
            verify the peer with
          * ``headers`` - table of HTTP headers
          * ``keepalive_idle`` - delay, in seconds, that the operating system
            will wait while the connection is idle before sending keepalive
            probes. See also
            `CURLOPT_TCP_KEEPIDLE <https://curl.haxx.se/libcurl/c/CURLOPT_TCP_KEEPIDLE.html>`_
            and the note below about keepalive_interval.
          * ``keepalive_interval`` - the interval, in seconds, that the operating
            system will wait between sending keepalive probes. See also
            `CURLOPT_TCP_KEEPINTVL <https://curl.haxx.se/libcurl/c/CURLOPT_TCP_KEEPINTVL.html>`_.
            If both keepalive_idle and keepalive_interval are set, then
            Tarantool will also set HTTP keepalive headers: Connection:Keep-Alive
            and Keep-Alive:timeout=<keepalive_idle>.
            Otherwise Tarantool will send Connection:close
          * ``low_speed_limit`` - set the "low speed limit" -- the average
            transfer speed in bytes per second that the transfer should be below
            during "low speed time" seconds for the library to consider it to be
            too slow and abort. See also
            `CURLOPT_LOW_SPEED_LIMIT <https://curl.haxx.se/libcurl/c/CURLOPT_LOW_SPEED_LIMIT.html>`_
          * ``low_speed_time`` - set the "low speed time" -- the time that the
            transfer speed should be below the "low speed limit" for the library
            to consider it too slow and abort. See also
            `CURLOPT_LOW_SPEED_TIME <https://curl.haxx.se/libcurl/c/CURLOPT_LOW_SPEED_TIME.html>`_
          * ``max_header_name_len`` - the maximal length of a header name. If a header
            name is bigger than this value, it is truncated to this length.
            The default value is '32'.
          * ``no_proxy`` - a comma-separated list of hosts that do not require proxies, or '*', or ''.
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
          * ``proxy`` - a proxy server host or IP address, or ''.
            If ``proxy`` is a host or IP address, then it may begin with a scheme,
            for example 'https://' for an https proxy or 'http:// for an http proxy.
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
          * ``ssl_cert`` - path to a SSL client certificate file. See also
            `CURLOPT_SSLCERT <https://curl.haxx.se/libcurl/c/CURLOPT_SSLCERT.html>`_
          * ``ssl_key`` - path to a private key file for a TLS and SSL client
            certificate. See also
            `CURLOPT_SSLKEY <https://curl.haxx.se/libcurl/c/CURLOPT_SSLKEY.html>`_
          * ``timeout`` - number of seconds to wait for a curl API read request
            before timing out
          * ``unix_socket`` - a socket name to use instead of an Internet address,
            for a local connection. The Tarantool server must be built with
            ``libcurl`` 7.40 or later. See the :ref:`second example <http-example2>`
            later in this section.
          * ``verbose`` - set on/off verbose mode
          * ``verify_host`` - set on/off verification of the certificate's name
            (CN) against host. See also
            `CURLOPT_SSL_VERIFYHOST <https://curl.haxx.se/libcurl/c/CURLOPT_SSL_VERIFYHOST.html>`_
          * ``verify_peer`` - set on/off verification of the peer's SSL
            certificate. See also
            `CURLOPT_SSL_VERIFYPEER <https://curl.haxx.se/libcurl/c/CURLOPT_SSL_VERIFYPEER.html>`_

        :return: connection information, with all of these components:

          * ``status`` - HTTP response status
          * ``reason`` - HTTP response status text
          * ``headers`` - a Lua table with normalized HTTP headers
          * ``body`` - response body
          * ``proto`` - protocol version

        :rtype: table

        The following "shortcuts" exist for requests:

        * ``http_client:get(url, options)`` - shortcut for
          ``http_client:request("GET", url, nil, opts)``
        * ``http_client:post (url, body, options)`` - shortcut for
          ``http_client:request("POST", url, body, opts)``
        * ``http_client:put(url, body, options)`` - shortcut for
          ``http_client:request("PUT", url, body, opts)``
        * ``http_client:patch(url, body, options)`` - shortcut for
          ``http_client:request("PATCH", url, body, opts)``
        * ``http_client:options(url, options)`` - shortcut for
          ``http_client:request("OPTIONS", url, nil, opts)``
        * ``http_client:head(url, options)`` - shortcut for
          ``http_client:request("HEAD", url, nil, opts)``
        * ``http_client:delete(url, options)`` - shortcut for
          ``http_client:request("DELETE", url, nil, opts)``
        * ``http_client:trace(url, options)`` - shortcut for
          ``http_client:request("TRACE", url, nil, opts)``
        * ``http_client:connect:(url, options)`` - shortcut for
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

        * ``active_requests`` - number of currently executing requests
        * ``sockets_added`` - total number of sockets added into an event loop
        * ``sockets_deleted`` - total number of sockets sockets from an event loop
        * ``total_requests`` - total number of requests
        * ``http_200_responses`` - total number of requests which have returned
          code HTTP 200
        * ``http_other_responses`` - total number of requests which have not
          returned code HTTP 200
        * ``failed_requests`` - total number of requests which have failed
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
