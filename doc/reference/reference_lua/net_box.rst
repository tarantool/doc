.. _net_box-module:

--------------------------------------------------------------------------------
Module `net.box`
--------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

The ``net.box`` module contains connectors to remote database systems. One
variant, to be discussed later, is for connecting to MySQL or MariaDB or PostgreSQL
(see :ref:`SQL DBMS modules <dbms_modules>` reference). The other variant, which
is discussed in this section, is for connecting to Tarantool server instances via a
network.

You can call the following methods:

* ``require('net.box')`` to get a ``net.box`` object
  (named ``net_box`` for examples in this section),
* ``net_box.connect()`` to connect and get a connection object
  (named ``conn`` for examples in this section),
* other ``net.box()`` routines, passing ``conn:``, to execute requests on
  the remote database system,
* ``conn:close`` to disconnect.

All ``net.box`` methods are fiber-safe, that is, it is safe to share and use the
same connection object across multiple concurrent fibers. In fact that is perhaps
the best programming practice with Tarantool. When multiple fibers use the same
connection, all requests are pipelined through the same network socket, but each
fiber gets back a correct response. Reducing the number of active sockets lowers
the overhead of system calls and increases the overall server performance. However
for some cases a single connection is not enough —- for example, when
it is necessary to prioritize requests or to use different authentication IDs.

.. _net_box-options:

Most ``net.box`` methods allow a final ``{options}`` argument, which can be:

* ``{timeout=...}``. For example, a method whose final argument is
  ``{timeout=1.5}`` will stop after 1.5 seconds on the local node, although this
  does not guarantee that execution will stop on the remote server node.
* ``{buffer=...}``. For an example see :ref:`buffer module <buffer-module>`.
* ``{is_async=...}``. For example, a method whose final argument is
  ``{is_async=true}`` will not wait for the result of a request. See the
  :ref:`is_async <net_box-is_async>` description.
* ``{on_push=... on_push_ctx=...}``. For receiving out-of-band messages.
  See the :ref:`box.session.push <box_session-push>` description.

The diagram below shows possible connection states and transitions:

.. ifconfig:: builder not in ('latex', )

    .. image:: net_states.svg
        :align: center
        :alt: net_states.svg

On this diagram:

* The state machine starts in the 'initial' state.

* ``net_box.connect()`` method changes the state to 'connecting' and spawns a worker fiber.

* If authentication and schema upload are required, it's possible later on to re-enter
  the 'fetch_schema' state from 'active' if a request fails due to a schema version
  mismatch error, so schema reload is triggered.

* ``conn.close()`` method sets the state to 'closed' and kills the worker.
  If the transport is already in the 'error' state, ``close()`` does nothing.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``net.box`` functions.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +----------------------------------------------------+---------------------------+
    | Name                                               | Use                       |
    +====================================================+===========================+
    | :ref:`net_box.connect()                            |                           |
    | <net_box-connect>` |br|                            | Create a connection       |
    | :ref:`net_box.new()                                |                           |
    | <net_box-new>` |br|                                |                           |
    | :ref:`net_box.self <net_box-self>`                 |                           |
    +----------------------------------------------------+---------------------------+
    | :ref:`conn:ping()                                  | Execute a PING command    |
    | <conn-ping>`                                       |                           |
    +----------------------------------------------------+---------------------------+
    | :ref:`conn:wait_connected()                        | Wait for a connection to  |
    | <conn-wait_connected>`                             | be active or closed       |
    +----------------------------------------------------+---------------------------+
    | :ref:`conn:is_connected()                          | Check if a connection     |
    | <conn-is_connected>`                               | is active or closed       |
    +----------------------------------------------------+---------------------------+
    | :ref:`conn:wait_state()                            | Wait for a target state   |
    | <conn-wait_state>`                                 |                           |
    +----------------------------------------------------+---------------------------+
    | :ref:`conn:close()                                 | Close a connection        |
    | <conn-close>`                                      |                           |
    +----------------------------------------------------+---------------------------+
    | :ref:`conn.space.space-name:select{field-value}    | Select one or more tuples |
    | <conn-select>`                                     |                           |
    +----------------------------------------------------+---------------------------+
    | :ref:`conn.space.space-name:get{field-value}       | Select a tuple            |
    | <conn-get>`                                        |                           |
    +----------------------------------------------------+---------------------------+
    | :ref:`conn.space.space-name:insert{field-value}    | Insert a tuple            |
    | <conn-insert>`                                     |                           |
    +----------------------------------------------------+---------------------------+
    | :ref:`conn.space.space-name:replace{field-value}   | Insert or replace a tuple |
    | <conn-replace>`                                    |                           |
    +----------------------------------------------------+---------------------------+
    | :ref:`conn.space.space-name:update{field-value}    | Update a tuple            |
    | <conn-update>`                                     |                           |
    +----------------------------------------------------+---------------------------+
    | :ref:`conn.space.space-name:upsert{field-value}    | Update a tuple            |
    | <conn-upsert>`                                     |                           |
    +----------------------------------------------------+---------------------------+
    | :ref:`conn.space.space-name:delete{field-value}    | Delete a tuple            |
    | <conn-delete>`                                     |                           |
    +----------------------------------------------------+---------------------------+
    | :ref:`conn:eval()                                  | Evaluate and execute the  |
    | <net_box-eval>`                                    | expression in a string    |
    +----------------------------------------------------+---------------------------+
    | :ref:`conn:call()                                  | Call a stored procedure   |
    | <net_box-call>`                                    |                           |
    +----------------------------------------------------+---------------------------+
    | :ref:`conn:timeout()                               | Set a timeout             |
    | <conn-timeout>`                                    |                           |
    +----------------------------------------------------+---------------------------+
    | :ref:`conn:on_connect()                            | Define a connect          |
    | <net_box-on_connect>`                              | trigger                   |
    +----------------------------------------------------+---------------------------+
    | :ref:`conn:on_disconnect()                         | Define a disconnect       |
    | <net_box-on_disconnect>`                           | trigger                   |
    +----------------------------------------------------+---------------------------+
    | :ref:`conn:on_schema_reload()                      | Define a trigger when     |
    | <net_box-on_schema_reload>`                        | schema is modified        |
    +----------------------------------------------------+---------------------------+
