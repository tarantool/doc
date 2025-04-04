..  _box_session-euid:

box.session.euid()
==================

.. module:: box.session

.. function:: euid()

    :return: the :ref:`effective user <box_session-effective_user>` ID of the :ref:`current user <authentication-users>`.

    The system uses the effective user ID to determine the process's permissions at any given moment.
    This is the same as :doc:`/reference/reference_lua/box_session/uid`, except
    two cases:

    * ``box.session.euid()`` is called within
      a function invoked by
      :doc:`box.session.su() </reference/reference_lua/box_session/su>`.
      In this case:

      - ``box.session.euid()`` returns the ID of the changed user
      (the user who is specified by the ``user-name`` parameter of the ``box.session.su()`` function).
      - ``box.session.uid()`` returns the ID of the original user
      (the user who calls the ``box.session.su()`` function).

    * ``box.session.euid()`` is called within
      a function specified with
      :doc:`box.schema.func.create(function-name, {setuid= true}) </reference/reference_lua/box_schema/func_create>`
      and the binary protocol is in use.
      In this case:

      - ``box.session.euid()`` returns the ID of the user who created ``function-name``.
      - ``box.session.uid()`` returns the ID of the user who calls ``function-name``.

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