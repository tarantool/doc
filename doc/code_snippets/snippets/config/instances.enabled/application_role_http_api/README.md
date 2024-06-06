# HTTP API

A sample application showing how to implement a custom `http-api` role.

## Running

To start an application, execute the following command in the [config](../../../config) directory:

```console
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