.. module:: net_box

.. _net_box-connect:

.. function:: connect(URI [, {option[s]}])

.. _net_box-new:

.. function:: new(URI [, {option[s]}])

    .. NOTE::

       The names ``connect()`` and ``new()`` are synonyms: ``connect()`` is
       preferred; ``new()`` is retained for backward compatibility.

    Create a new connection. The connection is established on demand, at the
    time of the first request. It can be re-established automatically after a
    disconnect (see ``reconnect_after`` option below).
    The returned ``conn`` object supports methods for making remote requests,
    such as select, update or delete.

    Possible options:

    * `user/password`: you have two ways to connect to a remote host:
      using :ref:`URI <index-uri>` or using the options `user` and `password`. For
      example, instead of ``connect('username:userpassword@localhost:33301')`` you
      can write ``connect('localhost:33301', {user = 'username', password='userpassword'})``.

    * `wait_connected`: by default, connection creation is blocked until the connection is established,
      but passing ``wait_connected=false`` makes it return immediately. Also, passing a timeout
      makes it wait before returning (e.g. ``wait_connected=1.5`` makes it wait at most 1.5 seconds).

      .. NOTE::

         If ``reconnect_after`` is greater than zero, then ``wait_connected`` ignores transient failures.
         The wait completes once the connection is established or is closed explicitly.

    * `reconnect_after`: if ``reconnect_after`` is greater than zero, then a ``net.box`` instance
      will try to reconnect if a connection is broken or if a connection attempt fails.
      This makes transient network failures become transparent to the application.
      Reconnect happens automatically in the background, so requests that
      initially fail due to connectivity loss are transparently retried.
      The number of retries is unlimited, connection attempts are made after each
      specified interval (for example ``reconnect_after=5`` means try to reconnect every 5 seconds).
      When a connection is explicitly closed, or when the Lua garbage collector
      removes it, then reconnect attempts stop.
      The default value of ``reconnect_after``, as with other ``connect`` options, is ``nil``.

    * `call_16`: [since 1.7.2] by default, ``net.box`` connections comply with a new
      binary protocol command for CALL, which is not backward compatible with previous versions.
      The new CALL no longer restricts a function to returning an array of tuples
      and allows returning an arbitrary MsgPack/JSON result, including scalars, nil and void (nothing).
      The old CALL is left intact for backward compatibility.
      It will be removed in the next major release.
      All programming language drivers will be gradually changed to use the new CALL.
      To connect to a Tarantool instance that uses the old CALL, specify ``call_16=true``.

    * `console`: depending on the option's value, the connection supports different methods
      (as if instances of different classes were returned). With ``console = true``, you can use
      ``conn`` methods ``close()``, ``is_connected()``, ``wait_state()``, ``eval()`` (in this case, both
      binary and Lua console network protocols are supported). With ``console = false`` (default), you can
      also use ``conn`` database methods (in this case, only the binary protocol is supported).
      Deprecation notice: ``console = true`` is deprecated, users should use
      :ref:`console.connect() <console-connect>` instead.

    * `connect_timeout`: number of seconds to wait before returning "error: Connection timed out".

    :param string URI: the :ref:`URI <index-uri>` of the target for the connection
    :param options: possible options are `user`, `password`, `wait_connected`,
                    `reconnect_after`, `call_16`, `console` and `connect_timeout`
    :return: conn object
    :rtype:  userdata

    **Examples:**

    .. code-block:: lua

        conn = net_box.connect('localhost:3301')
        conn = net_box.connect('127.0.0.1:3302', {wait_connected = false})
        conn = net_box.connect('127.0.0.1:3303', {reconnect_after = 5, call_16 = true})

