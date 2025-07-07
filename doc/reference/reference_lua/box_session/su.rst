..  _box_session-su:

box.session.su()
================

..  module:: box.session

..  function:: su(user-name [, function-to-execute])

    Change Tarantool's :ref:`current user <authentication-users>` --
    this is analogous to the Unix command ``su``.

    Or, if the ``function-to-execute`` option is specified,
    change Tarantool's current user temporarily while executing the function --
    this is analogous to the Unix command ``sudo``.
    If the user is changed temporarily:

    - :ref:`box.session.user() <box_session-user>` ignores this change.
    - :ref:`box.session.effective_user() <box_session-effective_user>` shows this change.


    :param string user-name: name of a target user
    :param function-to-execute: a function object.
                                Additional parameters may be passed to
                                ``box.session.su()``, they will be interpreted
                                as parameters of ``function-to-execute``.

    **Example 1**

    Change Tarantool's current user to ``guest``:

    ..  code-block:: tarantoolsession

        app:instance001> box.session.su('guest')
        ---
        ...

    **Example 2**

    Change Tarantool's current user to ``temporary_user`` temporarily:

    ..  code-block:: tarantoolsession

        app:instance001> function get_current_user() return box.session.user() end
        ---
        ...

        app:instance001> function get_effective_user() return box.session.effective_user() end
        ---
        ...

        app:instance001> get_current_user()
        ---
        - admin
        ...

        app:instance001> box.session.su('temporary_user', get_current_user)
        ---
        - admin
        ...

        app:instance001> box.session.su('temporary_user', get_effective_user)
        ---
        - temporary_user
        ...

        app:instance001> box.session.su('temporary_user', get_effective_user, '-xxx')
        ---
        - temporary_user-xxx
        ...

        app:instance001> box.session.su('temporary_user', function(...) return box.session.user() end)
        ---
        - admin
        ...
