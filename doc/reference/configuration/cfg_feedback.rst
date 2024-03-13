.. _cfg_feedback:

* :ref:`feedback_enabled <cfg_logging-feedback_enabled>`
* :ref:`feedback_host <cfg_logging-feedback_host>`
* :ref:`feedback_interval <cfg_logging-feedback_interval>`

By default, a Tarantool daemon sends a small packet
once per hour, to ``https://feedback.tarantool.io``.
The packet contains three values from :ref:`box.info <box_introspection-box_info>`:
``box.info.version``, ``box.info.uuid``, and ``box.info.cluster_uuid``.
By changing the feedback configuration parameters, users can
adjust or turn off this feature.

.. _cfg_logging-feedback_enabled:

.. confval:: feedback_enabled

    Since version 1.10.1.

    Whether to send feedback.

    If this is set to ``true``, feedback will be sent as described above.
    If this is set to ``false``, no feedback will be sent.

    |
    | Type: boolean
    | Default: true
    | Environment variable: TT_FEEDBACK_ENABLED
    | Dynamic: yes

.. _cfg_logging-feedback_host:

.. confval:: feedback_host

    Since version 1.10.1.

    The address to which the packet is sent.
    Usually the recipient is Tarantool, but it can be any URL.

    |
    | Type: string
    | Default: ``https://feedback.tarantool.io``
    | Environment variable: TT_FEEDBACK_HOST
    | Dynamic: yes

.. _cfg_logging-feedback_interval:

.. confval:: feedback_interval

    Since version 1.10.1.

    The number of seconds between sendings, usually 3600 (1 hour).

    |
    | Type: float
    | Default: 3600
    | Environment variable: TT_FEEDBACK_INTERVAL
    | Dynamic: yes
