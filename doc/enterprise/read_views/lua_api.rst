.. _read_views_lua_api:

Read views: Lua API
===================

This topic describes the Lua API for working with :ref:`read views <read_views>`.

..  _box-read_view-open:

..  function:: box.read_view:open({opts})

    Create a :ref:`new read view <creating_read_view>`.

    :param table opts:  (optional) configurations options for a read view.
                        For example, the ``name`` option specifies a read view name.
                        If ``name`` is not specified, a read view name is set to ``unknown``.

    :return: a created read view object
    :rtype: read_view_object

    **Example:**

    ..  code-block:: tarantoolsession

        tarantool> read_view1 = box.read_view.open({name = 'read_view1'})



..  class:: read_view_object

    An object that represents a :ref:`read view <read_views>`.

    ..  _read_view_object-info:

    ..  method:: read_view_object:info()

        Get information about a read view such as a name, status, or ID.
        All the available fields are listed below in the object options.

        :return: information about a read view
        :rtype: table

    ..  _read_view_object-close:

    ..  method:: read_view_object:close()

        Close a read view.
        After the read view is closed, its :ref:`status <read_view_object-status>` is set to ``closed``.
        On an attempt to use it, an error is raised.

    ..  _read_view_object-status:

    ..  data:: status

        A read view status.
        The possible values are ``open`` and ``closed``.

        :rtype: string

    ..  _read_view_object-id:

    ..  data:: id

        A unique numeric identifier of a read view.

        :rtype: number

    ..  _read_view_object-name:

    ..  data:: name

        A read view name.
        You can specify a read view name in the :ref:`box.read_view.open() <box-read_view-open>` arguments.

        :rtype: string

    ..  _read_view_object-is_system:

    ..  data:: is_system

        Determine whether a read view is system.
        For example, system read views can be created to make a :ref:`checkpoint <book_cfg_checkpoint_daemon>`
        or join a new :ref:`replica <replication-architecture>`.

        :rtype: boolean

    ..  _read_view_object-timestamp:

    ..  data:: timestamp

        The :ref:`fiber.clock() <fiber-clock>` value at the moment of opening a read view.

        :rtype: number

    ..  _read_view_object-vclock:

    ..  data:: vclock

        The :ref:`box.info.vclock <box_introspection-box_info>` value at the moment of opening a read view.

        :rtype: table

    ..  _read_view_object-signature:

    ..  data:: signature

        The :ref:`box.info.signature <box_introspection-box_info>` value at the moment of opening a read view.

        :rtype: number

    ..  _read_view_object-space:

    ..  data:: space

        Get access to database spaces included in a read view.
        You can use this field to :ref:`query space data <querying_data>`.

        :rtype: space object
