.. _box_space-vspace:

===============================================================================
box.space._vspace
===============================================================================

.. module:: box.space

.. data:: _vspace

    ``_vspace`` is a system space that represents a virtual view. The structure
    of its tuples is identical to that of :ref:`_space <box_space-space>`, but
    permissions for certain tuples are limited in accordance with user privileges.
    ``_vspace`` contains only those tuples that are accessible to the current user.
    See :ref:`Access control <authentication>` for details about user privileges.

    If the user has the full set of privileges (like 'admin'), the contents
    of ``_vspace`` match the contents of ``_space``. If the user has limited
    access, ``_vspace`` contains only tuples accessible to this user.

    .. NOTE::

       * ``_vspace`` is a system view, so it allows only read requests.

       * While the ``_space`` space requires proper access privileges, any user
         can always read from ``_vspace``.
