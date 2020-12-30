
.. _box_session-on_disconnect:

================================================================================
box.session.on_disconnect()
================================================================================

.. module:: box.session

.. function:: box.session.on_disconnect([trigger-function [, old-trigger-function]])

    Define a trigger for execution after a client has disconnected. If the
    trigger function causes an error, the error is logged but otherwise is
    ignored. The trigger is invoked while the session associated with the
    client still exists and can access session properties, such as
    :doc:`/reference/reference_lua/box_session/id`.

    Since version 1.10, the trigger function is invoked immediately after the
    disconnect, even if requests that were made during the session have not
    finished.

    :param function trigger-function: function which will become the trigger
                                      function
    :param function old-trigger-function: existing trigger function which will
                                          be replaced by trigger-function
    :return: nil or function pointer

    If the parameters are (nil, old-trigger-function),
    then the old trigger is deleted.

    If both parameters are omitted, then the response is a list of existing
    trigger functions.

    Details about trigger characteristics are in the
    :ref:`triggers <triggers-box_triggers>` section.

    **Example #1**

    .. code-block:: tarantoolsession

        tarantool> function f ()
                 >   x = x + 1
                 > end
        tarantool> box.session.on_disconnect(f)

    **Example #2**

    After the following series of requests, a Tarantool instance will write
    a message using the :ref:`log <log-module>` module whenever any user
    connects or disconnects.

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
