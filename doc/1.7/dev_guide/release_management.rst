.. _release:

--------------------------------------------------------------------------------
Release management
--------------------------------------------------------------------------------

.. _release-policy-existing:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Release policy: existing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here we use terms according to their definitions provided at http://semver.org:

* A **major** release may contain incompatible changes.
* A **minor** release does not contain incompatible changes, but may contain
  features.
* A **patch release** must contain backward-compatible bug fixes only.

Tarantool today publishes a major release every 1 or 2 years. We use both first
and second version digits to identify a major release. For example, both 1.7 and
1.6 are major releases.

Each major release goes through development-maturity life cycle, as follows:

1. **Alpha**. Once in every few months we release a few alpha versions,
   e.g. 1.7.1, 1.7.2.

   Alpha versions may contain incompatible changes, crashes and other bugs.

2. **Beta**. Once major changes necessary to introduce new flagship features
   are ready, we release a few beta versions, e.g. 1.7.3, 1.7.4.

   Beta versions may contain crashes, but do not have incompatible changes,
   so can be used to develop new applications.

3. **Gamma**. Once all crashes are ironed out, minor features are complete and
   we've done some rigorous internal testing, we release a gamma version.

   A gamma is a special kind of stable release. We believe it's stable, since
   we have fixed all the bugs in it we could find, but it has not been proven
   to be stable by the community, hence we don't call it stable.

4. **Stable**. Finally, after we see our gamma versions run successfully in
   production, usually in a few more months, during which we fix all incoming
   bugs and add some minor features, we declare a release stable.

   A stable release is supported for 3 years, during which we continue fixing
   bugs in it.

We do not have patch releases, in definition of semver, as such.
We simply publish all our nightly builds, for all our releases, beginning with
their alpha state.

Meanwhile we are not too happy with the existing release policy, because
our maturity cycle may take a long time. Some major features, such as vinyl,
take 2-3 years to mature. While this happens, we have no vehicle to deliver
minor features to the community in a regular fashion -- e.g. every few months.

This situation is self-aggravating. At the end of a maturity cycle, we tend to
push more and more features into the release, since we know that the next
vehicle may not depart in a year or two, thus destabilizing the release, and
prolonging the stabilization period even more.

Another manifestation of the same, we have no other vehicle to deliver minor
features for paying customers but pushing them into a stable release, thus
violating our commitment to community to keep a stable release stable.

Community has no quick way to identify how stable and supported a release is
just by looking at its version.

.. _release-policy-new:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Release policy: new
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Like Ubuntu, we begin distinguishing two kinds of stable releases:
**LTS (Long Term Support)** and a **standard stable release**.

We continue supporting LTS releases for 3, and, with paying customers,
up to 5 years, while standard stable release will be only supported a few months
after the next stable is out.

We adopt semantic versioning for our release numbers:

* Only the first digit now stands for MAJOR release, meaning we do not allow
  incompatible changes between 1.7 and 1.8.
* The second digit stands for MINOR, and is used for introducing
  backward-compatible features.
* PATCH level releases contain only backward compatible bug fixes.

We reflect how stable a release is in MINOR digit:

* 0 meaning alpha,
* 1 meaning beta,
* anything between 1 and 10 meaning stable, and
* 10 meaning LTS.

With these changes our release cycle will look as follows.

We will be adding commits simultaneously to three major releases:
LTS, STABLE, and NEXT.

LTS is a stable release which does not receive new features, and only gets
backward compatible fixes. Hence, following the rules of semver, LTS release
never has its MAJOR or MINOR version increased, and only gets PATCH level
releases.

STABLE is our current stable release, which may receive new features.
When the next STABLE version is published, MINOR version is incremented.
Between MINOR releases, we may have intermediate PATCH level releases as well,
which will contain only bug fixes. We will maintain PATCH level releases for two
STABLE releases, the current and the previous one, to maintain support continuity.

