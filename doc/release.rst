..  _release_notes:

********************************************************************************
Release notes
********************************************************************************

Since version 2.10, there's a :doc:`new release policy for Tarantool <release/policy>`.
In short, Tarantool version numbers consist of three parts:

..  code-block:: text

    MAJOR.MINOR.PATCH

Any version without extra prefixes is a release version.
If you need a version for production use, pick the latest release.
For evaluation and development, you can use beta versions.
They are marked with ``-betaN`` suffixes.

Before 2.10.0, version numbers were subject to the
:doc:`legacy versioning policy <release/legacy-policy>`:

..  code-block:: text

    MAJOR_VERSION.RELEASE_SERIES.RELEASE

Below is the table listing all Tarantool versions starting from 1.10.0 up to
the current latest versions.
Each link leads to the release notes page of the corresponding version:

..  _release-list:

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2
    ..  rst-class:: left-align-column-3
    ..  rst-class:: left-align-column-4

    ..  list-table::

        *   -   Release Series
            -   Alpha
            -   Beta
            -   Release

        *   -   2.10
            -   n/a
            -   :doc:`2.10.0-beta1 <release/2021-08-releases>`
            -   not released yet

        *   -   2.8
            -   2.8.0
            -   :doc:`2.8.1 <release/2.8.1>`
            -   :doc:`2.8.2 <release/2021-08-releases>`

        *   -   2.7
            -   2.7.0
            -   :doc:`2.7.1 <release/2.7.1>`
            -   :doc:`2.7.2 <release/2.7.2>`, :doc:`2.7.3 <release/2021-08-releases>`

        *   -   2.6
            -   2.6.0
            -   :doc:`2.6.1 <release/2.6.1>`
            -   :doc:`2.6.2 <release/2.6.2>`,
                :doc:`2.6.3 <release/2.6.3>`

        *   -   2.5
            -   2.5.0
            -   :doc:`2.5.1 <release/2.5.1>`
            -   :doc:`2.5.2 <release/2.5.2>`,
                :doc:`2.5.3 <release/2.5.3>`

        *   -   2.4
            -   2.4.0
            -   :doc:`2.4.1 <release/2.4.1>`
            -   :doc:`2.4.2 <release/2.4.2>`,
                :doc:`2.4.3 <release/2.4.3>`

        *   -   2.3
            -   2.3.0
            -   :doc:`2.3.1 <release/2.3.1>`
            -   :doc:`2.3.2 <release/2.3.2>`,
                :doc:`2.3.3 <release/2.3.3>`

        *   -   2.2
            -   2.2.0
            -   :doc:`2.2.1 <release/2.2.1>`
            -   :doc:`2.2.2 <release/2.2.2>`,
                :doc:`2.2.3 <release/2.2.3>`


        *   -   1.10 (LTS series)
            -   1.10.0
            -   1.10.1
            -   :ref:`1.10.2 <whats_new_1102>`,
                :ref:`1.10.3 <whats_new_1103>`,
                :ref:`1.10.4 <whats_new_1104>`,
                :doc:`1.10.5 <release/1.10.5>`,
                :doc:`1.10.6 <release/1.10.6>`,
                :doc:`1.10.7 <release/1.10.7>`,
                :doc:`1.10.8 <release/1.10.8>`,
                :doc:`1.10.9 <release/1.10.9>`,
                :doc:`1.10.10 <release/1.10.10>`,
                :doc:`1.10.11 <release/2021-08-releases>`


For smaller feature changes and bug fixes, see closed
`milestones <https://github.com/tarantool/tarantool/milestones?state=closed>`_
at GitHub.

Release notes for series before 1.10 are also available:

*   :doc:`release/1.9`
*   :doc:`release/1.8`
*   :doc:`release/1.7`
*   :doc:`release/1.6`

..  toctree::
    :hidden:

    release/policy
    release/legacy-policy
    release/major-features
    release/2021-08-releases
    release/2.8.1
    release/2.7.2
    release/2.7.1
    release/2.6.3
    release/2.6.2
    release/2.6.1
    release/2.5.3
    release/2.5.2
    release/2.5.1
    release/2.4.3
    release/2.4.2
    release/2.4.1
    release/2.3.3
    release/2.3.2
    release/2.3.1
    release/2.2.3
    release/2.2.2
    release/2.2.1
    release/2.1.2
    release/1.10.10
    release/1.10.9
    release/1.10.8
    release/1.10.7
    release/1.10.6
    release/1.10.5
    release/1.10
    release/1.9
    release/1.8
    release/1.7
    release/1.6
