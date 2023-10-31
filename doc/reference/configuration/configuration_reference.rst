..  _configuration_reference:

Configuration reference
=======================

This topic describes all :ref:`configuration parameters <configuration>` provided by Tarantool.

..  _configuration_reference_config:

config
------

* :ref:`config.reload <configuration_reference_config_reload>`
* :ref:`config.version <configuration_reference_config_version>`
* :ref:`config.etcd.* <configuration_reference_config_etcd>`

.. _configuration_reference_config_reload:

.. confval:: config.reload

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    Specify how the configuration is reloaded.
    This option accepts the following values:

    - ``auto``: configuration is reloaded automatically when it is changed.
    - ``manual``: configuration should be reloaded manually. In this case, you can reload the configuration in the application code using :ref:`config.reload() <config-module>`.

    See also: :ref:`Reloading configuration <etcd_reloading_configuration>`.

    | Type: string
    | Possible values: 'auto', 'manual'
    | Default: 'auto'
    | Environment variable: TT_CONFIG_RELOAD


.. _configuration_reference_config_version:

.. confval:: config.version

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A configuration version.

    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_VERSION



.. _configuration_reference_config_etcd:

etcd
~~~~

..  admonition:: Enterprise Edition
    :class: fact

    Storing configuration in etcd is supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

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

    | Type: array
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_ENDPOINTS


.. _config_etcd_prefix:

.. confval:: config.etcd.prefix

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A key prefix used to search a configuration on an etcd server.
    Tarantool searches keys by the following path: ``/prefix/config/*``.

    See also: :ref:`Local etcd configuration <etcd_local_configuration>`.

    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_PREFIX

.. _config_etcd_username:

.. confval:: config.etcd.username

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A username used for authentication.

    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_USERNAME

.. _config_etcd_password:

.. confval:: config.etcd.password

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A password used for authentication.

    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_PASSWORD


.. _config_etcd_ssl_ca_file:

.. confval:: config.etcd.ssl.ca_file

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A path to a trusted certificate authorities (CA) file.

    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_SSL_CA_FILE


.. _config_etcd_ssl_ca_path:

.. confval:: config.etcd.ssl.ca_path

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A path to a directory holding certificates to verify the peer with.

    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_SSL_CA_PATH


.. _config_etcd_ssl_ssl_key:

.. confval:: config.etcd.ssl.ssl_key

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A path to a private SSL key file.

    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_SSL_SSL_KEY


.. _config_etcd_ssl_verify_host:

.. confval:: config.etcd.ssl.verify_host

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    Enable verification of the certificate's name (CN) against the specified host.

    | Type: boolean
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_SSL_VERIFY_HOST


.. _config_etcd_ssl_verify_peer:

.. confval:: config.etcd.ssl.verify_peer

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    Enable verification of the peer's SSL certificate.

    | Type: boolean
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_SSL_VERIFY_PEER


.. _config_etcd_http_request_timeout:

.. confval:: config.etcd.http.request.timeout

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A timeout for connecting to an etcd server.

    | Type: number
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_HTTP_REQUEST_TIMEOUT

.. _config_etcd_http_request_unix_socket:

.. confval:: config.etcd.http.request.unix_socket

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A Unix domain socket used to connect to an etcd server.

    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_HTTP_REQUEST_UNIX_SOCKET




..  TODO
    https://github.com/tarantool/doc/issues/3664

