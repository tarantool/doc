.. _box_session:

-------------------------------------------------------------------------------
                            Submodule `box.session`
-------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

The ``box.session`` submodule allows querying the session state, writing to a
session-specific temporary Lua table, or sending out-of-band messages, or
setting up triggers which will fire when a session starts or ends.

A *session* is an object associated with each client connection.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``box.session`` functions and members.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`box.session.id()               | Get the current session's ID    |
    | <box_session-id>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.exists()           | Check if a session exists       |
    | <box_session-exists>`                |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.peer()             | Get the session peer's host     |
    | <box_session-peer>`                  | address and port                |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.sync()             | Get the sync integer constant   |
    | <box_session-sync>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.user()             | Get the current user's name     |
    | <box_session-user>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.type()             | Get the connection type or      |
    | <box_session-type>`                  | cause of action                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.su()               | Change the current user         |
    | <box_session-su>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.uid()              | Get the current user's ID       |
    | <box_session-uid>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.euid()             | Get the current effective       |
    | <box_session-euid>`                  | user's ID                       |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.storage            | Table with session-specific     |
    | <box_session-storage>`               | names and values                |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.on_connect()       | Define a connect trigger        |
    | <box_session-on_connect>`            |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.on_disconnect()    | Define a disconnect trigger     |
    | <box_session-on_disconnect>`         |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.on_auth()          | Define an authentication        |
    | <box_session-on_auth>`               | trigger                         |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.on_access_denied() | Define a trigger to report      |
    | <box_session-on_access_denied>`      | restricted actions              |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.push()             | Send an out-of-band message     |
    | <box_session-push>`                  |                                 |
    +--------------------------------------+---------------------------------+

.. module:: box.session

.. _box_session-id:

.. function:: id()

    :return: the unique identifier (ID) for the current session.
             The result can be 0 or -1 meaning there is no session.
    :rtype:  number

.. _box_session-exists:

.. function:: exists(id)

    :return: true if the session exists, false if the session does not exist.
    :rtype:  boolean

.. _box_session-peer:

.. function:: peer(id)

    This function works only if there is a peer, that is,
    if a connection has been made to a separate Tarantool instance.

    :return: The host address and port of the session peer,
             for example "127.0.0.1:55457".
             If the session exists but there is no connection to a
             separate instance, the return is null.
             The command is executed on the server instance,
             so the "local name" is the server instance's host
             and port, and the "peer name" is the client's host
             and port.
    :rtype:  string

    Possible errors: 'session.peer(): session does not exist'

.. _box_session-sync:

.. function:: sync()

    :return: the value of the :code:`sync` integer constant used in the
             `binary protocol <https://github.com/tarantool/tarantool/blob/1.10/src/box/iproto_constants.h>`_.
             This value becomes invalid when the session is disconnected.

    :rtype:  number

.. _box_session-user:

.. function:: user()

    :return: the name of the :ref:`current user <authentication-users>`

    :rtype:  string

.. _box_session-type:

.. function:: type()

    :return: the type of connection or cause of action.

    :rtype:  string

    Possible return values are:

    * 'binary' if the connection was done via the binary protocol, for example
      to a target made with
      :ref:`box.cfg{listen=...} <cfg_basic-listen>`;
    * 'console' if the connection was done via the administrative console,
      for example to a target made with
      :ref:`console.listen <console-listen>`;
    * 'repl' if the connection was done directly, for example when
      :ref:`using Tarantool as a client <admin-using_tarantool_as_a_client>`;
    * 'applier' if the action is due to
      :ref:`replication <replication>`,
      regardless of how the connection was done;
    * 'background' if the action is in a
      :ref:`background fiber <fiber-module>`,
      regardless of whether the Tarantool server was
      :ref:`started in the background <cfg_basic-background>`.

    ``box.session.type()`` is useful for an
    :ref:`on_replace() <box_space-on_replace>` trigger
    on a replica -- the value will be 'applier' if and only if
    the trigger was activated because of a request that was done on
    the master.

