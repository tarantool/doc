.. _box_schema-user_create:

===============================================================================
box.schema.user.create()
===============================================================================

.. module:: box.schema

.. function:: box.schema.user.create(name [, {options}])

    Create a user.
    For explanation of how Tarantool maintains user data, see
    section :ref:`Users<authentication-users>` and reference on
    :ref:`_user <box_space-user>` space.

    The possible options are:

    * ``if_not_exists`` = ``true|false`` (default = ``false``) - boolean;
      ``true`` means there should be no error if the user already exists,

    * ``password`` (default = '') - string; the ``password`` = *password*
      specification is good because in a :ref:`URI <index-uri>`
      (Uniform Resource Identifier) it is usually illegal to include a
      username without a password.

    .. NOTE::

        The maximum number of users is 32.

    :param string name: a user name, which should conform to the :ref:`rules for object names <app_server-names>`
    :param table options: ``if_not_exists``, ``password``

    :return: nil

    **Examples:**

    ..  literalinclude:: /code_snippets/test/access_control/grant_user_privileges_test.lua
        :language: lua
        :start-after: Create a user with a password
        :end-before: End: Create a user with a password
        :dedent:

    See also: :ref:`access_control_users`.
