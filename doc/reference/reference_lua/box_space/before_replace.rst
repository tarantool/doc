.. _box_space-before_replace:

===============================================================================
space_object:before_replace()
===============================================================================

.. module:: box.space

.. class:: space_object

    .. method:: before_replace([trigger-function [, old-trigger-function]])

        Create a "replace :ref:`trigger <triggers>`".
        The ``trigger-function`` will be executed
        whenever a ``replace()`` or ``insert()`` or ``update()`` or ``upsert()``
        or ``delete()`` happens to a tuple in ``<space-name>``.

        :param function     trigger-function: function which will become the
                                              trigger function; for the trigger
                                              function's optional parameters see
                                              the description of
                                              :ref:`on_replace <box_space-on_replace>`.
        :param function old-trigger-function: existing trigger function which
                                              will be replaced by
                                              ``trigger-function``
        :return: nil or function pointer

        If the parameters are ``(nil, old-trigger-function)``, then the old
        trigger is deleted.

        If both parameters are omitted, then the response is a list of existing trigger functions.

        If it is necessary to know whether the trigger activation
        happened due to replication or on a specific connection type,
        the function can refer to :ref:`box.session.type() <box_session-type>`.

        Details about trigger characteristics are in the
        :ref:`triggers <triggers-box_triggers>` section.

        See also :ref:`space_object:on_replace() <box_space-on_replace>`.

        Administrators can make replace triggers with ``on_replace()``,
        or make triggers with ``before_replace()``.
        If they make both types, then all ``before_replace`` triggers
        are executed before all ``on_replace`` triggers.
        The functions for both ``on_replace`` and ``before_replace``
        triggers can make changes to the database, but only the
        functions for ``before_replace`` triggers can change the
        tuple that is being replaced.

        Since a ``before_replace`` trigger function has the extra
        capability of making a change to the old tuple, it also can have
        extra overhead, to fetch the old tuple before making the
        change. Therefore an ``on_replace`` trigger is better if
        there is no need to change the old tuple. However, this
        only applies for the memtx engine -- for the vinyl engine,
        the fetch will happen for either kind of trigger.
        (With memtx the tuple data is stored along with the
        index key so no extra search is necessary;
        with vinyl that is not the case so the extra search
        is necessary.)

        Where the extra capability is not needed,
        ``on_replace`` should be used instead of ``before_replace``.
        Usually ``before_replace`` is used only for certain
        replication scenarios -- it is useful for conflict resolution.

        The value that a ``before_replace`` trigger function can return
        affects what will happen after the return. Specifically:

        * if there is no return value, then execution proceeds,
          inserting|replacing the new value;
        * if the value is nil, then the tuple will be deleted;
        * if the value is the same as the old parameter, then no
          ``on_replace`` function will be called and the data
          change will be skipped. The return value will be absent.

        * if the value is the same as the new parameter, then it's as if
          the ``before_replace`` function wasn't called;
        * if the value is some other tuple, then it is used for insert/replace.

        However, if a trigger function returns an old tuple, or if a
        trigger function calls :ref:`run_triggers(false) <box_space-run_triggers>`,
        that will not affect other triggers that are activated for the same
        insert|update|replace request.

        **Example:**

        The following are ``before_replace`` functions that have no return
        value, or that return nil, or the same as the old parameter, or the
        same as the new parameter, or something else.

        .. code-block:: lua

            function f1 (old, new) return end
            function f2 (old, new) return nil end
            function f3 (old, new) return old end
            function f4 (old, new) return new end
            function f5 (old, new) return box.tuple.new({new[1],'b'}) end
