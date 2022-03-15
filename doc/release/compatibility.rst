Compatibility guarantees
========================

Backward compatibility (binary data layout)
-------------------------------------------

A newer release (its runtime) is backward compatible with an older one.
It means a more recent release should work on top of data
(``*.xlog``, ``*.snap``, ``*.vylog``, ``*.run``) from the older one.
All functionality that is part of the older release is working in this configuration.

An attempt to use a new feature results in one of these options:

*   The attempt is successful.

*   There is meaningful error about the old data layout until the database schema upgrade.
    It does not lead to a service outage or data corruption.
    An instance can upgrade the data layout using the :ref:`box.schema.upgrade() <admin-upgrades>` call
    to enable all new release features (when all instances of the replicaset are run on the same Tarantool version).

Backward compatibility (binary protocol)
----------------------------------------

All binary protocol requests operational in an older release should work on a newer one.
They do not change the meaning.
Responses have the same format, but mappings may contain fields not present in the older release.

``net.box`` client of the older release is able to work
with the newer one, except the features introduced in the newer release.
``net.box`` client of the newer release is fully operational with the server
running under the older one, except the features that are not implemented in the older release.

Backward compatibility (replication protocol)
---------------------------------------------

An instance run on a newer release may work as:

*   upstream (master) of an instance with an older release

*   downstream (replica) without a database schema upgrade.

The database schema upgrade (``box.schema.upgrade()``) must be performed when all replicaset instances
run on the same Tarantool version.
The upgrade does not cause downtime if the application does not lean on internal schema representation.
