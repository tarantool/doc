.. _box_schema-user_enable:

===============================================================================
box.schema.user.enable()
===============================================================================

.. module:: box.schema

.. function:: box.schema.user.enable(username)

    Activate deactivated user. If :samp:`'{username}'` does not exist, it will be created. If :samp:`'{username}'` is already active, nothing changes.

    :param string username: the name of a user to be activated
 
    :return: ``---``

    **Example:**

        ..  code-block:: lua

            box.schema.user.enable (username)
            
            ---

    **Variation:** instead of :samp:`box.schema.user.enable('{username}')`, say
    :samp:`box.schema.user.grant('{username}','usage,session','universe',nil,` :code:`{if_not_exists=true})`
    (see section :ref:`box.schema.user.grant <box_schema-user_grant>`).