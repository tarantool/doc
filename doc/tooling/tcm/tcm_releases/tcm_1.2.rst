.. _tcm_releases_1_2:

Tarantool Cluster Manager 1.2
=============================

Release date: July 30, 2024

Latest release in series: 1.2.1

|tcm_full_name| 1.2 introduces new features that extend its
cluster management capabilities. Below is an overview of its key updates.

.. _tcm_releases_1_2_tarantool_users:

Managing Tarantool users
------------------------

|tcm| 1.2 introduces the ability to manage Tarantool users on connected clusters.
Previously, you could manage Tarantool users only though the Lua API (:ref:`box.schema <box_schema>` submodule)
or cluster :ref:`configuration <configuration_credentials_managing_users_roles>`.
Now you can create, edit, and delete users and roles on each instance of a Tarantool
cluster through the |tcm| web interface.

The tools for managing Tarantool users on a cluster instance are located on the
**Users** tab of the instance page.

Learn more about managing Tarantool users from |tcm| in :ref:`tcm_cluster_users`.

.. _tcm_releases_1_2_migrations:

Migrations
----------

Since version 1.2.0, |tcm| includes a page for editing and executing :ref:`migrations <migrations>`
on connected clusters. The new page **Migrations** in the **Cluster** page group
provides a text editor where you can write migration scripts in Lua and apply them
to the cluster.

Learn more about migrations in Tarantool :ref:`migrations`.

.. _tcm_releases_1_2_cluster_security:

Cluster security settings
-------------------------

Since version 1.2.2, |tcm| provides a web interface for managing cluster security settings
on the **Security** page in the **Cluster** group.

Learn more about managing cluster security from |tcm| in :ref:`tcm_cluster_security`.

.. _tcm_releases_1_2_tcf:

TCF integration
---------------

Since version 1.2.2, |tcm| includes a page for managing clusters that
run within `Tarantool Clusters Federation <https://www.tarantool.io/en/clustersfederation/>`__.

Learn more about working with TCF in |tcm| in :ref:`tcm_cluster_tcf`.
