.. _getting_started-schema_changing:

=================================================================================
Updating the data schema
=================================================================================

When working with data, it is sometimes necessary to change the original data schema.

In the previous sections, we described a cluster-wide data schema in the YAML format.
The ``ddl`` module is responsible for applying the schema on the cluster. This module does not allow
to modify the schema after applying it.

The easiest way to change it is to delete the database snapshots and create
a schema from scratch. Of course, this is only acceptable during development and debugging.
applications. For production scenarios read the section :ref:`migrations<migrations>`.

To remove snapshots, you need:

- if you are using Tarantool in the cloud, then you can use the "Reset configuration" button
- if you start Tarantool locally via the cartridge start utility, then you can run the command
``cartridge clean`` in the application directory.
- if you start Tarantool in a different way, then you need to delete snapshots and xlogs manually. They have the .snap and .xlog extensions, respectively, and are located in the Tarantool working directory.

To understand how the Tarantool data schema works, read the section :ref:`Data model<box_data_model>`.