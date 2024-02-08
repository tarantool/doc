..  _configuration_credentials:

Credentials
===========

Tarantool enables flexible management of access to various database resources by providing specific privileges to users.
You can read more about the main concepts of Tarantool access control system in the :ref:`authentication` section.

This topic describes how to create users and grant them the specified privileges in the :ref:`credentials <configuration_reference_credentials>` section of a YAML configuration.
This might be used to create specific users used in communications between Tarantool instances.
For example, such users can be created to maintain :ref:`replication <replication-master_replica_configuring_credentials>` and sharding in a Tarantool cluster.


.. _configuration_credentials_managing_users_roles:

Managing users and roles
------------------------

.. _configuration_credentials_managing_users_roles_creating_user:

Creating a user
~~~~~~~~~~~~~~~

You can create new or configure credentials of the existing users in the :ref:`credentials.users <configuration_reference_credentials_users>` section.

In the example below, a ``dbadmin`` user without a password is created:

.. code-block:: yaml

    credentials:
      users:
        dbadmin: {}

To set a password, use the :ref:`credentials.users.\<username\>.password <configuration_reference_credentials_users_name_password>` option:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/credentials/config.yaml
    :language: yaml
    :start-at: credentials:
    :end-at: T0p_Secret
    :dedent:

.. _configuration_credentials_managing_users_roles_granting_privileges:

Granting privileges to a user
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To assign a role to a user, use the :ref:`credentials.users.\<username\>.roles <configuration_reference_credentials_users_name_roles>` option.
In this example, the ``dbadmin`` user gets privileges granted to the ``super`` built-in role:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/credentials/config.yaml
    :language: yaml
    :start-at: credentials:
    :end-at: [ super ]
    :dedent:

To create a new role, define it in the :ref:`credentials.roles.* <configuration_reference_credentials_roles_options>` section.
In the example below, the ``writers_space_reader`` role gets privileges to select data in the ``writers`` space:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/credentials/config.yaml
    :language: yaml
    :start-after: spaces: [ books ]
    :end-at: spaces: [ writers ]
    :dedent:

Then, you can assign this role to a user using :ref:`credentials.users.\<username\>.roles <configuration_reference_credentials_users_name_roles>` (``sampleuser`` in the example below):

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/credentials/config.yaml
    :language: yaml
    :start-at: sampleuser:
    :end-at: [ writers_space_reader ]
    :dedent:

Apart from assigning a role to a user, you can grant specific privileges directly using :ref:`credentials.users.\<username\>.privileges <configuration_reference_credentials_users_name_privileges>`.
In this example, ``sampleuser`` gets privileges to select and modify data in the ``books`` space:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/credentials/config.yaml
    :language: yaml
    :start-at: sampleuser:
    :end-at: [ books ]
    :dedent:

You can find the full example here: `credentials <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/credentials>`_.



.. _configuration_credentials_loading_secrets:

Loading secrets from safe storage
---------------------------------

Tarantool enables you to load secrets from safe storage such as external files or environment variables.
To do this, you need to define corresponding options in the :ref:`config.context <configuration_reference_config_context_options>` section.
In the examples below, ``context.dbadmin_password`` and ``context.sampleuser_password`` define how to load user passwords from ``*.txt`` files or environment variables:

*   This example shows how to load passwords from ``*.txt`` files:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/credentials_context_file/config.yaml
        :language: yaml
        :start-at: config:
        :end-before: credentials:
        :dedent:

*   This example shows how to load passwords from environment variables:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/credentials_context_env/config.yaml
        :language: yaml
        :start-at: config:
        :end-before: credentials:
        :dedent:

    These environment variables should be set before :ref:`starting instances <configuration_run_instance>`.

After configuring how to load passwords, you can set password values using :ref:`credentials.users.\<username\>.password <configuration_reference_credentials_users_name_password>` as follows:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/credentials_context_env/config.yaml
    :language: yaml
    :start-at: credentials:
    :end-at: context.sampleuser_password
    :dedent:

You can find the full examples here: `credentials_context_file <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/credentials_context_file>`_, `credentials_context_env <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/credentials_context_env>`_.
