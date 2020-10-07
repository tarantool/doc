.. _developer_guidelines:

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
   * sql:

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

We don't accept GitHub pull requests. Instead, all patches
should be sent as plain-text messages to tarantool-patches@dev.tarantool.org.
Please subscribe to our mailing list
at https://lists.tarantool.org/mailman/listinfo/tarantool-patches
to ensure that your messages are added to the archive.

1. **Preparing a patch**

Once you have committed a patch to your local git repository, you can
submit it for review.

To prepare an email, use ``git format-patch`` command:

.. code-block:: console

    $ git format-patch -1

It will format the commit at the top of your local git repository as
a plain-text email and write it to a file in the current directory.
The file name will look like ``0001-your-commit-subject-line.patch``.
To specify a different directory, use ``-o`` option:

.. code-block:: console

    $ git format-patch -1 -o ~/patches-to-send

Once the patch has been formatted, you can view and edit it with your
favorite text editor (after all, it is a plain-text file!). We strongly
recommend adding:

* a hyperlink to the branch where this patch can be found at GitHub, and
* a hyperlink to the GitHub issue your patch is supposed to fix, if any.

If there is just one patch, the change log should go right after ``---`` in the
message body (it will be ignored by ``git am`` then).

If there are multiple patches you want to submit in one go (e.g. this is
a big feature which requires some preparatory patches to be committed
first), you should send each patch in a separate email in reply to a cover
letter. To format a patch series accordingly, pass the following options
to ``git format-patch``:

.. code-block:: console

    $ git format-patch --cover-letter --thread=shallow HEAD~2

where:

* ``--cover-letter`` will make ``git format-patch`` generate a cover letter;
* ``--thread=shallow`` will mark each formatted patch email to be sent
  in reply to the cover letter;
* ``HEAD~2`` (we now use it instead of ``-1``) will make ``git format-patch``
  format the first two patches at the top of your local git branch instead
  of just one. To format three patches, use ``HEAD~3``, and so forth.

After the command has been successfully executed, you will find all your
patches formatted as separate emails in your current directory (or in the
directory specified via ``-o`` option):

.. code-block:: none

    0000-cover-letter.patch
    0001-first-commit.patch
    0002-second-commit.patch
    ...

The cover letter will have BLURB in its subject and body. You'll have to
edit it before submitting (again, it is a plain text file). Please write:

* a short series description in the subject line;
* a few words about each patch of the series in the body.

And don't forget to add hyperlinks to the GitHub issue and branch where
your series can be found. In this case you don't need to put links or any
additional information to each individual email -- the cover letter will
cover everything.

.. NOTE::

    To omit ``--cover-letter`` and ``--thread=shallow`` options, you can
    add the following lines to your gitconfig:

    .. code-block:: none

        [format]
            thread = shallow
            coverLetter = auto

2. **Sending a patch**

Once you have formatted your patches, they are ready to be sent via email.
Of course, you can send them with your favorite mail agent, but it is
much easier to use ``git send-email`` for this. Before using this command,
you need to configure it.

If you use a GMail account, add the following code to your ``.gitconfig``:

.. code-block:: none

    [sendemail]
        smtpencryption = tls
        smtpserver = smtp.gmail.com
        smtpserverport = 587
        smtpuser = your.name@gmail.com
        smtppass = topsecret

For mail.ru users, the configuration will be slightly different:

.. code-block:: none

    [sendemail]
        smtpencryption = ssl
        smtpserver = smtp.mail.ru
        smtpserverport = 465
        smtpuser = your.name@mail.ru
        smtppass = topsecret

If your email account is hosted by another service, consult your service
provider about your SMTP settings.

Once configured, use the following command to send your patches:

.. code-block:: console

    $ git send-email --to tarantool-patches@dev.tarantool.org 00*

(``00*`` wildcard will be expanded by your shell to the list of patches
generated at the previous step.)

If you want someone in particular to review your patch, add them to the
list of recipients by passing ``--to`` or ``--cc`` once per each recipient.

.. NOTE::

    It is useful to check that ``git send-email`` will work as expected
    without sending anything to the world. Use ``--dry-run`` option for that.

3. **Review process**

After having sent your patches, you just wait for a review. The reviewer
will send their comments back to you in reply to the email that contains
the patch that in their opinion needs to be fixed.

Upon receiving an email with review remarks, you carefully read it and reply
about whether you agree or disagree with. Please note that we use the
interleaved reply style (aka "inline reply") for communications over email.

Upon reaching an agreement, you send a fixed patch in reply to the email that
ended the discussion. To send a patch, you can either attach a plain diff
(created by ``git diff`` or ``git format-patch``) to email and send it with your
favorite mail agent, or use ``--in-reply-to`` option of ``git send-email``
command.

If you feel that the accumulated change set is large enough to send the
whole series anew and restart the review process in a different thread,
you generate the patch email(s) again with ``git format-patch``, this time
adding v2 (then v3, v4, and so forth) to the subject and a change log to
the message body. To modify the subject line accordingly, use the
``--subject-prefix`` option to ``git format-patch`` command:

.. code-block:: console

    $ git format-patch -1 --subject-prefix='PATCH v2'

To add a change log, open the generated email with you favorite text
editor and edit the message body. If there is just one patch, the change
log should go right after ``---`` in the message body (it will be ignored
by ``git am`` then). If there is more than one patch, the change log should
be added to the cover letter. Here is an example of a good change log:

.. code-block:: console

    Changes in v3:
      - Fixed comments as per review by Alex
      - Added more tests
    Changes in v2:
      - Fixed a crash if the user passes invalid options
      - Fixed a memory leak at exit

It is also a good practice to add a reference to the previous version of
your patch set (via a hyperlink or message id).

.. NOTE::

    * Do not disagree with the reviewer without providing a good argument
      supporting your point of view.
    * Do not take every word the reviewer says for granted. Reviewers are
      humans too, hence fallible.
    * Do not expect that the reviewer will tell you how to do your thing.
      It is not their job. The reviewer might suggest alternative ways to
      tackle the problem, but in general it is your responsibility.
    * Do not forget to update your remote git branch every time you send a
      new version of your patch.
    * Do follow the guidelines above. If you do not comply, your patches are
      likely to be silently ignored.

.. _1: https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project
.. _2: https://chris.beams.io/posts/git-commit/
