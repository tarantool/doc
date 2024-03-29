
Module datetime
===============

Since :doc:`2.10.0 </release/2.10.0>`.

The ``datetime`` module provides support for the :ref:`datetime and interval data types <index-box_datetime>`.
It allows creating the date and time values either via the object interface
or via parsing string values conforming to the ISO-8601 standard.

Below is a list of the ``datetime`` module functions and methods.

.. container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 25 75
        :header-rows: 1

        *   -   Name
            -   Use

        *   -   :doc:`./datetime/new`
            -   Create a ``datetime`` object from a table of time units.

        *   -   :ref:`format() <datetime-format>`
            -   Convert the standard presentation of a ``datetime`` object into a formatted string.

        *   -   :ref:`datetime_object:totable() <datetime-totable>`
            -   Convert the information from a ``datetime`` object into the table format.

        *   -   :ref:`set() <datetime-set>`
            -   Update the field values in the existing ``datetime`` object.

        *   -   :ref:`parse() <datetime-parse>`
            -   Convert an input string with the date and time information into a ``datetime`` object.

        *   -   :ref:`add() <datetime-add>`
            -   Modify an existing datetime object by adding values of the input arguments.

        *   -   :ref:`sub() <datetime-sub>`
            -   Modify an existing datetime object by subtracting values of the input arguments.

        *   -   :doc:`./datetime/interval_new`
            -   Create an ``interval`` object from a table of time units.

        *   -   :ref:`interval_object:totable() <interval-totable>`
            -   Convert the information from an ``interval`` object into the table format.

        *   -   :doc:`./datetime/interval_arithm`
            -   Arithmetic operations with datetime and interval objects.

..  toctree::
    :hidden:

    datetime/new
    datetime/datetime_object
    datetime/interval_new
    datetime/interval_object
    datetime/interval_arithm
