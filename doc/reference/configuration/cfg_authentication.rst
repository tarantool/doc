.. _cfg_authentication:

..  admonition:: Enterprise Edition
    :class: fact

    Authentication features are supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

* :ref:`auth_delay <cfg_auth_delay>`
* :ref:`auth_retries <cfg_auth_retries>`
* :ref:`auth_type <cfg_auth_type>`
* :ref:`disable_guest <cfg_disable_guest>`
* :ref:`password_min_length <cfg_password_min_length>`
* :ref:`password_enforce_uppercase <cfg_password_enforce_uppercase>`
* :ref:`password_enforce_lowercase <cfg_password_enforce_lowercase>`
* :ref:`password_enforce_digits <cfg_password_enforce_digits>`
* :ref:`password_enforce_specialchars <cfg_password_enforce_specialchars>`
* :ref:`password_lifetime_days <cfg_password_lifetime_days>`
* :ref:`password_history_length <cfg_password_history_length>`


.. _cfg_auth_delay:

.. confval:: auth_delay

    Since :doc:`2.11.0 </release/2.11.0>`.

    Specifies a period of time (in seconds) that a specific user should wait
    for the next attempt after failed authentication.

    With the configuration below, Tarantool refuses the authentication attempt if the previous
    attempt was less than 5 seconds ago.

    .. code-block:: lua

        box.cfg{ auth_delay = 5 }


    | Type: number
    | Default: 0
    | Environment variable: TT_AUTH_DELAY
    | Dynamic: yes

.. _cfg_auth_retries:

.. confval:: auth_retries

    Since :doc:`3.0.0 </release/3.0.0>`.

    Specify the maximum number of authentication retries allowed before ``auth_delay`` is enforced.
    The default value is 0, which means ``auth_delay`` is enforced after the first failed authentication attempt.

    The retry counter is reset after ``auth_delay`` seconds since the first failed attempt.
    For example, if a client tries to authenticate fewer than ``auth_retries`` times within ``auth_delay`` seconds, no authentication delay is enforced.
    The retry counter is also reset after any successful authentication attempt.

    | Type: number
    | Default: 0
    | Environment variable: TT_AUTH_RETRIES
    | Dynamic: yes


.. _cfg_auth_type:

.. confval:: auth_type

    Since :doc:`2.11.0 </release/2.11.0>`.

    Specify an authentication protocol:

    - 'chap-sha1': use the `CHAP <https://en.wikipedia.org/wiki/Challenge-Handshake_Authentication_Protocol>`_ protocol to authenticate users with ``SHA-1`` hashing applied to :ref:`passwords <authentication-passwords>`.
    - 'pap-sha256': use `PAP <https://en.wikipedia.org/wiki/Password_Authentication_Protocol>`_ authentication with the ``SHA256`` hashing algorithm.

    For new users, the :doc:`box.schema.user.create </reference/reference_lua/box_schema/user_create>` method
    will generate authentication data using ``PAP-SHA256``.
    For existing users, you need to reset a password using
    :doc:`box.schema.user.passwd </reference/reference_lua/box_schema/user_passwd>`
    to use the new authentication protocol.

    | Type: string
    | Default value: 'chap-sha1'
    | Environment variable: TT_AUTH_TYPE
    | Dynamic: yes


.. _cfg_disable_guest:

.. confval:: disable_guest

    Since :doc:`2.11.0 </release/2.11.0>`.

    If **true**, disables access over remote connections
    from unauthenticated or :ref:`guest access <authentication-passwords>` users.
    This option affects both
    :doc:`net.box </reference/reference_lua/net_box>` and
    :ref:`replication <replication-master_replica_bootstrap>` connections.

    | Type: boolean
    | Default: false
    | Environment variable: TT_DISABLE_GUEST
    | Dynamic: yes

.. _cfg_password_min_length:

.. confval:: password_min_length

    Since :doc:`2.11.0 </release/2.11.0>`.

    Specifies the minimum number of characters for a password.

    The following example shows how to set the minimum password length to 10.

    .. code-block:: lua

        box.cfg{ password_min_length = 10 }

    | Type: integer
    | Default: 0
    | Environment variable: TT_PASSWORD_MIN_LENGTH
    | Dynamic: yes


.. _cfg_password_enforce_uppercase:

.. confval:: password_enforce_uppercase

    Since :doc:`2.11.0 </release/2.11.0>`.

    If **true**, a password should contain uppercase letters (A-Z).

    | Type: boolean
    | Default: false
    | Environment variable: TT_PASSWORD_ENFORCE_UPPERCASE
    | Dynamic: yes


.. _cfg_password_enforce_lowercase:

.. confval:: password_enforce_lowercase

    Since :doc:`2.11.0 </release/2.11.0>`.

    If **true**, a password should contain lowercase letters (a-z).

    | Type: boolean
    | Default: false
    | Environment variable: TT_PASSWORD_ENFORCE_LOWERCASE
    | Dynamic: yes


.. _cfg_password_enforce_digits:

.. confval:: password_enforce_digits

    Since :doc:`2.11.0 </release/2.11.0>`.

    If **true**, a password should contain digits (0-9).

    | Type: boolean
    | Default: false
    | Environment variable: TT_PASSWORD_ENFORCE_DIGITS
    | Dynamic: yes


.. _cfg_password_enforce_specialchars:

.. confval:: password_enforce_specialchars

    Since :doc:`2.11.0 </release/2.11.0>`.

    If **true**, a password should contain at least one special character (such as ``&|?!@$``).

    | Type: boolean
    | Default: false
    | Environment variable: TT_PASSWORD_ENFORCE_SPECIALCHARS
    | Dynamic: yes


.. _cfg_password_lifetime_days:

.. confval:: password_lifetime_days

    Since :doc:`2.11.0 </release/2.11.0>`.

    Specifies the maximum period of time (in days) a user can use the same password.
    When this period ends, a user gets the "Password expired" error on a login attempt.
    To restore access for such users, use :doc:`box.schema.user.passwd </reference/reference_lua/box_schema/user_passwd>`.

    .. note::

        The default 0 value means that a password never expires.

    The example below shows how to set a maximum password age to 365 days.

    .. code-block:: lua

        box.cfg{ password_lifetime_days = 365 }

    | Type: integer
    | Default: 0
    | Environment variable: TT_PASSWORD_LIFETIME_DAYS
    | Dynamic: yes


.. _cfg_password_history_length:

.. confval:: password_history_length

    Since :doc:`2.11.0 </release/2.11.0>`.

    Specifies the number of unique new user passwords before an old password can be reused.

    In the example below, a new password should differ from the last three passwords.

    .. code-block:: lua

        box.cfg{ password_history_length = 3 }

    | Type: integer
    | Default: 0
    | Environment variable: TT_PASSWORD_HISTORY_LENGTH
    | Dynamic: yes

    .. note::
        Tarantool uses the ``auth_history`` field in the
        :doc:`box.space._user </reference/reference_lua/box_space/_user>`
        system space to store user passwords.

