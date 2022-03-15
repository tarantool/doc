Release policies
================

Since version 2.10, there's a :doc:`new release policy for Tarantool <policy>`.
In short, Tarantool version numbers consist of three parts:

..  code-block:: text

    MAJOR.MINOR.PATCH

Any version without extra prefixes is a release version.
If you need a version for production use, pick the latest release.
For evaluation and development, you can use beta versions.
They are marked with ``-betaN`` suffixes.

Before 2.10.0, version numbers were subject to the
:doc:`legacy versioning policy <legacy-policy>`:

..  code-block:: text

    MAJOR_VERSION.RELEASE_SERIES.RELEASE

..  toctree::
    :hidden:
    :maxdepth: 2

    policy
    legacy-policy
