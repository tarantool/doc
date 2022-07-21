
Module datetime
===============

Since :doc:`2.10.0 </release/2.10.0>`.

The ``datetime`` module provides support of the timestamp and interval data types. [TDB -- links].
It allows to create the date and timestamp values using either object interface,
or via parsing the string values conforming to ISO-8601 standard.

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
            -   Create a datetime object from a table of date and time values/parameters

        *   -   :ref:`format() <datetime-format>`
            -   Convert a datetime object into a string of a particular format

        *   -   :ref:`totable() <datetime-totable>`
            -   Convert a datetime object into a Lua table

        *   -   :ref:`set() <datetime-set>`
            -   Update the field values in the existing datetime object



..  toctree::
    :hidden:

    datetime/new
    datetime/datetime_object
