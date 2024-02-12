.. _box_schema-user_drop:

===============================================================================
box.schema.user.drop()
===============================================================================

.. module:: box.schema

.. function:: box.schema.user.drop(username [, {options}])

    Drop a user.
    For explanation of how Tarantool maintains user data, see
    section :ref:`Users <authentication-users>` and reference on
    :ref:`_user <box_space-user>` space.

    :param string username: the name of the user
    :param table options: ``if_exists`` = ``true|false`` (default = ``false``) - boolean;
                          ``true`` means there should be no error if the user does not exist.

    **Examples:**

    ..  literalinclude:: /code_snippets/test/access_control/grant_user_privileges_test.lua
        :language: lua
        :start-after: Drop a user
        :end-before: End: Drop a user
        :dedent:

    See also: :ref:`access_control_users`.
