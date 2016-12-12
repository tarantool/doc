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

All of them are implemented as functions in Tarantool built-in libraries.

All triggers have the following characteristics:

* Triggers associate a function with an event.
  The request to "define a trigger" implies passing the name of the
  trigger’s function to one of the "on_event-name()" functions from the
  :ref:`box.session <box_session>` submodule: 
  :ref:`on_connect() <box_session-on_connect>`,
  :ref:`on_auth() <box_session-on_auth>`, 
  :ref:`on_disconnect() <box_session-on_disconnect>`, or 
  :ref:`on_replace() <box_space-on_replace>`.

* Triggers are defined only by the 'admin' user.

* Triggers are stored in the server's memory, not in the database.
  So, triggers disappear when the server is shut down.
  To make them permanent, put function definitions and trigger settings
  into Tarantool's :ref:`initialization script <index-init_label>`.

* Triggers have low overhead. If a trigger is not defined, then the overhead
  is minimal: merely a pointer dereference and check. If a trigger is defined,
  then its overhead is equivalent to the overhead of calling a stored procedure.

* There can be multiple triggers for one event. In this case, triggers are
  executed in the reverse order that they were defined in.

* Triggers must work within the event context. However, effects are undefined
  if a function contains requests which normally could not occur immediately
  after the event, but only before the return from the event. For example, putting
  `os.exit() <http://www.lua.org/manual/5.1/manual.html#pdf-os.exit>`_ or 
  :ref:`box.rollback() <box-rollback>` in a trigger function would be
  bringing in requests outside the event context.

* Triggers are replaceable. The request to "redefine a trigger" implies
  passing the names of a new trigger function and an old trigger function
  to one of the "on_event-name()" functions.

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
