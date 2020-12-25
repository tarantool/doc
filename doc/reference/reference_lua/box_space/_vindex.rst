.. _box_space-vindex:

===============================================================================
box.space._vindex
===============================================================================

.. module:: box.space

.. data:: _vindex

    ``_vindex`` is a system space that represents a virtual view. The structure
    of its tuples is identical to that of :ref:`_index <box_space-index>`, but
    permissions for certain tuples are limited in accordance with user privileges.
    ``_vindex`` contains only those tuples that are accessible to the current user.
    See :ref:`Access control <authentication>` for details about user privileges.

    If the user has the full set of privileges (like 'admin'), the contents
    of ``_vindex`` match the contents of ``_index``. If the user has limited
    access, ``_vindex`` contains only tuples accessible to this user.

    .. NOTE::

       * ``_vindex`` is a system view, so it allows only read requests.

       * While the ``_index`` space requires proper access privileges, any user
         can always read from ``_vindex``.
