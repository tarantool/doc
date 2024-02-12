.. _box_schema-user_info:

===============================================================================
box.schema.user.info()
===============================================================================

.. module:: box.schema

.. function:: box.schema.user.info([username])

    Return a description of a user's :ref:`privileges <authentication-owners_privileges>`.

    :param string username: the name of the user.
                            This is optional; if it is not
                            supplied, then the information
                            will be for the user who is
                            currently logged in.

    See also: :ref:`access_control_user_info`.
