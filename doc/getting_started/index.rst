:noindex:
:fullwidth:

.. _getting_started:

********************************************************************************
Getting started
********************************************************************************

In the section :ref:`First steps <getting_started-imcp>` we will get acquainted with Tarantool: start it, create a data schema and write the first data. It will give you a basic understanding of the technology and introduce you to basic terms and features. You will learn about Tarantool by creating a basic microservice for the Tiktok service. This section is completed in 15 minutes.

Next, we'll show you how to read or write data to Tarantool from your Python/Go/PHP application or another programming language. It will be under :ref:`Connecting to cluster <connecting_to_cluster>`.

After connecting to the database for the first time, you might want to change the data schema. In the section :ref:`Updating the data schema <getting_started-schema_changing>` we will discuss the limitations and approaches to changing the data schema.

When we prepare our code for working with Tarantool, we may want to transfer some of the logic for working with data into Tarantool itself. In the section :ref:`Writing cluster application code <getting_started-wrirting_cluster-code>` we will write "Hello, World!" in the Lua language, which will work in our Tarantool cluster. This will give you a basic understanding of how the role mechanism works and you will be able to understand what part of the business logic you would like to write/migrate to Tarantool.

.. toctree::
   :maxdepth: 1

   getting_started_imcp
   connecting_to_cluster
   change_schema_dynamically
   writing_cluster_code
