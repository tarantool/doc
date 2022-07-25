.. _datetime_object:

datetime_object
===============

..  class:: datetime_object

    Since :doc:`2.10.0 </release/2.10.0>`.

    ..  _datetime-totable:

    ..  method:: totable()

        Convert the information from the ``datetime`` object into the table format.
        Resulting table has the following fields:

        ..  container:: table

            ..  list-table::
                :widths: 30 70
                :header-rows: 1

                *   -   Field name
                    -   Description

                *   -   nsec
                    -   Nanosecods

                *   -   sec
                    -   Seconds

                *   -   min
                    -   Minutes

                *   -   hour
                    -   Hours

                *   -   day
                    -   Day number

                *   -   month
                    -   Month number

                *   -   year
                    -   Year

                *   -   wday
                    -   Days since the beginning of the week

                *   -   yday
                    -   Days since the beginning of the year

                *   -   isdst
                    -   Is the DST (Daylight saving time) applicable for the date. Boolean.

                *   -   tzoffset
                    -   Time zone offset from UTC

        :return: table with the date and time parameters [TBD - description]
        :rtype: table

        **Example:**

        ..  code-block:: tarantoolsession

            tarantool> dt = datetime.new {
                        sec = 20,
                        min = 25,
                        hour = 18,

                        day = 20,
                        month = 8,
                        year = 2021,
                        }
            ---
            ...

            tarantool> dt:totable()
            ---
            - sec: 20
              min: 25
              yday: 232
              day: 20
              nsec: 0
              isdst: false
              wday: 6
              tzoffset: 0
              month: 8
              year: 2021
              hour: 18
            ...

    ..  _datetime-format:

    ..  method:: format( ['convension_specifications'] )

        Convert the standard ``datetime`` object presentation into a formatted string.
        The formatting convension specifications are the same as in the `FreeBSD strftime <https://www.freebsd.org/cgi/man.cgi?query=strftime&sektion=3>`__.
        Additional convension for nanoseconds is `%f` which also allows a modifier to control the output precision of fractional part: `%5f` (see the example below).
        If no arguments are set for the method, the default convensions are used: `'%FT%T.%f%z'` (see the example below).

        :param string convension_specifications: string consisting of zero or more conversion specifications and ordinary characters

        :return: string with the formatted date and time information
        :rtype: string

        **Example:**

        ..  code-block:: tarantoolsession

            tarantool> dt = datetime.new {
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
            ...

            tarantool> dt:format('%d.%m.%y %H:%M:%S.%5f')
            ---
            - 20.08.21 18:25:20.12345
            ...

            tarantool> dt:format()
            ---
            - 2021-08-20T18:25:20.123456789+0300
            ...

            tarantool> dt:format('%FT%T.%f%z')
            ---
            - 2021-08-20T18:25:20.123456789+0300
            ...

    ..  _datetime-set:

    ..  method:: set( [{ time_units }] )

        Update the field values in the existing ``datetime`` object.

        :param table time_units: Table of time units. The :ref:`time units <datetime-new-args>` are the same as for the ``datetime.new()`` function.

        :return: updated datetime_object
        :rtype: cdata

        **Example:**

        ..  code-block:: tarantoolsession

            tarantool> dt = datetime.new {
                        nsec = 123456789,

                        sec = 20,
                        min = 25,
                        hour = 18,

                        day = 20,
                        month = 8,
                        year = 2021,

                        tzoffset  = 180
                        }

            tarantool> dt:set {msec = 567}
            ---
            - 2021-08-20T18:25:20.567+0300
            ...

            tarantool> dt:set {tzoffset = 60}
            ---
            - 2021-08-20T18:25:20.567+0100
            ...
