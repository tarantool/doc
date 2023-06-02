..  _net_box-module:

--------------------------------------------------------------------------------
Module net.box
--------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

The ``net.box`` module contains connectors to remote database systems. One
variant, to be discussed later, is for connecting to MySQL or MariaDB or PostgreSQL
(see :ref:`SQL DBMS modules <dbms_modules>` reference). The other variant, which
is discussed in this section, is for connecting to Tarantool server instances via a 
network.
For a quick start with ``net.box``, refer to the :ref:`tutorial <getting_started_net_box>`.

You can call the following methods:

* ``require('net.box')`` -- to get a ``net.box`` object
  (named ``net_box`` for examples in this section)
* ``net_box.connect()`` -- to connect and get a connection object
  (named ``conn`` for examples in this section)
* other ``net.box()`` routines, passing ``conn:``, to execute requests on
  the remote database system
* ``conn:close`` -- to disconnect

All ``net.box`` methods are fiber-safe, that is, it is safe to share and use the
same connection object across multiple concurrent fibers. In fact that is perhaps
the best programming practice with Tarantool. When multiple fibers use the same
connection, all requests are pipelined through the same network socket, but each
fiber gets back a correct response. Reducing the number of active sockets lowers
the overhead of system calls and increases the overall server performance. However
for some cases a single connection is not enough -- for example, when
it is necessary to prioritize requests or to use different authentication IDs.

.. _net_box-options:

Most ``net.box`` methods accept the last ``{options}`` argument, which can be:

* ``{timeout=...}``. For example, a method whose last argument is
  ``{timeout=1.5}`` will stop after 1.5 seconds on the local node, although this
  does not guarantee that execution will stop on the remote server node.

* ``{buffer=...}``. For an example, see the :ref:`buffer module <buffer-module>`.

* ``{is_async=...}``. For example, a method whose last argument is
  ``{is_async=true}`` will not wait for the result of a request. See the
  :ref:`is_async <net_box-is_async>` description.

* ``{on_push=... on_push_ctx=...}``. For receiving out-of-band messages.
  See the :doc:`/reference/reference_lua/box_session/push` description.

* ``{return_raw=...}`` (since version 2.10.0).
  If set to ``true``, net.box returns response data wrapped
  in a :ref:`MsgPack object <msgpack-object-info>` instead of decoding it to Lua.
  The default value is ``false``.
  For an example, see option description :ref:`below <net_box-return_raw>`.

.. _net_box-state_diagram:

The diagram below shows possible connection states and transitions:

.. ifconfig:: builder not in ('latex', )

    .. image:: net_states.png
        :align: center
        :alt: net_states.png

On this diagram:

*   ``net_box.connect()`` method spawns a worker fiber, which will establish the connection and start the state machine.

*   The state machine goes to the ``initial`` state.

*   Authentication and schema upload.
    It is possible later on to re-enter the ``fetch_schema`` state from ``active`` to trigger schema reload.

*   The state changes to the ``graceful_shutdown`` state when the state machine
    receives a :ref:`box.shutdown <system-events_box-shutdown>` event from the remote host
    (see :ref:`conn:on_shutdown() <net_box-on_shutdown>`).
    Once all pending requests are completed, the state machine switches to the ``error`` (``error_reconnect``) state.

*   The transport goes to the ``error`` state in case of an error.
    It can happen, for example, if the server closed the connection.
    If the ``reconnect_after`` option is set, instead of the ‘error’ state,
    the transport goes to the ``error_reconnect`` state.

*   ``conn.close()`` method sets the state to ``closed`` and kills the worker.
    If the transport is already in the ``error`` state, ``close()`` does nothing.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``net.box`` functions.

