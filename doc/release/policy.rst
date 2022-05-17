Tarantool release policy
========================

..  _release-policy:

Summary
-------

The Tarantool release policy is changing to become more clear and intuitive.
The new policy uses a `SemVer-like <https://semver.org/>`__ versioning format,
and introduces a new version lifecycle with more long-time support series.
This document explains the new release policy, versioning rules, and :term:`release series` lifecycle.

The new release policy replaces :doc:`the legacy policy </release/legacy-policy>`
for:

*   The ``2.x.y`` series since the ``2.10.0`` release.
    Development for this new release starts with version ``2.10.0-beta1``.
*   The future ``3.0.0`` series.

Here are the most significant changes from the legacy release policy:

*   The third number in the version label doesn't distinguish between
    pre-release (alpha and beta) and release versions.
    Instead, it is used for patch (bugfix-only) releases.
    Pre-release versions have suffixes, like ``3.0.0-alpha1``.

*   In the legacy release policy, ``1.10`` was a long-term support (LTS) series,
    while ``2.x.y`` had stable releases, but wasn't an LTS series.
    Now both series are long-term supported.

The topics below describe the new versioning policy in more detail.

Versioning policy
-----------------

Release series and versions
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The new Tarantool release policy is based on having several release series,
each with its own lifecycle, pre-release and release versions.

..  glossary::

    Release series

        Release series is a sequence of development and production-ready versions
        with linear evolution toward a defined roadmap.
        A series has a distinct lifecycle and certain compatibility guarantees within itself and with other series.
        The intended support time for each series is at least two years since the first release.

        At the moment when this document is published, there are two release series: series ``1.10`` and series ``2``.

    Release version

        Release version is a Tarantool distribution which is thoroughly tested and ready for production usage.
        It is bound to a certain commit.
        Release version label consists of three numbers:

        ..  code-block:: text

            MAJOR.MINOR.PATCH

These numbers correspond to the three types of release versions:

..  glossary::

    Major release

        Major release is the first :term:`release version <release version>` of its own
        :term:`release series <release series>`.
        It introduces new features and can have a few backward-incompatible changes.
        Such release changes the first version number:

        ..  code-block:: text

            MAJOR.0.0

            3.0.0

    Minor release

        Minor release introduces a few new features, but guarantees backward compatibility.
        There can be a few bugs fixed as well.
        Such release changes the second version number:

        ..  code-block:: text

            MAJOR.MINOR.0

            3.1.0
            3.2.0

    Patch release

        Patch release fixes bugs from an earlier release, but doesn't introduce new features.
        Such release changes the third version number:

        ..  code-block:: text

            MAJOR.MINOR.PATCH

            3.0.1
            3.0.2

Release versions conform to a set of requirements:

    *   The release has gone through pre-release testing and adoption
        in the internal projects until there were no doubts regarding its stability.

    *   There are no known bugs in the typical usage scenarios.

    *   There are no degradations from the previous release or release series, in case of a major release.

Backwards compatibility is guaranteed between all versions in the same release series.
It is also appreciated, but not guaranteed between different release series (major number changes).
See :doc:`compatibility guarantees page </release/compatibility>` for details.

Pre-release versions
~~~~~~~~~~~~~~~~~~~~

..  glossary::

    Pre-release version

        Pre-release versions are the ones published for testing and evaluation,
        and not intended for production use.
        Such versions use the same pattern with an additional suffix:

        ..  code-block:: text

            MAJOR.MINOR.PATCH-suffix

There are a few types of pre-release versions:

