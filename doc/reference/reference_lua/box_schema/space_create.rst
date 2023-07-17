.. _box_schema-space_create:

===============================================================================
box.schema.space.create()
===============================================================================

.. module:: box.schema

.. function:: box.schema.space.create(space-name [, {space_opts}])
              box.schema.create_space(space-name [, {space_opts}])

    Create a :ref:`space <index-box_space>`.
    You can use either syntax. For example,
    ``s = box.schema.space.create('tester')`` has the same effect as
    ``s = box.schema.create_space('tester')``.

    There are :ref:`three syntax variations <app_server-object_reference>`
    for object references targeting space objects, for example
    :samp:`box.schema.space.drop({space-id})`
    will drop a space. However, the common approach is to use functions
    attached to the space objects, for example
    :ref:`space_object:drop() <box_space-drop>`.

    After a space is created, usually the next step is to
    :ref:`create an index <box_space-create_index>` for it, and then it is
    available for insert, select, and all the other :ref:`box.space <box_space>`
    functions.

    :param string space-name: name of space, which should
                              conform to the :ref:`rules for object names <app_server-names>`
    :param table options: space options (see :ref:`space_opts <space_opts_object>`)

    :return: space object
    :rtype: userdata

.. _space_opts_object:

space_opts
----------

..  class:: space_opts

    Space options that include the space id, format, field count, constraints and
    foreign keys, and so on.
    These options are passed to the :ref:`box.schema.space.create() <box_schema-space_create>` method.

    .. NOTE::

    These options are also passed to :doc:`/reference/reference_lua/box_space/alter`.

    ..  _space_opts_if_not_exists:

    .. data:: if_not_exists

        Create space only if a space with the same name does not exist already.
        Otherwise, do nothing but do not cause an error.

        | Type: boolean
        | Default: ``false``

    ..  _space_opts_engine:

    .. data:: engine

        :ref:`Storage engine <engines-chapter>`.

        | Type: string
        | Default: `memtx`
        | Possible values: ``memtx``, ``vinyl``

    ..  _space_opts_id:

    .. data:: id

        A unique numeric identifier of the space: users can refer to spaces with
        this id instead of the name.

        | Type: number
        | Default: last space's ID + 1

    ..  _space_opts_field_count:

    .. data:: field_count

        Fixed count of :ref:`fields <index-box_tuple>`. For example, if ``field_count=5``,
        it is illegal to insert a tuple with fewer than or more than 5 fields.

        | Type: number
        | Default: ``0`` (not fixed)

    ..  _space_opts_user:

    .. data:: user

        The name of the user who is considered to be the space's :ref:`owner <authentication-owners_privileges>`
        for authorization purposes.

        | Type: string
        | Default: current user's name

    ..  _space_opts_format:

    .. data:: format

        Field names and types.
        See the illustrations of format clauses in the :ref:`space_object:format() <box_space-format>`
        description and in the :ref:`box.space._space <box_space-space>`
        example. Optional and usually not specified.

        | Type: table
        | Default: blank

    ..  _space_opts_is_local:

    .. data:: is_local

        Space contents are :ref:`replication-local <replication-local>`:
        changes are stored in the :ref:`write-ahead log <internals-wal>`
        of the local node but there is no :ref:`replication <replication>`.

        | Type: boolean
        | Default: ``false``

    ..  _space_opts_temporary:

    .. data:: temporary

        Space contents are temporary: changes are not stored in the :ref:`write-ahead log <internals-wal>`
        and there is no :ref:`replication <replication>`.

        .. note::

            Vinyl does not support temporary spaces.

        | Type: boolean
        | Default: ``false``

    ..  _space_opts_is_sync:

    .. data:: is_sync

        Any transaction doing a DML request on this space becomes synchronous.

        | Type: boolean
        | Default: ``false``

    ..  _space_opts_constraint:

    .. data:: constraint

        The :ref:`constraints <index-constraints>` that space tuples must satisfy.

        | Type: table
        | Default: blank

    ..  _space_opts_foreign_key:

    .. data:: foreign_key

        :ref:`Foreign keys <index-box_foreign_keys>` for space fields.

        | Type: table
        | Default: blank

    Saying ``box.cfg{read_only=true...}`` during :ref:`configuration <cfg_basic-read_only>`
    affects spaces differently depending on the options that were used during
    ``box.schema.space.create``, as summarized by this chart:

    .. container:: table

        +------------+-----------------+--------------------+----------------+----------------+
        | Option     | Can be created? | Can be written to? | Is replicated? | Is persistent? |
        +============+=================+====================+================+================+
        | (default)  | no              | no                 | yes            | yes            |
        +------------+-----------------+--------------------+----------------+----------------+
        | temporary  | no              | yes                | no             | no             |
        +------------+-----------------+--------------------+----------------+----------------+
        | is_local   | no              | yes                | no             | yes            |
        +------------+-----------------+--------------------+----------------+----------------+


    **Example:**

    .. code-block:: tarantoolsession

       tarantool> s = box.schema.space.create('space55')
       ---
       ...
       tarantool> s = box.schema.space.create('space55', {
                >   id = 555,
                >   temporary = false
                > })
       ---
       - error: Space 'space55' already exists
       ...
       tarantool> s = box.schema.space.create('space55', {
                >   if_not_exists = true
                > })
       ---
       ...
