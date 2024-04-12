.. _tcm_data_storage:

Data storage
============


..  include:: index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

|tcm_full_name| uses an external data storage for storing its own objects: users,
roles, information about connected clusters, settings, and so on.
The connection parameters to |tcm| data storage are passed during startup in the
``storage.*`` configuration parameters.

The usage of an external data storage makes |tcm| stateless: you can start new
|tcm| instances pointing to the same storage, and they will duplicate each other.
If you stop all instances, the storage still contains all the data and you continue
to work with it right after starting a new instance.

The |tcm| data storage can be of two types: etcd or Tarantool. This is similar to
Tarantool cluster configuration storage. Read on to learn to configure connection to
storages of both types.

For development purposes, you can start |tcm| with embedded data storage. Learn more in
the


TCM data includes users/roles/clusters/etc.

|tcm_full_name| stores its data in a storage
one of two types: etcd and tarantool

TCM is stateless
any number of instances looking at the same storage duplicate each other




Storage connection parameters are storage.*

TCM clustering: configure the same storage in two or more TCM instances

Embedded storage for development purposes: tcm.etcd.embed and tcm.tarantool.embed

.. _tcm_data_storage_etcd:

etcd storage
------------

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
-----------------------

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
      username: tarantooluser
      password: secret

For the full list of the Tarantool-based |tcm| data storage options, see the
:ref:`TCM configuration reference <tcm_configuration_reference_storage>`.


The |tcm| data is stored in the Tarantool cluster under the prefix specified in ``storage.tarantool.prefix``.
By default, the prefix is ``/tcm``. If you want to change it or store data of
different |tcm| instances separately in one Tarantool cluster, set the prefix explicitly:

.. code-block:: yaml

  storage:
    provider: tarantool
    tarantool:
      addr: unix/:/tmp/tnt_config_instance.sock
      username: tarantooluser
      password: secret
      prefix: /tcm2

.. _tcm_data_storage_embed:

Embedded data storage
---------------------

For development purposes, you can use |tcm| with an embedded storage for its data.
This
|tcm| can start its own data storage upon startup. This can be useful for development
purposes
To start a data storage together with a |tcm| instance, specify options ``storage.etcd.embed.*``
for etcd storage or ``storage.tarantool.embed.*`` for Tarantool-based storage.

To start |tcm| with an embedded etcd node with default settings, set ``storage.etcd.embed.enabled`` to ``true``
or add the ``--storage.etcd.embed.enabled`` command-line option:

.. code-block:: console

    $ tcm --storage.etcd.embed.enabled

This call starts a etcd storage that works with |tcm| without additional configuration.

To use an embedded Tarantool storage with default settings:

*   set ``storage.provider`` to ``tarantool``
*   set ``storage.tarantool.embed.enabled`` to ``true``

.. code-block:: console

    $ tcm --storage.provider=tarantool --storage.tarantool.embed.enabled

|tcm| allows fine tuning of embedded data storages. For example,

For the full list of configuration options of embedded data storages, see the
:ref:`TCM configuration reference <tcm_configuration_reference_storage>`.
