How to write release notes
==========================

Below are some best practices to make changelogs consistent, neat, and human-oriented.

*   Use the past tense to describe changed or fixed behavior.

    ..  admonition:: Examples
        :class: fact
        
        Fixed false positive panic when yielding in debug hook (gh-5649).

        Fedora 32 is supported now. Added per-commit testing, updated YUM repositories (gh-4966).

*   Use the present tense to describe new behavior.

    ..  admonition:: Example
        :class: fact
        
        Data changes in read-only mode are now forbidden (gh-5231).

*   Start with a capital letter, end with a period. 

Note that these guidelines differ from the best practice for commit message titles
that suggests using the imperative mood.
