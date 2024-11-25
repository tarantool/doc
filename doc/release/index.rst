:noindex:
:fullwidth:

..  _release:

Releases
========

This section contains information about Tarantool releases: release notes, lifecycle
information, release policy, and other documents.
To download Tarantool releases, check the `Download <https://www.tarantool.io/en/download/>`_ page.

All currently supported versions are listed on this page :ref:`below <release-supported-versions>`.
The information about earlier versions is provided in :ref:`release-eol-versions`.

The Enterprise Edition of Tarantool is distributed in the form of an SDK that has
its own versioning. See the :ref:`release-enterprise-changelog` to learn about
SDK version numbering and changes.

The detailed information about Tarantool version numbering and release lifecycle
is available in :ref:`release-policy`.

Backward compatibility is guaranteed between all versions in the same :term:`release series`.
It is also appreciated but not guaranteed between different release series (major number changes).
To learn more, read the :doc:`Compatibility guarantees <compatibility>` article.

..  _release-supported-versions:

Supported versions
------------------

Every Tarantool release series has :ref:`the same lifecycle <release-series-lifecycle>`
defined by the release policy. The following diagram visualizes the lifecycle of currently
supported Tarantool versions:

.. image:: _images/releases_calendar.svg
    :align: center
    :alt: Release calendar

The table below provides information about supported versions with links to their
*What's new* pages in the documentation and detailed changelogs on GitHub.
For information about earlier versions, see :doc:`eol_versions`.

.. note::

    *End of life* (*EOL*) means the release series will no longer receive any patches,
    updates, or feature improvements after the specified date. Versions that haven't
    reached their end of life yet are shown in **bold**.

    *End of support* (*EOS*) means that we won't provide technical support to product
    versions after the specified date.

..  container:: table

    ..  list-table::
        :header-rows: 1

        *   -   Series
            -   First release date
            -   End of life
            -   End of support
            -   Versions

        *   -   :doc:`3.2 </release/3.2.0>`
            -   **August 26, 2024**
            -   **August 26, 2026**
            -   **Not planned yet**
            -   | :tarantool-release:`3.2.1`
                | :tarantool-release:`3.2.0`

        *   -   :doc:`3.1 </release/3.1.0>`
            -   **April 16, 2024**
            -   **April 16, 2026**
            -   **Not planned yet**
            -   | :tarantool-release:`3.1.2`
                | :tarantool-release:`3.1.1`
                | :tarantool-release:`3.1.0`

        *   -   :doc:`3.0 </release/3.0.0>`
            -   **December 26, 2023**
            -   **December 26, 2025**
            -   **Not planned yet**
            -   | :tarantool-release:`3.0.2`
                | :tarantool-release:`3.0.1`
                | :tarantool-release:`3.0.0`

        *   -   :doc:`2.11 LTS </release/2.11.0>`
            -   **May 24, 2023**
            -   **May 24, 2025**
            -   **Not planned yet**
            -   | :tarantool-release:`2.11.5`
                | :tarantool-release:`2.11.4`
                | :tarantool-release:`2.11.3`
                | :tarantool-release:`2.11.2`
                | :tarantool-release:`2.11.1`
                | :tarantool-release:`2.11.0`

        *   -   2.10
            -   May 22, 2022
            -   September 14, 2023
            -   Not planned yet
            -   | :doc:`2.10.8 </release/2.10.8>`
                | :doc:`2.10.7 </release/2.10.7>`
                | :doc:`2.10.6 </release/2.10.6>`
                | :doc:`2.10.5 </release/2.10.5>`
                | :doc:`2.10.4 </release/2.10.4>`
                | :doc:`2.10.3 </release/2.10.3>`
                | :doc:`2.10.2 </release/2.10.2>`
                | :doc:`2.10.1 </release/2.10.1>`
                | :doc:`2.10.0 </release/2.10.0>`

        *   -   2.8
            -   August 19, 2021
            -   April 25, 2022
            -   December 31, 2024
            -   | :doc:`2.8.4 </release/2.8.4>`
                | :doc:`2.8.3 </release/2.8.3>`
                | :doc:`2.8.2 </release/2.8.2>`

..  toctree::
    :maxdepth: 1

    3.2.0
    3.1.0
    3.0.0
    2.11.0
    eol_versions
    enterprise-changelog
    policy
    compatibility
