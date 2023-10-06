.. _enterprise-admin:

===============================================================================
Cluster administrator's guide
===============================================================================

This guide focuses on Enterprise-specific administration features available
on top of the open-source Tarantool version with Tarantool Cartridge framework:

* :ref:`space explorer <space_explorer>`
* :ref:`upgrade of environment-independent applications in production <enterprise-production-upgrade>`

Otherwise, please consult the open-source Tarantool documentation for:

* basic information on
  :doc:`deploying and managing a Tarantool cluster </book/cartridge/cartridge_admin>`
* more information on
  :doc:`managing Tarantool instances </book/admin/index>`

.. _space_explorer:

-------------------------------------------------------------------------------
Exploring spaces
-------------------------------------------------------------------------------

The web interface lets you connect (in the browser) to any instance in the cluster
and see what spaces it stores (if any) and their contents.

To explore spaces:

#. Open the **Space Explorer** tab in the menu on the left:

   .. image:: images/space_explr_tab.png
      :align: center
      :scale: 80%

#. Click **connect** next to an instance that stores data. The basic sanity-check
   (``test.py``) of the example application puts sample data to one replica
   set (shard), so its master and replica store the data in their spaces:

   .. image:: images/spaces_with_data.png
      :align: center
      :scale: 80%

   When connected to a instance, the space explorer shows a table with basic
   information on its spaces. For more information, see the
   :doc:`box.space reference </reference/reference_lua/box_space>`.

   To see hidden spaces, tick the corresponding checkbox:

   .. image:: images/hidden_spaces.png
      :align: center
      :scale: 80%

#. Click the space's name to see its format and contents:

   .. image:: images/space_contents.png
      :align: center
      :scale: 70%

   To search the data, select an index and, optionally, its iteration type from
   the drop-down lists, and enter the index value:

   .. image:: images/space_search.png
      :align: center
      :scale: 80%

.. _enterprise-production-upgrade:

-------------------------------------------------------------------------------
Upgrading in production
-------------------------------------------------------------------------------

To upgrade either a single instance or a cluster, you need a new version of the
packaged (archived) application.

A single instance upgrade is simple:

#. Upload the package (archive) to the server.
#. Stop the current instance.
#. Deploy the new one as described in :ref:`deploying packaged applications <enterprise-packaged-app>`
   (or :ref:`archived ones <enterprise-archived-app>`).

.. _enterprise-cluster-upgrade:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Cluster upgrade
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To upgrade a cluster, choose one of the following scenarios:

* **Cluster shutdown**. Recommended for backward-incompatible updates, requires
  downtime.

* **Instance by instance**. Recommended for backward-compatible updates, does
  not require downtime.

To upgrade the cluster, do the following:

#. Schedule a downtime or plan for the instance-by-instance upgrade.

#. Upload a new application package (archive) to all servers.

Next, execute the chosen scenario:

* **Cluster shutdown**:

  #. Stop all instances on all servers.
  #. Deploy the new package (archive) on every server.

* **Instance by instance**. Do the following in every replica set in succession:

  #. Stop a replica on any server.
  #. Deploy the new package (archive) in place of the old replica.
  #. Promote the new replica to a master (see
     :ref:`Switching the replica set's master <cartridge-switch-master>`
     section in the Tarantool manual).
  #. Redeploy the old master and the rest of the instances in the replica set.
  #. Be prepared to resolve possible logic conflicts.
