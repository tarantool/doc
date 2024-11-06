.. _tcm_configuration_reference:

Configuration reference
=======================

..  include:: index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

This topic describes :ref:`configuration parameters <tcm_configuration>` of |tcm_full_name|.

There are the following groups of |tcm| configuration parameters:

- :ref:`cluster <tcm_configuration_reference_cluster>`
- :ref:`http <tcm_configuration_reference_http>`
- :ref:`log <tcm_configuration_reference_log>`
- :ref:`storage <tcm_configuration_reference_storage>`
- :ref:`addon <tcm_configuration_reference_addon>`
- :ref:`limits <tcm_configuration_reference_limits>`
- :ref:`security <tcm_configuration_reference_security>`
- :ref:`mode <tcm_configuration_reference_mode>`
- :ref:`initial-settings <tcm_configuration_reference_initial>`

.. _tcm_configuration_reference_cluster:

cluster
-------

The ``cluster`` group defines parameters of |tcm| interaction with connected
Tarantool clusters.

-   :ref:`connection-rate-limit <tcm_configuration_reference_cluster_connection-rate-limit>`
-   :ref:`tarantool-timeout <tcm_configuration_reference_cluster_tarantool-timeout>`
-   :ref:`tarantool-ping-timeout <tcm_configuration_reference_cluster_tarantool-ping-timeout>`
-   :ref:`tt-command <tcm_configuration_reference_cluster_tt-command>`
-   :ref:`refresh-state-period <tcm_configuration_reference_cluster_refresh-state-period>`
-   :ref:`refresh-state-timeout <tcm_configuration_reference_cluster_refresh-state-timeout>`
-   :ref:`discovery-period <tcm_configuration_reference_cluster_discovery-period>`
-   :ref:`sharding-index <tcm_configuration_reference_cluster_sharding-index>`
-   :ref:`skew-time <tcm_configuration_reference_cluster_skew-time>`
-   :ref:`fragmentation-threshold <tcm_configuration_reference_cluster_fragmentation-threshold>`

.. _tcm_configuration_reference_cluster_connection-rate-limit:

.. confval:: cluster.connection-rate-limit

    A rate limit for connections to Tarantool instances.

    |
    | Type: uint
    | Default: 512
    | Environment variable: TCM_CLUSTER_CONNECTION_RATE_LIMIT
    | Command-line option: ``--cluster.connection-rate-limit``

.. _tcm_configuration_reference_cluster_tarantool-timeout:

.. confval:: cluster.tarantool-timeout

    A timeout for receiving a response from Tarantool instances.

    |
    | Type: time.Duration
    | Default: 10s
    | Environment variable: TCM_CLUSTER_TARANTOOL_TIMEOUT
    | Command-line option: ``--cluster.tarantool-timeout``

.. _tcm_configuration_reference_cluster_tarantool-ping-timeout:

.. confval:: cluster.tarantool-ping-timeout

    A timeout for receiving a ping response from Tarantool instances.

    |
    | Type: time.Duration
    | Default: 5s
    | Environment variable: TCM_CLUSTER_TARANTOOL_PING_TIMEOUT
    | Command-line option: ``--cluster.tarantool-ping-timeout``

.. _tcm_configuration_reference_cluster_tt-command:

.. confval:: cluster.tt-command

    The command that runs the :ref:`tt <tt-cli>` utility on hosts with cluster instances.

    |
    | Type: string
    | Default: `tt`
    | Environment variable: TCM_CLUSTER_TT_COMMAND
    | Command-line option: ``--cluster.tt-command``

.. _tcm_configuration_reference_cluster_refresh-state-period:

.. confval:: cluster.refresh-state-period

    The time interval for refreshing the cluster instances state on the Stateboard.

    |
    | Type: time.Duration
    | Default: 5s
    | Environment variable: TCM_CLUSTER_REFRESH_STATE_PERIOD
    | Command-line option: ``--cluster.refresh-state-period``

.. _tcm_configuration_reference_cluster_refresh-state-timeout:

.. confval:: cluster.refresh-state-timeout

    The time limit for refreshing an instance state.
    If this limit is reached, an error is shown.

    |
    | Type: time.Duration
    | Default: 4s
    | Environment variable: TCM_CLUSTER_REFRESH_STATE_TIMEOUT
    | Command-line option: ``--cluster.refresh-state-timeout``

.. _tcm_configuration_reference_cluster_discovery-period:

.. confval:: cluster.discovery-period

    The time interval for checking the leadership in replica sets.

    |
    | Type: time.Duration
    | Default: 4s
    | Environment variable: TCM_CLUSTER_DISCOVERY_PERIOD
    | Command-line option: ``--cluster.discovery-period``

.. _tcm_configuration_reference_cluster_sharding-index:

.. confval:: cluster.sharding-index

    The name of the space field that is used as a sharding key.

    |
    | Type: string
    | Default: `bucket_id`
    | Environment variable: TCM_CLUSTER_SHARDING_INDEX
    | Command-line option: ``--cluster.sharding-index``

.. _tcm_configuration_reference_cluster_skew-time:

.. confval:: cluster.skew-time

    The maximum time skew between any two cluster instances.
    If this limit is reached, a warning is shown.

    |
    | Type: time.Duration
    | Default: 30s
    | Environment variable: TCM_CLUSTER_SKEW_TIME
    | Command-line option: ``--cluster.skew-time``

.. _tcm_configuration_reference_cluster_fragmentation-threshold:

.. confval:: cluster.fragmentation-threshold

    The count of allocated slabs that reflects high memory fragmentation.
    When this number is reached, a warning is shown.

    See also: :ref:`engines-memtx`

    |
    | Type: int
    | Default: 40
    | Environment variable: TCM_CLUSTER_FRAGMENTATION_THRESHOLD
    | Command-line option: ``--cluster.fragmentation-threshold``

.. _tcm_configuration_reference_http:

http
----

The ``http`` group defines parameters of HTTP connections between |tcm| and clients.

-   :ref:`http.network <tcm_configuration_reference_http_network>`
-   :ref:`http.host <tcm_configuration_reference_http_host>`
-   :ref:`http.port <tcm_configuration_reference_http_port>`
-   :ref:`http.request-size <tcm_configuration_reference_http_request-size>`
-   :ref:`http.websocket.read-buffer-size <tcm_configuration_reference_http_websocket_read-buffer-size>`
-   :ref:`http.websocket.write-buffer-size <tcm_configuration_reference_http_websocket_write-buffer-size>`
-   :ref:`http.websocket.keepalive-ping-interval <tcm_configuration_reference_http_websocket_keepalive-ping-interval>`
-   :ref:`http.websocket.handshake-timeout <tcm_configuration_reference_http_websocket_handshake-timeout>`
-   :ref:`http.websocket.init-timeout <tcm_configuration_reference_http_websocket_init-timeout>`
-   :ref:`http.websession-cookie.name <tcm_configuration_reference_http_websession-cookie_name>`
-   :ref:`http.websession-cookie.path <tcm_configuration_reference_http_websession-cookie_path>`
-   :ref:`http.websession-cookie.domain <tcm_configuration_reference_http_websession-cookie_domain>`
-   :ref:`http.websession-cookie.ttl <tcm_configuration_reference_http_websession-cookie_ttl>`
-   :ref:`http.websession-cookie.secure <tcm_configuration_reference_http_websession-cookie_secure>`
-   :ref:`http.websession-cookie.http-only <tcm_configuration_reference_http_websession-cookie_http-only>`
-   :ref:`http.websession-cookie.same-site <tcm_configuration_reference_http_websession-cookie_same-site>`
-   :ref:`http.cors.enabled <tcm_configuration_reference_http_cors_enabled>`
-   :ref:`http.cors.allowed-origins <tcm_configuration_reference_http_cors_allowed-origins>`
-   :ref:`http.cors.allowed-methods <tcm_configuration_reference_http_cors_allowed-methods>`
-   :ref:`http.cors.allowed-headers <tcm_configuration_reference_http_cors_allowed-headers>`
-   :ref:`http.cors.exposed-headers <tcm_configuration_reference_http_cors_exposed-headers>`
-   :ref:`http.cors.allow-credentials <tcm_configuration_reference_http_cors_allow-credentials>`
-   :ref:`http.cors.debug <tcm_configuration_reference_http_cors_debug>`
-   :ref:`http.tls.enabled <tcm_configuration_reference_http_tls_enabled>`
-   :ref:`http.tls.cert-file <tcm_configuration_reference_http_tls_cert-file>`
-   :ref:`http.tls.key-file <tcm_configuration_reference_http_tls_key-file>`
-   :ref:`http.tls.server <tcm_configuration_reference_http_tls_server>`
-   :ref:`http.tls.min-version <tcm_configuration_reference_http_tls_min-version>`
-   :ref:`http.tls.max-version <tcm_configuration_reference_http_tls_max-version>`
-   :ref:`http.tls.curve-preferences <tcm_configuration_reference_http_tls_curve-preferences>`
-   :ref:`http.tls.cipher-suites <tcm_configuration_reference_http_tls_cipher-suites>`
-   :ref:`http.read-timeout <tcm_configuration_reference_http_read-timeout>`
-   :ref:`http.read-header-timeout <tcm_configuration_reference_http_read-header-timeout>`
-   :ref:`http.write-timeout <tcm_configuration_reference_http_write-timeout>`
-   :ref:`http.idle-timeout <tcm_configuration_reference_http_idle-timeout>`
-   :ref:`http.disable-general-options-handler <tcm_configuration_reference_http_disable-general-options-handler>`
-   :ref:`http.max-header-bytes <tcm_configuration_reference_http_max-header-bytes>`
-   :ref:`http.api-timeout <tcm_configuration_reference_http_api-timeout>`
-   :ref:`http.api-update-interval <tcm_configuration_reference_http_api-update-interval>`
-   :ref:`http.frontend-dir <tcm_configuration_reference_http_frontend-dir>`
-   :ref:`http.show-stack-trace <tcm_configuration_reference_http_show-stack-trace>`
-   :ref:`http.trace <tcm_configuration_reference_http_trace>`
-   :ref:`http.max-static-size <tcm_configuration_reference_http_max-static-size>`
-   :ref:`http.graphql.complexity <tcm_configuration_reference_http_graphql_complexity>`


.. _tcm_configuration_reference_http_network:

.. confval:: http.network

    An addressing scheme that |tcm| uses.

    Possible values:

    -   ``tcp``: IPv4 address
    -   ``tcp6``: IPv6 address
    -   ``unix``: Unix domain socket

    |
    | Type: string
    | Default: tcp
    | Environment variable: TCM_HTTP_NETWORK
    | Command-line option: ``--http.network``

.. _tcm_configuration_reference_http_host:

.. confval:: http.host

    A host name on which |tcm| serves.

    |
    | Type: string
    | Default: 127.0.0.1
    | Environment variable: TCM_HTTP_HOST
    | Command-line option: ``--http.host``


.. _tcm_configuration_reference_http_port:

.. confval:: http.port

    A port on which |tcm| serves.

    |
    | Type: int
    | Default: 8080
    | Environment variable: TCM_HTTP_PORT
    | Command-line option: ``--http.port``


.. _tcm_configuration_reference_http_request-size:

.. confval:: http.request-size

    The maximum size (in bytes) of a client HTTP request to |tcm|.

    |
    | Type: int64
    | Default: 1572864
    | Environment variable: TCM_HTTP_REQUEST_SIZE
    | Command-line option: ``--http.request-size``

