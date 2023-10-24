.. _contributing:

How to get involved in Tarantool
================================

What is Tarantool?
------------------

Tarantool is an open source database that can store everything in RAM.
Use Tarantool as a cache with the ability to save data to disk.
Tarantool serves up to a million requests per second,
allows for secondary index searches, and has SQL support.

In Tarantool, you can execute code alongside data.
This allows for faster operations.
Implement any business logic in Lua.
Get rid of stale entries, sync with other data sources, implement an HTTP service.

Go to :ref:`Getting Started <getting_started>` and try Tarantool.

How to get help?
----------------

We have a `special Telegram chat <https://t.me/tarantool_contrib>`_
for contributors.
We speak Russian and English in the chat.

This is the easiest way to get your questions answered.
Many people are afraid to ask questions because they believe they are
"wasting the experts' time," but we don't really think so.
Contributors are important to us.

We also have a
`Stack Overflow tag <https://stackoverflow.com/questions/tagged/tarantool>`_.

Join the chat and ask questions.

How to leave feedback, ideas, or suggestions?
---------------------------------------------

You can leave your feedback or share ideas in different ways:

* **The simplest way** is to fill
  `the feedback form <https://docs.google.com/forms/d/1iwBj_2in-rBIYEcPeeVPQa4JfUIU_m14IUbAK4NojIE/edit?usp=sharing>`__.
  All you need to do is fill in one product comment field and click "Send."
  You can optionally provide your email address.
  If you wish, we can involve you in the product development process.
* **A more technical way** is to create a ticket on GitHub.
  If you have a suggestion for a new feature or information about a bug,
  `create a new GitHub issue <https://github.com/tarantool/tarantool/issues/new>`_.
  The link leads to the ``tarantool/tarantool`` repository.
  To leave feedback for our other projects on GitHub, select "Issues" > "New issue."

See `an example of a feature request <https://github.com/tarantool/tarantool/issues/5046>`_.

To talk to our team about a product, go to one of our chats:

* `Russian-speaking <https://t.me/tarantoolru>`_
* `English-speaking <https://t.me/tarantool>`_

If Telegram is inconvenient for you or simply isn't working,
you can leave your comment on `tarantool.io <http://www.tarantool.io>`_.
Fill out the form at the bottom of the site and leave your email.
We read every request and respond to them usually within 2 days.

How to contribute
-----------------

There are many ways to contribute to Tarantool:

* Code: Contribute to the code.
  We have components written in C, Lua, Python, Go, and other languages.
* Write: Improve documentation, write blog posts, create tutorials or solution pages.
* Q&A: Share your experience on Stack Overflow with the
  `#tarantool <https://stackoverflow.com/questions/tagged/tarantool>`_ tag.
* Spread the word: Share your accomplishments on social media using the
  ``#tarantool`` hashtag (or CC ``@tarantooldb`` on Twitter).


Tarantool ecosystem
-------------------

Tarantool has a large ecosystem of tools.
We divide the ecosystem into four large blocks:

* Tarantool itself.
* Modules for Tarantool. They can be written in C and Lua.
* Connectors for programming languages.
* Applied tools. See the curated
  `Awesome Tarantool list <https://github.com/tarantool/awesome-tarantool>`_,
  which also includes external tools.

To start contributing, check the "good first issue" tag
in the issues section of any of our repositories.
These are beginner to intermediate tasks that will
help you get comfortable with the tool.

See the `list of tasks <https://github.com/tarantool/tarantool/labels/good%20first%20issue>`_
for the ``tarantool/tarantool`` repository.

There is a review queue in each of our repositories,
so your changes may not be reviewed immediately.
We usually give the first answer within two days.
Depending on the ticket and its complexity, the review time may take a week or more.

Please do not hesitate to tag the maintainer in your GitHub ticket.

Read on to learn about contributing to different ecosystem blocks.


Documentation: How to report and fix problems
---------------------------------------------

There are several ways to improve the documentation:

* **The easiest one** is to leave your comment on the web documentation page.
  To use the built-in feedback form, select the text that you want to comment on,
  press :kbd:`Ctrl+Enter`, type your comment in the pop-up window,
  and click :guilabel:`Submit`.
  On mobile screens, an :guilabel:`Error?` button appears at the bottom of the screen,
  which opens the same pop-up window.
  You can point out an error,
  provide feedback on the current article, or suggest changes.
  We review each comment and work with it.