.. _box_session-su:

.. function:: su(user-name [, function-to-execute])

    Change Tarantool's :ref:`current user <authentication-users>` --
    this is analogous to the Unix command ``su``.

    Or, if function-to-execute is specified,
    change Tarantool's :ref:`current user <authentication-users>`
    temporarily while executing the function --
    this is analogous to the Unix command ``sudo``.

    :param string user-name: name of a target user
    :param function-to-execute: name of a function, or definition of a function.
                                Additional parameters may be passed to
                                ``box.session.su``, they will be interpreted
                                as parameters of function-to-execute.

    **Example**

    .. code-block:: tarantoolsession

        tarantool> function f(a) return box.session.user() .. a end
        ---
        ...

        tarantool> box.session.su('guest', f, '-xxx')
        ---
        - guest-xxx
        ...

        tarantool> box.session.su('guest',function(...) return ... end,1,2)
        ---
        - 1
        - 2
        ...

.. _box_session-uid:

.. function:: uid()

    :return: the user ID of the :ref:`current user <authentication-users>`.

    :rtype:  number

    Every user has a unique name (seen with :ref:`box.session.user() <box_session-user>`)
    and a unique ID (seen with ``box.session.uid()``). The values are stored
    together in the ``_user`` space.

.. _box_session-euid:

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
      :ref:`box.schema.func.create(function-name, {setuid= true}) <box_schema-func_create>`
      and the binary protocol is in use
      -- in that case, ``box.session.euid()`` returns the ID of the user who
      created "function-name" but ``box.session.uid()`` returns the ID of the
      the user who is calling "function-name".

    :rtype: number

    **Example**

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

.. _box_session-storage:

.. data:: storage

    A Lua table that can hold arbitrary unordered session-specific
    names and values, which will last until the session ends.
    For example, this table could be useful to store current tasks when working
    with a `Tarantool queue manager <https://github.com/tarantool/queue>`_.

    **Example**

    .. code-block:: tarantoolsession

        tarantool> box.session.peer(box.session.id())
        ---
        - 127.0.0.1:45129
        ...
        tarantool> box.session.storage.random_memorandum = "Don't forget the eggs"
        ---
        ...
        tarantool> box.session.storage.radius_of_mars = 3396
        ---
        ...
        tarantool> m = ''
        ---
        ...
        tarantool> for k, v in pairs(box.session.storage) do
                 >   m = m .. k .. '='.. v .. ' '
                 > end
        ---
        ...
        tarantool> m
        ---
        - 'radius_of_mars=3396 random_memorandum=Don't forget the eggs. '
        ...

.. _box_session-on_connect:

.. function:: box.session.on_connect([trigger-function [, old-trigger-function]])

    Define a trigger for execution when a new session is created due to an event
    such as :ref:`console.connect <console-connect>`. The trigger function will be the first thing
    executed after a new session is created. If the trigger execution fails and raises an
    error, the error is sent to the client and the connection is closed.

    :param function trigger-function: function which will become the trigger function
    :param function old-trigger-function: existing trigger function which will be replaced by trigger-function
    :return: nil or function pointer

    If the parameters are (nil, old-trigger-function), then the old trigger is deleted.

    If both parameters are omitted, then the response is a list of existing trigger functions.

    Details about trigger characteristics are in the :ref:`triggers <triggers-box_triggers>` section.

    **Example**

    .. code-block:: tarantoolsession

        tarantool> function f ()
                 >   x = x + 1
                 > end
        tarantool> box.session.on_connect(f)

    .. WARNING::

        If a trigger always results in an error, it may become impossible to
        connect to a server to reset it.

.. _box_session-on_disconnect:

.. function:: box.session.on_disconnect([trigger-function [, old-trigger-function]])

    Define a trigger for execution after a client has disconnected. If the trigger
    function causes an error, the error is logged but otherwise is ignored. The
    trigger is invoked while the session associated with the client still exists
    and can access session properties, such as :ref:`box.session.id() <box_session-id>`.

    Since version 1.10, the trigger function is invoked immediately after the disconnect,
    even if requests that were made during the session have not finished.

    :param function trigger-function: function which will become the trigger function
    :param function old-trigger-function: existing trigger function which will be replaced by trigger-function
    :return: nil or function pointer

    If the parameters are (nil, old-trigger-function), then the old trigger is deleted.

    If both parameters are omitted, then the response is a list of existing trigger functions.

    Details about trigger characteristics are in the :ref:`triggers <triggers-box_triggers>` section.

    **Example #1**

    .. code-block:: tarantoolsession

        tarantool> function f ()
                 >   x = x + 1
                 > end
        tarantool> box.session.on_disconnect(f)

    **Example #2**

    After the following series of requests, a Tarantool instance will write a message
    using the :ref:`log <log-module>` module whenever any user connects or disconnects.

    .. code-block:: lua_tarantool

        function log_connect ()
          local log = require('log')
          local m = 'Connection. user=' .. box.session.user() .. ' id=' .. box.session.id()
          log.info(m)
        end

        function log_disconnect ()
          local log = require('log')
          local m = 'Disconnection. user=' .. box.session.user() .. ' id=' .. box.session.id()
          log.info(m)
        end

        box.session.on_connect(log_connect)
        box.session.on_disconnect(log_disconnect)

    Here is what might appear in the log file in a typical installation:

    .. code-block:: lua

        2014-12-15 13:21:34.444 [11360] main/103/iproto I>
            Connection. user=guest id=3
        2014-12-15 13:22:19.289 [11360] main/103/iproto I>
            Disconnection. user=guest id=3

.. _box_session-on_auth:

.. function:: box.session.on_auth([trigger-function [, old-trigger-function]])

    Define a trigger for execution during :ref:`authentication <authentication-users>`.

    The ``on_auth`` trigger function is invoked in these circumstances:

    (1) The :ref:`console.connect <console-connect>` function includes an authentication check
        for all users except 'guest'.
        For this case, the ``on_auth`` trigger function is invoked after the ``on_connect``
        trigger function, if and only if the connection has succeeded so far.

    (2) The :ref:`binary protocol <admin-security>` has a separate
        :ref:`authentication packet <box_protocol-authentication>`.
        For this case, connection and authentication are considered to be separate steps.

    Unlike other trigger types, ``on_auth`` trigger functions are invoked **before**
    the event. Therefore a trigger function like :code:`function auth_function () v = box.session.user(); end`
    will set :code:`v` to "guest", the user name before the authentication is done.
    To get the user name **after** the authentication is done, use the special syntax:
    :code:`function auth_function (user_name) v = user_name; end`

    If the trigger fails by raising an error, the error is sent to the client and the connection is closed.

    :param function trigger-function: function which will become the trigger function
    :param function old-trigger-function: existing trigger function which will be replaced by trigger-function
    :return: nil or function pointer

    If the parameters are (nil, old-trigger-function), then the old trigger is deleted.

    If both parameters are omitted, then the response is a list of existing trigger functions.

    Details about trigger characteristics are in the :ref:`triggers <triggers-box_triggers>` section.

    **Example 1**

    .. code-block:: tarantoolsession

        tarantool> function f ()
                 >   x = x + 1
                 > end
        tarantool> box.session.on_auth(f)

    **Example 2**

    This is a more complex example, with two server instances.

    The first server instance listens on port 3301; its default
    user name is 'admin'.
    There are three ``on_auth`` triggers:

    * The first trigger has a function with no arguments, it can only look
      at ``box.session.user()``.
    * The second trigger has a function with a ``user_name`` argument,
      it can look at both of: ``box.session.user()`` and ``user_name``.
    * The third trigger has a function with a ``user_name`` argument
      and a ``status`` argument,
      it can look at all three of:
      ``box.session.user()`` and ``user_name`` and ``status``.

    The second server instance will connect with
    :ref:`console.connect <console-connect>`,
    and then will cause a display of the variables that were set by the
    trigger functions.

    .. code-block:: lua

        -- On the first server instance, which listens on port 3301
        box.cfg{listen=3301}
        function function1()
          print('function 1, box.session.user()='..box.session.user())
          end
        function function2(user_name)
          print('function 2, box.session.user()='..box.session.user())
          print('function 2, user_name='..user_name)
          end
        function function3(user_name, status)
          print('function 3, box.session.user()='..box.session.user())
          print('function 3, user_name='..user_name)
          if status == true then
            print('function 3, status = true, authorization succeeded')
            end
          end
        box.session.on_auth(function1)
        box.session.on_auth(function2)
        box.session.on_auth(function3)
        box.schema.user.passwd('admin')

    .. code-block:: lua

        -- On the second server instance, that connects to port 3301
        console = require('console')
        console.connect('admin:admin@localhost:3301')

    The result looks like this:

    .. code-block:: console

        function 3, box.session.user()=guest
        function 3, user_name=admin
        function 3, status = true, authorization succeeded
        function 2, box.session.user()=guest
        function 2, user_name=admin
        function 1, box.session.user()=guest