.. _tcm_configuration_reference_http_websocket_read-buffer-size:

.. confval:: http.websocket.read-buffer-size

    The size (in bytes) of the read buffer for `WebSocket <https://developer.mozilla.org/en-US/docs/Glossary/WebSockets>`__
    connections.

    |
    | Type: int
    | Default: 16384
    | Environment variable: TCM_HTTP_WEBSOCKET_READ_BUFFER_SIZE
    | Command-line option: ``--http.websocket.read-buffer-size``

.. _tcm_configuration_reference_http_websocket_write-buffer-size:

.. confval:: http.websocket.write-buffer-size

    The size (in bytes) of the write buffer for `WebSocket <https://developer.mozilla.org/en-US/docs/Glossary/WebSockets>`__
    connections.

    |
    | Type: int
    | Default: 16384
    | Environment variable: TCM_HTTP_WEBSOCKET_WRITE_BUFFER_SIZE
    | Command-line option: ``--http.websocket.write-buffer-size``

.. _tcm_configuration_reference_http_websocket_keepalive-ping-interval:

.. confval:: http.websocket.keepalive-ping-interval

    The time interval for sending `WebSocket <https://developer.mozilla.org/en-US/docs/Glossary/WebSockets>`__
    keepalive pings.

    |
    | Type: time.Duration
    | Default: 20s
    | Environment variable: TCM_HTTP_WEBSOCKET_KEEPALIVE_PING_INTERVAL
    | Command-line option: ``--http.websocket.keepalive-ping-interval``

.. _tcm_configuration_reference_http_websocket_handshake-timeout:

.. confval:: http.websocket.handshake-timeout

    The time limit for completing a `WebSocket <https://developer.mozilla.org/en-US/docs/Glossary/WebSockets>`__
    opening handshake with a client.

    |
    | Type: time.Duration
    | Default: 10s
    | Environment variable: TCM_HTTP_WEBSOCKET_HANDSHAKE_TIMEOUT
    | Command-line option: ``--http.websocket.handshake-timeout``

.. _tcm_configuration_reference_http_websocket_init-timeout:

.. confval:: http.websocket.init-timeout

    The time limit for establishing a `WebSocket <https://developer.mozilla.org/en-US/docs/Glossary/WebSockets>`__
    connection with a client.

    |
    | Type: time.Duration
    | Default: 15s
    | Environment variable: TCM_HTTP_WEBSOCKET_INIT_TIMEOUT
    | Command-line option: ``--http.websocket.init-timeout``

.. _tcm_configuration_reference_http_websession-cookie_name:

.. confval:: http.websession-cookie.name

    The name of the cookie that |tcm| sends to clients.

    This value is used as the cookie name in the `Set-Cookie <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie>`__
    HTTP response header.

    |
    | Type: string
    | Default: tcm
    | Environment variable: TCM_HTTP_WEBSESSION_COOKIE_NAME
    | Command-line option: ``---http.websession-cookie.name``

.. _tcm_configuration_reference_http_websession-cookie_path:

.. confval:: http.websession-cookie.path

    The URL path that must be present in the requested URL in order to send the cookie.

    This value is used in the ``Path`` attribute of the `Set-Cookie <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie>`__
    HTTP response header.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_HTTP_WEBSESSION_COOKIE_PATH
    | Command-line option: ``---http.websession-cookie.path``

.. _tcm_configuration_reference_http_websession-cookie_domain:

.. confval:: http.websession-cookie.domain

    The domain to which the cookie can be sent.

    This value is used in the ``Domain`` attribute of the `Set-Cookie <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie>`__
    HTTP response header.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_HTTP_WEBSESSION_COOKIE_DOMAIN
    | Command-line option: ``---http.websession-cookie.domain``

.. _tcm_configuration_reference_http_websession-cookie_ttl:

.. confval:: http.websession-cookie.ttl

    The maximum lifetime of the |tcm| cookie.

    This value is used in the ``Max-Age`` attribute of the `Set-Cookie <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie>`__
    HTTP response header.

    |
    | Type: time.Duration
    | Default: 2h0m0s
    | Environment variable: TCM_HTTP_WEBSESSION_COOKIE_TTL
    | Command-line option: ``---http.websession-cookie.ttl``

.. _tcm_configuration_reference_http_websession-cookie_secure:

.. confval:: http.websession-cookie.secure

    Indicates whether the cookie can be sent only over the HTTPS protocol.
    In this case, it's never sent over the unencrypted HTTP, therefore preventing
    man-in-the-middle attacks.

    When ``true``, the ``Secure`` attribute is added to the `Set-Cookie <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie>`__
    HTTP response header.

    |
    | Type: bool
    | Default: false
    | Environment variable: TCM_HTTP_WEBSESSION_COOKIE_SECURE
    | Command-line option: ``---http.websession-cookie.secure``

.. _tcm_configuration_reference_http_websession-cookie_http-only:

.. confval:: http.websession-cookie.http-only

    Indicates that the cookie can't be accessed from the JavaScript
    `Document.cookie <https://developer.mozilla.org/en-US/docs/Web/API/Document/cookie>`__ API.
    This helps mitigate cross-site scripting attacks.

    When ``true``, the ``HttpOnly`` attribute is added to the `Set-Cookie <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie>`__
    HTTP response header.

    |
    | Type: bool
    | Default: true
    | Environment variable: TCM_HTTP_WEBSESSION_COOKIE_HTTP_ONLY
    | Command-line option: ``---http.websession-cookie.http-only``

.. _tcm_configuration_reference_http_websession-cookie_same-site:

.. confval:: http.websession-cookie.same-site

    Indicates if it is possible to send the |tcm| cookie along with cross-site
    requests. Possible values are the Go's `http.SameSite <https://pkg.go.dev/net/http#SameSite>`__ constants:

    -   ``SameSiteDefaultMode``
    -   ``SameSiteLaxMode``
    -   ``SameSiteStrictMode``
    -   ``SameSiteNoneMode``

    For details on ``SameSite`` modes, see the `Set-Cookie header documentation <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie#samesitesamesite-value>`__
    in the MDN web docs.

    This value is used in the ``SameSite`` attribute of the `Set-Cookie <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie>`__
    HTTP response header.

    |
    | Type: http.SameSite
    | Default: SameSiteDefaultMode
    | Environment variable: TCM_HTTP_WEBSESSION_COOKIE_SAME_SITE
    | Command-line option: ``---http.websession-cookie.same-site``

.. _tcm_configuration_reference_http_cors_enabled:

.. confval:: http.cors.enabled

    Indicates whether to use the `Cross-Origin Resource Sharing <https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS>`__
    (*CORS*).

    |
    | Type: bool
    | Default: false
    | Environment variable: TCM_HTTP_CORS_ENABLED
    | Command-line option: ``--http.cors.enabled``

.. _tcm_configuration_reference_http_cors_allowed-origins:

.. confval:: http.cors.allowed-origins

    The `origins <https://developer.mozilla.org/en-US/docs/Glossary/Origin>`__
    with which the HTTP response can be shared, separated by semicolons.

    The specified values are sent in the `Access-Control-Allow-Origin <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin>`__
    HTTP response headers.

    |
    | Type: []string
    | Default: []
    | Environment variable: TCM_HTTP_CORS_ALLOWED_ORIGINS
    | Command-line option: ``--http.cors.allowed-origins``

.. _tcm_configuration_reference_http_cors_allowed-methods:

.. confval:: http.cors.allowed-methods

    HTTP request methods that are allowed when accessing a resource,
    separated by semicolons.

    The specified values are sent in the `Access-Control-Allow-Methods <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Methods>`__
    HTTP header of a response to a `CORS preflight request <https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request>`__.

    |
    | Type: []string
    | Default: []
    | Environment variable: TCM_HTTP_CORS_ALLOWED_METHODS
    | Command-line option: ``--http.cors.allowed-methods``

.. _tcm_configuration_reference_http_cors_allowed-headers:

.. confval:: http.cors.allowed-headers

    HTTP headers that are allowed during the actual request, separated by semicolons.

    The specified values are sent in the `Access-Control-Allow-Headers <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Headers>`__
    HTTP header of a response to a `CORS preflight request <https://developer.mozilla.org/en-US/docs/Glossary/Preflight_request>`__.

    |
    | Type: []string
    | Default: []
    | Environment variable: TCM_HTTP_CORS_ALLOWED_HEADERS
    | Command-line option: ``--http.cors.allowed-headers``

.. _tcm_configuration_reference_http_cors_exposed-headers:

.. confval:: http.cors.exposed-headers

    Response headers that should be made available to scripts running in the browser,
    in response to a cross-origin request, separated by semicolons.

    The specified values are sent in the `Access-Control-Expose-Headers <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Expose-Headers>`__
    HTTP response headers.

    |
    | Type: []string
    | Default: []
    | Environment variable: TCM_HTTP_CORS_EXPOSED_HEADERS
    | Command-line option: ``--http.cors.exposed-headers``

.. _tcm_configuration_reference_http_cors_allow-credentials:

.. confval:: http.cors.allow-credentials

    Whether to expose the response to the frontend JavaScript code when the `request's
    credentials <https://developer.mozilla.org/en-US/docs/Web/API/Request/credentials>`__
    mode is ``include``.

    When ``true``, the `Access-Control-Allow-Credentials <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Credentials>`__
    HTTP response header is sent.

    |
    | Type: bool
    | Default: false
    | Environment variable: TCM_HTTP_CORS_ALLOW_CREDENTIALS
    | Command-line option: ``--http.cors.allow-credentials``

.. _tcm_configuration_reference_http_cors_debug:

.. confval:: http.cors.debug

    For debug purposes.

    |
    | Type: bool
    | Default: false

.. _tcm_configuration_reference_http_tls_enabled:

.. confval:: http.tls.enabled

    Indicates whether TLS is enabled for client connections to |tcm|.

    |
    | Type: bool
    | Default: false
    | Environment variable: TCM_HTTP_TLS_ENABLED
    | Command-line option: ``--http.tls.enabled``

.. _tcm_configuration_reference_http_tls_cert-file:

.. confval:: http.tls.cert-file

    A path to a TLS certificate file. Mandatory when TLS is enabled.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_HTTP_TLS_CERT_FILE
    | Command-line option: ``--http.tls.cert-file``

.. _tcm_configuration_reference_http_tls_key-file:

.. confval:: http.tls.key-file

    A path to a TLS private key file. Mandatory when TLS is enabled.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_HTTP_TLS_KEY_FILE
    | Command-line option: ``--http.tls.key-file``

.. _tcm_configuration_reference_http_tls_server:

.. confval:: http.tls.server

    The TLS server.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_HTTP_TLS_SERVER
    | Command-line option: ``--http.tls.server``

.. _tcm_configuration_reference_http_tls_min-version:

.. confval:: http.tls.min-version

    The minimum version of the TLS protocol.

    |
    | Type: uint16
    | Default: 0
    | Environment variable: TCM_HTTP_TLS_MIN_VERSION
    | Command-line option: ``--http.tls.min-version``

.. _tcm_configuration_reference_http_tls_max-version:

.. confval:: http.tls.max-version

    The maximum version of the TLS protocol.

    |
    | Type: uint16
    | Default: 0
    | Environment variable: TCM_HTTP_TLS_MAX_VERSION
    | Command-line option: ``--http.tls.max-version``

