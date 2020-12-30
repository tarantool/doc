.. _box_space-vuser:

===============================================================================
box.space._vuser
===============================================================================

.. module:: box.space

.. data:: _vuser

    ``_vuser`` is a system space that represents a virtual view. The structure
    of its tuples is identical to that of :ref:`_user <box_space-user>`, but
    permissions for certain tuples are limited in accordance with user privileges.
    ``_vuser`` contains only those tuples that are accessible to the current user.
    See :ref:`Access control <authentication>` for details about user privileges.

    If the user has the full set of privileges (like 'admin'), the contents
    of ``_vuser`` match the contents of ``_user``. If the user has limited
    access, ``_vuser`` contains only tuples accessible to this user.

    To see how ``_vuser`` works,
    :ref:`connect to a Tarantool database remotely <connecting-remotely>`
    via ``tarantoolctl`` and select all tuples from the ``_user``
    space, both when the 'guest' user *is* and *is not* allowed to read from the
    database.

    First, start Tarantool and grant the 'guest' user with read, write and execute
    privileges:

    .. code-block:: tarantoolsession

        tarantool> box.cfg{listen = 3301}
        ---
        ...
        tarantool> box.schema.user.grant('guest', 'read,write,execute', 'universe')
        ---
        ...

    Switch to the other terminal, connect to the Tarantool instance and select all
    tuples from the ``_user`` space:

    .. code-block:: tarantoolsession

        $ tarantoolctl connect 3301
        localhost:3301> box.space._user:select{}
        ---
        - - [0, 1, 'guest', 'user', {}]
          - [1, 1, 'admin', 'user', {}]
          - [2, 1, 'public', 'role', {}]
          - [3, 1, 'replication', 'role', {}]
          - [31, 1, 'super', 'role', {}]
        ...

    This result contains the same set of users as if you made the request from your
    Tarantool instance as 'admin'.

    Switch to the first terminal and revoke the read privileges from the 'guest' user:

    .. code-block:: tarantoolsession

        tarantool> box.schema.user.revoke('guest', 'read', 'universe')
        ---
        ...

    Switch to the other terminal, stop the session (to stop ``tarantoolctl``, type Ctrl+C
    or Ctrl+D) and repeat the ``box.space._user:select{}`` request. The access is
    denied:

    .. code-block:: tarantoolsession

        $ tarantoolctl connect 3301
        localhost:3301> box.space._user:select{}
        ---
        - error: Read access to space '_user' is denied for user 'guest'
        ...

    However, if you select from ``_vuser`` instead, the users' data available for the
    'guest' user is displayed:

    .. code-block:: tarantoolsession

        localhost:3301> box.space._vuser:select{}
        ---
        - - [0, 1, 'guest', 'user', {}]
        ...

    .. NOTE::

        * ``_vuser`` is a system view, so it allows only read requests.
        * While the ``_user`` space requires proper access privileges, any user
          can always read from ``_vuser``.
