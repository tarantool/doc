.. _box_schema-space_create:

===============================================================================
box.schema.space.create()
===============================================================================

.. module:: box.schema

.. function:: box.schema.space.create(space-name [, {options}])
              box.schema.create_space(space-name [, {options}])

    Create a :ref:`space <index-box_space>`.

    :param string space-name: name of space, which should
                              conform to the :ref:`rules for object names <app_server-names>`
    :param table options: see "Options for box.schema.space.create" chart, below

    :return: space object
    :rtype: userdata

    You can use either syntax. For example,
    ``s = box.schema.space.create('tester')`` has the same effect as
    ``s = box.schema.create_space('tester')``.

    .. container:: table

        **Options for box.schema.space.create**

        .. rst-class:: left-align-column-1
        .. rst-class:: left-align-column-2
        .. rst-class:: left-align-column-3
        .. rst-class:: left-align-column-4

        .. tabularcolumns:: |\Y{0.2}|\Y{0.4}|\Y{0.2}|\Y{0.2}|

        +---------------+----------------------------------------------------+---------+---------------------+
        | Name          | Effect                                             | Type    | Default             |
        +===============+====================================================+=========+=====================+
        | constraint    | constraints that space tuples must satisfy.        | table   | (blank)             |
        |               | See :ref:`Constraints <index-constraints>` for     |         |                     |
        |               | details.                                           |         |                     |
        +---------------+----------------------------------------------------+---------+---------------------+
        | engine        | 'memtx' or 'vinyl'                                 | string  | 'memtx'             |
        +---------------+----------------------------------------------------+---------+---------------------+
        | field_count   | fixed count of :ref:`fields <index-box_tuple>`:    | number  | 0 i.e. not fixed    |
        |               | for example if                                     |         |                     |
        |               | field_count=5, it is illegal                       |         |                     |
        |               | to insert a tuple with fewer                       |         |                     |
        |               | than or more than 5 fields                         |         |                     |
        +---------------+----------------------------------------------------+---------+---------------------+
        | foreign_key   | foreign keys for space fields.                     | table   | (blank)             |
        |               | See :ref:`Foreign keys <index-box_foreign_keys>`   |         |                     |
        |               | for details.                                       |         |                     |
        +---------------+----------------------------------------------------+---------+---------------------+
        | format        | field names and types:                             | table   | (blank)             |
        |               | See the illustrations of format clauses in the     |         |                     |
        |               | :ref:`space_object:format() <box_space-format>`    |         |                     |
        |               | description and in the                             |         |                     |
        |               | :ref:`box.space._space <box_space-space>`          |         |                     |
        |               | example. Optional and usually not specified.       |         |                     |
        +---------------+----------------------------------------------------+---------+---------------------+
        | id            | unique identifier:                                 | number  | last space's id, +1 |
        |               | users can refer to spaces with                     |         |                     |
        |               | the id instead of the name                         |         |                     |
        +---------------+----------------------------------------------------+---------+---------------------+
        | if_not_exists | create space only if a space                       | boolean | false               |
        |               | with the same name does not                        |         |                     |
        |               | exist already, otherwise do                        |         |                     |
        |               | nothing but do not cause an                        |         |                     |
        |               | error                                              |         |                     |
        +---------------+----------------------------------------------------+---------+---------------------+
        | is_local      | space contents are                                 | boolean | false               |
        |               | :ref:`replication-local <replication-local>`:      |         |                     |
        |               | changes are stored in the                          |         |                     |
        |               | :ref:`write-ahead log <internals-wal>`             |         |                     |
        |               | of the local node but there is no                  |         |                     |
        |               | :ref:`replication <replication>`.                  |         |                     |
        +---------------+----------------------------------------------------+---------+---------------------+
        | is_sync       | any transaction doing a DML request on this space  | boolean | false               |
        |               | becomes synchronous                                |         |                     |
        +---------------+----------------------------------------------------+---------+---------------------+
        | temporary     | space contents are temporary:                      | boolean | false               |
        |               | changes are not stored in the                      |         |                     |
        |               | :ref:`write-ahead log <internals-wal>`             |         |                     |
        |               | and there is no                                    |         |                     |
        |               | :ref:`replication <replication>`.                  |         |                     |
        |               | Note regarding storage engine: vinyl               |         |                     |
        |               | does not support temporary spaces.                 |         |                     |
        +---------------+----------------------------------------------------+---------+---------------------+
        | user          | name of the user who is considered to be           | string  | current user's name |
        |               | the space's                                        |         |                     |
        |               | :ref:`owner <authentication-owners_privileges>`    |         |                     |
        |               | for authorization purposes                         |         |                     |
        +---------------+----------------------------------------------------+---------+---------------------+

    .. _box_schema-space_create-options:

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

    There are three :ref:`syntax variations <app_server-object_reference>`
    for object references targeting space objects, for example
    :samp:`box.schema.space.drop({space-id})`
    will drop a space. However, the common approach is to use functions
    attached to the space objects, for example
    :ref:`space_object:drop() <box_space-drop>`.

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

    After a space is created, usually the next step is to
    :ref:`create an index <box_space-create_index>` for it, and then it is
    available for insert, select, and all the other :ref:`box.space <box_space>`
    functions.
