.. _release:

Release management
------------------

All released versions are listed at the :doc:`/release` page.
:doc:`/release/policy` explains the rules and meaning of numbers in ``x.y.z`` versions.

This page will tell you how to make a Tarantool release.

How to make a minor release
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. _release-minor:


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

..  _release-table:

Currently supported versions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Below is the releases lifetime table listing all Tarantool versions starting from 1.10.x up to the current latest versions.
Each link leads to the release notes page of the corresponding version.
End of standard support means the release series will no longer receive any patches, updates, or feature improvements.

..  container:: table

    ..  list-table::

        *   -   Version
            -   Release date
            -   End of standard support

        *   -   2.10.0
            -   To be announced
            -   Not planned yet

        *   -   `2.8.3 <https://github.com/tarantool/tarantool/releases/tag/2.8.3>`_
            -   December 22, 2021
            -   Not planned yet

        *   -   :doc:`2.8.2 </release/2021-08-releases>`
            -   August 19, 2021
            -   Not planned yet

        *   -   :doc:`2.7.3 </release/2021-08-releases>`
            -   August 19, 2021
            -   August 19, 2021

        *   -   :doc:`2.7.2 </release/2.7.2>`
            -   April 21, 2021
            -   August 19, 2021

        *   -   :doc:`2.6.3 </release/2.6.3>`
            -   April 21, 2021
            -   April 21, 2021

        *   -   :doc:`2.6.2 </release/2.6.2>`
            -   December 30, 2020
            -   April 21, 2021

        *   -   :doc:`2.5.3 </release/2.5.3>`
            -   December 30, 2020
            -   December 30, 2020

        *   -   :doc:`2.5.2 </release/2.5.2>`
            -   October 22, 2020
            -   December 30, 2020

        *   -   :doc:`2.4.3 </release/2.4.3>`
            -   October 22, 2020
            -   October 22, 2020

        *   -   :doc:`2.4.2 </release/2.4.2>`
            -   July 17, 2020
            -   October 22, 2020

        *   -   :doc:`2.3.3 </release/2.3.3>`
            -   July 17, 2020
            -   July 17, 2020

        *   -   :doc:`2.3.2 </release/2.3.2>`
            -   April 20, 2020
            -   July 17, 2020

        *   -   :doc:`2.2.3 </release/2.2.3>`
            -   April 20, 2020
            -   April 20, 2020

        *   -   :doc:`2.2.2 </release/2.2.2>`
            -   December 31, 2019
            -   April 20, 2020

        *   -   :doc:`1.10.11 LTS </release/2021-08-releases>`
            -   August 19, 2021
            -   To be announced

        *   -   :doc:`1.10.10 LTS </release/1.10.10>`
            -   August 19, 2021
            -   To be announced

        *   -   :doc:`1.10.9 LTS </release/1.10.9>`
            -   December 30, 2020
            -   To be announced

        *   -   :doc:`1.10.8 LTS </release/1.10.8>`
            -   October 22, 2020
            -   To be announced

        *   -   :doc:`1.10.7 LTS </release/1.10.7>`
            -   July 17, 2019
            -   To be announced

        *   -   :doc:`1.10.6 LTS </release/1.10.6>`
            -   April 20, 2020
            -   To be announced

        *   -   :doc:`1.10.5 LTS </release/1.10.5>`
            -   January 14, 2020
            -   To be announced

        *   -   :ref:`1.10.4 LTS <whats_new_1104>`
            -   September 26, 2019
            -   To be announced

        *   -   :ref:`1.10.3 LTS <whats_new_1103>`
            -   April 1, 2019
            -   To be announced

        *   -   :ref:`1.10.2 LTS <whats_new_1102>`
            -   October 13, 2018
            -   To be announced

..  _release-calendar:

Releases calendar
~~~~~~~~~~~~~~~~~

Currently supported versions visualised as a calendar.
