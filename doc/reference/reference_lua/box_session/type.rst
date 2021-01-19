
.. _box_session-type:

================================================================================
box.session.type()
================================================================================

.. module:: box.session

.. function:: type()

    :return: the type of connection or cause of action.

    :rtype:  string

    Possible return values are:

    * 'binary' if the connection was done via the binary protocol, for example
      to a target made with
      :ref:`box.cfg{listen=...} <cfg_basic-listen>`;
    * 'console' if the connection was done via the administrative console,
      for example to a target made with
      :ref:`console.listen <console-listen>`;
    * 'repl' if the connection was done directly, for example when
      :ref:`using Tarantool as a client <admin-using_tarantool_as_a_client>`;
    * 'applier' if the action is due to
      :ref:`replication <replication>`,
      regardless of how the connection was done;
    * 'background' if the action is in a
      :ref:`background fiber <fiber-module>`,
      regardless of whether the Tarantool server was
      :ref:`started in the background <cfg_basic-background>`.

    ``box.session.type()`` is useful for an
    :ref:`on_replace() <box_space-on_replace>` trigger
    on a replica -- the value will be 'applier' if and only if
    the trigger was activated because of a request that was done on
    the master.