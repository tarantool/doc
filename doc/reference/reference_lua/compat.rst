.. _compat-module:

Module compat
=============

[TDB] some intro sentences
[TBD] Since version :doc:`2.11.0-rc </release/2.11.0-rc>`.


The usual way to handle compatibility problems is to introduce an option for new behavior and leave the old one by default.
It is not always the perfect way.

Sometimes we want to keep the old behavior for existing applications and offer the new one by default for new ones.
For example, the old behavior is known to be problematic / less safe / does not correspond to user expectations.
In contrast, the user doesn’t always read all the documentation and often assumes good defaults.
It was decided to introduce a compatibility module to provide a direct way to deprecate unwanted behavior.

The ``compat`` module is basically a global table of options with additional verbose interface and helper functions.
There are three stages of changing behavior:

*   old behavior by default
*   new behavior by default
*   new behavior is frozen and the old behavior is removed.

During the first two stages, a user can toggle options via the interface and change the behavior according to one's needs.
At the last stage, the old behavior is removed from the codebase and the option is marked as obsolete.
Because compat is a global instance, options can be hardcoded into it or added in runtime, for example, by external module.

Options will be switched to the next stage in major releases, this way developers would be able to adapt to the new standard behavior and test it before switching to the next release.
If something is broken by the new tarantool version, developer would still have a way to fix it by a simple config change (explicitly select old behavior).

Consider example below:

*   The option ``json_esc_slash`` is introduced in the 2.11 minor release. Default is set to 'old' but developer can utilize new behavior or test updated behavior by switching it manually to 'new'.

*   In 3.0 — next major release, json_esc_slash's default is switched to 'new'. Now developers that didn’t manage to adapt to new behavior will be able to switch option to 'old' and fix their module in the future.

*   In 4.0 json_esc_slash is marked as obsolete and old behavior is no longer accessible. Developers are forced to use new behavior.

Basic compat usage
------------------

If you want to explicitly secure every behavior in compat, you can do it manually and then call ``compat.dump()`` to get a Lua command that sets up compat with all thouse picked options.
You should place this commands at the beginning of your init.lua. This way you are guaranteed to get the same behavior on any other Tarantool version.
See a :doc:`tutorial on using compat <./compat/compat_tutorial>` for more examples.

Existing options
----------------

..  toctree::

    compat/json_escape_forward_slash
    compat/yaml_pretty_multiline
    compat/fiber_channel_close_mode
    compat/box_cfg_replication_sync_timeout
    compat/sql_seq_scan_default

[TDB] topics and links below

compat tutorial
---------------

    compat/compat_tutorial

compat module API
-----------------

    compat/compat_api

