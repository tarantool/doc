.. _box_space-user:

===============================================================================
box.space._user
===============================================================================

.. module:: box.space

.. data:: _user

    ``_user`` is a system space where user names and password hashes are stored.
    Learn more about Tarantool's access control system from the :ref:`access_control` topic.

    Tuples in this space contain the following fields:

    * a numeric id of the tuple ("id")
    * a numeric id of the tuple’s creator
    * a name
    * a type: 'user' or 'role'
    * (optional) a password hash
    * (optional) an array of previous authentication data
    * (optional) a timestamp of the last password update

    There are five special tuples in the ``_user`` space: 'guest', 'admin',
    'public', 'replication', and 'super'.

    .. container:: table

        .. rst-class:: left-align-column-1
        .. rst-class:: right-align-column-2
        .. rst-class:: left-align-column-3
        .. rst-class:: left-align-column-4

        .. tabularcolumns:: |\Y{0.2}|\Y{0.1}|\Y{0.1}|\Y{0.6}|

        +-------------+----+------+----------------------------------------------------------------+
        | Name        | ID | Type | Description                                                    |
        +=============+====+======+================================================================+
        | guest       | 0  | user | Default user when connecting remotely.                         |
        |             |    |      | Usually, an untrusted user with few privileges.                |
        +-------------+----+------+----------------------------------------------------------------+
        | admin       | 1  | user | Default user when using Tarantool as a console.                |
        |             |    |      | Usually, an                                                    |
        |             |    |      | :ref:`administrative user <authentication-owners_privileges>`  |
        |             |    |      | with all privileges.                                           |
        +-------------+----+------+----------------------------------------------------------------+
        | public      | 2  | role | Pre-defined :ref:`role <authentication-roles>`,                |
        |             |    |      | automatically granted to new users when they are               |
        |             |    |      | created with                                                   |
        |             |    |      | ``box.schema.user.create(user-name)``.                         |
        |             |    |      | Therefore a convenient way to grant 'read' on space            |
        |             |    |      | 't' to every user that will ever exist is with                 |
        |             |    |      | ``box.schema.role.grant('public','read','space','t')``.        |
        +-------------+----+------+----------------------------------------------------------------+
        | replication | 3  | role | Pre-defined :ref:`role <authentication-roles>`,                |
        |             |    |      | which the 'admin' user can grant to users who need to use      |
        |             |    |      | :ref:`replication <replication>` features.                     |
        +-------------+----+------+----------------------------------------------------------------+
        | super       | 31 | role | Pre-defined :ref:`role <authentication-roles>`,                |
        |             |    |      | which the 'admin' user can grant to users who need all         |
        |             |    |      | privileges on all objects.                                     |
        |             |    |      | The 'super' role has these privileges on                       |
        |             |    |      | 'universe':                                                    |
        |             |    |      | read, write, execute, create, drop, alter.                     |
        +-------------+----+------+----------------------------------------------------------------+

    To select a tuple from the ``_user`` space, use ``box.space._user:select()``.
    In the example below, ``select`` is executed for a user with id = 0.
    This is the 'guest' user that has no password.

    .. code-block:: tarantoolsession

        tarantool> box.space._user:select{0}
        ---
        - - [0, 1, 'guest', 'user']
        ...

    .. WARNING::

        To change tuples in the ``_user`` space, do not use ordinary ``box.space`` functions for insert, update, or delete.
        Learn more from :ref:`access_control_users`.

    The :ref:`system space view <box_space-sysviews>` for ``_user`` is ``_vuser``.
