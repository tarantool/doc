# Sharded cluster with CRUD

A sample application demonstrating how to set up a sharded cluster with the [crud](https://github.com/tarantool/crud) module.

## Running

Before running the cluster, execute the `tt build` command in the [sharding](../../../sharding) directory:

```shell
$ tt build sharded_cluster_crud
```

Then, start all instances in the cluster using `tt start`:

```shell
$ tt start sharded_cluster_crud
```

## Bootstrapping a cluster

After starting instances, you need to bootstrap the cluster.
Connect to the router instance using `tt connect`:

```shell
$ tt connect sharded_cluster_crud:router-a-001
   • Connecting to the instance...
   • Connected to sharded_cluster_crud:router-a-001
```

Call `vshard.router.bootstrap()` to perform the initial cluster bootstrap:

```shell
sharded_cluster_crud:router-a-001> vshard.router.bootstrap()
---
- true
...
```


## Inserting data

To insert sample data, call `crud.insert_many()` on the router:

```lua
crud.insert_many('bands', {
    { 1, box.NULL, 'Roxette', 1986 },
    { 2, box.NULL, 'Scorpions', 1965 },
    { 3, box.NULL, 'Ace of Base', 1987 },
    { 4, box.NULL, 'The Beatles', 1960 },
    { 5, box.NULL, 'Pink Floyd', 1965 },
    { 6, box.NULL, 'The Rolling Stones', 1962 },
    { 7, box.NULL, 'The Doors', 1965 },
    { 8, box.NULL, 'Nirvana', 1987 },
    { 9, box.NULL, 'Led Zeppelin', 1968 },
    { 10, box.NULL, 'Queen', 1970 }
})
```
