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

For example, the version label is ``3.1.2``:

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::

        *   -   3
            -   release series, major version

        *   -   3.1
            -   feature set, the minor version is
                increased with new features

        *   -   3.1.2, 3.1.3
            -   releases, might differ by fixed bugs




Versions in development and release candidates use the same pattern with an additional suffix:

..  code-block:: text

    MAJOR.MINOR.PATCH-<pre-release suffix>

There are four types of suffixes in versions before a release:

#.  Alpha (``MAJOR.MINOR.PATCH-alphaN``)
#.  Beta (``MAJOR.MINOR.PATCH-betaN``)
#.  Release candidate (``MAJOR.MINOR.PATCH-rcN``)
#.  Nightly build (``MAJOR.MINOR.PATCH-dev``)

A release series goes through a set of alpha, beta and release candidate versions
and eventually gets released. During early development, there are alpha, beta and release candidates.
Also, a release candidate can be published during the support stage (``3.2.0-rcN``).

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


Nightly builds are marked this way: ``git describe --always --long-dev``.
Together with the development flow, it gives names like so:
``3.0.0-alpha1-14-gxxxxxxxxx-dev``,
``3.1.2-5-gxxxxxxxxx-dev``,
``3.0.0-entrypoint-17-gxxxxxxxxx-dev``.

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
    The intended support time is at least two years since the first release.

A release series lifecycle
--------------------------

A release series goes over the following stages:

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::

        *   -   **Stage**
            -   **Versions to publish**

        *   -   Early development
            -   Alpha, beta, release candidate

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

End of life
~~~~~~~~~~~

A series reaches the end of life (EOL) when the last release in the series is
published. The series will not receive updates anymore.

In modules, connectors and tools, we don't guarantee support of a release series
that reaches EOL.

A release series cannot reach EOL until the vast majority of productions
(where we have commitments / SLA) will be updated to a newer series.

Version string meaning
----------------------

Nightly build
~~~~~~~~~~~~~

These versions are not supposed to be used by customers. A version string
contains ``-dev`` postfix.

Alpha
~~~~~

An alpha version is for early adopters and developers of dependent components
(such as connectors and modules).

It is an early stage of a release series. The functionality might be incomplete or
unstable.

Beta
~~~~

A beta version is good to start developing a new application.

We begin publishing beta versions when all functionality planned for the release series becomes implemented.

At this point, we can reevaluate the readiness of a feature and decide to remove it from the series, finish it later
or replace it with something else.

A beta version might have a known bug in the new functionality or a known degradation since a previous release
series that affects a common use case, unlike a release candidate.

Release candidate
~~~~~~~~~~~~~~~~~

A release candidate fits good to setup a staging server.

There are two kinds of a release candidate. First, during early
development, when the series goes to be mature enough. Second, on the support
stage, to collect feedback before an upcoming release.

The key difference between beta and release candidate is the maturity of the new
functionality. The formal rules are:

*   No known bugs in typical usage scenarios for new functionality.
*   No known degradations since a previous release series.

Release
~~~~~~~

A release is a version that is ready for production usage.

The requirements are the same as for a release candidate. Aside from this, we might perform extra pre-release
testing and adoption in our internal projects if there are doubts regarding stability.