..  glossary::

    Development build

        Development builds reflect the state of current development process.
        They're used entirely for development and testing,
        and not intended for any external use.

        Development builds have suffixes made with ``$(git describe --always --long)-dev``:

        ..  code-block:: text

            MAJOR.MINOR.PATCH-describe-dev

            2.10.2-149-g1575f3c07-dev
            3.0.0-alpha1-14-gxxxxxxxxx-dev
            3.0.0-entrypoint-17-gxxxxxxxxx-dev
            3.1.2-5-gxxxxxxxxx-dev

    Alpha version

        Alpha version has some of the features planned in the release series.
        It can be incomplete or unstable, and can break the backwards compatibility
        with the previous release series.

        Alpha versions are published for early adopters and developers of dependent components,
        such as connectors and modules.

        ..  code-block:: text

            MAJOR.MINOR.PATCH-alphaN

            3.0.0-alpha1
            3.0.0-alpha2

    Beta version

        Beta version has all the features which are planned for the release series.
        It is a good choice to start developing a new application.

        Readiness of a feature can be checked in a beta version to decide whether to remove the feature,
        finish it later, or replace it with something else.
        A beta version can still have a known bug in the new functionality,
        or a known degradation since the previous release series that affects a common use case.

        ..  code-block:: text

            MAJOR.MINOR.PATCH-betaN

            3.0.0-beta1
            3.0.0-beta2

        Note that the development of ``2.10.0``, the first release under the new policy,
        starts with version ``2.10.0-beta1``.

    Release candidate

        Release candidate is used to fix bugs, mature the functionality,
        and collect feedback before an upcoming release.
        Release candidate has the same feature set as the preceding beta version
        and doesn't have known bugs in typical usage scenarios
        or degradations from the previous release series.

        Release candidate is a good choice to set up a staging server.

        ..  code-block:: text

            MAJOR.MINOR.PATCH-rcN

            3.0.0-rc1
            3.0.0-rc2
            3.0.1-rc1

..  _release-series-lifecycle:

Release series lifecycle
--------------------------

Every release series goes through the following stages:

..  contents::
    :local:

Early development
~~~~~~~~~~~~~~~~~

The early development stage goes on until the first :term:`major release <major release>`.
Alpha, beta, and release candidate versions are published at this stage.

The stage splits into two phases:

1.  Development of a new functionality through alpha and beta versions.
    Features can be added and, sometimes, removed in this phase.

2.  Stabilization starts with the first release candidate version.
    Feature set doesn't change in this phase.

Support
~~~~~~~

The stage starts when the first release is published.
The release series now is an object of only backward compatible changes.

At this stage, all known security problems and all found
degradations since the previous series are being fixed.

The series receives degradation fixes and other bugfixes during the support stage
and until the series transitions into the end of life (EOL) stage.

The decision of whether to fix a particular problem in a particular release series
depends on the impact of the problem, risks around backward compatibility, and the
complexity of backporting a fix.

The release series might receive new features at this stage,
but only in a backward compatible manner.
Also, a release candidate may be published to collect feedback before the release version.

During the support period a release series receives new versions of supported Linux
distributives to build infrastructure.

The intended duration of the support period for each series is at least two years.

End of life
~~~~~~~~~~~

A series reaches the end of life (EOL) when the last release in the series is
published. The series will not receive updates anymore.

In modules, connectors and tools, we don't guarantee support of any release series
that reaches EOL.

A release series cannot reach EOL until the vast majority of production environments,
for which we have commitments and SLAs, is updated to a newer series.


Versions per lifecycle stage
----------------------------

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :header-rows: 1

        *   -   Stage
            -   Version types
            -   Examples

        *   -   Early development
            -   Alpha, beta, release candidate

            -   ..  code-block:: text

                    3.0.0-alpha1
                    3.0.0-beta1
                    3.0.0-rc1
                    3.0.0-dev

        *   -   Support
            -   Release candidate, release

            -   ..  code-block:: text

                    3.0.0
                    3.0.1-rc1
                    3.0.1-dev

        *   -   End of life
            -   None
            -   N/A


Example of a release series
---------------------------

A release series in an early development stage can have
the following version sequence:

    ..  code-block:: text

        3.0.0-alpha1
        3.0.0-alpha2
        ...
        3.0.0-alpha7

        3.0.0-beta1
        ...
        3.0.0-beta5

        3.0.0-rc1
        ...
        3.0.0-rc4

        3.0.0 (release)

Since the first release version, the series comes into a support stage.
Then it can proceed with a version sequence like the following:

    ..  code-block:: text

        3.0.0 (release of a new major version)

        3.0.1-rc1
        ...
        3.0.1-rc4
        3.0.1 (release with some bugs fixed but no new features)

        3.1.0-rc1
        ...
        3.1.0-rc6
        3.1.0 (release with new features and, possibly, extra fixed bugs)

Eventually, the support stage stops and the release series comes to the
end of life (EOL) stage.
No new versions are released since then.

    ..  note::

        See all currently supported Tarantool versions visualised as :doc:`a calendar <calendar>`
        or as :ref:`a release lifetime table <release-table>`.
