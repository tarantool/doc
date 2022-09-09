.. _connecting_to_cluster:

=================================================================================
Connecting to the cluster
=================================================================================

In the last section, we set up a cluster, created a schema, and wrote data through the HTTP API.
Now we can connect to the cluster from code and work with data.

..  note::

    If you are using Tarantool without Cartridge, go to the
    :ref:`Connecting from your favorite language <getting_started_connectors>` section.
    If you are undergoing training, read on.

You may have noticed that we used the ``crud`` module in the HTTP handler code.
The code looked something like this:

..  code:: lua

    local crud = require ('crud')

    function add_user(request)
        local result, err = crud.insert_object ('users', {user_id = uuid.new (), fullname = fullname})
    end


This module allows you to work with data in a cluster. The syntax here is similar to
what the Tarantool ``box`` module offers.
You will learn more about the ``box`` module in the following sections.

The ``crud`` module contains a set of stored procedures.
To work with them, we must activate special roles on all routers and storages.
We selected those roles in the previous section, so we don't need to do anything.
The roles are named accordingly: "crud-router" and "crud-storage".

To write and read data in the Tarantool cluster from code, we will call stored
procedures of the ``crud`` module.

In Python, it looks like this:

..  code:: python

    res = conn.call('crud.insert', 'users', <uuid>, 'Jim Carrey')
    users = conn.call('crud.select', 'users', {limit: 100})

All functions of the ``crud`` module are described
in the `README of our GitHub repository <https://github.com/tarantool/crud/#insert>`_.

Here is an incomplete list:

* ``insert``
* ``select``
* ``get``
* ``delete``
* ``min``\/``max``
* ``replace``\/``upsert``
* ``truncate``

To learn how to call stored procedures in your programming language, see the corresponding section:

* :ref:`for Python <getting_started-python>`
* :ref:`for Go <getting_started-go>`
* :ref:`for PHP <getting_started-php>`
* :doc:`for C++ </how-to/getting_started_cxx>`

For connectors to other languages, check the README for the connector of your choice
`on GitHub <https://github.com/tarantool>`_.
