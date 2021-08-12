Examples and templates
======================

This document contains general guidelines for describing the Tarantool API,
as well as examples and templates.

Use this checklist for documenting a function or a method:

* Base description
* Parameters
* What this function returns (if nothing, write 'none')
* Return type (if exists)
* Possible errors (if exist)
* Complexity factors (if exist)
* Example(s)
* Extra information (if needed)
..  // * Note re storage engine (if exists). TODO (was the third from last bullet point)

Documenting functions
~~~~~~~~~~~~~~~~~~~~~

We use the Sphinx directives ``.. module::``
and ``.. function::`` to describe functions of Tarantool modules:

..  literalinclude:: ./_includes/function_template.rst
    :language: rst

The resulting output looks like this:

..  include:: ./_includes/function_template.rst

Documenting class methods and data
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Methods are described similarly to functions, but the ``.. class::``
directive, unlike ``.. module::``, requires nesting.

As for data, it's enough to write the description, the return type, and an example.

Here is the example documentation describing
the method and data of the ``index_object`` class:

..  literalinclude:: ./_includes/class_template.rst
    :language: rst

And the resulting output looks like this:

..  include:: ./_includes/class_template.rst
