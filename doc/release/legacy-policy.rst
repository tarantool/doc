Tarantool legacy release policy
===============================

.. important::

    This page describes the release policy that was used for Tarantool versions **before 2.10.0**.

    For information about the current release policy, see :ref:`release-policy`.

A Tarantool release is identified by three digits, for example, 2.6.2 or 1.10.9:

*   The first digit stands for a MAJOR release series that introduces
    some *major changes*. Up to now, there has been only one major release jump
    when we delivered the 2.x release series with the SQL support.
*   The second digit stands for a MINOR release series that is used for
    introducing new *features*.
    :ref:`Backward incompatible changes <backward-incompatible>`
    are possible between these release series.
*   The third digit is for PATCH releases by which we reflect how stable
    the MINOR release series is:

    * ``0`` meaning **alpha**
    * ``1`` meaning **beta**
    * ``2`` and above meaning **release** (earlier known as **stable**).

So, each MINOR release series goes through a development-maturity life cycle
as follows:

1.  **Alpha**. Once a quarter, we start off with a new alpha version,
    such as 2.3.0, 2.4.0, and so on. This is not what an alpha release usually
    means in the typical software release life cycle but rather the current trunk
    version which is under heavy development and can be unstable.
    The current alpha version always lives in the master branch.

2.  **Beta**. When all the features planned are implemented, we fork a new branch
    from the master branch and tag it as a new beta version.
    It contains ``1`` for the PATCH digit, e.g., 2.3.1, 2.4.1, and so on.
    This version cannot be called stable yet (feature freeze has just been done)
    although there are no known critical regressions in it since
    the last stable release.

3.  **Release** (earlier known as **stable**).
    Finally, after we see our beta version runs successfully in
    a production or development environment during another quarter while we fix
    incoming bugs, we declare this version stable. It is tagged with ``2`` for
    the PATCH digit, e.g., 2.3.2, 2.4.2, and so on.

    We support such version for 3 months while making another stable release
    by fixing all bugs found. We release it in a quarter. This last tag
    contains ``3`` for the PATCH digit, e.g., 2.3.3, 2.4.3, and so on.
    After the tag is set, no new changes are allowed to the release branch,
    and it is declared deprecated and superseded by a newer MINOR version.

    Release versions don't receive any new features and only get backward
    compatible fixes.

Like Ubuntu, in terms of support, we distinguish between two kinds of stable
release series:

*   **LTS (Long Term Support)** is a release series that is supported
    for 3 years (community) and up to 5 years (paying customers).
    Current LTS release series is 1.10, and it receives only PATCH level
    releases.

*   **Standard** is a release series that is supported only for a few months
    until the next release series enters the stable state.

Below is a diagram that illustrates the release sequence issuing described above
by an example of some latest releases and release series:

..  _release-diagram:

..  code-block:: text

    1.10 series -- 1.10.4 -- 1.10.5 -- 1.10.6 -- 1.10.7
    (LTS)

    ....

    2.2 series --- 2.2.1 --- 2.2.2 --- 2.2.3 (end of support)
                     |
                     V
    2.3 series ... 2.3.0 --- 2.3.1 --- 2.3.2 --- 2.3.3 (end of support)
                               |
                               V
    2.4 series ............. 2.4.0 --- 2.4.1 --- 2.4.2
                                         |
                                         V
    2.5 series ....................... 2.5.0 --- 2.5.1
                                                   |
                                                   V
    2.6 series ................................. 2.6.0

    -----------------|---------|---------|---------|------> (time)
                       1/4 yr.   1/4 yr.   1/4 yr.

*Support* means that we continue fixing bugs. We add bug fixes simultaneously
into the following release series: LTS, last stable, beta, and alpha.
If we look at the release diagram above, it means that the bug fixes are to be
added into 1.10, 2.4, 2.5, and 2.6 release series.

To sum it up, once a quarter we release (see the release diagram above for
reference):

*   next LTS release, e.g., 1.10.9
*   two stable releases, e.g., 2.5.3 and 2.6.2
*   beta version of the next release series, e.g., 2.7.1.

In all supported releases, when we find and fix an outstanding CVE/vulnerability,
we deliver a patch for that but do not tag a new PATCH level version.
Users will be informed about such critical patches via the official Tarantool news
channel (`tarantool_news <https://t.me/tarantool_news>`_).

We also publish nightly builds, and use the fourth slot in the version
identifier to designate the nightly build number.

..  _backward-incompatible:

..  note::

    A release series may introduce backward incompatible changes in a sense that
    existing Lua, SQL or C code that are run on a current release series
    may not be run with the same effect on a future series.
    However, we don't exploit this rule and don't make incompatible changes
    without appropriate reason. We usually deliver information how mature
    a functionality is via release notes.

    Please note that binary data layout
    is always compatible with the previous series as well as with the LTS series
    (an instance of ``X.Y`` version can be started on top of ``X.(Y+1)``
    or ``1.10.z`` data); binary protocol is compatible too
    (client-server as well as replication protocol).
