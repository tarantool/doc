.. _tcm_backend_store:

Backend store
=============

..  include:: index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

|tcm_full_name| uses an underlying data store (*backend store*) for its entities:
users, roles, cluster connections, settings, and other objects that you manipulate in |tcm|.
The backend store can be either an etcd or a Tarantool cluster.

Typically, the backend store works independently from |tcm|. For example, it can
be the same ectd or Tarantool cluster that you use as a :ref:`centralized configuration storage <configuration_etcd>`.
This makes |tcm| stateless: all objects created or modified in its web UI are sent
to the backend store, and nothing is stored inside the |tcm| instances themselves.
Any number of instances can duplicate each other when connected to the same backend store.
If you stop all instances, the store still contains their objects. You can continue
working with them right after starting a new instance.

In addition to using an external backend store, you can run |tcm| with an embedded
etcd or Tarantool instance to use as the backend store.

On this page, you will learn to connect |tcm| to backend stores of both types,
or start |tcm| with an embedded backend store.

.. _tcm_backend_store_set_up:

Setting up a backend store
--------------------------

The |tcm| backend store requires the same configuration as
:ref:`Tarantool centralized configuration storage <configuration_etcd>`.
Follow the instructions in :ref:`centralized_configuration_storage_set_up` to
set up a backend store.

.. note::

    If you already have the centralized configuration store for your Tarantool clusters,
    you can use it as a |tcm| backend store as well.

.. _tcm_backend_store_connect:

Configuring backend store connection
------------------------------------

The |tcm|'s connection to its backend store is configured using the :ref:`storage.* <tcm_configuration_reference_storage>`
configuration options. The :ref:`storage.provider <tcm_configuration_reference_storage_provider>`
option selects the store type. It can be either ``etcd`` or ``tarantool``.

.. _tcm_backend_store_connect_etcd:

etcd store
~~~~~~~~~~

To use an etcd cluster as a |tcm| backend store, set the ``storage.provider`` option
to ``etcd`` and specify connection parameters in ``storage.etcd.*`` options.
A minimal etcd configuration includes the storage endpoints:

.. code-block:: yaml

    storage:
      provider: etcd
      etcd:
        endpoints:
          - https://127.0.0.1:2379

If authentication is enabled in etcd, specify ``storage.etcd.username`` and ``storage.etcd.password``:

.. code-block:: yaml

    storage:
      provider: etcd
      etcd:
        endpoints:
          - https://127.0.0.1:2379
        username: etcduser
        password: secret

The |tcm| data is stored in etcd under the prefix specified in ``storage.etcd.prefix``.
By default, the prefix is ``/tcm``. If you want to change it or store data of
different |tcm| instances separately in one etcd cluster, set the prefix explicitly:

.. code-block:: yaml

    storage:
      provider: etcd
      etcd:
        endpoints:
          - https://127.0.0.1:2379
        prefix: /tcm2


Other ``storage.etcd.*`` options configure various aspects of the etcd store connection,
such as network timeouts and limits or TLS parameters.
For the full list of the etcd |tcm| backend store options, see the
:ref:`TCM configuration reference <tcm_configuration_reference_storage>`.

.. _tcm_backend_store_connect_tarantool:

Tarantool-based store
~~~~~~~~~~~~~~~~~~~~~

To use a Tarantool cluster as a |tcm| backend store, set the ``storage.provider`` option
to ``tarantool`` and specify connection parameters in ``storage.tarantool.*`` options.
A minimal configuration includes the one or more addresses of
the backend store instances:

.. code-block:: yaml

    storage:
      provider: tarantool
      tarantool:
        addr: https://127.0.0.1:3301

Or:

.. code-block:: yaml

    storage:
      provider: tarantool
      tarantool:
        addrs:
          - https://127.0.0.1:3301
          - https://127.0.0.1:3302
          - https://127.0.0.1:3303

