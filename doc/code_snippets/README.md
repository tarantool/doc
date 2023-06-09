# Tarantool code examples

The `doc/code_snippets` folder of a Tarantool documentation repository contains runnable code examples that show how to work with various Tarantool modules. Code from these examples is [referenced](#referencing-code-snippets) in corresponding documentation sections. 

## Prerequisites

First, install the [tt CLI utility](https://www.tarantool.io/en/doc/latest/reference/tooling/tt_cli/).
Then, go to the `doc/code_snippets` folder and install the following libraries:

- Install [luatest](https://github.com/tarantool/luatest):
    ```shell
    tt rocks install luatest
    ```

- Install [luarapidxml](https://github.com/tarantool/luarapidxml):
    ```shell
    tt rocks install luarapidxml
    ```



## Running and testing examples

To test all the examples, go to the `doc/code_snippets` folder and execute the `luatest` command:

```shell
.rocks/bin/luatest
```

To run a specific example with tests, use the `luatest` command with the `-c` option, for example:

```shell
.rocks/bin/luatest -c test/http_client/get_test.lua
```

You can also run the `httpbin` service locally using Docker:

```shell
docker run -p 80:80 kennethreitz/httpbin
```

In this case, replace `https://httpbin.org` links with `http://127.0.0.1` to test the examples.


## Referencing code snippets
To display a specific source file in a topic, use the `literalinclude` directive as follows:
```
..  literalinclude:: /code_snippets/test/http_client/post_json_test.lua
    :language: lua
    :lines: 1-6
```
