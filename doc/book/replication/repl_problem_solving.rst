.. _replication-problem_solving:

================================================================================
Resolving replication conflicts
================================================================================

**************************************************
Solving problems with master-master replication
**************************************************

**Case:** you have two instances of Tarantool. For example, you try to make a 
``replace`` operation with the same primary key on both instances in the same time.
This will cause a conflict over which tuple to save and which one to discard. 

Tarantool :ref:`trigger functions <triggers>` can help here to implement the
rules of conflict resolution on some condition. For example, if you have a
timestamp, you can declare saving the tuple with the bigger one.

First, you need a :ref:`before_replace() <box_space-before_replace>` trigger on
the space which may have conflicts. In this trigger you can compare the old and new
replica records and choose which one to use (or skip the update entirely,
or merge two records together).

Then you need to set the trigger at the right time, before the space starts
to receive any updates. The way you usually set the ``before_replace`` trigger
is right when the space is created, so you need a trigger to set another trigger
on the system space ``_space``, to capture the moment when your space is created
and set the trigger there. This can be an :ref:`on_replace() <box_space-on_replace>`
trigger.

The difference between ``before_replace`` and ``on_replace`` is that ``on_replace``
is called after a row is inserted into the space, and ``before_replace``
is called before that.

To set a ``_space:on_replace()`` trigger correctly, you also need the right timing. The best
timing to use it is when ``_space`` is just created, which is 
the :ref:`box.ctl.on_schema_init() <box_ctl-on_schema_init>` trigger. 

You will also need to utilize ``box.on_commit`` to get access to the space being
created. The resulting snippet would be the following:

.. code-block:: lua

    local my_space_name = 'my_space'
    local my_trigger = function(old, new) ... end -- your function resolving a conflict
    box.ctl.on_schema_init(function()
        box.space._space:on_replace(function(old_space, new_space)
            if not old_space and new_space and new_space.name == my_space_name then
                box.on_commit(function()
                    box.space[my_space_name]:before_replace(my_trigger)
                end
            end
        end)
    end)
