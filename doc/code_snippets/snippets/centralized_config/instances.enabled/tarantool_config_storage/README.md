# Setting up Tarantool configuration storage

A sample application demonstrating how to set up Tarantool configuration storage.

## Running

To start all instances of the configuration storage, execute the following command in the [centralized_config](../../../centralized_config) directory:

```console
$ tt start tarantool_config_storage
```

To upload configuration for [config_storage](../config_storage) application, execute `put_config` function for the leader instanse (instance with RW mode):

```console
$ tt status tarantool_config_storage
 INSTANCE                              STATUS   PID  MODE  CONFIG  BOX      UPSTREAM
 tarantool_config_storage:instance001  RUNNING  802  RW    ready   running  --
 tarantool_config_storage:instance002  RUNNING  803  RO    ready   running  --
 tarantool_config_storage:instance003  RUNNING  809  RO    ready   running  --

$ echo 'put_config()' | tt connect tarantool_config_storage:instance001 -f -
---
- revision: 1
...
```