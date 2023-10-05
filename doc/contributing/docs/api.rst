Documenting the API
===================

This document contains general guidelines for describing the Tarantool API,
as well as examples and templates.

Style
-----

Please write as simply as possible. Describe functionality using short sentences in the present simple tense.
A short sentence consists of no more than two clauses.
Consider using `LanguageTool <https://languagetool.org/>`_ or `Grammarly <https://www.grammarly.com/>`_
to check your English.
For more style-related specifics, consult the :doc:`Language and style </contributing/docs/style>` section.

..  _contributing-docs-api_version:

Indicating the version
----------------------

For every new module, function, or method, specify the version it first appears in.

For a new parameter, specify the version it first appears in if this parameter is a "feature"
and the version it's been introduced in differs from
the version introducing the function/method and all other parameters.

To specify the version, use the following Sphinx directive:

..  code-block:: rst

    Since :doc:`2.10.0 </release/2.10.0>`.
    This is a link to the release notes on the Tarantool documentation website.

The result looks like this:

    Since Tarantool :doc:`2.10.0 </release/2.10.0>`.
    This is a link to the release notes on the Tarantool documentation website.

..  _contributing-api-docs_general-description:

Language of the general description
-----------------------------------

Use one of the two options:

*   Start with a verb in the imperative mood. Example: *Create a fiber.*
*   Start with a noun. Example: *The directory where memtx stores snapshot files.*

Checklist
---------

Each list item is a characteristic to be described. Some items can be optional.

Function or method
^^^^^^^^^^^^^^^^^^

*   :ref:`Since which Tarantool version <contributing-docs-api_version>`
*   :ref:`General description <contributing-api-docs_general-description>`
*   :ref:`Parameters <documenting_parameters>`
*   What this function returns (if nothing, write 'none')
*   Return type (if exists)
*   :ref:`Possible errors <contributing-docs-possible_errors>` (if exist)
*   :ref:`Complexity factors <index-box_complexity-factors>`
    (for :doc:`CRUD operations </reference/reference_lua/box_space>` and
    :doc:`index access functions </reference/reference_lua/box_index/>`)
*   Usage with memtx and vinyl (if differs)
*   Example(s)
*   Extra information (if needed)

See :ref:`module function example <contributing-api-docs_function-example>`,
:ref:`class method example <contributing-api-docs_class-example>`.

Data
^^^^

*   :ref:`Since which Tarantool version <contributing-docs-api_version>`
*   :ref:`General description <contributing-api-docs_general-description>`
*   Return type
*   Example

See :ref:`class data example <contributing-api-docs_class-example>`.

..  _documenting_parameters:

Function and method parameters
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

*   :ref:`Since which Tarantool version <contributing-docs-api_version>`
    (if added later)
*   :ref:`General description <contributing-api-docs_general-description>`
*   Type
*   Default value (if optional), possible values

If the parameter is optional, make sure it is enclosed in square brackets
in the function declaration (in the "heading").
Do not mark parameters additionaly as "optional" or "required":

..  code-block:: rst

    ..  function:: format(URI-components-table[, include-password])

        Construct a URI from components.

        :param URI-components-table: a series of ``name:value`` pairs, one for each component
        :param include-password: boolean. If this is supplied and is ``true``, then
                                 the password component is rendered in clear text,
                                 otherwise it is omitted.

..  _documenting_confvals:

Configuration parameters
^^^^^^^^^^^^^^^^^^^^^^^^

Configuration parameters are not to be confused with class and method parameters.
Configuration parameters are passed to Tarantool via the command line or in an initialization file.
You can find a list of Tarantool configuration parameters in the :doc:`configuration reference </reference/configuration/index>`.

*   :ref:`Since which Tarantool version <contributing-docs-api_version>`
*   :ref:`General description <contributing-api-docs_general-description>`
*   Type
*   Corresponding environment variable (if applicable)
*   Default value
*   Possible values (can be included in the general description, for example, as a list)
*   Dynamic (yes or no)

See :ref:`configuration parameter example <contributing-api-docs_confval-example>`.

..  _contributing-docs-possible_errors:

Documenting possible errors
---------------------------

In the "Possible errors" section of a function or class method,
consider explaining what happens if any parameter hasn't been defined or has the wrong value.

Examples and templates
----------------------

..  _contributing-api-docs_function-example:

Module functions
^^^^^^^^^^^^^^^^

We use the Sphinx directives ``.. module::``
and ``.. function::`` to describe functions of Tarantool modules:

..  literalinclude:: ./_includes/function_template.rst
    :language: rst

The resulting output looks like this:

..  include:: ./_includes/function_template.rst


..  _contributing-api-docs_class-example:

Class methods and data
^^^^^^^^^^^^^^^^^^^^^^

Methods are described similarly to functions, but the ``.. class::``
directive, unlike ``.. module::``, requires nesting.

As for data, it's enough to write the description, the return type, and an example.

Here is the example documentation describing
the method and data of the ``index_object`` class:

..  literalinclude:: ./_includes/class_template.rst
    :language: rst

And the resulting output looks like this:

..  include:: ./_includes/class_template.rst

..  _contributing-api-docs_confval-example:

Configuration parameters
^^^^^^^^^^^^^^^^^^^^^^^^

Example:

..  literalinclude:: /reference/configuration/cfg_basic.rst
    :language: rst
    :lines: 219-231

Result:

..  include:: /reference/configuration/cfg_basic.rst
    :start-line: 219
    :end-line: 231
