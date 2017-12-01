-------------------------------------------------------------------------------
                               Release management
-------------------------------------------------------------------------------
===========================================================
              How to make a minor release
===========================================================

.. code-block:: bash

    $ git tag -a 1.4.4 -m "Next minor in 1.4 series"
    $ vim CMakeLists.txt # edit CPACK_PACKAGE_VERSION_PATCH
    $ git push --tags

Update the Web site in doc/www

Update all issues, upload the ChangeLog based on ``git log`` output.
The ChangeLog must only include items which are mentioned as issues
on github. If anything significant is there, which is not mentioned,
something went wrong in release planning and the release should be
held up until this is cleared.

Click 'Release milestone'. Create a milestone for the next minor release.
Alert the driver to target bugs and blueprints to the new milestone.

A tag which is made on a git branch can be taken along with a merge, or left
on the branch. The technique to "keep the tag on the branch it was
originally set on" is to use --no-fast-forward when merging this branch.
With --no-ff, a merge changeset is created to represent the received
changes, and only that merge changeset ends up in the destination branch.
This technique can be useful when there are two active lines of development,
e.g. "stable" and "next", and it's necessary to be able to tag both
lines independently.


To make sure that a tag doesn't end up in the destination branch, is
necessary to have the commit, to which the tag is attached, "stay on the
original branch". A merge with disabled "fast-forward" does exactly that --
creates a "merge" commit and adds it to both branches.

Here's how it may look like:

.. code-block:: bash

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

