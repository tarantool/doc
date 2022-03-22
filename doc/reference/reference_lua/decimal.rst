.. _decimal:

-------------------------------------------------------------------------------
                            Module decimal
-------------------------------------------------------------------------------

.. module:: decimal

The ``decimal`` module has functions for working with
exact numbers. This is important when numbers are large
or even the slightest inaccuracy is unacceptable.
For example Lua calculates ``0.16666666666667 * 6``
with floating-point so the result is 1.
But with the decimal module (using ``decimal.new``
to convert the number to decimal type) 
``decimal.new('0.16666666666667') * 6`` is 1.00000000000002.

To construct a decimal number, bring in the module with
``require('decimal')`` and then use ``decimal.new(n)``
or any function in the decimal module:

* :ref:`abs(n) <decimal-abs>`
* :ref:`exp(n) <decimal-exp>`
* :ref:`is_decimal(n) <decimal-is_decimal>`
* :ref:`ln(n) <decimal-ln>`
* :ref:`log10(n) <decimal-log10>`
* :ref:`new(n) <decimal-new>`
* :ref:`precision(n) <decimal-precision>`
* :ref:`rescale(decimal-number, new-scale) <decimal-rescale>`
* :ref:`scale(n) <decimal-scale>`
* :ref:`sqrt(n) <decimal-sqrt>`
* :ref:`trim(decimal-number) <decimal-trim>`,

where n can be a string or a non-decimal number or a decimal number.
If it is a string or a non-decimal number,
Tarantool converts it to a decimal number before
working with it.
It is best to construct from strings, and to convert
back to strings after calculations, because Lua numbers
have only 15 digits of precision. Decimal numbers have
38 digits of precision, that is, the total number of digits
before and after the decimal point can be 38.
Tarantool supports the usual arithmetic and comparison operators
+ - * / % ^ < > <= >= ~= ==.
If an operation has both decimal and non-decimal operands,
then the non-decimal operand is converted to decimal before
the operation happens.

Use ``tostring(decimal-number)`` to convert back to a string.

A decimal operation will fail if overflow happens (when a
number is greater than 10^38 - 1 or less than -10^38 - 1).
A decimal operation will fail if arithmetic is impossible
(such as division by zero or square root of minus 1).
A decimal operation will not fail if rounding of
post-decimal digits is necessary to get 38-digit precision.

.. _decimal-abs:

.. function:: abs(string-or-number-or-decimal-number)

    Returns absolute value of a decimal number.
    For example if ``a`` is ``-1`` then ``decimal.abs(a)`` returns ``1``.

.. _decimal-exp:

.. function:: exp(string-or-number-or-decimal-number)

    Returns *e* raised to the power of a decimal number.
    For example if ``a`` is ``1`` then ``decimal.exp(a)`` returns
    ``2.7182818284590452353602874713526624978``.
    Compare ``math.exp(1)`` from the
    `Lua math library <https://www.lua.org/pil/18.html>`_,
    which returns ``2.718281828459``.

.. _decimal-is_decimal:

.. function:: is_decimal(string-or-number-or-decimal-number)

    Returns ``true`` if the specified value is a decimal, and ``false`` otherwise.
    For example if ``a`` is ``123`` then ``decimal.is_decimal(a)`` returns ``false``. 
    if ``a`` is ``decimal.new(123)`` then ``decimal.is_decimal(a)`` returns ``true``. 

.. _decimal-ln:

.. function:: ln(string-or-number-or-decimal-number)

    Returns natural logarithm of a decimal number.
    For example if ``a`` is ``1`` then ``decimal.ln(a)`` returns ``0``.

.. _decimal-log10:

.. function:: log10(string-or-number-or-decimal-number)

    Returns base-10 logarithm of a decimal number.
    For example if ``a`` is ``100`` then ``decimal.log10(a)`` returns ``2``.

.. _decimal-new:

.. function:: new(string-or-number-or-decimal-number)

    Returns the value of the input as a decimal number.
    For example if ``a`` is ``1E-1`` then
    ``decimal.new(a)`` returns ``0.1``.

.. _decimal-precision:

.. function:: precision(string-or-number-or-decimal-number)

    Returns the number of digits in a decimal number.
    For example if ``a`` is ``123.4560`` then ``decimal.precision(a)`` returns ``7``.

.. _decimal-rescale:

.. function:: rescale(decimal-number, new-scale)

    Returns the number after possible rounding or padding.
    If the number of post-decimal digits is greater than new-scale,
    then rounding occurs. The rounding rule is: round half away from zero.
    If the number of post-decimal digits is less than new-scale,
    then padding of zeros occurs.
    For example if ``a`` is ``-123.4550`` then ``decimal.rescale(a, 2)`` 
    returns ``-123.46``, and ``decimal.rescale(a, 5)`` returns ``-123.45500``.

.. _decimal-scale:

.. function:: scale(string-or-number-or-decimal-number)

    Returns the number of post-decimal digits in a decimal number.
    For example if ``a`` is ``123.4560`` then ``decimal.scale(a)`` returns ``4``.

.. _decimal-sqrt:

.. function:: sqrt(string-or-number-or-decimal-number)

    Returns the square root of a decimal number.
    For example if ``a`` is ``2`` then ``decimal.sqrt(a)`` returns 
    ``1.4142135623730950488016887242096980786``.

.. _decimal-trim:

.. function:: trim(decimal-number)

    Returns a decimal number after possible removing of trailing post-decimal zeros.
    For example if ``a`` is ``2.20200`` then ``decimal.trim(a)`` returns ``2.202``. 

