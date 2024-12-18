.. _compat-option-session-push-deprecation:

box.session.push() deprecation
==============================

Option: ``box_session_push_deprecation``

Starting from version 3.0, Lua API function :ref:`box.session.push() <box_session-push>`
and C API function :ref:`box_session_push() <box_box_session_push>` are deprecated.

Old and new behavior
--------------------

New behavior: calling `box.session.push()` raises an error.

..  code-block:: tarantoolsession

    tarantool> box.session.push({1})
    ---
    - error: box.session.push is deprecated
    ...

Old behavior: `box.session.push()` is available to use. When it's called for the
first time, a deprecation warning is printed to the log.

..  code-block:: tarantoolsession

    tarantool> box.session.push({1})
    2024-12-18 15:42:51.537 [50750] main/104/interactive session.c:569 W> box.session.push is deprecated. Consider using box.broadcast instead.
    %TAG !push! tag:tarantool.io/push,2018
    ---
    - 1
    ...
    ---
    - true
    ...

Known compatibility issues
--------------------------

At this point, no incompatible modules are known.

Detecting issues in your codebase
---------------------------------

If your application uses `box.session.push()`, consider rewriting it using
:ref:`box.broadcast() <box-broadcast>`.