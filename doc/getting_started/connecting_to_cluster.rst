.. _connecting_to_cluster:

=================================================================================
Connecting to the cluster
=================================================================================

In the last section, we set up a cluster, created a schema, and wrote data through the HTTP API.
Now we can connect to the cluster from code and work with data.

.. NOTE::

    If you are using Tarantool without Cartridge, then go to :ref:`this section is <getting_started_connectors>`.
    If you are undergoing training, then read on.

You may have noticed that we used the ``crud`` module in the HTTP handler code.
The code looked something like this:

.. code:: lua

    local crud = require ('crud')

    function add_user(request)
        local result, err = crud.insert_object ('users', {user_id = uuid.new (), fullname = fullname})
    end


This module allows you to work with data in a cluster and has a similar syntax,
what the Tarantool `box` module offers. You will learn more about the box module in the following sections.

The crud module contains a set of stored procedures. For it to work, we must activate special roles on all routers and storages. In the previous section, we selected them, so we don't need to do anything. The roles are named accordingly: "crud-router", "crud-storage".

To write and read data in the Tarantool cluster from code, we will call the stored
the procedures of the `crud` module.

In Python, it looks like this:

.. code:: python

    res = conn.call('crud.insert', 'users', <uuid>, 'Jim Carrey')
    users = conn.call('crud.select', 'users', {limit: 100})

The list of all functions of the `crud` module is described in the `Github repository <https://github.com/tarantool/crud/#insert>`_.

It includes:

- insert
- select
- get
- delete
- min/max
- replace/upsert
- truncate
- other

To learn how to call stored procedures in your programming language, see the section
"Calling Stored Procedures":

- :ref:`for Python<getting_started-python>`
- :ref:`for Go<getting_started-go>`
- :ref:`for PHP<getting_started-php>`

For connectors to other languages, read the README for the `corresponding connector on Github <https://github.com/tarantool>`_.