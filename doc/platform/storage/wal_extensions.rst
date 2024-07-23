..  _wal_extensions:

WAL extensions
==============

..  admonition:: Enterprise Edition
    :class: fact

    WAL extensions are available in the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

WAL extensions allow you to add auxiliary information to each :ref:`write-ahead log <internals-wal>` record.
For example, you can enable storing an old and new tuple for each CRUD operation performed.
This information might be helpful for implementing a CDC (Change Data Capture) utility
that transforms a data replication stream.

See also: :ref:`Configure the write-ahead log <configuration_persistence_wal>`.

..  _wal_extensions_configuration:

Configuration
-------------

WAL extensions are disabled by default.
To configure them, use the :ref:`wal.ext.* <configuration_reference_wal_ext>` configuration options.
Inside the ``wal.ext`` block, you can enable storing old and new tuples as follows:

*   To store old and new tuples in a write-ahead log for all spaces, set the
    :ref:`wal.ext.old <configuration_reference_wal_ext_old>` and :ref:`wal.ext.new <configuration_reference_wal_ext_new>`
    options to ``true``:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/persistence_wal/config.yaml
        :language: yaml
        :start-at: ext:
        :end-at: old: true
        :dedent:

*   To adjust these options for specific spaces, specify the :ref:`wal.ext.spaces <configuration_reference_wal_ext_spaces>` option:

    ..  code-block:: yaml

        wal:
          ext:
            old: true
            new: true
            spaces:
              space1:
                old: false
              space2:
                new: false

    The configuration for specific spaces has priority over the configuration in the ``wal.ext.new`` and ``wal.ext.old``
    options.
    It means that only new tuples are added to the log for ``space1`` and only old tuples for ``space2``.

Note that records with additional fields are :ref:`replicated <replication-architecture>` as follows:

*   If a replica doesn't support the extended format configured on a master, auxiliary fields are skipped.
*   If a replica and master have different configurations for WAL records, the master's configuration is ignored.

..  _wal_extensions_example:

Example
-------

The table below demonstrates how write-ahead log records might look
for the specific :ref:`CRUD operations <box_space_examples>`
if storing old and new tuples is enabled for the ``bands`` space.

..  container:: table

    ..  list-table::
        :widths: 10 50 40
        :header-rows: 1

        *   -   Operation
            -   Example
            -   WAL information
        *   -   insert
            -   ``bands:insert{4, 'The Beatles', 1960}``
            -   | **new_tuple**: [4, 'The Beatles', 1960]
                | tuple: [4, 'The Beatles', 1960]
        *   -   delete
            -   ``bands:delete{4}``
            -   | key: [4]
                | **old_tuple**: [4, 'The Beatles', 1960]
        *   -   update
            -   ``bands:update({2}, {{'=', 2, 'Pink Floyd'}})``
            -   | **new_tuple**: [2, 'Pink Floyd', 1965]
                | **old_tuple**: [2, 'Scorpions', 1965]
                | key: [2]
                | tuple: [['=', 2, 'Pink Floyd']]
        *   -   upsert
            -   ``bands:upsert({2, 'Pink Floyd', 1965}, {{'=', 2, 'The Doors'}})``
            -   | **new_tuple**: [2, 'The Doors', 1965]
                | **old_tuple**: [2, 'Pink Floyd', 1965]
                | operations: [['=', 2, 'The Doors']]
                | tuple: [2, 'Pink Floyd', 1965]
        *   -   replace
            -   ``bands:replace{1, 'The Beatles', 1960}``
            -   | **old_tuple**: [1, 'Roxette', 1986]
                | **new_tuple**: [1, 'The Beatles', 1960]
                | tuple: [1, 'The Beatles', 1960]

Storing both old and new tuples is especially useful for the ``update``
operation because a write-ahead log record contains only a key value.

.. NOTE::

    You can use the :doc:`tt cat </reference/tooling/tt_cli/cat>` command to see the contents of a write-ahead log.
