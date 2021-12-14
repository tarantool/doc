.. _getting_started-wrirting_cluster-code:

=================================================================================
Writing code in a clustered application
=================================================================================

In the article "Getting Started", we wrote the application code directly in the browser and using the file ``config.yml`` described handlers for HTTP endpoints. This is a convenient and fast way to write code that allows you to use Tarantool as a repository without any additional HTTP service.
This functionality is implemented through the module ``cartridge-extensions``. It is also included in the tutorial default application.

However, in Tarantool, you can implement absolutely any business logic on top of a cluster.
In this section, we will learn about the clustered role mechanism and write a clustered application from scratch.

.. include:: getting_started_cartridge.rst