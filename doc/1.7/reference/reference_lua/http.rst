.. _http-module:

-------------------------------------------------------------------------------
                          Module `http`
-------------------------------------------------------------------------------

.. module:: http.client

The ``http`` module, specifically the ``http.client`` submodule,
provides the functionality of an HTTP client with support for HTTPS and keepalive.
It uses routines in the `libcurl <https://curl.haxx.se/libcurl/>`_ library.

.. _http-new:

.. function:: new([options])

    Construct a new HTTP client instance.

    :param table options: the maximum number of entries in the connection cache.

    :return: a new HTTP client instance
    :rtype:  userdata

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> http_client = require('http.client').new({5})
        ---
        ...

.. class:: client_object

    .. method:: request(method, url, body, opts)

        If ``http_client`` is an HTTP client instance, ``http_client:request()`` will
        perform an HTTP request and, if there is a successful connection,
        will return a table with connection information.

        :param string method: HTTP method, for example 'GET' or 'POST' or 'PUT'
        :param string url: location, for example 'https://tarantool.org/doc'
        :param string body: optional initial message, for example 'My text string!'
        :param table opts: table of connection options, with any of these components:

          * ``timeout`` - number of seconds to wait for a curl API read request
            before timing out
          * ``ca_path`` - path to a directory holding one or more certificates to
            verify the peer with
          * ``ca_file`` - path to an SSL certificate file to verify the peer with
          * ``headers`` - table of HTTP headers
          * ``keepalive_idle`` - delay, in seconds, that the operating system
            will wait while the connection is idle before sending keepalive
            probes. See also
            `CURLOPT_TCP_KEEPALIVE <https://curl.haxx.se/libcurl/c/CURLOPT_TCP_KEEPALIVE.html>`_
          * ``keepalive_interval`` - the interval, in seconds, that the operating
            system will wait between sending keepalive probes. See also
            `CURLOPT_TCP_KEEPALIVE <https://curl.haxx.se/libcurl/c/CURLOPT_TCP_KEEPALIVE.html>`_
          * ``low_speed_time`` - set the "low speed time" -- the time that the
            transfer speed should be below the "low speed limit" for the library
            to consider it too slow and abort. See also
            `CURLOPT_LOW_SPEED_TIME <https://curl.haxx.se/libcurl/c/CURLOPT_LOW_SPEED_TIME.html>`_
          * ``low_speed_limit`` - set the "low speed limit" -- the average
            transfer speed in bytes per second that the transfer should be below
            during "low speed time" seconds for the library to consider it to be
            too slow and abort. See also
            `CURLOPT_LOW_SPEED_LIMIT <https://curl.haxx.se/libcurl/c/CURLOPT_LOW_SPEED_LIMIT.html>`_
          * ``verbose`` - set on/off verbose mode

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
            ``http_client:request("POST", url, body, opts)``
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

    **Example:**

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
