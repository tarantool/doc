.. _box_schema-user_disable:

===============================================================================
box.schema.user.disable()
===============================================================================

.. module:: box.schema

.. function:: box.schema.user.disable(username)

    Initiates the :samp:`box.schema.user.revoke('{username}','usage,session','universe',nil,` :code:`{if_exists=true})`
    (see section :ref:`box.schema.user.revoke <box_schema-user_revoke>`).

    :param string username: the name of a user to be deactivated
 
    :return: (if success) ``---``

             (if failure) ``error: User 'username' is not found``


    **Example:**

        ..  code-block:: lua

            box.schema.user.disable (username)       
            ---