.. _tcm_configuration_reference_http_tls_curve-preferences:

.. confval:: http.tls.curve-preferences

    Elliptic curves that are used for TLS connections.
    Possible values are the Go's `tls.CurveID <https://pkg.go.dev/crypto/tls#CurveID>`__ constants:

    -   ``CurveP256``
    -   ``CurveP384``
    -   ``CurveP521``
    -   ``X25519``

    |
    | Type: []tls.CurveID
    | Default: []
    | Environment variable: TCM_HTTP_TLS_CURVE_PREFERENCES
    | Command-line option: ``--http.tls.curve-preferences``

.. _tcm_configuration_reference_http_tls_cipher-suites:

.. confval:: http.tls.cipher-suites

    Enabled TLS cipher suites. Possible values are the Golang `tls.TLS_* <https://pkg.go.dev/crypto/tls#pkg-constants>`__ constants.

    |
    | Type: []uint16
    | Default: []
    | Environment variable: TCM_HTTP_TLS_CIPHER_SUITES
    | Command-line option: ``--http.tls.cipher-suites``

.. _tcm_configuration_reference_http_read-timeout:

.. confval:: http.read-timeout

    A timeout for reading an incoming request.

    |
    | Type: time.Duration
    | Default: 30s
    | Environment variable: TCM_HTTP_READ_TIMEOUT
    | Command-line option: ``--http.read-timeout``

.. _tcm_configuration_reference_http_read-header-timeout:

.. confval:: http.read-header-timeout

    A timeout for reading headers of an incoming request.

    |
    | Type: time.Duration
    | Default: 30s
    | Environment variable: TCM_HTTP_READ_HEADER_TIMEOUT
    | Command-line option: ``--http.read-header-timeout``

.. _tcm_configuration_reference_http_write-timeout:

.. confval:: http.write-timeout

    A timeout for writing a response.

    |
    | Type: time.Duration
    | Default: 30s
    | Environment variable: TCM_HTTP_WRITE_TIMEOUT
    | Command-line option: ``--http.write-timeout``

.. _tcm_configuration_reference_http_idle-timeout:

.. confval:: http.idle-timeout

    The timeout for idle connections.

    |
    | Type: time.Duration
    | Default: 30s
    | Environment variable: TCM_HTTP_IDLE_TIMEOUT
    | Command-line option: ``--http.idle-timeout``

.. _tcm_configuration_reference_http_disable-general-options-handler:

.. confval:: http.disable-general-options-handler

    Whether the client requests with the ``OPTIONS`` HTTP method are allowed.

    |
    | Type: bool
    | Default: false
    | Environment variable: TCM_HTTP_DISABLE_GENERAL_OPTIONS_HANDLER
    | Command-line option: ``--http.disable-general-options-handler``

.. _tcm_configuration_reference_http_max-header-bytes:

.. confval:: http.max-header-bytes

    The maximum size (in bytes) of a header in a client's request to |TCM|.

    |
    | Type: int
    | Default: 0
    | Environment variable: TCM_HTTP_MAX_HEADER_BYTES
    | Command-line option: ``--http.max-header-bytes``

.. _tcm_configuration_reference_http_api-timeout:

.. confval:: http.api-timeout

    The stateboard update timeout.

    |
    | Type: time.Duration
    | Default: 8s
    | Environment variable: TCM_HTTP_API_TIMEOUT
    | Command-line option: ``--http.api-timeout``

.. _tcm_configuration_reference_http_api-update-interval:

.. confval:: http.api-update-interval

    The stateboard update interval.

    |
    | Type: time.Duration
    | Default: 5s
    | Environment variable: TCM_HTTP_API_UPDATE_INTERVAL
    | Command-line option: ``--http.api-update-interval``

.. _tcm_configuration_reference_http_frontend-dir:

.. confval:: http.frontend-dir

    The directory with custom |tcm| frontend files (for development purposes).

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_HTTP_FRONTEND_DIR
    | Command-line option: ``--http.frontend-dir``

.. _tcm_configuration_reference_http_show-stack-trace:

.. confval:: http.show-stack-trace

    Whether error stack traces are shown in the web UI.

    |
    | Type: bool
    | Default: true
    | Environment variable: TCM_HTTP_SHOW_STACK_TRACE
    | Command-line option: ``--http.show-stack-trace``

.. _tcm_configuration_reference_http_trace:

.. confval:: http.trace

    Whether all query tracing information is written in logs.

    |
    | Type: bool
    | Default: false
    | Environment variable: TCM_HTTP_TRACE
    | Command-line option: ``--http.trace``

.. _tcm_configuration_reference_http_max-static-size:

.. confval:: http.max-static-size

    The maximum size (in bytes) of a static content sent to |TCM|.

    |
    | Type: int
    | Default: 104857600
    | Environment variable: TCM_HTTP_MAX_STATIC_SIZE
    | Command-line option: ``--http.max-static-size``

.. _tcm_configuration_reference_http_graphql_complexity:

.. confval:: http.graphql.complexity

    The maximum `complexity <https://typegraphql.com/docs/complexity.html>`__ of
    GraphQL queries that |tcm| processes. If this value is exceeded, |tcm|
    returns an error.

    |
    | Type: int
    | Default: 40
    | Environment variable: TCM_HTTP_GRAPHQL_COMPLEXITY
    | Command-line option: ``--http.graphql.complexity``


.. log configuration

.. _tcm_configuration_reference_log:

log
---

The ``log`` section defines the |tcm|  logging parameters.

-   :ref:`log.default.add-source <tcm_configuration_reference_log_default_add-source>`
-   :ref:`log.default.show-stack-trace <tcm_configuration_reference_log_default_show-stack-trace>`
-   :ref:`log.default.level <tcm_configuration_reference_log_default_level>`
-   :ref:`log.default.format <tcm_configuration_reference_log_default_format>`
-   :ref:`log.default.output <tcm_configuration_reference_log_default_output>`
-   :ref:`log.default.no-colorized <tcm_configuration_reference_log_default_no-colorized>`
-   :ref:`log.default.file.name <tcm_configuration_reference_log_default_file_name>`
-   :ref:`log.default.file.maxsize <tcm_configuration_reference_log_default_file_maxsize>`
-   :ref:`log.default.file.maxage <tcm_configuration_reference_log_default_file_maxage>`
-   :ref:`log.default.file.maxbackups <tcm_configuration_reference_log_default_file_maxbackups>`
-   :ref:`log.default.file.compress <tcm_configuration_reference_log_default_file_compress>`
-   :ref:`log.default.syslog.protocol <tcm_configuration_reference_log_default_syslog_protocol>`
-   :ref:`log.default.syslog.output <tcm_configuration_reference_log_default_syslog_output>`
-   :ref:`log.default.syslog.priority <tcm_configuration_reference_log_default_syslog_priority>`
-   :ref:`log.default.syslog.facility <tcm_configuration_reference_log_default_syslog_facility>`
-   :ref:`log.default.syslog.tag <tcm_configuration_reference_log_default_syslog_tag>`
-   :ref:`log.default.syslog.timeout <tcm_configuration_reference_log_default_syslog_timeout>`
-   :ref:`log.outputs <tcm_configuration_reference_log_outputs>`

.. _tcm_configuration_reference_log_default_add-source:

.. confval:: log.default.add-source

    Whether sources are added to the |tcm| log.

    |
    | Type: bool
    | Default: false
    | Environment variable: TCM_LOG_DEFAULT_ADD_SOURCE
    | Command-line option: ``--log.default.add-source``

.. _tcm_configuration_reference_log_default_show-stack-trace:

.. confval:: log.default.show-stack-trace

    Whether stack traces are added to the |tcm| log.

    |
    | Type: bool
    | Default: false
    | Environment variable: TCM_LOG_DEFAULT_SHOW_STACK_TRACE
    | Command-line option: ``--log.default.show-stack-trace``

.. _tcm_configuration_reference_log_default_level:

.. confval:: log.default.level

    The default |tcm| logging level.

    Possible values:

    *   ``VERBOSE``
    *   ``INFO``
    *   ``WARN``
    *   ``ALARM``

    |
    | Type: string
    | Default: INFO
    | Environment variable: TCM_LOG_DEFAULT_LEVEL
    | Command-line option: ``--log.default.level``

.. _tcm_configuration_reference_log_default_format:

.. confval:: log.default.format

    |tcm| log entries format.

    Possible values:

    *   ``struct``
    *   ``json``

    |
    | Type: string
    | Default: struct
    | Environment variable: TCM_LOG_DEFAULT_FORMAT
    | Command-line option: ``--log.default.format``

.. _tcm_configuration_reference_log_default_output:

.. confval:: log.default.output

    The output used for |tcm| log.

    Possible values:

    *   ``stdout``
    *   ``stderr``
    *   ``file``
    *   ``syslog``

    |
    | Type: string
    | Default: stdout
    | Environment variable: TCM_LOG_DEFAULT_OUTPUT
    | Command-line option: ``--log.default.output``

.. _tcm_configuration_reference_log_default_no-colorized:

.. confval:: log.default.no-colorized

    Whether the stdout log is not colorized.

    |
    | Type: bool
    | Default: false
    | Environment variable: TCM_LOG_DEFAULT_NO_COLORIZED
    | Command-line option: ``--log.default.no-colorized``

.. _tcm_configuration_reference_log_default_file_name:

.. confval:: log.default.file.name

    The name of the |tcm| log file.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_LOG_DEFAULT_FILE_NAME
    | Command-line option: ``--log.default.file.name``

.. _tcm_configuration_reference_log_default_file_maxsize:

.. confval:: log.default.file.maxsize

    The maximum size (in bytes) of the |tcm| log file.

    |
    | Type: int
    | Default: 0
    | Environment variable: TCM_LOG_DEFAULT_FILE_MAXSIZE
    | Command-line option: ``--log.default.file.maxsize``

.. _tcm_configuration_reference_log_default_file_maxage:

.. confval:: log.default.file.maxage

    The maximum age of a |tcm| log file, in days.

    |
    | Type: int
    | Default: 0
    | Environment variable: TCM_LOG_DEFAULT_FILE_MAXAGE
    | Command-line option: ``--log.default.file.maxage``

.. _tcm_configuration_reference_log_default_file_maxbackups:

.. confval:: log.default.file.maxbackups

    The maximum number of users in |tcm|.

    |
    | Type: int
    | Default: 0
    | Environment variable: TCM_LOG_DEFAULT_FILE_MAXBACKUPS
    | Command-line option: ``--log.default.file.maxbackups``

.. _tcm_configuration_reference_log_default_file_compress:

.. confval:: log.default.file.compress

    Indicated that |tcm| compresses log files upon rotation.

    |
    | Type: bool
    | Default: false
    | Environment variable: TCM_LOG_DEFAULT_FILE_COMPRESS
    | Command-line option: ``--log.default.file.compress``

.. _tcm_configuration_reference_log_default_syslog_protocol:

.. confval:: log.default.syslog.protocol

    The network protocol used for connecting to the syslog server. Typically,
    it's ``tcp``, ``udp``, or ``unix``. All possible values are listed in the Go's
    `net.Dial <https://pkg.go.dev/net#Dial>`__ documentation.

    |
    | Type: string
    | Default: tcp
    | Environment variable: TCM_LOG_DEFAULT_SYSLOG_PROTOCOL
    | Command-line option: ``--log.default.syslog.protocol``