* **Advanced**: All Tarantool documentation tasks can be found in the
  `repository <https://github.com/tarantool/doc/issues>`_.
  Go to any task and suggest your changes.
  We write our documentation using
  `reStructuredText markup <https://docutils.sourceforge.io/docs/ref/rst/restructuredtext.html>`_,
  and we have a :doc:`writing style guide <docs>`.
  After you make the change, build the documentation locally and
  see how it works. This can be done automatically in Docker.
  To learn more, check the `README of the tarantool/doc repository <https://github.com/tarantool/doc>`_.

Some Tarantool projects have their documentation in the code repository.
This is typical for modules, for example, `metrics <https://github.com/tarantool/metrics/>`_.
This is done on purpose, so the developers themselves can update it faster.
You can find instructions for building such documentation in the code repository.

If you find that the documentation provided in the README of a module or
a connector is incomplete or wrong, the best way to influence this is to fix it
yourself. Clone the repository, fix the bug, and suggest changes in a pull request.
It will take you five minutes but it will help the whole community.

If you cannot fix it for any reason, create a ticket in the repository
and report the error. It will be fixed promptly.


How to contribute to modules
----------------------------

Tarantool is a database with an embedded application server.
This means you can write any code in C or Lua and pack it in distributable modules.

We have official and unofficial modules.
Here are some of our official modules:

* `HTTP server <https://github.com/tarantool/http>`_: HTTP server implementation
  with middleware support.
* `queue <https://github.com/tarantool/queue>`_: Tarantool implementation of
  the persistent message queue.
* `metrics <https://github.com/tarantool/metrics>`_: Ready-to-use solution for
  collecting metrics.

Official modules are provided in our organization on GitHub.

All modules are distributed through our package manager, which is
pre-installed with Tarantool.
That also applies to unofficial modules, which means that
other users can get your module easily.

If you want to add your module to our GitHub organization,
`send us a message on Telegram <https://t.me/arturbrsg>`_.


Contributing to an existing module
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tasks for contributors can be found in the issues section of any repository
under the "good first issue" tag. These tasks are beginner or intermediate
in terms of difficulty level, so you can comfortably get used to the module of your interest.

Check the
`currently open tasks <https://github.com/tarantool/http/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22>`_
for the HTTP Server module.

Please see our :doc:`Lua style guide </dev_guide/lua_style_guide>`.

You can find the contact of the current maintainer in the MAINTAINERS file, located
in the root of the repository. If there is no such file, please
`let us know <https://t.me/arturbrsg>`_.
We will respond within two days.

If you see that the project does not have a maintainer or is inactive, you can
become its maintainer yourself.
See the :ref:`How to become a maintainer <contributing-how_to_become_a_maintainer>` section.


Creating a new module
~~~~~~~~~~~~~~~~~~~~~

You can also create custom modules and share them with the community.
`Look at the module template <https://github.com/tarantool/modulekit>`_
and write your own.


How to contribute to Tarantool Core
-----------------------------------

Tarantool is written mostly in C.
Some parts are in C++ and Lua.
Your contributions to Tarantool Core
may take longer to review because we want the code to be reliable.

To start:

* :doc:`Learn how to build Tarantool </dev_guide/building_from_source>`.
* Read about Tarantool architecture and main modules on the
  `developer site <https://docs.tarantool.dev/en/latest/>`__ and on
  `GitHub <https://github.com/tarantool/tarantool/wiki/Developer-information>`__.

In Tarantool development, we strive to follow the standards laid out in
our :doc:`style and contribution guides </dev_guide/developer_guidelines>`.
These documents explain how to format your code and commits as well as
how to write tests without breaking anything accidentally.

The guidelines also help you create patches that are easy to check, which allows
quickly pushing changes to master.

Please read about
`our code review procedure <https://github.com/tarantool/tarantool/wiki/Code-review-procedure#general-coding-points-to-check>`_
before making your first commit.

You can suggest a patch using the fork and pull mechanism on GitHub: Make changes to your
copy of the repository and submit it to us for review. Check the
`GitHub documentation <https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork>`__
to learn how to do it.


How to write tests
------------------

A database is a product that is expected to be as reliable as possible.
We at Tarantool created ``test-run``, a dedicated test framework for developing
scripts that test Tarantool itself.

