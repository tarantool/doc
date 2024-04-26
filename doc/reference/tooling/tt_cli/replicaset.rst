.. _tt-replicaset:

Working with replicasets
=========================

..  code-block:: console

    $ tt replicaset COMMAND {APPLICATION[:APP_INSTANCE] | URI} [OPTIONS ...]
    # or
    $ tt rs COMMAND {APPLICATION[:APP_INSTANCE] | URI} [OPTIONS ...]

``tt replicaset`` (or ``tt rs``) manages a Tarantool replica set.

``COMMAND`` is one of the following:

*   :ref:`status <tt-replicaset-status>`
*   :ref:`promote <tt-replicaset-promote>`
*   :ref:`demote <tt-replicaset-demote>`


.. _tt-replicaset-status:

status
------

..  code-block:: console

    $ tt replicaset status {APPLICATION[:APP_INSTANCE] | URI} [OPTIONS ...]
    # or
    $ tt rs status  {APPLICATION[:APP_INSTANCE] | URI} [OPTIONS ...]

``tt replicaset status`` (``tt rs status``) shows the current status of a replica set.


.. _tt-replicaset-status-application:

Displaying status of all replica sets
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To view the status of all replica sets of an application in the current ``tt``
environment, run ``tt replicaset status`` with the application name:

..  code-block:: console

    $ tt replicaset status myapp

.. _tt-replicaset-status-instance:

Displaying status of a single replica set
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To view the status of a single replica set of an application , run ``tt replicaset status``
with a name or a URI of an instance from this replica set:

..  code-block:: console

    $ tt replicaset status myapp:storage-001-a

..  code-block:: console

    $ tt replicaset status 192.168.10.10:3301

.. _tt-replicaset-status-authentication:

Authentication
~~~~~~~~~~~~~~

Use one of the following ways to pass the username and the password when connecting
to the instance:

*   The ``-u`` (``--username``) and ``-p`` (``--password``) options:

    ..  code-block:: console

        $ tt replicaset status 192.168.10.10:3301 -u myuser -p p4$$w0rD

*   The connection string:

    ..  code-block:: console

        $ tt replicaset status myuser:p4$$w0rD@192.168.10.10:3301

*   Environment variables ``TT_CLI_USERNAME`` and ``TT_CLI_PASSWORD``:

    ..  code-block:: console

        $ export TT_CLI_USERNAME=myuser
        $ export TT_CLI_PASSWORD=p4$$w0rD
        $ tt replicaset status 192.168.10.10:3301

.. _tt-replicaset-status-force:

Selecting the application orchestrator manually
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can specify the orchestrator to use for the application using the following options:

*   ``--config`` for applications that use YAML cluster configuration (Tarantool 3.x or later).
*   ``--cartridge`` for Cartridge applications (Tarantool 2.x).
*   ``--custom`` for any other orchestrators used on Tarantool 2.x clusters.

..  code-block:: console

    $ tt replicaset status myapp --config
    $ tt replicaset status my-cartridge-app --cartridge

If an actual orchestrator that the application uses does not match the specified
option, an error is raised.


.. _tt-replicaset-status-options:

Options
~~~~~~~

..  option:: --cartridge

    Force the Cartridge orchestrator for Tarantool 2.x clusters.

..  option:: --config

    Force the YAML configuration orchestrator for Tarantool 3.0 or later clusters.

..  option:: --custom

    Force a custom orchestrator for Tarantool 2.x clusters.

..  option:: -u USERNAME, --username USERNAME

    A Tarantool user for connecting to the instance.

..  option:: -p PASSWORD, --password PASSWORD

    The user's password.

..  option:: --sslcertfile FILEPATH

    The path to an SSL certificate file for encrypted connections.

..  option:: --sslkeyfile FILEPATH

    The path to a private SSL key file for encrypted connections.

..  option:: --sslcafile FILEPATH

    The path to a trusted certificate authorities (CA) file for encrypted connections.

..  option:: --sslciphers STRING

    The list of SSL cipher suites used for encrypted connections, separated by colons (``:``).

.. _tt-replicaset-promote:

promote
-------

``tt replicaset promote`` (``tt rs promote``) promotes an instance.

.. _tt-replicaset-demote:

demote
------

``tt replicaset deomote`` (``tt rs demote``) demotes an instance.



