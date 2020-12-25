.. _box_schema-user_drop:

===============================================================================
box.schema.user.drop()
===============================================================================

.. module:: box.schema

.. function:: box.schema.user.drop(user-name [, {options}])

    Drop a user.
    For explanation of how Tarantool maintains user data, see
    section :ref:`Users <authentication-users>` and reference on
    :ref:`_user <box_space-user>` space.

    :param string user-name: the name of the user
    :param table options: ``if_exists`` = ``true|false`` (default = ``false``) - boolean;
                          ``true`` means there should be no error if the user does not exist.

    **Examples:**

    .. code-block:: lua

        box.schema.user.drop('Lena')
        box.schema.user.drop('Lena',{if_exists=false})
