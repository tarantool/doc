.. _box_ctl-on_schema_init:

===============================================================================
box.ctl.on_schema_init()
===============================================================================

.. module:: box.ctl

.. function:: on_schema_init(trigger-function [, old-trigger-function])

    Create a "schema_init :ref:`trigger <triggers>`".
    The ``trigger-function`` will be executed
    when :ref:`box.cfg{} <index-book_cfg>` happens for the first time.
    That is, the ``schema_init`` trigger is called before the server's
    configuration and recovery begins, and therefore ``box.ctl.on_schema_init``
    must be called before ``box.cfg`` is called.

    :param function     trigger-function: function which will become the
                                           trigger function
    :param function old-trigger-function: existing trigger function which
                                          will be replaced by
                                          trigger-function
    :return: nil or function pointer

    If the parameters are (nil, old-trigger-function), then the old
    trigger is deleted.

    A common use is: make a ``schema_init`` trigger function which creates
    a ``before_replace`` trigger function on a system space. Thus, since
    system spaces are created when the server starts, the ``before_replace``
    triggers will be activated for each tuple in each system space.
    For example, such a trigger could change the storage engine of a
    given space, or make a given space :ref:`replica-local <replication-local>`
    while a replica is being bootstrapped. Making such a change after ``box.cfg``
    is not reliable because other connections might use the database before
    the change is made.

    Details about trigger characteristics are in the :ref:`triggers <triggers-box_triggers>` section.

    **Example:**

    Suppose that, before the server is fully up and ready
    for connections, you want to make sure that the engine of
    space ``space_name`` is vinyl. So you want to make a trigger
    that will be activated when a tuple is inserted in the
    ``_space`` system space. In this case you could end up with
    a master that has space-name with ``engine='memtx'`` and a
    replica that has space_name with ``engine='vinyl'``, with
    the same contents.

    .. code-block:: lua

        function function_for_before_replace(old, new)
          if old == nil and new ~= nil and new[3] == 'space_name' and new[4] ~= 'vinyl' then
            return new:update{{'=', 4, 'vinyl'}}
          end
        end

        box.ctl.on_schema_init(function()
          box.space._space:before_replace(function_for_before_replace)
        end)

        box.cfg{replication='master_uri', ...}
