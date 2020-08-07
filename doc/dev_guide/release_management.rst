.. _release:

--------------------------------------------------------------------------------
Release management
--------------------------------------------------------------------------------

.. _release-policy:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Release policy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A Tarantool release is identified by three digits, for example, 1.10.7:

* The first digit stands for ?a MAJOR release. A MAJOR release may contain
  *incompatible changes*.
* The second digit stands for ?a MINOR release. It does not contain incompatible
  changes, and is used for introducing backward-compatible *features*.
* The third digit is for [TODO]PATCH releases that contain only
  backward-compatible *bug fixes*.

In the PATCH digit, we reflect how stable a release is:

* ``0`` meaning **alpha**
* ``1`` meaning **beta**
* ``2`` and above meaning **stable**.

So, each MINOR release series goes through a development-maturity life cycle
as follows:

1. **Alpha**. Once a quarter, we start off with a new alpha version,
   such as 2.3.0, 2.4.0, and so on. It is not what an alpha release usually
   means in the software release life cycle but rather the current trunk version
   which is under heavy development and can be unstable.
   The current alpha version always lives in the master branch.

2. **Beta**. When all the features planned are implemented, we fork a new branch
   from the master branch and tag it as a new beta version.
   It contains ``1`` for the PATCH digit, e.g., 2.3.1, 2.4.1, and so on.
   This version is still unstable although there're no critical regressions
   in it since the last stable release. We do this quarterly as well.

3. **Stable**. Finally, after we see our beta version runs successfully in
   a production or development environment during another quarter while we fix
   incoming bugs we declare this version stable. It is tagged with ``2`` for
   the PATCH digit, e.g., 2.3.2, 2.4.2, and so on.

   We support such version for 3 months while making another stable release
   by fixing all bugs found. We release it in a quarter. This last tag
   contains ``3`` for the PATCH digit, e.g., 2.3.3, 2.4.3, and so on.
   After the tag is set, no new changes are allowed to the release branch,
   and it is declared deprecated and superseded by a newer MINOR version."

Like Ubuntu, we distinguish between two kinds of stable releases:

* **LTS (Long Term Support)** is a release series that is supported
  for 3 years (community) and up to 5 years (paying customers).
  Current LTS release series is 1.10.

* **Standard stable releases** are only supported a few months after the next
  stable is out.

"Support" means that we continue fixing bugs in a release.

We add bug fixes simultaneously into the following three releases and
into the current alpha release:

* **LTS** is a stable release which does not receive new features, and only gets
  backward compatible fixes. Hence, LTS release
  never has its MAJOR or MINOR version increased, and only gets PATCH level
  releases.

* **STABLE** are our current stable releases which may not receive new features.
  When the next STABLE version is published, MINOR version is incremented.
  We maintain PATCH level releases for two STABLE releases,
  the current and the previous one, to preserve support continuity.

* **NEXT** Beta is our next MINOR release, and it follows the maturity cycle
  described in the beginning.

To sum up, once a quarter we release:

* the next LTS release, e.g., 1.10.6, 1.10.7, and or so on
* the next STABLE release, e.g., 2.4.2 or 2.3.3
* the beta version of the NEXT release, e.g., 2.5.1 or 2.6.1.

In all supported releases, we also release a PATCH release as soon as we
find and fix an outstanding CVE/vulnerability.

We also publish nightly builds, and use the fourth slot in the version
identifier to designate the nightly build number.

Example version identifier:

* 2.5.0 -- the current alpha version under development
* 2.6.1 -- a beta version of the 2.6 release
* 2.3.3 or 2.4.2 -- stable versions of the 2.3 or 2.4 releases, but not an LTS yet
* 1.10.7 - a release within the LTS release series 1.10.

.. _release-list:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Release list
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Below is the table containing all Tarantool releases starting from 1.10.0 up to
the current latest versions. Releases are sorted out for alpha, beta, and
stable ones.

+-------+--------+--------+--------+
| MINOR | Alpha  | Beta   | Stable |
+=======+========+========+========+
| 1.10  | 1.10.0 | 1.10.1 | 1.10.2 |
| (LTS) |        |        | 1.10.3 |
|       |        |        | 1.10.4 |
|       |        |        | 1.10.5 |
|       |        |        | 1.10.6 |
|       |        |        | 1.10.7 |
+-------+--------+--------+--------+
| 2.1   | 2.1.0  | 2.1.1  | 2.1.2  |
|       |        |        | 2.1.3  |
+-------+--------+--------+--------+
| 2.2   | 2.2.0  | 2.2.1  | 2.2.2  |
|       |        |        | 2.2.3  |
+-------+--------+--------+--------+
| 2.3   | 2.3.0  | 2.3.1  | 2.3.2  |
|       |        |        | 2.3.2  |
+-------+--------+--------+--------+
| 2.4   | 2.4.0  | 2.4.1  | 2.4.2  |
+-------+--------+--------+--------+
| 2.5   | 2.5.0  | 2.5.1  |        |
+-------+--------+--------+--------+
| 2.6   | 2.6.0  |        |        |
+-------+--------+--------+--------+


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
