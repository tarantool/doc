.. _box_space-session_settings:

===============================================================================
box.space._session_settings
===============================================================================

.. module:: box.space

.. data:: _session_settings

    ``_session_settings`` is a temporary system space with a list of settings that
    may affect behavior, particularly SQL behavior, for the current session.
    It uses a special engine named 'service'.
    Every 'service' tuple is created on the fly, that is, new tuples are made every time ``_session_settings`` is accessed.
    Every settings tuple has two fields: ``name`` (the primary key) and ``value``.
    The tuples' names and default values are: |br|
    ``error_marshaling_enabled``: whether
    :doc:`error objects </reference/reference_lua/box_error/new>` have
    a special structure. Default = false. |br|
    ``sql_default_engine``: default :ref:`storage engine <engines-chapter>` for new SQL tables. Default = 'memtx'. |br|
    ``sql_defer_foreign_keys``: whether foreign-key checks can wait till commit. Default = false. |br|
    ``sql_full_column_names``: whether a full column name is used in :ref:`SQL result set metadata <box-sql_result_sets>`. Default = false. |br|
    ``sql_full_metadata``: whether :ref:`SQL result set metadata <box-sql_result_sets>` will have more than just name and type. Default = false. |br|
    ``sql_parser_debug``: whether to show parser steps for following statements. Default = false. |br|
    ``sql_recursive_triggers``: whether a triggered statement can activate a :ref:`trigger <sql_create_trigger>`. Default = true. |br|
    ``sql_reverse_unordered_selects``: whether result rows are usually in reverse order if there is no :ref:`ORDER BY clause <sql_order_by>`. Default = false. |br|
    ``sql_select_debug``: whether to show execution steps during :ref:`SELECT <sql_select>`. Default = false. |br|
    ``sql_vdbe_debug``: for use by Tarantool's developers. Default = false. |br|
    Three requests are possible: :doc:`select </reference/reference_lua/box_space/select>` and :doc:`get </reference/reference_lua/box_space/get>` and :doc:`update </reference/reference_lua/box_space/update>`.
    For example, after ``s = box.space._session_settings``,
    ``s:select('sql_default_engine')`` probably returns ``{'sql_default_engine', 'memtx'}``, and
    ``s:update('sql_default_engine', {{'=', 'value', 'vinyl'}})`` changes the default engine to 'vinyl'. |br|
    Updating ``sql_parser_debug`` or ``sql_select_debug`` or ``sql_vdbe_debug`` has no effect unless
    Tarantool was built with -DCMAKE_BUILD_TYPE=Debug. To check if this is so, look at
    ``require('tarantool').build.target``.
