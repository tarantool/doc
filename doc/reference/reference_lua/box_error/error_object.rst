.. _box_error-error_object:

===============================================================================
error_object
===============================================================================

.. class:: error_object

    An object that defines an error.
    ``error_object`` is returned by the following methods:

    *  :ref:`box.error.new() <box_error-new>`
    *  :ref:`box.error.last() <box_error-last>`

    .. _box_error-unpack:

    .. method:: unpack()

        Get error details that may include an error code, type, message, and trace.

        **Example**

        ..  literalinclude:: /code_snippets/test/errors/unpack_clear_error_test.lua
            :language: lua
            :start-after: Get error details: start
            :end-before: Get error details: end
            :dedent:

        .. NOTE::

            Depending on the error type, error details may include other attributes, such as :ref:`errno <box_error-errno>` or :ref:`reason <box_error-reason>`.

    .. _box_error-raise:

    .. method:: raise()

        Raise the current error.

        **See also:** :ref:`Raising an error <box_error_raise_error>`

    .. _box_error-set_prev:

    .. method:: set_prev(error_object)

        **Since:** :doc:`2.4.1 </release/2.4.1>`

        Set the previous error for the current one.

        :param error_object body: an error object

        **See also:** :ref:`Error lists <box_error_error_lists>`

    .. _box_error-prev:

    .. data:: prev

        **Since:** :doc:`2.4.1 </release/2.4.1>`

        Get the previous error for the current one.

        :rtype: error_object

        **See also:** :ref:`Error lists <box_error_error_lists>`

    .. _box_error-code:

    .. data:: code

        The error code.
        This attribute may return a :ref:`custom error <box_error_raise_custom_table_error>` code or a :ref:`Tarantool error <box_error_raise_tarantool_error>` code.

        :rtype: number

    .. _box_error-type:

    .. data:: type

        The error type.

        :rtype: string

        **See also:** :ref:`Custom error <box_error_raise_custom_error>`

    .. _box_error-message:

    .. data:: message

        The error message.

        :rtype: string

    .. _box_error-trace:

    .. data:: trace

        The error trace.

        :rtype: table

    .. _box_error-errno:

    .. data:: errno

        If the error is a system error (for example, a socket or file IO failure),
        returns a C standard error number.

        :rtype: number

    .. _box_error-reason:

    .. data:: reason

        **Since:** :doc:`2.10.0 </release/2.10.0>`

        Returns the :ref:`box.info.ro_reason <box_introspection-box_info>` value at the moment of throwing the ``box.error.READONLY`` error.

        The following values may be returned:

        -   ``election`` if the instance has :ref:`box.cfg.election_mode <cfg_replication-election_mode>` set to a value other than ``off`` and this instance is not a leader.
            In this case, ``error_object`` may include the following attributes: ``state``, ``leader_id``, ``leader_uuid``, and ``term``.
        -   ``synchro`` if the synchronous queue has an owner that is not the given instance.
            This error usually happens if :ref:`synchronous replication <repl_sync>` is used and another instance is called :ref:`box.ctl.promote() <box_ctl-promote>`.
            In this case, ``error_object`` may include the ``queue_owner_id``, ``queue_owner_uuid``, and ``term`` attributes.
        -   ``config`` if the :ref:`box.cfg.read_only <cfg_basic-read_only>` is set to ``true``.
        -   ``orphan`` if the instance is in the :ref:`orphan <replication-orphan_status>` state.

        .. NOTE::

            If multiple reasons are true at the same time, then only one is returned in the following order of preference: ``election``, ``synchro``, ``config``, ``orphan``.

        :rtype: string

    .. _box_error-state:

    .. data:: state

        **Since:** :doc:`2.10.0 </release/2.10.0>`

        For the ``box.error.READONLY`` error, returns the current state of a replica set node in regards to leader election (see :ref:`box.info.election.state <box_info_election>`).
        This attribute presents if the :ref:`error reason <box_error-reason>` is ``election``.

        :rtype: string

    .. _box_error-leader_id:

    .. data:: leader_id

        **Since:** :doc:`2.10.0 </release/2.10.0>`

        For the ``box.error.READONLY`` error, returns a numeric identifier (:ref:`box.info.id <box_introspection-box_info>`) of the replica set leader.
        This attribute may present if the :ref:`error reason <box_error-reason>` is ``election``.

        :rtype: number

    .. _box_error-leader_uuid:

    .. data:: leader_uuid

        **Since:** :doc:`2.10.0 </release/2.10.0>`

        For the ``box.error.READONLY`` error, returns a globally unique identifier (:ref:`box.info.uuid <box_introspection-box_info>`) of the replica set leader.
        This attribute may present if the :ref:`error reason <box_error-reason>` is ``election``.

    .. _box_error-queue_owner_id:

    .. data:: queue_owner_id

        **Since:** :doc:`2.10.0 </release/2.10.0>`

        For the ``box.error.READONLY`` error, returns a numeric identifier (:ref:`box.info.id <box_introspection-box_info>`) of the synchronous queue owner.
        This attribute may present if the :ref:`error reason <box_error-reason>` is ``synchro``.

        :rtype: number

    .. _box_error-queue_owner_uuid:

    .. data:: queue_owner_uuid

        **Since:** :doc:`2.10.0 </release/2.10.0>`

        For the ``box.error.READONLY`` error, returns a globally unique identifier (:ref:`box.info.uuid <box_introspection-box_info>`) of the synchronous queue owner.
        This attribute may present if the :ref:`error reason <box_error-reason>` is ``synchro``.

    .. _box_error-term:

    .. data:: term

        **Since:** :doc:`2.10.0 </release/2.10.0>`

        For the ``box.error.READONLY`` error, returns the current election term (see :ref:`box.info.election.term <box_info_election>`).
        This attribute may present if the :ref:`error reason <box_error-reason>` is ``election`` or ``synchro``.
