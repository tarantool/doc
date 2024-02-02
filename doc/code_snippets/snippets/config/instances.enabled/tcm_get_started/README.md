# Getting started with Tarantool Cluster Manager

A sample application created in the [Getting started with Tarantool Cluster Manager](https://www.tarantool.io/en/doc/latest/how-to/getting_started_tcm/) tutorial.

## Running

Before starting instances, set up a Tarantool EE cluster as described in the tutorial.
Then, start all instances by executing the following command in the [config](../../../config) directory:

```console
$ tt start tcm_get_started
```

>
> To publish a cluster's configuration to etcd using tt, execute `tt cluster publish`:
> 
> ```shell
> tt cluster publish "http://localhost:2379/default" instances.enabled/tcm_get_started/cluster.yaml
> ```
