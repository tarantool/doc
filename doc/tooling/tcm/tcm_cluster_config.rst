..  _tcm_configuring_clusters:

Configuring clusters
====================

..  include:: index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

|tcm_full_name| features a built-in text editor for Tarantool EE cluster configurations.

When you :ref:`connect a cluster <tcm_connect_clusters>` to |tcm|, it gains access
to the cluster's centralized configuration storage: an etcd or a Tarantool cluster.
|tcm| has both read and write access to the cluster configuration. This enables
the configuration editor to work in two ways:

*   If a configuration already exists, the editor shows its current state.
*   When you change the configuration in the editor and apply changes, they
    are sent to the configuration storage.

To learn how to write Tarantool cluster configurations, see :ref:`configuration`.

..  _tcm_configuring_clusters_manage:

Managing a cluster's configuration
----------------------------------

The configuration editor is available on the **Cluster** > **Configuration** page.

To start managing a cluster's configuration, select this cluster in the **Cluster**
drop-down and go to the **Configuration** page.

A cluster configuration in |tcm| can consist of one or multiple YAML files.
When there are multiple files, they are all considered parts of a single cluster
configuration. You can use this for structuring big cluster configurations.
All files that form the configuration of a cluster are listed on the left side
of the **Cluster configuration** page.

To add a cluster configuration file, click the plus icon (**+**) below the page title.

To open a configuration file in the editor, click its name in the file list.

To delete a cluster configuration file, click the **Delete** button beside the filename.

To download a cluster configuration file, click the **Download** button beside the filename.

.. warning::

    All configuration changes are discarded when you leave the **Cluster configuration** page.
    :ref:`Save <tcm_configuring_clusters_save>` the configuration if you want to continue
    editing it later or :ref:`apply <tcm_configuring_clusters_apply>` it
    to start using it on the cluster.

..  _tcm_configuring_clusters_save:

Saving a configuration draft
----------------------------

|tcm| can store configurations drafts. If you want to leave an unfinished configuration
and return to it later, save it in |tcm|. Saving applies to whole cluster configurations:
it records the edits of all files, file additions, and file deletions.

To save a cluster configuration draft after editing, click **Save** in the **Cluster configuration** page.

All unsaved changes are discarded when you leave the **Cluster configuration** page.

If you have a saved configuration draft, you can reset the changes for each of its
files individually. A reset returns the file into the state that is currently used
by a cluster (that is, saved in the configuration storage). If you reset a newly
added file, it is deleted.

To reset a saved configuration file, click the **Reset** button beside the filename.


..  _tcm_configuring_clusters_apply:

Applying a configuration
------------------------

When you finish editing a configuration and it's ready to use, apply the updated
configuration to the cluster. To apply a cluster configuration, click **Apply**
on the **Cluster configuration** page. This sends the new configuration to the cluster
configuration storage, and it comes into effect upon the cluster configuration reload.


