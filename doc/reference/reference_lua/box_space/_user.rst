.. _box_space-user:

===============================================================================
box.space._user
===============================================================================

.. module:: box.space

.. data:: _user

    ``_user`` is a system space where user-names and password hashes are stored.

    Tuples in this space contain the following fields:

    * the numeric id of the tuple ("id"),
    * the numeric id of the tuple’s creator,
    * the name,
    * the type: 'user' or 'role',
    * optional password.

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
        |             |    |      | Usually an untrusted user with few privileges.                 |
        +-------------+----+------+----------------------------------------------------------------+
        | admin       | 1  | user | Default user when using Tarantool as a console.                |
        |             |    |      | Usually an                                                     |
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
    For example, here is what happens with a select for user id = 0, which is
    the 'guest' user, which by default has no password:

    .. code-block:: tarantoolsession

        tarantool> box.space._user:select{0}
        ---
        - - [0, 1, 'guest', 'user']
        ...

    .. WARNING::

       To change tuples in the ``_user`` space, do not use ordinary ``box.space``
       functions for insert or update or delete. The ``_user`` space is special,
       so there are special functions which have appropriate error checking.

    To create a new user, use :doc:`/reference/reference_lua/box_schema/user_create`:

    .. code-block:: lua

        box.schema.user.create(*user-name*)
        box.schema.user.create(*user-name*, {if_not_exists = true})
        box.schema.user.create(*user-name*, {password = *password*})

    To change the user's password, use :doc:`/reference/reference_lua/box_schema/user_password`:

    .. code-block:: lua

        -- To change the current user's password
        box.schema.user.passwd(*password*)

        -- To change a different user's password
        -- (usually only 'admin' can do it)
        box.schema.user.passwd(*user-name*, *password*)

    To drop a user, use :doc:`/reference/reference_lua/box_schema/user_drop`:

    .. code-block:: lua

        box.schema.user.drop(*user-name*)

    To check whether a user exists, use :doc:`/reference/reference_lua/box_schema/user_exists`,
    which returns ``true`` or ``false``:

    .. code-block:: lua

        box.schema.user.exists(*user-name*)

    To find what privileges a user has, use :doc:`/reference/reference_lua/box_schema/user_info`:

    .. code-block:: lua

        box.schema.user.info(*user-name*)

    .. NOTE::

        The maximum number of users is 32.

    **Example:**

    Here is a session which creates a new user with a strong password, selects a
    tuple in the ``_user`` space, and then drops the user.

    .. code-block:: tarantoolsession

        tarantool> box.schema.user.create('JeanMartin', {password = 'Iwtso_6_os$$'})
        ---
        ...
        tarantool> box.space._user.index.name:select{'JeanMartin'}
        ---
        - - [17, 1, 'JeanMartin', 'user', {'chap-sha1': 't3xjUpQdrt857O+YRvGbMY5py8Q='}]
        ...
        tarantool> box.schema.user.drop('JeanMartin')
        ---
        ...

    The :ref:`system space view <box_space-sysviews>` for ``_user`` is ``_vuser``.