NEXT is our next major release, and it should follow the same maturity cycle as
described in the preamble. While NEXT release is in alpha state, its MINOR is
frozen at 0 and is only increased when the release reaches BETA status.
Once the NEXT release becomes STABLE, we switch the vehicle for delivery of
minor features, designating the previous stable release as LTS, and relasing it
with MINOR set to 10.

To sum up, once a quarter we should:

* release the next LTS release, e.g. 2.10.6, 2.10.7, 2.10.8
* release the next STABLE release, e.g. 3.6, 3.7 or 3.8
* optionally release an alpha or beta version of the NEXT release,
  e.g. 4.0.1 or 4.0.2 or 4.0.3

In all supported releases, we also must release a PATCH release as soon as we
find and fix an outstanding CVE/vulnerability.

We will also publish nightly builds, and will continue using the fourth slot
in the version identifier to designate the nightly build number.

.. NOTE::

    According to the new policy, the current 1.7 is STABLE, and should have
    its MINOR increased to 1.8 with the next release of 1.7.7.
    But -- as a transtion measure -- we will NOT do that, instead, we will
    freeze 1.7 for new features with release of 1.10 and turn it into LTS.

    According to the same policy, the current 1.8 is the NEXT major, since it
    has some big features we've been working for the past 3 years.
    We will need to transition it to STABLE ASAP, since otherwise we will have
    no vehicle for small features, thus it will be renumbered to 2.0.

    Synchronous replication and sharding will have to go to the new NEXT, i.e.
    Tarantool 3.0.

Example version identifier:

* 2.0.3 - third alpha of 2.0 release
* 2.1.3 - a beta of 2.0 release
* 2.2 - a stable version of 2.0 series, but perhaps not an LTS yet
* 2.10 - an LTS release

.. _release-minor:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
How to make a minor release
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: console

    $ git tag -a 1.4.4 -m "Next minor in 1.4 series"
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
     kostja@shmita:~/work/tarantool$ git tag -a 1.4.1 -m "Next development"
     kostja@shmita:~/work/tarantool$ git describe
     1.4.1
     kostja@shmita:~/work/tarantool$ git checkout master-stable
     Switched to branch 'master-stable'
     kostja@shmita:~/work/tarantool$ git tag -a 1.3.5 -m "Next stable"
     kostja@shmita:~/work/tarantool$ git describe
     1.3.5
     kostja@shmita:~/work/tarantool$ git checkout master
     Switched to branch 'master'
     kostja@shmita:~/work/tarantool$ git describe
     1.4.1
     kostja@shmita:~/work/tarantool$ git merge --no-ff master-stable
     Auto-merging CMakeLists.txt
     Merge made by recursive.
      CMakeLists.txt |    1 +
      1 files changed, 1 insertions(+), 0 deletions(-)
     kostja@shmita:~/work/tarantool$ git describe
     1.4.1-2-g0a98576

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
   find the Dockerfile that corresponds to the commit's major version (e.g.
   https://github.com/tarantool/docker/blob/master/1.7/Dockerfile
   for Tarantool version 1.7) and specify the required commit in
   ``TARANTOOL_VERSION``, for example
   ``TARANTOOL_VERSION=1.7.6-11-gcd17b77f9``.

   Commit the Dockerfile back to ``master`` branch.

3. In the same repository, create a branch named after the commit's
   ``1.<major>.<minor>`` versions,
   e.g. ``1.7.6`` for commit 1.7.6-11-gcd17b77f9.

4. In Tarantool container build settings at ``hub.docker.com``
   (https://hub.docker.com/r/tarantool/tarantool/~/settings/automated-builds/),
   add a new line:

   .. code-block:: text

       Branch: 1.x.y, /1.x, 1.x.y

   where ``x`` and ``y`` correspond to the commit's major and minor versions.

   Click **Save changes**.

Shortly after, a new Docker container will be built.
