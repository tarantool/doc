..  _configuration_etcd:

Storing configuration in etcd
=============================

..  admonition:: Enterprise Edition
    :class: fact

    Centralized configuration is supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

..  TODO
    https://github.com/tarantool/doc/issues/3658

    - Install and configure etcd (authentication, TLS)
    - Local etcd configuration (mention env vars)
        - endpoints
        - key prefix
        - auth
        - TLS
        - http (timeout, socket)
    - Put a remote config
        - etcdctl put
        - tt cluster publish
    - Show cluster config
        - etcdctl get
        - tt cluster show
    - Start app
        - Local config
        - Env vars
    - Reload config
        - auto
        - manual (config.reload)


    Local config (``config.yaml``):

    ..  literalinclude:: /code_snippets/test/config/etcd.yaml
        :language: yaml
        :dedent:

    Remote config (``remote_config.yaml``):

    ..  literalinclude:: /code_snippets/test/config/replicaset_manual.yaml
        :language: yaml
        :dedent:

    Put a remote config:

    .. code-block:: console

        $ etcdctl put /example/config/all.yaml < remote_config.yaml

    Put a remote config using ``tt cluster``:

    .. code-block:: console

        $ tt cluster publish "http://localhost:2379/tt" remote_config.yaml

    Searches keys by the following path: ``/prefix/config/*``.
    See https://github.com/tarantool/doc/issues/3725

    Manual:

    .. code-block:: yaml

        config:
          reload: 'manual'

    Reload config (on all instances):

    .. code-block:: lua

        require('config'):reload()

    Authentication:

    .. code-block:: console

        $ etcdctl --user root --password foobar role grant-permission tt readwrite /tt/config/all
        $ etcdctl --user root --password foobar role grant-permission tt --prefix=true readwrite /tt/

        $ etcdctl --user root --password foobar user grant-role testuser tt


    .. code-block:: yaml

        config:
          etcd:
            http:
              request:
                timeout: 3
            prefix: /tt
            endpoints:
            - http://localhost:2379
            username: testuser
            password: foobar

