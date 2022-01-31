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
    * the type of object: 'space', 'index', 'function', 'sequence', 'user', 'role', or 'universe',
    * the numeric id of the object,
    * the type of operation: "read" = 1, "write" = 2, "execute" = 4,
      "create" = 32, "drop" = 64, "alter" = 128, or
      a combination such as "read,write,execute".

    See :ref:`Access control <authentication>` for details about user privileges.
         
    The :ref:`system space view <box_space-sysviews>` for ``_priv`` is ``_vpriv``.

