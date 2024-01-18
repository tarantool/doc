.. _enterprise-flight-recorder:

Flight recorder
===============

**Example on GitHub**: `flightrec <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/flightrec>`_

The flight recorder available in the Enterprise Edition is an event collection tool that
gathers various information about a working Tarantool instance, such as:

*   logs
*   metrics
*   requests and responses

This information helps you investigate incidents related
to :ref:`crashing <admin-disaster_recovery>` a Tarantool instance.


.. _enterprise-flight-recorder_enable:

Enabling the flight recorder
----------------------------

The flight recorder is disabled by default and can be enabled and configured for
a specific Tarantool instance.
To enable the flight recorder, set the :ref:`flightrec.enabled <configuration_reference_flightrec_enabled>`
configuration option to ``true``. This option is dynamic and can be changed at runtime.

..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/flightrec/config.yaml
    :language: yaml
    :start-at: flightrec:
    :end-at: enabled: true
    :dedent:


After ``flightrec_enabled`` is set to ``true``, the flight recorder starts collecting data in the flight recording file  ``current.ttfr``.
This file is stored in the :ref:`memtx_dir <cfg_basic-memtx_dir>` directory.
By default, the directory is ``var/log/{{ instance_name }}/<file_name>.ttfr``.

If the instance crashes and reboots, Tarantool rotates the flight recording:
``current.ttfr`` is renamed to ``<timestamp>.ttfr`` (for example, ``20230411T050721.ttfr``)
and the new ``current.ttfr`` file is created for collecting data.
In the case of correct shutdown (for example, using ``os.exit()``),
Tarantool continues writing to the existing ``current.ttfr`` file after restart.

.. NOTE::

    Note that old flight recordings should be removed manually.


See also: :ref:`Flight recorder configuration options <configuration_reference_flightrec>`.

Reading flight recordings
-------------------------

Since:** :doc:`3.0.0 </release/3.0.0>` version, you can read flight recordings using the API provided by the
``flightrec`` module. To open and read ``*.ttfr`` files, use the Lua API:

..  include:: /release/3.0.0.rst
    :start-after: 3-0-flight-recorder-begin
    :end-before: 3-0-flight-recorder-end


