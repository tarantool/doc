.. _compat-module:

Module compat
=============

The usual way to handle compatibility problems is to introduce an option for a new behavior and leave the old one by default.
It is not always the perfect way.

Sometimes developers want to keep the old behavior for existing applications and offer the new behavior by default for the new ones.
For example, the old behavior is known to be problematic, or less safe, or it doesn't correspond to user expectations.
In contrast, the user doesn't always read all the documentation and often assumes good defaults.
It was decided to introduce a compatibility module to provide a direct way to deprecate unwanted behavior.

The ``compat`` module is basically a global table of options with additional verbose interface and helper functions.
There are three stages of changing behavior:

1.   Old behavior by default.
2.   New behavior by default.
3.   New behavior is frozen and the old behavior is removed.

During the first two stages, a user can toggle options via the interface and change the behavior according to one's needs.
At the last stage, the old behavior is removed from the codebase, and the option is marked as obsolete.
Because ``compat`` is a global instance, options can be hardcoded into it or added in runtime, for example, by external module.

Options are switched to the next stage in major releases. In this way, developers are able to adapt to the new standard behavior and test it before switching to the next release.
If something is broken by a new Tarantool version, a developer can still have a way to fix it by a simple config change, that is, explicitly select the old behavior.

Consider example below:

*   The option ``json_esc_slash`` is introduced in the 2.11 minor release. Default is set to 'old', but a developer can utilize the new behavior or test the updated behavior by switching it manually to 'new'.

*   In release 3.0, the next major release, ``json_esc_slash`` default is switched to 'new'.
    Now, developers who don't manage to adapt to the new behavior, are able to switch the option to 'old' and fix their module in the future.

*   In release 4.0, ``json_esc_slash`` is marked as obsolete, and the old behavior is no longer accessible. Developers are forced to use the new behavior.

Basic usage
-----------

If you want to explicitly secure every behavior in ``compat``, you can do it manually, and then call ``compat.dump()`` to get a Lua command that sets up the ``compat`` with all the options selected.
You should place this commands at the beginning of code in your ``init.lua`` file. In this way, you are guaranteed to get the same behavior on any other Tarantool version.
See a :doc:`tutorial on using compat <./compat/compat_tutorial>` for more examples.

Configuration options
---------------------

Another way to handle compatibility issues is setting the ``compat.*`` :ref:`configuration options <configuration_reference_compat>`.
Similarly to the ``compat`` Lua module options, the configuration options can have
values ``new`` and ``old``. The set of configuration options matches the set of
options available in the ``compat`` module.

Below is an example fragment of a YAML configuration file:

.. code-block:: yaml

    compat:
      box_space_max: 'new'
      sql_seq_scan_default: 'old'
      fiber_slice_default: 'old'
      binary_data_decoding: 'new'

Learn more in the :ref:`configuration_reference`.

Options
-------

Below are the available ``compat`` options:

* :doc:`json_escape_forward_slash <./compat/json_escape_forward_slash>`
* :doc:`yaml_pretty_multiline <./compat/yaml_pretty_multiline>`
* :doc:`fiber_channel_close_mode <./compat/fiber_channel_close_mode>`
* :doc:`box_cfg_replication_sync_timeout <./compat/box_cfg_replication_sync_timeout>`
* :doc:`sql_seq_scan_default <./compat/sql_seq_scan_default>`
* :doc:`fiber_slice_default <./compat/fiber_slice_default>`
* :doc:`binary_data_decoding <./compat/binary_data_decoding>`
* :doc:`box_info_cluster_meaning <./compat/box_info_cluster_meaning>`
* :doc:`box_session_push_deprecation <./compat/box_session_push_deprecation>`

..  toctree::
    :hidden:

    compat/json_escape_forward_slash
    compat/yaml_pretty_multiline
    compat/fiber_channel_close_mode
    compat/box_cfg_replication_sync_timeout
    compat/sql_seq_scan_default
    compat/fiber_slice_default
    compat/binary_data_decoding
    compat/box_session_push_deprecation
    compat/compat_tutorial
