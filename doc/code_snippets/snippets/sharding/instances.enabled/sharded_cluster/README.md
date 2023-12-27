# Sharded cluster

A sample application demonstrating how to configure a [sharded](https://www.tarantool.io/en/doc/latest/concepts/sharding/) cluster.

## Running

To run the cluster, go to the `sharding` directory in the terminal and perform the following steps:

1. Install dependencies defined in the `*.rockspec` file:

   ```console
   $ tt build
   ```
   
2. Run the cluster:

   ```console
   $ tt start sharded_cluster
   ```

3. Connect to the router:

   ```console
   $ tt connect sharded_cluster:router-a-001
   ```

4. Insert test data:

   ```console
   sharded_cluster:router-a-001> insert_data()
   ---
   ...
   ```
   
5. Connect to storages in different replica sets to see how data is distributed across nodes:

   a. `storage-a-001`:

      ```console
      sharded_cluster:storage-a-001> box.space.bands:select()
      ---
      - - [1, 614, 'Roxette', 1986]
        - [2, 986, 'Scorpions', 1965]
        - [5, 755, 'Pink Floyd', 1965]
        - [7, 998, 'The Doors', 1965]
        - [8, 762, 'Nirvana', 1987]
      ...
      ```
   
   b. `storage-b-001`:

      ```console
      sharded_cluster:storage-b-001> box.space.bands:select()
      ---
      - - [3, 11, 'Ace of Base', 1987]
        - [4, 42, 'The Beatles', 1960]
        - [6, 55, 'The Rolling Stones', 1962]
        - [9, 299, 'Led Zeppelin', 1968]
        - [10, 167, 'Queen', 1970]
      ...
      ```


## Packaging

To package an application into a `.tgz` archive, use the `tt pack` command:

```console
$ tt pack tgz --app-list sharded_cluster
```

Note that the necessary `vshard` dependency is specified in the [sharded_cluster-scm-1.rockspec](sharded_cluster-scm-1.rockspec) file.
