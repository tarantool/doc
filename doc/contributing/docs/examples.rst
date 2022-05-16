Examples and templates
======================

This document contains general guidelines for describing the Tarantool API,
as well as examples and templates.

Use this checklist for documenting a function or a method:

*   General description
*   :ref:`Parameters <documenting_parameters>`
*   What this function returns (if nothing, write 'none')
*   Return type (if exists)
*   Possible errors (if exist)
*   Complexity factors (if exist)
*   Usage with memtx and vinyl (if differs)
*   Example(s)
*   Extra information (if needed)

Documenting functions
---------------------

We use the Sphinx directives ``.. module::``
and ``.. function::`` to describe functions of Tarantool modules:

..  literalinclude:: ./_includes/function_template.rst
    :language: rst

The resulting output looks like this:

..  include:: ./_includes/function_template.rst

..  note::

    The best practices for :ref:`parameter description <documenting_parameters>` are listed below.

Documenting class methods and data
----------------------------------

Methods are described similarly to functions, but the ``.. class::``
directive, unlike ``.. module::``, requires nesting.

As for data, it's enough to write the description, the return type, and an example.

Here is the example documentation describing
the method and data of the ``index_object`` class:

..  literalinclude:: ./_includes/class_template.rst
    :language: rst

And the resulting output looks like this:

..  include:: ./_includes/class_template.rst

..  note::

    The best practices for :ref:`parameter description <documenting_parameters>` are listed below.

..  _documenting_parameters:

Parameters in functions and classes
-----------------------------------

This section explains how to document specific function or class method parameters as described above.
To learn how to document :doc:`configuration parameters </reference/configuration/index>`
passed to Tarantool via the command line or in an initialization file,
see the :ref:`next section <documenting_confvals>`.

For every function or class method parameter, list the following details:

*   General description
*   Type
*   If optional, indicate *(optional)* in parentheses
*   Default value (if optional), possible values

In the "Possible errors" section of the function or class method,
consider explaining what happens if the parameter hasn't been defined or has the wrong value.

..  _documenting_confvals:

Configuration parameters
------------------------

For every configuration parameter, list the following details:

*   Since which Tarantool version
*   General description
*   Type
*   Corresponding environment variable (if applicable)
*   Default value
*   Possible values
*   Dynamic (yes or no)

Example
^^^^^^^

..  literalinclude:: ./_includes/confval_template.rst
    :language: rst

Result:

..  include:: ./_includes/confval_template.rst
