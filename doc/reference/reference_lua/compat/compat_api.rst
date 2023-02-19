..  _compat-api:

compat module API
=================

[TBD] title above
[TBD] some intro

Below is a list of all the ``compat`` functions and members.

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 25 75
        :header-rows: 1

        *   - Name
            - Use

        *   - :ref:`compat-api-help`
            - Show help

        *   - :ref:`compat-api-option`
            - List the option information

        *   - :ref:`compat-api-option-value`
            - Set desired value to the option

        *   - :ref:`compat-api-option-value-many`
            - Set the listed options to desired values ('old', 'new', 'default')

        *   - :ref:`compat-api-dump`
            - Get a Lua command that sets up different compat with same options as current

        *   - :ref:`compat-api-add-option`
            - Add a new compat option

..  _compat-api-help

compat.help()
-------------







..  _compat-api-option

compat.<option_name>
--------------------







..  _compat-api-option-value

compat.<option_name> = '<value>'
--------------------------------







..  _compat-api-option-value-many

compat{<option_name> = '<value>'}
---------------------------------







..  _compat-api-dump

compat.dump(['<value>'])
------------------------







..  _compat-api-add-option

compat.add_option({<option_def>})
---------------------------------





