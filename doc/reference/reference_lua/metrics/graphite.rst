..  _metrics-graphite-api_reference:

metrics.plugins.graphite
========================

..  module:: metrics.plugins.graphite

..  function:: init(options)

    Send all metrics to a remote Graphite server.
    Exported metric names are formatted as follows: ``<prefix>.<metric_name>``.

    :param table options: possible options:

                          *  ``prefix`` (string): metrics prefix (``'tarantool'`` by default)
                          *  ``host`` (string): Graphite server host (``'127.0.0.1'`` by default)
                          *  ``port`` (number): Graphite server port (``2003`` by default)
                          *  ``send_interval`` (number): metrics collection interval in seconds
                             (``2`` by default)

**Example**

..  code-block:: lua

    local graphite_plugin = require('metrics.plugins.graphite')
    graphite_plugin.init {
        prefix = 'tarantool',
        host = '127.0.0.1',
        port = 2003,
        send_interval = 1,
    }
