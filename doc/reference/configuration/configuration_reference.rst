..  _configuration_reference:

Configuration reference
=======================

..  TODO
    https://github.com/tarantool/doc/issues/3664

This topic describes all :ref:`configuration parameters <configuration>` provided by Tarantool.

Most of the configuration options described in this reference can be applied to a specific instance, replica set, group, or to all instances globally.
To do so, you need to define the required option at the :ref:`specified level <configuration_scopes>`.


..  _configuration_reference_config:

config
------

The ``config`` section defines various parameters related to centralized configuration.

.. NOTE::

    ``config`` can be defined in the global :ref:`scope <configuration_scopes>` only.

* :ref:`config.reload <configuration_reference_config_reload>`
* :ref:`config.etcd.* <configuration_reference_config_etcd>`

.. _configuration_reference_config_reload:

.. confval:: config.reload

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    Specify how the configuration is reloaded.
    This option accepts the following values:

    - ``auto``: configuration is reloaded automatically when it is changed.
    - ``manual``: configuration should be reloaded manually. In this case, you can reload the configuration in the application code using :ref:`config:reload() <config-module>`.

    See also: :ref:`Reloading configuration <etcd_reloading_configuration>`.

    |
    | Type: string
    | Possible values: 'auto', 'manual'
    | Default: 'auto'
    | Environment variable: TT_CONFIG_RELOAD



.. _configuration_reference_config_etcd:

config.etcd.*
~~~~~~~~~~~~~

..  include:: /concepts/configuration/configuration_etcd.rst
    :start-after: ee_note_etcd_start
    :end-before: ee_note_etcd_end

This section describes options related to :ref:`storing configuration in etcd <configuration_etcd>`.

* :ref:`config.etcd.endpoints <config_etcd_endpoints>`
* :ref:`config.etcd.prefix <config_etcd_prefix>`
* :ref:`config.etcd.username <config_etcd_username>`
* :ref:`config.etcd.password <config_etcd_password>`
* :ref:`config.etcd.ssl.ca_file <config_etcd_ssl_ca_file>`
* :ref:`config.etcd.ssl.ca_path <config_etcd_ssl_ca_path>`
* :ref:`config.etcd.ssl.ssl_key <config_etcd_ssl_ssl_key>`
* :ref:`config.etcd.ssl.verify_host <config_etcd_ssl_verify_host>`
* :ref:`config.etcd.ssl.verify_peer <config_etcd_ssl_verify_peer>`
* :ref:`config.etcd.http.request.timeout <config_etcd_http_request_timeout>`
* :ref:`config.etcd.http.request.unix_socket <config_etcd_http_request_unix_socket>`



.. _config_etcd_endpoints:

.. confval:: config.etcd.endpoints

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    The list of endpoints used to access an etcd server.

    See also: :ref:`Local etcd configuration <etcd_local_configuration>`.

    |
    | Type: array
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_ENDPOINTS


.. _config_etcd_prefix:

