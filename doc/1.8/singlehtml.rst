.. ifconfig:: builder in ('singlehtml', )

    -------------------------------------------------------------------------------
    Documentation
    -------------------------------------------------------------------------------

    .. toctree::
        :maxdepth: 2

        whats_new
        intro
        book/index
        reference/index
        tutorials/index
        dev_guide/index

.. ifconfig:: builder not in ('singlehtml', )

    .. toctree::
        :hidden:

        whats_new
        intro
        book/index
        reference/index
        tutorials/index
        dev_guide/index