.. _box_session-on_access_denied:

.. function:: box.session.on_access_denied([trigger-function [, old-trigger-function]])

    Define a trigger for reacting to user's attempts to execute actions that are
    not within the user's privileges.

    :param function trigger-function: function which will become the trigger function
    :param function old-trigger-function: existing trigger function which will be
                                          replaced by trigger-function
    :return: nil or function pointer

    If the parameters are `(nil, old-trigger-function)`, then the old trigger is deleted.

    If both parameters are omitted, then the response is a list of existing trigger functions.

    Details about trigger characteristics are in the :ref:`triggers <triggers-box_triggers>` section.

    **Example**

    For example, server administrator can log restricted actions like this:

    .. code-block:: tarantoolsession

        tarantool> function on_access_denied(op, type, name)
                 > log.warn('User %s tried to %s %s %s without required privileges', box.session.user(), op, type, name)
                 > end
        ---
        ...
        tarantool> box.session.on_access_denied(on_access_denied)
        ---
        - 'function: 0x011b41af38'
        ...
        tarantool> function test() print('you shall not pass') end
        ---
        ...
        tarantool> box.schema.func.create('test')
        ---
        ...

    Then, when some user without required privileges tries to call ``test()``
    and gets the error, the server will execute this trigger and write to log
    **"User *user_name* tried to Execute function test without required privileges"**

.. _box_session-push:

.. function:: box.session.push(message [, sync])

    Generate an out-of-band message. By "out-of-band" we mean an extra
    message which supplements what is passed in a network via the usual
    channels. Although ``box.session.push()`` can be called at any time, in
    practice it is used with networks that are set up with
    :ref:`module net.box <net_box-module>`, and
    it is invoked by the server (on the "remote database system" to use
    our terminology for net.box), and the client has options for getting
    such messages.

    This function returns an error if the session is disconnected.

    :param any-Lua-type message: what to send
    :param int sync: an optional argument to indicate what the session is,
                     as taken from an earlier call to :ref:`box_session:sync() <box_session-sync>`.
                     If it is omitted, the default is the current ``box.session.sync()`` value.
    :rtype: {nil, error} or true:

            * If the result is an error, then the first part of the return is
              ``nil`` and the second part is the error object.
            * If the result is not an error, then the return is the boolean value ``true``.
            * When the return is ``true``, the message has gone to the network
              buffer as a :ref:`packet <box_protocol-iproto_protocol>`
              with the code IPROTO_CHUNK (0x80).

    The server's sole job is to call ``box.session.push()``, there is no
    automatic mechanism for showing that the message was received.

    The client's job is to check for such messages after it sends
    something to the server. The major client methods --
    :ref:`conn:call <net_box-call>`, :ref:`conn:eval <net_box-eval>`,
    :ref:`conn:select <conn-select>`, :ref:`conn:insert <conn-insert>`,
    :ref:`conn:replace <conn-replace>`, :ref:`conn:update <conn-update>`,
    :ref:`conn:upsert <conn-upsert>`, :ref:`delete <conn-delete>` --
    may cause the server to send a message.

    Situation 1: when the client calls synchronously with the default
    ``{async=false}`` option. There are two optional additional options:
    :samp:`on_push={function-name}`, and :samp:`on_push_ctx={function-argument}`.
    When the client receives an out-of-band message for the session,
    it invokes "function-name(function-argument)". For example, with
    options ``{on_push=table.insert, on_push_ctx=messages}``, the client
    will insert whatever it receives into a table named 'messages'.

    Situation 2: when the client calls asynchronously with the non-default
    ``{async=true}`` option. Here ``on_push`` and ``on_push_ctx`` are not allowed, but
    the messages can be seen by calling ``pairs()`` in a loop.

    Situation 2 complication: ``pairs()`` is subject to timeout. So there
    is an optional argument = timeout per iteration. If timeout occurs before
    there is a new message or a final response, there is an error return.
    To check for an error one can use the first loop parameter (if the loop
    starts with "for i, message in future:pairs()" then the first loop parameter
    is i). If it is ``box.NULL`` then the second parameter (in our example, "message")
    is the error object.

    **Example**

    .. code-block:: lua

        -- Make two shells. On Shell#1 set up a "server", and
        -- in it have a function that includes box.session.push:
        box.cfg{listen=3301}
        box.schema.user.grant('guest','read,write,execute','universe')
        x = 0
        fiber = require('fiber')
        function server_function() x=x+1; fiber.sleep(1); box.session.push(x); end

        -- On Shell#2 connect to this server as a "client" that
        -- can handle Lua (such as another Tarantool server operating
        -- as a client), and initialize a table where we'll get messages:
        net_box = require('net.box')
        conn = net_box.connect(3301)
        messages_from_server = {}

        -- On Shell#2 remotely call the server function and receive
        -- a SYNCHRONOUS out-of-band message:
        conn:call('server_function', {},
                  {is_async = false,
                   on_push = table.insert,
                   on_push_ctx = messages_from_server})
        messages_from_server
        -- After a 1-second pause that is caused by the fiber.sleep()
        -- request inside server_function, the result in the
        --  messages_from_server table will be: 1. Like this:
        -- tarantool> messages_from_server
        -- ---
        -- - - 1
        -- ...
        -- Good. That shows that box.session.push(x) worked,
        -- because we know that x was 1.

        -- On Shell#2 remotely call the same server function and
        -- get an ASYNCHRONOUS out-of-band message. For this we cannot
        -- use on_push and on_push_ctx options, but we can use pairs():
        future = conn:call('server_function', {}, {is_async = true})
        messages = {}
        keys = {}
        for i, message in future:pairs() do
            table.insert(messages, message) table.insert(keys, i) end
        messages
        future:wait_result(1000)
        for i, message in future:pairs() do
            table.insert(messages, message) table.insert(keys, i) end
        messages
        -- There is no pause because conn:call does not wait for
        -- server_function to finish. The first time that we go through
        -- the pairs() loop, we see the messages table is empty. Like this:
        -- tarantool> messages
        -- ---
        -- - - 2
        --   - []
        -- ...
        -- That is okay because the server hasn't yet called
        -- box.session.push(). The second time that we go through
        -- the pairs() loop, we see the value of x at the time of
        -- the second call to box.session.push(). Like this:
        -- tarantool> messages
        -- ---
        -- - - 2
        --   - &0 []
        --   - 2
        --   - *0
        -- ...
        -- Good. That shows that the message was asynchronous, and
        -- that box.session.push() did its job.
