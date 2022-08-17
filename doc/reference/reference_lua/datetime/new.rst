..  _datetime-new:

datetime.new()
==============

..  function:: datetime.new( [{ units }] )

    Since :doc:`2.10.0 </release/2.10.0>`.

    Create an object of the :ref:`datetime type <index-box_datetime>` from a table of time units.
    See :ref:`description of units <datetime-new-args>` and :ref:`examples <datetime-new-example>` below.

    :param table units: Table of :ref:`time units <datetime-new-args>`.
                                If an empty table or no arguments are passed, the ``datetime`` object with the default values corresponding to Unix Epoch is created: ``1970-01-01T00:00:00Z``.

    :return: :doc:`datetime object <./datetime/datetime_object>`
    :rtype: cdata

    ..  _datetime-new-args:

    **Possible input time units for ``datetime.new()``**

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
                -   Seconds. Value range: 0 - 60.
                -   number
                -   0

            *   -   min
                -   Minutes. Value range: 0 - 59.
                -   number
                -   0

            *   -   hour
                -   Hours. Value range: 0 - 23.
                -   number
                -   0

            *   -   day
                -   Day number. Value range: 1 - 31. The special value ``-1`` generates the last day of a particular month (see :ref:`example below <datetime-new-example>`).
                -   number
                -   1

            *   -   month
                -   Month number. Value range: 1 - 12.
                -   number
                -   1

            *   -   year
                -   Year.
                -   number
                -   1970

            *   -   timestamp
                -   Timestamp, in seconds. Similar to the Unix timestamp, but can have a fractional part which is converted in nanoseconds in the resulting ``datetime`` object.
                    If the fractional part for the last second is set via the ``nsec``, ``usec``, or ``msec`` units, the timestamp value should be integer otherwise an error occurs.
                    Timestamp is not allowed if you already set time and/or date via specific units, namely, ``sec``, ``min``, ``hour``, ``day``, ``month``, and ``year``.
                -   number
                -   0

            *   -   tzoffset
                -   Time zone offset from UTC, in minutes. If both ``tzoffset`` and ``tz`` are specified, ``tz`` has the preference and the ``tzoffset`` value is ignored.
                -   number
                -   0

            *   -   tz
                -   Time zone name according to the `tz database <https://en.wikipedia.org/wiki/Tz_database>`__.
                -   string
                -   -

    ..  _datetime-new-example:

    **Examples:**

    ..  code-block:: tarantoolsession

        tarantool> datetime.new {
                    nsec = 123456789,

                    sec = 20,
                    min = 25,
                    hour = 18,

                    day = 20,
                    month = 8,
                    year = 2021,

                    tzoffset  = 180
                    }
        ---
        - 2021-08-20T18:25:20.123456789+0300
        ...

        tarantool> datetime.new {
                    nsec = 123456789,

                    sec = 20,
                    min = 25,
                    hour = 18,

                    day = 20,
                    month = 8,
                    year = 2021,

                    tzoffset = 60,
                    tz = Europe/Moscow
                    }
        ---
        - 2021-08-20T18:25:20.123456789 Europe/Moscow
        ...

        tarantool> datetime.new {
                    day = -1,
                    month = 2,
                    year = 2021,
                    }
        ---
        - 2021-02-28T00:00:00Z
        ...

        tarantool> datetime.new {
                    timestamp = 1656664205.123,
                    tz = 'Europe/Moscow'
                    }
        ---
        - 2022-07-01T08:30:05.122999906 Europe/Moscow
        ...

        tarantool> datetime.new {
                    nsec = 123,
                    timestamp = 1656664205,
                    tz = 'Europe/Moscow'
                    }
        ---
        - 2022-07-01T08:30:05.000000123 Europe/Moscow
        ...