If authentication is enabled in the backend store, specify ``storage.tarantool.username``
and ``storage.tarantool.password``:

.. code-block:: yaml

    storage:
      provider: tarantool
      tarantool:
        addr: https://127.0.0.1:3301
        username: tarantooluser
        password: secret

The |tcm| data is stored in the Tarantool-based backend store under the prefix
specified in ``storage.tarantool.prefix``.
By default, the prefix is ``/tcm``. If you want to change it or store data of
different |tcm| instances separately in one Tarantool cluster, set the prefix explicitly:

.. code-block:: yaml

    storage:
      provider: tarantool
      tarantool:
        addr: https://127.0.0.1:3301
        username: tarantooluser
        password: secret
        prefix: /tcm2


Other ``storage.tarantool.*`` options configure various aspects of |tcm| connection
to the Tarantool-based backend store, such as network timeouts and limits or TLS parameters.
For the full list of the Tarantool-based |tcm| backend store options, see the
:ref:`TCM configuration reference <tcm_configuration_reference_storage>`.

.. _tcm_backend_store_embed:

Using an embedded backend store
-------------------------------

For development purposes, you can start |tcm| with an embedded backend store.
This is useful for local runs when you don't have or don't need an external backend store.

An embedded |tcm| backend store is a single instance of etcd or Tarantool that
is started automatically on the same host during the |tcm| startup. It runs
in the background until |tcm| is stopped. The embedded backend store is persistent:
if you start |tcm| again with the same backend store configuration, it restores
the |tcm| data from the previous runs.

.. note::

    To start a clean instance of |tcm|, remove the working directory of the
    embedded backend store specified in the ``storage.etcd.embed.workdir`` or
    ``storage.tarantool.embed.workdir`` option.

The embedded backend store parameters are configured using the ``storage.etcd.embed.*`` options
for etcd or ``storage.tarantool.embed.*`` options for a Tarantool-based store.

To start |tcm| with an embedded etcd with default settings, set ``storage.etcd.embed.enabled`` to ``true``
and leave other ``storage.*`` options default:

.. code-block:: yaml

    storage.etcd.embed.enabled: true

To start |tcm| with default settings and an embedded etcd without a YAML configuration,
use the ``--storage.etcd.embed.enabled`` command-line option:

.. code-block:: console

    $ tcm --storage.etcd.embed.enabled

To start |tcm| with an embedded Tarantool storage with default settings:

*   set ``storage.provider`` to ``tarantool``
*   set ``storage.tarantool.embed.enabled`` to ``true``

.. code-block:: yaml

    storage:
      provider: tarantool
      tarantool.embed.enabled: true

With command-line arguments:

.. code-block:: console

    $ tcm --storage.provider=tarantool --storage.tarantool.embed.enabled

You can tune the embedded backend store, for example, enable and configure TLS on it
or change its working directories or startup arguments. To set specific parameters,
specify the corresponding ``storage.etcd.embed.*`` or ``storage.tarantool.embed.*``
options. For the full list of configuration options of embedded backend stores, see the
:ref:`TCM configuration reference <tcm_configuration_reference_storage>`.

.. _tcm_backend_store_embed_cluster:

Setting up a cluster of embedded backend stores
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To simulate the production environment, you can form a distributed multi-instance cluster
from embedded stores of multiple |tcm| instances. To do this, configure each |tcm|
instance's embedded store to join each other.

For etcd, provide the embedded store clustering parameters ``storage.etcd.embed.*``
and specify the endpoints in ``storage.etcd.endpoints``. The options that configure
embedded etcd mostly match the etcd configuration options. For more information
about these options, see the `etcd documentation <https://etcd.io/docs/latest/op-guide/configuration/>`__.

Below are example configurations of three |tcm| instances that start with embedded etcd instances
and form an etcd cluster from them:

*   First instance:

    .. code-block:: yaml

        http.port: 8080
        storage:
          provider: etcd
          etcd:
            endpoints:
              - http://127.0.0.1:2379
              - http://127.0.0.1:22379
              - http://127.0.0.1:32379
            embed:
              enabled: true
              name: infra1
              endpoints: http://127.0.0.1:2379
              advertises: http://127.0.0.1:2379
              initial-cluster-state: new
              initial-cluster: infra1=http://127.0.0.1:12380,infra2=http://127.0.0.1:22380,infra3=http://127.0.0.1:32380
              initial-cluster-token: etcd-cluster-1
              peer-endpoints: http://127.0.0.1:12380
              peer-advertises: http://127.0.0.1:12380
              workdir: node1.etcd

*   Second instance:

    .. code-block:: yaml

        http.port: 8081
        storage:
          provider: etcd
          etcd:
            endpoints:
              - http://127.0.0.1:2379
              - http://127.0.0.1:22379
              - http://127.0.0.1:32379
            embed:
              enabled: true
              name: infra2
              endpoints: http://127.0.0.1:22379
              advertises: http://127.0.0.1:22379
              initial-cluster-state: new
              initial-cluster: infra1=http://127.0.0.1:12380,infra2=http://127.0.0.1:22380,infra3=http://127.0.0.1:32380
              initial-cluster-token: etcd-cluster-1
              peer-endpoints: http://127.0.0.1:22380
              peer-advertises: http://127.0.0.1:22380
              workdir: node2.etcd

*   Third instance:

    .. code-block:: yaml

        http.port: 8082
        storage:
          provider: etcd
          etcd:
            endpoints:
              - http://127.0.0.1:2379
              - http://127.0.0.1:22379
              - http://127.0.0.1:32379
            embed:
              enabled: true
              name: infra3
              endpoints: http://127.0.0.1:32379
              advertises: http://127.0.0.1:32379
              initial-cluster-state: new
              initial-cluster: infra1=http://127.0.0.1:12380,infra2=http://127.0.0.1:22380,infra3=http://127.0.0.1:32380
              initial-cluster-token: etcd-cluster-1
              peer-endpoints: http://127.0.0.1:32380
              peer-advertises: http://127.0.0.1:32380
              workdir: node3.etcd


To set up a cluster from embedded Tarantool-based backend stores:

1.  Specify the Tarantool cluster configuration in ``storage.tarantool.embed.config``
    (as a plain text) or ``storage.tarantool.embed.config-file`` (as a YAML file).
2.  Assign an instance name from this configuration to each instance using ``storage.tarantool.embed.args``
    to each embedded store.

Example configurations of three |tcm| instances that start with embedded Tarantool-based
store instances and form a cluster from them:

*   First instance:

    .. code-block:: yaml

        http.port: 8080
        storage:
          provider: tarantool
          tarantool:
            addrs:
              - http://127.0.0.1:3301
              - http://127.0.0.1:3302
              - http://127.0.0.1:3303
            embed:
              enabled: true
              config-filename: config.yml
              workdir: node1.tarantool
              args:
                - --name
                - instance-001
                - --config
                - config.yml

*   Second instance:

    .. code-block:: yaml

        http.port: 8081
        storage:
          provider: tarantool
          tarantool:
            addrs:
              - http://127.0.0.1:3301
              - http://127.0.0.1:3302
              - http://127.0.0.1:3303
            embed:
              enabled: true
              config-filename: config.yml
              workdir: node2.tarantool
              args:
                - --name
                - instance-002
                - --config
                - config.yml

*   Third instance:

    .. code-block:: yaml

        http.port: 8082
        storage:
          provider: tarantool
          tarantool:
            addrs:
              - http://127.0.0.1:3301
              - http://127.0.0.1:3302
              - http://127.0.0.1:3303
            embed:
              enabled: true
              config-filename: config.yml
              workdir: node3.tarantool
              args:
                - --name
                - instance-003
                - --config
                - config.yml