.. _tcm_configuration_reference_log_default_syslog_output:

.. confval:: log.default.syslog.output

    The syslog server URI.

    |
    | Type: string
    | Default: 127.0.0.1:5514
    | Environment variable: TCM_LOG_DEFAULT_SYSLOG_OUTPUT
    | Command-line option: ``--log.default.syslog.output``

.. _tcm_configuration_reference_log_default_syslog_priority:

.. confval:: log.default.syslog.priority

    The syslog severity level.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_LOG_DEFAULT_SYSLOG_PRIORITY
    | Command-line option: ``--log.default.syslog.priority``

.. _tcm_configuration_reference_log_default_syslog_facility:

.. confval:: log.default.syslog.facility

    The syslog facility.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_LOG_DEFAULT_SYSLOG_FACILITY
    | Command-line option: ``--log.default.syslog.facility``

.. _tcm_configuration_reference_log_default_syslog_tag:

.. confval:: log.default.syslog.tag

    The syslog tag.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_LOG_DEFAULT_SYSLOG_TAG
    | Command-line option: ``--log.default.syslog.tag``

.. _tcm_configuration_reference_log_default_syslog_timeout:

.. confval:: log.default.syslog.timeout

    The timeout for connecting to the syslog server.

    |
    | Type: time.Duration
    | Default: 10s
    | Environment variable: TCM_LOG_DEFAULT_SYSLOG_TIMEOUT
    | Command-line option: ``--log.default.syslog.timeout``

.. _tcm_configuration_reference_log_outputs:

.. confval:: log.outputs

    An array of log outputs that |tcm| uses **in addition** to the default one
    that is defined by the ``log.default.*`` parameters. Each array item can include
    the parameters of the ``log.default`` group. If a parameter is skipped, its
    value is taken from ``log.default``.

    |
    | Type: []LogOuputConfig
    | Default: []
    | Environment variable: TCM_LOG_OUTPUTS
    | Command-line option: ``--log-outputs``


.. storage configuration

.. _tcm_configuration_reference_storage:

storage
-------

The ``storage`` section defines the parameters of the |tcm| :ref:`backend store <tcm_backend_store>`.

-   :ref:`storage.provider <tcm_configuration_reference_storage_provider>`

etcd backend store parameters:

-   :ref:`storage.etcd.prefix <tcm_configuration_reference_storage_etcd_prefix>`
-   :ref:`storage.etcd.endpoints <tcm_configuration_reference_storage_etcd_endpoints>`
-   :ref:`storage.etcd.dial-timeout <tcm_configuration_reference_storage_etcd_dial-timeout>`
-   :ref:`storage.etcd.auto-sync-interval <tcm_configuration_reference_storage_etcd_auto-sync-interval>`
-   :ref:`storage.etcd.dial-keep-alive-time <tcm_configuration_reference_storage_etcd_dial-keep-alive-time>`
-   :ref:`storage.etcd.dial-keep-alive-timeout <tcm_configuration_reference_storage_etcd_dial-keep-alive-timeout>`
-   :ref:`storage.etcd.bootstrap-timeout <tcm_configuration_reference_storage_etcd_bootstrap-timeout>`
-   :ref:`storage.etcd.max-call-send-msg-size <tcm_configuration_reference_storage_etcd_max-call-send-msg-size>`
-   :ref:`storage.etcd.username <tcm_configuration_reference_storage_etcd_username>`
-   :ref:`storage.etcd.password <tcm_configuration_reference_storage_etcd_password>`
-   :ref:`storage.etcd.password-file <tcm_configuration_reference_storage_etcd_password-file>`
-   :ref:`storage.etcd.tls.enabled <tcm_configuration_reference_storage_etcd_tls_enabled>`
-   :ref:`storage.etcd.tls.auto <tcm_configuration_reference_storage_etcd_tls_auto>`
-   :ref:`storage.etcd.tls.cert-file <tcm_configuration_reference_storage_etcd_tls_cert-file>`
-   :ref:`storage.etcd.tls.key-file <tcm_configuration_reference_storage_etcd_tls_key-file>`
-   :ref:`storage.etcd.tls.trusted-ca-file <tcm_configuration_reference_storage_etcd_tls_trusted-ca-file>`
-   :ref:`storage.etcd.tls.client-cert-auth <tcm_configuration_reference_storage_etcd_tls_client-cert-auth>`
-   :ref:`storage.etcd.tls.crl-file <tcm_configuration_reference_storage_etcd_tls_crl-file>`
-   :ref:`storage.etcd.tls.insecure-skip-verify <tcm_configuration_reference_storage_etcd_tls_insecure-skip-verify>`
-   :ref:`storage.etcd.tls.skip-client-san-verify <tcm_configuration_reference_storage_etcd_tls_skip-client-san-verify>`
-   :ref:`storage.etcd.tls.server-name <tcm_configuration_reference_storage_etcd_tls_server-name>`
-   :ref:`storage.etcd.tls.cipher-suites <tcm_configuration_reference_storage_etcd_tls_cipher-suites>`
-   :ref:`storage.etcd.tls.allowed-cn <tcm_configuration_reference_storage_etcd_tls_allowed-cn>`
-   :ref:`storage.etcd.tls.allowed-hostname <tcm_configuration_reference_storage_etcd_tls_allowed-hostname>`
-   :ref:`storage.etcd.tls.empty-cn <tcm_configuration_reference_storage_etcd_tls_empty-cn>`
-   :ref:`storage.etcd.permit-without-stream <tcm_configuration_reference_storage_etcd_permit-without-stream>`
-   :ref:`storage.etcd.embed.enabled <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.endpoints <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.advertises <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.tls.enabled <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.tls.auto <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.tls.cert-file <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.tls.key-file <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.tls.trusted-ca-file <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.tls.client-cert-auth <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.tls.crl-file <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.tls.insecure-skip-verify <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.tls.skip-client-san-verify <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.tls.server-name <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.tls.cipher-suites <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.tls.allowed-cn <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.tls.allowed-hostname <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.tls.empty-cn <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.peer-endpoints <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.peer-advertises <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.peer-tls.enabled <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.peer-tls.auto <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.peer-tls.cert-file <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.peer-tls.key-file <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.peer-tls.trusted-ca-file <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.peer-tls.client-cert-auth <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.peer-tls.crl-file <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.peer-tls.insecure-skip-verify <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.peer-tls.skip-client-san-verify <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.peer-tls.server-name <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.peer-tls.cipher-suites <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.peer-tls.allowed-cn <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.peer-tls.allowed-hostname <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.peer-tls.empty-cn <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.grpc-keep-alive-timeout <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.grpc-keep-alive-interval <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.grpc-keep-alive-min-time <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.workdir <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.waldir <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.max-request-bytes <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.debug <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.start-timeout <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.log-level <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.initial-cluster <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.initial-cluster-token <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.name <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.initial-cluster-state <tcm_configuration_reference_storage_etcd_embed>`
-   :ref:`storage.etcd.embed.self-signed-cert-validity <tcm_configuration_reference_storage_etcd_embed>`

Tarantool backend store parameters:

-   :ref:`storage.tarantool.prefix <tcm_configuration_reference_storage_tarantool_prefix>`
-   :ref:`storage.tarantool.addr <tcm_configuration_reference_storage_tarantool_addr>`
-   :ref:`storage.tarantool.addrs <tcm_configuration_reference_storage_tarantool_addrs>`
-   :ref:`storage.tarantool.auth <tcm_configuration_reference_storage_tarantool_auth>`
-   :ref:`storage.tarantool.timeout <tcm_configuration_reference_storage_tarantool_timeout>`
-   :ref:`storage.tarantool.reconnect <tcm_configuration_reference_storage_tarantool_reconnect>`
-   :ref:`storage.tarantool.max-reconnects <tcm_configuration_reference_storage_tarantool_max-reconnects>`
-   :ref:`storage.tarantool.username <tcm_configuration_reference_storage_tarantool_username>`
-   :ref:`storage.tarantool.password <tcm_configuration_reference_storage_tarantool_password>`
-   :ref:`storage.tarantool.password-file <tcm_configuration_reference_storage_tarantool_password-file>`
-   :ref:`storage.tarantool.rate-limit <tcm_configuration_reference_storage_tarantool_rate-limit>`
-   :ref:`storage.tarantool.rate-limit-action <tcm_configuration_reference_storage_tarantool_rate-limit-action>`
-   :ref:`storage.tarantool.concurrency <tcm_configuration_reference_storage_tarantool_concurrency>`
-   :ref:`storage.tarantool.skip-schema <tcm_configuration_reference_storage_tarantool_skip-schema>`
-   :ref:`storage.tarantool.transport <tcm_configuration_reference_storage_tarantool_transport>`
-   :ref:`storage.tarantool.ssl.key-file <tcm_configuration_reference_storage_tarantool_ssl_key-file>`
-   :ref:`storage.tarantool.ssl.cert-file <tcm_configuration_reference_storage_tarantool_ssl_cert-file>`
-   :ref:`storage.tarantool.ssl.ca-file <tcm_configuration_reference_storage_tarantool_ssl_ca-file>`
-   :ref:`storage.tarantool.ssl.ciphers <tcm_configuration_reference_storage_tarantool_ssl_ciphers>`
-   :ref:`storage.tarantool.ssl.password <tcm_configuration_reference_storage_tarantool_ssl_password>`
-   :ref:`storage.tarantool.ssl.password-file <tcm_configuration_reference_storage_tarantool_ssl_password-file>`
-   :ref:`storage.tarantool.required-protocol-info.auth <tcm_configuration_reference_storage_tarantool_required-protocol-info_auth>`
-   :ref:`storage.tarantool.required-protocol-info.version <tcm_configuration_reference_storage_tarantool_required-protocol-info_version>`
-   :ref:`storage.tarantool.required-protocol-info.features <tcm_configuration_reference_storage_tarantool_required-protocol-info_features>`
-   :ref:`storage.tarantool.embed.enabled <tcm_configuration_reference_storage_tarantool_embed>`
-   :ref:`storage.tarantool.embed.workdir <tcm_configuration_reference_storage_tarantool_embed>`
-   :ref:`storage.tarantool.embed.executable <tcm_configuration_reference_storage_tarantool_embed>`
-   :ref:`storage.tarantool.embed.config-filename <tcm_configuration_reference_storage_tarantool_embed>`
-   :ref:`storage.tarantool.embed.config <tcm_configuration_reference_storage_tarantool_embed>`
-   :ref:`storage.tarantool.embed.args <tcm_configuration_reference_storage_tarantool_embed>`
-   :ref:`storage.tarantool.embed.env <tcm_configuration_reference_storage_tarantool_embed>`


.. _tcm_configuration_reference_storage_provider:

.. confval:: storage.provider

    The type of the storage used for storing |tcm| configuration.

    Possible values:

    -   ``etcd``
    -   ``tarantool``

    |
    | Type: string
    | Default: etcd
    | Environment variable: TCM_STORAGE_PROVIDER
    | Command-line option: ``--storage.provider``

.. _tcm_configuration_reference_storage_etcd_prefix:

.. confval:: storage.etcd.prefix

    A prefix for the |tcm| configuration parameters in etcd.

    |
    | Type: string
    | Default: "/tcm"
    | Environment variable: TCM_STORAGE_ETCD_PREFIX
    | Command-line option: ``--storage.etcd.prefix``


