..  _tcm_cluster_users:

Cluster users and roles
=======================


Managing cluster users and roles
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO: check the location

.. important::

    This creates Tarantool users and roles (link)on a connected cluster / or replicaset?
    To learn about TCM users, refer to :ref:`tcm_access_control`.

You can manage Tarantool users and roles on a connected cluster from the Users tab of
the instance page.

only on read-write (leader) instances

To create a user:

#.  click Add in the Users section.
#.  Enter a username and a password in the dialog and click Add.
#.  Click the lock icon against the username in the table to open user privileges dialog.
#.  Add privileges


.. note

    a user on whose behalf tcm connect to the cluster must have the privileges to
    grant privileges to users


To create a role:

