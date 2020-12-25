.. _box_schema-user_exists:

===============================================================================
box.schema.user.exists()
===============================================================================

.. module:: box.schema

.. function:: box.schema.user.exists(user-name)

    Return ``true`` if a user exists; return ``false`` if a user does not exist.
    For explanation of how Tarantool maintains user data, see
    section :ref:`Users <authentication-users>` and reference on
    :ref:`_user <box_space-user>` space.

    :param string user-name: the name of the user
    :rtype: bool

    **Example:**

    .. code-block:: lua

        box.schema.user.exists('Lena')
