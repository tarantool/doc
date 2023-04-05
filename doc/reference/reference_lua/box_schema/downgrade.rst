..  _box_schema-downgrade:

box.schema.downgrade()
======================

..  module:: box.schema

..  function:: box.schema.downgrade(version)

    Allows you to downgrade a database to the specified Tarantool version.
    This might be useful if you need to run a database on older Tarantool versions.

    To prepare a database for using it on an older Tarantool instance:

    #. Call ``box.schema.downgrade`` and pass the desired Tarantool version:

        ..  code-block:: tarantoolsession

            tarantool> box.schema.downgrade('2.8.4')

    #. Take a data snapshot using :ref:`box.snapshot() <box-snapshot>`:

        ..  code-block:: tarantoolsession

            tarantool> box.snapshot()


    To see Tarantool versions available for downgrade, call :ref:`box.schema.downgrade_versions() <box_schema-downgrade_versions>`. The oldest supported release available for downgrade is `2.8.2`.

    Note that the downgrade process might fail if the database enables specific features not supported
    in the target Tarantool version.
    You can see all such issues using the :ref:`box.schema.downgrade_issues() <box_schema-downgrade_issues>` method,
    which accepts the target version.
    For example, ``downgrade`` to the ``2.8.4`` version fails if you use `tuple compression <https://www.tarantool.io/en/enterprise_doc/tuple_compression/>`__ or field :ref:`constraints <index-constraint_functions>` in your database:

    ..  code-block:: tarantoolsession

        tarantool> box.schema.downgrade_issues('2.8.4')
        ---
        - - Tuple compression is found in space 'bands', field 'band_name'. It is supported
            starting from version 2.10.0.
          - Field constraint is found in space 'bands', field 'year'. It is supported starting
            from version 2.10.0.
        ...

    See also: :ref:`box.schema.upgrade() <box_schema-upgrade>`
