Git workflow
============

Branching
---------

Use one branch for a single task, unless you're fixing typos or markup on several pages.
Long commit histories are hard to manage and sometimes end up stale.

Start a new branch from the last commit on ``latest``.
Make sure to update your local version of ``latest`` with ``git pull``.
Otherwise, you may have to rebase later.

Name your branch so it's clear what you're doing. Examples:

*   ``short-issue-description``
*   ``gh-1234-short-issue-description``
*   ``your-github-handle/short-issue-description``

Linking issues and PRs
----------------------

When a PR is linked to an issue:

*   You can go from the issue straight to the PR by clicking the link in the right column.
*   The issue will be automatically closed when you close the PR.

Specify the issue(s) you want to close in the description of your PR. GitHub will connect them if you use specific
`keywords <https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue#linking-a-pull-request-to-an-issue-using-a-keyword>`__.
Here are some of them:

*   Closes #1234
*   Resolves #1234
*   Fixes #1234

If your PR closes more than one issue, mention each of them:

..  code-block::

    Resolves #1300, resolves #1234, resolves tarantool/doc#100

Commit messages
---------------

*   Most of the time, one-line commit messages are sufficient for documentation changes.

    -   When you squash commits at merge, the resulting commit message is a sum of all commit messages in the PR.
        It is advised to include the "resolves" string in the first commit.
        Otherwise, there's a risk that this line won't be included in the merge commit.

*   Convey the nature of the change and possibly the reason why it was made.

    -   Don't specify the files you've changed or the issue you're working on.
        The file names can be looked up in the "Files" section of the PR, and the PR description has the issue number(s).

*   Try keeping the commit title 50 characters or shorter.
*   Use the imperative mood.
*   Start with a capital letter, don't add ending punctuation.
*   (Optional) Use the telegraphic style, or "headlinese", dropping the articles.

Good examples
~~~~~~~~~~~~~

*   ``git commit -m "Expand section on msgpack"``
*   ``git commit -m "Add details on IPROTO_BALLOT"``
*   ``git commit -m "Create new structure"``
*   ``git commit -m "Improve grammar"``

Bad examples
~~~~~~~~~~~~

*   ``git commit -m "Fix gh-2007, second commit"``
*   ``git commit -m “Changed the file box_protocol.rst”``
*   ``git commit -m "added more list items"``

Selecting a reviewer
--------------------

Ideally, a PR should have two reviewers: a subject matter expert (SME) and a documentarian.
The SME checks the facts, and the documentarian checks the language and style.

If you're not sure who the SME for an issue is, try the following:

*   Check the issue description. The SME is often mentioned there explicitly.
*   Note who created the issue and who was involved in the discussion.

Merging
-------

Merge when your document is ready and good enough.
For external contributors, merging is blocked until a reviewer's approval.

*   Always squash commits.
*   Make sure the commit message mentions all relevant issues with "resolves" or "fixes".
*   Make sure you've
    `attributed <https://docs.github.com/en/pull-requests/committing-changes-to-your-project/creating-and-editing-commits/creating-a-commit-with-multiple-authors>`__
    all participants with ``Co-authored-by``.
