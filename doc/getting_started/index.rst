:noindex:
:fullwidth:

.. _getting_started:

********************************************************************************
Getting started
********************************************************************************

The :ref:`First steps <getting_started-imcp>` section
will get you acquainted with Tarantool in 15 minutes.
We will be creating a basic microservice for TikTok.
We will start Tarantool, create a data schema, and write our first data.
You'll get an understanding of the technology and learn about the basic terms and features.

In the :ref:`Connecting to cluster <connecting_to_cluster>` section,
we'll show you how to read or write data to Tarantool
from your Python/Go/PHP application or another programming language.

After connecting to the database for the first time, you might want to change the data schema.
In the section :ref:`Updating the data schema <getting_started-schema_changing>`,
we'll discuss the approaches to changing the data schema and the associated limitations.

To make our code work with Tarantool,
we may want to transfer some of our data logic to Tarantool.
In the section :ref:`Writing cluster application code <getting_started-wrirting_cluster-code>`,
we'll write a "Hello, World!" program in the Lua language,
which will work in our Tarantool cluster.
This will give you a basic understanding of how the role mechanism works.
In this way, you'll understand what part of your business logic you would like
to write in/migrate to Tarantool.

.. toctree::
   :maxdepth: 1

   getting_started_imcp
   connecting_to_cluster
   change_schema_dynamically
   writing_cluster_code
   whats_next
