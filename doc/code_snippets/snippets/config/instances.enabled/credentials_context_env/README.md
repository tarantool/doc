# Credentials: environment variables

A sample application demonstrating how set passwords in a YAML configuration using environment variables.

## Running

Before starting instances, set the `DBADMIN_PASSWORD` and `SAMPLEUSER_PASSWORD` environment variables, for example:

```console
$ export DBADMIN_PASSWORD='T0p_Secret_P@$$w0rd'
$ export SAMPLEUSER_PASSWORD='123456'
```

Then, start the application by executing the following command in the [config](../../../config) directory:

```console
$ tt start credentials_context_env
```
