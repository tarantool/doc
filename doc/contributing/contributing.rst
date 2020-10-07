.. _contributing:

================================================================================
How to be involved in Tarantool
================================================================================

--------------------------------------------------------------------------------
What is Tarantool?
--------------------------------------------------------------------------------

Tarantool is an open source database that can store everything in RAM.
Use Tarantool as a cache with the ability to save data to disk.
Tarantool serves up to a million requests per second, secondary index searches,
and SQL support.

In Tarantool, you can execute code alongside data.
This allows for faster operations.
Implement any business logic in Lua.
Get rid of stale entries, sync with other data sources, implement an HTTP service.

Go to :ref:`Getting Started <getting_started>` and try Tarantool.

--------------------------------------------------------------------------------
How to get help?
--------------------------------------------------------------------------------

We have a `special Telegram chat <https://t.me/tarantool_contrib>`_
for contributors.
We speak Russian and English in the chat.

This is the easiest way to get your questions answered.
Many people are afraid to ask questions because they think they are
"wasting the experts' time," but no one really thinks so.
Contributors are important to us.

Also we have a
`Stackoverflow tag <https://stackoverflow.com/questions/tagged/tarantool>`_.

Join the chat and ask questions.

--------------------------------------------------------------------------------
How to leave feedback, idea or suggestion?
--------------------------------------------------------------------------------

You can leave your feedback or share ideas in different ways:

* **The simplest way** is to write
  `here <https://docs.google.com/forms/d/1iwBj_2in-rBIYEcPeeVPQa4JfUIU_m14IUbAK4NojIE/edit?usp=sharing>`_.
  All you need to do is fill in one product comment field and send it to us.
  If you don't mind -- leave your email address.
  If you wish, we can involve you in the product development process.
* **A more technical way** is to create a ticket on Github.
  If you have a suggestion for a new feature or information about a bug,
  `follow the link <https://github.com/tarantool/tarantool/issues/new>`_
  and leave a ticket.
  The link leads to the ``tarantool/tarantool`` repository.
  For any other projects on Github select "Issues" - "New issue".

See `an example of a feature request <https://github.com/tarantool/tarantool/issues/5046>`_.

You can chat with the team in the general product chat.
They are divided by language:

* `Russian-speaking <https://t.me/tarantoolru>`_
* `English-speaking <https://t.me/tarantool>`_

If this communication channel is inconvenient for you or there is simply no Telegram,
you can leave your comment on `tarantool.io <http://www.tarantool.io>`_.
Fill out the form at the bottom of the site and leave your email.
We read each request and respond to them usually within 2 days.

--------------------------------------------------------------------------------
How to contribute?
--------------------------------------------------------------------------------

There are many ways to contribute to Tarantool:

* Code -- Contribute to the code.
  We have components written in C, Lua, Python, Go, and other languages.
* Write -- Improve documentation, write blogposts, create tutorials or solution pages.
* Q&A -- Share your acknowledgments at Stackoverflow with tag
  `#tarantool <https://stackoverflow.com/questions/tagged/tarantool>`_.
* Spread the word -- Share your accomplishments in social media using the
  ``#tarantool`` hashtags (or CC ``@tarantooldb`` in Twitter).

--------------------------------------------------------------------------------
Tarantool Ecosystem
--------------------------------------------------------------------------------

Tarantool has a large ecosystem of tools around the product itself.

We divide the Tarantool ecosystem into 4 types:

* Tarantool itself.
* Modules for Tarantool. They can be written in C and Lua.
* Connectors for programming languages.
* Applied tools. For example, Kubernetes operator, Ansible role for deployment,
  or ``tarantool-admin`` utility for viewing data in Tarantool via GUI.

First-time tasks can be easily found in the issues section of any repository by
the "good first issue" tag. These are beginner to intermediate tasks that will
help you get comfortable with the tool.

See the `list of tasks <https://github.com/tarantool/tarantool/labels/good%20first%20issue>`_
for the ``tarantool/tarantool`` repository.

For each repository we have a queue for reviewing,
and reviewing your changes can be delayed.
We try to give the first answer within two days.
Depending on the ticket and its complexity, the review time may take a week or more.

Please do not hesitate to tag the maintainer in your Github ticket.

Read further about the contribution to each of the blocks.

--------------------------------------------------------------------------------
You have a problem in documentation. How to tell about it and how to fix it?
--------------------------------------------------------------------------------

There are several ways to improve the documentation:

