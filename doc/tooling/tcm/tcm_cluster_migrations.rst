..  _tcm_cluster_migrations:

Performing migrations
=====================

..  include:: index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

|tcm_full_name| provides a web interface for managing and performing migrations
in connected clusters. To learn more about migrations in Tarantool, see :ref:`migrations`.

Migrations are named Lua files with code that alters the cluster data schema, for example,
creates a space, changes it format, or adds indexes. In |tcm|, there is a dedicated
page on which you can organize migrations, edit their code, and apply them to the cluster.

..  _tcm_cluster_migrations_manage:

Managing migrations
-------------------

The tools for managing migrations from |tcm| are located on the **Cluster** > **Migrations** page.

To create a migration:

#.  Click **Add** (the **+** icon) on the **Migrations** page.
#.  Enter the migration name.

    .. important::

        When naming migrations, remember that they are applied in the lexicographical order.
        Use ordered numbers as filename prefixes to define the migrations order.
        For example, ``001_create_table``, ``002_add_column``, ``003_create_index``.

#.  Write the migration code in Lua in the editor window. Use the :ref:`box module reference <box-module>`
    to learn how to work with Tarantool data schema.

To save the migration without applying it to the cluster, click **Save**.
This saves the currently selected migration.

To apply all _saved_ migrations to the cluster at once, click **Apply**.

.. important::

    Applying all saved migrations **at once in the lexicographical** order is the
    only way to apply migrations in |tcm|. There is no way to select a single  or
    several migrations to apply.
    The migrations that are already applied are skipped. To learn how to find out
    a migration status, see :ref:`tcm_cluster_migrations_check`.


..  _tcm_cluster_migrations_check:

Checking migrations status
--------------------------

To check the migration results on the cluster, use the **Migrations** widget on the
:ref:`cluster stateboard <tcm_ui_cluster_stateboard>`. It reflects the general result
of the last applied migration set:

-   If all saved migration are applied successfully,
    the widget is green.
-   If any migration from this set fails on certain instances, the widget color changes to yellow.
-   If there are saved migrations that are not applied yet, the widget becomes gray.

Hovering a cursor over the widget shows the number of instances on which the currently
saved migration set is already applied.

You can also check the status of each particular migration on the **Migrations** page.
The migrations that are successfully applied are marked with green check marks.
Failed migrations are marked with exclamation mark icons (**!**). Hover the cursor over
the icon to see the information about the error.