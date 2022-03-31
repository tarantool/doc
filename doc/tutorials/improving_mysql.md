(improving-mysql)=

# Improving MySQL with Tarantool

Replicating MySQL is one of the Tarantool’s killer functions.
It allows you to keep your existing MySQL database while at the same time
accelerating it and scaling it out horizontally. Even if you aren’t interested
in extensive expansion, simply replacing existing replicas with Tarantool can
save you money, because Tarantool is more efficient per core than MySQL. To read
a testimonial of a company that implemented Tarantool replication on a large scale,
please see
[here](https://dzone.com/articles/next-level-mysql-performance-tarantool-as-a-replic).

Notes:

- if you run into any trouble with regards to the basics of Tarantool, you may
  wish to consult the {ref}`Getting started guide <getting_started_db>` or
  the {ref}`Data model description <box_data_model>`.
- these instructions are for **CentOS 7.5** and **MySQL 5.7**. They also assume
  that you have systemd installed and are working with an existing MySQL installation.
- a helpful log for troubleshooting during this tutorial is `replicatord.log`
  in `/var/log`. You can also have a look at the instance’s log `example.log`
  in `/var/log/tarantool`.

So let’s proceed.

01. First we’ll install the necessary packages in CentOS:

    ```bash
    yum -y install git ncurses-devel cmake gcc-c++ boost boost-devel wget unzip nano bzip2 mysql-devel mysql-lib
    ```

02. Next we’ll clone the Tarantool-MySQL replication package from GitHub:

    ```bash
    git clone https://github.com/tarantool/mysql-tarantool-replication.git
    ```

03. Now we can build the replicator with cmake:

    ```bash
    cd mysql-tarantool-replication
    git submodule update --init --recursive
    cmake .
    make
    ```

04. Our replicator will run as a systemd daemon called replicatord, so let’s edit
    its systemd service file, `replicatord.service`, in the
    mysql-tarantool-replication repo.

    ```bash
    nano replicatord.service
    ```

    Change the following line:

    ```bash
    ExecStart=/usr/local/sbin/replicatord -c /usr/local/etc/replicatord.cfg
    ```

    Replace the `.cfg` extension with `.yml`:

    ```bash
    ExecStart=/usr/local/sbin/replicatord -c /usr/local/etc/replicatord.yml
    ```

05. Next let’s copy some files from our replicatord repo to other necessary locations:

    ```bash
    cp replicatord /usr/local/sbin/replicatord
    cp replicatord.service /etc/systemd/system
    ```

06. Now let’s enter the MySQL console and create a sample database (depending on
    your existing installation, you may of course be a user other than root):

    ```sql
    mysql -u root -p
    CREATE DATABASE menagerie;
    QUIT
    ```

07. Next we’ll get some sample data from MySQL, which we’ll pull into our root
    directory, then install from the terminal:

    ```sql
    cd
    wget http://downloads.mysql.com/docs/menagerie-db.zip
    unzip menagerie-db.zip
    cd menagerie-db
    mysql -u root -p menagerie < cr_pet_tbl.sql
    mysql -u root -p menagerie < load_pet_tbl.sql
    mysql menagerie -u root -p < ins_puff_rec.sql
    mysql menagerie -u root -p < cr_event_tbl.sql
    ```

08. Let’s enter the MySQL console now and massage the data for use with the
    Tarantool replicator (we are adding an ID, changing a field name to avoid
    conflict, and cutting down the number of fields; note that with real data,
    this is the step that will involve the most tweaking):

    ```sql
    mysql -u root -p
    USE menagerie;
    ALTER TABLE pet ADD id INT PRIMARY KEY AUTO_INCREMENT FIRST;
    ALTER TABLE pet CHANGE COLUMN 'name' 'name2' VARCHAR(255);
    ALTER TABLE pet DROP sex, DROP birth, DROP death;
    QUIT
    ```

09. Now that we have the sample data set up, we’ll need to edit MySQL’s
    configuration file for use with the replicator.

    ```bash
    cd
    nano /etc/my.cnf
    ```

    Note that your `my.cnf` for MySQL could be in a slightly different location.
    Set:

    ```bash
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
    ```

10. After exiting nano, we’ll restart mysqld:

    ```bash
    systemctl restart mysqld
    ```

11. Next, let’s install Tarantool and set up spaces for replication.
    Go to the [Download page](https://www.tarantool.io/en/download/os-installation/rhel-centos/) and
    follow the instructions there to install Tarantool.

12. Now we will write a standard Tarantool program by editing the Lua example,
    which comes with Tarantool:

    ```bash
    cd
    nano /etc/tarantool/instances.available/example.lua
    ```

13. Replace the entire contents of the file with the following:

    ```lua
    box.cfg {
        listen = 3301;
        memtx_memory = 128 * 1024 * 1024; -- 128Mb
        memtx_min_tuple_size = 16;
        memtx_max_tuple_size = 128 * 1024 * 1024; -- 128Mb
        vinyl_memory = 128 * 1024 * 1024; -- 128Mb
        vinyl_cache = 128 * 1024 * 1024; -- 128Mb
        vinyl_max_tuple_size = 128 * 1024 * 1024; -- 128Mb
        vinyl_write_threads = 2;
        wal_mode = "none";
        wal_max_size = 256 * 1024 * 1024;
        checkpoint_interval = 60 * 60; -- one hour
        checkpoint_count = 6;
        force_recovery = true;

         -- 1 – SYSERROR
         -- 2 – ERROR
         -- 3 – CRITICAL
         -- 4 – WARNING
         -- 5 – INFO
         -- 6 – VERBOSE
         -- 7 – DEBUG
         log_level = 7;
         too_long_threshold = 0.5;
     }

    box.schema.user.grant('guest','read,write,execute','universe')

    local function bootstrap()

        if not box.space.mysqldaemon then
            s = box.schema.space.create('mysqldaemon')
            s:create_index('primary',
            {type = 'tree', parts = {1, 'unsigned'}, if_not_exists = true})
        end

        if not box.space.mysqldata then
            t = box.schema.space.create('mysqldata')
            t:create_index('primary',
            {type = 'tree', parts = {1, 'unsigned'}, if_not_exists = true})
        end

    end

    bootstrap()
    ```

    To understand more of what’s happening here, it would be best to have a look
    back at the earlier
    [articles](https://dzone.com/articles/tarantool-101-10-steps-for-absolute-beginners-the)
    in the Tarantool 101 series or use the {ref}`getting-started <getting_started_db>` guide.

14. Now we need to create a symlink from `instances.available` to a directory named
    `instances.enabled` (similar to NGINX). So in `/etc/tarantool` run the
    following:

    ```bash
    mkdir instances.enabled
    ln -s /instances.available/example.lua instances.enabled
    ```

15. Next we can start up our Lua program with `tarantoolctl`, a wrapper for systemd:

    ```bash
    tarantoolctl start example.lua
    ```

16. Now let’s enter our Tarantool instance, where we can check that our target
    spaces were successfully created:

    ```bash
    tarantoolctl enter example.lua
    ```

    ```tarantoolsession
    tarantool> box.space._space:select()
    ```

    At the bottom you will see "mysqldaemon" and "mysqldata" spaces. Then exit with "CTRL+C".

17. Now that we have MySQL and Tarantool set up, we can proceed to configure
    our replicator. First let’s work with `replicatord.yml` in the main
    `tarantool-mysql-replication` directory.

    ```bash
    nano replicatord.yml
    ```

    Change the entire file as follows, making sure to add your MySQL password and
    to set the appropriate user:

    ```bash
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
    ```

18. Now we need to copy replicatord.yml to the location where systemd looks for it:

    ```bash
    cp replicatord.yml /usr/local/etc/replicatord.yml
    ```

19. Next we can start up the replicator:

    ```bash
    systemctl start replicatord
    ```

    Now we can enter our Tarantool instance and do a select on the “mysqldata”
    space. We will see the replicated content from MySQL:

    ```bash
    tarantoolctl enter example.lua
    ```

    ```tarantoolsession
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
    ```

20. Finally let’s enter a record into MySQL and then go back to Tarantool to make
    sure it’s replicated. So first we’ll exit our Tarantool instance with
    `CTRL-C`, and then say:

    ```sql
    mysql -u root -p
    USE menagerie;
    INSERT INTO pet(name2, owner, species) VALUES ('Spot', 'Brad', 'dog');
    QUIT
    ```

    Once back in the terminal enter:

    ```bash
    tarantoolctl enter example.lua
    ```

    ```tarantoolsession
    tarantool> box.space.mysqldata:select()
    ```

    You should see the replicated data in Tarantool!
