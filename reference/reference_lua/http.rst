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

    :param table options: integer settings which are passed to libcurl.

    The two possible options are ``max_connections`` and ``max_total_connections``.

    ``max_connections`` is the maximum number of entries in the cache.
    It affects libcurl `CURLMOPT_MAXCONNECTS <https://curl.haxx.se/libcurl/c/CURLMOPT_MAXCONNECTS.html>`_.
    The default is -1.

    ``max_total_connections`` is the maximum number of active connections.
    It affects libcurl  `CURLMOPT_MAX_TOTAL_CONNECTIONS <https://curl.haxx.se/libcurl/c/CURLMOPT_MAX_TOTAL_CONNECTIONS.html>`_.
    It is ignored if the curl version is less than 7.30.
    The default is 0, which allows libcurl to scale according to easy handles count.
    
    The default option values are usually good enough but in rare cases it
    might be good to set them. In that case here are two tips.

    1. You may want to control the maximum number of sockets that a particular http client uses simultaneously.
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

          * ``timeout`` - number of seconds to wait for a curl API read request
            before timing out
          * ``ca_path`` - path to a directory holding one or more certificates to
            verify the peer with
          * ``ca_file`` - path to an SSL certificate file to verify the peer with
          * ``verify_host`` - set on/off verification of the certificate's name
            (CN) against host. See also
            `CURLOPT_SSL_VERIFYHOST <https://curl.haxx.se/libcurl/c/CURLOPT_SSL_VERIFYHOST.html>`_
          * ``verify_peer`` - set on/off verification of the peer's SSL
            certificate. See also
            `CURLOPT_SSL_VERIFYPEER <https://curl.haxx.se/libcurl/c/CURLOPT_SSL_VERIFYPEER.html>`_
          * ``ssl_key`` - path to a private key file for a TLS and SSL client
            certificate. See also
            `CURLOPT_SSLKEY <https://curl.haxx.se/libcurl/c/CURLOPT_SSLKEY.html>`_
          * ``ssl_cert`` - path to a SSL client certificate file. See also
            `CURLOPT_SSLCERT <https://curl.haxx.se/libcurl/c/CURLOPT_SSLCERT.html>`_
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
          * ``unix_socket`` - a socket name to use instead of an Internet address,
            for a local connection. The Tarantool server must be built with
            ``libcurl`` 7.40 or later. See the :ref:`second example <http-example2>`
            later in this section.
          * ``max_header_name_len`` - the maximal length of a header name. If a header
            name is bigger than this value, it is truncated to this length.
            The default value is '32'.

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
        :samp:`HTTP_PROXY={proxy}` before initiating any requests.
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
