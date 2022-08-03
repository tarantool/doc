
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

        *   -   :ref:`totable() <datetime-totable>`
            -   Convert the information from a ``datetime`` object into the table format.

        *   -   :ref:`set() <datetime-set>`
            -   Update the field values in the existing ``datetime`` object.

        *   -   :doc:`./datetime/interval_new`
            -   Create an ``interval`` object from a table of time units.


..  toctree::
    :hidden:

    datetime/new
    datetime/datetime_object
    datetime/interval_new
