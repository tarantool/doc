# Tarantool code examples

The `doc/code_snippets` folder of a Tarantool documentation repository contains runnable code examples that show how to work with Tarantool:

- The [snippets](snippets) folder contains sample applications that demonstrate how to configure a Tarantool cluster.
- The [test](test) folder contains testable Lua examples that show how to work with various Tarantool modules.

Code from these examples is [referenced](#referencing-code-snippets) in corresponding documentation sections. 

## Prerequisites

- Install the [tt CLI utility](https://www.tarantool.io/en/doc/latest/tooling/tt_cli/).
- To be able to run tests for samples from [test](test), go to the `doc/code_snippets` folder and install the following libraries:

    - [luatest](https://github.com/tarantool/luatest):
        ```shell
        tt rocks install luatest
        ```

    - [luarapidxml](https://github.com/tarantool/luarapidxml):
        ```shell
        tt rocks install luarapidxml
        ```



## Running

### Running applications from 'snippets'

To run applications placed in [snippets](snippets), follow these steps:

1.  Go to the directory containing samples for a specific feature, for example, [snippets/replication](snippets/replication).
2. To run applications placed in [instances.enabled](instances.enabled), execute the `tt start` command, for example:

    ```console
    $ tt start auto_leader
    ```

### Running and testing examples from 'test'

To test all the examples, go to the `doc/code_snippets` folder and execute the `luatest` command:

```shell
.rocks/bin/luatest
```

To test the examples from the specified directory, pass its relative path to the `luatest` command:

```shell
.rocks/bin/luatest test/transactions
```

To test a specific example with the `stdout` output enabled, use the `luatest` command with the `-c` option, for example:

```shell
.rocks/bin/luatest -c test/http_client/get_test.lua
```

Note that the HTTP client samples (placed in `test/http_client`) use the `httpbin` service.
You can run `httpbin` locally using Docker to stabilize test results:

```shell
docker run -p 80:80 kennethreitz/httpbin
```

In this case, you need to replace `https://httpbin.org` links with `http://127.0.0.1`.


## Referencing code snippets
To display a specific source file in a topic, use the `literalinclude` directive as follows:
```
..  literalinclude:: /code_snippets/test/http_client/post_json_test.lua
    :language: lua
    :lines: 1-6
```
