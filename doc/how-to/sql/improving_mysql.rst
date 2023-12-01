.. _improving_mysql:

================================================================================
Improving MySQL with Tarantool
================================================================================

Replicating MySQL is one of the Tarantool’s killer functions.
It allows you to keep your existing MySQL database while at the same time
accelerating it and scaling it out horizontally. Even if you aren’t interested
in extensive expansion, replacing existing replicas with Tarantool can
save you money, because Tarantool is more efficient per core than MySQL. To read
a testimonial of a company that implemented Tarantool replication on a large scale,
please see
`here <https://dzone.com/articles/next-level-mysql-performance-tarantool-as-a-replic>`_.

Notes:

* if you run into any trouble with regards to the basics of Tarantool, you may
  wish to consult the :ref:`Getting started guide <getting_started_db>` or
  the :ref:`Data model description <box_data_model>`.

* these instructions are for **CentOS 7.5** and **MySQL 5.7**. They also assume
  that you have systemd installed and are working with an existing MySQL installation.

* a helpful log for troubleshooting during this tutorial is ``replicatord.log``
  in ``/var/log``. You can also have a look at the instance’s log ``example.log``
  in ``/var/log/tarantool``.

So let’s proceed.

#. First, install the necessary packages in CentOS:

   .. code-block:: bash

       yum -y install git ncurses-devel cmake gcc-c++ boost boost-devel wget unzip nano bzip2 mysql-devel mysql-lib

#. Then clone the Tarantool-MySQL replication package from GitHub:

   ..  code-block:: bash

       git clone https://github.com/tarantool/mysql-tarantool-replication.git

#. Build the replicator with ``cmake``:

   ..  code-block:: bash

       cd mysql-tarantool-replication
       git submodule update --init --recursive
       cmake .
       make

#. Our replicator will run as a systemd daemon called replicatord, so let’s edit
   its systemd service file, ``replicatord.service``, in the
   mysql-tarantool-replication repo.

   ..  code-block:: bash

       nano replicatord.service

   Change the following line:

   ..  code-block:: bash

       ExecStart=/usr/local/sbin/replicatord -c /usr/local/etc/replicatord.cfg

   Replace the ``.cfg`` extension with ``.yml``:

   ..  code-block:: bash

       ExecStart=/usr/local/sbin/replicatord -c /usr/local/etc/replicatord.yml

#. Next, copy some files from our replicatord repo to other necessary locations:

   ..  code-block:: bash

       cp replicatord /usr/local/sbin/replicatord
       cp replicatord.service /etc/systemd/system

#. After that, enter the MySQL console and create a sample database (depending on
   your existing installation, you may of course be a user other than root):

   ..  code-block:: sql

       mysql -u root -p
       CREATE DATABASE menagerie;
       QUIT

#. Next, get some sample data from MySQL, which we’ll pull into our root
   directory, then install from the terminal:

   ..  code-block:: sql

       cd
       wget http://downloads.mysql.com/docs/menagerie-db.zip
       unzip menagerie-db.zip
       cd menagerie-db
       mysql -u root -p menagerie < cr_pet_tbl.sql
       mysql -u root -p menagerie < load_pet_tbl.sql
       mysql menagerie -u root -p < ins_puff_rec.sql
       mysql menagerie -u root -p < cr_event_tbl.sql

#. Enter the MySQL console now and massage the data for use with the
   Tarantool replicator (we are adding an ID, changing a field name to avoid
   conflict, and cutting down the number of fields; note that with real data,
   this is the step that will involve the most tweaking):

   .. code-block:: sql

      mysql -u root -p
      USE menagerie;
      ALTER TABLE pet ADD id INT PRIMARY KEY AUTO_INCREMENT FIRST;
      ALTER TABLE pet CHANGE COLUMN 'name' 'name2' VARCHAR(255);
      ALTER TABLE pet DROP sex, DROP birth, DROP death;
      QUIT

#. Now that we have the sample data set up, we’ll need to edit MySQL’s
   configuration file for use with the replicator.

   .. code-block:: bash

      cd
      nano /etc/my.cnf

   Note that your ``my.cnf`` for MySQL could be in a slightly different location.
   Set:

   .. code-block:: bash

      [mysqld]
      binlog_format = ROW
      server_id = 1
      log-bin = mysql-bin
      interactive_timeout = 3600
      wait_timeout = 3600
      max_allowed_packet = 32M
      socket = /var/lib/mysql/mysql.sock
      bind-address = 127.0.0.1

      [client]
      socket = /var/lib/mysql/mysql.sock

