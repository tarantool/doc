Defining and using terms
========================

What are concepts and terms
---------------------------

To write well about some subject matter, one needs to know the objects of this subject matter
and use the right, carefully selected words for them.
Such objects are called concepts, and the words for them are called terms.

..  glossary::

    concept
        The concept is the idea of some object, attribute, or action.
        It is independent of languages, audience, and products. It just exists.

        For example, a large database can be partitioned into smaller instances,
        which are easier to operate and can exceed the throughput of
        a single large database instance. Such instances can exchange data
        for keeping it consistent between them.

    term
        The term is a word, which authors or a particular book, article, or documentation set
        have explicitly selected to denote a :term:`concept` in a particular language
        and for a particular audience.

        For example, in Tarantool, we use the term "[database] sharding" to denote the
        concept mentioned in the previous example.

Use preferred terms
-------------------

The purpose of using terms is to write concisely and unambiguously,
which is good for readers.
But selecting terms is hard.
Often there are two or more terms for one concept popular with the community,
so there's no obvious choice.
Indeed, selecting and consistently using any of them is much better
than not selecting and just using random terms each time.
This is why it's also helpful to restrict the usage of some terms explicitly.

..  glossary::

    restricted term
        A restricted term is a word that authors have explicitly forbidden to use for denoting a :term:`concept`.
        Such a word is sometimes used as a :term:`term` for the same :term:`concept` elsewhere:
        in the community, in other books, or other products' documentation.
        Sometimes, this word is used to denote a similar but different concept.
        In this case, the right choice of terms helps us differentiate between concepts.

        For example, in Tarantool, we don't use the term "[database] segmentation"
        to denote what we call "database sharding."
        Although, other authors could do so.
        Also, there is a term "[database] partitioning" that we use to denote
        a wider concept, which includes sharding and other things.

Define terms by explaining concepts
-----------------------------------

Define the term by explaining the concept.
For the most important concepts and the ones unique to Tarantool,
the definition should always be in our documentation.

Define each term in the document which is most relevant to it.
There's no need to gather all definitions on a particular "Glossary" page.

To define a term, use the ``glossary`` directive in the following way:

..  code-block:: rst

    ..  glossary::

        term
            definition text

        term2
            definition text



There can be several ``glossary`` directives in a Sphinx documentation project
and even in a single document.
This page has two of them, for example.

The `Sphinx documentation
<https://github.com/sphinx-doc/sphinx/blob/master/doc/glossary.rst>`_
has an extensive glossary, which we can use as a reference.


Introduce terms on first entry
------------------------------

When you use a term for the first time in a document, introduce it by giving a definition,
synonyms, translation, examples, and links.
It will help readers learn the term and understand the concept behind it.


#.  Define the term or give a link to the definition.

        Database sharding is a type of horizontal partitioning.

    To give a link to the definition, use the `term` role:

    ..  code-block:: rst

        For example, this is a link to the definition of :term:`concept`.
        As with any rST role, it can have :term:`custom text <concept>`.

    The resulting output will look like this:

        For example, this is a link to the definition of :term:`concept`.
        As with any rST role, it can have :term:`custom text <concept>`.

    With acronyms, you can also use the `abbr` role:

    ..  code-block:: rst

        Delete the corresponding :abbr:`PVC (persistent volume claim)`...

    It produces a tooltip link: :abbr:`PVC (persistent volume claim)`.

#.  Provide synonyms, including the :term:`restricted terms <restricted term>`.
    Only do it on the first entry of a term.

        Database sharding (also known as ...) is a type of...

#.  When writing in Russian, it's good to add the corresponding English term.
    Readers may be more familiar with it or can use it in search.

        Шардирование (сегментирование, sharding) — это...

#.  Give examples or links to extra reading where you can.

