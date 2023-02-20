.. _compat-tutorial:

compat module tutorial
======================

This tutorial covers the following ``compat`` module API and its usage:

..  contents::
    :local:

Listing options
---------------

The options list is serialized in the interactive console with additional details for user convenience:

*   All non-obsolete options in order new > old > default.

*   Serialization returns array-like table with tables ``{<option> = <value>}``.

*   The result of compat serialization can still be indexed as a normal key-value table.

..  code-block:: lua

    tarantool> compat = require('compat')
    ---
    ...

    tarantool> compat
    ---
    - - json_escape_forward_slash: new
    - - option_2: old
    - - option_default_old: default (old)
    - - option_default_new: default (new)
...

Listing options details
-----------------------

*   ``current`` – the state of the option.
*   ``default`` – the default state of the option.
*   ``brief`` – text options description with a link to more detailed description.

..  code-block:: lua

    tarantool> compat.option_default_new
    ---
    - current: old
    default: new
    brief: <...>
    ...

Changing option value
---------------------

You can do it directly, or by passing a table with option-value.
Possible values to assign are 'new' , 'old', and 'default'.

..  code-block:: lua

    tarantool> compat.json_escape_forward_slash = 'old'
    ---
    ...

    tarantool> compat{json_escape_forward_slash = 'new', option_2 = 'default'}
    ---
    ...

Restoring defaults
------------------

By setting 'default' value to an option:

..  code-block:: lua

    tarantool> compat.option_2 = 'default'
    ---
    ...

    tarantool> compat.option_2
    ---
    - current: default
    - default: new
    - brief: <...>
    ...

Getting compat setup with compat.dump()
---------------------------------------

..  code-block:: lua

    tarantool> compat({
             >     obsolete_set_explicitly = 'new',
             >     option_set_old = 'old',
             >     option_set_new = 'new'
             > })
    ---
    ...

    tarantool> compat
    ---
    - - option_set_old: old
    - - option_set_new: new
    - - option_default_old: default (old)
    - - option_default_new: default (new)
    ...

    # Obsolete options are not returned in serialization, but have the following values:
    # - obsolete_option_default: default (new)
    # - obsolete_set_explicitly: new

    # nil does output obsolete unset options as 'default'
    tarantool> compat.dump()
    ---
    - require('compat')({
                option_set_old          = 'old',
                option_set_new          = 'new',
                option_default_old      = 'default',
                option_default_new      = 'default',
                obsolete_option_default = 'default', -- obsolete since X.Y
                obsolete_set_explicitly = 'new',     -- obsolete since X.Y
        })
    ...

    # 'current' is the same as nil with default set to current values
    tarantool> compat.dump('current')
    ---
    - require('compat')({
                option_set_old          = 'old',
                option_set_new          = 'new',
                option_default_old      = 'old',
                option_default_new      = 'new',
                obsolete_option_default = 'new',     -- obsolete since X.Y
                obsolete_set_explicitly = 'new',     -- obsolete since X.Y
        })
    ...

    # 'new' outputs obsolete as 'new'.
    tarantool> compat.dump('new')
    ---
    - require('compat')({
                option_set_old          = 'new',
                option_set_new          = 'new',
                option_default_old      = 'new',
                option_default_new      = 'new',
                obsolete_option_default = 'new',     -- obsolete since X.Y
                obsolete_set_explicitly = 'new',     -- obsolete since X.Y
        })
    ...

    # 'old' outputs obsolete options as 'new'.
    tarantool> compat.dump('old')
    ---
    - require('compat')({
                option_set_old          = 'old',
                option_set_new          = 'old',
                option_default_old      = 'old',
                option_default_new      = 'old',
                obsolete_option_default = 'new',     -- obsolete since X.Y
                obsolete_set_explicitly = 'new',     -- obsolete since X.Y
        })
    ...

    # 'default' does output obsolete options as default.
    tarantool> dump('default')
    ---
    - require('compat')({
                option_set_old          = 'default',
                option_set_new          = 'default',
                option_default_old      = 'default',
                option_default_new      = 'default',
                obsolete_option_default = 'default', -- obsoleted since X.Y
                obsolete_set_explicitly = 'default', -- obsoleted since X.Y
        })
    ...

Setting all options to a specific value with compat.dump()
----------------------------------------------------------

*   use compat.dump() to get a specific configuration

*   copy and paste it into console (or use loadstring())

..  code-block:: lua

    tarantool> compat.dump('new')
    ---
    - require('compat')({
          option_2 = 'new',
          json_escape_forward_slash = 'new',
      })
    ...
    tarantool> require('compat')({
          option_2 = 'new',
          json_escape_forward_slash = 'new',
      })
    ---
    ...

    tarantool> compat
    ---
    - - json_escape_forward_slash: new
    - - option_2: new
    ...

Adding an option during runtime
-------------------------------

User must provide a table with:

*   name (string)
*   default (’new’ / ’old’)
*   brief (explanation of the option, can be multiline string)
*   obsolete (’X.Y’ / nil) — tarantool version that marked option as obsolete. When nil, option is treated as non-obsolete)
*   action function (argument - boolean is_new, changes the behavior accordingly)
*   run_action_now (true / false / nil) if add_options should run action afterwards, false by default

Option hot reload:

You can change an existing option in runtime using add_option(), it will update all the fields but keep currently selected behavior if any.
The new action will be called afterwards.

..  code-block:: lua

    tarantool> compat.add_option{
                     name = 'option_4',
                     default = 'new',
                     brief = "<...>",
                     obsolete = nil,          -- you can explicitly mark the option as non-obsolete
                     action = function(is_new)
                          print(("option_4 action was called with is_new = %s!"):format(is_new))
                     end,
                     run_action_now = true
               }
    option_4 postaction was called with is_new = true!
    ---
    ...

    tarantool> compat.add_option{             -- hot reload of option_4
                     name = 'option_4',
                     default = 'old',         -- different default
                     brief = "<...>",
                     action = function(is_new)
                          print(("new option_4 action was called with is_new = %s!"):format(is_new))
                     end
               }
    ---
    ...         -- action is not called by default
