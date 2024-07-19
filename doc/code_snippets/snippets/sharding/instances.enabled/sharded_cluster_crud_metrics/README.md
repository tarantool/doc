# Sharded cluster: Exposing metrics

A sample application showing how to enable and expose [metrics](https://www.tarantool.io/doc/latest/book/monitoring/) through HTTP.

## Running

Before starting the application, install dependencies defined in the `*.rockspec` file:

```console
$ tt build sharded_cluster_crud_metrics
```

Then, start the application:

```console
$ tt start sharded_cluster_crud_metrics
```

To get Prometheus metrics, make the following request:

```console
$ curl -X GET --location "http://127.0.0.1:8081/metrics/prometheus"
```

To get metrics in the JSON format, make the following request:

```console
$ curl -X GET --location "http://127.0.0.1:8081/metrics/json"
```


## Running the Prometheus server

To monitor the metrics of a running sample, you need to install Prometheus either locally or using Docker.
To install and run Prometheus using Docker, follow the steps below:

1. Open the [sharded_cluster_crud_metrics](../../../sharding/instances.enabled/sharded_cluster_crud_metrics) directory in the terminal.
2. Replace `127.0.0.1` with `host.docker.internal` in the `prometheus/prometheus.yml` file.
3. Then, run a server:
   ```Bash
   docker compose up
   ```
4. Open the [http://localhost:9090/graph](http://localhost:9090/graph) page to access the Prometheus expression browser.
5. Enter the desired Tarantool metric, for example, `tnt_info_uptime`or `tnt_info_memory_data` to see monitoring results.
