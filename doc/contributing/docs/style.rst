
Language and style
==================

..  contents::
    :maxdepth: 2


General style
-------------

Concise is good
~~~~~~~~~~~~~~~

People usually read technical documentation because they want something
up and running quickly. Write simpler, more concise sentences.

Split the content into smaller paragraphs to improve readability.
This will also eliminate the need for using ``|br|`` and help us translate content faster.
Any paragraph over 6 sentences is large.

Keep your audience in mind
~~~~~~~~~~~~~~~~~~~~~~~~~~

Consider your audience's level. A getting started guide should be written
in simpler terms than an advanced internals description.

If you choose to use metaphors to clarify a concept, make sure they are relatable
for an international audience of IT professionals. 

..  
    _Don't say "we"!
    _~~~~~~~~~~~~~~!

    _Avoid using the pronoun "we", because it is unclear who that is exactly.!
    _`Consider how Gentoo does it <https://wiki.gentoo.org/wiki/Gentoo_Wiki:Guidelines#Avoid_first_and_second_person_writing>`__.!

Express one idea in a sentence
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

Put examples next to theory
~~~~~~~~~~~~~~~~~~~~~~~~~~~

It's best if examples immediately follow the concept they illustrate.
The readers wouldn't want to look for the examples in a different part of the article.

Specify link text
~~~~~~~~~~~~~~~~~

When you provide a :doc:`link </contributing/docs/markup/links>`, clearly specify
where it leads. In this way, you will not mislead the reader.

Bad example:

    For more details, click :doc:`here </contributing/docs/markup/links>`.

    Use :doc:`this </contributing/docs/markup/links>`.

Good example:

    For more details, refer to the documentation on
    :doc:`making links </contributing/docs/markup/links>`.

    Use full :doc:`link names </contributing/docs/markup/links>`.

Formatting
----------

Use lists and tables
~~~~~~~~~~~~~~~~~~~~

Lists and tables help split heavy content into manageable chunks.

To make tables maintainable and easy to translate,
use the ``list-table`` directive, as described in the Tarantool
:doc:`table markup reference <contributing/docs/markup/tables>`__.

Translators find it hard to work with content "drawn" with ASCII characters,
because it requires adjusting the number of spaces and manually counting characters.

Bad example:

..  image:: images/dont.png
    :alt: Don't "draw" tables with ASCII characters

Good example:

..  image:: images/do.png
    :alt: Use the "list-table" directive instead


Format code as code
~~~~~~~~~~~~~~~~~~~

Format large code fragments using the ``code-block`` directive, indicating the language.
For ``shorter code snippets``, make sure that only code goes in the backticks.
Non-code shouldn't be formatted as code, because this confuses users (and translators, too).
Check our guidelines on
`writing about code <https://www.tarantool.io/en/doc/latest/contributing/docs/markup/code/>`__.

For more on formatting, check out the full :doc:`markup reference <contributing/docs/markup>`.


Word choice
-----------

Instance vs server
~~~~~~~~~~~~~~~~~~

We say "instance" rather than "server" to refer to a Tarantool
server instance. This keeps the manual terminology consistent with names like
``/etc/tarantool/instances.enabled`` in the Tarantool environment.

Wrong usage: "Replication allows multiple Tarantool *servers* to work with copies
of the same database."

Correct usage: "Replication allows multiple Tarantool *instances* to work with
copies of the same database."

Don't use i.e. and e.g.
~~~~~~~~~~~~~~~~~~~~~~~

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


    
Spelling and punctuation
------------------------

US vs British spelling
~~~~~~~~~~~~~~~~~~~~~~

We use the US English spelling.

Check your spelling and punctuation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Consider checking spelling, grammar, and punctuation with special tools.

Consistent ending punctuation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Make sure that your lists and tables have consistent punctuation---either
all similar list/table items end with a period or they all don't.
In the example below, *all* items in the second column don't have
ending punctuation. Meanwhile, *all* items in the fourth column end with a period:

..  image:: images/punctuation.png
    :alt: Items in one column have similar ending punctuation
