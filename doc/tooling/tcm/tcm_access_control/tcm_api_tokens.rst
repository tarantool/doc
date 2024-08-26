
.. _tcm_access_control_api_tokens:

API tokens
==========

..  include:: ../index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

|tcm_full_name| uses the Bearer HTTP authentication scheme with *API tokens* to authenticate
external applications' requests to |tcm|. For example, these can be Prometheus
jobs that retrieve metrics of connected Tarantool clusters.

The API tokens functionality is disabled by default. To enable it, set the
:ref:`feature.api-token <tcm_configuration_reference_feature_api-token>` configuration option to ``true``.

.. code-block:: yaml

    feature:
      api-token: true

Each |tcm| API token belongs to the user that created it and has the same :ref:`access permissions <tcm_access_control_permissions>`.
Thus, if a user has a permission to view a cluster's metrics in |tcm|, this user's
API tokens can be used to read this cluster's metrics with Prometheus.

API tokens have expiration dates that are set during the token creation and cannot
be changed.

.. _tcm_access_control_api_tokens_manage:

Managing API tokens
-------------------

.. note::

    Each user, including **Default Admin** and other administrators, can create only
    their own tokens. There is no way to create a token for another user.

To create a |tcm| API token:

#. Open the user settings by clicking the user's name in the top-right corner.
#. Go to the **API tokens** tab and click **Add**.
#. Specify the token expiration date and an optional description and click **Add**.

The created token is shown in a dialog.

.. important::

    An API token is shown only once after its creation. There is no way to view
    it again after you close the dialog. Make sure to copy the token in a safe place.

To delete an API token, click **Delete** in the actions menu of the corresponding
**API tokens** table row.

Administrators can also view information about users' API tokens and delete them
on the **Secrets** page. To open a user's secrets, click **Secrets** in the **Actions**
menu of the corresponding **Users** table row.