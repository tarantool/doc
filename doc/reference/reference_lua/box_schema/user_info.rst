.. _box_schema-user_info:

===============================================================================
box.schema.user.info()
===============================================================================

.. module:: box.schema

.. function:: box.schema.user.info([user-name])

    Return a description of a user's :ref:`privileges <authentication-owners_privileges>`.

    :param string user-name: the name of the user.
                             This is optional; if it is not
                             supplied, then the information
                             will be for the user who is
                             currently logged in.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> box.schema.user.info('admin')
        ---
        - - - read,write,execute,session,usage,create,drop,alter,reference,trigger,insert,update,delete
            - universe
            -
        ...
