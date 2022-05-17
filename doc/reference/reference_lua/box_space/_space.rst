.. _box_space-space:

===============================================================================
box.space._space
===============================================================================

.. module:: box.space

.. data:: _space

    ``_space`` is a system space. It contains all spaces hosted on the current
    Tarantool instance, both system ones and created by users.

    Tuples in this space contain the following fields:

    * ``id``,
    * ``owner`` (= id of user who owns the space),
    * ``name``, ``engine``, ``field_count``,
    * ``flags`` (e.g. temporary),
    * ``format`` (as made by a :doc:`format clause </reference/reference_lua/box_space/format>`).

    These fields are established by :doc:`/reference/reference_lua/box_schema/space_create`.

    **Example #1:**

    The following function will display every simple field in all tuples of
    ``_space``.

    .. code-block:: lua

        function example()
          local ta = {}
          local i, line
          for k, v in box.space._space:pairs() do
            i = 1
            line = ''
            while i <= #v do
              if type(v[i]) ~= 'table' then
                line = line .. v[i] .. ' '
              end
            i = i + 1
            end
            table.insert(ta, line)
          end
          return ta
        end

    Here is what ``example()`` returns in a typical installation:

    .. code-block:: tarantoolsession

        tarantool> example()
        ---
        - - '272 1 _schema memtx 0  '
          - '280 1 _space memtx 0  '
          - '281 1 _vspace sysview 0  '
          - '288 1 _index memtx 0  '
          - '296 1 _func memtx 0  '
          - '304 1 _user memtx 0  '
          - '305 1 _vuser sysview 0  '
          - '312 1 _priv memtx 0  '
          - '313 1 _vpriv sysview 0  '
          - '320 1 _cluster memtx 0  '
          - '512 1 tester memtx 0  '
          - '513 1 origin vinyl 0  '
          - '514 1 archive memtx 0  '
        ...

    **Example #2:**

    The following requests will create a space using
    ``box.schema.space.create()`` with a :doc:`format clause </reference/reference_lua/box_space/format>`, then retrieve
    the ``_space`` tuple for the new space. This illustrates the typical use of
    the ``format`` clause, it shows the recommended names and data types for the
    fields.

    .. code-block:: tarantoolsession

        tarantool> box.schema.space.create('TM', {
                 >   id = 12345,
                 >   format = {
                 >     [1] = {["name"] = "field_1"},
                 >     [2] = {["type"] = "unsigned"}
                 >   }
                 > })
        ---
        - index: []
          on_replace: 'function: 0x41c67338'
          temporary: false
          id: 12345
          engine: memtx
          enabled: false
          name: TM
          field_count: 0
        - created
        ...
        tarantool> box.space._space:select(12345)
        ---
        - - [12345, 1, 'TM', 'memtx', 0, {}, [{'name': 'field_1'}, {'type': 'unsigned'}]]
        ...
        
    The :ref:`system space view <box_space-sysviews>` for ``_space`` is ``_vspace``.

