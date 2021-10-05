
Language and style
==================

US vs British spelling
----------------------

We use the US English spelling.

Instance vs server
------------------

We say "instance" rather than "server" to refer to a Tarantool
server instance. This keeps the manual terminology consistent with names like
``/etc/tarantool/instances.enabled`` in the Tarantool environment.

Wrong usage: "Replication allows multiple Tarantool *servers* to work with copies
of the same database."

Correct usage: "Replication allows multiple Tarantool *instances* to work with
copies of the same database."

Express one idea in a sentence
------------------------------

Say exactly one thing in a sentence.
If you want to define or clarify something, do it in a separate sentence.
Simple sentences are easier to read, understand and translate.

..  rst-class:: table-example
..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :header-rows: 1

        *   -   Don't
            -   Do

        *   -   Dogs (I have three of them) are my favourite animals.
                Their names are Ace, Bingo and Charm; Charm is the youngest one.

            -   Dogs are my favourite animals.
                I have three of them.
                Their names are Ace, Bingo and Charm.
                Charm is the youngest one.

        *   -   memtx (the in-memory storage engine) is the default and was the first to arrive.
            -   memtx is an in-memory storage engine.
                It is the default and was the first to arrive.

        *   -   The replica set from where the bucket is being migrated is called the source;
                the target replica set where the bucket is being migrated to is called the destination.
            -   The replica set from where the bucket is being migrated is called the source.
                The target replica set where the bucket is being migrated to is called the destination.

Don't use i.e. and e.g.
-----------------------

Don't use the following contractions:

*   `"i.e." <https://www.merriam-webster.com/dictionary/i.e.>`_---from
    the Latin "id est". Use "that is" or "which means" instead.
*   `"e.g." <https://www.merriam-webster.com/dictionary/e.g.>`_---from
    the Latin "exempli gratia". Use "for example" or "such as" instead.

Many people, especially non-native English speakers,
aren't familiar with the
`"i.e." and "e.g." contractions
<https://www.merriam-webster.com/words-at-play/ie-vs-eg-abbreviation-meaning-usage-difference>`_
or don't know the difference between them.
For this reason, it's best to avoid using them.

Specify link text
-----------------

When you provide a :doc:`link </contributing/docs/markup/links>`, clearly specify
where it leads. In this way, you will not mislead the reader.

Bad example:

    For more details, click :doc:`here </contributing/docs/markup/links>`.

    Use :doc:`this </contributing/docs/markup/links>`.

Good example:

    For more details, refer to the documentation on
    :doc:`making links </contributing/docs/markup/links>`.

    Use full :doc:`link names </contributing/docs/markup/links>`.
    