# HTTP API

A sample application showing how to implement a custom `http-api` role.

## Running

Before starting the application, install the `http` module by executing the `tt rocks install` command in the [config](../../../config) directory:

```shell
$ tt rocks install http
```

Then, start the application:

```shell
$ tt start application_role_http_api
```

## Making test requests

To test the API, make the following requests:

```console
$ curl -X GET --location "http://0.0.0.0:8080/band?limit=7" \
    -H "Accept: application/json"
$ curl -X GET --location "http://0.0.0.0:8080/band/5" \
    -H "Accept: application/json"
```
