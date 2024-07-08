.. _admin-instance_config:
.. _admin-instance-environment-overview:
.. _admin-tt_config_file:

Application environment
=======================

This section provides a high-level overview on how to prepare a Tarantool application for deployment
and how the application's environment and layout might look.
This information is helpful for understanding how to administer Tarantool instances using :ref:`tt CLI <tt-cli>` in both development and production environments.

The main steps of creating and preparing the application for deployment are:

1.  :ref:`admin-instance_config-init-environment`.

2.  :ref:`admin-instance_config-develop-app`.

3.  :ref:`admin-instance_config-package-app`.

In this section, a `sharded_cluster_crud <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud>`_ application is used as an example.
This cluster includes 5 instances: one router and 4 storages, which constitute two replica sets.

.. image:: /book/admin/admin_instances_dev.png
    :align: left
    :width: 700
    :alt: Cluster topology



.. _admin-instance_config-init-environment:
.. _admin-start_stop_instance-running_locally:

Initializing a local environment
--------------------------------

Before creating an application, you need to set up a local environment for ``tt``:

1.  Create a home directory for the environment.

2.  Run ``tt init`` in this directory:

    .. code-block:: console

        ~/myapp$ tt init
           • Environment config is written to 'tt.yaml'

This command creates a default ``tt`` configuration file ``tt.yaml`` for a local
environment and the directories for applications, control sockets, logs, and other
artifacts:

.. code-block:: console

    ~/myapp$ ls
    bin  distfiles  include  instances.enabled  modules  templates  tt.yaml

Find detailed information about the ``tt`` configuration parameters and launch modes
on the :ref:`tt configuration page <tt-config>`.



.. _admin-instance_config-develop-app:
.. _admin-start_stop_instance-multi-instance:
.. _admin-start_stop_instance-multi-instance-layout:

Creating and developing an application
--------------------------------------

You can create an application in two ways:

-   Manually by preparing its layout in a directory inside ``instances_enabled``.
    The directory name is used as the application identifier.

-   From a template by using the :ref:`tt create <tt-create>` command.

In this example, the application's layout is prepared manually and looks as follows.

.. code-block:: console

    ~/myapp$ tree
    .
    ├── bin
    ├── distfiles
    ├── include
    ├── instances.enabled
    │   └── sharded_cluster_crud
    │       ├── config.yaml
    │       ├── instances.yaml
    │       ├── router.lua
    │       ├── sharded_cluster_crud-scm-1.rockspec
    │       └── storage.lua
    ├── modules
    ├── templates
    └── tt.yaml


The ``sharded_cluster_crud`` directory contains the following files:

-   ``config.yaml``: contains the :ref:`configuration <configuration>` of the cluster. This file might include the entire cluster topology or provide connection settings to a centralized configuration storage.
-   ``instances.yml``: specifies instances to run in the current environment. For example, on the developer’s machine, this file might include all the instances defined in the cluster configuration. In the production environment, this file includes :ref:`instances to run on the specific machine <admin-instances_to_run>`.
-   ``router.lua``: includes code specific for a :ref:`router <vshard-architecture-router>`.
-   ``sharded_cluster_crud-scm-1.rockspec``: specifies the required external dependencies (for example, ``vshard`` and ``crud``).
-   ``storage.lua``: includes code specific for :ref:`storages <vshard-architecture-storage>`.

You can find the full example here:
`sharded_cluster_crud <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud>`_.



.. _admin-instance_config-package-app:
.. _admin-instance-app-layout:
.. _admin-instance_file:

Packaging the application
-------------------------

To package the ready application, use the :ref:`tt pack <tt-pack>` command.
This command can create an installable DEB/RPM package or generate ``.tgz`` archive.

The structure below reflects the content of the packed ``.tgz`` archive for the `sharded_cluster_crud <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud>`_ application:

.. code-block:: console

    ~/myapp$ tree -a
    .
    ├── bin
    │   ├── tarantool
    │   └── tt
    ├── instances.enabled
    │   └── sharded_cluster_crud -> ../sharded_cluster_crud
    ├── sharded_cluster_crud
    │   ├── .rocks
    │   │   └── share
    │   │       └── ...
    │   ├── config.yaml
    │   ├── instances.yaml
    │   ├── router.lua
    │   └── storage.lua
    └── tt.yaml


The application's layout looks similar to the one defined when :ref:`developing the application <admin-instance_config-develop-app>` with some differences:

-   ``bin``: contains the ``tarantool`` and ``tt`` binaries packed with the application bundle.

-   ``instances.enabled``: contains a symlink to the packed ``sharded_cluster`` application.

-   ``sharded_cluster_crud``: a packed application. In addition to files created during the application development, includes the ``.rocks`` directory containing application dependencies (for example, ``vshard`` and ``crud``).

-   ``tt.yaml``: a ``tt`` configuration file.

.. note::

    In DEB/PRM packages generated by :ref:`tt pack <tt-pack>`, there are also ``.service``
    unit files for each packaged application.

.. _admin-instance_config-deploy-app:

Deploying the application
-------------------------

.. _admin-instances_to_run:

Instances to run
~~~~~~~~~~~~~~~~

When deploying a distributed cluster application from a `.tar.gz` archive, you can
define instances to run on each machine by changing the content of the ``instances.yaml`` file.

-   On the developer's machine, this file might include all the instances defined in the cluster configuration.

    .. image:: /book/admin/admin_instances_dev.png
        :align: left
        :width: 700
        :alt: Cluster topology

    ``instances.yaml``:

    ..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud/instances.yaml
        :language: yaml
        :dedent:

-   In the production environment, this file includes instances to run on the specific machine.

    .. image:: /book/admin/admin_instances_prod.png
        :align: left
        :width: 700
        :alt: Cluster topology

    ``instances.yaml`` (Server-001):

    .. code-block:: yaml

        router-a-001:

    ``instances.yaml`` (Server-002):

    .. code-block:: yaml

        storage-a-001:
        storage-b-001:

    ``instances.yaml`` (Server-003):

    .. code-block:: yaml

        storage-a-002:
        storage-b-002:

The :ref:`Starting and stopping instances <admin-start_stop_instance>` section describes how to start and stop Tarantool instances.

.. _admin-deploy-rpm-deb:

DEB and RPM packages
~~~~~~~~~~~~~~~~~~~~

Tarantool applications installed from DEB and RPM packages built with :ref:`tt pack <tt-pack>`
can run as ``systemd`` services. They run on behalf of the ``tarantool`` system user.
It is created automatically during the package installation.

By default, the application artifacts are placed in the following directories:

-   ``/var/lib/tarantool/sys_env`` -- application data
-   ``/var/log/tarantool/sys_env`` -- logs
-   ``/var/run/tarantool/sys_env`` -- runtime artifacts

If you want to change these directories, make sure that the ``tarantool`` user
has enough permissions on the directories you use.