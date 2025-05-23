.. _box_schema-user_disable:

===============================================================================
box.schema.user.disable()
===============================================================================

.. module:: box.schema

.. function:: box.schema.user.disable(username)

    Revokes ``usage`` and ``session`` permissions from the subject user. Equivalent to the following call:

    ..  code-block:: lua

        box.schema.user.revoke(username, 'usage,session', 'universe', nil, {if_not_exists = true})

    .. NOTE::

       * ``session`` - (cannot be granted to a role) allows the binary protocol layer (iproto) to authenticate the user

       * ``usage`` - (cannot be granted to a role) lets user use their privileges on database objects (such as read, write and alter space)

    For more information about revoking permissions see section :ref:`box.schema.user.revoke <box_schema-user_revoke>`.

    :param string username: the name of the subject user
 
    :return: (if success) nothing

    Possible errors:

    * ``NO_SUCH_USER`` - in case the subject user is not found.