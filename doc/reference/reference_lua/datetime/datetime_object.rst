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

        :return: table with the date and time parameters
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

    ..  method:: format( ['convensions'] )

        Convert the standard ``datetime`` object presentation into a formatted string.
        The formatting convension specifications are the same as in the `strftime <https://www.freebsd.org/cgi/man.cgi?query=strftime&sektion=3>`__ library.
        Additional convension for nanoseconds is `%f` which also allows a modifier to control the output precision of fractional part: `%5f` (see the example below).
        If no arguments are set for the method, the default convensions are used: `'%FT%T.%f%z'` (see the example below).

        :param string convensions: string consisting of zero or more conversion specifications and ordinary characters

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

    ..  method:: set( [{ units }] )

        Update the field values in the existing ``datetime`` object.

        :param table units: Table of time units. The :ref:`time units <datetime-new-args>` are the same as for the ``datetime.new()`` function.

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

    ..  _datetime-parse:

    ..  method:: parse( 'input_string'[, {format, tzoffset} ] )

        Convert an input string with the date and time information into a ``datetime`` object.
        The input string should be formatted according to one of the following standards:

        *   ISO 8601
        *   RFC 3339
        *   extended `strftime <https://www.freebsd.org/cgi/man.cgi?query=strftime&sektion=3>`__ -- see description of the :ref:`format() <datetime-format>` for details.

        :param string input_string: string with the date and time information.
        :param string format: indicator of the input_sting format. Possible values: 'iso8601', 'rfc3339', or ``strptime``-like format string.
                                If no value is set, the default formating  is used.
        :param number tzoffset: time zone offset from UTC, in minutes.

        :return: a datetime_object
        :rtype: cdata

        **Example:**

        ..  code-block:: tarantoolsession

            tarantool> t = datetime.parse('1970-01-01T00:00:00Z')

            tarantool> t
            ---
            - 1970-01-01T00:00:00Z
            ...

            tarantool> t = datetime.parse('1970-01-01T00:00:00', {format = 'iso8601', tzoffset = 180})

            tarantool> t
            ---
            - 1970-01-01T00:00:00+0300
            ...

            tarantool> t = datetime.parse('2017-12-27T18:45:32.999999-05:00', {format = 'rfc3339'})

            tarantool> t
            ---
            - 2017-12-27T18:45:32.999999-0500
            ...

            tarantool> T = datetime.parse('Thu Jan  1 03:00:00 1970', {format = '%c'})

            tarantool> T
            ---
            - 1970-01-01T03:00:00Z
            ...

            tarantool> T = datetime.parse('12/31/2020', {format = '%m/%d/%y'})

            tarantool> T
            ---
            - 2020-12-31T00:00:00Z
            ...

            tarantool> T = datetime.parse('1970-01-01T03:00:00.125000000+0300', {format = '%FT%T.%f%z'})

            tarantool> T
            ---
            - 1970-01-01T03:00:00.125+0300
            ...

