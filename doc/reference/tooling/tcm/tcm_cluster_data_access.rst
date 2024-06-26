..  _tcm_cluster_data_access:

Accessing cluster data
======================

..  include:: index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

|tcm_full_name| provides access to data stored in connected clusters through its
web interface. You can view, add, edit, and delete tuples from spaces.

.. note::

    A |TCM| user's access to specific clusters and spaces is determined by their
    :ref:`cluster permissions <tcm_access_control_permissions>` and :ref:`access control list <tcm_access_control_acl>`.

Data access is implemented in |tcm| on a per-instance basis: you can access
data stored on one cluster instance at a time. For sharded clusters that use the
`CRUD <https://github.com/tarantool/crud>`__ module,
it's also possible to access data throughout the whole cluster.

..  _tcm_cluster_data_access_instance:

Instance data
-------------

There are the following ways to access data stored on a cluster instance from |tcm|:

-   **Instance explorer** displays the instance's spaces as tables in the web interface
-   **SQL terminal** allows executing SQL statements on the instance
-   **Tarantool and tt consoles** allow accessing the data using the Lua API

.. important::

    Data modification is possible only on instances in the read-write mode (replica set leaders).
    Changes are applied to read-only replicas in accordance with the cluster topology.

..  _tcm_cluster_data_access_instance_explorer:

Instance explorer
~~~~~~~~~~~~~~~~~

The instance explorer provides access to all spaces that exist on the instances
in the web interface. This includes both system and user spaces.

To open the instance explorer:

#.  Go to **Stateboard**.
#.  Click the instance row in the instances list or its graph vertex in the graph view.
#.  Click **Explorer** in the **Actions menu** of the instance details page.

To view tuples of a space, click its row in the spaces list.

To add a new tuple, click **+** on the space page and provide tuple field values
in the Lua format, for example, ``[ 1, 1000, true, "test"]``.

To edit a tuple, click it in the table and then click **Edit**.

To delete a tuple, select it in the table and click **Delete** (the trash bin button).

In the development mode, you can also create, edit, truncate, and delete spaces
in the instance explorer. To create a space, click **Add** and follow the wizard steps.
To edit, truncate, or remove a space, click the corresponding button in the **Actions**
menu of the space row in the table.

..  _tcm_cluster_data_access_instance_sql:

SQL terminal
~~~~~~~~~~~~

|tcm| features an SQL terminal that you can use to access stored data. It is located
on the **SQL** tab of the instance details page. In the SQL terminal, you can execute
any :ref:`supported SQL expressions <sql_statements_and_clauses>` on the selected instance.

For ``select`` SQL queries, you can also download the query result set in the CSV format.

To learn more about using SQL in Tarantool, see the :ref:`sql_tutorial`.

..  _tcm_cluster_data_access_instance_lua:

Lua API: Tarantool and tt consoles
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

|tcm| provides interactive access to instances' consoles on the **Terminal** tab
of the instance details page. You can choose between the :ref:`tt console <tt-interactive-console>`
(**TT Connect** tab) and :ref:`Tarantool interactive console <interactive_console>` (**Direct** tab).

In these consoles, you can access the stored data using the Tarantool :ref:`Lua API <built_in_modules>`.

..  _tcm_cluster_data_access_crud:

Sharded cluster data
--------------------

For sharded clusters that use the `CRUD <https://github.com/tarantool/crud>`__ module,
it's possible to access stored data throughout the cluster on the **Cluster** > **Tuples** page.
This page displays only user spaces.

To view all tuples of a space in a sharded cluster, click the space row in the list.

To add a new tuple, click **+** on the space page and provide tuple field values
in the Lua format, for example ``[ 1, 1000, true, "test"]``. When you add a tuple
in a sharded cluster, it is distributed to a replica set based on the sharding key
(the ``bucket_id`` field) value.

To edit a tuple, click it in the table and then click **Edit**.

To delete a tuple, select it in the table and click **Delete** (the trash bin button).


..  _tcm_cluster_data_access_crud_spaces:

Creating spaces in sharded clusters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To create a space in a sharded cluster, create it on all read-write cluster instances
on their :ref:`Instance explorer <tcm_cluster_data_access_instance_explorer>` pages.

.. important::

    Sharded spaces must include the ``bucket_id`` field of the ``unsigned`` type
    and a non-unique index by this field with the same name.

To edit, truncate, or delete spaces in a sharded cluster, perform the corresponding
action on all read-write cluster instances.
