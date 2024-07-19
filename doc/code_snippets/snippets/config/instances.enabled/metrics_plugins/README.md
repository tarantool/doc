# Exposing metrics using plugins

A sample application showing how to use [metrics](https://www.tarantool.io/doc/latest/book/monitoring/) plugins for exposing metrics.

## Running

Before starting the application, install the `http` module by executing the `tt rocks install` command in the [config](../../../config) directory:

```shell
$ tt rocks install http
```

Then, start the application:

```shell
$ tt start metrics_plugins
```

To get Prometheus metrics, make the following request:

```console
$ curl -X GET --location "http://127.0.0.1:8080/metrics/prometheus"
```

To get metrics in the JSON format, make the following request:

```console
$ curl -X GET --location "http://127.0.0.1:8081/metrics/json"
```
