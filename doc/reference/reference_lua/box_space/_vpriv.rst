.. _box_space-vpriv:

===============================================================================
box.space._vpriv
===============================================================================

.. module:: box.space

.. data:: _vpriv

    ``_vpriv`` is a system space that represents a virtual view. The structure
    of its tuples is identical to that of :ref:`_priv <box_space-priv>`, but
    permissions for certain tuples are limited in accordance with user privileges.
    ``_vpriv`` contains only those tuples that are accessible to the current user.
    See :ref:`Access control <authentication>` for details about user privileges.

    If the user has the full set of privileges (like 'admin'), the contents
    of ``_vpriv`` match the contents of ``_priv``. If the user has limited
    access, ``_vpriv`` contains only tuples accessible to this user.

    .. NOTE::

       * ``_vpriv`` is a system view, so it allows only read requests.

       * While the ``_priv`` space requires proper access privileges, any user
         can always read from ``_vpriv``.