#. After exiting nano, restart mysqld:

   .. code-block:: bash

      systemctl restart mysqld

#. Next, let’s install Tarantool and set up spaces for replication.
   Go to the `Download page
   <https://www.tarantool.io/en/download/os-installation/rhel-centos/>`_ and
   follow the instructions there to install Tarantool.

#. Now we will write a standard Tarantool program by editing the Lua example,
   which comes with Tarantool:

   .. code-block:: bash

      cd
      nano /etc/tarantool/instances.available/example.lua

#. Replace the entire contents of the file with the following:

    ..  literalinclude:: /code_snippets/snippets/mysql/instances.enabled/mysql.lua
        :language: lua
        :lines: 3-17
        :dedent:

   To understand more of what’s happening here, it would be best to have a look
   back at the earlier
   `articles <https://dzone.com/articles/tarantool-101-10-steps-for-absolute-beginners-the>`_
   in the Tarantool 101 series or use the :ref:`getting-started <getting_started_db>` guide.

#. Now we need to create a symlink from ``instances.available`` to a directory named
   ``instances.enabled`` (similar to NGINX). So in ``/etc/tarantool`` run the
   following:

   .. code-block:: bash

      mkdir instances.enabled
      ln -s /instances.available/example.lua instances.enabled

#. Next we can start up our Lua program with ``tt``, the Tarantool command-line
   utility:

   .. code-block:: bash

      tt start example

#. Then enter our Tarantool instance, where we can check that our target
   spaces were successfully created:

   .. code-block:: bash

      tt connect example

   .. code-block:: tarantoolsession

      tarantool> box.space._space:select()

   At the bottom you will see "mysqldaemon" and "mysqldata" spaces. Then exit with "CTRL+C".

#. Now that we have MySQL and Tarantool set up, we can proceed to configure
   our replicator. First let’s work with ``replicatord.yml`` in the main
   ``tarantool-mysql-replication`` directory.

   .. code-block:: bash

      nano replicatord.yml

   Change the entire file as follows, making sure to add your MySQL password and
   to set the appropriate user:

   .. code-block:: bash

     mysql:
         host: 127.0.0.1
         port: 3306
         user: root
         password:
         connect_retry: 15 # seconds

     tarantool:
         host: 127.0.0.1:3301
         binlog_pos_space: 512
         binlog_pos_key: 0
         connect_retry: 15 # seconds
         sync_retry: 1000 # milliseconds

     mappings:
         - database: menagerie
           table: pet
           columns: [ id, name2, owner, species ]
           space: 513
           key_fields:  [ 0 ]
           # insert_call: function_name
           # update_call: function_name
           # delete_call: function_name

#. Now we need to copy replicatord.yml to the location where systemd looks for it:

   .. code-block:: bash

      cp replicatord.yml /usr/local/etc/replicatord.yml

#. Next we can start up the replicator:

   .. code-block:: bash

      systemctl start replicatord

   Now we can enter our Tarantool instance and do a select on the “mysqldata”
   space. We will see the replicated content from MySQL:

   .. code-block:: bash

      tt connect example

   .. code-block:: tarantoolsession

       tarantool> box.space.mysqldata:select()
       ---
       - - [1, 'Fluffy', 'Harold', 'cat']
         - [2, 'Claws', 'Gwen', 'cat']
         - [3, 'Buffy', 'Harold', 'dog']
         - [4, 'Fang', 'Benny', 'dog']
         - [5, 'Bowser', 'Diane', 'dog']
         - [6, 'Chirpy', 'Gwen', 'bird']
         - [7, 'Whistler', 'Gwen', 'bird']
         - [8, 'Slim', 'Benny', 'snake']
         - [9, 'Puffball', 'Diane', 'hamster']


#. Finally let’s enter a record into MySQL and then go back to Tarantool to make
   sure it’s replicated. So first we’ll exit our Tarantool instance with
   ``CTRL-C``, and then say:

   .. code-block:: sql

      mysql -u root -p
      USE menagerie;
      INSERT INTO pet(name2, owner, species) VALUES ('Spot', 'Brad', 'dog');
      QUIT

   Once back in the terminal enter:

   .. code-block:: bash

      tt connect example

   .. code-block:: tarantoolsession

      tarantool> box.space.mysqldata:select()

   You should see the replicated data in Tarantool!