.. confval:: config.etcd.prefix

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A key prefix used to search a configuration on an etcd server.
    Tarantool searches keys by the following path: ``<prefix>/config/*``.
    Note that ``<prefix>`` should start with a slash (``/``).

    See also: :ref:`Local etcd configuration <etcd_local_configuration>`.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_PREFIX

.. _config_etcd_username:

.. confval:: config.etcd.username

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A username used for authentication.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_USERNAME

.. _config_etcd_password:

.. confval:: config.etcd.password

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A password used for authentication.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_PASSWORD


.. _config_etcd_ssl_ca_file:

.. confval:: config.etcd.ssl.ca_file

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A path to a trusted certificate authorities (CA) file.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_SSL_CA_FILE


.. _config_etcd_ssl_ca_path:

.. confval:: config.etcd.ssl.ca_path

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A path to a directory holding certificates to verify the peer with.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_SSL_CA_PATH


.. _config_etcd_ssl_ssl_key:

.. confval:: config.etcd.ssl.ssl_key

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A path to a private SSL key file.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_SSL_SSL_KEY


.. _config_etcd_ssl_verify_host:

.. confval:: config.etcd.ssl.verify_host

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    Enable verification of the certificate's name (CN) against the specified host.

    |
    | Type: boolean
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_SSL_VERIFY_HOST


.. _config_etcd_ssl_verify_peer:

.. confval:: config.etcd.ssl.verify_peer

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    Enable verification of the peer's SSL certificate.

    |
    | Type: boolean
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_SSL_VERIFY_PEER


.. _config_etcd_http_request_timeout:

.. confval:: config.etcd.http.request.timeout

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A time period required to process an HTTP request to an etcd server: from sending a request to receiving a response.

    |
    | Type: number
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_HTTP_REQUEST_TIMEOUT

.. _config_etcd_http_request_unix_socket:

.. confval:: config.etcd.http.request.unix_socket

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A Unix domain socket used to connect to an etcd server.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_HTTP_REQUEST_UNIX_SOCKET




..  _configuration_reference_credentials:

credentials
-----------

..  TODO: https://github.com/tarantool/doc/issues/3666

.. NOTE::

    ``credentials`` can be defined in any :ref:`scope <configuration_scopes>`.


-   :ref:`credentials.roles.* <configuration_reference_credentials_roles>`
-   :ref:`credentials.users.* <configuration_reference_credentials_users>`
-   :ref:`<user_or_role_name>.privileges.* <configuration_reference_credentials_privileges>`


.. _configuration_reference_credentials_roles:

.. confval:: credentials.roles

    | Type: map
    | Default: nil
    | Environment variable: TT_CREDENTIALS_ROLES


.. _configuration_reference_credentials_users:

.. confval:: credentials.users

    | Type: map
    | Default: nil
    | Environment variable: TT_CREDENTIALS_USERS



..  _configuration_reference_credentials_role:

credentials.roles.*
~~~~~~~~~~~~~~~~~~~

.. _configuration_reference_credentials_roles_name_roles:

.. confval:: credentials.roles.<role_name>.roles


.. _configuration_reference_credentials_roles_name_privileges:

.. confval:: credentials.roles.<role_name>.privileges

    See :ref:`privileges <configuration_reference_credentials_privileges>`.


..  _configuration_reference_credentials_user:

credentials.users.*
~~~~~~~~~~~~~~~~~~~


.. _configuration_reference_credentials_users_name_password:

.. confval:: credentials.users.<username>.password


.. _configuration_reference_credentials_users_name_roles:

.. confval:: credentials.users.<username>.roles


.. _configuration_reference_credentials_users_name_privileges:

.. confval:: credentials.users.<username>.privileges

    See :ref:`privileges <configuration_reference_credentials_privileges>`.


..  _configuration_reference_credentials_privileges:

<user_or_role_name>.privileges.*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. _configuration_reference_credentials_users_name_privileges_permissions:

.. confval:: <user_or_role_name>.privileges.permissions


.. _configuration_reference_credentials_users_name_privileges_spaces:

.. confval:: <user_or_role_name>.privileges.spaces


.. _configuration_reference_credentials_users_name_privileges_functions:

.. confval:: <user_or_role_name>.privileges.functions


.. _configuration_reference_credentials_users_name_privileges_sequences:

.. confval:: <user_or_role_name>.privileges.sequences


.. _configuration_reference_credentials_users_name_privileges_lua_eval:

.. confval:: <user_or_role_name>.privileges.lua_eval


.. _configuration_reference_credentials_users_name_privileges_lua_call:

.. confval:: <user_or_role_name>.privileges.lua_call


.. _configuration_reference_credentials_users_name_privileges_sql:

.. confval:: <user_or_role_name>.privileges.sql




..  _configuration_reference_database:

database
--------

The ``database`` section defines database-specific configuration parameters, such as an instance's read-write mode or transaction isolation level.

.. NOTE::

    ``database`` can be defined in any :ref:`scope <configuration_scopes>`.

-   :ref:`database.hot_standby <configuration_reference_database_hot_standby>`
-   :ref:`database.instance_uuid <configuration_reference_database_instance_uuid>`
-   :ref:`database.mode <configuration_reference_database_mode>`
-   :ref:`database.replicaset_uuid <configuration_reference_database_replicaset_uuid>`
-   :ref:`database.txn_isolation <configuration_reference_database_txn_isolation>`
-   :ref:`database.txn_timeout <configuration_reference_database_txn_timeout>`
-   :ref:`database.use_mvcc_engine <configuration_reference_database_use_mvcc_engine>`

.. _configuration_reference_database_hot_standby:

.. confval:: database.hot_standby

    | Type: boolean
    | Default: false
    | Environment variable: TT_DATABASE_HOT_STANDBY


.. _configuration_reference_database_instance_uuid:

.. confval:: database.instance_uuid

    An :ref:`instance UUID <replication_uuid>`.

    By default, instance UUIDs are generated automatically.
    ``database.instance_uuid`` can be used to specify an instance identifier manually.

    UUIDs should follow these rules:

    *   The values must be true unique identifiers, not shared by other instances
        or replica sets within the common infrastructure.

    *   The values must be used consistently, not changed after the initial setup.
        The initial values are stored in :ref:`snapshot files <index-box_persistence>`
        and are checked whenever the system is restarted.

        .. TODO: https://github.com/tarantool/doc/issues/3661 mention that UUIDs can be dropped during migration.

    *   The values must comply with `RFC 4122 <https://tools.ietf.org/html/rfc4122>`_.
        The `nil UUID <https://tools.ietf.org/html/rfc4122#section-4.1.7>`_ is not allowed.

    See also: :ref:`database.replicaset_uuid <configuration_reference_database_replicaset_uuid>`

    |
    | Type: string
    | Default: :ref:`box.NULL <box-null>`
    | Environment variable: TT_DATABASE_INSTANCE_UUID


.. _configuration_reference_database_mode:

.. confval:: database.mode

    An instance's operating mode.
    This option is in effect if :ref:`replication.failover <configuration_reference_replication_failover>` is set to ``off``.

    The following modes are available:

    -   ``rw``: an instance is in read-write mode.
    -   ``ro``: an instance is in read-only mode.

    If not specified explicitly, the default value depends on the number of instances in a replica set. For a single instance, the ``rw`` mode is used, while for multiple instances, the ``ro`` mode is used.

    **Example**

    You can set the ``database.mode`` option to ``rw`` on all instances in a replica set to make a :ref:`master-master <replication-roles>` configuration.
    In this case, ``replication.failover`` should be set to ``off``.

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/master_master/config.yaml
        :language: yaml
        :dedent:

    | Type: string
    | Default: :ref:`box.NULL <box-null>` (the actual default value depends on the number of instances in a replica set)
    | Environment variable: TT_DATABASE_MODE


.. _configuration_reference_database_replicaset_uuid:

.. confval:: database.replicaset_uuid

    A :ref:`replica set UUID <replication_uuid>`.

    By default, replica set UUIDs are generated automatically.
    ``database.replicaset_uuid`` can be used to specify a replica set identifier manually.

    See also: :ref:`database.instance_uuid <configuration_reference_database_instance_uuid>`

    |
    | Type: string
    | Default: :ref:`box.NULL <box-null>`
    | Environment variable: TT_DATABASE_REPLICASET_UUID


.. _configuration_reference_database_txn_isolation:

.. confval:: database.txn_isolation

    A transaction :ref:`isolation level <transaction_model_levels>`.

    |
    | Type: string
    | Default: ``best-effort``
    | Possible values: ``best-effort``, ``read-committed``, ``read-confirmed``
    | Environment variable: TT_DATABASE_TXN_ISOLATION


.. _configuration_reference_database_txn_timeout:

.. confval:: database.txn_timeout

    A timeout (in seconds) after which the transaction is rolled back.

    See also: :ref:`box.begin() <box-begin>`

    |
    | Type: number
    | Default: 3153600000 (~100 years)
    | Environment variable: TT_DATABASE_TXN_TIMEOUT


.. _configuration_reference_database_use_mvcc_engine:

.. confval:: database.use_mvcc_engine

    Whether the :ref:`transactional manager <txn_mode_transaction-manager>` is enabled.

    |
    | Type: boolean
    | Default: false
    | Environment variable: TT_DATABASE_USE_MVCC_ENGINE





..  _configuration_reference_iproto:

iproto
------

The ``iproto`` section is used to configure parameters related to communicating to and between cluster instances.

.. NOTE::

    ``iproto`` can be defined in any :ref:`scope <configuration_scopes>`.


-   :ref:`iproto.advertise.* <configuration_reference_iproto_advertise>`

    -   :ref:`iproto.advertise.client <configuration_reference_iproto_advertise_client>`
    -   :ref:`iproto.advertise.peer <configuration_reference_iproto_advertise_peer>`
    -   :ref:`iproto.advertise.sharding <configuration_reference_iproto_advertise_sharding>`
    -   :ref:`iproto.advertise.\<peer_or_sharding\>.* <configuration_reference_iproto_advertise.peer_sharding>`

-   :ref:`iproto.* <configuration_reference_iproto_misc>`

    -   :ref:`iproto.listen <configuration_reference_iproto_listen>`
    -   :ref:`iproto.net_msg_max <configuration_reference_iproto_net_msg_max>`
    -   :ref:`iproto.readahead <configuration_reference_iproto_readahead>`
    -   :ref:`iproto.threads <configuration_reference_iproto_threads>`

-   :ref:`<uri>.params.* <configuration_reference_iproto_uri_params>`



.. _configuration_reference_iproto_advertise:

iproto.advertise.*
~~~~~~~~~~~~~~~~~~


.. _configuration_reference_iproto_advertise_client:

.. confval:: iproto.advertise.client

    An URI used to advertise the current instance to clients.

    The ``iproto.advertise.client`` option accepts an URI in the following formats:

    -   An address: ``host:port``.

    -   A Unix domain socket: ``unix/:``.

    Note that this option doesn't allow to set a username and password.
    If a remote client needs this information, it should be delivered outside of the cluster configuration.

    .. host_port_limitations_start

    .. NOTE::

        The host value cannot be ``0.0.0.0``/``[::]`` and the port value cannot be ``0``.

    .. host_port_limitations_end

    |
    | Type: string
    | Default: :ref:`box.NULL <box-null>`
    | Environment variable: TT_IPROTO_ADVERTISE_CLIENT

.. _configuration_reference_iproto_advertise_peer:

.. confval:: iproto.advertise.peer

    An URI used to advertise the current instance to other cluster members.

    The ``iproto.advertise.peer`` option accepts an URI in the format described in :ref:`iproto_advertise.\<peer_or_sharding\>.* <configuration_reference_iproto_advertise.peer_sharding>`.

    **Example**

    In the example below, the following configuration options are specified:

    -   In the :ref:`credentials <configuration_reference_credentials>` section, the ``replicator`` user with the ``replication`` role is created.
    -   ``iproto.advertise.peer`` specifies that other instances should connect to an address defined in :ref:`iproto.listen <configuration_reference_iproto_listen>` using the ``replicator`` user.

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/auto_leader/config.yaml
        :language: yaml
        :start-at: credentials:
        :end-at: 127.0.0.1:3303
        :dedent:

    | Type: map
    | Environment variable: see :ref:`iproto.advertise.\<peer_or_sharding\>.* <configuration_reference_iproto_advertise.peer_sharding>`

.. _configuration_reference_iproto_advertise_sharding:

.. confval:: iproto.advertise.sharding

    An advertise URI used by a router and rebalancer.

    The ``iproto.advertise.sharding`` option accepts an URI in the format described in :ref:`iproto_advertise.\<peer_or_sharding\>.* <configuration_reference_iproto_advertise.peer_sharding>`.

    **Example**

    In the example below, the following configuration options are specified:

    -   In the :ref:`credentials <configuration_reference_credentials>` section, the ``replicator`` and ``storage`` users are created.
    -   ``iproto.advertise.peer`` specifies that other instances should connect to an address defined in :ref:`iproto.listen <configuration_reference_iproto_listen>` with the ``replicator`` user.
    -   ``iproto.advertise.sharding`` specifies that a router should connect to storages using an address defined in :ref:`iproto.listen <configuration_reference_iproto_listen>` with the ``storage`` user.

    ..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/config.yaml
        :language: yaml
        :start-at: credentials:
        :end-at: login: storage
        :dedent:

    | Type: map
    | Environment variable: see :ref:`iproto.advertise.\<peer_or_sharding\>.* <configuration_reference_iproto_advertise.peer_sharding>`


.. _configuration_reference_iproto_advertise.peer_sharding:

iproto.advertise.<peer_or_sharding>.*
*************************************

.. _configuration_reference_iproto_advertise.peer_sharding.uri:

.. confval:: iproto_advertise.<peer_or_sharding>.uri

    An URI used to advertise the current instance.

    ..  include:: /reference/configuration/configuration_reference.rst
        :start-after: host_port_limitations_start
        :end-before: host_port_limitations_end

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_IPROTO_ADVERTISE_PEER_URI, TT_IPROTO_ADVERTISE_SHARDING_URI

.. _configuration_reference_iproto_advertise.peer_sharding.login:

.. confval:: iproto_advertise.<peer_or_sharding>.login

    A username that should be used to connect to the current instance.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_IPROTO_ADVERTISE_PEER_LOGIN, TT_IPROTO_ADVERTISE_SHARDING_LOGIN

.. _configuration_reference_iproto_advertise.peer_sharding.password:

.. confval:: iproto_advertise.<peer_or_sharding>.password

    A password for the specified user.
    If a password is missing, it is taken from :ref:`credentials <configuration_reference_credentials>` for the specified username.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_IPROTO_ADVERTISE_PEER_PASSWORD, TT_IPROTO_ADVERTISE_SHARDING_PASSWORD

.. _configuration_reference_iproto_advertise.peer_sharding.params:

.. confval:: iproto_advertise.<peer_or_sharding>.params

    Additional parameters required for connecting to the current instance.
    These parameters are described in :ref:`<uri>.params.* <configuration_reference_iproto_uri_params>`.



.. _configuration_reference_iproto_misc:

iproto.*
~~~~~~~~

.. _configuration_reference_iproto_listen:

.. confval:: iproto.listen

    An array of URIs used to listen for incoming requests.
    In required, you can enable SSL for specific URIs by providing additional parameters (:ref:`<uri>.params.* <configuration_reference_iproto_uri_params>`).

    These URIs are used for different purposes, for example:

    -   Communicating between replica set peers or cluster members.
    -   Remote administration using :ref:`tt connect <tt-connect>`.
    -   Connecting to an instance using :ref:`connectors <index-box_connectors>` for different languages.

    To grant the specified privileges for connecting to an instance, use the :ref:`credentials <configuration_reference_credentials>` configuration section.

    **Example**

    In the example below, ``iproto.listen`` is set explicitly for each instance in a cluster:

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/auto_leader/config.yaml
        :language: yaml
        :start-at: groups:
        :end-before: Load sample data
        :dedent:

    See also: :ref:`Connection settings <configuration_options_connection>`.

    |
    | Type: array
    | Default: nil
    | Environment variable: TT_IPROTO_LISTEN


.. _configuration_reference_iproto_net_msg_max:

.. confval:: iproto.net_msg_max

    To handle messages, Tarantool allocates :ref:`fibers <app-fibers>`.
    To prevent fiber overhead from affecting the whole system,
    Tarantool restricts how many messages the fibers handle,
    so that some pending requests are blocked.

    -   On powerful systems, increase ``net_msg_max``, and the scheduler
        starts processing pending requests immediately.

    -   On weaker systems, decrease ``net_msg_max``, and the overhead
        may decrease. Although this may take some time because the
        scheduler must wait until already-running requests finish.

    When ``net_msg_max`` is reached,
    Tarantool suspends processing of incoming packages until it
    has processed earlier messages. This is not a direct restriction of
    the number of fibers that handle network messages, rather it
    is a system-wide restriction of channel bandwidth.
    This in turn restricts the number of incoming
    network messages that the
    :ref:`transaction processor thread <thread_model>`
    handles, and therefore indirectly affects the fibers that handle
    network messages.

    .. NOTE::

        The number of fibers is smaller than the number of messages because
        messages can be released as soon as they are delivered, while
        incoming requests might not be processed until some time after delivery.

    | Type: integer
    | Default: 768
    | Environment variable: TT_IPROTO_NET_MSG_MAX


.. _configuration_reference_iproto_readahead:

.. confval:: iproto.readahead

    The size of the read-ahead buffer associated with a client connection.
    The larger the buffer, the more memory an active connection consumes, and the
    more requests can be read from the operating system buffer in a single
    system call.

    The recommendation is to make sure that the buffer can contain at least a few dozen requests.
    Therefore, if a typical tuple in a request is large, e.g. a few kilobytes or even megabytes, the read-ahead buffer size should be increased.
    If batched request processing is not used, it’s prudent to leave this setting at its default.

    |
    | Type: integer
    | Default: 16320
    | Environment variable: TT_IPROTO_READAHEAD


.. _configuration_reference_iproto_threads:

.. confval:: iproto.threads

    The number of :ref:`network threads <thread_model>`.
    There can be unusual workloads where the network thread
    is 100% loaded and the transaction processor thread is not, so the network
    thread is a bottleneck.
    In that case, set ``iproto_threads`` to 2 or more.
    The operating system kernel determines which connection goes to
    which thread.

    |
    | Type: integer
    | Default: 1
    | Environment variable: TT_IPROTO_THREADS


.. _configuration_reference_iproto_uri_params:

<uri>.params.*
~~~~~~~~~~~~~~

.. _configuration_reference_iproto_uri_params_transport:

.. confval:: <uri>.params.transport

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_IPROTO_ADVERTISE_PEER_PARAMS_TRANSPORT, TT_IPROTO_ADVERTISE_SHARDING_PARAMS_TRANSPORT

.. _configuration_reference_iproto_uri_params_ssl_ca_file:

.. confval:: <uri>.params.ssl_ca_file

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_IPROTO_ADVERTISE_PEER_PARAMS_SSL_CA_FILE, TT_IPROTO_ADVERTISE_SHARDING_PARAMS_SSL_CA_FILE

.. _configuration_reference_iproto_uri_params_ssl_cert_file:

.. confval:: <uri>.params.ssl_cert_file

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_IPROTO_ADVERTISE_PEER_PARAMS_SSL_CERT_FILE, TT_IPROTO_ADVERTISE_SHARDING_PARAMS_SSL_CERT_FILE

.. _configuration_reference_iproto_uri_params_ssl_ciphers:

.. confval:: <uri>.params.ssl_ciphers

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_IPROTO_ADVERTISE_PEER_PARAMS_SSL_CIPHERS, TT_IPROTO_ADVERTISE_SHARDING_PARAMS_SSL_CIPHERS

.. _configuration_reference_iproto_uri_params_ssl_key_file:

.. confval:: <uri>.params.ssl_key_file

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_IPROTO_ADVERTISE_PEER_PARAMS_SSL_KEY_FILE, TT_IPROTO_ADVERTISE_SHARDING_PARAMS_SSL_KEY_FILE

.. _configuration_reference_iproto_uri_params_ssl_password:

.. confval:: <uri>.params.ssl_password

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_IPROTO_ADVERTISE_PEER_PARAMS_SSL_PASSWORD, TT_IPROTO_ADVERTISE_SHARDING_PARAMS_SSL_PASSWORD

.. _configuration_reference_iproto_uri_params_ssl_password_file:

.. confval:: <uri>.params.ssl_password_file

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_IPROTO_ADVERTISE_PEER_PARAMS_SSL_PASSWORD_FILE, TT_IPROTO_ADVERTISE_SHARDING_PARAMS_SSL_PASSWORD_FILE





..  _configuration_reference_groups:

groups
------

The ``groups`` section provides the ability to define the :ref:`full topology of a Tarantool cluster <configuration_overview>`.

.. NOTE::

    ``groups`` can be defined in the global :ref:`scope <configuration_scopes>` only.

-   :ref:`groups.\<group_name\> <configuration_reference_groups_name>`
-   :ref:`groups.\<group_name\>.replicasets <configuration_reference_groups_name_replicasets>`
-   :ref:`groups.\<group_name\>.\<config_parameter\> <configuration_reference_groups_name_config_parameter>`

.. _configuration_reference_groups_name:

.. confval:: groups.<group_name>

    A group name.


.. _configuration_reference_groups_name_replicasets:

.. confval:: groups.<group_name>.replicasets

    Replica sets that belong to this group. See :ref:`replicasets <configuration_reference_replicasets>`.


.. _configuration_reference_groups_name_config_parameter:

.. confval:: groups.<group_name>.<config_parameter>

    Any configuration parameter that can be defined in the group :ref:`scope <configuration_scopes>`.
    For example, :ref:`iproto <configuration_reference_iproto>` and :ref:`database <configuration_reference_database>` configuration parameters defined at the group level are applied to all instances in this group.



..  _configuration_reference_replicasets:

replicasets
~~~~~~~~~~~

.. NOTE::

    ``replicasets`` can be defined in the group :ref:`scope <configuration_scopes>` only.

-   :ref:`replicasets.\<replicaset_name\> <configuration_reference_replicasets_name>`
-   :ref:`replicasets.\<replicaset_name\>.leader <configuration_reference_replicasets_name_leader>`
-   :ref:`replicasets.\<replicaset_name\>.bootstrap_leader <configuration_reference_replicasets_name_bootstrap_leader>`
-   :ref:`replicasets.\<replicaset_name\>.instances <configuration_reference_replicasets_name_instances>`
-   :ref:`replicasets.\<replicaset_name\>.\<config_parameter\> <configuration_reference_replicasets_name_config_parameter>`

.. _configuration_reference_replicasets_name:

.. confval:: replicasets.<replicaset_name>

    A replica set name.


.. _configuration_reference_replicasets_name_leader:

.. confval:: replicasets.<replicaset_name>.leader

    A replica set leader.
    This option can be used to set a replica set leader when ``manual`` :ref:`replication.failover <configuration_reference_replication_failover>` is used.

    To perform :ref:`controlled failover <replication-controlled_failover>`, ``<replicaset_name>.leader`` can be temporarily removed or set to ``null``.

    **Example**

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/manual_leader/config.yaml
        :language: yaml
        :start-at: replication:
        :end-at: 127.0.0.1:3303
        :dedent:


.. _configuration_reference_replicasets_name_bootstrap_leader:

.. confval:: replicasets.<replicaset_name>.bootstrap_leader

    A bootstrap leader for a replica set.
    To specify a bootstrap leader manually, you need to set :ref:`replication.bootstrap_strategy <configuration_reference_replication_bootstrap_strategy>` to ``config``.

    **Example**

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/bootstrap_strategy/config.yaml
        :language: yaml
        :start-at: groups:
        :end-at: 127.0.0.1:3303
        :dedent:


.. _configuration_reference_replicasets_name_instances:

.. confval:: replicasets.<replicaset_name>.instances

    Instances that belong to this replica set. See :ref:`instances <configuration_reference_instances>`.


.. _configuration_reference_replicasets_name_config_parameter:

.. confval:: replicasets.<replicaset_name>.<config_parameter>

    Any configuration parameter that can be defined in the replica set :ref:`scope <configuration_scopes>`.
    For example, :ref:`iproto <configuration_reference_iproto>` and :ref:`database <configuration_reference_database>` configuration parameters defined at the replica set level are applied to all instances in this replica set.



..  _configuration_reference_instances:

instances
*********

.. NOTE::

    ``instances`` can be defined in the replica set :ref:`scope <configuration_scopes>` only.

-   :ref:`instances.\<instance_name\> <configuration_reference_instances_name>`
-   :ref:`instances.\<instance_name\>.\<config_parameter\> <configuration_reference_instances_name_config_parameter>`

.. _configuration_reference_instances_name:

.. confval:: instances.<instance_name>

    An instance name.


.. _configuration_reference_instances_name_config_parameter:

.. confval:: instances.<instance_name>.<config_parameter>

    Any configuration parameter that can be defined in the instance :ref:`scope <configuration_scopes>`.
    For example, :ref:`iproto <configuration_reference_iproto>` and :ref:`database <configuration_reference_database>` configuration parameters defined at the instance level are applied to this instance only.














..  _configuration_reference_replication:

replication
-----------

The ``replication`` section defines configuration parameters related to :ref:`replication <replication>`.

-   :ref:`replication.anon <configuration_reference_replication_anon>`
-   :ref:`replication.bootstrap_strategy <configuration_reference_replication_bootstrap_strategy>`
-   :ref:`replication.connect_timeout <configuration_reference_replication_connect_timeout>`
-   :ref:`replication.election_mode <configuration_reference_replication_election_mode>`
-   :ref:`replication.election_timeout <configuration_reference_replication_election_timeout>`
-   :ref:`replication.election_fencing_mode <configuration_reference_replication_election_fencing_mode>`
-   :ref:`replication.failover <configuration_reference_replication_failover>`
-   :ref:`replication.peers <configuration_reference_replication_peers>`
-   :ref:`replication.skip_conflict <configuration_reference_replication_skip_conflict>`
-   :ref:`replication.sync_lag <configuration_reference_replication_sync_lag>`
-   :ref:`replication.sync_timeout <configuration_reference_replication_sync_timeout>`
-   :ref:`replication.synchro_quorum <configuration_reference_replication_synchro_quorum>`
-   :ref:`replication.synchro_timeout <configuration_reference_replication_synchro_timeout>`
-   :ref:`replication.threads <configuration_reference_replication_threads>`
-   :ref:`replication.timeout <configuration_reference_replication_timeout>`


.. _configuration_reference_replication_anon:

.. confval:: replication.anon

    | Type: boolean
    | Default: ``false``
    | Environment variable: TT_REPLICATION_ANON


.. _configuration_reference_replication_bootstrap_strategy:

.. confval:: replication.bootstrap_strategy

    Specifies a strategy used to bootstrap a :ref:`replica set <replication-bootstrap>`.
    The following strategies are available:

    *   ``auto``: a node doesn't boot if half or more of the other nodes in a replica set are not connected.
        For example, if a replica set contains 2 or 3 nodes, a node requires 2 connected instances.
        In the case of 4 or 5 nodes, at least 3 connected instances are required.
        Moreover, a bootstrap leader fails to boot unless every connected node has chosen it as a bootstrap leader.

    *   ``config``: use the specified node to bootstrap a replica set.
        To specify the bootstrap leader, use the :ref:`<replicaset_name>.bootstrap_leader <configuration_reference_replicasets_name_bootstrap_leader>` option.

    *   ``supervised``: a bootstrap leader isn't chosen automatically but should be appointed using :ref:`box.ctl.make_bootstrap_leader() <box_ctl-make_bootstrap_leader>` on the desired node.

    *   ``legacy`` (deprecated since :doc:`2.11.0 </release/2.11.0>`): a node requires the :ref:`replication_connect_quorum <cfg_replication-replication_connect_quorum>` number of other nodes to be connected.
        This option is added to keep the compatibility with the current versions of Cartridge and might be removed in the future.

    | Type: string
    | Default: ``auto``
    | Environment variable: TT_REPLICATION_BOOTSTRAP_STRATEGY


.. _configuration_reference_replication_connect_timeout:

.. confval:: replication.connect_timeout

    A timeout (in seconds) a replica waits when trying to connect to a master in a cluster.
    See :ref:`orphan status <replication-orphan_status>` for details.

    This parameter is different from
    :ref:`replication.timeout <configuration_reference_replication_timeout>`,
    which a master uses to disconnect a replica when the master
    receives no acknowledgments of heartbeat messages.

    |
    | Type: number
    | Default: 30
    | Environment variable: TT_REPLICATION_CONNECT_TIMEOUT


.. _configuration_reference_replication_election_mode:

.. confval:: replication.election_mode

    A role of a replica set node in the :ref:`leader election process <repl_leader_elect>`.

    The possible values are:

    *   ``off``: a node doesn't participate in the election activities.

    *   ``voter``: a node can participate in the election process but can't be a leader.

    *   ``candidate``: a node should be able to become a leader.

    *   ``manual``: allow to control which instance is the leader explicitly instead of relying on automated leader election.
        By default, the instance acts like a voter -- it is read-only and may vote for other candidate instances.
        Once :ref:`box.ctl.promote() <box_ctl-promote>` is called, the instance becomes a candidate and starts a new election round.
        If the instance wins the elections, it becomes a leader but won't participate in any new elections.

    |
    | Type: string
    | Default: :ref:`box.NULL <box-null>` (the actual default value depends on :ref:`replication.failover <configuration_reference_replication_failover>`)
    | Environment variable: TT_REPLICATION_ELECTION_MODE


.. _configuration_reference_replication_election_timeout:

.. confval:: replication.election_timeout

    Specifies the timeout (in seconds) between election rounds in the
    :ref:`leader election process <repl_leader_elect>` if the previous round
    ended up with a split vote.

    It is quite big, and for most of the cases, it can be lowered to
    300-400 ms.

    To avoid the split vote repeat, the timeout is randomized on each node
    during every new election, from 100% to 110% of the original timeout value.
    For example, if the timeout is 300 ms and there are 3 nodes started
    the election simultaneously in the same term,
    they can set their election timeouts to 300, 310, and 320 respectively,
    or to 305, 302, and 324, and so on. In that way, the votes will never be split
    because the election on different nodes won't be restarted simultaneously.

    |
    | Type: number
    | Default: 5
    | Environment variable: TT_REPLICATION_ELECTION_TIMEOUT


.. _configuration_reference_replication_election_fencing_mode:

.. confval:: replication.election_fencing_mode

    Specifies the :ref:`leader fencing mode <repl_leader_elect_fencing>` that
    affects the leader election process. When the parameter is set to ``soft``
    or ``strict``, the leader resigns its leadership if it has less than
    :ref:`replication.synchro_quorum <configuration_reference_replication_synchro_quorum>`
    of alive connections to the cluster nodes.
    The resigning leader receives the status of a follower in the current election term and becomes
    read-only.

    *   In ``soft`` mode, a connection is considered dead if there are no responses for
        :ref:`4 * replication.timeout <configuration_reference_replication_timeout>` seconds both on the current leader and the followers.

    *   In ``strict`` mode, a connection is considered dead if there are no responses
        for :ref:`2 * replication.timeout <configuration_reference_replication_timeout>` seconds on the
        current leader and
        :ref:`4 * replication.timeout <configuration_reference_replication_timeout>` seconds on the
        followers. This improves the chances that there is only one leader at any time.

    Fencing applies to the instances that have the
    :ref:`replication.election_mode <configuration_reference_replication_election_mode>` set to ``candidate`` or ``manual``.
    To turn off leader fencing, set ``election_fencing_mode`` to ``off``.

    |
    | Type: string
    | Default: ``soft``
    | Possible values: ``off``, ``soft``, ``strict``
    | Environment variable: TT_REPLICATION_ELECTION_FENCING_MODE


.. _configuration_reference_replication_failover:

.. confval:: replication.failover

    A failover mode used to take over a master role when the current master instance fails.
    The following modes are available:

    -   ``off``

        Leadership in a replica set is controlled using the :ref:`database.mode <configuration_reference_database_mode>` option.
        In this case, you can set the ``database.mode`` option to ``rw`` on all instances in a replica set to make a :ref:`master-master <replication-roles>` configuration.

        The default ``database.mode`` is determined as follows: ``rw`` if there is one instance in a replica set; ``ro`` if there are several instances.

    -   ``manual``

        Leadership in a replica set is controlled using the :ref:`<replicaset_name>.leader <configuration_reference_replicasets_name_leader>` option.
        In this case, a :ref:`master-master <replication-roles>` configuration is forbidden.

        In the ``manual`` mode, the :ref:`database.mode <configuration_reference_database_mode>` option cannot be set explicitly.
        The leader is configured in the read-write mode, all the other instances are read-only.

    -   ``election``

        :ref:`Automated leader election <repl_leader_elect>` is used to control leadership in a replica set.

        In the ``election`` mode, :ref:`database.mode <configuration_reference_database_mode>` and :ref:`<replicaset_name>.leader <configuration_reference_replicasets_name_leader>` shouldn't be set explicitly.

    -   ``supervised`` (`Enterprise Edition <https://www.tarantool.io/compare/>`_ only)

        Leadership in a replica set is controlled using an external failover agent.

        In the ``supervised`` mode, :ref:`database.mode <configuration_reference_database_mode>` and :ref:`<replicaset_name>.leader <configuration_reference_replicasets_name_leader>` shouldn't be set explicitly.

        ..  TODO: https://github.com/tarantool/enterprise_doc/issues/253


    See also: :ref:`Replication tutorials <how-to-replication>`.

    .. NOTE::

        ``replication.failover`` can be defined in the global, group, and replica set :ref:`scope <configuration_scopes>`.

    **Example**

    In the example below, the following configuration options are specified:

    -   In the :ref:`credentials <configuration_reference_credentials>` section, the ``replicator`` user with the ``replication`` role is created.
    -   :ref:`iproto.advertise.peer <configuration_reference_iproto_advertise_peer>` specifies that other instances should connect to an address defined in :ref:`iproto.listen <configuration_reference_iproto_listen>` using the ``replicator`` user.
    -   ``replication.failover`` specifies that a master instance should be set manually.
    -   :ref:`<replicaset_name>.leader <configuration_reference_replicasets_name_leader>` sets ``instance001`` as a replica set leader.

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/manual_leader/config.yaml
        :language: yaml
        :end-before: Load sample data
        :dedent:

    | Type: string
    | Default: ``off``
    | Environment variable: TT_REPLICATION_FAILOVER


.. _configuration_reference_replication_peers:

.. confval:: replication.peers

    URIs of instances that constitute a replica set.
    These URIs are used by an instance to connect to another instance as a replica.

    Alternatively, you can use :ref:`iproto.advertise.peer <configuration_reference_iproto_advertise_peer>` to specify a URI used to advertise the current instance to other cluster members.

    **Example**

    In the example below, the following configuration options are specified:

    -   In the :ref:`credentials <configuration_reference_credentials>` section, the ``replicator`` user with the ``replication`` role is created.
    -   ``replication.peers`` specifies URIs of replica set instances.

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/peers/config.yaml
        :language: yaml
        :start-at: credentials:
        :end-at: - replicator:topsecret@127.0.0.1:3303
        :dedent:

    | Type: array
    | Default: :ref:`box.NULL <box-null>`
    | Environment variable: TT_REPLICATION_PEERS


.. _configuration_reference_replication_skip_conflict:

.. confval:: replication.skip_conflict

    By default, if a replica adds a unique key that another replica has
    added, replication :ref:`stops <replication-replication_stops>`
    with the ``ER_TUPLE_FOUND`` :ref:`error <error_codes>`.
    If ``replication.skip_conflict`` is set to ``true``, such errors are ignored.

    .. NOTE::

        Instead of saving the broken transaction to the write-ahead log, it is written as ``NOP`` (No operation).

    | Type: boolean
    | Default: false
    | Environment variable: TT_REPLICATION_SKIP_CONFLICT


.. _configuration_reference_replication_sync_lag:

.. confval:: replication.sync_lag

    The maximum delay (in seconds) between the time when data is written to the master and the time when it is written to a replica.
    If ``replication.sync_lag`` is set to ``nil`` or 365 * 100 * 86400 (``TIMEOUT_INFINITY``),
    a replica is always considered to be "synced".

    .. NOTE::

        This parameter is ignored during bootstrap.
        See :ref:`orphan status <replication-orphan_status>` for details.

    | Type: number
    | Default: 10
    | Environment variable: TT_REPLICATION_SYNC_LAG


.. _configuration_reference_replication_sync_timeout:

.. confval:: replication.sync_timeout

    The timeout (in seconds) that a node waits when trying to sync with
    other nodes in a replica set after connecting or during a :ref:`configuration update <replication-configuration_update>`.
    This could fail indefinitely if :ref:`replication.sync_lag <configuration_reference_replication_sync_lag>` is smaller than network latency, or if the replica cannot keep pace with master updates.
    If ``replication.sync_timeout`` expires, the replica enters :ref:`orphan status <replication-orphan_status>`.

    |
    | Type: number
    | Default: 0
    | Environment variable: TT_REPLICATION_SYNC_TIMEOUT


.. _configuration_reference_replication_synchro_quorum:

.. confval:: replication.synchro_quorum

    A number of replicas that should confirm the receipt of a :ref:`synchronous <repl_sync>` transaction before it can finish its commit.

    This option supports dynamic evaluation of the quorum number.
    For example, the default value is ``N / 2 + 1`` where ``N`` is the current number of replicas registered in a cluster.
    Once any replicas are added or removed, the expression is re-evaluated automatically.

    Note that the default value (``at least 50% of the cluster size + 1``) guarantees data reliability.
    Using a value less than the canonical one might lead to unexpected results,
    including a :ref:`split-brain <repl_leader_elect_splitbrain>`.

    ``replication.synchro_quorum`` is not used on replicas. If the master fails, the pending synchronous
    transactions will be kept waiting on the replicas until a new master is elected.

    .. NOTE::

        ``replication.synchro_quorum`` does not account for anonymous replicas.

    | Type: string, number
    | Default: ``N / 2 + 1``
    | Environment variable: TT_REPLICATION_SYNCHRO_QUORUM


.. _configuration_reference_replication_synchro_timeout:

.. confval:: replication.synchro_timeout

    For :ref:`synchronous replication <repl_sync>` only.
    Specify how many seconds to wait for a synchronous transaction quorum
    replication until it is declared failed and is rolled back.

    It is not used on replicas, so if the master fails, the pending synchronous
    transactions will be kept waiting on the replicas until a new master is
    elected.

    |
    | Type: number
    | Default: 5
    | Environment variable: TT_REPLICATION_SYNCHRO_TIMEOUT


.. _configuration_reference_replication_threads:

.. confval:: replication.threads

    The number of threads spawned to decode the incoming replication data.

    In most cases, one thread is enough for all incoming data.
    Possible values range from 1 to 1000.
    If there are multiple replication threads, connections to serve are distributed evenly between the threads.

    |
    | Type: integer
    | Default: 1
    | Environment variable: TT_REPLICATION_THREADS


.. _configuration_reference_replication_timeout:

.. confval:: replication.timeout

    A time interval (in seconds) used by a master to send heartbeat requests to a replica when there are no updates to send to this replica.
    For each request, a replica should return a heartbeat acknowledgment.

    If a master or replica gets no heartbeat message for ``4 * replication.timeout`` seconds, a connection is dropped and a replica tries to reconnect to the master.

    See also: :ref:`Monitoring a replica set <replication-monitoring>`.

    |
    | Type: number
    | Default: 1
    | Environment variable: TT_REPLICATION_TIMEOUT

