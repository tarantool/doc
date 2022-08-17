.. _interval_arithm:

Interval arithmetic
===================

Since :doc:`2.10.0 </release/2.10.0>`.

The :doc:`datetime module </reference/reference_lua/datetime>` enables creating objects of two types: ``datetime`` and ``interval``.

If you need to shift the ``datetime`` object values, you can use either the modifier methods, that is, the :ref:`:add <datetime-add>` or :ref:`:sub <datetime-sub>` methods,
or apply interval arithmetic using overloaded `+ (__add)` or `- (__sub)` methods.

``:add``/``:sub`` modify the current object, but ``+``/``-`` create copy of the object as the operation result.

In the interval operation, each of the interval subcomponents are sequentially calculated starting from the largest (``year``) to the smallest (``nsec``):

*   ``year`` -- years
*   ``month`` -- months
*   ``week`` -- weeks
*   ``day`` -- days
*   ``hour`` -- hours
*   ``min`` -- minutes
*   ``sec`` -- seconds
*   ``nsec`` -- nanoseconds.

If results of the operation exceed the allowed range for any of the components, an exception is raised.

The ``datetime`` and ``interval`` objects can participate in arithmetic operations:

*   The sum of two intervals is an interval object, which fields are sum of each particular component of operands.

*   The result of subtraction of two intervals is similar: it's an interval object where each subcomponent is the result of subtraction of particular fields in the original operands.

*   If you add datetime and interval objects, the result is a datetime object. Addition is being performed in a determined order from the largest component (``year``) to the smallest (``nsec``).

*   Subtraction of two datetime objects produce an interval object. Difference of two time values is performed not as difference of the epoch seconds,
    but as difference of all the subcomponents, that is, years, months, days, hours, minutes, and seconds.

*   An untyped table object can be used in each context where the typed datetime or interval objects are used if left operand is typed object with overloaded operation of ``+`` or ``-``.

The matrix of the ``addition`` operands eligibility and their result types:

..  container:: table

    ..  list-table::
        :widths: 25 25 25 25
        :header-rows: 1

        *   -
            -   datetime
            -   interval
            -   table

        *   -   **datetime**
            -
            -   datetime
            -   datetime

        *   -   **interval**
            -   datetime
            -   interval
            -   interval

        *   -   **table**
            -
            -
            -

The matrix of the ``subtraction`` operands eligibility and their result types:

..  container:: table

    ..  list-table::
        :widths: 25 25 25 25
        :header-rows: 1

        *   -
            -   datetime
            -   interval
            -   table

        *   -   **datetime**
            -   interval
            -   datetime
            -   datetime

        *   -   **interval**
            -
            -   interval
            -   interval

        *   -   **table**
            -
            -
            -
