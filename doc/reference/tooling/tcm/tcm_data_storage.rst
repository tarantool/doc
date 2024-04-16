.. _tcm_data_storage:

Data storage
============

..  include:: index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

|tcm_full_name| uses a persistent external storage for its data: users, roles,
cluster connections, settings, and other |tcm| objects. This makes |tcm| stateless:
nothing is stored inside the |tcm| instances, and any number of instances can duplicate
each other when connected to the same data storage. If you stop all instances,
the storage still contains their data. You can continue working with it right after
starting a new instance.

The |tcm| data storage can have one of two types: etcd or Tarantool. This is similar to
:ref:`Tarantool centralized configuration storage <configuration_etcd>`. On this
page, you will learn how to connect |tcm| to external data storages of both types.

Additionally, you can configure |tcm| to run an embedded instance of the data storage
upon startup. It can be used independently or connect to an existing etcd or Tarantool cluster.


.. _tcm_data_storage_configuring:

Configuring data storage connection
-----------------------------------

The |tcm|'s connection to its data storage is configured using the :ref:`storage.* <tcm_configuration_reference_storage>``
configuration options. The :ref:`tcm_configuration_reference_storage_provider`
option selects the storage type. It can be either ``etcd`` or ``tarantool``.

.. _tcm_data_storage_etcd:

etcd storage
~~~~~~~~~~~~

To use an etcd cluster as a |tcm| data storage, set the ``storage.provider`` option
to ``etcd`` and specify connection parameters in ``storage.etcd.*`` options.
A minimal etcd configuration includes the storage endpoints:

.. code-block:: yaml

    storage:
      provider: etcd
      etcd:
        endpoints:
          - https://127.0.0.1:2379

If etcd authentication is enabled, specify ``storage.etcd.username`` and ``storage.etcd.password``:

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


For the full list of the etcd |tcm| data storage options, see the
:ref:`TCM configuration reference <tcm_configuration_reference_storage>`.

.. _tcm_data_storage_tarantool:

Tarantool-based storage
~~~~~~~~~~~~~~~~~~~~~~~

To use a Tarantool cluster as a |tcm| data storage, set the ``storage.provider`` option
to ``tarantool`` and specify connection parameters in ``storage.tarantool.*`` options.
A minimal Tarantool storage configuration includes the storage endpoints:

.. code-block:: yaml

    storage:
      provider: tarantool
      tarantool:
        addr: unix/:/tmp/tnt_config_instance.sock

If authentication is enabled in Tarantool, specify ``storage.tarantool.user`` and ``storage.tarantool.pass``:

.. code-block:: yaml

    storage:
      provider: tarantool
      tarantool:
        addr: unix/:/tmp/tnt_config_instance.sock
        user: tarantooluser
        pass: secret

The |tcm| data is stored in the Tarantool cluster under the prefix specified in ``storage.tarantool.prefix``.
By default, the prefix is ``/tcm``. If you want to change it or store data of
different |tcm| instances separately in one Tarantool cluster, set the prefix explicitly:

.. code-block:: yaml

    storage:
      provider: tarantool
      tarantool:
        addr: unix/:/tmp/tnt_config_instance.sock
        user: tarantooluser
        pass: secret
        prefix: /tcm2

For the full list of the Tarantool-based |tcm| data storage options, see the
:ref:`TCM configuration reference <tcm_configuration_reference_storage>`.

.. _tcm_data_storage_embed:

Using an embedded data storage
------------------------------

For development purposes, you can run |tcm| with an embedded storage for its data.
This can be useful for local runs when you don't have or don't need an external data storage.

To start a data storage together with a |tcm| instance, specify options ``storage.etcd.embed.*``
for etcd storage or ``storage.tarantool.embed.*`` for Tarantool-based storage.

To start |tcm| with an embedded etcd node with default settings, set ``storage.etcd.embed.enabled`` to ``true``
and leave other ``storage.*`` options default:

.. code-block:: yaml

    storage.etcd.embed.enabled: true

You can use the ``--storage.etcd.embed.enabled`` command-line option to get |tcm|
up and running with an embedded etcd without a configuration file:

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

The configuration options of embedded data storages. For example, you can configure the embedded
storage to connect to an external cluster

You can tune the embedded data storage parameters to imitate

Embedde data storage can

For the full list of configuration options of embedded data storages, see the
:ref:`TCM configuration reference <tcm_configuration_reference_storage>`.
