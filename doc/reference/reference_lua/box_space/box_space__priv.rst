.. _box_space-priv:

===============================================================================
box.space._priv
===============================================================================

.. module:: box.space

.. data:: _priv

    ``_priv`` is a system space where
    :ref:`privileges <authentication-owners_privileges>` are stored.

    Tuples in this space contain the following fields:

    * the numeric id of the user who gave the privilege ("grantor_id"),
    * the numeric id of the user who received the privilege ("grantee_id"),
    * the type of object: 'space', 'function', 'sequence' or 'universe',
    * the numeric id of the object,
    * the type of operation: "read" = 1, "write" = 2, "execute" = 4,
      "create" = 32, "drop" = 64, "alter" = 128, or
      a combination such as "read,write,execute".

    You can:

    * Grant a privilege with :ref:`box.schema.user.grant() <box_schema-user_grant>`.
    * Revoke a privilege with :ref:`box.schema.user.revoke() <box_schema-user_revoke>`.

    .. NOTE::

       * Generally, privileges are granted or revoked by the owner of the object
         (the user who created it), or by the 'admin' user.

       * Before dropping any objects or users, make sure that all their associated
         privileges have been revoked.

       * Only the :ref:`'admin' user <authentication-owners_privileges>`
         can grant privileges for the 'universe'.

       * Only the 'admin' user or the creator of a space can drop, alter, or
         truncate the space.

       * Only the 'admin' user or the creator of a user can change a different
         user’s password.
