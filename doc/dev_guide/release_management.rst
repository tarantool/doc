.. _release:

--------------------------------------------------------------------------------
Release management
--------------------------------------------------------------------------------

.. _release-policy:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Release policy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A Tarantool release is identified by three digits, for example, 1.10.7:

* The first digit stands for a MAJOR release series that introduces
  some *major changes*. Up to now, there has been only one major release jump
  when we delivered the 2.x release series with the SQL support.
* The second digit stands for a MINOR release series that is used for
  introducing new *features*. :ref:`Backward incompatible changes <backward-incompatible>`
  are possible between these release series.
* The third digit is for PATCH releases by which we reflect how stable
  the MINOR release series is:

  * ``0`` meaning **alpha**
  * ``1`` meaning **beta**
  * ``2`` and above meaning **stable**.

So, each MINOR release series goes through a development-maturity life cycle
as follows:

1. **Alpha**. Once a quarter, we start off with a new alpha version,
   such as 2.3.0, 2.4.0, and so on. This is not what an alpha release usually
   means in the typical software release life cycle but rather the current trunk
   version which is under heavy development and can be unstable.
   The current alpha version always lives in the master branch.

2. **Beta**. When all the features planned are implemented, we fork a new branch
   from the master branch and tag it as a new beta version.
   It contains ``1`` for the PATCH digit, e.g., 2.3.1, 2.4.1, and so on.
   This version cannot be called stable yet (feature freeze has just been done)
   although there're no known critical regressions in it since
   the last stable release.

3. **Stable**. Finally, after we see our beta version runs successfully in
   a production or development environment during another quarter while we fix
   incoming bugs, we declare this version stable. It is tagged with ``2`` for
   the PATCH digit, e.g., 2.3.2, 2.4.2, and so on.

   We support such version for 3 months while making another stable release
   by fixing all bugs found. We release it in a quarter. This last tag
   contains ``3`` for the PATCH digit, e.g., 2.3.3, 2.4.3, and so on.
   After the tag is set, no new changes are allowed to the release branch,
   and it is declared deprecated and superseded by a newer MINOR version.

   Stable versions don't receive any new features and only get backward
   compatible fixes.

Like Ubuntu, in terms of support, we distinguish between two kinds of stable
release series:

* **LTS (Long Term Support)** is a release series that is supported
  for 3 years (community) and up to 5 years (paying customers).
  Current LTS release series is 1.10, and it receives only PATCH level
  releases.

* **Standard** is a release series that is supported only for a few months
  until the next release series enters the stable state.

Below is a diagram that illustrates the release sequence issuing described above
by an example of some latest releases and release series:

.. _release-diagram:

.. code-block:: text

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

* next LTS release, e.g., 1.10.7
* two stable releases, e.g., 2.3.3 and 2.4.2
* beta version of the next release series, e.g., 2.5.1.

In all supported releases, when we find and fix an outstanding CVE/vulnerability,
we deliver a patch for that but do not tag a new PATCH level version.
Users will be informed about such critical patches via the official Tarantool news
channel (`tarantool_news <https://t.me/tarantool_news>`_).

We also publish nightly builds, and use the fourth slot in the version
identifier to designate the nightly build number.

.. _backward-incompatible:

.. note::

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

.. _release-list:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Release list
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Below is the table containing all Tarantool releases starting from 1.10.0 up to
the current latest versions (as of September 1, 2020). For each release series,
releases are sorted out as alpha, beta, and stable ones.

.. container:: table

   .. rst-class:: left-align-column-1
   .. rst-class:: left-align-column-2
   .. rst-class:: left-align-column-3
   .. rst-class:: left-align-column-4

   +---------+--------+--------+--------+
   | Release | Alpha  | Beta   | Stable |
   | series  |        |        |        |
   +=========+========+========+========+
   | 1.10    | 1.10.0 | 1.10.1 | 1.10.2 |
   | (LTS)   |        |        | 1.10.3 |
   |         |        |        | 1.10.4 |
   |         |        |        | 1.10.5 |
   |         |        |        | 1.10.6 |
   |         |        |        | 1.10.7 |
   +---------+--------+--------+--------+
   | 2.1     | 2.1.0  | 2.1.1  | 2.1.2  |
   |         |        |        | 2.1.3  |
   +---------+--------+--------+--------+
   | 2.2     | 2.2.0  | 2.2.1  | 2.2.2  |
   |         |        |        | 2.2.3  |
   +---------+--------+--------+--------+
   | 2.3     | 2.3.0  | 2.3.1  | 2.3.2  |
   |         |        |        | 2.3.3  |
   +---------+--------+--------+--------+
   | 2.4     | 2.4.0  | 2.4.1  | 2.4.2  |
   +---------+--------+--------+--------+
   | 2.5     | 2.5.0  | 2.5.1  |        |
   +---------+--------+--------+--------+
   | 2.6     | 2.6.0  |        |        |
   +---------+--------+--------+--------+


.. _release-minor:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
How to make a minor release
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: console

    $ git tag -a 2.4 -m "Next minor in 2.x series"
    $ vim CMakeLists.txt # edit CPACK_PACKAGE_VERSION_PATCH
    $ git push --tags

A tag which is made on a git branch can be taken along with a merge, or left
on the branch. The technique to "keep the tag on the branch it was
originally set on" is to use ``--no-fast-forward`` when merging this branch.

With ``--no-ff``, a merge changeset is created to represent the received
changes, and only that merge changeset ends up in the destination branch.
This technique can be useful when there are two active lines of development,
e.g. "stable" and "next", and it's necessary to be able to tag both
lines independently.

To make sure that a tag doesn't end up in the destination branch, it is
necessary to have the commit to which the tag is attached, "stay on the
original branch". That's exactly what a merge with disabled "fast-forward"
does -- creates a "merge" commit and adds it to both branches.

Here's what it may look like:

.. code-block:: console

     kostja@shmita:~/work/tarantool$ git checkout master
     Already on 'master'
     kostja@shmita:~/work/tarantool$ git tag -a 2.4 -m "Next development"
     kostja@shmita:~/work/tarantool$ git describe
     2.4
     kostja@shmita:~/work/tarantool$ git checkout master-stable
     Switched to branch 'master-stable'
     kostja@shmita:~/work/tarantool$ git tag -a 2.3 -m "Next stable"
     kostja@shmita:~/work/tarantool$ git describe
     2.3
     kostja@shmita:~/work/tarantool$ git checkout master
     Switched to branch 'master'
     kostja@shmita:~/work/tarantool$ git describe
     2.4
     kostja@shmita:~/work/tarantool$ git merge --no-ff master-stable
     Auto-merging CMakeLists.txt
     Merge made by recursive.
      CMakeLists.txt |    1 +
      1 files changed, 1 insertions(+), 0 deletions(-)
     kostja@shmita:~/work/tarantool$ git describe
     2.4.0-0-g0a98576

Also, don't forget this:

1. Update all issues. Upload the ChangeLog based on ``git log`` output.

   The ChangeLog must only include items which are mentioned as issues
   on GitHub. If anything significant is there, which is not mentioned,
   something went wrong in release planning and the release should be
   held up until this is cleared.

2. Click 'Release milestone'. Create a milestone for the next minor release.
   Alert the driver to target bugs and blueprints to the new milestone.
