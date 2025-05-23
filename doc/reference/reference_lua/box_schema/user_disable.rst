.. _box_schema-user_disable:

===============================================================================
box.schema.user.disable()
===============================================================================

.. module:: box.schema

.. function:: box.schema.user.disable(username)

    Revokes ``usage`` and ``session`` permissions from the subject user. Equivalent to the following call:

    ..  code-block:: lua
        
        box.schema.user.revoke('{username}','usage,session','universe',nil,{if_not_exists=true})            
    
    .. NOTE::

    ``session`` - (cannot be granted to a role) if is not granted, ``IPROTO_AUTH`` always fails connection to the user, so does ``box.session.su()``
    ``usage`` - (cannot be granted to a role) lets user use their privileges on database objects (e.g. read, write and alter space)
    
    For more information about revoking permissions see section :ref:`box.schema.user.revoke <box_schema-user_revoke>`.

    :param string username: the name of the subject user
 
    :return: (if success) nothing

             (if failure) The error is raised ``- error: User 'username' is not found``