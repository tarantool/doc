.. _box_session:

-------------------------------------------------------------------------------
                            Submodule `box.session`
-------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

The ``box.session`` submodule allows querying the session state, writing to a
session-specific temporary Lua table, or setting up triggers which will fire
when a session starts or ends. A *session* is an object associated with each
client connection.

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

.. module:: box.session

.. _box_session-id:

.. function:: id()

    :return: the unique identifier (ID) for the current session.
             The result can be 0 meaning there is no session.
    :rtype:  number

.. _box_session-exists:

.. function:: exists(id)

    :return: 1 if the session exists, 0 if the session does not exist.
    :rtype:  number

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
             `binary protocol <https://github.com/tarantool/tarantool/blob/1.7/src/box/iproto_constants.h>`_.

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
        - 'radius_of_mars=3396 random_memorandum=Don''t forget the eggs. '
        ...

.. _box_session-on_connect:

.. function:: box.session.on_connect(trigger-function [, old-trigger-function])

    Define a trigger for execution when a new session is created due to an event
    such as :ref:`console.connect <console-connect>`. The trigger function will be the first thing
    executed after a new session is created. If the trigger execution fails and raises an
    error, the error is sent to the client and the connection is closed.

    :param function trigger-function: function which will become the trigger function
    :param function old-trigger-function: existing trigger function which will be replaced by trigger-function
    :return: nil or function pointer

    If the parameters are (nil, old-trigger-function), then the old trigger is deleted.

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

.. function:: box.session.on_disconnect(trigger-function [, old-trigger-function])

    Define a trigger for execution after a client has disconnected. If the trigger
    function causes an error, the error is logged but otherwise is ignored. The
    trigger is invoked while the session associated with the client still exists
    and can access session properties, such as box.session.id.

    :param function trigger-function: function which will become the trigger function
    :param function old-trigger-function: existing trigger function which will be replaced by trigger-function
    :return: nil or function pointer

    If the parameters are (nil, old-trigger-function), then the old trigger is deleted.

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

.. function:: box.session.on_auth(trigger-function [, old-trigger-function])

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
    There are two ``on_auth`` triggers:

    * The first trigger has a function with no arguments, it can only look
      at ``box.session.user()``.
    * The second trigger has a function with a ``user_name`` argument,
      it can look at both ``box.session.user()`` and ``user_name``.

    The second server instance will connect with
    :ref:`console.connect <console-connect>`,
    and then will display the variables that were set by the
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
        box.session.on_auth(function1)
        box.session.on_auth(function2)
        box.schema.user.passwd('admin')

    .. code-block:: lua

        -- On the second server instance, that connects to port 3301
        console = require('console')
        console.connect('admin:admin@localhost:3301')

    The result looks like this:

    .. code-block:: console

        function 2, box.session.user()=guest
        function 2, user_name=admin
        function 1, box.session.user()=guest
