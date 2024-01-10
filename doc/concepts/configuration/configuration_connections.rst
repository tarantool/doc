..  _configuration_connections:

Connections
===========

Communicating to Tarantool instances is required for different purposes, for example:

-   Communicating between replica set peers or cluster members.
-   Connecting to cluster members for administration using :ref:`tt <tt-cli>`.
-   Managing clusters using :ref:`Tarantool Cluster Manager <tcm>`.
-   Connecting to an instance using the :ref:`net.box <net_box-module>` module or :ref:`connectors <index-box_connectors>` for different languages.

For communication to and between cluster instances, Tarantool uses a binary protocol called :ref:`iproto <box_protocol>`.
The corresponding :ref:`iproto <configuration_reference_iproto>` section in :ref:`YAML configuration <configuration>` lets you configure various connection settings:

-   One or several URIs used to listen for incoming requests.
-   Settings used advertise an instance to other cluster members.
-   SSL settings used to secure connections.


.. _configuration_connections_listen_uri:

Listen URI
----------

To configure URIs used to listen for incoming requests, use the :ref:`iproto.listen <configuration_reference_iproto_listen>` configuration option.

.. _configuration_connections_listen_address:

One listen address
~~~~~~~~~~~~~~~~~~

The example below shows how to set a listening IP address for ``instance001`` to ``127.0.0.1:3301``:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/iproto_listen_address/config.yaml
    :start-at: instance001
    :end-at: '127.0.0.1:3301'
    :language: yaml
    :dedent:

.. _configuration_connections_listen_addresses:

Multiple listen addresses
~~~~~~~~~~~~~~~~~~~~~~~~~

In this example, ``instance001`` listens on two IP addresses:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/iproto_listen_addresses/config.yaml
    :start-at: instance001
    :end-at: '127.0.0.1:3302'
    :language: yaml
    :dedent:

.. _configuration_connections_listen_port:

Listen port
~~~~~~~~~~~

You can pass only a port value to ``iproto.listen``:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/iproto_listen_port/config.yaml
    :start-at: instance001
    :end-at: '3301'
    :language: yaml
    :dedent:

In this case, this port is used for all IP addresses the server listens on.


.. _configuration_connections_listen_ssl:

SSL parameters
~~~~~~~~~~~~~~

You can enable :ref:`traffic encryption <configuration_connections_ssl>` for a connection using the ``params`` section of the specified URI:

..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/ssl_without_ca/config.yaml
    :language: yaml
    :start-at: instance001:
    :end-before: instance002:
    :dedent:


.. _configuration_connections_unix_socket:

Unix domain socket
~~~~~~~~~~~~~~~~~~

For local development, you can enable communication between cluster members by using Unix domain sockets:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/iproto_listen_socket/config.yaml
    :start-at: instance001
    :end-at: tarantool.iproto
    :language: yaml
    :dedent:




.. _configuration_connections_advertise:

Advertise settings
------------------

Advertise settings (:ref:`iproto.advertise.* <configuration_reference_iproto_advertise>`) let other cluster members or clients know how to connect to the current Tarantool instance.
These settings might include the credentials required to connect to this instance, a URI used to listen for incoming requests, and SSL settings.

If an advertise URI is not specified explicitly, a :ref:`listen URI <configuration_connections_listen_uri>` of this instance is used.
In this case, you need at least to specify credentials for connecting to this instance.

..  NOTE::

    If several listen URIs are specified, the first one is used as an advertise URI.

.. _configuration_connections_advertise_credentials:

Connection credentials
~~~~~~~~~~~~~~~~~~~~~~

In the example below, the ``iproto.advertise.peer`` option is used to inform other replica set members that the ``replicator`` user should be used to connect to the current instance:

..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/advertise_peer/config.yaml
    :language: yaml
    :start-after: roles: [replication]
    :end-at: login: replicator
    :dedent:

In a sharded cluster, ``iproto.advertise.sharding`` specifies that a router and rebalancer should use the ``storage`` user to connect to storages:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/config.yaml
    :language: yaml
    :start-at: iproto
    :end-at: login: storage
    :dedent:


.. _configuration_connections_advertise_explicitly:

Advertise URI
~~~~~~~~~~~~~

If required, you can specify an advertise URI explicitly by setting up the :ref:`iproto_advertise.\<peer_or_sharding\>.uri <configuration_reference_iproto_advertise.peer_sharding.uri>` option.
In the example below, ``iproto.listen`` includes two URIs that can be used to connect to ``instance001`` but only the second one is used to advertise this instance to other replica set peers:

..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/advertise_peer/config.yaml
    :language: yaml
    :start-at: instance001:
    :end-before: instance002:
    :dedent:

