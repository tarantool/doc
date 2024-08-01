# net.box

A sample application containing `net.box` requests from the [Connecting to a database using net.box](https://www.tarantool.io/en/doc/latest/reference/reference_lua/net_box/#connecting-to-a-database-using-net-box) tutorial.


## Running

Before running this sample, start an application that allows remote connections to a sample database: [sample_db](../instances.enabled/sample_db).

Then, start the interactive session by executing the following command in the [connectors](..) directory:

```console
$ tt run -i net_box/myapp.lua
```

In the console, you can use the `conn` object to execute requests for manipulating the data.
