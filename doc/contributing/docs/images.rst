Images
======

Images are useful in explanations of concepts and structures.
When you introduce a term or describe a structure of multiple interconnected parts
(such as a cluster), consider illustrating it with a diagram. If you are explaining how to
use a GUI, check if a screenshot can make the doc clearer.

Note that illustrations should complement the text, not replace it. Even with an image,
the text should be enough for readers to understand the topic.

Don't overuse images: they are harder to support than text. Use them only if they bring
an obvious benefit.

Diagrams
--------

There is a basic set of diagram elements -- blocks, arrows, and other -- to use in Tarantool docs.
It is stored in `this Miro board <https://miro.com/app/board/uXjVPYdYCng=/>`_. It also provides
basic rules for creating diagrams.

Size
~~~~

There are two sizes of diagram elements:

*   **M** – bigger elements to use in diagrams with a small number of elements.
*   **S** – smaller elements to use in diagrams with a big number of elements.

Avoid changing the size of diagram elements unless it's absolutely necessary.

The diagrams should have the same width. This guarantees that their elements have the same
size on pages. The examples in the Miro board have frames of the right width.
Copy the frame and and place your diagram in it without changing the frame width.

Exporting
~~~~~~~~~

To save the diagram to a file:

#.  Make the frame transparent so that it isn't shown in the resulting image (set its color
    to "no color").

#.  Select all elements together with the frame and click **Copy as image**
    in the context menu (under the three dots). The image will
    be copied to the clipboard.

#.  Paste the image from the clipboard to any graphic editor, for example, GIMP.

#.  Remove the Miro logo in the bottom right corner.

#.  Export/save the image to PNG.


Screenshots
-----------

Take screenshots with any tool you like.

Ensure screenshot consistency on the page:

*   Screenshots must show the same environment: operating system, product version,
    visual theme, and so on.

*   The configuration and data must be consistent. For example, if you've shown spaces
    with data on a screenshot, subsequent screenshots must have the same data, too.

*   Size and resolution must be the same across the page unless you want to zoom in to
    a specific part of the screen.

Markup
------

Insert the images using the ``image`` directive:

..  code-block:: rst

    ..  image:: images/example_diagram.png
        :alt: Example diagram alt text

Result:

..  image:: images/example_diagram.png
    :alt: Example diagram alt text