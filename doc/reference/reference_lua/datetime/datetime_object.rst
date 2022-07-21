.. _datetime_object:

datetime_object
===============

..  class:: datetime_object

    Since :doc:`2.10.0 </release/2.10.0>`.

    ..  _datetime-totable:

    ..  method:: totable()

        Export a table with the date and time parameters taken from the ``datetime`` object values.
        Additional parameters ``wday``, ``yday``, and ``isdst`` are as in :ref:`os.date() <os-date>`.

        :return: table with the date and time parameters
        :rtype: table

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

            tarantool> dt:totable()
            ---
            - sec: 20
              min: 25
              yday: 232
              day: 20
              nsec: 123456789
              isdst: false
              wday: 6
              tzoffset: 180
              month: 8
              year: 2021
              hour: 18
            ...


    ..  _datetime-format:

    ..  method:: format( ['format units'] )

        Convert standard ``datetime`` object presentation into a formatted string based on the format notation according to the FreeBSD/Olson ``strftime``.


        :return: formatted string with the date and time information
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

            tarantool> dt:format('%d.%m.%y %H:%M:%S')
            ---
            - 20.08.21 18:25:20
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
