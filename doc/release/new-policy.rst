Release Policy Project
======================

Summary
-------

Tarantool release policy changes to become more clear and intuitive.
The new policy uses a `SemVer-like <https://semver.org/>`__ versioning format,
and introduces a new version lifecycle with more long-time support series.
This document explains the new release policy, versioning rules, and release series lifecycle.

The new release policy replaces :doc:`the legacy policy <release/policy>`
for the versions in 2.x.y series since 2.TBD.0,
and for the future major series ones (3.0.0+) as well.

The topics below describe the new versioning policy in more detail.

Versioning
----------

Production-ready (release) version labels consist of major, minor and patch numbers:

..  code-block:: text

    MAJOR.MINOR.PATCH

Versions in development and release candidates use the same pattern with an additional suffix:

..  code-block:: text

    MAJOR.MINOR.PATCH-<pre-release suffix>

There are four stages of development before a release:

#.  Alpha (``MAJOR.MINOR.PATCH-alphaN``)
#.  Beta (``MAJOR.MINOR.PATCH-betaN``)
#.  Release candidate (``MAJOR.MINOR.PATCH-rcN``)
#.  Nightly build (``MAJOR.MINOR.PATCH-dev``)

A release series goes through a set of alpha, beta and release candidate versions,
and eventually gets released.
For example:

..  code-block:: text

    3.2.0-alpha1
    3.2.0-alpha2
    ...
    3.2.0-alpha7
    3.2.0-beta1
    ...
    3.2.0-beta5
    3.2.0-rc1
    ...
    3.2.0-rc4
    3.2.0 (release)

Backwards compatibility is guaranteed between minor versions in the same major release series.
Also, it is appreciated but not guaranteed between different major numbers.
A detailed description of compatibility guarantees will be published later.

Changes
-------

There are several significant changes from the legacy release policy:

*   The third number in the version name doesn't distinguish between
    alpha, beta and release version anymore.

*   In the legacy release policy, 1.10 was a long-term support (LTS) series,
    while 2.x.y had "stable releases", but wasn't an LTS series.

    Now both series are long-term supported.
    The intended support time is at least two years.

A release series lifecycle
--------------------------

A release series goes over the following stages:

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::

        *   -   **Stage**
            -   **Versions to publish**
            -   **Example**

        *   -   Early development
            -   Alpha, beta, release candidate
            -   3

        *   -   Support
            -   Release candidate, release

        *   -   End of life
            -   N/A


The sections below describe those stages in detail.

A release series stages
-----------------------

Early development
~~~~~~~~~~~~~~~~~

The stage goes on until a first release. Alpha, beta versions and pre-releases
are published within this stage.

In fact, this stage splits into two phases: development of a new functionality
and its stabilization.

A premature functionality might be removed on the alpha/beta stage, but it will
not be removed after the publication of a release candidate.

Support
~~~~~~~

The stage starts when a first release is published. The release series now is
an object of only backward compatible changes.

At this stage, we're fixing all known security problems and fixing all found
degradations since the previous series.

A series receives degradation fixes and other bugfixes till the
end of life.

The decision of whether to fix a particular problem in a particular release series
is based on the impact of the problem, risks around backward compatibility and the
complexity of backporting a fix.

A release series might receive new features at this stage, but only in a
backward compatible manner. A release candidate might be published for a new
functionality before a release.

During the support period we're adding new versions of supported Linux distros
to our build infrastructure.

A support period might be extended.

See the **Delivery channels** section for information about a particular bug in the release
or about the resolve of a feature request.

End of life
~~~~~~~~~~~

A series reaches the end of life (EOL) when the last release in the series is
published. The series will not receive updates anymore.

In modules, connectors and tools, we don't guarantee support of a release series
that reaches EOL.

A release series cannot reach EOL until the vast majority of productions
(where we have commitments / SLA) will be updated to a newer series.