..  container:: table

    ..  list-table::
        :widths: 50 50
        :header-rows: 1

        *   -   Name
            -   Use
        *   -   :ref:`net_box.connect() <net_box-connect>` |br| :ref:`net_box.new() <net_box-new>` |br| :ref:`net_box.self <net_box-self>` 
            -   Create a connection
        *   -   :ref:`conn:ping() <conn-ping>`
            -   Execute a PING command            
        *   -   :ref:`conn:wait_connected() <conn-wait_connected>`   
            -   Wait for a connection to be active or closed      
        *   -   :ref:`conn:is_connected() <conn-is_connected>`                           
            -   Check if a connection is active or closed            
        *   -   :ref:`conn:wait_state() <conn-wait_state>`                  
            -   Wait for a target state            
        *   -   :ref:`conn:close() <conn-close>`                                     
            -   Close a connection
        *   -   :ref:`conn.space.space-name:select{field-value} <conn-select>`          
            -   Select one or more tuples            
        *   -   :ref:`conn.space.space-name:get{field-value} <conn-get>`  
            -   Select a tuple            
        *   -   :ref:`conn.space.space-name:insert{field-value} <conn-insert>`
            -   Insert a tuple 
        *   -   :ref:`conn.space.space-name:replace{field-value} <conn-replace>`     
            -   Insert or replace a tuple            
        *   -   :ref:`conn.space.space-name:update{field-value} <conn-update>`                                   
            -   Update a tuple              
        *   -   :ref:`conn.space.space-name:upsert{field-value} <conn-upsert>`    
            -   Update a tuple     
        *   -   :ref:`conn.space.space-name:delete{field-value} <conn-delete>`                           
            -   Delete a tuple                 
        *   -   :ref:`conn:eval() <net_box-eval>`                                
            -   Evaluate the expression in a string and execute it                
        *   -   :ref:`conn:call() <net_box-call>`                      
            -   Call a stored procedure               
        *   -   :ref:`conn:timeout() <conn-timeout>`                               
            -   Set a timeout
        *   -   :ref:`conn:watch() <conn-watch>`
            -   Subscribe to events broadcast by a remote host
        *   -   :ref:`conn:on_connect() <net_box-on_connect>`                            
            -   Define a connect trigger            
        *   -   :ref:`conn:on_disconnect() <net_box-on_disconnect>`                     
            -   Define a disconnect trigger
        *   -   :ref:`conn:on_shutdown() <net_box-on_shutdown>`
            -   Define a shutdown trigger
        *   -   :ref:`conn:on_schema_reload() <net_box-on_schema_reload>`                    
            -   Define a trigger when schema is modified
        *   -   :ref:`conn:new_stream() <conn-new_stream>`
            -   Create a stream             
        *   -   :ref:`stream:begin() <net_box-stream_begin>`                    
            -   Begin a stream transaction               
        *   -   :ref:`stream:commit() <net_box-stream_commit>`                    
            -   Commit a stream transaction   
        *   -   :ref:`stream:rollback() <net_box-stream_rollback>`                    
            -   Rollback a stream transaction                           
            
.. module:: net_box

.. _net_box-connect:

