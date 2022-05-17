.. _box_space-func:

===============================================================================
box.space._func
===============================================================================

.. module:: box.space

.. data:: _func

   ``_func`` is a system space with function tuples made by
   :ref:`box.schema.func.create() <box_schema-func_create>`
   or
   :ref:`box.schema.func.create(func-name [, {options-with-body}]) <box_schema-func_create_with-body>`.

   Tuples in this space contain the following fields:

   * id (integer identifier)
   * owner (integer identifier)
   * the function name
   * the setuid flag
   * a language name (optional): 'LUA' (default) or 'C'
   * the body
   * the is_deterministic flag
   * the is_sandboxed flag
   * options.

   If the function tuple was made in the older way without specification of ``body``,
   then the ``_func`` space will contain default values for the body and the
   is_deterministic flag and the is_sandboxed flag.
   Such function tuples are called "not persistent".
   You continue to create Lua functions in the usual way, by saying
   ``function function_name () ... end``, without adding anything
   in the ``_func`` space. The ``_func`` space only exists for storing
   function tuples so that their names can be used within
   :ref:`grant/revoke <authentication-owners_privileges>`
   functions.

   If the function tuple was made the newer way with specification of ``body``,
   then all the fields may contain non-default values.
   Such functions are called "persistent".
   They should be invoked with :samp:`box.func.{func-name}:call([parameters])`.

   You can:

   * Create a ``_func`` tuple with
     :doc:`/reference/reference_lua/box_schema/func_create`.
   * Drop a ``_func`` tuple with
     :doc:`/reference/reference_lua/box_schema/func_drop`.
   * Check whether a ``_func`` tuple exists with
     :doc:`/reference/reference_lua/box_schema/func_exists`.

   **Example:**

   In the following example, we create a function named ‘f7’, put it into
   Tarantool's ``_func`` space and grant 'execute' privilege for this function
   to 'guest' user.

   .. code-block:: tarantoolsession

      tarantool> function f7()
               >  box.session.uid()
               > end
      ---
      ...
      tarantool> box.schema.func.create('f7')
      ---
      ...
      tarantool> box.schema.user.grant('guest', 'execute', 'function', 'f7')
      ---
      ...
      tarantool> box.schema.user.revoke('guest', 'execute', 'function', 'f7')
      ---
      ...
      
   The :ref:`system space view <box_space-sysviews>` for ``_func`` is ``_vfunc``.

