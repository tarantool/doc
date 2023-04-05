..  _box_schema-upgrade:

box.schema.upgrade()
====================

..  module:: box.schema

..  function:: box.schema.upgrade()

    If you created a database with an older Tarantool version and have now installed
    a newer version, make the request ``box.schema.upgrade()``. This updates
    Tarantool system spaces to match the currently installed version of Tarantool.

    For example, here is what happens when you run ``box.schema.upgrade()`` with a
    database created with Tarantool version 1.6.4 to version 1.7.2 (only a small
    part of the output is shown):

    ..  code-block:: tarantoolsession

        tarantool> box.schema.upgrade()
        alter index primary on _space set options to {"unique":true}, parts to [[0,"unsigned"]]
        alter space _schema set options to {}
        create view _vindex...
        grant read access to 'public' role for _vindex view
        set schema version to 1.7.0
        ---
        ...
 
    You can also put the request ``box.schema.upgrade()``
    inside a :doc:`box.once() </reference/reference_lua/box_once>` function in your Tarantool
    :ref:`initialization file <index-init_label>`.
    On startup, this will create new system spaces, update data type names (for example,
    ``num`` -> ``unsigned``, ``str`` -> ``string``) and options in Tarantool system spaces.

    See also: :ref:`box.schema.downgrade() <box_schema-downgrade>`
