..  _datetime-new:

datetime.interval.new()
=======================

..  function:: datetime.interval.new( [{ input }] )

    Since :doc:`2.10.0 </release/2.10.0>`.

    Create an object of the :ref:`interval type <index-box_interval>` from a table of time units.
    See :ref:`description of units <interval-new-args>` and :ref:`examples <interval-new-example>` below.

    :param table input: Table with :ref:`time units and parameters<interval-new-args>`. For all possible time units, the values are not restricted.
                                If an empty table or no arguments are passed, the ``interval`` object with the default value ``0 seconds`` is created.

    :return: :doc: interval object
    :rtype: cdata

    ..  _interval-new-args:

    **Possible input time units and parameters for ``datetime.interval.new()**

    ..  container:: table

        ..  list-table::
            :widths: 20 50 20 10
            :header-rows: 1

            *   -   Name
                -   Description
                -   Type
                -   Default

            *   -   nsec (usec, msec)
                -   Fractional part of the last second. You can specify either nanoseconds (``nsec``), or microseconds (``usec``), or milliseconds (``msec``).
                    Specifying two of these units simultaneously or all three ones lead to an error.
                -   number
                -   0

            *   -   sec
                -   Seconds
                -   number
                -   0

            *   -   min
                -   Minutes
                -   number
                -   0

            *   -   hour
                -   Hours
                -   number
                -   0

            *   -   day
                -   Day number
                -   number
                -   0

            *   -   week
                -   Week number
                -   number
                -   0

            *   -   month
                -   Month number
                -   number
                -   0

            *   -   year
                -   Year. ... [TBD year range and huge year number support]
                -   number
                -   0

            *   -   adjust
                -   ... [TBD]
                -   string
                -   'none'

    ..  _interval-new-example:

    **Examples:**

    ..  code-block:: tarantoolsession

        tarantool> datetime.interval.new()

        ---
        - 0 seconds
        ...

        tarantool> datetime.interval.new {
                    month = 6,
                    year = 1
                    }
        ---
        - +1 years, 6 months
        ...

        tarantool> datetime.interval.new {
                    day = -1
                    }
        ---
        - -1 days
        ...