The ``iproto_advertise.<peer_or_sharding>.uri`` option can also accept an FQDN instead of an IP address:

..  code-block:: yaml

    instance001:
      iproto:
        listen:
        - uri: '192.168.0.101:3301'
        advertise:
          peer:
            uri: 'server001.example.com:3301'


.. _configuration_connections_advertise_uri_ssl:

SSL parameters
~~~~~~~~~~~~~~

:ref:`SSL parameters <configuration_connections_ssl>` for an advertise URI should be set only if this :ref:`advertise URI is specified explicitly <configuration_connections_advertise_explicitly>`.
Otherwise, SSL parameters of a listen URI are used and no additional configuration is required.

Configuring an advertise URI's SSL options depends on whether a trusted certificate authorities (CA) file is set or not.
Without the CA file, you only need to set ``iproto_advertise.<peer_or_sharding>.params.transport`` to ``ssl`` as shown below:

..  code-block:: yaml

    instance001:
      iproto:
        listen:
        - uri: '192.168.0.101:3301'
          params:
            transport: 'ssl'
            ssl_cert_file: 'certs/server.crt'
            ssl_key_file: 'certs/server.key'
        advertise:
          peer:
            uri: 'server.example.com:3301'
            params:
              transport: 'ssl'


If the CA file is specified for a listen URI, you also need to configure ``ssl_cert_file`` and ``ssl_key_file`` for this advertise URI:

..  code-block:: yaml

    instance001:
      iproto:
        listen:
        - uri: '192.168.0.101:3301'
          params:
            transport: 'ssl'
            ssl_ca_file: 'certs/root_ca.crt'
            ssl_cert_file: 'certs/instance001/server001.crt'
            ssl_key_file: 'certs/instance001/server001.key'
        advertise:
          peer:
            uri: 'server001.example.com:3301'
            params:
              transport: 'ssl'
              ssl_cert_file: 'certs/instance001/server001.crt'
              ssl_key_file: 'certs/instance001/server001.key'


.. _configuration_connections_ssl:
.. _enterprise-iproto-encryption:
.. _enterprise-iproto-encryption-config:

Securing connections with SSL
-----------------------------

..  admonition:: Enterprise Edition
    :class: fact

    SSL is supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

Tarantool supports the use of SSL connections to encrypt client-server communications for increased security.
To enable SSL, use the :ref:`<uri>.params.* <configuration_reference_iproto_uri_params>` options, which can be applied to both listen and advertise URIs.

This section shows how to configure SSL settings for a listen URI.
To learn about the specifics of configuring an advertise URI's SSL settings, see :ref:`SSL parameters <configuration_connections_advertise_uri_ssl>`.


.. _configuration_connections_ssl_without_ca:

Without CA
~~~~~~~~~~

The example below demonstrates how to enable traffic encryption by using a self-signed server certificate.
The following parameters are specified for each instance:

-   ``ssl_cert_file``: a path to an SSL certificate file.
-   ``ssl_key_file``: a path to a private SSL key file.

..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/ssl_without_ca/config.yaml
    :language: yaml
    :start-at: replicaset001:
    :dedent:

You can find the full example here: `ssl_without_ca <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/replication/instances.enabled/ssl_without_ca>`_.


.. _configuration_connections_ssl_with_ca:

With CA
~~~~~~~

The example below demonstrates how to enable traffic encryption by using a server certificate signed by a trusted certificate authority.
In this case, all replica set peers verify each other for authenticity.

The following parameters are specified for each instance:

-   ``ssl_ca_file``: a path to a trusted certificate authorities (CA) file.
-   ``ssl_cert_file``: a path to an SSL certificate file.
-   ``ssl_key_file``: a path to a private SSL key file.
-   ``ssl_password`` (``instance001``): a password for an encrypted private SSL key.
-   ``ssl_password_file`` (``instance002`` and ``instance003``): a text file containing passwords for encrypted SSL keys.
-   ``ssl_ciphers``: a colon-separated list of SSL cipher suites the connection can use.

..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/ssl_with_ca/config.yaml
    :language: yaml
    :start-at: replicaset001:
    :end-before: app:
    :dedent:

You can find the full example here: `ssl_with_ca <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/replication/instances.enabled/ssl_with_ca>`_.



.. _configuration_connections_ssl_reloading_certificates:

Reloading certificates
~~~~~~~~~~~~~~~~~~~~~~

To reload SSL certificate files specified in the configuration, open an :ref:`admin console <admin-security>` and reload the configuration using :ref:`config.reload() <config-module>`:

.. code-block:: lua

    require('config'):reload()

New certificates will be used for new connections.
Existing connections will continue using old SSL certificates until reconnection is required.
For example, certificate expiry or a network issue causes reconnection.
