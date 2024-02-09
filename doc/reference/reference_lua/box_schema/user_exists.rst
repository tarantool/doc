.. _box_schema-user_exists:

===============================================================================
box.schema.user.exists()
===============================================================================

.. module:: box.schema

.. function:: box.schema.user.exists(username)

    Return ``true`` if a user exists; return ``false`` if a user does not exist.
    For explanation of how Tarantool maintains user data, see
    section :ref:`Users <authentication-users>` and reference on
    :ref:`_user <box_space-user>` space.

    :param string username: the name of the user
    :rtype: bool

    See also: :ref:`access_control_user_info`.
