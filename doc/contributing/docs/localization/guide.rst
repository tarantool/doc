Tarantool Translation Guidelines
================================

Use this guide when localizing Tarantool into Russian.

Tone of voice
-------------

We address IT specialists fairly knowledgeable in their respective fields.
The goal of our translations is to help these people understand how to use Tarantool.
Think of us as their colleagues and address them as such.
Be professional but friendly.
Don’t command or patronize.
Use colloquial speech but avoid being too familiar.
It’s all about the golden mean.

Think twice when translating modal verbs.
Avoid using expressions like «вы должны», because they sound like a demand in Russian,
and «вам придётся», because it implies that our readers will face a lot of trouble.
Make it easy for the user to read the documentation.

Use gender-neutral expressions like «сделать самостоятельно» instead of «сделать самому», etc.


Term choice
-----------

Though not all of our readers may be fluent in English,
they write in English-based programming languages
and are used to seeing error messages in English.
Therefore, if they see an unfamiliar and/or more archaic Russian term
for a familiar concept, they might have trouble correlating them.

We don’t want our audience to feel confused, so we prefer newer terms.
We also provide the English equivalent for a term
if it is used in the article for the first time.

If you feel like the older Russian term may sound more familiar for a part of the audience
(for example, those with a math background),
consider adding it in parentheses along with the English equivalent.
Don’t repeat the parentheses throughout the text.
(:doc:`A similar rule </contributing/docs/terms/#introduce-terms-on-first-entry>`
applies to writing Tarantool documentation.)

.. container:: table

    .. list-table:: Examples
       :widths: 24 38 38
       :header-rows: 1

       *   -
           -   First time
           -   All following times
       *   -   state machine
           -   машина состояний (конечный автомат, state machine)
           -   машина состояний
       *   -   WAL
           -   журнал упреждающей записи (WAL)
           -   журнал упреждающей записи; WAL; журнал WAL *(using a descriptor)*
       *   -
           -
           -

Best practices
--------------

Be creative
~~~~~~~~~~~
Please avoid word-for-word translations.
Let the resulting text sound as though it was originally written in Russian.

Topic and focus
~~~~~~~~~~~~~~~
Avoid English word order.
The Russian speech is structured with topic and focus (тема и рема).
The focus is whatever new/important information is provided in the sentence
about the topic.
In Russian, the focus most often stands at the end of the sentence,
while in English, sentences may start with it.

.. container:: table

    .. list-table:: Examples
       :widths: 50 50
       :header-rows: 0

       *   -   It is recommended to use `systemd`
               for managing the application instances and accessing log entries.
           -   Для управления экземплярами приложения и доступа к записям журнала
               рекомендуется использовать `systemd`.
       *   -   Do not specify working directories of the instances in this configuration.
           -   Не указывайте в этой конфигурации рабочие директории экземпляров.

No bureaucratese
~~~~~~~~~~~~~~~~
Avoid overly formal, bureaucratic language whenever possible.
Prefer verbs over verbal nouns,
and don’t use «являться» and «осуществляться» unless it’s absolutely necessary.
To learn how to clear your Russian texts of bureaucratese,
check `Timur Anikin's training The Writing Dead <https://www.timuroki.ink/thewritingdead>`_.

Consistency
~~~~~~~~~~~
Use one term for one concept throughout the article.
For example, only translate production as «производственная среда»
and not as «эксплуатационная среда» throughout your article.
It’s not about synonyms, but about terms: we don’t want people to get confused.

Avoid elliptical sentences
~~~~~~~~~~~~~~~~~~~~~~~~~~

    .. container:: table

        .. list-table:: Examples
           :widths: 30 30 40
           :header-rows: 1

           *   -
               -   Don't
               -   Do
           *   -   Defaults to `root`.
               -   По умолчанию --- `root`.
               -   Значение по умолчанию --- `root`.

Pronoun collocations
~~~~~~~~~~~~~~~~~~~~
Do all the pronouns point to the exact nouns you want them to?

**Example (how not to):**
Прежде чем добавить запись в конфигурацию, укажите к ней путь.

In the example above, it is not quite clear
what «к ней» means—to the record or to the configuration.
For more on this issue, check out
`the writers' reference at «Ошибкариум» <https://lapsus.timuroki.ink/pest/wanderer/>`_.

Be critical
~~~~~~~~~~~

Tidy up your translation until it feels just right.

Be nice to your peers
~~~~~~~~~~~~~~~~~~~~~
If you review others’ translations, be gentle and kind.
Everyone makes mistakes, and nobody likes to be punished for them.
You can use phrasings like "I suggest" or "it's a good idea to... ."
