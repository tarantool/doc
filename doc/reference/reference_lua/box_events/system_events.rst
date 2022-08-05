.. _system-events:

System events
=============

Predefined events have a special naming schema -- theirs names always start with the reserved ``box.`` prefix.
It means that you cannot create new events with it.

The system processes the following events:

*   ``box.id``
*   ``box.status``
*   ``box.election``
*   ``box.schema``

In response to each event, the server sends back certain ``IPROTO`` fields.

The events are available from the beginning as non-:ref:`MP_NIL <box_protocol-notation>`.
If a watcher subscribes to a system event before it has been broadcast,
it receives an empty table for the event value.

The event is generated when there is a change in any of the values listed in the event.
For example, see the parameters in the ``box.id`` event below -- ``id``, ``instance_uuid``, and ``replicaset_uuid``.
Suppose the ``ìd`` value (``box.info.id``) has changed.
This triggers the ``box.info`` event, which states that the value of ``box.info.id`` has changed,
while ``box.info.uuid`` and ``box.info.cluster.uuid`` remain the same.

box.id
~~~~~~

Contains :ref:`identification <box_info_info>` of the instance.
Value changes are rare.

*   ``id``: the numeric instance ID is unknown before the registration.
    For anonymous replicas, the value is ``0`` until they are officially registered.

*   ``instance_uuid``: the UUID of the instance never changes after the first
    :doc:`box.cfg </reference/reference_lua/box_cfg>`.
    The value is unknown before the ``box.cfg`` call.

*   ``replicaset_uuid``: the value is unknown until the instance joins a replicaset or boots a new one.

..  code-block:: lua

    -- box.id value
    {
    MP_STR “id”: MP_UINT; box.info.id,
    MP_STR “instance_uuid”: MP_UUID; box.info.uuid,
    MP_STR “replicaset_uuid”: MP_UUID box.info.cluster.uuid,
    }

box.status
~~~~~~~~~~

Contains generic information about the instance status.

*   ``is_ro``: :ref:`indicates the read-only mode <box_introspection-box_info>` or the ``orphan`` status.
*   ``is_ro_cfg``: indicates the :ref:`read_only <cfg_basic-read_only>` mode for the instance.
*   ``status``: shows the status of an instance.

..  code-block:: lua

    {
    MP_STR “is_ro”: MP_BOOL box.info.ro,
    MP_STR “is_ro_cfg”: MP_BOOL box.cfg.read_only,
    MP_STR “status”: MP_STR box.info.status,
    }

box.election
~~~~~~~~~~~~

Contains fields of :doc:`box.info.election </reference/reference_lua/box_info/election>`
that are necessary to find out the most recent writable leader.

*   ``term``: shows the current election term.
*   ``role``: indicates the election state of the node -- ``leader``, ``follower``, or ``candidate``.
*   ``is_ro``: :ref:`indicates the read-only mode <box_introspection-box_info>` or the ``orphan`` status.
*   ``leader``: shows the leader node ID in the current term.

..  code-block:: lua

    {
    MP_STR “term”: MP_UINT box.info.election.term,
    MP_STR “role”: MP_STR box.info.election.state,
    MP_STR “is_ro”: MP_BOOL box.info.ro,
    MP_STR “leader”: MP_UINT box.info.election.leader,
    }

box.schema
~~~~~~~~~~

Contains schema-related data.

*   ``version``: shows the schema version.

..  code-block:: lua

    {
    MP_STR “version”: MP_UINT schema_version,
    }

Usage example
-------------

..  code-block:: lua

    local conn = net.box.connect(URI)
    local log = require('log')
    -- Subscribe to updates of key 'box.id'
    local w = conn:watch('box.id', function(key, value)
        assert(key == 'box.id')
        log.info("The box.id value is '%s'", value)
    end)

If you want to unregister the watcher when it's no longer needed, use the following command:

..  code-block:: lua

    w:unregister()


