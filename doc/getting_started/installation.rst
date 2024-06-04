.. _tarantool_installation:

Installation
============

This section explains how to download and set up Tarantool Enterprise Edition and run
a sample application provided with it.
To learn how to download and install Tarantool Community Edition, see the `Download <https://www.tarantool.io/en/download/>`_ page.

..  NOTE::

    For developers: :ref:`tt-install`.


.. _enterprise-prereqs:

System requirements
-------------------

The recommended system requirements for running Tarantool Enterprise are as
follows.

.. _enterprise-prereqs-hardware:

Hardware requirements
~~~~~~~~~~~~~~~~~~~~~

To fully ensure the fault tolerance of a distributed data storage system, at
least **three** physical computers or virtual servers are required.

For testing/development purposes, the system can be deployed using a smaller number
of servers; however, it is not recommended to use such configurations for production.

.. _enterprise-prereqs-software:

Software requirements
~~~~~~~~~~~~~~~~~~~~~

#. As host operating systems, Tarantool Enterprise Edition supports
   **Red Hat Enterprise Linux** and **CentOS** versions 7.5 and higher.

   .. NOTE::

      Tarantool Enterprise can run on other ``systemd``-based Linux distributions
      but it is not tested on them and may not work as expected.

#. ``glibc`` 2.17-260.el7_6.6 and higher is required. Take care to check and
   update, if needed:

   .. code-block:: console

       $ rpm -q glibc
       glibc-2.17-196.el7_4.2
       $ yum update glibc

.. _enterprise-prereqs-network:

Network requirements
~~~~~~~~~~~~~~~~~~~~

Hereinafter, **"storage servers"** or **"Tarantool servers"** are the computers
used to store and process data, and **"administration server"** is the computer
used by the system operator to install and configure the product.

The Tarantool cluster has a full mesh topology, therefore all Tarantool servers
should be able to communicate and send traffic from and to TCP/UDP ports
used by the cluster's instances (see ``advertise_uri: <host>:<port>`` and
``config: advertise_uri: '<host>:<port>'`` in ``/etc/tarantool/conf.d/*.yml``
for each instance). For example:

.. code-block:: kconfig

    # /etc/tarantool/conf.d/*.yml

    myapp.s2-replica:
      advertise_uri: localhost:3305 # this is a TCP/UDP port
      http_port: 8085

    all:
      ...
      hosts:
        storage-1:
          config:
            advertise_uri: 'vm1:3301' # this is a TCP/UDP port
            http_port: 8081

To configure remote monitoring or to connect via the administrative console,
the administration server should be able to access the following TCP ports on
Tarantool servers:

* 22 to use the SSH protocol,
* ports specified in instance configuration to monitor the HTTP-metrics.

Additionally, it is recommended to apply the following settings for ``sysctl``
on all Tarantool servers:

.. code-block:: console

    $ # TCP KeepAlive setting
    $ sysctl -w net.ipv4.tcp_keepalive_time=60
    $ sysctl -w net.ipv4.tcp_keepalive_intvl=5
    $ sysctl -w net.ipv4.tcp_keepalive_probes=5

This optional setup of the Linux network stack helps speed up the troubleshooting
of network connectivity when the server physically fails. To achieve maximum
performance, you may also need to configure other network stack parameters that
are not specific to the Tarantool DBMS. For more information, please refer to the
`Network Performance Tuning Guide <https://access.redhat.com/sites/default/files/attachments/20150325_network_performance_tuning.pdf>`_
section of the RHEL7 user documentation.

.. _enterprise-package-contents:

Package contents
----------------

The latest release packages of Tarantool Enterprise are available in the
`customer zone <https://www.tarantool.io/accounts/customer_zone/packages/enterprise>`_
at Tarantool website. Please contact ``support@tarantool.io`` for access.

Each package is distributed as a ``tar + gzip`` archive and includes
the following components and features:

* Static Tarantool binary for simplified deployment in Linux environments.
* ``tt`` command-line utility that provides a unified command-line interface for
  managing Tarantool-based applications. See :ref:`tt-cli` for details.
* |tcm_full_name| -- a web-based interface for managing Tarantool EE clusters.
  See :ref:`tcm` for details.
* Selection of open and closed source modules.
* Sample application walking you through all included modules

Archive contents:

* ``tarantool`` is the main executable of Tarantool.
* ``tt`` command-line utility.
* ``tcm`` is the |tcm_full_name| executable.
* ``tarantoolctl`` is the utility script for installing supplementary modules
  and connecting to the administrative console.

  .. important::

    ``tarantoolctl`` is deprecated in favor of the :ref:`tt CLI utility <tt-cli>`.

* ``examples/`` is the directory containing sample applications:

  * ``pg_writethrough_cache/`` is an application showcasing how Tarantool can
    cache data written to, for example, a PostgreSQL database;
  * ``ora_writebehind_cache/`` is an application showcasing how Tarantool can
    cache writes and queue them to, for example, an Oracle database;
  * ``docker/`` is an application designed to be easily packed into a Docker
    container;

* ``rocks/`` is the directory containing a selection of additional open and
  closed source modules included in the distribution as an offline rocks
  repository. See the :ref:`rocks reference <enterprise-rocks>` for details.
* ``templates/`` is the directory containing template files for your application
  development environment.
* ``deprecated/`` is a set of modules that are no longer supported:

  * ``vshard-zookeeper-orchestrator`` is a Python application
    for launching ``orchestrator``,
  * ``zookeeper-scm`` files are the ZooKeeper integration modules (require
    ``usr/`` libraries).

.. _archive-unpack:
.. _enterprise-install:

Installation
------------

The delivered ``tar + gzip`` archive should be uploaded to a server and unpacked:

.. code-block:: console

    $ tar xvf tarantool-enterprise-sdk-<version>.tar.gz

No further installation is required as the unpacked binaries are almost ready
to go. Go to the directory with the binaries (``tarantool-enterprise``) and
add them to the executable path by running the script provided by the distribution:

.. code-block:: console

    $ source ./env.sh

Make sure you have enough privileges to run the script and that the file is executable.
Otherwise, try ``chmod`` and ``chown`` commands to adjust it.

Next, set up your development environment as described in
:ref:`the developer's guide <enterprise-app-development>`.
