
================================================================================
Language and style
================================================================================

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
US vs British spelling
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We use English US spelling.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Instance vs server
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We say "instance" rather than "server" to refer to an instance of Tarantool
server. This keeps the manual terminology consistent with names like
``/etc/tarantool/instances.enabled`` in the Tarantool environment.

Wrong usage: "Replication allows multiple Tarantool *servers* to work on copies
of the same databases."

Correct usage: "Replication allows multiple Tarantool *instances* to work on
copies of the same databases."


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Express one idea in a sentence
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

        *   -   A replica set from which the bucket is being migrated is called a source;
                a target replica set to which the bucket is being migrated is called a destination.
            -   A replica set from which the bucket is being migrated is called a source.
                A target replica set to which the bucket is being migrated is called a destination.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Don't use i.e. and e.g.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Don't use the following contractions:

*   `"i.e." <https://www.merriam-webster.com/dictionary/i.e.>`_
    —from Latin "id est". Use "that is" or "which means" instead.
*   `"e.g." <https://www.merriam-webster.com/dictionary/e.g.>`_
    —from Latin "exempli gratia". Use "for example" or "such as" instead.

Many people, especially non-native English speakers,
aren't familiar or don't know the difference between
`"i.e." and "e.g." contractions
<https://www.merriam-webster.com/words-at-play/ie-vs-eg-abbreviation-meaning-usage-difference>`_.
So it's best to avoid using them.