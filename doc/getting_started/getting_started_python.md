(getting-started-python)=

# Connecting from Python

(getting-started-python-pre-requisites)=

## Pre-requisites

Before we proceed:

1. [Install](https://github.com/tarantool/tarantool-python#download-and-install)
   the `tarantool` module. We recommend using `python3` and `pip3`.

2. {ref}`Start <getting_started_db>` Tarantool (locally or in Docker)
   and make sure that you have created and populated a database as we suggested
   {ref}`earlier <creating-db-locally>`:

   ```lua
   box.cfg{listen = 3301}
   s = box.schema.space.create('tester')
   s:format({
            {name = 'id', type = 'unsigned'},
            {name = 'band_name', type = 'string'},
            {name = 'year', type = 'unsigned'}
            })
   s:create_index('primary', {
            type = 'hash',
            parts = {'id'}
            })
   s:create_index('secondary', {
            type = 'hash',
            parts = {'band_name'}
            })
   s:insert{1, 'Roxette', 1986}
   s:insert{2, 'Scorpions', 2015}
   s:insert{3, 'Ace of Base', 1993}
   ```

   :::{IMPORTANT}
   Please do not close the terminal window
   where Tarantool is running -- you'll need it soon.
   :::

3. In order to connect to Tarantool as an administrator, reset the password
   for the `admin` user:

   ```lua
   box.schema.user.passwd('pass')
   ```

(getting-started-python-connecting)=

## Connecting to Tarantool

To get connected to the Tarantool server, say this:

```python
>>> import tarantool
>>> connection = tarantool.connect("localhost", 3301)
```

You can also specify the user name and password, if needed:

```python
>>> tarantool.connect("localhost", 3301, user=username, password=password)
```

The default user is `guest`.

(getting-started-python-manipulate)=

## Manipulating the data

A {term}`space` is a container for {term}`tuples <tuple>`.
To access a space as a named object, use `connection.space`:

```python
>>> tester = connection.space('tester')
```

(getting-started-python-insert)=

### Inserting data

To insert a tuple into a space, use `insert`:

```python
>>> tester.insert((4, 'ABBA', 1972))
[4, 'ABBA', 1972]
```

(getting-started-python-query)=

### Querying data

Let's start with selecting a tuple by the primary key
(in our example, this is the index named `primary`, based on the `id` field
of each tuple). Use `select`:

```python
>>> tester.select(4)
[4, 'ABBA', 1972]
```

Next, select tuples by a secondary key.
For this purpose, you need to specify the number *or* name of the index.

First off, select tuples using the index number:

```python
>>> tester.select('Scorpions', index=1)
[2, 'Scorpions', 2015]
```

(We say `index=1` because index numbers in Tarantool start with 0,
and we're using our second index here.)

Now make a similar query by the index name and make sure that the result
is the same:

```python
>>> tester.select('Scorpions', index='secondary')
[2, 'Scorpions', 2015]
```

Finally, select all the tuples in a space via a `select` with no
arguments:

```python
>>> tester.select()
```

(getting-started-python-update)=

### Updating data

Update a {term}`field` value using `update`:

```python
>>> tester.update(4, [('=', 1, 'New group'), ('+', 2, 2)])
```

This updates the value of field `1` and increases the value of field `2`
in the tuple with `id = 4`. If a tuple with this `id` doesn't exist,
Tarantool will return an error.

Now use `replace` to totally replace the tuple that matches the
primary key. If a tuple with this primary key doesn't exist, Tarantool will
do nothing.

```python
>>> tester.replace((4, 'New band', 2015))
```

You can also update the data using `upsert` that works similarly
to `update`, but creates a new tuple if the old one was not found.

```python
>>> tester.upsert((4, 'Another band', 2000), [('+', 2, 5)])
```

This increases by 5 the value of field `2` in the tuple with `id = 4`, or
inserts the tuple `(4, "Another band", 2000)` if a tuple with this `id`
doesn't exist.

(getting-started-python-delete)=

### Deleting data

To delete a tuple, use `delete(primary_key)`:

```python
>>> tester.delete(4)
[4, 'New group', 2012]
```

To delete all tuples in a space (or to delete an entire space), use `call`.
We'll focus on this function in more detail in the
{ref}`next <getting_started-python-stored-procs>` section.

To delete all tuples in a space, call `space:truncate`:

```python
>>> connection.call('box.space.tester:truncate', ())
```

To delete an entire space, call `space:drop`.
This requires connecting to Tarantool as the `admin` user:

```python
>>> connection.call('box.space.tester:drop', ())
```

(getting-started-python-stored-procs)=

## Executing stored procedures

Switch to the terminal window where Tarantool is running.

:::{NOTE}
If you don't have a terminal window with remote connection to Tarantool,
check out these guides:

- {ref}`connecting to a local Tarantool instance <connecting-remotely>`
- {ref}`attaching to a Tarantool instance that runs in a Docker container <getting_started-docker-attaching>`
:::

Define a simple Lua function:

```lua
function sum(a, b)
    return a + b
end
```

Now we have a Lua function defined in Tarantool. To invoke this function from
`python`, use `call`:

```python
>>> connection.call('sum', (3, 2))
5
```

To send bare Lua code for execution, use `eval`:

```python
>>> connection.eval('return 4 + 5')
9
```

(getting-started-python-comparison)=

## Feature comparison

See the {ref}`feature comparison table <index_connector_py>` of all Python connectors available.
