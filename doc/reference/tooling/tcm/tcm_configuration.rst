.. _tcm_configuration:

Configuration
=============

.. TODO: write specific configuration tutorials for http, security, logging, and so on.

This topic describes the |tcm_full_name| configuration model. For the complete
list of |tcm| configuration parameters, see the :ref:`TCM configuration reference <tcm_configuration_reference>`.

Configuration structure
-----------------------

|tcm_full_name| configuration is a set of parameters that define various aspects
of |tcm| functioning. Parameters are grouped by the particular aspect that they
affect. There are the following groups:

*   HTTP
*   logging
*   configuration storage
*   security
*   add-ons
*   limits
*   |tcm| running mode

Parameter groups can be nested. For example, in the ``http`` group there are
``tls`` and ``websession-cookie`` groups, which define TLS encryption and
cookie settings.

Parameter names are the full paths from the top-level group to the specific parameter.
For example:

*   ``http.host`` is the ``host`` parameter that is defined directly in the ``http`` group.
*   ``http.tls.enabled`` is the ``enabled`` parameter that is defined in the ``tls``
    nested group within ``http``.

.. _tcm_configuration_ways:

Ways to pass configuration parameters
-------------------------------------

There are three ways to pass |tcm| configuration parameters:

-   a YAML file
-   environment variables
-   command-line options of the |tcm| executable

.. _tcm_configuration_ways_yaml:

YAML file
~~~~~~~~~

|tcm| configuration can be stored in a YAML file. Its structure must reflect the
configuration parameters hierarchy.

The example below shows a shows a fragment of a |tcm| configuration file:

.. code-block:: yaml

    # a fragment of a YAML configuration file
    cluster: # top-level group
        on-air-limit: 4096
        connection-rate-limit: 512
        tarantool-timeout: 10s
        tarantool-ping-timeout: 5s
    http: # top-level group
        basic-auth: # nested group
            enabled: false
        network: tcp
        host: 127.0.0.1
        port: 8080
        request-size: 1572864
        websocket: # nested group
            read-buffer-size: 16384
            write-buffer-size: 16384
            keepalive-ping-interval: 20s
            handshake-timeout: 10s
            init-timeout: 15s

To start |tcm| with a YAML configuration, pass the location of the configuration
file in the ``-c`` command-line option:

.. code-block:: console

    tcm -c=config.yml

.. _tcm_configuration_ways_env:

Environment variables
~~~~~~~~~~~~~~~~~~~~~

|tcm| can take values of its configuration parameters from environment variables.
The variable names start with ``TCM_``. Then goes the full path to the parameter,
converted to upper case. All delimiters are replaced with underscores (``_``).
Examples:

-   ``TCM_HTTP_HOST`` is a variable for the ``http.host`` parameter.
-   ``TCM_HTTP_WEBSESSION_COOKIE_NAME`` is a variable for the ``http.websession-cookie.name`` parameter.

The example below shows how to start |tcm| passing configuration parameters in
environment variables:

.. code-block:: console

    export TCM_HTTP_HOST=0.0.0.0
    export TCM_HTTP_PORT=8888
    tcm

.. _tcm_configuration_ways_cli:

Command-line arguments
~~~~~~~~~~~~~~~~~~~~~~

The |tcm| executable has ``--`` command-line options for each configuration parameter.
Their names reflect the full path to the parameter, with all delimiters replaced by
hyphens (``-``). Examples:

-   ``--http-host`` is an option for ``http.host``.
-  ``--http-websession-cookie-name`` is an option for ``http.websession-cookie.name``.

The example below shows how to start |tcm| passing configuration parameters in
command-line options:

.. code-block:: console

    ./tcm --storage.etcd.embed.enabled --addon.enabled --http.host=0.0.0.0 --http.port=8888


..  _tcm_configuration_precedence:

Configuration precedence
~~~~~~~~~~~~~~~~~~~~~~~~

|tcm| configuration options are applied from multiple sources with the following precedence,
from highest to lowest:

#.  ``tcm`` executable arguments.
#.  `TCM_*` environment variables.
#.  Configuration from a YAML file.

If the same option is defined in two or more locations, the option with the highest
precedence is applied. For options that aren't defined in any location, the default
values are used.

You can combine different ways of |tcm| configuration for efficient management of
multiple |tcm| installations:

-   A single YAML file for all installations can contain the common configuration parts.
    For example, the |tcm| configuration storage used for all installations or
    TLS settings.
-   Environment variables that set specific parameters for each server, such as
    local directories and paths.
-   Command-line options for parameters that must be unique for different |tcm| instances
    running on a single server. For example, ``http.port``.

Configuration parameter types
-----------------------------

|tcm| configuration parameters have the `Go <https://go.dev/>`__ language
types. Note that this is different from the :ref:`Tarantool configuration parameters <configuration_reference>`,
which have Lua types.

Most options have the Go's basic types: `bool`, `string`, `int`, and other numeric types.
Their values are passed as strings:

.. code-block:: yaml

    http:
        basic-auth:
            enabled: false # bool
        network: tcp # string
        host: 127.0.0.1 #string
        port: 8080 # int
        request-size: 1572864 # int64

Parameters that can take multiple values are arrays. In YAML, they are passed as
YAML arrays (each item on a new line, starting with a dash). In environment variables
and command line options, the items of such arrays are passed in a semicolon-separated string.

.. code-block:: yaml

    storage:
    provider: etcd
    etcd:
        endpoints: # array
            - https://192.168.0.1:2379 # item 1
            - https://192.168.0.2:2379 # item 2

Parameters that set timeouts, TTLs, and other duration values, have the Go's `time.Duration <https://pkg.go.dev/time#Duration>`__
type. Their values can be passed in time-formatted strings such as ``4h30m25s``.

.. code-block:: yaml

    cluster:
        tarantool-timeout: 10s # duration
        tarantool-ping-timeout: 5s # duration

Finally, there are parameters whose values are constants defined in Go packages.
For example, :ref:`http.websession-cookie.same-site <tcm_configuration_reference_http_websession-cookie_same-site> `
values are constants from the Go's `http.SameSite <https://pkg.go.dev/net/http#SameSite>`__
type. To find out the exact values available for such parameters, refer to `Go
packages documentation <https://pkg.go.dev/>`__.

.. code-block:: yaml

    http:
        tls:
            cipher-suites:
                - TLS_RSA_WITH_RC4_128_SHA # Go constant

Creating configuration template
-------------------------------

You can create a YAML configuration template for |tcm| by running the ``tcm``
executable with the ``generate-config`` option:

.. code-block:: console

    tcm generate-config