
.. _box_session-uid:

================================================================================
box.session.uid()
================================================================================

.. module:: box.session

.. function:: uid()

    :return: the user ID of the :ref:`current user <authentication-users>`.

    :rtype:  number

    Every user has a unique name (seen with
    :doc:`/reference/reference_lua/box_session/user`)
    and a unique ID (seen with ``box.session.uid()``).
    The values are stored together in the ``_user`` space.