..  _tcm_cluster_migrations:

Performing migrations in TCM
============================

..  include:: index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

|tcm_full_name| provides a web interface for managing and performing migrations
in connected clusters. To learn more about migrations in Tarantool, see :ref:`_migrations`.

In |tcm|, migrations are named Lua files with code that alters the cluster data
schema.

..  _tcm_cluster_migrations_manage:

Managing migrations
-------------------

The tools for managing migrations from |tcm| are located on the **Cluster** > **Migrations** page.

To create a migration:

#.  Click **Add** (the **+** icon) on the **Migrations** page.
#.  Enter the migration name.

    .. important::

        When naming migrations, remember that they are applied in the lexicographical order.

#.  Write the migration code in Lua in the editor window.

To save the migration without sending it to the cluster instances, click **Save**.

To apply all saved migrations at once, click **Apply**.

.. important::

    Applying all saved migrations at once is the only way supported in |tcm|.
    If a migration has already been applied, it is skipped. To learn to find out
    the migration status, see :ref:`tcm_cluster_migrations_check`.


..  _tcm_cluster_migrations_check:

Checking migrations status
--------------------------

To check how the loaded migrations are applied to the cluster, use the **Migrations**
widget on the :ref:`cluster stateboard <tcm_ui_cluster_stateboard>`. It reflects the
general result of the last applied migration set. If any migration from this set fails
on certain instances, the widget color changes to yellow. If the set of migrations
has changes that are not applied yet, the widget becomes grey.


Hovering a cursor over the widget shows
the number of instances on which the migrations have failed.

You can also check the status of each particular migration on the **Migrations** page.
The migrations that are successfully applied are marked with green check marks.
Failed migrations are marked with red icons. Hover the cursor over the icon to see
the information about the error.