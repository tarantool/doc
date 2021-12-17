.. _getting_started-wrirting_cluster-code:

=================================================================================
Writing cluster application code
=================================================================================

In the "Getting Started" tutorial,
we wrote the application code directly in the browser.
We used the file ``config.yml`` to describe HTTP endpoint handlers.
This is a convenient and fast way to write code
that allows you to use Tarantool as a repository without any additional HTTP service.
This functionality is implemented through the ``cartridge-extensions`` module.
It is also included in the tutorial default application.

However, in Tarantool, you can implement absolutely any business logic on top of a cluster.
In this section, we will learn about cluster roles
and write a cluster application from scratch.

.. include:: getting_started_cartridge.rst