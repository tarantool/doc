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

For every new feature or parameter, please indicate the version it was introduced in.

With Tarantool features and parameters, use one of the following Sphinx directives:

..  code-block:: rst

    Since :tarantool-release:`2.10.0`.
    This is a link to the release notes on GitHub.

    Since :doc:`2.10.0 </release/2.10.0>`.
    This is a link to the release notes on the Tarantool documentation website.

The result looks like this:

    Since Tarantool :tarantool-release:`2.10.0`.
    This is a link to the release notes on GitHub.

    Since Tarantool :doc:`2.10.0 </release/2.10.0>`.
    This is a link to the release notes on the Tarantool documentation website.

See also the :doc:`guide on writing release notes </contributing/release_notes/>`.

..  _contributing-api-docs_general-description:

Language of the general description
-----------------------------------

Use one of the two options:

*   Start with a verb in the imperative mood. Example: *Create a fiber.*
*   Start with a noun. Example: *The directory where memtx stores snapshot files.*

Checklist
---------

Function or method
^^^^^^^^^^^^^^^^^^

*   :ref:`Since which Tarantool version <contributing-docs-api_version>`
*   :ref:`General description <contributing-api-docs_general-description>`
*   :ref:`Parameters <documenting_parameters>`
*   What this function returns (if nothing, write 'none')
*   Return type (if exists)
*   Possible errors (if exist)
*   Complexity factors (if exist)
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

Function and class parameters
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

*   :ref:`Since which Tarantool version <contributing-docs-api_version>`
    (if added later)
*   :ref:`General description <contributing-api-docs_general-description>`
*   Type
*   Default value (if optional), possible values

If the parameter is optional, make sure it is enclosed in square brackets
in the function declaration (in the "heading").

In the "Possible errors" section of the function or class method,
consider explaining what happens if the parameter hasn't been defined or has the wrong value.

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
*   Possible values
*   Dynamic (yes or no)

See :ref:`configuration parameter example <contributing-api-docs_confval-example>`.

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

..  literalinclude:: ./_includes/confval_template.rst
    :language: rst

Result:

..  include:: ./_includes/confval_template.rst
