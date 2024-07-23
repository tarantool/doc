.. _read_views:

Read views
==========

A read view is an in-memory snapshot of the entire database that isn't
affected by future :ref:`data modifications <index-box_operations>`.
Read views provide access to database spaces and their indexes and enable you to
retrieve data using the same ``select`` and ``pairs`` operations.

Read views can be used to make complex analytical queries.
This reduces the load on the main database and improves RPS for a single Tarantool instance.

To improve memory consumption and performance,
Tarantool creates read views using the copy-on-write technique.
In this case, duplication of the entire data set is not required:
Tarantool duplicates only blocks modified after a read view is created.

.. NOTE::

    Tarantool Enterprise Edition supports read views starting from v2.11.0 and enables the ability
    to work with them using both :ref:`Lua <read_views_lua_api>` and :ref:`C API <read_views_c_api>`.

.. _read_views_limitations:

Limitations
-----------

Read views have the following limitations:

-   Only the :ref:`memtx <engines-memtx>` engine is supported.
-   Only :ref:`TREE <indexes-tree>`, :ref:`HASH <indexes-hash>` and :ref:`functional <box_space-index_func>`
    indexes are supported.

.. _working_with_read_views:

Working with read views
-----------------------

.. _creating_read_view:

Creating a read view
~~~~~~~~~~~~~~~~~~~~

To create a read view, call the :ref:`box.read_view.open() <box-read_view-open>` function.
The snippet below shows how to create a read view with the ``read_view1`` name.

..  code-block:: tarantoolsession

    tarantool> read_view1 = box.read_view.open({name = 'read_view1'})

After creating a read view, you can see the information about it by calling
:ref:`read_view_object:info() <read_view_object-info>`.

..  code-block:: tarantoolsession

    tarantool> read_view1:info()
    ---
    - timestamp: 66.606817935
      signature: 24
      is_system: false
      status: open
      vclock: {1: 24}
      name: read_view1
      id: 1
    ...

To list all the created read views, call the :ref:`box.read_view.list() <reference_lua-box_read_view_list>` function.

.. _querying_data:

Querying data
~~~~~~~~~~~~~

After creating a read view, you can access database spaces using the
:ref:`read_view_object.space <read_view_object-space>` field.
This field provides access to a space object that exposes the
:ref:`select <box_space-select>`, :ref:`get <box_space-get>`,
and :ref:`pairs <box_space-pairs>` methods with the same behavior
as corresponding ``box.space`` methods.

The example below shows how to select 4 records from the ``bands`` space:

..  code-block:: tarantoolsession

    tarantool> read_view1.space.bands:select({}, {limit = 4})
    ---
    - - [1, 'Roxette', 1986]
      - [2, 'Scorpions', 1965]
      - [3, 'Ace of Base', 1987]
      - [4, 'The Beatles', 1960]
    ...

Similarly, you can retrieve data by the specific index.

..  code-block:: tarantoolsession

    tarantool> read_view1.space.bands.index.year:select({}, {limit = 4})
    ---
    - - [4, 'The Beatles', 1960]
      - [2, 'Scorpions', 1965]
      - [1, 'Roxette', 1986]
      - [3, 'Ace of Base', 1987]
    ...

Pagination is supported in read views in the same ways as in ``select`` requests
to spaces: using the ``fetch_pos`` and ``after`` arguments. To get the cursor position
after executing a request on a read view, set ``fetch_pos`` to ``true``:

.. code-block:: tarantoolsession

    -- Select first 3 tuples and fetch a last tuple's position --
    app:instance001> result, position = read_view1.space.bands:select({}, { limit = 3, fetch_pos = true })
    ---
    ...

    app:instance001> result
    ---
    - - [1, 'Roxette', 1986]
      - [2, 'Scorpions', 1965]
      - [3, 'Ace of Base', 1987]
    ...

    app:instance001> position
    ---
    - kQM
    ...

Then, pass this position in the ``after`` parameter of a request to get the
next data chunk:

.. code-block:: tarantoolsession

    app:instance001> read_view1.space.bands:select({}, { limit = 3, after = position })
    ---
    - - [4, 'The Beatles', 1960]
      - [5, 'Pink Floyd', 1965]
      - [6, 'The Rolling Stones', 1962]
    ...


.. _closing_read_view:

Closing a read view
~~~~~~~~~~~~~~~~~~~

When a read view is no longer needed, close it using the
:ref:`read_view_object:close() <read_view_object-close>` method
because a read view may consume a substantial amount of memory.

..  code-block:: tarantoolsession

    tarantool> read_view1:close()
    ---
    ...

Otherwise, a read view is closed implicitly when the read view object is collected by the Lua garbage collector.

After the read view is closed,
its :ref:`status <read_view_object-status>` is set to ``closed``.
On an attempt to use it, an error is raised.

.. _read_views_example:

Example
-------

A Tarantool session below demonstrates how to open a read view,
get data from this view, and close it.
To repeat these steps, you need to bootstrap a Tarantool instance
as described in :ref:`Using data operations <box_space-operations-detailed-examples>`
(you can skip creating secondary indexes).

1.  Insert test data.

    ..  code-block:: tarantoolsession

        tarantool> bands:insert{1, 'Roxette', 1986}
                   bands:insert{2, 'Scorpions', 1965}
                   bands:insert{3, 'Ace of Base', 1987}
                   bands:insert{4, 'The Beatles', 1960}

2.  Create a read view by calling the ``open`` function.
    Then, make sure that the read view status is ``open``.

    ..  code-block:: tarantoolsession

        tarantool> read_view1 = box.read_view.open({name = 'read_view1'})

        tarantool> read_view1.status
        ---
        - open
        ...

3.  Change data in a database using the ``delete`` and ``update`` operations.

    ..  code-block:: tarantoolsession

        tarantool> bands:delete(4)
        ---
        - [4, 'The Beatles', 1960]
        ...
        tarantool> bands:update({2}, {{'=', 2, 'Pink Floyd'}})
        ---
        - [2, 'Pink Floyd', 1965]
        ...

4.  Query a read view to make sure it contains a snapshot of data before a database is updated.

    ..  code-block:: tarantoolsession

        tarantool> read_view1.space.bands:select()
        ---
        - - [1, 'Roxette', 1986]
          - [2, 'Scorpions', 1965]
          - [3, 'Ace of Base', 1987]
          - [4, 'The Beatles', 1960]
        ...

5.  Close a read view.

    ..  code-block:: tarantoolsession

        tarantool> read_view1:close()
        ---
        ...

..  toctree::
    :maxdepth: 2
    :hidden:

    read_views/lua_api
    read_views/c_api