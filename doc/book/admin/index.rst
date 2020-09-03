.. _admin:

********************************************************************************
Administration
********************************************************************************

Tarantool is designed to have multiple running instances on the same host.

Here we show how to administer Tarantool instances using any of the following
utilities:

* ``systemd`` native utilities, or
* :ref:`tarantoolctl <tarantoolctl>`, a utility shipped and installed as
  part of Tarantool distribution.

.. NOTE::

   * Unlike the rest of this manual, here we use system-wide paths.
   * Console examples here are for Fedora.

This chapter includes the following sections:

.. toctree::
   :maxdepth: 2
   :numbered: 0

   instance_config
   start_stop_instance
   logs
   security
   server_introspection
   daemon_supervision
   disaster_recovery
   backups
   upgrades
   os_notes
   bug_reports
   troubleshoot
   ../monitoring/index
