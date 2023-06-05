.. _reference_lua-box_read_view_list:

===============================================================================
box.read_view.list()
===============================================================================

.. function:: read_view.list()

    Return an array of all active database read views.
    This array might include the following read view types:

    *   `read views <https://www.tarantool.io/en/enterprise_doc/read_views/>`_ created by application code (available in Tarantool Enterprise only)

    *   system read views (used, for example, to make a :ref:`checkpoint <book_cfg_checkpoint_daemon>`
        or join a new :ref:`replica <replication-architecture>`)

    Read views created by application code also have the ``space`` field.
    The field lists all spaces available in a read view,
    and may be used like a read view object returned by ``box.read_view.open()``.

    .. NOTE::

        ``read_view.list()`` also contains read views created using the
        `C API <https://www.tarantool.io/en/enterprise_doc/read_views/c_api/>`_ (``box_raw_read_view_new()``).
        Note that you cannot access database spaces included in such views from Lua.


    **Example:**

    .. code-block:: tarantoolsession

        tarantool> box.read_view.list()
        ---
        - - timestamp: 1138.98706933
            signature: 47
            is_system: false
            status: open
            vclock: &0 {1: 47}
            name: read_view1
            id: 1
          - timestamp: 1172.202995842
            signature: 49
            is_system: false
            status: open
            vclock: &1 {1: 49}
            name: read_view2
            id: 2
        ...