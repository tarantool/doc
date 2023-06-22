#.  On each ``router`` instance, perform the :ref:`vshard.router check <admin-upgrades-router-check>`:

    ..  code-block:: tarantoolsession

        vshard.router.info()
        -- no issues in the output
        -- sum of 'bucket.available_rw' == total number of buckets

#.  On each ``storage`` instance, perform the :ref:`replication check <admin-upgrades-replication-check>`:

    ..  code-block:: tarantoolsession

        box.info
        -- box.info.status == 'running'
        -- box.info.ro == 'false' on one instance in each replica set.
        -- box.info.replication[*].upstream.status == 'follow'
        -- box.info.replication[*].downstream.status == 'follow'
        -- box.info.replication[*].upstream.lag <= box.cfg.replication_timeout
        -- can also be moderately larger under a write load


#.  On each ``storage`` instance, perform the :ref:`vshard.storage check <admin-upgrades-storage-check>`:

    ..  code-block:: tarantoolsession

        vshard.storage.info()
        -- no issues in the output
        -- replication.status == 'follow'

#.  Check all instances' :ref:`logs <admin-logs>` for application errors.

.. note::

    If you're running Cartridge, you can check the health of the cluster instances
    on the **Cluster** tab of its web interface.