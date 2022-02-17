
.. _box_session-on_auth:

================================================================================
box.session.on_auth()
================================================================================

.. module:: box.session

.. function:: box.session.on_auth([trigger-function [, old-trigger-function]])

    Define a trigger for execution during
    :ref:`authentication <authentication-users>`.

    The ``on_auth`` trigger function is invoked in these circumstances:

    (1) The :ref:`console.connect <console-connect>` function includes an
        authentication check for all users except 'guest'. For this case, the
        ``on_auth`` trigger function is invoked after the ``on_connect``
        trigger function, if and only if the connection has succeeded so far.

    (2) The :ref:`binary protocol <admin-security>` has a separate
        :ref:`authentication packet <box_protocol-authentication>`. For this
        case, connection and authentication are considered to be separate steps.

    Unlike other trigger types, ``on_auth`` trigger functions are invoked
    **before** the event. Therefore a trigger function like
    :code:`function auth_function () v = box.session.user(); end`
    will set :code:`v` to "guest", the user name before the authentication is
    done. To get the user name **after** the authentication is done, use the
    special syntax: :code:`function auth_function (user_name) v = user_name; end`

    If the trigger fails by raising an error, the error is sent to the client
    and the connection is closed.

    :param function trigger-function: function which will become the
                                      trigger function
    :param function old-trigger-function: existing trigger function which will
                                          be replaced by trigger-function
    :return: nil or function pointer

    If the parameters are (nil, old-trigger-function),
    then the old trigger is deleted.

    If both parameters are omitted, then the response is
    a list of existing trigger functions.

    Details about trigger characteristics are in the
    :ref:`triggers <triggers-box_triggers>` section.

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