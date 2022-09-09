.. _getting_started-schema_changing:

=================================================================================
Updating the data schema
=================================================================================

When working with data, it is sometimes necessary to change the original data schema.

In the previous sections, we described a cluster-wide data schema in the YAML format.
The ``ddl`` module is responsible for applying the schema on the cluster. This module does not allow
to modify the schema after applying it.

The easiest way to change it is to delete the database snapshots and create
a schema from scratch. Of course, this is only acceptable during application
development and debugging.
For production scenarios, read the section on :ref:`migrations <migrations>`.

To remove snapshots:

*   If you are using Tarantool in the cloud,
    click the "Reset configuration" button.
*   If you've started Tarantool locally via ``cartridge start``,
    run ``cartridge clean`` in the application directory.
*   If you've started Tarantool in a different way,
    delete the snapshots and xlogs manually.
    These files have the .snap and .xlog extensions respectively,
    and they are located in the Tarantool working directory.

To understand how the Tarantool data schema works, read the :ref:`Data model <box_data_model>` section.
