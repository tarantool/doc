.. _box_schema-user_enable:

===============================================================================
box.schema.user.enable()
===============================================================================

.. module:: box.schema

.. function:: box.schema.user.enable(username)

    Initiates the :samp:`box.schema.user.grant('{username}','usage,session','universe',nil,` :code:`{if_not_exists=true})` method
    (see section :ref:`box.schema.user.grant <box_schema-user_grant>`).

    :param string username: the name of the subject user
 
    :return: (if success) ``---``

             (if failure) ``error: User 'username' is not found``

    **Example:**

        ..  code-block:: lua

            box.schema.user.enable (username)            
            ---
