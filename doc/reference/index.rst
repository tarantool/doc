..  _reference:

********************************************************************************
Reference
********************************************************************************

..  panels::
    :container: doc-cards
    :column: doc-card doc-card_medium
    :card: doc-card__content
    :header: doc-card__title
    :body: doc-card__text
    :footer: doc-card__link

    SQL Reference

    ^^^

    SQL statements and clauses supported by Tarantool.

    ---

    Built-in modules reference

    ^^^

    Tarantool's built-in Lua modules.

    ---

    Rocks reference

    ^^^

    Third-party Lua modules for Tarantool.

    ---

    Configuration reference

    ^^^

    Options and parameters which can be set for Tarantool on the command line or in an initialization file.

    ---

    C API reference

    ^^^

    List of C API headers.

    ---

    Internals

    ^^^

    Binary protocol, MessagePack extensions, file formats, and the recovery process.

    ---

    Limitations

    ^^^

    Important limitations for tuples, indexes, and spaces.

    ---

    Interactive console

    ^^^

    Basic CLI for entering requests and seeing results.

    ---

    Utility tarantoolctl

    ^^^

    Utility for administering Tarantool instances, checkpoint files and modules.

    ---

    Tips on Lua syntax

    ^^^

    The Lua syntax for data-manipulating functions.



..  toctree::
    :hidden:
    :maxdepth: 2

    reference_sql/index
    reference_lua/index
    reference_rock/index
    configuration/index
    ../dev_guide/reference_capi/index
    ../dev_guide/internals/index
    ../book/box/limitations
    interactive_console
    tarantoolctl
    lua_tips
