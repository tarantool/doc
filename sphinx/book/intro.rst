-------------------------------------------------------------------------------
                             Preface
-------------------------------------------------------------------------------

Welcome to Tarantool. This is the User Guide.
We recommend reading this first, and afterwards
reading the Reference chapters which have more detail.

===============================================================================
                    How to read the documentation
===============================================================================

To get started, you can either download the whole package
as described in the first part of Chapter 2 "Getting started",
or you can initially skip the download and connect to the online
Tarantool server running on the web at http://try.tarantool.org.
Either way, the first tryout can be a matter of following the example
in the second part of chapter 2: "Starting Tarantool and making your first
database".

Chapter 3 "Database" is about the Tarantool NoSQL DBMS.
If the only intent is to use Tarantool as a Lua application server,
most of the material in this chapter and in the following chapter
(Chapter 4 "Replication") will not be necessary.
Once again, the detailed instructions about each module in chapter 3 "Database"
can be regarded as reference material.

Chapter 5 "Configuration reference" and Chapter 6 "Server administration"
are primarily for administrators; however, every user should know something
about how the server is configured, so the section about box.cfg is not skippable.

Chapter 7 "Connectors" is strictly for users who are connecting from a different
language such as C or Perl or Python -- other users will find no immediate need
for this chapter.

Chapter 8 "Modules" shows how to install modules (libraries)
and how to create new ones in Lua or C.

The first two Appendices, A and B, contain reference information about 
Tarantool's code errors, internal file formats and internal processes (recovery
and replication).

The three long tutorials in Appendix C -- "Insert one million tuples with a Lua
stored procedure", "Sum a JSON field for all tuples" and "Indexed Pattern
Search" -- start slowly and contain commentary that is especially aimed at users
who may not consider themselves experts at either Lua or NoSQL database management.

Appendix D "Vinyl" provides details about Tarantool's disk storage
engine named `vinyl`.

Appendix E "Cookbook" shows some code contributions for common or difficult tasks.

Appendix F has one long tutorial: "C stored procedures".

Appendix G "Version-specific changes" summarizes significant changes introduced
in newer Tarantool versions.

For experienced users, there are also Reference documents plus a Developer Guide,
and an extensive set of comments in the source code.

===============================================================================
             Getting in touch with the Tarantool community
===============================================================================

Please report bugs or make feature requests at http://github.com/tarantool/tarantool/issues.

You can contact developers directly in `telegram <http://telegram.me/tarantool>`_
or in a Tarantool discussion group
(`English <https://groups.google.com/forum/#!forum/tarantool>`_ or
`Russian <https://googlegroups.com/group/tarantool-ru>`_).




