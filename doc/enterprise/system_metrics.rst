..  _enterprise_system_metrics:

Monitoring system metrics
=========================

..  container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | Option               | Description                          | SNMP type    | Units of measure| Threshold       |
    +======================+======================================+==============+=================+=================+
    | Version              | Tarantool version                    | DisplayString|                 |                 |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | IsAlive              | instance availability indicator      | Integer      |                 | 0 - unavailable |
    |                      |                                      |              |                 |                 |
    |                      |                                      | (listing)    |                 | 1 - available   |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | MemoryLua            | storage space used by Lua            | Gauge32      | Mbyte           | 900             |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | MemoryData           | storage space used for storing data  | Gauge32      | Mbyte           | set the value   |
    |                      |                                      |              |                 | manually        |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | MemoryNet            | storage space used for network I/O   | Gauge32      | Mbyte           | 1024            |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | MemoryIndex          | storage space used for storing       | Gauge32      | Mbyte           | set the value   |
    |                      | indexes                              |              |                 | manually        |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | MemoryCache          | storage space used for storing caches| Gauge32      | Mbyte           |                 |
    |                      | (for vinyl engine only)              |              |                 |                 |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | ReplicationLag       | lag time since the last sync between | Integer32    | sec.            | 5               |
    |                      | (the maximum value in case there are |              |                 |                 |
    |                      | multiple fibers)                     |              |                 |                 |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | FiberCount           | number of fibers                     | Gauge32      | pc.             | 1000            |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | CurrentTime          | current time, in seconds, starting at| Unsigned32   | Unix timestamp, |                 |
    |                      | January, 1st, 1970                   |              | in sec.         |                 |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | StorageStatus        | status of a replica set              | Integer      | listing         | > 1             |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | StorageAlerts        | number of alerts for storage nodes   | Gauge32      | pc.             | >= 1            |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | StorageTotalBkts     | total number of buckets in the       | Gauge32      | pc.             | < 0             |
    |                      | storage                              |              |                 |                 |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | StorageActiveBkts    | number of buckets in the ACTIVE state| Gauge32      | pc.             | < 0             |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | StorageGarbageBkts   | number of buckets in the GARBAGE     | Gauge32      | pc.             | < 0             |
    |                      | state                                |              |                 |                 |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | StorageReceivingBkts | number of buckets in the RECEIVING   | Gauge32      | pc.             | < 0             |
    |                      | state                                |              |                 |                 |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | StorageSendingBkts   | number of buckets in the SENDING     | Gauge32      | pc.             | < 0             |
    |                      | state                                |              |                 |                 |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | RouterStatus         | status of the ``router``             | Integer      | listing         | > 1             |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | RouterAlerts         | number of alerts for the router      | Gauge32      | pc.             | >= 1            |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | RouterKnownBkts      | number of buckets within the known   | Gauge32      | pc.             | < 0             |
    |                      | destination replica sets             |              |                 |                 |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | RouterUnknownBkts    | number of buckets that are unknown to| Gauge32      | pc.             | < 0             |
    |                      | the ``router``                       |              |                 |                 |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | RequestCount         | total number of requests             | Counter64    | pc.             |                 |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | InsertCount          | total number of insert requests      | Counter64    | pc.             |                 |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | DeleteCount          | total number of delete requests      | Counter64    | pc.             |                 |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | ReplaceCount         | total number of replace requests     | Counter64    | pc.             |                 |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | UpdateCount          | total number of update requests      | Counter64    | pc.             |                 |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | SelectCount          | total number of select requests      | Counter64    | pc.             |                 |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | EvalCount            | number of calls made via Eval        | Counter64    | pc.             |                 |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | CallCount            | number of calls made via ``call``    | Counter64    | pc.             |                 |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | ErrorCount           | number of errors in Tarantool        | Counter64    | pc.             |                 |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
    | AuthCount            | number of completed authentication   | Counter64    | pc.             |                 |
    |                      | operations                           |              |                 |                 |
    +----------------------+--------------------------------------+--------------+-----------------+-----------------+
