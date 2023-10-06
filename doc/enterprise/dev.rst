.. _enterprise-app-development:

===============================================================================
Developer's guide
===============================================================================

To develop an application, use the Tarantool Cartridge framework that is
:ref:`installed <enterprise-install>` as part of Tarantool Enterprise.

Here is a summary of the commands you need:

#. Create a cluster-aware application from the template:

   .. code-block:: bash

       $ tt create cartridge --name <app_name> -d /path/to

#. Develop your application:

   .. code-block:: bash

       $ cd /path/to/<app_name>
       $ ...

#. Package your application:

   .. code-block:: bash

       $ tt pack [rpm|tgz] /path/to/<app_name>

#. Deploy your application:

   * For ``rpm`` package:

     1. Upload the package to all servers dedicated to Tarantool.
     2. Install the package:

        .. code-block:: bash

            $ yum install <app_name>-<version>.rpm

     3. Launch the application.

        .. code-block:: bash

            $ systemctl start <app_name>

   * For ``tgz`` archive:

     1. Upload the archive to all servers dedicated to Tarantool.
     2. Unpack the archive:

        .. code-block:: bash

            $ tar -xzvf <app_name>-<version>.tar.gz -C /home/<user>/apps

     3. Launch the application

        .. code-block:: bash

            $ tarantool init.lua

For details and examples, please consult the open-source Tarantool documentation:

* a `getting started guide <https://github.com/tarantool/cartridge-cli/blob/master/examples/getting-started-app/README.md>`_
  that walks you through developing and deploying a simple clustered application using
  Tarantool Cartridge,
* a :doc:`detailed manual </book/cartridge/index>`
  on creating and managing clustered Tarantool applications using
  Tarantool Cartridge.

Further on, this guide focuses on Enterprise-specific developer features available
on top of the open-source Tarantool version with the Tarantool Cartridge framework:

* :ref:`LDAP authorization in the web interface <ldap_auth>`,
* :ref:`environment-independent applications <enterprise-env-independent-apps>`,
* :ref:`sample applications with Enterprise flavors <enterprise-run-app>`.

.. _ldap_auth:

-------------------------------------------------------------------------------
Implementing LDAP authorization in the web interface
-------------------------------------------------------------------------------

If you run an LDAP server in your organization, you can connect Tarantool
Enterprise to it and let it handle the authorization. In this case, follow the
:ref:`general recipe <cartridge-auth-enable>`
where in the first step add the ``ldap`` module to the ``.rockspec`` file
as a dependency and consider implementing the ``check_password`` function
the following way:

.. code-block:: Lua
   :emphasize-lines: 4, 10, 13

   -- auth.lua
   -- Require the LDAP module at the start of the file
   local ldap = require('ldap')
   ...
   -- Add a function to check the credentials
   local function check_password(username, password)

       -- Configure the necessary LDAP parameters
       local user = string.format("cn=%s,ou=tarantool,dc=glauth,dc=com", username)

       -- Connect to the LDAP server
       local ld, err = ldap.open("localhost:3893", user, password)

       -- Return an authentication success or failure
       if not ld then
          return false
       end
       return true
   end
    ...

.. _enterprise-env-independent-apps:

--------------------------------------------------------------------------------
Delivering environment-independent applications
--------------------------------------------------------------------------------

Tarantool Enterprise allows you to build environment-independent applications.

An environment-independent application is an assembly (in one directory) of:

* files with Lua code,
* ``tarantool`` executable,
* plugged external modules (if necessary).

When started by the ``tarantool`` executable, the application provides a
service.

The modules are Lua rocks installed into a virtual environment (under the
application directory) similar to Python's ``virtualenv`` and Ruby's bundler.

Such an application has the same structure both in development and
production-ready phases. All the application-related code resides in one place,
ready to be packed and copied over to any server.

.. _enterprise-app-package:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Packaging applications
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Once custom cluster role(s) are defined and the application is developed, pack
it and all its dependencies (module binaries) together with the ``tarantool``
executable.

This will allow you to upload, install, and run your application on any server in
one go.

To pack the application, say:

.. code-block:: console

   $ tt pack [rpm|tgz] /path/to/<app_name>

where specify a path to your development environment -- the Git repository
containing your application code, -- and one of the following build options:

