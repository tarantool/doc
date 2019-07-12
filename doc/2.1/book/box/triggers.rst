.. _triggers:
.. _triggers-box_triggers:

================================================================================
Triggers
================================================================================

**Triggers**, also known as **callbacks**, are functions which the server
executes when certain events happen.

There are six types of triggers in Tarantool:

* :ref:`connection triggers <box_session-on_connect>`, which are executed
  when a session begins or ends,

* :ref:`authentication triggers <box_session-on_auth>`, which are
  executed during authentication,

* :ref:`replace triggers <box_space-on_replace>`, which are for database
  events,

* :ref:`transaction triggers <box-on_commit>`, which are executed
  during commit or rollback,

* :ref:`server triggers <box_ctl-on_schema_init>`, which are executed
  when the server starts or stops.

* :ref:`member triggers <swim-on_member_event>`, which are executed
  when a SWIM member is updated.


All triggers have the following characteristics:

* Triggers associate a function with an event.
  The request to "define a trigger" implies passing the
  trigger’s function to one of the "on_event()" functions:

  * :ref:`box.session.on_connect() <box_session-on_connect>` and :ref:`box.session.on_disconnect() <box_session-on_disconnect>`, or
  * :ref:`box.session.on_auth() <box_session-on_auth>`, or
  * :ref:`space_object:on_replace() <box_space-on_replace>` and :ref:`space_object:before_replace() <box_space-before_replace>`, or
  * :ref:`box.on_commit() <box-on_commit>` and :ref:`box.on_rollback() <box-on_rollback>`, or
  * :ref:`box.ctl.on_schema_init() <box_ctl-on_schema_init>` and :ref:`box.ctl.on_shutdown() <box_ctl-on_shutdown>`, or
  * :ref:`swim_object:on_member_event() <swim-on_member_event>`.

* Triggers are defined only by the :ref:`'admin' user <authentication-owners_privileges>`.

* Triggers are stored in the Tarantool instance's memory, not in the database.
  Therefore triggers disappear when the instance is shut down.
  To make them permanent, put function definitions and trigger settings
  into Tarantool's :ref:`initialization script <index-init_label>`.

* Triggers have low overhead. If a trigger is not defined, then the overhead
  is minimal: merely a pointer dereference and check. If a trigger is defined,
  then its overhead is equivalent to the overhead of calling a function.

* There can be multiple triggers for one event. In this case, triggers are
  executed in the reverse order that they were defined in. (Exception:
  member triggers are executed in the order that they appear in the member list.)

* Triggers must work within the event context. However, effects are undefined
  if a function contains requests which normally could not occur immediately
  after the event, but only before the return from the event. For example, putting
  `os.exit() <http://www.lua.org/manual/5.1/manual.html#pdf-os.exit>`_ or
  :ref:`box.rollback() <box-rollback>` in a trigger function would be
  bringing in requests outside the event context.

* Triggers are replaceable. The request to "redefine a trigger" implies
  passing a new trigger function and an old trigger function
  to one of the "on_event()" functions.

* The "on_event()" functions all have parameters which are function
  pointers, and they all return function pointers. Remember that a Lua
  function definition such as "function f() x = x + 1 end" is the same
  as "f = function () x = x + 1 end" -- in both cases ``f`` gets a function pointer.
  And "trigger = box.session.on_connect(f)" is the same as
  "trigger = box.session.on_connect(function () x = x + 1 end)" -- in both cases
  ``trigger`` gets the function pointer which was passed.

To get a list of triggers, you can use:

* box.session.on_connect() – with no arguments – to return a table of all connect-trigger functions;
* box.session.on_auth() to return all authentication-trigger functions;
* box.session.on_disconnect() to return all disconnect-trigger functions;
* space_object:on_replace() to return all replace-trigger functions made for on_replace().
* space_object:before_replace() to return all replace-trigger functions made for before_replace().
* box.ctl.on_shutdown() to return all shutdown-trigger functions made for on_shutdown().
* box.ctl.on_schema_init() to return all initialization-trigger functions made for on_schema_init().
* swim_object:on_member_event() to return all member triggers made for on_member_event().

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
   end"

   function on_connect() pcall(on_connect_impl) end
   function on_disconnect() pcall(on_disconnect_impl) end
   function on_auth(user) pcall(on_auth_impl, user) end

   box.session.on_connect(on_connect)
   box.session.on_disconnect(on_disconnect)
   box.session.on_auth(on_auth)
