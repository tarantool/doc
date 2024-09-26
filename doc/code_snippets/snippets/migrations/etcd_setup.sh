#!/usr/bin/env bash

# 1. Remove the 'default.etcd' directory to reset etcd to initial state.
# 2. Start etcd by executing the 'etcd' command.
# 3. Execute this script to enable authentication.

etcdctl user add root:topsecret
etcdctl role add app_config_manager
etcdctl role grant-permission app_config_manager --prefix=true readwrite /myapp/
etcdctl user add app_user:config_pass
etcdctl user grant-role app_user app_config_manager
etcdctl auth enable
