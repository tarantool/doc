
.. _box_session-on_access_denied:

================================================================================
box.session.on_access_denied()
================================================================================

.. module:: box.session

.. function:: box.session.on_access_denied([trigger-function [, old-trigger-function]])

    Define a trigger for reacting to user's attempts to execute actions that are
    not within the user's privileges.

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