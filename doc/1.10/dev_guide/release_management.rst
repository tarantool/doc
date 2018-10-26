.. _release:

--------------------------------------------------------------------------------
Release management
--------------------------------------------------------------------------------

.. _release-policy:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Release policy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A Tarantool release is identified by three digits, for example, 1.7.7.
We use these digits according to their definitions provided at http://semver.org:

* The first digit stands for MAJOR release. A **major** release may contain
  *incompatible changes*.
* The second digit stands for MINOR release, it does not contain incompatible
  changes, and is used for introducing backward-compatible *features*.
* The third digit is for PATCH releases that contain only backward-compatible
  *bug fixes*.

In MINOR digit, we reflect how stable a release is:

* 0 meaning alpha,
* 1 meaning beta,
* anything between 1 and 10 meaning stable, and
* 10 meaning LTS.

So, each MAJOR release series goes through a development-maturity life cycle of
MINOR releases, as follows:

1. **Alpha**. Once in every few months we release a few alpha versions,
   e.g. 2.0.1, 2.0.2.

   Alpha versions may contain incompatible changes, crashes and other bugs.

2. **Beta**. Once major changes necessary to introduce new flagship features
   are ready, we release a few beta versions, e.g. 2.1.3, 2.1.4.

   Beta versions may contain crashes, but do not have incompatible changes,
   so can be used to develop new applications.

4. **Stable**. Finally, after we see our beta versions run successfully in
   production, usually in a few more months, during which we fix all incoming
   bugs and add some minor features, we declare this MAJOR release series
   stable.

Like Ubuntu, we distinguish two kinds of stable releases:

* **LTS (Long Term Support)** releases that are supported for 3 years
  (community) and up to 5 years (paying customers). **LTS** release
  is identified by MINOR version 10.
* **Standard stable releases** are only supported a few months after the next
  stable is out.

"Support" means that we continue fixing bugs in a release.

We add commits simultaneously to three MAJOR releases:

* **LTS** is a stable release which does not receive new features, and only gets
  backward compatible fixes. Hence, following the rules of semver, LTS release
  never has its MAJOR or MINOR version increased, and only gets PATCH level
  releases.

* **STABLE** is our current stable release, which may receive new features.
  When the next STABLE version is published, MINOR version is incremented.
  Between MINOR releases, we may have intermediate PATCH level releases as well,
  which will contain only bug fixes. We maintain PATCH level releases for
  two STABLE releases, the current and the previous one, to preserve support
  continuity.

* **NEXT** is our next MAJOR release, and it follows the maturity
  cycle described in the beginning. While NEXT release is in alpha state,
  its MINOR is frozen at 0 and is only increased when the release reaches
  BETA status. Once the NEXT release becomes STABLE, we switch the vehicle for
  delivery of minor features, designating the previous stable release as LTS,
  and releasing it with MINOR set to 10.

To sum up, once a quarter we release:

* the next LTS release, e.g. 2.10.6, 2.10.7 or 2.10.8
* the next STABLE release, e.g. 3.6, 3.7 or 3.8
* (optionally) an alpha or beta version of the NEXT release,
  e.g. 4.0.1, 4.0.2 or 4.0.3

In all supported releases, we also release a PATCH release as soon as we
find and fix an outstanding CVE/vulnerability.

We also publish nightly builds, and use the fourth slot in the version
identifier to designate the nightly build number.

Example version identifier:

* 2.0.3 - third alpha of 2.0 release
* 2.1.3 - a beta of 2.0 release
* 2.2 - a stable version of 2.0 series, but not an LTS yet
* 2.10 - an LTS release

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

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
How to release a Docker container
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To bump a new version of a Docker container:

1. On the ``master`` branch of
   `tarantool/docker <https://github.com/tarantool/docker>`_ repository,
   find the Dockerfile that corresponds to the commit's **major** version (e.g.
   https://github.com/tarantool/docker/blob/master/2.x/Dockerfile
   for Tarantool version 2.4) and specify the required commit in
   ``TARANTOOL_VERSION``, for example
   ``TARANTOOL_VERSION=2.4.0-11-gcd17b77f9``.

   Commit the Dockerfile back to ``master`` branch.

3. In the same repository, create a branch named after the commit's
   ``<major>.<minor>`` versions,
   e.g. branch ``2.4`` for commit 2.4.0-11-gcd17b77f9.

4. In Tarantool container build settings at ``hub.docker.com``
   (https://hub.docker.com/r/tarantool/tarantool/~/settings/automated-builds/),
   add a new line:

   .. code-block:: text

       Branch: x.y, /x, x.y

   where ``x`` and ``y`` correspond to the commit's major and minor versions.

   Click **Save changes**.

Shortly after, a new Docker container will be built.
