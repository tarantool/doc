.. _triggers:
.. _triggers-box_triggers:

================================================================================
Triggers
================================================================================

**Triggers**, also known as **callbacks**, are functions which the server
executes when certain events happen.

There are three types of triggers in Tarantool:

* :ref:`connection triggers <box_session-on_connect>`, which are executed
  when a session begins or ends, 

* :ref:`authentication triggers <box_session-on_auth>`, which are
  executed during authentication, and

* :ref:`replace triggers <box_space-on_replace>`, which are for database
  events.

All triggers have the following characteristics:

* Triggers associate a function with an event.
  The request to "define a trigger" implies passing the
  trigger’s function to one of the "on_event-name()" functions:
  :ref:`box.session.on_connect() <box_session-on_connect>`,
  :ref:`box.session.on_auth() <box_session-on_auth>`, 
  :ref:`box.session.on_disconnect() <box_session-on_disconnect>`, or 
  :ref:`space_object:on_replace() <box_space-on_replace>`.

* Triggers are defined only by the 'admin' user.

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
  :ref:`box.rollback() <box-rollback>` in a trigger function would be
  bringing in requests outside the event context.

* Triggers are replaceable. The request to "redefine a trigger" implies
  passing a new trigger function and an old trigger function
  to one of the "on_event-name()" functions.

* The "on_event_name()" functions all have parameters which are function
  pointers, and they all return function pointers. Remember that a Lua
  function definition such as "function f() x = x + 1 end" is the same
  as "f = function () x = x + 1 end" -- in both cases ``f`` gets a function pointer.
  And "trigger = box.session.on_connect(f)" is the same as
  "trigger = box.session.on_connect(function () x = x + 1 end)" -- in both cases
  ``trigger`` gets the function pointer which was passed.

To get a list of triggers, you can use:

* on_connect() – with no arguments – to return a table of all connect-trigger functions;
* on_auth() to return all authentication-trigger functions;
* on_disconnect() to return all disconnect-trigger functions;
* on_replace() to return all replace-trigger functions.

**Example**

Here we log connect and disconnect events into Tarantool server log.

.. code-block:: lua_tarantool

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