.. function:: connect(URI [, {option[s]}])

    Create a new connection. The connection is established on demand, at the
    time of the first request. It can be re-established automatically after a
    disconnect (see ``reconnect_after`` option below).
    The returned ``conn`` object supports methods for making remote requests,
    such as select, update or delete.

    :param string URI: the :ref:`URI <index-uri>` of the target for the connection
    :param options: the supported options are shown below:

        *   ``user/password``: two options to connect to a remote host other than through
            :ref:`URI <index-uri>`. For example, instead of ``connect('username:userpassword@localhost:3301')``
            you can write ``connect('localhost:3301', {user = 'username', password='userpassword'})``.

        *   ``wait_connected``: a connection timeout. By default, the connection is blocked until the connection
            is established, but if you specify ``wait_connected=false``, the connection returns immediately.
            If you specify this timeout, it will wait before returning (``wait_connected=1.5`` makes it wait at most 1.5 seconds).

            .. NOTE::

                 If ``reconnect_after`` is greater than zero, then ``wait_connected`` ignores transient failures.
                 The wait completes once the connection is established or is closed explicitly.


        *   ``reconnect_after``: a number of seconds to wait before reconnecting.
            The default value, as with the other ``connect`` options, is ``nil``. If ``reconnect_after``
            is greater than zero, then a ``net.box`` instance will attempt to reconnect if a connection
            is lost or a connection attempt fails. This makes transient network failures transparent to the application.
            Reconnection happens automatically in the background, so requests that initially fail due to connection drops
            fail, are transparently retried. The number of retries is unlimited, connection retries are made after
            any specified interval (for example, ``reconnect_after=5`` means that reconnect attempts are made every 5 seconds).
            When a connection is explicitly closed or when the Lua garbage collector removes it, then reconnect attempts stop.


        *   ``call_16``: [since 1.7.2] a new binary protocol command for CALL in ``net.box`` connections by default.
            The new CALL is not backward compatible with previous versions. It no longer restricts a function to
            returning an array of tuples and allows returning an arbitrary MsgPack/JSON result,
            including scalars, nil and void (nothing). The old CALL is left intact for backward compatibility.
            It will not be present in the next major release. All programming language drivers will gradually be switched
            to the new CALL. To connect to a Tarantool instance that uses the old CALL, specify ``call_16=true``.

        *   ``console``: an option to use different connection support methods (as if instances of different
            classes are returned). With ``console = true``, you can use the ``conn`` methods ``close()``,
            ``is_connected()``, ``wait_state()``, ``eval()`` (in this case both binary and Lua console
            network protocols are supported).
            With ``console = false`` (default), you can also use ``conn`` database methods (in this case only the
            binary protocol is supported). Deprecation note: ``console = true`` is deprecated, users should use
            :ref:`console.connect() <console-connect>` instead.

        *   ``connect_timeout``: a number of seconds to wait before returning "error: Connection timed out".

        *   ``fetch_schema``: a boolean option that controls fetching schema changes from the server. Default: ``true``.
            If you don't operate with remote spaces, for example, run only ``call`` or ``eval``, set ``fetch_schema`` to
            ``false`` to avoid fetching schema changes which is not needed in this case.

            .. important::

                If ``fetch_schema`` is ``false``, remote spaces are unavailable and the :ref:``on_schema_reload <net_box-on_schema_reload>``
                trigger won't work.

        *   ``required_protocol_version``: a minimum version of the :ref:`IPROTO protocol <box_protocol-id>`
            supported by the server. If the version of the :ref:`IPROTO protocol <box_protocol-id>` supported
            by the server is lower than specified, the connection will fail with an error message.
            With ``required_protocol_version = 1``, all connections fail where the :ref:`IPROTO protocol <box_protocol-id>`
            version is lower than ``1``.

        *   ``required_protocol_features``: specified :ref:`IPROTO protocol features <box_protocol-id>` supported by the server.
            You can specify one or more ``net.box`` features from the table below. If the server does not
            support the specified features, the connection will fail with an error message.
            With ``required_protocol_features = {'transactions'}``, all connections fail where the
            server has ``transactions: false``.

    ..  container:: table

    	..  list-table::
           :widths: 26 29 25 20
           :header-rows: 1

           *   -   net.box feature
               -   Use
               -   IPROTO feature ID
               -   IPROTO versions supporting the feature
           *   -   ``streams``
               -   Requires streams support on the server
               -   IPROTO_FEATURE_STREAMS
               -   1 and newer
           *   -   ``transactions``
               -   Requires transactions support on the server
               -   IPROTO_FEATURE_TRANSACTIONS
               -   1 and newer
           *   -   ``error_extension``
               -   Requires support for :ref:`MP_ERROR <msgpack_ext-error>` MsgPack extension on the server
               -   IPROTO_FEATURE_ERROR_EXTENSION
               -   2 and newer
           *   -   ``watchers``
               -   Requires remote :ref:`watchers <conn-watch>` support on the server
               -   IPROTO_FEATURE_WATCHERS
               -   3 and newer

    To learn more about IPROTO features, see :ref:`IPROTO_ID <box_protocol-id>`
    and the :ref:`IPROTO_FEATURES <internals-iproto-keys-features>` key.

    :return: conn object
    :rtype:  userdata

    **Examples:**

    .. code-block:: lua

        net_box = require('net.box')

        conn = net_box.connect('localhost:3301')
        conn = net_box.connect('127.0.0.1:3302', {wait_connected = false})
        conn = net_box.connect('127.0.0.1:3303', {reconnect_after = 5, call_16 = true})
        conn = net_box.connect('127.0.0.1:3304', {required_protocol_version = 4, required_protocol_features = {'transactions', 'streams'}, })

.. _net_box-new:

