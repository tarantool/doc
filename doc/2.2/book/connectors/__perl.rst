=====================================================================
                            Perl
=====================================================================

The most commonly used Perl driver is
`tarantool-perl <https://github.com/tarantool/tarantool-perl>`_. It is not
supplied as part of the Tarantool repository; it must be installed separately.
The most common way to install it is by cloning from GitHub.

To avoid minor warnings that may appear the first time ``tarantool-perl`` is
installed, start with installing some other modules that ``tarantool-perl`` uses,
with `CPAN, the Comprehensive Perl Archive Network <https://en.wikipedia.org/wiki/Cpan>`_:

.. code-block:: console

    $ sudo cpan install AnyEvent
    $ sudo cpan install Devel::GlobalDestruction

Then, to install ``tarantool-perl`` itself, say:

.. code-block:: console

    $ git clone https://github.com/tarantool/tarantool-perl.git tarantool-perl
    $ cd tarantool-perl
    $ git submodule init
    $ git submodule update --recursive
    $ perl Makefile.PL
    $ make
    $ sudo make install

Here is a complete Perl program that inserts ``[99999,'BB']`` into ``space[999]``
via the Perl API. Before trying to run, check that the server instance is listening at
``localhost:3301`` and that the space ``examples`` exists, as
:ref:`described earlier <index-connector_setting>`.
To run, paste the code into a file named :file:`example.pl` and say
:samp:`perl example.pl`. The program will connect using an application-specific
definition of the space. The program will open a socket connection with the
Tarantool instance at ``localhost:3301``, then send an :ref:`space_object:INSERT<box_space-insert>` request, then — if
all is well — end without displaying any messages. If Tarantool is not running
on ``localhost`` with :ref:`listen<cfg_basic-listen>` port = 3301, the program will print “Connection
refused”.

.. code-block:: perl

    #!/usr/bin/perl
    use DR::Tarantool ':constant', 'tarantool';
    use DR::Tarantool ':all';
    use DR::Tarantool::MsgPack::SyncClient;

    my $tnt = DR::Tarantool::MsgPack::SyncClient->connect(
      host    => '127.0.0.1',                      # look for tarantool on localhost
      port    => 3301,                             # on port 3301
      user    => 'guest',                          # username. for 'guest' we do not also say 'password=>...'

      spaces  => {
        999 => {                                   # definition of space[999] ...
          name => 'examples',                      #   space[999] name = 'examples'
          default_type => 'STR',                   #   space[999] field type is 'STR' if undefined
          fields => [ {                            #   definition of space[999].fields ...
              name => 'field1', type => 'NUM' } ], #     space[999].field[1] name='field1',type='NUM'
          indexes => {                             #   definition of space[999] indexes ...
            0 => {
              name => 'primary', fields => [ 'field1' ] } } } } );

    $tnt->insert('examples' => [ 99999, 'BB' ]);

The example program uses field type names 'STR' and 'NUM'
instead of :ref:`'string' and 'unsigned'<box_space-create_index>`, due to a temporary Perl limitation.

The example program only shows one request and does not show all that's
necessary for good practice. For that, please see the
`tarantool-perl repository <https://github.com/tarantool/tarantool-perl>`_.
