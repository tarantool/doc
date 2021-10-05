Defining and using terms
========================

..  _concepts-and-terms:

What are concepts and terms
---------------------------

To write well about a certain subject matter,
one needs to know the objects of this subject matter
and use the right, carefully selected words for them.
Such objects are called concepts, and the words for them are called terms.

..  glossary::

    concept
        A concept is the idea of some object, attribute, or action.
        It is independent of languages, audience, and products. It just exists.

        For example, a large database can be partitioned into smaller instances.
        Those instances are easier to operate and can exceed the throughput of
        a single large database instance. They can exchange data,
        keeping it consistent between them.

    term
        A term is a word explicitly selected by the authors of a particular text
        to denote a :term:`concept` in a particular language
        for a particular audience.

        For example, in Tarantool, we use the term "[database] sharding" to denote the
        concept described in the previous example.


..  _use-preferred-terms:

Use preferred terms
-------------------

The purpose of using terms is to write concisely and unambiguously,
which is good for the readers.
But selecting terms is hard.
Often, the community favors two or more terms for one concept,
so there's no obvious choice.
Selecting and consistently using any of them is much better
than not making a choice and using a random term every time.
This is why it's also helpful to restrict the usage of some terms explicitly.

..  glossary::

    restricted term
        A restricted term is a word that the authors explicitly prohibited to use for denoting a :term:`concept`.
        Such a word is sometimes used as a :term:`term` for the same :term:`concept` elsewhere:
        in the community, in books, or in other product documentation.
        Sometimes, this word is used to denote a similar but different concept.
        In this case, the right choice of terms helps us differentiate between concepts.

        For example, in Tarantool, we don't use the term "[database] segmentation"
        to denote what we call "database sharding."
        Nevertheless, other authors could do so.
        We also use the term "[database] partitioning" to denote
        a wider concept, which includes sharding among other things.

..  _define-terms:

Define terms by explaining concepts
-----------------------------------

Definitions for the most important concepts,
as well as for concepts unique to Tarantool,
always have to be included in our documentation.

Define every term in the document that you find most appropriate for it.
You don't have to create a dedicated glossary page with all the definitions.

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
has an extensive glossary that can be used as a reference.

..  _introduce-terms:

Introduce terms on first entry
------------------------------

When you use a term in a document for the first time, define it
and provide synonyms, a translation, examples, and/or links.
It will help readers learn the term and understand the concept behind it.


#.  Define the term or give a link to the definition.

        Database sharding is a type of horizontal partitioning.

    To give a link to the definition, use the `term` role:

    ..  code-block:: rst

        For example, this is a link to the definition of :term:`concept`.
        Like any rST role, it can have :term:`custom text <concept>`.

    The resulting output will look like this:

        For example, this is a link to the definition of :term:`concept`.
        Like any rST role, it can have :term:`custom text <concept>`.

    With acronyms, you can also use the `abbr` role:

    ..  code-block:: rst

        Delete the corresponding :abbr:`PVC (persistent volume claim)`...

    It produces a tooltip link: :abbr:`PVC (persistent volume claim)`.

#.  Provide synonyms, including the :term:`restricted terms <restricted term>`.
    Only do it on the first entry of a term.

        Database sharding (also known as ...) is a type of...

#.  When writing in Russian, it's good to add the corresponding English term.
    Readers may be more familiar with it or can search it online.

        Шардирование (сегментирование, sharding) --- это...

#.  Give examples or links to extra reading where you can.