.. _tcm_configuration_reference_storage_etcd_endpoints:

.. confval:: storage.etcd.endpoints

    An array of node URIs of the etcd cluster where the |tcm| configuration is stored,
    separated by semicolons (``;``).

    |
    | Type: []string
    | Default: ["http://127.0.0.1:2379"]
    | Environment variable: TCM_STORAGE_ETCD_ENDPOINTS
    | Command-line option: ``--storage.etcd.endpoints``


.. _tcm_configuration_reference_storage_etcd_dial-timeout:

.. confval:: storage.etcd.dial-timeout

    An etcd dial timeout.

    |
    | Type: time.Duration
    | Default: 10s
    | Environment variable: TCM_STORAGE_ETCD_DIAL_TIMEOUT
    | Command-line option: ``--storage.etcd.dial-timeout``

.. _tcm_configuration_reference_storage_etcd_auto-sync-interval:

.. confval:: storage.etcd.auto-sync-interval

    An automated sync interval.

    |
    | Type: time.Duration
    | Default: 0 (disabled)
    | Environment variable: TCM_STORAGE_ETCD_AUTO_SYNC_INTERVAL
    | Command-line option: ``--storage.etcd.auto-sync-interval``

.. _tcm_configuration_reference_storage_etcd_dial-keep-alive-time:

.. confval:: storage.etcd.dial-keep-alive-time

    A dial keep-alive time.

    |
    | Type: time.Duration
    | Default: 30s
    | Environment variable: TCM_STORAGE_ETCD_DIAL_KEEP_ALIVE_TIME
    | Command-line option: ``--storage.etcd.dial-keep-alive-time``

.. _tcm_configuration_reference_storage_etcd_dial-keep-alive-timeout:

.. confval:: storage.etcd.dial-keep-alive-timeout

    A dial keep-alive timeout.

    |
    | Type: time.Duration
    | Default: 30s
    | Environment variable: TCM_STORAGE_ETCD_DIAL_KEEP_ALIVE_TIMEOUT
    | Command-line option: ``--storage.etcd.dial-keep-alive-timeout``

.. _tcm_configuration_reference_storage_etcd_bootstrap-timeout:

.. confval:: storage.etcd.bootstrap-timeout

    A bootstrap timeout.

    |
    | Type: time.Duration
    | Default: 30s
    | Environment variable: TCM_STORAGE_ETCD_BOOTSTRAP_TIMEOUT
    | Command-line option: ``--storage.etcd.bootstrap-timeout``

.. _tcm_configuration_reference_storage_etcd_max-call-send-msg-size:

.. confval:: storage.etcd.max-call-send-msg-size

    The maximum size (in bytes) of a transaction between |tcm| and etcd.

    |
    | Type: int
    | Default: 2097152
    | Environment variable: TCM_STORAGE_ETCD_MAX_CALL_SEND_MSG_SIZE
    | Command-line option: ``--storage.etcd.max-call-send-msg-size``

.. _tcm_configuration_reference_storage_etcd_username:

.. confval:: storage.etcd.username

    A username for accessing the etcd storage.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_STORAGE_ETCD_USERNAME
    | Command-line option: ``--storage.etcd.username``

.. _tcm_configuration_reference_storage_etcd_password:

.. confval:: storage.etcd.password

    A password for accessing the etcd storage.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_STORAGE_ETCD_PASSWORD
    | Command-line option: ``--storage.etcd.password``

.. _tcm_configuration_reference_storage_etcd_password-file:

.. confval:: storage.etcd.password-file

    A path to the file with a password for accessing the etcd storage.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_STORAGE_ETCD_PASSWORD_FILE
    | Command-line option: ``--storage.etcd.password-file``

.. _tcm_configuration_reference_storage_etcd_tls_enabled:

.. confval:: storage.etcd.tls.enabled

    Indicates whether TLS is enabled for etcd connections.

    |
    | Type: bool
    | Default: false
    | Environment variable: TCM_STORAGE_ETCD_TLS_ENABLED
    | Command-line option: ``--storage.etcd.tls.enabled``

.. _tcm_configuration_reference_storage_etcd_tls_auto:

.. confval:: storage.etcd.tls.auto

    Use generated certificates for etcd connections.

    |
    | Type: bool
    | Default: false
    | Environment variable: TCM_STORAGE_ETCD_TLS_AUTO
    | Command-line option: ``--storage.etcd.tls.auto``

.. _tcm_configuration_reference_storage_etcd_tls_cert-file:

.. confval:: storage.etcd.tls.cert-file

    A path to a TLS certificate file to use for etcd connections.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_STORAGE_ETCD_TLS_CERT_FILE
    | Command-line option: ``--storage.etcd.tls.cert-file``

.. _tcm_configuration_reference_storage_etcd_tls_key-file:

.. confval:: storage.etcd.tls.key-file

    A path to a TLS private key file to use for etcd connections.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_STORAGE_ETCD_TLS_KEY_FILE
    | Command-line option: ``--storage.etcd.tls.key-file``

.. _tcm_configuration_reference_storage_etcd_tls_trusted-ca-file:

.. confval:: storage.etcd.tls.trusted-ca-file

    A path to a trusted CA certificate file to use for etcd connections.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_STORAGE_ETCD_TLS_TRUSTED_CA_FILE
    | Command-line option: ``--storage.etcd.tls.trusted-ca-file``

.. _tcm_configuration_reference_storage_etcd_tls_client-cert-auth:

.. confval:: storage.etcd.tls.client-cert-auth

    Indicates whether client cert authentication is enabled.

    |
    | Type: bool
    | Default: false
    | Environment variable: TCM_STORAGE_ETCD_TLS_CLIENT_CERT_AUTH
    | Command-line option: ``--storage.etcd.tls.client-cert-auth``

.. _tcm_configuration_reference_storage_etcd_tls_crl-file:

.. confval:: storage.etcd.tls.crl-file

    A path to the client certificate revocation list file.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_STORAGE_ETCD_TLS_CRL_FILE
    | Command-line option: ``--storage.etcd.tls.crl-file``

.. _tcm_configuration_reference_storage_etcd_tls_insecure-skip-verify:

.. confval:: storage.etcd.tls.insecure-skip-verify

    Skip checking client certificate in etcd connections.

    |
    | Type: bool
    | Default: false
    | Environment variable: TCM_STORAGE_ETCD_TLS_INSECURE_SKIP_VERIFY
    | Command-line option: ``--storage.etcd.tls.insecure-skip-verify``

.. _tcm_configuration_reference_storage_etcd_tls_skip-client-san-verify:

.. confval:: storage.etcd.tls.skip-client-san-verify

    Skip verification of SAN field in client certificate for etcd connections.

    |
    | Type: bool
    | Default: false
    | Environment variable: TCM_STORAGE_ETCD_TLS_SKIP_CLIENT_SAN_VERIFY
    | Command-line option: ``--storage.etcd.tls.skip-client-san-verify``

.. _tcm_configuration_reference_storage_etcd_tls_server-name:

.. confval:: storage.etcd.tls.server-name

    Name of the TLS server for etcd connections.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_STORAGE_ETCD_TLS_SERVER_NAME
    | Command-line option: ``--storage.etcd.tls.server-name``

.. _tcm_configuration_reference_storage_etcd_tls_cipher-suites:

.. confval:: storage.etcd.tls.cipher-suites

    TLS cipher suites for etcd connections. Possible values are the Golang `tls.TLS_* <https://pkg.go.dev/crypto/tls#pkg-constants>`__ constants.

    |
    | Type: []uint16
    | Default: []
    | Environment variable: TCM_STORAGE_ETCD_TLS_CIPHER_SUITES
    | Command-line option: ``--storage.etcd.tls.cipher-suites``

.. _tcm_configuration_reference_storage_etcd_tls_allowed-cn:

.. confval:: storage.etcd.tls.allowed-cn

    An allowed common name for authentication in etcd connections.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_STORAGE_ETCD_TLS_ALLOWED_CN
    | Command-line option: ``--storage.etcd.tls.allowed-cn``

.. _tcm_configuration_reference_storage_etcd_tls_allowed-hostname:

.. confval:: storage.etcd.tls.allowed-hostname

    An allowed TLS certificate name for authentication in etcd connections.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_STORAGE_ETCD_TLS_ALLOWED_HOSTNAME
    | Command-line option: ``--storage.etcd.tls.allowed-hostname``

.. _tcm_configuration_reference_storage_etcd_tls_empty-cn:

.. confval:: storage.etcd.tls.empty-cn

    Whether the empty common name is allowed in etcd connections.

    |
    | Type: bool
    | Default: false
    | Environment variable: TCM_STORAGE_ETCD_TLS_EMPTY_CN
    | Command-line option: ``--storage.etcd.tls.empty-cn``

.. _tcm_configuration_reference_storage_etcd_permit-without-stream:

.. confval:: storage.etcd.permit-without-stream

    Whether keepalive pings can be send to the etcd server without active streams.

    |
    | Type: bool
    | Default: false
    | Environment variable: TCM_STORAGE_ETCD_PERMIT_WITHOUT_STREAM
    | Command-line option: ``--storage.etcd.permit-without-stream``

.. _tcm_configuration_reference_storage_etcd_embed:

storage.etcd.embed.*
~~~~~~~~~~~~~~~~~~~~

The ``storage.etcd.embed`` group defines the configuration of the embedded etcd
cluster to use as a |tcm| backend store.
This cluster can be used for development purposes when the production or testing
etcd cluster is not available or not needed.

See also :ref:`tcm_backend_store_embed`.

.. _tcm_configuration_reference_storage_tarantool_prefix:

.. confval:: storage.tarantool.prefix

    A prefix for the |tcm| configuration parameters in the Tarantool-based configuration storage.

    |
    | Type: string
    | Default: "/tcm"
    | Environment variable: TCM_STORAGE_TARANTOOL_PREFIX
    | Command-line option: ``--storage.tarantool.prefix``


.. _tcm_configuration_reference_storage_tarantool_addr:

.. confval:: storage.tarantool.addr

    The URI for connecting to the Tarantool-based configuration storage.

    |
    | Type: string
    | Default: "unix/:/tmp/tnt_config_instance.sock"
    | Environment variable: TCM_STORAGE_TARANTOOL_ADDR
    | Command-line option: ``--storage.tarantool.addr``

.. _tcm_configuration_reference_storage_tarantool_addrs:

.. confval:: storage.tarantool.addrs

    An array of the Tarantool-based configuration storage URIs.

    |
    | Type: []string
    | Default: ["unix/:/tmp/tnt_config_instance.sock"]
    | Environment variable: TCM_STORAGE_TARANTOOL_ADDRS
    | Command-line option: ``--storage.tarantool.addrs``


.. _tcm_configuration_reference_storage_tarantool_auth:

.. confval:: storage.tarantool.auth

    An authentication method for the Tarantool-based configuration storage.

    Possible values are the Go's `go-tarantool/Auth <https://pkg.go.dev/github.com/tarantool/go-tarantool#Auth>`__ constants:

    -   ``AutoAuth`` (0)
    -   ``ChapSha1Auth``
    -   ``PapSha256Auth``

    |
    | Type: int
    | Default: 0
    | Environment variable: TCM_STORAGE_TARANTOOL_AUTH
    | Command-line option: ``--storage.tarantool.auth``


