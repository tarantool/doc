
.. _box_session-on_connect:

================================================================================
box.session.on_connect()
================================================================================

.. module:: box.session

.. function:: box.session.on_connect([trigger-function [, old-trigger-function]])

    Define a trigger for execution when a new session is created due to an event
    such as :ref:`console.connect <console-connect>`. The trigger function will
    be the first thing executed after a new session is created. If the trigger
    execution fails and raises an error, the error is sent to the client and
    the connection is closed.

    :param function trigger-function: function which will become the trigger
                                      function
    :param function old-trigger-function: existing trigger function which will
                                          be replaced by trigger-function
    :return: nil or function pointer

    If the parameters are (nil, old-trigger-function), then the old trigger
    is deleted.

    If both parameters are omitted, then the response is a list of existing
    trigger functions.

    Details about trigger characteristics are in the
    :ref:`triggers <triggers-box_triggers>` section.

    **Example**

    .. code-block:: tarantoolsession

        tarantool> function f ()
                 >   x = x + 1
                 > end
        tarantool> box.session.on_connect(f)

    .. WARNING::

        If a trigger always results in an error, it may become impossible to
        connect to a server to reset it.