* **The easiest one** is to leave your comment on the web documentation page.
  All you need to do is click on the red button in the bottom right corner
  of the page and fill in the comment field. You can point out an error,
  provide feedback on the current article, or suggest changes.
  We review each comment and take it to work.
  This form is built into the documentation on the Tarantool website.
* **Advanced** -- All Tarantool documentation tasks are
  `in the repository <https://github.com/tarantool/doc/issues>`_.
  Here you can take any tasks and suggest your changes.
  Our documentation is written in the `ReST format <https://docutils.sourceforge.io/docs/ref/rst/restructuredtext.html>`_.
  :ref:`Here <documentation_guidelines>` is our Style Guide for writers.
  After making the change, you need to build the documentation locally and
  see how it was laid out. This is done automatically in Docker.
  `Read more in the README of the tarantool/doc repository. <https://github.com/tarantool/doc>`_

Some projects have their documentation in the code repository.
For example, `Tarantool Cartridge <https://github.com/tarantool/cartridge/>`_.
This is done on purpose, so the developers themselves can update it faster.
Instructions for building such documentation sets are in the code repository.

If you find that the documentation in the README of a module or, for example,
a connector is incomplete or wrong, the best way to influence this is to fix it
yourself. Clone the repository, fix the bug, and suggest changes as a PR.
It will take you 5 minutes and will help the whole community.

If for some reason you cannot fix it, create a ticket in this repository
and report the error. Such errors are fixed quickly.

--------------------------------------------------------------------------------
How to contribute to modules
--------------------------------------------------------------------------------

Tarantool is a database with an embedded application server.
You can write any code in C and Lua and pack it in distributable modules.

Here are examples of official modules:

* `HTTP server <https://github.com/tarantool/http>`_ -- HTTP server implementation
  with middleware support.
* `queue <https://github.com/tarantool/queue>`_ - Tarantool implementation of
  a persistent message queue.
* `metrics <https://github.com/tarantool/metrics>`_ - ready-to-use solution for
  collecting metrics.
* `cartridge <https://github.com/tarantool/cartridge>`_ - framework for writing
  distributed applications.

Modules are distributed through our package manager, which is already
preinstalled with Tarantool.

We have official modules and unofficial ones.
The official ones are those that are in our organization on Github.
But we distribute unofficial ones via our package manager too so that other
users can get your module easily.
If you want to add your module to our Github organization --
`text us here <https://t.me/arturbrsg>`_.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Want to contribute to an existing module
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tasks for contributors can be easily found in the issues section of any repository
by the "good first issue" tag. These are tasks of an initial or intermediate
level of difficulty that will help you get comfortable in the module of interest.

Look at the
`currently open tasks <https://github.com/tarantool/http/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22>`_
for the HTTP Server module.

The style guide for the Lua code we are following is :ref:`here <lua_style_guide>`.

You can contact the current maintainer through MAINTAINERS, which is located
in the root of the repository. If there is not such a file --
`let us know <https://t.me/arturbrsg>`_.
We will respond within one to two days.

If you see that the project does not have a maintainer or is inactive, you can
become one yourself.
See the section :ref:`How to become a maintainer <how_to_become_a_maintainer>`.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Want to create a new module
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can also create any custom modules and share them with the community.
`Look at the module template <https://github.com/tarantool/modulekit>`_
and write your own one.

--------------------------------------------------------------------------------
How to contribute to Tarantool Core
--------------------------------------------------------------------------------

Tarantool is written mostly in C.
Some parts are written in C++ and Lua.
Review can take longer because we want it to be reliable.

To start:

* :ref:`learn how to build Tarantool <building_from_source>`
* :ref:`run the test suite <run_test_suite>`
* read about Tarantool architecture and main modules
  (`here <https://docs.tarantool.dev/en/latest/>`_ and
  `here <https://github.com/tarantool/tarantool/wiki/Developer-information>`_)

We have standards that we try to adhere to when developing in Tarantool.
These are Style Guide and Contribution Guide :ref:`links <developer_guidelines>`.
They tell you how to format your code, how to format your commits, and how to
write your test and make sure you don't break anything.

They will also help you make a patch that is easier to check, which will allow
you to quickly push changes to master.

Before your first commit, read
`this article <https://github.com/tarantool/tarantool/wiki/Code-review-procedure#general-coding-points-to-check>`_!

A patch can be offered in two ways:

* (preferred) Using a fork and pull mechanism on Github: make changes to your
  copy of the repository and submit to us for review.
  See details `here <https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork>`_.
* Suggest a patch via the mailing list. Our developers are discussing most of
  the features there.
  See details :ref:`here <dev_guidelines-patch-review>`.

--------------------------------------------------------------------------------
How to write a test
--------------------------------------------------------------------------------