.. _tcm_configuration_reference_storage_tarantool_timeout:

.. confval:: storage.tarantool.timeout

    A request timeout for the Tarantool-based configuration storage.

    See also `go-tarantool.Opts <https://pkg.go.dev/github.com/tarantool/go-tarantool#Opts>`__.

    |
    | Type: time.Duration
    | Default: 0s
    | Environment variable: TCM_STORAGE_TARANTOOL_TIMEOUT
    | Command-line option: ``--storage.tarantool.timeout``

.. _tcm_configuration_reference_storage_tarantool_reconnect:

.. confval:: storage.tarantool.reconnect

    A timeout between reconnect attempts for the Tarantool-based configuration storage.

    See also `go-tarantool.Opts <https://pkg.go.dev/github.com/tarantool/go-tarantool#Opts>`__.

    |
    | Type: time.Duration
    | Default: 0s
    | Environment variable: TCM_STORAGE_TARANTOOL_RECONNECT
    | Command-line option: ``--storage.tarantool.reconnect``

.. _tcm_configuration_reference_storage_tarantool_max-reconnects:

.. confval:: storage.tarantool.max-reconnects

    The maximum number of reconnect attempts for the Tarantool-based configuration storage.

    See also `go-tarantool.Opts <https://pkg.go.dev/github.com/tarantool/go-tarantool#Opts>`__.

    |
    | Type: int
    | Default: 0
    | Environment variable: TCM_STORAGE_TARANTOOL_MAX_RECONNECTS
    | Command-line option: ``--storage.tarantool.max-reconnects``

.. _tcm_configuration_reference_storage_tarantool_user:
.. _tcm_configuration_reference_storage_tarantool_username:

.. confval:: storage.tarantool.username

    A username for connecting to the Tarantool-based configuration storage.

    See also `go-tarantool.Opts <https://pkg.go.dev/github.com/tarantool/go-tarantool#Opts>`__.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_STORAGE_TARANTOOL_USERNAME
    | Command-line option: ``--storage.tarantool.username``

.. _tcm_configuration_reference_storage_tarantool_pass:
.. _tcm_configuration_reference_storage_tarantool_password:

.. confval:: storage.tarantool.password

    A password for connecting to the Tarantool-based configuration storage.

    See also `go-tarantool.Opts <https://pkg.go.dev/github.com/tarantool/go-tarantool#Opts>`__.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_STORAGE_TARANTOOL_PASSWORD
    | Command-line option: ``--storage.tarantool.password``

.. _tcm_configuration_reference_storage_tarantool_password-file:

.. confval:: storage.tarantool.password-file

    A path to the file with a password for connecting to the Tarantool-based configuration storage.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_STORAGE_TARANTOOL_PASSWORD_FILE
    | Command-line option: ``--storage.tarantool.password-file``

.. _tcm_configuration_reference_storage_tarantool_rate-limit:

.. confval:: storage.tarantool.rate-limit

    A rate limit for connecting to the Tarantool-based configuration storage.

    See also `go-tarantool.Opts <https://pkg.go.dev/github.com/tarantool/go-tarantool#Opts>`__.

    |
    | Type: int
    | Default: 0
    | Environment variable: TCM_STORAGE_TARANTOOL_RATE_LIMIT
    | Command-line option: ``--storage.tarantool.rate-limit``

.. _tcm_configuration_reference_storage_tarantool_rate-limit-action:

.. confval:: storage.tarantool.rate-limit-action

    An action to perform when the :ref:`storage.tarantool.rate-limit <tcm_configuration_reference_storage_tarantool_rate-limit>` is reached.

    See also `go-tarantool.Opts <https://pkg.go.dev/github.com/tarantool/go-tarantool#Opts>`__.

    |
    | Type: int
    | Default: 0
    | Environment variable: TCM_STORAGE_TARANTOOL_RATE_LIMIT_ACTION
    | Command-line option: ``--storage.tarantool.rate-limit-action``


.. _tcm_configuration_reference_storage_tarantool_concurrency:

.. confval:: storage.tarantool.concurrency

    An amount of separate mutexes for request queues and buffers inside of a connection
    to the Tarantool |tcm| configuration storage.

    See also `go-tarantool.Opts <https://pkg.go.dev/github.com/tarantool/go-tarantool#Opts>`__.

    |
    | Type: int
    | Default: 0
    | Environment variable: TCM_STORAGE_TARANTOOL_CONCURRENCY
    | Command-line option: ``--storage.tarantool.concurrency``

.. _tcm_configuration_reference_storage_tarantool_skip-schema:

.. confval:: storage.tarantool.skip-schema

    Whether the schema is loaded from the Tarantool |tcm| configuration storage.

    See also `go-tarantool.Opts <https://pkg.go.dev/github.com/tarantool/go-tarantool#Opts>`__.

    |
    | Type: bool
    | Default: true
    | Environment variable: TCM_STORAGE_TARANTOOL_SKIP_SCHEMA
    | Command-line option: ``--storage.tarantool.skip-schema``

.. _tcm_configuration_reference_storage_tarantool_transport:

.. confval:: storage.tarantool.transport

    The connection type for the Tarantool |tcm| configuration storage.

    See also `go-tarantool.Opts <https://pkg.go.dev/github.com/tarantool/go-tarantool#Opts>`__.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_STORAGE_TARANTOOL_TRANSPORT
    | Command-line option: ``--storage.tarantool.transport``

.. _tcm_configuration_reference_storage_tarantool_ssl_key-file:

.. confval:: storage.tarantool.ssl.key-file

    A path to a TLS private key file to use for connecting to the Tarantool |tcm|
    configuration storage.

    See also: :ref:`configuration_connections_ssl`.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_STORAGE_TARANTOOL_SSL_KEY_FILE
    | Command-line option: ``--storage.tarantool.ssl.key-file``

.. _tcm_configuration_reference_storage_tarantool_ssl_cert-file:

.. confval:: storage.tarantool.ssl.cert-file

    A path to an SSL certificate to use for connecting to the Tarantool |tcm|
    configuration storage.

    See also: :ref:`configuration_connections_ssl`.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_STORAGE_TARANTOOL_SSL_CERT_FILE
    | Command-line option: ``--storage.tarantool.ssl.cert-file``

.. _tcm_configuration_reference_storage_tarantool_ssl_ca-file:

.. confval:: storage.tarantool.ssl.ca-file

    A path to a trusted CA certificate to use for connecting to the Tarantool |tcm|
    configuration storage.

    See also: :ref:`configuration_connections_ssl`.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_STORAGE_TARANTOOL_SSL_CA_FILE
    | Command-line option: ``--storage.tarantool.ssl.ca-file``

.. _tcm_configuration_reference_storage_tarantool_ssl_ciphers:

.. confval:: storage.tarantool.ssl.ciphers

    A list of SSL cipher suites that can be used for connecting to the Tarantool |tcm|
    configuration storage. Possible values are listed in :ref:`<uri>.params.ssl_ciphers <configuration_reference_iproto_uri_params_ssl_ciphers>`.

    See also: :ref:`configuration_connections_ssl`.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_STORAGE_TARANTOOL_SSL_CIPHERS
    | Command-line option: ``--storage.tarantool.ssl.ciphers``

.. _tcm_configuration_reference_storage_tarantool_ssl_password:

.. confval:: storage.tarantool.ssl.password

    A password for an encrypted private SSL key to use for connecting to the Tarantool |tcm|
    configuration storage.

    See also: :ref:`configuration_connections_ssl`.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_STORAGE_TARANTOOL_SSL_PASSWORD
    | Command-line option: ``--storage.tarantool.ssl.password``

.. _tcm_configuration_reference_storage_tarantool_ssl_password-file:

.. confval:: storage.tarantool.ssl.password-file

    A text file with passwords for encrypted private SSL keys to use
    for connecting to the Tarantool |tcm| configuration storage.

    See also: :ref:`configuration_connections_ssl`.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_STORAGE_TARANTOOL_SSL_PASSWORD_FILE
    | Command-line option: ``--storage.tarantool.ssl.password-file``

.. _tcm_configuration_reference_storage_tarantool_required-protocol-info_auth:

.. confval:: storage.tarantool.required-protocol-info.auth

    An authentication method for the Tarantool |tcm| configuration storage.

    Possible values are the Go's `go-tarantool/Auth <https://pkg.go.dev/github.com/tarantool/go-tarantool#Auth>`__ constants:

    -   ``AutoAuth`` (0)
    -   ``ChapSha1Auth``
    -   ``PapSha256Auth``

    See also `go-tarantool.ProtocolInfo <https://pkg.go.dev/github.com/tarantool/go-tarantool#ProtocolInfo>`__.

    |
    | Type: int
    | Default: 0
    | Environment variable: TCM_STORAGE_TARANTOOL_SSL_REQUIRED_PROTOCOL_INFO_AUTH
    | Command-line option: ``--storage.tarantool.required-protocol-info.auth``

.. _tcm_configuration_reference_storage_tarantool_required-protocol-info_version:

.. confval:: storage.tarantool.required-protocol-info.version

    A Tarantool protocol version.

    See also `go-tarantool.ProtocolInfo <https://pkg.go.dev/github.com/tarantool/go-tarantool#ProtocolInfo>`__.

    |
    | Type: uint64
    | Default: 0
    | Environment variable: TCM_STORAGE_TARANTOOL_SSL_REQUIRED_PROTOCOL_INFO_VERSION
    | Command-line option: ``--storage.tarantool.required-protocol-info.version``

.. _tcm_configuration_reference_storage_tarantool_required-protocol-info_features:

.. confval:: storage.tarantool.required-protocol-info.features

    An array of Tarantool protocol features.

    See also `go-tarantool.ProtocolInfo <https://pkg.go.dev/github.com/tarantool/go-tarantool#ProtocolInfo>`__.

    |
    | Type: []int
    | Default: []
    | Environment variable: TCM_STORAGE_TARANTOOL_SSL_REQUIRED_PROTOCOL_INFO_FEATURES
    | Command-line option: ``--storage.tarantool.required-protocol-info.features``

.. _tcm_configuration_reference_storage_tarantool_embed:

storage.tarantool.embed.*
~~~~~~~~~~~~~~~~~~~~~~~~~

The ``storage.tarantool.embed`` group parameters define the configuration of the
embedded Tarantool cluster to use as a |tcm| backend store.
This cluster can be used for development purposes when the production or testing
cluster is not available or not needed.

See also :ref:`tcm_backend_store_embed`.

.. _tcm_configuration_reference_addon:

addon
-----

The ``addon`` section defines settings related to |tcm| add-ons.

-   :ref:`addon.enabled <tcm_configuration_reference_addon_enabled>`
-   :ref:`addon.addons-dir <tcm_configuration_reference_addon_addons-dir>`
-   :ref:`addon.max-upload-size <tcm_configuration_reference_addon_max-upload-size>`
-   :ref:`addon.dev-addons-dir <tcm_configuration_reference_addon_dev-addons-dir>`

.. _tcm_configuration_reference_addon_enabled:

.. confval:: addon.enabled

    Whether to enable the add-on functionality in |tcm|.

    |
    | Type: bool
    | Default: false
    | Environment variable: TCM_ADDON_ENABLED
    | Command-line option: ``--addon.enabled``

.. _tcm_configuration_reference_addon_addons-dir:

