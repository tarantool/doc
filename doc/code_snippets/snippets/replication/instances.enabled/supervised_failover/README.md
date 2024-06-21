# Master-replica: supervised failover

A sample application demonstrating how to bootstrap a replica set that uses an [external failover coordinator](https://www.tarantool.io/doc/latest/concepts/replication/supervised_failover/).
The failover coordinator's state is stored in etcd along with a replica set configuration.


## Running

1. Start etcd:

   ```console
   $ etcd
   ```
   
2. Publish a replica set configuration to etcd by executing the `tt cluster publish` command in the [replication](../../../replication) directory:

   ```console
   $ tt cluster publish "http://localhost:2379/myapp" instances.enabled/supervised_failover/source.yaml
   ```
   
3. To start the failover coordinator, execute the `tarantool` command with the `--failover` option:

   ```console
   $ tarantool --failover --config instances.enabled/supervised_failover/config.yaml
   ```

4. Then, start the application as follows:

   ```console
   $ tt start supervised_failover
   ```