* ``rpm`` to build an RPM package (recommended), or
* ``tgz`` to build a ``tar + gz`` archive
  (choose this option only if you do not have root
  privileges on servers dedicated for Tarantool Enterprise).

This will create a package (or compressed archive) named
``<app_name>-<version_tag>-<number_of_commits>`` (e.g., ``myapp-1.2.1-12.rpm``)
containing your environment-independent application.

Next, proceed to deploying :ref:`packaged applications <enterprise-packaged-app>`
(or :ref:`archived ones <enterprise-archived-app>`) on your servers.

.. _enterprise-packaged-app:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Deploying packaged applications
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To deploy your packaged application, do the following on every server dedicated
for Tarantool Enterprise:

#. Upload the package created in the :ref:`previous step <enterprise-app-package>`.

#. Install:

   .. code-block:: console

      $ yum install <app_name>-<version>.rpm

#. Start one or multiple Tarantool instances with the corresponding services
   as described below.

   * A single instance:

     .. code-block:: console

        $ systemctl start <app_name>

     This will start an instantiated ``systemd`` service that will listen to port
     ``3301``.

   * Multiple instances on one or multiple servers:

     .. code-block:: console

        $ systemctl start <app_name>@instance_1
        $ systemctl start <app_name>@instance_2
        ...
        $ systemctl start <app_name>@instance_<number>

     where ``<app_name>@instance_<number>`` is the instantiated service name
     for ``systemd`` with an incremental ``<number>`` (unique for every
     instance) to be added to the ``3300`` port the instance will listen to
     (e.g., ``3301``, ``3302``, etc.).

#. In case it is a cluster-aware application, proceed to
   :ref:`deploying the cluster <cartridge-deployment>`.

To stop all services on a server, use the ``systemctl stop`` command and specify
instance names one by one. For example:

.. code-block:: console

   $ systemctl stop <app_name>@instance_1 <app_name>@instance_2 ... <app_name>@instance_<N>

.. _enterprise-archived-app:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Deploying archived applications
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

While the RPM package places your application to ``/usr/share/tarantool/<app_name>``
on your server by default, the ``tar + gz`` archive does not enforce any structure
apart from just the ``<app_name>/`` directory, so you are responsible for placing
it appropriately.

.. NOTE::

   RPM packages are recommended for deployment. Deploy archives only if
   you do not have root privileges.

To place and deploy the application, do the following on every server dedicated
for Tarantool Enterprise:

#. Upload the archive, decompress, and extract it to the ``/home/<user>/apps``
   directory:

   .. code-block:: console

      $ tar -xzvf <app_name>-<version>.tar.gz -C /home/<user>/apps

#. Start Tarantool instances with the corresponding services.

   To manage instances and configuration, use tools like ``ansible``,
   ``systemd``, and ``supervisord``.

#. In case it is a cluster-aware application, proceed to
   :ref:`deploying the cluster <cartridge-deployment>`.

.. _enterprise-code-upgrade:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Upgrading code
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

All instances in the cluster are to run the same code. This includes all the
components: custom roles, applications, module binaries, ``tarantool``, and
``tt`` (if necessary) executables.

Pay attention to possible backward incompatibility that any component may
introduce. This will help you choose a scenario for an
:ref:`upgrade in production <enterprise-production-upgrade>`. Keep in mind that
you are responsible for code compatibility and handling conflicts should
inconsistencies occur.

To upgrade any of the components, prepare a new version of the package (archive):

#. Update the necessary files in your development environment (directory):

   * Your own source code: custom roles and/or applications.
   * Module binaries.
   * Executables. Replace them with ones from the new bundle.

#. Increment the version as described in
   :ref:`application versioning <cartridge-versioning>`.

#. Repack the updated files as described in :ref:`packaging applications <enterprise-app-package>`.

#. Choose an upgrade scenario as described in the :ref:`Upgrading in production <enterprise-production-upgrade>`
   section.

.. _enterprise-run-app:

-------------------------------------------------------------------------------
Running sample applications
-------------------------------------------------------------------------------

The Enterprise distribution package includes sample applications in the
``examples/`` directory that showcase basic Tarantool functionality.

