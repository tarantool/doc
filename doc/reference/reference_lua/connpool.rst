..  _connpool_module:

Module experimental.connpool
============================

**Since:** :doc:`3.1.0 </release/3.1.0>`

..  important::

    ``experimental.connpool`` is an experimental module and is subject to changes.

An ``experimental.connpool`` module provides a set of features for connecting to remote cluster instances and for executing remote procedure calls on an instance that satisfies the specified criteria.

..  NOTE::

    Note that the execution time for ``experimental.connpool`` functions depends on the number of instances and the time required to connect to each instance.



..  _connpool_module_load:

Loading a module
----------------

To load the ``experimental.connpool`` module, use the ``require()`` directive:

..  code-block:: lua

    local connpool = require('experimental.connpool')


..  _connpool_module_api_reference:

API Reference
-------------

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 35 65

        *   -   **Functions**
            -

        *   -   :ref:`connpool.call() <connpool_module_call>`
            -   Execute the specified function on a remote instance

        *   -   :ref:`connpool.connect() <connpool_module_connect>`
            -   Create a connection to the specified instance

        *   -   :ref:`connpool.filter() <connpool_module_filter>`
            -   Get names of instances that match the specified conditions





.. module:: connpool

..  _connpool_module_api_reference_functions:

Functions
~~~~~~~~~

..  _connpool_module_call:

..  function:: call(func_name, args, opts)

    Execute the specified function on a remote instance.

    ..  NOTE::

        You need to grant the ``execute`` :ref:`permission <configuration_credentials_managing_users_roles_granting_privileges>` for the specified function to a user used for replication to execute this function on a remote instance.

    :param string func_name: a name of the function to execute.
    :param table/nil args: function arguments.
    :param table/nil opts: options used to select candidates on which the function should be executed:

                           * ``labels`` -- the :ref:`labels <configuration_reference_labels>` an instance has.
                           * ``roles`` -- the :ref:`roles <configuration_application_roles>` of an instance.
                           * ``prefer_local`` -- whether to prefer a local or remote instance to execute ``call()`` on:

                               * if ``true`` (default), ``call()`` tries to execute the specified function on a local instance.
                               * if ``false``, ``call()`` tries to connect to a random candidate until a connection is established.

                           * ``mode`` -- a mode that allows filtering candidates based on their read-only status. This option accepts the following values:

                               * ``nil`` (default) -- don't check the read-only status of instances.
                               * ``ro`` -- consider only read-only instances.
                               * ``rw`` -- consider only read-write instances.
                               * ``prefer_ro`` -- consider read-only instances, then read-write instances.
                               * ``prefer_rw`` -- consider read-write instances, then read-only instances.

                           * ``instances`` -- the names of instances to consider as candidates.
                           * ``replicasets`` -- the names of replica sets whose instances are considered as candidates.
                           * ``groups`` -- the names of groups whose instances are considered as candidates.
                           * ``timeout`` -- a connection timeout (in seconds).
                           * ``buffer`` -- a :ref:`buffer <buffer-module>` used to read a returned value.
                           * ``on_push`` -- a function to execute when the client receives an out-of-band message. Learn more from :ref:`box_session-push`.
                           * ``on_push_ctx`` -- an argument of the function executed when the client receives an out-of-band message. Learn more from :ref:`box_session-push`.
                           * ``is_async`` -- whether to wait for the result of the call.

    :return: a function's return value.

    **Example**

    In the example below, the following conditions are specified to choose an instance to execute the :ref:`vshard.storage.buckets_count <storage_api-buckets_count>` function:

    *   An instance has the ``roles.crud-storage`` role.
    *   An instance has the ``dc`` label set to ``east``.
    *   An instance is read-only.

    ..  code-block:: lua

        local connpool = require('experimental.connpool')
        local buckets_count = connpool.call('vshard.storage.buckets_count',
                nil,
                { roles = { 'roles.crud-storage' },
                  labels = { dc = 'east' },
                  mode = 'ro' }
        )


..  _connpool_module_connect:

..  function:: connect(instance_name, opts)

    Create a connection to the specified instance.

    :param string instance_name: an instance name.
    :param table/nil opts: none, any, or all of the following parameters:

                           * ``connect_timeout`` -- a connection timeout (in seconds).
                           * ``wait_connected`` -- whether to block the connection until it is established:

                               * if ``true`` (default), the connection is blocked until it is established.
                               * if ``false``, the connection is returned immediately.

                           * ``fetch_schema`` -- whether to fetch schema changes from a remote instance.

    :return: a :ref:`net.box <net_box-module>` connection.

    **Example**

    In the example below, ``connect()`` is used to create the active connection to ``storage-b-002``:

    ..  code-block:: lua

        local connpool = require('experimental.connpool')
        local conn = connpool.connect("storage-b-002", { fetch_schema = true })

    Once you have a connection, you can execute requests on a remote instance, for example, select data from a space using :ref:`conn.space.\<space-name\>:select() <conn-select>`.


..  _connpool_module_filter:

..  function:: filter(opts)

    Get names of instances that match the specified conditions.

    :param table/nil opts: none, any, or all of the following parameters:

                           * ``labels`` -- the :ref:`labels <configuration_reference_labels>` an instance has.
                           * ``roles`` -- the :ref:`roles <configuration_application_roles>` of an instance.
                           * ``mode`` -- a mode that allows filtering candidates based on their read-only status. This option accepts the following values:

                               * ``nil`` (default) -- don't check the read-only status of instances.
                               * ``ro`` -- consider only read-only instances.
                               * ``rw`` -- consider only read-write instances.

                           * ``instances`` -- the names of instances to consider as candidates.
                           * ``replicasets`` -- the names of replica sets whose instances are considered as candidates.
                           * ``groups`` -- the names of groups whose instances are considered as candidates.

    :return: an array of instance names.

    **Example**

    In the example below, ``filter()`` should return a list of instances with the ``roles.crud-storage`` role and specified label value:

    ..  code-block:: lua

        local connpool = require('experimental.connpool')
        local instance_names = connpool.filter({ roles = { 'roles.crud-storage' },
                                                 labels = { dc = 'east' } })
