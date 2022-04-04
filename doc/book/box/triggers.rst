:fullwidth:

.. _triggers:
.. _triggers-box_triggers:

================================================================================
Triggers
================================================================================

**Triggers**, also known as **callbacks**, are functions which the server
executes when certain events happen.

To associate an event with a callback,
one should pass the callback to the corresponding :samp:`on_{event}` function:

* :doc:`/reference/reference_lua/box_session/on_connect` or
  :doc:`/reference/reference_lua/box_session/on_disconnect`,
* :doc:`/reference/reference_lua/box_session/on_auth`,
* :doc:`/reference/reference_lua/box_space/on_replace` or
  :doc:`/reference/reference_lua/box_space/before_replace`,
* :doc:`/reference/reference_lua/box_txn_management/on_commit` or
  :doc:`/reference/reference_lua/box_txn_management/on_rollback`,
* :ref:`net.box.on_connect() <net_box-on_connect>` or
  :ref:`net.box.on_disconnect() <net_box-on_disconnect>`,
* :ref:`net.box.on_schema_reload() <net_box-on_schema_reload>`,
* :doc:`/reference/reference_lua/box_ctl/on_schema_init` or
  :doc:`/reference/reference_lua/box_ctl/on_shutdown`,
* :ref:`swim_object:on_member_event() <swim-on_member_event>`,
* :doc:`/reference/reference_lua/box_session/on_access_denied`.

Then the server will store the callback function and call it
when the corresponding event happens.

All triggers have the following characteristics:

* Triggers are defined only by the :ref:`'admin' user <authentication-owners_privileges>`.

* Triggers are stored in the Tarantool instance's memory, not in the database.
  Therefore triggers disappear when the instance is shut down.
  To make them permanent, put function definitions and trigger settings
  into Tarantool's :ref:`initialization script <index-init_label>`.

* Triggers have low overhead. If a trigger is not defined, then the overhead
  is minimal: merely a pointer dereference and check. If a trigger is defined,
  then its overhead is equivalent to the overhead of calling a function.

* There can be multiple triggers for one event. In this case, triggers are
  executed in the reverse order that they were defined in.

* Triggers must work within the event context. However, effects are undefined
  if a function contains requests which normally could not occur immediately
  after the event, but only before the return from the event. For example, putting
  `os.exit() <http://www.lua.org/manual/5.1/manual.html#pdf-os.exit>`_ or
  :doc:`/reference/reference_lua/box_txn_management/rollback` in a trigger
  function would be bringing in requests outside the event context.

* Triggers are replaceable. The request to "redefine a trigger" implies
  passing a new trigger function and an old trigger function
  to one of the :samp:`on_{event}` functions.

* The :samp:`on_{event}` functions all have parameters which are function
  pointers, and they all return function pointers. Remember that a Lua
  function definition such as ``function f() x = x + 1 end`` is the same
  as ``f = function () x = x + 1 end`` - in both cases ``f`` gets a function pointer.
  And ``trigger = box.session.on_connect(f)`` is the same as
  ``trigger = box.session.on_connect(function () x = x + 1 end)`` - in both cases
  ``trigger`` gets the function pointer which was passed.

* You can call any :samp:`on_{event}` function with no arguments to get a list
  of its triggers. For example, use ``box.session.on_connect()`` to return
  a table of all connect-trigger functions.

* Triggers can be useful in solving problems with replication. See details in
  :ref:`Resolving replication conflicts <replication-problem_solving>`.

**Example:**

Here we log connect and disconnect events into Tarantool server log.

..  code-block:: lua

    log = require('log')

    function on_connect_impl()
     log.info("connected "..box.session.peer()..", sid "..box.session.id())
    end

    function on_disconnect_impl()
     log.info("disconnected, sid "..box.session.id())
    end

    function on_auth_impl(user)
     log.info("authenticated sid "..box.session.id().." as "..user)
    end

    function on_connect() pcall(on_connect_impl) end
    function on_disconnect() pcall(on_disconnect_impl) end
    function on_auth(user) pcall(on_auth_impl, user) end

    box.session.on_connect(on_connect)
    box.session.on_disconnect(on_disconnect)
    box.session.on_auth(on_auth)
