..  _configuration_authentication:

Authentication
==============

..  admonition:: Enterprise Edition
    :class: fact

    Authentication features are supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

.. _enterprise-auth-restrictions:

Authentication restrictions
---------------------------

Tarantool Enterprise Edition provides the ability to apply additional restrictions for user authentication.
For example, you can specify the minimum time between authentication attempts
or turn off access for guest users.

In the configuration below, :ref:`security.auth_retries <configuration_reference_security_auth_retries>` is set to ``2``,
which means that Tarantool lets a client try to authenticate with the same username three times.
At the fourth attempt, the authentication delay configured with :ref:`security.auth_delay <configuration_reference_security_auth_delay>` is enforced.
This means that a client should wait 10 seconds after the first failed attempt.

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/security_auth_restrictions/config.yaml
    :language: yaml
    :start-at: security:
    :end-at: disable_guest
    :dedent:

The :ref:`disable_guest <configuration_reference_security_disable_guest>` option turns off access over remote connections from unauthenticated or :ref:`guest <authentication-passwords>` users.


.. _enterprise-password-policy:

Password policy
---------------

A password policy allows you to improve database security by enforcing the use
of strong passwords, setting up a maximum password age, and so on.
When you create a new user with
:doc:`box.schema.user.create </reference/reference_lua/box_schema/user_create>`
or update the password of an existing user with
:doc:`box.schema.user.passwd </reference/reference_lua/box_schema/user_passwd>`,
the password is checked against the configured password policy settings.

In the example below, the following options are specified:

-   :ref:`password_min_length <configuration_reference_security_password_min_length>` specifies that a password should be at least 16 characters.
-   :ref:`password_enforce_lowercase <configuration_reference_security_password_enforce_lowercase>` and :ref:`password_enforce_uppercase <configuration_reference_security_password_enforce_uppercase>` specify that a password should contain lowercase and uppercase letters.
-   :ref:`password_enforce_digits <configuration_reference_security_password_enforce_digits>` and :ref:`password_enforce_specialchars <configuration_reference_security_password_enforce_specialchars>` specify that a password should contain digits and at least one special character.
-   :ref:`password_lifetime_days <configuration_reference_security_password_lifetime_days>` sets a maximum password age to 365 days.
-   :ref:`password_history_length <configuration_reference_security_password_history_length>` specifies that a new password should differ from the last three passwords.

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/security_password_policy/config.yaml
    :language: yaml
    :start-at: security:
    :end-at: password_history_length
    :dedent:




.. _enterprise-authentication-protocol:

Authentication protocol
-----------------------

By default, Tarantool uses the
`CHAP <https://en.wikipedia.org/wiki/Challenge-Handshake_Authentication_Protocol>`_
protocol to authenticate users and applies ``SHA-1`` hashing to
:ref:`passwords <authentication-passwords>`.
Note that CHAP stores password hashes in the ``_user`` space unsalted.
If an attacker gains access to the database, they may crack a password, for example, using a `rainbow table <https://en.wikipedia.org/wiki/Rainbow_table>`_.

In the Enterprise Edition, you can enable
`PAP <https://en.wikipedia.org/wiki/Password_Authentication_Protocol>`_ authentication
with the ``SHA256`` hashing algorithm.
For PAP, a password is salted with a user-unique salt before saving it in the database,
which keeps the database protected from cracking using a rainbow table.

To enable PAP, specify the :ref:`security.auth_type <configuration_reference_security_auth_type>` option as follows:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/security_auth_protocol/config.yaml
    :language: yaml
    :start-at: security:
    :end-at: pap-sha256
    :dedent:

For new users, the :doc:`box.schema.user.create </reference/reference_lua/box_schema/user_create>` method generates authentication data using ``PAP-SHA256``.
For existing users, you need to reset a password using
:doc:`box.schema.user.passwd </reference/reference_lua/box_schema/user_passwd>`
to use the new authentication protocol.

.. warning::

    Given that ``PAP`` transmits a password as plain text,
    Tarantool requires configuring :ref:`SSL/TLS <configuration_connections_ssl>`
    for a connection.

The example below shows how to specify the authentication protocol using the ``auth_type`` parameter when connecting to an instance using :doc:`net.box </reference/reference_lua/net_box>`:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/security_auth_protocol/myapp.lua
    :language: lua
    :start-at: local connection
    :end-before: return connection
    :dedent:

If the authentication protocol isn't specified explicitly on the client side,
the client uses the protocol configured on the server via ``security.auth_type``.
