
.. _box_session-sync:

================================================================================
box.session.sync()
================================================================================

.. module:: box.session

.. function:: sync()

    :return: the value of the :code:`sync` integer constant used in the
             `binary protocol <https://github.com/tarantool/tarantool/blob/1.10/src/box/iproto_constants.h>`_.
             This value becomes invalid when the session is disconnected.

    :rtype:  number
