
.. _box_session-su:

================================================================================
box.session.su()
================================================================================

.. module:: box.session

.. function:: su(user-name [, function-to-execute])

    Change Tarantool's :ref:`current user <authentication-users>` --
    this is analogous to the Unix command ``su``.

    Or, if function-to-execute is specified,
    change Tarantool's :ref:`current user <authentication-users>`
    temporarily while executing the function --
    this is analogous to the Unix command ``sudo``.

    :param string user-name: name of a target user
    :param function-to-execute: name of a function, or definition of a function.
                                Additional parameters may be passed to
                                ``box.session.su``, they will be interpreted
                                as parameters of function-to-execute.

    **Example**

    .. code-block:: tarantoolsession

        tarantool> function f(a) return box.session.user() .. a end
        ---
        ...

        tarantool> box.session.su('guest', f, '-xxx')
        ---
        - guest-xxx
        ...

        tarantool> box.session.su('guest',function(...) return ... end,1,2)
        ---
        - 1
        - 2
        ...
