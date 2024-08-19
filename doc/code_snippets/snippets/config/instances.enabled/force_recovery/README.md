# Force recovery

A sample application demonstrating how to start an instance with a corrupted write-ahead log file.

## Running

- To start the instance using the `tt` utility, execute the following command in the [config](../../../config) directory:

  ```console
  $ TT_FORCE_RECOVERY=true tt start force_recovery
  ```

- To start the instance using the `tarantool` command, you can use both the `TT_FORCE_RECOVERY` environment variable and add the `--force-recovery` option.
  In the example below, the `tarantool` command is executed in the [config/instances.enabled/force_recovery](../../../config/instances.enabled/force_recovery) directory:

  ```console
  $ tarantool --name instance001 --config config.yaml --force-recovery -i
  ```
