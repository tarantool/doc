.. _improving_mysql:

Improving MySQL with Tarantool
==============================

Replicating MySQL is one of the Tarantool’s killer functions.
It allows you to keep your existing MySQL database while at the same time
accelerating it and scaling it out horizontally. Even if you aren’t interested
in extensive expansion, replacing existing replicas with Tarantool can
save you money, because Tarantool is more efficient per core than MySQL. To read
a testimonial of a company that implemented Tarantool replication on a large scale, see
`the following article <https://dzone.com/articles/next-level-mysql-performance-tarantool-as-a-replic>`_.

If you run into any trouble with regards to the basics of Tarantool, see the
:ref:`Getting started guide <getting_started_db>` or the :ref:`Data model description <box_data_model>`.
A helpful log for troubleshooting during this tutorial is ``replicatord.log`` in ``/var/log``.
You can also have a look at the instance’s log ``example.log`` in ``/var/log/tarantool``.

The tutorial is intended for **CentOS 7.5** and **MySQL 5.7**.
The tutorial requires that ``systemd`` and MySQL are installed.

..  _improving_mysql-setup-mysql:

Setting up MySQL
----------------

In this section, you configure MySQL and create a database.

#.  First, install the necessary packages in CentOS:

    ..  code-block:: console

        $ yum -y install git ncurses-devel cmake gcc-c++ boost boost-devel wget unzip nano bzip2 mysql-devel mysql-lib

#.  Clone the Tarantool-MySQL replication package from GitHub:

    ..  code-block:: console

        $ git clone https://github.com/tarantool/mysql-tarantool-replication.git

#.  Build the replicator with ``cmake``:

    ..  code-block:: console

        $ cd mysql-tarantool-replication
        $ git submodule update --init --recursive
        $ cmake .
        $ make

#.  The replicator will run as a ``systemd`` daemon called ``replicatord``, so, edit
    its ``systemd`` service file (``replicatord.service``) in the
    ``mysql-tarantool-replication`` repository:

    ..  code-block:: console

        $ nano replicatord.service

    The following line should be changed:

    ..  code-block:: bash

        ExecStart=/usr/local/sbin/replicatord -c /usr/local/etc/replicatord.cfg

    To change it, replace the ``.cfg`` extension with ``.yml``:

    ..  code-block:: bash

        ExecStart=/usr/local/sbin/replicatord -c /usr/local/etc/replicatord.yml

#.  Next, copy the files from the ``replicatord`` repository to other necessary locations:

    ..  code-block:: console

        $ cp replicatord /usr/local/sbin/replicatord
        $ cp replicatord.service /etc/systemd/system

#.  Enter MySQL console and create a sample database (depending on
    your existing installation, you may be a user other than root):

    ..  code-block:: sql

        mysql -u root -p
        CREATE DATABASE menagerie;
        QUIT

#.  Get some sample data from MySQL. The data will be pulled into the root
    directory. After that, install it from the terminal.

    ..  code-block:: sql

        cd
        wget http://downloads.mysql.com/docs/menagerie-db.zip
        unzip menagerie-db.zip
        cd menagerie-db
        mysql -u root -p menagerie < cr_pet_tbl.sql
        mysql -u root -p menagerie < load_pet_tbl.sql
        mysql menagerie -u root -p < ins_puff_rec.sql
        mysql menagerie -u root -p < cr_event_tbl.sql

#.  Enter MySQL console and massage the data for use with the
    Tarantool replicator. In this step, you:

    *   add an ID
    *   change a field name to avoid conflict
    *   cut down the number of fields

    With real data, this is the step that involves the most tweaking.

    ..  code-block:: sql

        mysql -u root -p
        USE menagerie;
        ALTER TABLE pet ADD id INT PRIMARY KEY AUTO_INCREMENT FIRST;
        ALTER TABLE pet CHANGE COLUMN 'name' 'name2' VARCHAR(255);
        ALTER TABLE pet DROP sex, DROP birth, DROP death;
        QUIT

