.. _box_space-session_settings:

===============================================================================
box.space._session_settings
===============================================================================

.. module:: box.space

.. data:: _session_settings

    A temporary system space with settings that affect behavior, particularly SQL behavior,
    for the current session. It uses a special engine named 'service'.
    Every 'service' tuple is created on the fly, that is, new tuples are made every
    time ``_session_settings`` is accessed.
    Every settings tuple has two fields: ``name`` (the primary key) and ``value``.
    The tuples' names and default values are:

    *   ``error_marshaling_enabled``: whether :doc:`error objects </reference/reference_lua/box_error/new>` have
        a special structure. Default: ``false``.
    *   ``sql_default_engine``: default :ref:`storage engine <engines-chapter>` for new SQL tables. Default: ``memtx``.
    *   ``sql_full_column_names``: use full column names in :ref:`SQL result set metadata <box-sql_result_sets>`.
        Default: ``false``.
    *   ``sql_full_metadata``: whether :ref:`SQL result set metadata <box-sql_result_sets>` includes more than just name
        and type. Default:``false``.
    *   ``sql_parser_debug``: show parser steps for following statements. Default: ``false``.
    *   ``sql_recursive_triggers``: whether a triggered statement can activate a :ref:`trigger <sql_create_trigger>`.
        Default: ``true``.
    *   ``sql_reverse_unordered_selects``: return result rows in reverse order if there is no :ref:`ORDER BY clause <sql_order_by>`.
        Default: ``false``.
    *   ``sql_select_debug``: show execution steps during :ref:`SELECT <sql_select>`. Default:``false``.
    *   ``sql_vdbe_debug``: for internal use. Default:``false``.
    *   ``sql_defer_foreign_keys``: **(removed in :doc:`2.11.0 </release/2.11.0>`)** whether foreign-key checks can wait till
        commit. Default: ``false``.

    Three requests are possible: :doc:`select </reference/reference_lua/box_space/select>`, :doc:`get </reference/reference_lua/box_space/get>`
    and :doc:`update </reference/reference_lua/box_space/update>`.
    For example, after ``s = box.space._session_settings``,
    ``s:select('sql_default_engine')`` probably returns ``{'sql_default_engine', 'memtx'}``, and
    ``s:update('sql_default_engine', {{'=', 'value', 'vinyl'}})`` changes the default engine to 'vinyl'. |br|
    Updating ``sql_parser_debug`` or ``sql_select_debug`` or ``sql_vdbe_debug`` has no effect unless
    Tarantool was built with ``-DCMAKE_BUILD_TYPE=Debug``. To check if this is so, look at
    ``require('tarantool').build.target``.
