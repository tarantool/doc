--------------------------------------------------------------------------------
What Tarantool's SQL product delivers
--------------------------------------------------------------------------------

Tarantool's SQL is a major new feature that was first introduced with Tarantool version 2.1. |br|
The primary advantages are: |br|
- a high level of SQL compatibility |br|
- an easy way to switch from NoSQL to SQL and back |br|
- the Tarantool brand.

The "high level of SQL compatibility" includes support for joins, subqueries, triggers,
indexes, groupings, transactions in a multi-user environment, and conformance with the
majority of the mandatory requirements of the SQL:2016 standard.

The "easy way to switch" consists of the fact that the same tables can be operated
on with SQL and with the  long-established Tarantool-NoSQL product, meaning that
when you want standard Relational-DBMS jobs you can do them, and when you want NoSQL capability
you can have it (Tarantool-NoSQL outperforms other NoSQL products in public benchmarks).

The "Tarantool brand" comes from the support of a multi-billion-dollar internet / mail / social-network
provider, a dozens-of-professionals staff of programmers and support people, a community who believes
in open-source BSD licensing, and hundreds of corporations / government bodies using Tarantool products in production already.

The status of Tarantool's SQL feature is "release". So, it is working now and you can verify
that by downloading it and trying all the features, which will be explained in the rest of this document.
There is also a :ref:`tutorial <sql_tutorial>`.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Differences from other products
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Differences from other SQL products:
The Tarantool design requirement is that Tarantool's SQL conforms to the majority of the listed
mandatory requirements of the core SQL:2016 standard, and this
will be shown in the specific conformance statements in the feature list
in a section about :ref:`"compliance with the official SQL standard" <sql>`.
Possibly the deviations which most people will find notable are:
type checking is less strict,
and some data definition options must be done with NoSQL syntax.

Differences from other NoSQL products:
By examining attempts by others to paste relatively smaller
subsets of SQL onto NoSQL products, it should be possible to conclude that Tarantool's
SQL has demonstrably more features and capabilities.
The reason is that the Tarantool developers started with a complete code base of
a working SQL DBMS and made it work with Tarantool-NoSQL underneath,
rather than starting with a NoSQL DBMS and adding syntax to it.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
What Tarantool's SQL manual delivers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following parts of this document are: |br|
The :ref:`SQL User Guide <sql_user_guide>` explains "How to get Started" and explains the terms and the syntax elements that
apply for all SQL statements. |br|
The :ref:`SQL Statements and Clauses <sql_statements_and_clauses>` guide explains, for each SQL statement, the format and the rules
and the exceptions and the examples and the limitations. |br|
The :ref:`SQL Plus Lua <sql_plus_lua>` guide has the details about calling Lua from SQL, calling SQL from Lua,
and using the same database objects in both SQL and Lua. |br|
The :ref:`SQL Features <sql>` list shows how the product conforms with the mandatory features of the SQL standard.

Users are expected to know what databases are, and experience with other SQL DBMSs would be an advantage.
To learn about the basics  of relational database management and SQL in particular,
check the :ref:`SQL Beginners' Guide <sql_beginners_guide>` in the :ref:`How-to guides <how-to>` section.