The database is the product that is expected to be as reliable as possible.
We at Tarantool have developed a dedicated test framework for developing
test scripts that test Tarantool itself. The framework is called ``test-run``.

Writing your own test is not difficult. See test examples here:

* `C unit test <https://github.com/tarantool/tarantool/blob/7b7a0c088f4fd25245d1d34544a2cd30589436e9/test/unit/csv.c>`_
* `Lua unit test <https://github.com/tarantool/tarantool/blob/7b7a0c088f4fd25245d1d34544a2cd30589436e9/test/app/fio.test.lua>`_

We also have a CI that automatically checks build and test coverage for new
changes on all supported operating systems.
This happens after any commit to the repository.

The QA team has many tasks for specialists who are involved in checking the
quality of the product and tools. They provide test coverage for products,
help develop the test framework, and introduce and maintain new tools to test
the stability of releases.

We test modules differently: for modules, we use the
`luatest <https://github.com/tarantool/luatest>`_ framework.
This is a fork of the popular framework in the Lua community, which we have
enhanced and optimized for our tasks.
See `examples <https://github.com/tarantool/metrics/tree/master/test>`_.
of writing tests for a module.

Read: writing tests in Tarantool, writing unit tests. ???

--------------------------------------------------------------------------------
How to contribute to language connectors
--------------------------------------------------------------------------------

A connector is a library that provides an API for accessing Tarantool from
a programming language. Tarantool uses its own binary protocol for access,
and the connector's task is to transfer user requests to the database and
application server in the required format.

Data access connectors have already been implemented for all major languages.
If you want to write your own connector, you first need to familiarize yourself with the Tarantool binary protocol. Its current description can be found :ref:`here <box_protocol-iproto_protocol>`.

We consider the following connectors as reference:

* https://github.com/tarantool-php/client
* `net.box <https://github.com/tarantool/tarantool/blob/master/src/box/lua/net_box.lua>`_ — binary protocol client in Tarantool

You can look at them to understand how to do it right.

The Tarantool ecosystem has connectors that are supported by the Tarantool team
itself, and there are those that are developed and supported exclusively by the
community. All of them have their pros and cons. See a
`complete list of connectors and their recommended versions <https://www.tarantool.io/en/download/connectors>`_.

If you are using an existing connector from the community and want to implement
new features or fix a bug, then send your PRs via Github to the desired repository.

To contact the author of the connector in case of questions, look in the
MAINTAINERS file: there will be contacts of the repository maintainer.
If there is no such file -- `text us here <https://t.me/arturbrsg>`_.
We will help you figure it out. We usually answer within one day.

--------------------------------------------------------------------------------
How to contribute to tools
--------------------------------------------------------------------------------

The Tarantool ecosystem has tools that help in operation, deploy applications,
or allow working with Kubernetes.

Examples of tools from the Tarantool team:

* `ansible-cartridge <https://github.com/tarantool/ansible-cartridge>`_:
  Ansible role for deploying an application on Cartridge
* `cartridge-cli <https://github.com/tarantool/cartridge-cli>`_:
  CLI utility for creating applications, launching clusters locally on Cartridge
  and solving operational problems
* `tarantool-operator <https://github.com/tarantool/tarantool-operator>`_:
  Kubernetes operator for cluster orchestration

These tools can be installed via standard package managers:
``ansible galaxy``, ``yum``, ``apt-get``, respectively.

.. _how_to_become_a_maintainer:

--------------------------------------------------------------------------------
How to become a maintainer
--------------------------------------------------------------------------------

Maintainers are people who can merge PRs or commit to master.
We expect maintainers to answer questions and tickets in time, and do code reviews.

If you need to get a review but no one responds for a week, take a look at the
Maintainers section of the ``README.md`` in the repository.
Write to the person listed there.
If you have not received an answer in 3-4 days, you can escalate the question
`here <https://t.me/arturbrsg>`_.

A repository may have no maintainers (the Maintainers list in ``README.md`` is empty),
or existing maintainers may be inactive. Then you can become a maintainer yourself.
We think it's better if the repository is maintained by a newbie than if the
repository is dead. So don't be shy: we love maintainers and help them figure it out.

All you need to do is fill out
`this form <https://docs.google.com/forms/d/1RihU9hQkbY5n7hU-3ZOr6t1L6cJKOlJcETowD_cNeOk/edit?usp=sharing>`_.
Indicate which repository you want to access,
the reason (inactivity, the maintainer is not responding),
and how to contact you.
We will consider the application in 1 day and either give you the rights
or tell you what else needs to be done.