.. function:: new(URI [, {option[s]}])

    ``new()`` is a synonym for ``connect()``. It is retained for backward compatibility.
    For more information, see the description of :ref:`net_box.connect() <net_box-connect>`.

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
      :ref:`the implicit rules <app-implicit-yields>`
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
        of the local call :samp:`box.space.{space-name}:select`:code:`{...}` (:ref:`see details <box_space-select>`).
        For an additional option see :ref:`Module buffer and skip-header <buffer-module_and_skip_header>`.

        **Example:**

        .. code-block:: lua

            conn.space.testspace:select({1,'B'}, {timeout=1})

        .. NOTE::

            Due to :ref:`the implicit yield rules <app-implicit-yields>`
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
        of the local call :samp:`box.space.{space-name}:insert(...)` (:ref:`see details <box_space-insert>`).
        For an additional option see :ref:`Module buffer and skip-header <buffer-module_and_skip_header>`.

        **Example:**

        .. code-block:: lua

            conn.space.testspace:insert({2,3,4,5}, {timeout=1.1})

    .. _conn-replace:

    .. method:: conn.space.<space-name>:replace({field-value, ...} [, {options}])

        :samp:`conn.space.{space-name}:replace(...)` is the remote-call equivalent
        of the local call :samp:`box.space.{space-name}:replace(...)` (:ref:`see details <box_space-replace>`).
        For an additional option see :ref:`Module buffer and skip-header <buffer-module_and_skip_header>`.

        **Example:**

        .. code-block:: lua

            conn.space.testspace:replace({5,6,7,8})

    .. _conn-update:

    .. method:: conn.space.<space-name>:update({field-value, ...} [, {options}])

        :samp:`conn.space.{space-name}:update(...)` is the remote-call equivalent
        of the local call :samp:`box.space.{space-name}:update(...)` (:ref:`see details <box_space-update>`).
        For an additional option see :ref:`Module buffer and skip-header <buffer-module_and_skip_header>`.

        **Example:**

        .. code-block:: lua

            conn.space.Q:update({1},{{'=',2,5}}, {timeout=0})

    .. _conn-upsert:

    .. method:: conn.space.<space-name>:upsert({field-value, ...} [, {options}])

        :samp:`conn.space.{space-name}:upsert(...)` is the remote-call equivalent
        of the local call :samp:`box.space.{space-name}:upsert(...)`. (:ref:`see details <box_space-upsert>`)
        For an additional option see :ref:`Module buffer and skip-header <buffer-module_and_skip_header>`.

    .. _conn-delete:

    .. method:: conn.space.<space-name>:delete({field-value, ...} [, {options}])

        :samp:`conn.space.{space-name}:delete(...)` is the remote-call equivalent
        of the local call :samp:`box.space.{space-name}:delete(...)` (:ref:`see details <box_space-delete>`).
        For an additional option see :ref:`Module buffer and skip-header <buffer-module_and_skip_header>`.

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

    ..  _conn-watch:

    ..  method:: watch(key, func)

        Subscribe to events broadcast by a remote host.

        :param string key: a key name of an event to subscribe to
        :param function func:  a callback to invoke when the key value is updated
        :return: a watcher handle. The handle consists of one method -- ``unregister()``, which unregisters the watcher.

        To read more about watchers, see the :ref:`Functions for watchers <box-watchers>` section.

        The method has the same syntax as the :doc:`box.watch() </reference/reference_lua/box_events/broadcast>`
        function, which is used for subscribing to events locally.

        Watchers survive reconnection (see the ``reconnect_after`` connection :ref:`option <net_box-connect>`).
        All registered watchers are automatically resubscribed when the
        connection is reestablished.

        If a remote host supports watchers, the ``watchers`` key will be set in the
        connection ``peer_protocol_features``.
        For details, check the :ref:`net.box features table <net_box-connect>`.

        ..  note::

            Keep in mind that garbage collection of a watcher handle doesn't lead to the watcher's destruction.
            In this case, the watcher remains registered.
            It is okay to discard the result of ``watch`` function if the watcher will never be unregistered.

        **Example:**

        Server:

        ..  code-block:: lua

            -- Broadcast value 42 for the 'foo' key.
            box.broadcast('foo', 42)

        Client:

        ..  code-block:: lua

            conn = net.box.connect(URI)
            local log = require('log')
            -- Subscribe to updates of the 'foo' key.
            w = conn:watch('foo', function(key, value)
                assert(key == 'foo')
                log.info("The box.id value is '%d'", value)
            end)

        If you don't need the watcher anymore, you can unregister it using the command below:

        ..  code-block:: lua

            w:unregister()

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

    ..  _net_box-is_async:

    ..  method:: request(... {is_async=...})

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
        by calling ``pairs()`` in a loop -- see :doc:`/reference/reference_lua/box_session/push`.

        A user would say ``future:discard()`` to make a connection forget about the response --
        if a response for a discarded object is received then it will be ignored, so that
        the size of the requests table will be reduced and other requests will be faster.

        **Examples:**

        .. code-block:: tarantoolsession

            -- Insert a tuple asynchronously --
            tarantool> future = conn.space.bands:insert({10, 'Queen', 1970}, {is_async=true})
            ---
            ...
            tarantool> future:is_ready()
            ---
            - true
            ...
            tarantool> future:result()
            ---
            - [10, 'Queen', 1970]
            ...

            -- Iterate through a space with 10 records to get data in chunks of 3 records --
            tarantool> while true do
                           future = conn.space.bands:select({}, {limit=3, after=position, fetch_pos=true, is_async=true})
                           result = future:wait_result()
                           tuples = result[1]
                           position = result[2]
                           if position == nil then
                               break
                           end
                           print('Chunk size: '..#tuples)
                       end
            Chunk size: 3
            Chunk size: 3
            Chunk size: 3
            Chunk size: 1
            ---
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

    ..  _net_box-return_raw:

    ..  method:: request(... {return_raw=...})

        ``{return_raw=true}`` is ignored for:

        *   Methods that return ``nil``:
            ``begin``, ``commit``, ``rollback``, ``upsert``, ``prepare``.

        *   ``index.count`` (returns number).

        For ``execute``, the option is applied only to data (`rows`). Metadata is decoded even if ``{return_raw=true}``.

        **Example:**

        ..  code-block:: lua

            local c = require('net.box').connect(uri)
            local mp = c.eval('eval ...', {1, 2, 3}, {return_raw = true})
            mp:decode() -- {1, 2, 3}

        The option can be useful if you want to pass a response through without decoding or with partial decoding.
        The usage of :ref:`MsgPack object <msgpack-object-info>` can reduce pressure on the Lua garbage collector.

    .. _conn-new_stream:

    .. method:: new_stream([options])

        Create a stream.

        **Example:**

        .. code-block:: lua

           -- Start a server to create a new stream
           local conn = net_box.connect('localhost:3301')
           local conn_space = conn.space.test
           local stream = conn:new_stream()
           local stream_space = stream.space.test

.. class:: stream

    .. _net_box-stream_begin:

    .. method:: begin([txn_isolation])

        Begin a stream transaction. Instead of the direct method, you can also use the ``call``, ``eval`` or execute methods with SQL transaction.

        :param txn_isolation: :ref:`transaction isolation level <txn_mode_mvcc-options>`

    .. _net_box-stream_commit:

    .. method:: commit()

        Commit a stream transaction. Instead of the direct method, you can also use the ``call``, ``eval`` or execute methods with SQL transaction.
        
        **Examples:**

        .. code-block:: lua

           -- Begin stream transaction
           stream:begin()
           -- In the previously created ``accounts`` space with the primary key ``test``, modify the fields 2 and 3
           stream.space.accounts:update(test_1, {{'-', 2, 370}, {'+', 3, 100}})
           -- Commit stream transaction
           stream:commit()
           
    .. _net_box-stream_rollback:

    .. method:: rollback()

        Rollback a stream transaction. Instead of the direct method, you can also use the ``call``, ``eval`` or execute methods with SQL transaction.

        **Example:**

        .. code-block:: lua

           -- Test rollback for memtx space
           space:replace({1})
           -- Select return tuple that was previously inserted, because this select belongs to stream transaction
           space:select({})
           stream:rollback()
           -- Select is empty, stream transaction rollback
           space:select({})

..  _net_box-triggers:

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

..  _net_box-on_shutdown:

..  function:: conn:on_shutdown([trigger-function[, old-trigger-function]])

    Define a trigger for shutdown when a :ref:`box.shutdown <system-events_box-shutdown>` event is received.

    The trigger starts in a new fiber.
    While the ``on_shutdown()`` trigger is running, the connection stays active.
    It means that the trigger callback is allowed to send new requests.

    After the trigger return, the ``net.box`` connection goes to the ``graceful_shutdown`` state
    (check :ref:`the state diagram <net_box-state_diagram>` for details).
    In this state, no new requests are allowed.
    The connection waits for all pending requests to be completed.

    Once all in-progress requests have been processed, the connection is closed.
    The state changes to ``error`` or ``error_reconnect``
    (if the ``reconnect_after`` option is defined).

    Servers that do not support the ``box.shutdown`` event or :ref:`IPROTO_WATCH <box_protocol-watch>`
    just close the connection abruptly.
    In this case, the ``on_shutdown()`` trigger is not executed.

    :param function trigger-function: function which will become the trigger
                                      function. Takes the ``conn``
                                      object as the first argument
    :param function old-trigger-function: existing trigger function which will
                                          be replaced by trigger-function
    :return: nil or function pointer

.. _net_box-on_schema_reload:

..  function:: conn:on_schema_reload([trigger-function[, old-trigger-function]])

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