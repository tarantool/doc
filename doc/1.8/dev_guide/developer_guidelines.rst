-------------------------------------------------------------------------------
Developer guidelines
-------------------------------------------------------------------------------

.. _dev_guidelines-work_on_a_bug:

===========================================================
How to work on a bug
===========================================================

Any defect, even minor, if it changes the user-visible server behavior, needs
a bug report. Report a bug at http://github.com/tarantool/tarantool/issues.

When reporting a bug, try to come up with a test case right away. Set the
current maintenance milestone for the bug fix, and specify the series.
Assign the bug to yourself. Put the status to 'In progress' Once the patch is
ready, put the bug the bug to 'In review' and solicit a review for the fix.

Once there is a positive code review, push the patch and set the status to 'Closed'

Patches for bugs should contain a reference to the respective Launchpad bug page or
at least bug id. Each patch should have a test, unless coming up with one is
difficult in the current framework, in which case QA should be alerted.

There are two things you need to do when your patch makes it into the master:

* put the bug to 'fix committed',
* delete the remote branch.

.. _dev_guidelines-commit_message:

===========================================================
How to write a commit message
===========================================================

Any commit needs a helpful message. Mind the following guidelines when committing
to any of Tarantool repositories at GitHub.

1. Separate subject from body with a blank line.
2. Try to limit the subject line to **50 characters** or so.
3. Start the subject line with a capital letter unless it prefixed with a
   subsystem name and semicolon:

   * memtx:
   * vinyl:
   * xlog:
   * replication:
   * recovery:
   * iproto:
   * net.box:
   * lua:

4.  Do not end the subject line with a period.
5.  Do not put "gh-xx", "closes #xxx" to the subject line.
6.  Use the imperative mood in the subject line.
    A properly formed Git commit subject line should always be able to complete
    the following sentence: "If applied, this commit will */your subject line here/*".
7.  Wrap the body to **72 characters** or so.
8.  Use the body to explain **what and why** vs. how.
9.  Link GitHub issues on the lasts lines
    (`see how <https://help.github.com/articles/closing-issues-via-commit-messages>`_).
10. Use your real name and real email address.
    For Tarantool team members, **@tarantool.org** email is preferred, but not
    mandatory.

A template:

.. code-block:: none

    Summarize changes in 50 characters or less

    More detailed explanatory text, if necessary.
    Wrap it to 72 characters or so.
    In some contexts, the first line is treated as the subject of the
    commit, and the rest of the text as the body.
    The blank line separating the summary from the body is critical
    (unless you omit the body entirely); various tools like `log`,
    `shortlog` and `rebase` can get confused if you run the two together.

    Explain the problem that this commit is solving. Focus on why you
    are making this change as opposed to how (the code explains that).
    Are there side effects or other unintuitive consequences of this
    change? Here's the place to explain them.

    Further paragraphs come after blank lines.

    - Bullet points are okay, too.

    - Typically a hyphen or asterisk is used for the bullet, preceded
      by a single space, with blank lines in between, but conventions
      vary here.

    Fixes: #123
    Closes: #456
    Needed for: #859
    See also: #343, #789

Some real-world examples:

* `tarantool/tarantool@2993a75 <https://github.com/tarantool/tarantool/commit/2993a75858352f101deb4a15cefd497ae6a78cf7>`_
* `tarantool/tarantool@ccacba2 <https://github.com/tarantool/tarantool/commit/ccacba28f813fb99fd9eaf07fb41bf604dd341bc>`_
* `tarantool/tarantool@386df3d <https://github.com/tarantool/tarantool/commit/386df3d3eb9c5239fc83fd4dd3292d1b49446b89>`_
* `tarantool/tarantool@076a842 <https://github.com/tarantool/tarantool/commit/076a842011e09c84c25fb5e68f1b23c9917a3750>`_

Based on [1_] and [2_].

.. _dev_guidelines-patch-review:

===========================================================
How to submit a patch for review
===========================================================

Since 24.01.2018 changes prepared for review should be submitted
to patches@tarantool.org.

e-mail messages are prepared using ``git format-patch`` and ``git send-email``.

.. container:: faq

    :Q: What a mail thread is and why is it useful?
    :A: An email thread keeps the review history local: all iterations are
        stored in a single mail thread, thus making navigation simple.

    :Q: When a cover letter is needed?
    :A: A cover letter unifies multiple patches (a patchset) into a single
        thread.

        So, a cover letter is needed at all times, unless a patchset contains
        just one patch. If so, it's the commit message that plays the cover
        letter's role.

    :Q: What to put in a cover letter?
    :A: A cover letter must contain:

        * An answer to the question "what does the patchset ?",
          e.g. "Improve HASH index search".
        * The branch name.
        * A hyperlink to the gh issue.

        If the patchset contains just one patch, all this information is present
        within the patch:

        * The commit message answers the "what" question.
        * The branch name is the current branch, and you can find it inside
          the patch body, delimited by `---`.
        * A hyperlink to the gh issue is available in the commit message.

    :Q: Which options to add to ``format-patch``?
    :A: The required options are:

        * ``--subject-prefix``
        * subject -- ??? NO OPTION FOUND
        * the first commit to send -- ??? NO OPTION FOUND

    :Q: What prefixes to put in the subject?
    :A: Always put ``PATCH``. For all the following reviews in the thread,
        also use ``PATCHSET_VERSION`` e.g. ``v2``.

    :Q: How to refer to the git branch and issue (in a cover letter)?
    :A: See Q#3.

    :Q: How to put updated changes derived from rebasing (force-pushing) into
        the same mail thread?
    :A: Use ``git send-email`` (this is a standalone git package) without the
        option ``in-reply-to``.

Check here_ for scripts which might be useful for preparing e-mail messages.

.. _1: https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project
.. _2: https://chris.beams.io/posts/git-commit/
.. _here: https://gist.github.com/Gerold103/5471a7ddbeec346c0c845930d5bb9df4
