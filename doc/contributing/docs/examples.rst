
================================================================================
Examples and templates
================================================================================

In this document, we explain general guidelines for describing Tarantool API and
give some examples and templates.

Use this checklist for documenting a function or a method:

* Base description
* Parameters
* What this function returns (if nothing, write 'none')
* Return type (if exists)
* Possible errors (if exist)
* Complexity factors (if exist)
* Note re storage engine (if exists)
* Example(s)
* Extra information (if needed)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Documenting a function
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We describe functions of Tarantool modules via Sphinx directives ``.. module::``
and ``.. function::``:

..  literalinclude:: function_template.rst
    :language: rst

And the resulting HTML looks like this:

..  include:: function_template.rst

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Documenting class method and data
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Description of a method is similar to a function, but the ``.. class::``
directive, unlike ``.. module::``, requires nesting.

As for documenting data, it will be enough to write a description,
a return type, and an example.

Here is an example of documenting a method and data of a class ``index_object``:

..  literalinclude:: class_template.rst
    :language: rst

And the resulting HTML looks like this:

..  include:: class_template.rst