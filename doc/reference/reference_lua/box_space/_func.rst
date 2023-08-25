.. _box_space-func:

===============================================================================
box.space._func
===============================================================================

.. module:: box.space

.. data:: _func

    A system space containing functions created using :ref:`box.schema.func.create() <box_schema-func_create>`.
    If a function's definition is specified in the :ref:`body <function_options_body>` option,
    this function is *persistent*.
    In this case, its definition is stored in a snapshot and can be recovered if the server restarts.

    .. NOTE::

        The :ref:`system space view <box_space-sysviews>` for ``_func`` is ``_vfunc``.