#.  The sample data is set up. Edit MySQL
    configuration file to use it with the replicator:

    ..  code-block:: console

        $ cd
        $ nano /etc/my.cnf

    Note that your ``my.cnf`` for MySQL could be in a slightly different location.
    Set:

    ..  code-block:: bash

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

#.  After exiting ``nano``, restart ``mysqld``:

    ..  code-block:: console

        $ systemctl restart mysqld

..  _improving_mysql-setup-tarantool:

Installing and configuring Tarantool
------------------------------------

In this section, you install Tarantool and set up spaces for replication.

#.  Go to the `Download page <https://www.tarantool.io/en/download/os-installation/rhel-centos/>`_ and
    follow the installation instructions.

#.  Install the :ref:`tt CLI <tt-installation>` utility.

#.  Create a new tt environment in the current directory using the :ref:`tt init <tt-init>` command.

#.  In the ``/etc/tarantool/instances.available/mysql`` directory, create the ``tt`` instance configuration files:

    *   ``config.yaml`` -- specifies the following configuration

        ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/mysql/config.yaml
            :language: yaml
            :dedent:

    *   ``instances.yml`` -- specifies instances to run in the current environment

        ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/mysql/instances.yml
            :language: yaml
            :dedent:

    *   ``myapp.lua`` -- contains a Lua script with an application to load

        ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/mysql/myapp.lua
            :language: lua
            :lines: 3-17
            :dedent:

    For details, see the :ref:`Configuration <configuration>` section.

#.  Inside the ``instances.enabled`` directory of the created tt environment, create a symlink (``mysql``)
    to the directory from the previous step:

    ..  code-block:: console

        $ ln -s /etc/tarantool/instances.available/mysql mysql

#.  Next, start up the Lua program with ``tt``, the Tarantool command-line
    utility:

    ..  code-block:: console

        $ tt start mysql

#.  Enter the Tarantool instance:

    ..  code-block:: console

        $ tt connect mysql:instance001

#.  Check that the target spaces were successfully created:

    ..  code-block:: tarantoolsession

        mysql:instance001> box.space._space:select()

    At the bottom, you will see ``mysqldaemon`` and ``mysqldata`` spaces. Then exit with "CTRL+C".

..  _improving_mysql-replicator:

Setting up the replicator
-------------------------

MySQL and Tarantool are now set up. You can proceed to configure the replicator.

#.  Edit the ``replicatord.yml`` file in the main ``tarantool-mysql-replication`` directory:

    ..  code-block:: bash

        nano replicatord.yml

#.  Change the entire file as follows. Don't forget to add your MySQL password and
    set the appropriate user:

    ..  code-block:: bash

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

#.  Copy ``replicatord.yml`` to the location where ``systemd`` looks for it:

    ..  code-block:: console

        $ cp replicatord.yml /usr/local/etc/replicatord.yml

#.  Next, start up the replicator:

    ..  code-block:: console

        $ systemctl start replicatord

#.  Enter the Tarantool instance:

    ..  code-block:: console

        $ tt connect mysql:instance001

#.  Do a select on the ``mysqldata`` space. The replicated content from MySQL looks the following way:

    ..  code-block:: tarantoolsession

        mysql:instance001> box.space.mysqldata:select()
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

..  _improving_mysql-test-replication:

Testing the replication
-----------------------

In this section, you enter a record into MySQL and check that the record is replicated to Tarantool.
To do this:

#.  Exit the Tarantool instance with ``CTRL-D``.

#.  Insert a record into MySQL:

    ..  code-block:: sql

        mysql -u root -p
        USE menagerie;
        INSERT INTO pet(name2, owner, species) VALUES ('Spot', 'Brad', 'dog');
        QUIT

#.  In the terminal, enter the Tarantool instance:

    ..  code-block:: bash

        $ tt connect mysql:instance001

#.  To see the replicated data in Tarantool, run the following command:

    ..  code-block:: tarantoolsession

        mysql:instance001> box.space.mysqldata:select()
