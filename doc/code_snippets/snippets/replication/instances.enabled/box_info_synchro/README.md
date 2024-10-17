# Using box.info.synchro

A sample application demonstrating how to work with [box.info.synchro](https://www.tarantool.io/en/doc/latest/reference/reference_lua/box_info/synchro/).

## Running

To start all instances, execute the following command in the [replication](../../../replication) directory:

```console
$ tt start box_info_synchro
```

To check the instance status, run:

```console
$ tt status box_info_synchro
```

To connect to the ``instance001`` instance, run:

```console
$ tt connect box_info_synchro:instance001
```