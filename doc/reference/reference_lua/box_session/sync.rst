
.. _box_session-sync:

================================================================================
box.session.sync()
================================================================================

.. module:: box.session

.. function:: sync()

    :return: the value of the :code:`sync` integer constant used in the
             `binary protocol <https://github.com/tarantool/tarantool/blob/2.1/src/box/iproto_constants.h>`_.
             This value becomes invalid when the session is disconnected.

    :rtype:  number

    This function is local for the request, i.e. not global for the session. If
    the connection behind the session is multiplexed, this function can be
    safely used inside the request processor.