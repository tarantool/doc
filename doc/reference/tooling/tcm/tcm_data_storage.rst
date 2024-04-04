.. _tcm_data_storage:

Data storage
============


..  include:: index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

|tcm_full_name| stores its data in a storage
one of two types: etcd and tarantool

TCM data includes users/roles/clusters/etc.


Storage connection parameters are storage.*

TCM clustering: configure the same storage in two or more TCM instances

Embedded storage for development purposes: tcm.etcd.embed and tcm.tarantool.embed


etcd storage
------------

storage.etcd.* configuration parameters

Tarantool-based storage
-----------------------

storage.tarantool.* configuration parameters


Embedded data storage
---------------------

storage.etcd.embed.* configuration parameters

.. code-block:: console

    ./tcm --storage.etcd.embed.enabled
    # or
    ./tcm --storage.tarantool.embed.enabled

Possible fine tuning:


