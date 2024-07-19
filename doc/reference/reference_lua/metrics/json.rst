..  _metrics-json-api_reference:

metrics.plugins.json
====================

..  module:: metrics.plugins.json

..  function:: export()

    Export metrics in the JSON format.

    :return: a string containing metrics in the JSON format

    :rtype: string

    ..  IMPORTANT::

        The values can also be ``+-math.huge`` and ``math.huge * 0``. In such case:

        *   ``math.huge`` is serialized to ``"inf"``
        *   ``-math.huge`` is serialized to ``"-inf"``
        *   ``math.huge * 0`` is serialized to ``"nan"``.


**Example**

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/metrics_plugins/examples/expose_json_metrics.lua
    :start-at: local json_plugin
    :end-at: local json_metrics
    :language: lua
    :dedent:

Example on GitHub: `metrics_plugins <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/metrics_plugins>`_