.. confval:: addon.addons-dir

    The directory from which |tcm| takes add-ons.

    |
    | Type: string
    | Default: addons
    | Environment variable: TCM_ADDON_ADDONS_DIR
    | Command-line option: ``--addon.addons-dir``

.. _tcm_configuration_reference_addon_max-upload-size:

.. confval:: addon.max-upload-size

    The maximum size (in bytes) of addon to upload to |tcm|.

    |
    | Type: int64
    | Default: 104857600
    | Environment variable: TCM_ADDON_MAX_UPLOAD_SIZE
    | Command-line option: ``--addon.max-upload-size``

.. _tcm_configuration_reference_addon_dev-addons-dir:

.. confval:: addon.dev-addons-dir

    Additional add-on directories for development purposes, separated by semicolons (``;``).

    |
    | Type: []string
    | Default: []
    | Environment variable: TCM_ADDON_DEV_ADDONS_DIR
    | Command-line option: ``--addon.dev-addons-dir``

.. limits configuration

.. _tcm_configuration_reference_limits:

limits
------

The ``limits`` section defines limits on various |tcm| objects and relations
between them.

-   :ref:`limits.users-count <tcm_configuration_reference_limits_users-count>`
-   :ref:`limits.clusters-count <tcm_configuration_reference_limits_clusters-count>`
-   :ref:`limits.roles-count <tcm_configuration_reference_limits_roles-count>`
-   :ref:`limits.webhooks-count <tcm_configuration_reference_limits_webhooks-count>`
-   :ref:`limits.user-secrets-count <tcm_configuration_reference_limits_user-secrets-count>`
-   :ref:`limits.user-websessions-count <tcm_configuration_reference_limits_user-websessions-count>`
-   :ref:`limits.linked-cluster-users <tcm_configuration_reference_limits_linked-cluster-users>`

.. _tcm_configuration_reference_limits_users-count:

.. confval:: limits.users-count

    The maximum number of users in |tcm|.

    |
    | Type: int
    | Default: 1000
    | Environment variable: TCM_LIMITS_USERS_COUNT
    | Command-line option: ``--limits.users-count``

.. _tcm_configuration_reference_limits_clusters-count:

.. confval:: limits.clusters-count

    The maximum number of clusters in |tcm|.

    |
    | Type: int
    | Default: 10
    | Environment variable: TCM_LIMITS_CLUSTERS_COUNT
    | Command-line option: ``--limits.clusters-count``

.. _tcm_configuration_reference_limits_roles-count:

.. confval:: limits.roles-count

    The maximum number of roles in |tcm|.

    |
    | Type: int
    | Default: 100
    | Environment variable: TCM_LIMITS_ROLES_COUNT
    | Command-line option: ``--limits.roles-count``

.. _tcm_configuration_reference_limits_webhooks-count:

.. confval:: limits.webhooks-count

    The maximum number of webhooks in |tcm|.

    |
    | Type: int
    | Default: 200
    | Environment variable: TCM_LIMITS_WEBHOOKS_COUNT
    | Command-line option: ``--limits.webhooks-count``

.. _tcm_configuration_reference_limits_user-secrets-count:

.. confval:: limits.user-secrets-count

    The maximum number secrets that a |tcm| user can have.

    |
    | Type: int
    | Default: 10
    | Environment variable: TCM_LIMITS_USER_SECRETS_COUNT
    | Command-line option: ``--limits.user-secrets-count``

.. _tcm_configuration_reference_limits_user-websessions-count:

.. confval:: limits.user-websessions-count

    The maximum number of open sessions that a |tcm| user can have.

    |
    | Type: int
    | Default: 10
    | Environment variable: TCM_LIMITS_USER_WEBSESSIONS_COUNT
    | Command-line option: ``--limits.user-websessions-count``

.. _tcm_configuration_reference_limits_linked-cluster-users:

.. confval:: limits.linked-cluster-users

    The maximum number of clusters to which a single user can have access.

    |
    | Type: int
    | Default: 10
    | Environment variable: TCM_LIMITS_LINKED_CLUSTER_USERS
    | Command-line option: ``--limits.linked-cluster-users``


.. security parameters

.. _tcm_configuration_reference_security:

security
--------

The ``security`` section defines the security parameters of |tcm|.

-   :ref:`security.auth <tcm_configuration_reference_security_auth>`
-   :ref:`security.hash-cost <tcm_configuration_reference_security_hash-cost>`
-   :ref:`security.encryption-key <tcm_configuration_reference_security_encryption-key>`
-   :ref:`security.encryption-key-file <tcm_configuration_reference_security_encryption-key-file>`
-   :ref:`security.bootstrap-password <tcm_configuration_reference_security_bootstrap-password>`
-   :ref:`security.bootstrap-api-token <tcm_configuration_reference_security_bootstrap-api-token>`
-   :ref:`security.integrity-check <tcm_configuration_reference_security_integrity-check>`
-   :ref:`security.signature-private-key-file <tcm_configuration_reference_security_signature-private-key-file>`

.. _tcm_configuration_reference_security_auth:

.. confval:: security.auth

    Ways to log into |tcm|.

    Possible values:

    - ``local``
    - ``ldap``

    |
    | Type: []string
    | Default: [local]
    | Environment variable: TCM_SECURITY_AUTH
    | Command-line option: ``--security.auth``

.. _tcm_configuration_reference_security_hash-cost:

.. confval:: security.hash-cost

    A hash cost for hashing users' passwords.

    |
    | Type: int
    | Default: 12
    | Environment variable: TCM_SECURITY_HASH_COST
    | Command-line option: ``--security.hash-cost``

.. _tcm_configuration_reference_security_encryption-key:

.. confval:: security.encryption-key

    An encryption key for passwords used by |tcm| for accessing Tarantool
    and etcd clusters.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_SECURITY_ENCRYPTION_KEY
    | Command-line option: ``--security.encryption-key``

.. _tcm_configuration_reference_security_encryption-key-file:

.. confval:: security.encryption-key-file

    A path to the file with the encryption key for passwords used by |tcm| for accessing Tarantool
    and etcd clusters.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_SECURITY_ENCRYPTION_KEY_FILE
    | Command-line option: ``--security.encryption-key-file``

.. _tcm_configuration_reference_security_bootstrap-password:

.. confval:: security.bootstrap-password

    A password for the first login of the ``admin`` user. Only for testing purposes.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_SECURITY_BOOTSTRAP_PASSWORD
    | Command-line option: ``--security.bootstrap-password``

.. _tcm_configuration_reference_security_bootstrap-api-token:

.. confval:: security.bootstrap-api-token

    A default API token for the ``admin`` user. Only for testing purposes.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_SECURITY_BOOTSTRAP_API_TOKEN
    | Command-line option: ``--security.bootstrap-api-token``

.. _tcm_configuration_reference_security_integrity-check:

.. confval:: security.integrity-check

    Whether to check the digital signature. If ``true``, the error is raised
    in case an incorrect signature is detected.

    |
    | Type: bool
    | Default: false
    | Environment variable: TCM_SECURITY_INTEGRITY_CHECK
    | Command-line option: ``--security.integrity-check``

.. _tcm_configuration_reference_security_signature-private-key-file:

.. confval:: security.signature-private-key-file

    A path to a file with the private key to sign |tcm| data.

    |
    | Type: string
    | Default: ""
    | Environment variable: TCM_SECURITY_SIGNATURE_PRIVATE_KEY_FILE
    | Command-line option: ``--security.signature-private-key-file``

.. mode

.. _tcm_configuration_reference_mode:

mode
----

.. confval:: mode

    The |tcm| mode: ``production``, ``development``, or ``test``.

    |
    | Type: string
    | Default: production
    | Environment variable: TCM_MODE
    | Command-line option: ``--mode``


.. feature

.. _tcm_configuration_reference_feature:

feature
-------


The ``feature`` section defines the security parameters of |tcm|.

-   :ref:`feature.ttgraph <tcm_configuration_reference_feature_ttgraph>`
-   :ref:`feature.column-store <tcm_configuration_reference_feature_column-store>`
-   :ref:`feature.tqe <tcm_configuration_reference_feature_tqe>`
-   :ref:`feature.api-token <tcm_configuration_reference_feature_api-token>`


.. _tcm_configuration_reference_feature_ttgraph:

.. confval:: feature.ttgraph

    Whether Tarantool Graph DB integration is enabled.

    |
    | Type: bool
    | Default: false
    | Environment variable: TCM_FEATURE_TTGRAPH
    | Command-line option: ``--feature.ttgraph``

.. _tcm_configuration_reference_feature_column-store:

.. confval:: feature.column-store

    Whether Tarantool Column Store integration is enabled.

    |
    | Type: bool
    | Default: false
    | Environment variable: TCM_FEATURE_COLUMN_STORE
    | Command-line option: ``--feature.column-store``

.. _tcm_configuration_reference_feature_tqe:

.. confval:: feature.tqe

    Whether Tarantool Queue Enterprise integration is enabled.

    |
    | Type: bool
    | Default: false
    | Environment variable: TCM_FEATURE_TQE
    | Command-line option: ``--feature.tqe``

.. _tcm_configuration_reference_feature_api-token:

.. confval:: feature.api-token

    Whether the use of :ref:`API tokens <tcm_access_control_api_tokens>` is enabled.

    |
    | Type: bool
    | Default: false
    | Environment variable: TCM_FEATURE_API_TOKEN
    | Command-line option: ``--feature.api-token``

.. _tcm_configuration_reference_initial:

initial-settings
----------------

The ``initial-settings`` group defines entities that are created automatically
upon the first |tcm| startup.

See also :ref:`tcm_configuration_initial`.


-   :ref:`initial-settings.clusters <tcm_configuration_reference_initial_clusters>`

.. important::

    The ``initial-settings.*`` configuration options can be set in the YAML
    configuration file only. There are no environment variables nor
    command-line options for them.

.. _tcm_configuration_reference_initial_clusters:

.. confval:: initial-settings.clusters

    An array of clusters to create in |tcm| automatically upon the first startup.

    See also :ref:`tcm_configuration_initial`.

    |
    | Type: []Cluster
    | Default: []


.. _tcm_configuration_reference_initial_cluster_id:

.. confval:: initial-settings.clusters.<cluster>.id

    Cluster ID. Skip this option to generate an ID automatically.
    Specify the value ``00000000-0000-0000-0000-000000000000``
    to customize the default cluster upon |tcm| startup.

    |
    | Type: string
    | Default: "" (ID is generated automatically)


.. _tcm_configuration_reference_initial_cluster_name:

.. confval:: initial-settings.clusters.<cluster>.name

    Cluster name.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_description:

.. confval:: initial-settings.clusters.<cluster>.description

    Cluster description.

    |
    | Type: string
    | Default: ""


.. _tcm_configuration_reference_initial_cluster_color:

.. confval:: initial-settings.clusters.<cluster>.color

    A color to highlight the cluster in |tcm|.
    Possible values:

    -   ``dark``
    -   ``gray``
    -   ``red``
    -   ``pink``
    -   ``grape``
    -   ``violet``
    -   ``indigo``
    -   ``blue``
    -   ``cyan``
    -   ``green``
    -   ``lime``
    -   ``yellow``
    -   ``orange``
    -   ``teal``
    -   empty string (no color)

    |
    | Type: string
    | Default: "" (no color)


.. _tcm_configuration_reference_initial_cluster_urls:

