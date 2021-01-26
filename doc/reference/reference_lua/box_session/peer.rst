
.. _box_session-peer:

================================================================================
box.session.peer()
================================================================================

.. module:: box.session

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
