.. _box_space-func:

===============================================================================
box.space._func
===============================================================================

.. module:: box.space

.. data:: _func

   ``_func`` is a system space with function tuples made by
   :ref:`box.schema.func.create() <box_schema-func_create>`.

   Tuples in this space contain the following fields:

   * the numeric function id, a number,
   * the function name,
   * flag,
   * a language name (optional): 'LUA' (default) or 'C'.

   The ``_func`` space does not include the function’s body.
   You continue to create Lua functions in the usual way, by saying
   ``function function_name () ... end``, without adding anything
   in the ``_func`` space. The ``_func`` space only exists for storing
   function tuples so that their names can be used within
   :ref:`grant/revoke <authentication-owners_privileges>`
   functions.

   You can:

   * Create a ``_func`` tuple with
     :ref:`box.schema.func.create() <box_schema-func_create>`,
   * Drop a ``_func`` tuple with
     :ref:`box.schema.func.drop() <box_schema-func_drop>`,
   * Check whether a ``_func`` tuple exists with
     :ref:`box.schema.func.exists() <box_schema-func_exists>`.

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
