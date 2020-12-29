
.. _box_session-euid:

================================================================================
box.session.euid()
================================================================================

.. module:: box.session

.. function:: euid()

    :return: the effective user ID of the :ref:`current user <authentication-users>`.

    This is the same as :ref:`box.session.uid() <box_session-uid>`, except
    in two cases:

    * The first case: if the call to ``box.session.euid()`` is within
      a function invoked by
      :ref:`box.session.su(user-name, function-to-execute) <box_session-su>`
      -- in that case, ``box.session.euid()`` returns the ID of the changed user
      (the user who is specified by the ``user-name`` parameter of the ``su``
      function)  but ``box.session.uid()`` returns the ID of the original user
      (the user who is calling the ``su`` function).

    * The second case: if the call to ``box.session.euid()`` is within
      a function specified with
      :doc:`box.schema.func.create(function-name, {setuid= true}) </reference/reference_lua/box_schema/func_create>`
      and the binary protocol is in use
      -- in that case, ``box.session.euid()`` returns the ID of the user who
      created "function-name" but ``box.session.uid()`` returns the ID of the
      the user who is calling "function-name".

    :rtype: number

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> box.session.su('admin')
        ---
        ...
        tarantool> box.session.uid(), box.session.euid()
        ---
        - 1
        - 1
        ...
        tarantool> function f() return {box.session.uid(),box.session.euid()} end
        ---
        ...
        tarantool> box.session.su('guest', f)
        ---
        - - 1
          - 0
        ...