.. contents:: Sample applications:
   :depth: 1
   :local:

.. _enterprise-pg-write-through-cache:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Write-through cache application for PostgreSQL
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The example in ``pg_writethrough_cache/`` shows how Tarantool can cache data
written *through* it to a PostgreSQL database to speed up the reads.

The sample application requires a deployed PostgreSQL database and the following
rock modules:

.. code-block:: console

    $ tt rocks install http
    $ tt rocks install pg
    $ tt rocks install argparse

Look through the code in the files to get an understanding of what the application
does.

To run the application for a local PostgreSQL database, say:

.. code-block:: console

    $ tarantool cachesrv.lua --binary-port 3333 --http-port 8888 --database postgresql://localhost/postgres

.. _enterprise-ora-write-behind-cache:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Write-behind cache application for Oracle
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The example in ``ora-writebehind-cache/`` shows how Tarantool can cache writes
and queue them to an Oracle database to speed up both writes and reads.

.. _enterprise-ora-write-behind-cache_reqs:

*******************************************************************************
Application requirements
*******************************************************************************

The sample application requires:

* deployed Oracle database;
* Oracle tools: `Instant Client and SQL Plus <https://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html>`_,
  both of version 12.2;

  .. NOTE::

     In case the Oracle Instant Client errors out on ``.so`` files
     (Oracle's dynamic libraries), put them to some directory and add it to the
     ``LD_LIBRARY_PATH`` environment variable.

     For example: ``export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/<path_to_so_files>``

* rock modules listed in the ``rockspec`` file.

To install the modules, run the following command in the ``examples/ora_writebehind_cache``
directory:

.. code-block:: console

   $ tt rocks make oracle_rb_cache-0.1.0-1.rockspec

If you do not have a deployed Oracle instance at hand, run a dummy in a Docker
container:

#. In the browser, log in to `Oracle container registry <container-registry.oracle.com>`_,
   click **Database**, and accept the Oracle's Enterprise Terms and Restrictions.

#. In the ``ora-writebehind-cache/`` directory, log in to the repository under
   the Oracle account, pull, and run an image using the prepared scripts:

   .. code-block:: console

      $ docker login container-registry.oracle.com
      Login:
      Password:
      Login Succeeded
      $ docker pull container-registry.oracle.com/database/enterprise:12.2.0.1
      $ docker run -itd \
         -p 1521:1521 \
         -p 5500:5500 \
         --name oracle \
         -v "$(pwd)"/setupdb/configDB.sh:/home/oracle/setup/configDB.sh \
         -v "$(pwd)"/setupdb/runUserScripts.sh:/home/oracle/setup/runUserScripts.sh \
         -v "$(pwd)"/startupdb:/opt/oracle/scripts/startup \
         container-registry.oracle.com/database/enterprise:12.2.0.1

When all is set and done, run the example application.

.. _enterprise-ora-write-behind-cache_run:

*******************************************************************************
Running write-behind cache
*******************************************************************************

To launch the application, run the following in the ``examples/ora_writebehind_cache``
directory:

.. code-block:: console

   $ tarantool init.lua

The application supports the following requests:

* Get: ``GET http://<host>:<http_port>/account/id``;
* Add: ``POST http://<host>:<http_port>/account/`` with the following data:

  .. code-block:: console

     {"clng_clng_id":1,"asut_asut_id":2,"creation_data":"01-JAN-19","navi_user":"userName"}

* Update: ``POST http://<host>:<http_port>/account/id`` with the same data as in the add request;
* Remove: ``DELETE http://<host>:<http_port>/account/id`` where ``id`` is an account identifier.

Look for sample CURL scripts in the ``examples/ora_writebehind_cache/testing``
directory and check ``README.md`` for more information on implementation.

.. _enterprise-docker-app:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Hello-world application in Docker
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The example in the ``docker/`` directory contains a hello-world application
that you can pack in a Docker container and run on CentOS 7.

The ``hello.lua`` file is the entry point and it is very bare-bones, so you
can add your code here.

#. To build the container, say:

   .. code-block:: console

      $ docker build -t tarantool-enterprise-docker -f Dockerfile ../..

#. To run it:

   .. code-block:: console

      $ docker run --rm -t -i tarantool-enterprise-docker
