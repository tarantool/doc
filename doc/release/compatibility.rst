Compatibility guarantees
========================

This chapter consists of six parts.

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
    An instance can upgrade the data layout using the ``box.schema.upgrade()`` call
    to enable all new release features (when all instances of the replicaset are run on the same Tarantool version).

Backward compatibility (binary protocol)
----------------------------------------

All binary protocol requests that were operational in an older release are
remain operational on a newer release and does not change meaning. Responses
have the same format, but mappings may have fields that were not present in
the older release.

net.box client of the older release able to work with the newer release
(except, maybe, functionality introduced in the newer release). net.box
client of the newer release is fully operational with the server that is run
under the older release (except, maybe, functionality that the older release
does not implement).

Backward compatibility (replication protocol)
---------------------------------------------

A instance that is run on a newer release may work as upstream (master) of an
instance with an older release or as downstream (replica) without database
schema upgrade.

The database schema upgrade (box.schema.upgrade()) must be performed when
all replicaset instances run on the same tarantool version. The upgrade does
not cause downtime (if the application does not lean on internal schema
representation).
