# Collecting HTTP metrics

A sample application showing how to enable and configure [metrics](https://www.tarantool.io/doc/latest/book/monitoring/) in your application.

## Running

Before starting the application, install the `http` module by executing the `tt rocks install` command in the [config](../../../config) directory:

```shell
$ tt rocks install http
```

Then, start the application:

```shell
$ tt start metrics_collect_http
```
