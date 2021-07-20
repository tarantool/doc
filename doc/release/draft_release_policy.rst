Release Policy Project
======================

Summary
-------

To make Tarantool builds' identification more clear and intuitive, the versioning policy for stable
releases is changing.
It will take effect for builds starting with 2.TBD.0 numbers and for future major series ones (3.0.0+) as well.

The new version numbering scheme will replace
`the legacy policy <https://www.tarantool.io/en/doc/1.10/dev_guide/release_management/>`_.
It changes to the semver-like format.
For releases Tarantool version numbers now consist of three parts, major, minor and patch:

..  code-block:: text

    MAJOR.MINOR.PATCH

For pre-releases the numbering now consists of three digits and additional suffix:

..  code-block:: text

    MAJOR.MINOR.PATCH-<pre-release suffix>

Suffixes ``-alphaN``, ``-betaN``, ``-rcN`` and ``-dev`` explicitly mark pre-releases and
developer builds so that users could avoid installing these versions on production systems.
Backwards compatibility is guaranteed between minor builds in the same major release series.
Also, it is appreciated but not guaranteed between different major numbers.

We don't distinguish now between two kinds of stable release series, as we're going to make
all of them a kind of 'long term supported'. They will be supported for at least two years.

The topics below describe the new versioning policy in great detail.

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

