
.. _tcm_access_control_acl:

Access control list
-------------------

|tcm|'s *access control list* (*ACL*) determines user access to particular data
and functions stored in clusters. You can use it to allow or deny access to specific
stored objects one by one.

Each ACL entry specifies privileges that a |tcm| user has on a particular
space or a function. There are three access privileges that can be granted in the ACL:
read, write, and execute (for stored functions only). The privileges work as follows:

-   Spaces:

    - ``Read``: the user sees the space and its tuples on the **Tuples** and **Explorer** pages
    - ``Write``: the user can add new and edit existing tuples of the space

-   Functions:

    - ``Read``: the user sees the function on the **Functions** tab of the instance details page.
    - ``Write``: the user can edit or delete the function
    - ``Execute``: the user can call the function

.. important::

    User access to space data and stored functions is primarily defined by the
    :ref:`cluster permissions <tcm_access_control_permissions_cluster>` ``cluster.space.data.*`` and ``cluster.func.*``.
    ACL only increases the access control granularity to particular objects.
    Make sure that users have these permissions before enabling ACL for them.

.. _tcm_access_control_acl_enable:

Enabling ACL for a user
~~~~~~~~~~~~~~~~~~~~~~~

To granularly manage a user's access to particular objects in a cluster, enable
the use of ACL in the user profile:

#.  Go to **Users** and click **Edit** in the **Actions** menu of the corresponding table row.

#.  In the user's **Clusters** list, add a cluster on which you want to use ACL
    or click the pencil icon if the cluster is already on the list.

#.  Select the **Use Access Control List (ACL)** checkbox and save changes.

#.  Repeat two previous steps for each cluster on which you want to use ACL for this user.

#.  Click **Update** to save the user account.

If the user doesn't exist yet, you can do the same when creating it.

.. important::

    When ACL use is enabled for a user, this user loses access to all spaces and
    functions of the selected cluster except the ones explicitly specified in the ACL.

.. _tcm_access_control_acl_manage:

Managing ACL
~~~~~~~~~~~~

The tools for managing ACL are located on the **ACL** page.

To add an ACL entry:

#.  Click **Add**.
#.  Select a user to which you want to grant access.
#.  Select a cluster that stores the target object: a space or a function.
#.  Select the target object type and enter its name.
#.  Select the privileges you want to grant.

To delete an ACL entry, click **Delete** in the **Actions** menu of the corresponding table row.
