..  _sandbox_datetime_timezone:

Функции работы с датами и временем
==================================

..  _sandbox_datetime:

Datetime
--------

Модуль ``datetime`` содержит функции для работы с датой и временем.

..  module:: datetime

..  _sandbox_datetime-now:

..  function:: now()

    :return: текущее время по Гринвичу (GMT) в наносекундах
    :rtype: cdata

..  _sandbox_datetime-sec_to_iso_date:

..  function:: sec_to_iso_8601_date(sec)

    Преобразует число секунд в строковое представление даты.

    :param number sec: число секунд

    :return: дата в формате ISO 8601 вида ``yyyy-MM-dd``
    :rtype: string

..  _sandbox_datetime-nsec_to_iso_date:

..  function:: nsec_to_iso_8601_date(nsec)

    Преобразует число наносекунд в строковое представление даты.

    :param cdata nsec: число наносекунд

    :return: дата в формате ISO 8601 вида ``yyyy-MM-dd``
    :rtype: string

..  _sandbox_datetime-nsec_to_iso_datetime:

..  function:: nsec_to_iso_8601_datetime(nsec)

    Преобразует число наносекунд в строковое представление даты и времени.

    :param cdata nsec: число наносекунд

    :return: дата и время в формате ISO 8601 вида ``yyyy-MM-ddTHH:mm:ss.SSSZ``
    :rtype: string

..  _sandbox_datetime-nsec_to_iso_time:

..  function:: nsec_to_iso_8601_time(nsec)

    Преобразует заданную в наносекундах дату и время в строковое представление времени.

    :param cdata nsec: число наносекунд

    :return: время в формате ISO 8601 вида ``HH:mm:ss.SSS``
    :rtype: string

..  _sandbox_datetime-nsec_to_week:

..  function:: nsec_to_day_of_week(nsec)

    Возвращает день недели для заданной в наносекундах даты и времени.

    :param cdata nsec: число наносекунд

    :return: день недели в формате числа от 1 до 7, где ``1`` -- воскресенье, а ``7`` -- суббота
    :rtype: number

..  _sandbox_datetime-iso_datetime_to_nsec:

..  function:: iso_8601_datetime_to_nsec(iso_8601_datetime)

    Преобразует строковое представление даты и времени в наносекунды.

    :param string iso_8601_datetime: дата и время в формате ISO 8601. Доступные форматы строки:

                                     *   ``yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ``

                                     *   ``yyyy-MM-dd'T'HH:mm:ssZZZZZ``

                                     *   ``yyyy-MM-dd'T'HH:mm:ss``

                                     *   ``yyyy-MM-dd'T'HHmmss.SZZZZZ``

                                     *   ``yyyy-MM-dd'T'HHmmssZZZZZ``

                                     *   ``yyyy-MM-dd'T'HHmmss.SSS``

                                     *   ``yyyy-MM-dd'T'HHmmss``

    :return: число наносекунд
    :rtype: cdata

..  _sandbox_datetime-iso_date_to_nsec:

..  function:: iso_8601_date_to_nsec(iso_8601_date)

    Преобразует строковое представление даты в наносекунды.

    :param string iso_8601_date: дата в формате ISO 8601 вида ``yyyy-MM-dd``

    :return: число наносекунд
    :rtype: cdata

..  _sandbox_datetime-iso_time_to_nsec:

..  function:: iso_8601_time_to_nsec(iso_8601_time)

    Преобразует строковое представление времени в наносекунды.

    :param string iso_8601_time: время в формате ISO 8601. Доступные форматы: ``HH:mm:ss.SSS``, ``HH:mm:ss``.

    :return: число наносекунд
    :rtype: cdata

..  _sandbox_datetime-iso_week_to_number:

..  function:: iso_8601_day_of_week_to_number(iso_8601_day_of_week)

    Преобразует строковое представление дня недели в число от 1 до 7, где ``1`` -- воскресенье, а ``7`` -- суббота.

    :param string iso_8601_day_of_week: день недели в формате ISO 8601 (например, "Sunday", "Sun", "Su")

    :return: число от 1 до 7
    :rtype: number

..  _sandbox_datetime-custom_dt_to_nsec:

..  function:: custom_datetime_str_to_nsec(date_str, format_str)

    Преобразует заданное шаблоном строковое представление даты или даты и времени в наносекунды.

    :param string date_str: дата или дата и времени
    :param string format_str: шаблон строки

    :return: число наносекунд
    :rtype: cdata

..  _sandbox_datetime-millisec_to_formatted_dt:

..  function:: millisec_to_formatted_datetime(datetime_millisec, datetime_format_str)

    Преобразует миллисекунды в заданное шаблоном строковое представление даты и времени.

    :param number datetime_millisec: время в миллисекундах
    :param string datetime_format_str: шаблон строки даты и времени

    :return: дата и время, заданные шаблоном
    :rtype: string

..  _sandbox_datetime-to_sec:

..  function:: to_sec(nsec)

    Преобразует наносекунды в секунды и приводит к типу number.

    :param cdata nsec: число наносекунд

    :return: число секунд
    :rtype: number

..  _sandbox_datetime-to_millisec:

..  function:: to_millisec(nsec)

    Преобразует наносекунды в миллисекунды и приводит к типу number.

    :param cdata nsec: число наносекунд

    :return: число миллисекунд
    :rtype: number

..  _sandbox_datetime-sec_since_midnight:

..  function:: seconds_since_midnight()

    :return: число секунд с начала суток по Гринвичу (GMT)
    :rtype: number

..  _sandbox_datetime-curr_dt_nsec:

..  function:: curr_date_nsec()

    :return: Unix timestamp в наносекундах
    :rtype: cdata

..  _sandbox_datetime-const:

Набор констант, которые используются для работы со временем:

*   ``NSEC_IN_SEC`` -- число наносекунд в секунде;

*   ``NSEC_IN_MILLISEC`` -- число наносекунд в миллисекунде;

*   ``NSEC_IN_DAY`` -- число наносекунд в сутках.

..  _sandbox_timezone:

Timezone
--------

Модуль ``timezone`` содержит функции для работы с часовыми поясами.

..  module:: timezone

..  _sandbox_timezone-now:

..  function:: now()

    :return: текущее время по Гринвичу (GMT) в наносекундах
    :rtype: cdata

..  _sandbox_timezone-sec_since_midnight:

..  function:: seconds_since_midnight(timezone_id)

    :param string timezone_id: ID часового пояса

    :return: число секунд с начала текущих суток для указанного часового пояса
    :rtype: number

..  _sandbox_timezone-curr_dt_nsec:

..  function:: curr_date_nsec(timezone_id)

    :param string timezone_id: ID часового пояса

    :return: Unix timestamp в наносекундах
    :rtype: cdata