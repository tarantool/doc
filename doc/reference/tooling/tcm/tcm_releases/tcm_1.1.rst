.. _tcm_releases_1_1:

Tarantool Cluster Manager 1.1
=============================

Release date: May 16, 2024

Releases in series: 1.1.0

|tcm_full_name| 1.1 introduces a number of new features that extend and improve its
cluster management capabilities. Below is an overview of its key updates.

.. _tcm_releases_1_1_data_access:

Data access
-----------

An important update of |tcm| 1.1.0 is a set of features that enable access to clusters'
stored data.

The instance *space explorer* shows all spaces that exist on an instance, including
system spaces. On its pages, you can view and edit the stored data. To open the instance explorer,
find the instance on the cluster stateboard and click its name to open its details page.
Then click **Explorer** in the **Actions** menu in the top right corner.

In the development mode, the instance explorer also includes the *schema editor*.
It allows you to add new and edit existing spaces.

For clusters that use the `CRUD <https://github.com/tarantool/crud>`__ module,
there is also the *CRUD explorer* that enables access to data in user spaces across
the entire cluster on one page. The CRUD explorer is located on the **Tuples** page.

.. _tcm_releases_1_1_acl:

Access control list
-------------------

|tcm|'s *access control list* (*ACL*) enables control over user access to particular spaces
and stored functions in the web interface.

For each user that has access to a cluster, you can enable the use of ACL on this cluster.
This restricts this user's access to the cluster's spaces and functions unless they
are explicitly specified in the ACL. The ACL must contain an entry for each such
space and function.

Users with ACL off have access to all spaces and functions on clusters according
to their cluster permissions.

The tools for managing ACL are located on the new **ACL** page.

.. _tcm_releases_1_1_api_tokens:

API tokens
----------

|tcm| 1.1.0 supports token authentication of external requests. Users can generate
API tokens in their user settings dialog. An API token has the same permissions
as its creator.

.. _tcm_releases_1_1_stateboard:

Stateboard improvements
-----------------------

|tcm| 1.1.0 extends the functionality of the cluster stateboard to improve the
cluster management experience. Here are the key updates of the stateboard:

-   More flexible instance grouping.
-   Stateful failover and switchover controls.
-   Runtime issues on the stateboard.

.. _tcm_releases_1_1_instance:

Instance interaction
--------------------

The instance management dialog has been extended with new functions:

-   A new terminal that uses the ``tt`` console instead of the Tarantool interactive
    console.
-   SQL query execution terminal.
-   Stored functions editor.
-   Slab visualization.

.. _tcm_releases_1_1_metrics:

Cluster metrics
---------------

Starting from version 1.1.0, |tcm| displays metrics of connected clusters.
You can view metrics in |tcm| one by one, visualizing them as charts or tables.
The cluster metrics are shown on the new **Cluster metrics** page.

For more complex monitoring, you can use dedicated solutions, for example, Prometheus.
It can integrate with |tcm| using the :ref:`API tokens <tcm_releases_1_1_api_tokens>`.

.. _tcm_releases_1_1_config:

Configuration validation
------------------------

The cluster configuration editor now validates the configuration semantically.
Previously, |tcm| was able to highlight the syntax errors in configurations, for example,
incorrect spelling of option names or hierarchy. In |tcm| 1.1.0, the editor
checks and highlights possible semantic issues, such as:

-   Users without passwords.
-   Users with the ``super`` role.
-   Absence of leader instances in replica sets.

.. _tcm_releases_1_1_tutorial:

Onboarding tutorial
-------------------

|tcm| 1.1.0 includes an interactive tutorial that takes new users though its
main features and pages. It opens automatically after the first start.
