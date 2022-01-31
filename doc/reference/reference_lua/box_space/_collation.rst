.. _box_space-collation:

===============================================================================
box.space._collation
===============================================================================

.. module:: box.space

.. data:: _collation

    ``_collation`` is a system space with a list of :ref:`collations <index-collation>`.
    There are over 270 built-in collations and users may add more. Here is one example:

    .. code-block:: tarantoolsession

        tarantool> box.space._collation:select(239)
        ---
        - - [239, 'unicode_uk_s2', 1, 'ICU', 'uk', {'strength': 'secondary'}]
        ...

    Explanation of the fields in the example: id = 239 i.e. Tarantool's primary key is 239,
    name = 'unicode_uk_s2' i.e. according to Tarantool's naming convention this is a
    Unicode collation + it is for the uk locale + it has secondary strength,
    owner = 1 i.e. :ref:`the admin user <authentication-owners_privileges>`,
    type = 'ICU' i.e. the rules are according to `International Components for Unicode <http://site.icu-project.org/home>`_,
    locale = 'uk' i.e. `Ukrainian <http://www.unicode.org/cldr/charts/29/collation/uk.html>`_,
    opts = 'strength:secondary' i.e. with this collation comparisons use both primary and secondary
    `weights <https://unicode.org/reports/tr10/#Weight_Level_Defn>`_.

    The :ref:`system space view <box_space-sysviews>` for ``_collation`` is ``_vcollation``.