.. confval:: initial-settings.clusters.<cluster>.urls

    URLs of additional services for the cluster. See also :ref:`tcm_connect_clusters_connect_new`.

    |
    | Type: []ClusterUrl
    | Default: []


.. _tcm_configuration_reference_initial_cluster_url_label:

.. confval:: initial-settings.clusters.<cluster>.<url>.label

    URL label to show in |tcm|. Typically, this is the linked service name.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_url_url:

.. confval:: initial-settings.clusters.<cluster>.<url>.url

    The URL address of the linked service.

    |
    | Type: string
    | Default: ""


.. _tcm_configuration_reference_initial_cluster_storage_provider:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.provider

    The type of the storage used for storing the cluster configuration.

    Possible values:

    -   ``etcd``
    -   ``tarantool``
    -   empty string (undefined)

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_storage_etcd_endpoints:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.endpoints

    An array of node URIs of the etcd cluster where the Tarantool cluster configuration is stored.

    |
    | Type: []string
    | Default: []

.. _tcm_configuration_reference_initial_cluster_storage_etcd_autosync:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.auto-sync-interval

    An automated sync interval.

    |
    | Type: time.Duration
    | Default: 0 (disabled)

.. _tcm_configuration_reference_initial_cluster_storage_etcd_dialtimeout:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.dial-timeout

    An etcd dial timeout.

    |
    | Type: time.Duration
    | Default: 0 (not set)

.. _tcm_configuration_reference_initial_cluster_storage_etcd_dialkatime:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.dial-keep-alive-time

    A dial keep-alive time.

    |
    | Type: time.Duration
    | Default: 0 (not set)

.. _tcm_configuration_reference_initial_cluster_storage_etcd_dialkatimeout:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.dial-keep-alive-timeout

    A dial keep-alive timeout.

    |
    | Type: time.Duration
    | Default: 0 (not set)

.. _tcm_configuration_reference_initial_cluster_storage_etcd_maxcallsend:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.max-call-send-msg-size

    The maximum size (in bytes) of a request from the cluster to its etcd
    configuration storage.

    |
    | Type: int
    | Default: 2097152

.. _tcm_configuration_reference_initial_cluster_storage_etcd_maxcallrecv:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.max-call-recv-msg-size

    The maximum size (in bytes) of a response to the cluster from its etcd
    configuration storage.

    |
    | Type: int
    | Default: 0 (unlimited)

.. _tcm_configuration_reference_initial_cluster_storage_etcd_username:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.username

    A username for accessing the cluster's etcd storage.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_storage_etcd_password:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.password

    A password for accessing the cluster's etcd storage.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_storage_etcd_rejectold:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.reject-old-cluster

    Whether etcd should refuse to create a client against an outdated cluster.

    |
    | Type: bool
    | Default: false

.. _tcm_configuration_reference_initial_cluster_storage_etcd_permitwostream:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.permit-without-stream

    Whether keepalive pings can be send to the etcd server without active streams.

    |
    | Type: bool
    | Default: false

.. _tcm_configuration_reference_initial_cluster_storage_etcd_prefix:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.prefix

    A prefix for the cluster configuration parameters in etcd.

    |
    | Type: string
    | Default: ""


.. _tcm_configuration_reference_initial_cluster_etcd_tls_enabled:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.tls.enabled

    Indicates whether TLS is enabled for connections to the cluster's etcd storage.

    |
    | Type: bool
    | Default: false

.. _tcm_configuration_reference_initial_cluster_etcd_tls_cert-file:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.tls.cert-file

    A path to a TLS certificate file to use for etcd connections.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_etcd_tls_key-file:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.tls.key-file

    A path to a TLS private key file to use for etcd connections.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_etcd_tls_trusted-ca-file:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.tls.trusted-ca-file

    A path to a trusted CA certificate file to use for etcd connections.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_etcd_tls_client-cert-auth:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.tls.client-cert-auth

    Indicates whether client cert authentication is enabled.

    |
    | Type: bool
    | Default: false

.. _tcm_configuration_reference_initial_cluster_etcd_tls_crl-file:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.tls.crl-file

    A path to the client certificate revocation list file.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_etcd_tls_insecure-skip-verify:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.tls.insecure-skip-verify

    Skip checking client certificate in etcd connections.

    |
    | Type: bool
    | Default: false

.. _tcm_configuration_reference_initial_cluster_etcd_tls_skip-client-san-verify:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.tls.skip-client-san-verify

    Skip verification of SAN field in client certificate for etcd connections.

    |
    | Type: bool
    | Default: false

.. _tcm_configuration_reference_initial_cluster_etcd_tls_server-name:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.tls.server-name

    Name of the TLS server for etcd connections.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_etcd_tls_cipher-suites:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.tls.cipher-suites

    TLS cipher suites for etcd connections. Possible values are the Golang `tls.TLS_* <https://pkg.go.dev/crypto/tls#pkg-constants>`__ constants.

    |
    | Type: []uint16
    | Default: []

.. _tcm_configuration_reference_initial_cluster_etcd_tls_allowed-cn:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.tls.allowed-cn

    An allowed common name for authentication in etcd connections.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_etcd_tls_allowed-hostname:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.tls.allowed-hostname

    An allowed TLS certificate name for authentication in etcd connections.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_etcd_tls_empty-cn:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.etcd-connection.tls.empty-cn

    Whether the empty common name is allowed in etcd connections.

    |
    | Type: bool
    | Default: false


.. _tcm_configuration_reference_initial_cluster_storage_tarantool_username:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.tarantool-connection.username

    A username for connecting to the cluster's Tarantool-based configuration storage.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_storage_tarantool_password:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.tarantool-connection.password

    A password for connecting to the cluster's Tarantool-based configuration storage.

    |
    | Type: string
    | Default: ""


.. _tcm_configuration_reference_initial_cluster_storage_tarantool_endpoints:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.tarantool-connection.endpoints

    An array of the cluster's Tarantool-based configuration storage URIs.

    |
    | Type: []string
    | Default: []

.. _tcm_configuration_reference_initial_cluster_storage_tarantool_method:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.tarantool-connection.method

    An authentication method for the cluster's Tarantool-based configuration storage.

    Possible values are the Go's `go-tarantool/Auth <https://pkg.go.dev/github.com/tarantool/go-tarantool#Auth>`__ constants:

    -   ``AutoAuth`` (0)
    -   ``ChapSha1Auth``
    -   ``PapSha256Auth``

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_storage_tarantool_prefix:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.tarantool-connection.prefix

    A prefix for the cluster configuration parameters in the Tarantool-based configuration storage.

    |
    | Type: string
    | Default: ""


.. _tcm_configuration_reference_initial_cluster_storage_tarantool_ssl_key-file:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.tarantool-connection.ssl.key-file

    A path to a TLS private key file to use for connecting to the cluster's Tarantool-based
    configuration storage.

    See also: :ref:`configuration_connections_ssl`.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_storage_tarantool_ssl_cert-file:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.tarantool-connection.ssl.cert-file

    A path to an SSL certificate to use for connecting to the cluster's Tarantool-based
    configuration storage.

    See also: :ref:`configuration_connections_ssl`.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_storage_tarantool_ssl_ca-file:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.tarantool-connection.ssl.ca-file

    A path to a trusted CA certificate to use for connecting to the cluster's Tarantool-based
    configuration storage.

    See also: :ref:`configuration_connections_ssl`.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_storage_tarantool_ssl_ciphers:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.tarantool-connection.ssl.ciphers

    A list of SSL cipher suites that can be used for connecting to the cluster's Tarantool-based
    configuration storage. Possible values are listed in :ref:`<uri>.params.ssl_ciphers <configuration_reference_iproto_uri_params_ssl_ciphers>`.

    See also: :ref:`configuration_connections_ssl`.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_storage_tarantool_ssl_enabled:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.tarantool-connection.ssl.enabled

    A password for an encrypted private SSL key to use for connecting to the cluster's Tarantool-based
    configuration storage.

    See also: :ref:`configuration_connections_ssl`.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_storage_tarantool_ssl_password-file:

.. confval:: initial-settings.clusters.<cluster>.storage-connection.tarantool-connection.ssl.password-file

    A text file with passwords for encrypted private SSL keys to use
    for connecting to the cluster's Tarantool-based configuration storage.

    See also: :ref:`configuration_connections_ssl`.

    |
    | Type: string
    | Default: ""


.. _tcm_configuration_reference_initial_cluster_tarantool_username:

.. confval:: initial-settings.clusters.<cluster>.tarantool-connection.username

    A username for connecting to the cluster instances.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_tarantool_password:

.. confval:: initial-settings.clusters.<cluster>.tarantool-connection.password

    A password for connecting to the cluster instances.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_tarantool_method:

.. confval:: initial-settings.clusters.<cluster>.tarantool-connection.method

    An authentication method for connecting to the cluster.

    Possible values are the Go's `go-tarantool/Auth <https://pkg.go.dev/github.com/tarantool/go-tarantool#Auth>`__ constants:

    -   ``AutoAuth`` (0)
    -   ``ChapSha1Auth``
    -   ``PapSha256Auth``

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_tarantool_timeout:

.. confval:: initial-settings.clusters.<cluster>.tarantool-connection.timeout

    The cluster request timeout.

    |
    | Type: time.Duration
    | Default: 0 (not set)

.. _tcm_configuration_reference_initial_cluster_tarantool_rate-limit:

.. confval:: initial-settings.clusters.<cluster>.tarantool-connection.rate-limit

    The cluster rate limit.

    |
    | Type: uint
    | Default: 0 (not set)


.. _tcm_configuration_reference_initial_cluster__tarantool_ssl_key-file:

.. confval:: initial-settings.clusters.<cluster>.tarantool-connection.ssl.key-file

    A path to a TLS private key file to use for connecting to the cluster instances.

    See also: :ref:`configuration_connections_ssl`.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_tarantool_ssl_cert-file:

.. confval:: initial-settings.clusters.<cluster>.tarantool-connection.ssl.cert-file

    A path to an SSL certificate to use for connecting to the cluster instances.

    See also: :ref:`configuration_connections_ssl`.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_tarantool_ssl_ca-file:

.. confval:: initial-settings.clusters.<cluster>.tarantool-connection.ssl.ca-file

    A path to a trusted CA certificate to use for connecting to the cluster instances.

    See also: :ref:`configuration_connections_ssl`.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_tarantool_ssl_ciphers:

.. confval:: initial-settings.clusters.<cluster>.tarantool-connection.ssl.ciphers

    A list of SSL cipher suites that can be used for connecting to the cluster instances.
    Possible values are listed in :ref:`<uri>.params.ssl_ciphers <configuration_reference_iproto_uri_params_ssl_ciphers>`.

    See also: :ref:`configuration_connections_ssl`.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_tarantool_ssl_enabled:

.. confval:: initial-settings.clusters.<cluster>.tarantool-connection.ssl.enabled

    A password for an encrypted private SSL key to use for connecting to the cluster instances.

    See also: :ref:`configuration_connections_ssl`.

    |
    | Type: string
    | Default: ""

.. _tcm_configuration_reference_initial_cluster_tarantool_ssl_password-file:

.. confval:: initial-settings.clusters.<cluster>.tarantool-connection.ssl.password-file

    A text file with passwords for encrypted private SSL keys to use
    for connecting to the cluster instances.

    See also: :ref:`configuration_connections_ssl`.

    |
    | Type: string
    | Default: ""
