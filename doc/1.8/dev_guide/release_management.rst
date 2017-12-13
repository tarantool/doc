--------------------------------------------------------------------------------
Release management
--------------------------------------------------------------------------------

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