Writing your own test is not difficult. Check out the following examples:

* `C unit test <https://github.com/tarantool/tarantool/blob/7b7a0c088f4fd25245d1d34544a2cd30589436e9/test/unit/csv.c>`_
* `Lua unit test <https://github.com/tarantool/tarantool/blob/7b7a0c088f4fd25245d1d34544a2cd30589436e9/test/app/fio.test.lua>`_

We also have a CI workflow that automatically checks build and test coverage for new
changes on all supported operating systems.
The workflow is launched after every commit to the repository.

We have many tasks for QA specialists. Our QA team provides test coverage for our products,
helps develop the test framework, and introduces and maintains new tools to test
the stability of our releases.

For modules, we use `luatest <https://github.com/tarantool/luatest>`_---
our fork of a framework popular in the Lua community,
enhanced and optimized for our tasks.
See `examples <https://github.com/tarantool/metrics/tree/master/test>`_.
of writing tests for a module.

..  // Read: writing tests in Tarantool, writing unit tests. ???


How to contribute to language connectors
----------------------------------------

A connector is a library that provides an API to access Tarantool from
a programming language. Tarantool uses its own binary protocol for access,
and the connector's task is to transfer user requests to the database and
application server in the required format.

Data access connectors have already been implemented for all major languages.
If you want to write your own connector,
you first need to familiarize yourself with the Tarantool binary protocol.
Read :doc:`the protocol description </dev_guide/internals/box_protocol>` to learn more.

We consider the following connectors as references:

* https://github.com/tarantool-php/client
* `net.box <https://github.com/tarantool/tarantool/blob/master/src/box/lua/net_box.lua>`_---Tarantool
  binary protocol client

You can look at them to understand how to do it right.

Some connectors in the Tarantool ecosystem are supported by the Tarantool team.
Others are developed and supported exclusively by the community.
All of them have their pros and cons. See the
`complete list of connectors and their recommended versions <https://www.tarantool.io/en/download/connectors>`_.

If you are using a community connector and want to implement
new features for it or fix a bug, send your PRs via GitHub to the connector repository.

If you have questions for the author of the connector, check the
MAINTAINERS file for the repository maintainer's contact.
If there is no such file, `send us a message on Telegram <https://t.me/arturbrsg>`_.
We will help you figure it out. We usually answer within one day.


How to contribute to tools
--------------------------

The Tarantool ecosystem has tools that facilitate the workflow,
help with application deployment, or allow working with Kubernetes.

Here are some of the tools created by the Tarantool team:

* `tt <https://github.com/tarantool/tt>`_:
  a CLI utility for creating and managing Tarantool applications.
* `tarantool-operator <https://github.com/tarantool/tarantool-operator>`_:
  a Kubernetes operator for cluster orchestration.

These tools can be installed via standard package managers:
``ansible galaxy``, ``yum``, or ``apt-get``.

If you have a tool that might go well in our curated
`Awesome Tarantool list <https://github.com/tarantool/awesome-tarantool>`_,
read the
`guide for contributors <https://github.com/tarantool/awesome-tarantool/blob/master/CONTRIBUTING.md>`_
and submit a pull request.

.. _contributing-how_to_become_a_maintainer:

How to become a maintainer
--------------------------

Maintainers are people who can merge PRs or commit to master.
We expect maintainers to answer questions and tickets on time as well as do code reviews.

If you need to get a review but no one responds within a week, take a look at the
Maintainers section of the repository's ``README.md``.
Write to the person listed there.
If you have not received an answer within 3--4 days, you can escalate the question
`on Telegram <https://t.me/arturbrsg>`__.

A repository may have no maintainers (empty Maintainers list in ``README.md``),
or the existing maintainers may be inactive. In this case, you can become a maintainer yourself.
We think it's better if the repository is maintained by a newbie than if the
repository is dead. So don't be shy: we love maintainers and help them figure it all out.

All you need to do is fill out
`this form <https://docs.google.com/forms/d/1RihU9hQkbY5n7hU-3ZOr6t1L6cJKOlJcETowD_cNeOk/edit?usp=sharing>`_.
Tell us what repository you want to access,
the reason (inactivity, the maintainer is not responding),
and how to contact you.
We will consider your application in 1 day and either give you the rights
or tell you what else needs to be done.