.. _net_box-self:

.. class:: self

    For a local Tarantool server, there is a pre-created always-established
    connection object named :samp:`{net_box}.self`. Its purpose is to make
    polymorphic use of the ``net_box`` API easier. Therefore
    :samp:`conn = {net_box}.connect('localhost:3301')`
    can be replaced by :samp:`conn = {net_box}.self`.

    However, there is an important difference between the embedded connection
    and a remote one:

    * With the embedded connection, requests which do not modify data do not yield.
      When using a remote connection, due to
      :ref:`the implicit rules <atomic-implicit-yields>`
      any request can yield, and the database state may have changed by the
      time it regains control.

    * All the options passed to a request (as ``is_async``, ``on_push``, ``timeout``)
      will be ignored.

.. class:: conn

    .. _conn-ping:

    .. method:: ping([options])

        Execute a PING command.

        :param table options: the supported option is :samp:`timeout={seconds}`
        :return: true on success, false on error
        :rtype:  boolean

        **Example:**

        .. code-block:: lua

            net_box.self:ping({timeout = 0.5})

    .. _conn-wait_connected:

    .. method:: wait_connected([timeout])

        Wait for connection to be active or closed.

        :param number timeout: in seconds
        :return: true when connected, false on failure.
        :rtype:  boolean

        **Example:**

        .. code-block:: lua

            net_box.self:wait_connected()

    .. _conn-is_connected:

    .. method:: is_connected()

        Show whether connection is active or closed.

        :return: true if connected, false on failure.
        :rtype:  boolean

        **Example:**

        .. code-block:: lua

            net_box.self:is_connected()

    .. _conn-wait_state:

    .. method:: wait_state(state[s][, timeout])

        [since 1.7.2] Wait for a target state.

        :param string states: target states
        :param number timeout: in seconds
        :return: true when a target state is reached, false on timeout or connection closure
        :rtype:  boolean

        **Examples:**

        .. code-block:: lua

            -- wait infinitely for 'active' state:
            conn:wait_state('active')

            -- wait for 1.5 secs at most:
            conn:wait_state('active', 1.5)

            -- wait infinitely for either `active` or `fetch_schema` state:
            conn:wait_state({active=true, fetch_schema=true})

    .. _conn-close:

    .. method:: close()

        Close a connection.

        Connection objects are destroyed by the Lua garbage collector, just like any other objects in Lua, so
        an explicit destruction is not mandatory. However, since close() is a system
        call, it is good programming practice to close a connection explicitly when it
        is no longer needed, to avoid lengthy stalls of the garbage collector.

        **Example:**

        .. code-block:: lua

            conn:close()

    .. _conn-select:

    .. method:: conn.space.<space-name>:select({field-value, ...} [, {options}])

        :samp:`conn.space.{space-name}:select`:code:`({...})` is the remote-call equivalent
        of the local call :samp:`box.space.{space-name}:select`:code:`{...}`
        (:ref:`see details <box_space-select>`).

        **Example:**

        .. code-block:: lua

            conn.space.testspace:select({1,'B'}, {timeout=1})

        .. NOTE::

            Due to :ref:`the implicit yield rules <atomic-implicit-yields>`
            a local :samp:`box.space.{space-name}:select`:code:`{...}` does
            not yield, but a remote :samp:`conn.space.{space-name}:select`:code:`{...}`
            call does yield, so global variables or database tuples data may
            change when a remote :samp:`conn.space.{space-name}:select`:code:`{...}`
            occurs.

    .. _conn-get:

    .. method:: conn.space.<space-name>:get({field-value, ...} [, {options}])

        :samp:`conn.space.{space-name}:get(...)` is the remote-call equivalent
        of the local call :samp:`box.space.{space-name}:get(...)`
        (:ref:`see details <box_space-get>`).

        **Example:**

        .. code-block:: lua

            conn.space.testspace:get({1})

    .. _conn-insert:

    .. method:: conn.space.<space-name>:insert({field-value, ...} [, {options}])

        :samp:`conn.space.{space-name}:insert(...)` is the remote-call equivalent
        of the local call :samp:`box.space.{space-name}:insert(...)`
        (:ref:`see details <box_space-insert>`).

        **Example:**

        .. code-block:: lua

            conn.space.testspace:insert({2,3,4,5}, {timeout=1.1})

    .. _conn-replace:

    .. method:: conn.space.<space-name>:replace({field-value, ...} [, {options}])

        :samp:`conn.space.{space-name}:replace(...)` is the remote-call equivalent
        of the local call :samp:`box.space.{space-name}:replace(...)`
        (:ref:`see details <box_space-replace>`).

        **Example:**

        .. code-block:: lua

            conn.space.testspace:replace({5,6,7,8})

    .. _conn-update:

    .. method:: conn.space.<space-name>:update({field-value, ...} [, {options}])

        :samp:`conn.space.{space-name}:update(...)` is the remote-call equivalent
        of the local call :samp:`box.space.{space-name}:update(...)`
        (:ref:`see details <box_space-update>`).

        **Example:**

        .. code-block:: lua

            conn.space.Q:update({1},{{'=',2,5}}, {timeout=0})

    .. _conn-upsert:

    .. method:: conn.space.<space-name>:upsert({field-value, ...} [, {options}])

        :samp:`conn.space.{space-name}:upsert(...)` is the remote-call equivalent
        of the local call :samp:`box.space.{space-name}:upsert(...)`
        (:ref:`see details <box_space-upsert>`).

    .. _conn-delete:

    .. method:: conn.space.<space-name>:delete({field-value, ...} [, {options}])

        :samp:`conn.space.{space-name}:delete(...)` is the remote-call equivalent
        of the local call :samp:`box.space.{space-name}:delete(...)`
        (:ref:`see details <box_space-delete>`).

    .. _net_box-eval:

    .. method:: eval(Lua-string [, {arguments}, [ {options} ]])

        :samp:`conn:eval({Lua-string})` evaluates and executes the expression
        in Lua-string, which may be any statement or series of statements.
        An :ref:`execute privilege <authentication-owners_privileges>` is required;
        if the user does not have it, an administrator may grant it with
        :samp:`box.schema.user.grant({username}, 'execute', 'universe')`.

        To ensure that the return from ``conn:eval`` is whatever the Lua expression returns,
        begin the Lua-string with the word "return".

        **Examples:**

        .. code-block:: lua

            tarantool> --Lua-string
            tarantool> conn:eval('function f5() return 5+5 end; return f5();')
            ---
            - 10
            ...
            tarantool> --Lua-string, {arguments}
            tarantool> conn:eval('return ...', {1,2,{3,'x'}})
            ---
            - 1
            - 2
            - [3, 'x']
            ...
            tarantool> --Lua-string, {arguments}, {options}
            tarantool> conn:eval('return {nil,5}', {}, {timeout=0.1})
            ---
            - [null, 5]
            ...

    .. _net_box-call:

    .. method:: call(function-name, [, {arguments} [, {options} ]])

        ``conn:call('func', {'1', '2', '3'})`` is the remote-call equivalent of
        ``func('1', '2', '3')``. That is, ``conn:call`` is a remote
        stored-procedure call. The return from ``conn:call`` is whatever the function returns.

        Limitation: the called function cannot return a function, for example
        if ``func2`` is defined as ``function func2 () return func end`` then
        ``conn:call(func2)`` will return "error: unsupported Lua type 'function'".

        **Examples:**

        .. code-block:: lua

            tarantool> -- create 2 functions with conn:eval()
            tarantool> conn:eval('function f1() return 5+5 end;')
            tarantool> conn:eval('function f2(x,y) return x,y end;')
            tarantool> -- call first function with no parameters and no options
            tarantool> conn:call('f1')
            ---
            - 10
            ...
            tarantool> -- call second function with two parameters and one option
            tarantool> conn:call('f2',{1,'B'},{timeout=99})
            ---
            - 1
            - B
            ...



    .. _conn-timeout:

    .. method:: timeout(timeout)

        ``timeout(...)`` is a wrapper which sets a timeout for the request that
        follows it. Since version 1.7.4 this method is deprecated -- it is better
        to pass a timeout value for a method's ``{options}`` parameter.

        **Example:**

        .. code-block:: lua

            conn:timeout(0.5).space.tester:update({1}, {{'=', 2, 15}})

        Although ``timeout(...)`` is deprecated, all
        remote calls support its use. Using a wrapper object makes
        the remote connection API compatible with the local one, removing the need
        for a separate ``timeout`` argument, which the local version would ignore. Once
        a request is sent, it cannot be revoked from the remote server even if a
        timeout expires: the timeout expiration only aborts the wait for the remote
        server response, not the request itself.

    .. _net_box-is_async:

    .. method:: request(... {is_async=...})

        ``{is_async=true|false}`` is an option which is applicable for all
        ``net_box`` requests including ``conn:call``, ``conn:eval``, and the
        ``conn.space.space-name`` requests.

        The default is ``is_async=false``, meaning requests are synchronous
        for the fiber. The fiber is blocked, waiting until there is a
        reply to the request or until timeout expires. Before Tarantool
        version 1.10, the only way to make asynchronous requests was to
        put them in separate fibers.

        The non-default is ``is_async=true``, meaning requests are asynchronous
        for the fiber. The request causes a yield but there is no waiting.
        The immediate return is not the result of the request, instead it is
        an object that the calling program can use later to get the result of the
        request.

        This immediately-returned object, which we'll call "future",
        has its own methods:

        * ``future:is_ready()`` which will return true
          when the result of the request is available,
        * ``future:result()`` to get the result of the request (returns the
          response or **nil** in case it's not ready yet or there has been an error),
        * ``future:wait_result(timeout)`` to
          wait until the result of the request is available and then get it, or
          throw an error if there is no result after the timeout exceeded,
        * ``future:discard()`` to abandon the object.

        Typically a user would say ``future=request-name(...{is_async=true})``,
        then either loop checking ``future:is_ready()`` until it is true and
        then say ``request_result=future:result()``,
        or say ``request_result=future:wait_result(...)``.
        Alternatively the client could check for "out-of-band" messages from the server
        by calling ``pairs()`` in a loop -- see :ref:`box.session.push() <box_session-push>`.

        A user would say ``future:discard()`` to make a connection forget about the response --
        if a response for a discarded object is received then it will be ignored, so that
        the size of the requests table will be reduced and other requests will be faster.

        **Example:**

        .. code-block:: lua

            tarantool> future = conn.space.tester:insert({900},{is_async=true})
            ---
            ...
            tarantool> future
            ---
            - method: insert
              response: [900]
              cond: cond
              on_push_ctx: []
              on_push: 'function: builtin#91'
            ...
            tarantool> future:is_ready()
            ---
            - true
            ...
            tarantool> future:result()
            ---
            - [900]
            ...

        Typically ``{is_async=true}`` is used only if the load is
        large (more than 100,000 requests per second) and latency
        is large (more than 1 second), or when it is necessary to
        send multiple requests in parallel then collect responses
        (sometimes called a "map-reduce" scenario).

        .. NOTE::

            Although the final result of an async request is the same as
            the result of a sync request, it is structured differently: as a
            table, instead of as the unpacked values.

.. _net_box-triggers:

============================================================================
Triggers
============================================================================

With the ``net.box`` module, you can use the following
:ref:`triggers <triggers-box_triggers>`:

.. _net_box-on_connect:

.. function:: conn:on_connect([trigger-function[, old-trigger-function]])

    Define a trigger for execution when a new connection is established, and authentication
    and schema fetch are completed due to an event such as ``net_box.connect``.
    If the trigger execution fails and an exception happens, the connection's
    state changes to 'error'. In this case, the connection is terminated, regardless of the
    ``reconnect_after`` option's value. Can be called as many times as
    reconnection happens, if ``reconnect_after`` is greater than zero.

    :param function trigger-function: function which will become the trigger
                                      function. Takes the ``conn``
                                      object as the first argument
    :param function old-trigger-function: existing trigger function which will
                                          be replaced by trigger-function
    :return: nil or function pointer

.. _net_box-on_disconnect:

.. function:: conn:on_disconnect([trigger-function[, old-trigger-function]])

    Define a trigger for execution after a connection is closed. If the trigger
    function causes an error, the error is logged but otherwise is ignored.
    Execution stops after a connection is explicitly closed, or once the Lua
    garbage collector removes it.

    :param function trigger-function: function which will become the trigger
                                      function. Takes the ``conn``
                                      object as the first argument
    :param function old-trigger-function: existing trigger function which will
                                          be replaced by trigger-function
    :return: nil or function pointer

.. _net_box-on_schema_reload:

.. function:: conn:on_schema_reload([trigger-function[, old-trigger-function]])

    Define a trigger executed when some operation has been performed on the remote
    server after schema has been updated. So, if a server request fails due to a
    schema version mismatch error, schema reload is triggered.

    :param function trigger-function: function which will become the trigger
                                      function. Takes the ``conn``
                                      object as the first argument
    :param function old-trigger-function: existing trigger function which will
                                          be replaced by trigger-function
    :return: nil or function pointer

    .. NOTE::

        If the parameters are ``(nil, old-trigger-function)``,
        then the old trigger is deleted.

        If both parameters are omitted, then the response is a list of
        existing trigger functions.

        Details about trigger characteristics are in the
        :ref:`triggers <triggers-box_triggers>` section.

============================================================================
Example
============================================================================

This example shows the use of most of the ``net.box`` methods.

The sandbox configuration for this example assumes that:

* the Tarantool instance is running on ``localhost 127.0.0.1:3301``,
* there is a space named ``tester`` with a numeric primary key and with a tuple
  that contains a key value = 800,
* the current user has read, write and execute privileges.

Here are commands for a quick sandbox setup:

.. code-block:: lua

    box.cfg{listen = 3301}
    s = box.schema.space.create('tester')
    s:create_index('primary', {type = 'hash', parts = {1, 'unsigned'}})
    t = s:insert({800, 'TEST'})
    box.schema.user.grant('guest', 'read,write,execute', 'universe')

And here starts the example:

.. code-block:: tarantoolsession

    tarantool> net_box = require('net.box')
    ---
    ...
    tarantool> function example()
             >   local conn, wtuple
             >   if net_box.self:ping() then
             >     table.insert(ta, 'self:ping() succeeded')
             >     table.insert(ta, '  (no surprise -- self connection is pre-established)')
             >   end
             >   if box.cfg.listen == '3301' then
             >     table.insert(ta,'The local server listen address = 3301')
             >   else
             >     table.insert(ta, 'The local server listen address is not 3301')
             >     table.insert(ta, '(  (maybe box.cfg{...listen="3301"...} was not stated)')
             >     table.insert(ta, '(  (so connect will fail)')
             >   end
             >   conn = net_box.connect('127.0.0.1:3301')
             >   conn.space.tester:delete({800})
             >   table.insert(ta, 'conn delete done on tester.')
             >   conn.space.tester:insert({800, 'data'})
             >   table.insert(ta, 'conn insert done on tester, index 0')
             >   table.insert(ta, '  primary key value = 800.')
             >   wtuple = conn.space.tester:select({800})
             >   table.insert(ta, 'conn select done on tester, index 0')
             >   table.insert(ta, '  number of fields = ' .. #wtuple)
             >   conn.space.tester:delete({800})
             >   table.insert(ta, 'conn delete done on tester')
             >   conn.space.tester:replace({800, 'New data', 'Extra data'})
             >   table.insert(ta, 'conn:replace done on tester')
             >   conn.space.tester:update({800}, {{'=', 2, 'Fld#1'}})
             >   table.insert(ta, 'conn update done on tester')
             >   conn:close()
             >   table.insert(ta, 'conn close done')
             > end
    ---
    ...
    tarantool> ta = {}
    ---
    ...
    tarantool> example()
    ---
    ...
    tarantool> ta
    ---
    - - self:ping() succeeded
      - '  (no surprise -- self connection is pre-established)'
      - The local server listen address = 3301
      - conn delete done on tester.
      - conn insert done on tester, index 0
      - '  primary key value = 800.'
      - conn select done on tester, index 0
      - '  number of fields = 1'
      - conn delete done on tester
      - conn:replace done on tester
      - conn update done on tester
      - conn close done
    ...
