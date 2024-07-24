.. _getting_started-cpp:

C++
===

**Example on GitHub**: `cpp <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/connectors/cpp>`_

To simplify the start of your working with the Tarantool C++ connector, we will
use the `example application <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/connectors/cpp/Simple.cpp>`_.
We will go step by step through the application code and explain what each part does.

The following main topics are discussed in this manual:

.. contents::
   :local:
   :depth: 1

.. _gs_cxx_prereq:

Pre-requisites
--------------

To go through this Getting Started exercise, you need the following
pre-requisites to be done:

* :ref:`clone the connector source code and ensure having Tarantool and third-party software <gs_cxx_prereq_install>`
* :ref:`start Tarantool and create a database <gs_cxx_prereq_tnt_run>`
* :ref:`set up access rights <gs_cxx_prereq_access>`.

.. _gs_cxx_prereq_install:

Installation
~~~~~~~~~~~~

The Tarantool C++ connector is currently supported for Linux only.

The connector itself is a header-only library, so, it doesn't require
installation and building as such. All you need is to clone the connector
source code and :ref:`embed <gs_cxx_connect_embed>` it in your C++ project.

Also, make sure you have other necessary software and Tarantool installed.

.. //TBD For the 3d-party  and Tarantool steps, maybe later we can move these details to REAMDE and leave here the links to those sections of README

1.  Make sure you have the following third-party software. If you miss some of
    the items, install them:

    *   `Git <https://git-scm.com/book/en/v2/Getting-Started-Installing-Git>`_, a version control system
    *   `unzip utility <https://linuxize.com/post/how-to-unzip-files-in-linux/#installing-unzip>`_
    *   `gcc compiler <https://gcc.gnu.org/install/>`_ complied with the `C++17 standard <https://gcc.gnu.org/projects/cxx-status.html#cxx17>`_
    *   `cmake and make tools <https://cmake.org/install/>`_.

2.  If you don't have Tarantool on your OS, install it in one of the ways:

    *   from a package--refer to `OS-specific instructions <https://www.tarantool.io/en/download/>`_
    *   from the `source <https://www.tarantool.io/en/download/os-installation/building-from-source/>`_.

3.  Clone the Tarantool C++ connector repository.

    ..  code-block:: bash

        git clone git@github.com:tarantool/tntcxx.git

.. _gs_cxx_prereq_tnt_run:

Starting Tarantool and creating a database
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Start Tarantool :ref:`locally <getting_started-using_package_manager>`
or :ref:`in Docker <getting_started-using_docker>`
and create a space with the following schema and index:

..  code-block:: lua

    box.cfg{listen = 3301}
    t = box.schema.space.create('t')
    t:format({
             {name = 'id', type = 'unsigned'},
             {name = 'a', type = 'string'},
             {name = 'b', type = 'number'}
             })
    t:create_index('primary', {
             type = 'hash',
             parts = {'id'}
             })

..  IMPORTANT::

    Do not close the terminal window where Tarantool is running.
    You will need it later to connect to Tarantool from your C++ application.

.. _gs_cxx_prereq_access:

Setting up access rights
~~~~~~~~~~~~~~~~~~~~~~~~

To be able to execute the necessary operations in Tarantool, you need to grant
the ``guest`` user with the read-write rights. The simplest way is to grant
the user with the :ref:`super role <authentication-roles>`:

..  code-block:: lua

    box.schema.user.grant('guest', 'super')

.. _gs_cxx_connect:

Connecting to Tarantool
-----------------------

There are three main parts of the C++ connector: the IO-zero-copy buffer,
the msgpack encoder/decoder, and the client that handles requests.

To set up connection to a Tarantool instance from a C++ application, you need
to do the following:

* :ref:`embed the connector into the application <gs_cxx_connect_embed>`
* :ref:`instantiate a connector client and a connection object <gs_cxx_connect_instantiate>`
* :ref:`define connection parameters and invoke the method to connect <gs_cxx_connect_connecting>`
* :ref:`define error handling behavior <gs_cxx_connect_error>`.

.. _gs_cxx_connect_embed:

Embedding connector
~~~~~~~~~~~~~~~~~~~

Embed the connector in your C++ application by including the main header:

..  literalinclude:: /code_snippets/snippets/connectors/cpp/Simple.cpp
    :start-after: doclabel01-1
    :end-before: doclabel01-2
    :language: cpp

.. _gs_cxx_connect_instantiate:

Instantiating objects
~~~~~~~~~~~~~~~~~~~~~

First, we should create a connector client. It can handle many connections
to Tarantool instances asynchronously. To instantiate a client, you should specify
the buffer and the network provider implementations as template parameters.
The connector's main class has the following signature:

..  code-block:: c

    template<class BUFFER, class NetProvider = EpollNetProvider<BUFFER>>
    class Connector;

The buffer is parametrized by allocator. It means that users can
choose which allocator will be used to provide memory for the buffer's blocks.
Data is organized into a linked list of blocks of fixed size that is specified
as the template parameter of the buffer.

You can either implement your own buffer or network provider or use the default
ones as we do in our example. So, the default connector instantiation looks
as follows:

..  literalinclude:: /code_snippets/snippets/connectors/cpp/Simple.cpp
    :start-after: doclabel02-1
    :end-before: doclabel02-2
    :language: cpp

..  literalinclude:: /code_snippets/snippets/connectors/cpp/Simple.cpp
    :start-after: doclabel03-1
    :end-before: doclabel03-2
    :language: cpp
    :dedent: 1

To use the ``BUFFER`` class, the buffer header should also be included:

..  literalinclude:: /code_snippets/snippets/connectors/cpp/Simple.cpp
    :start-after: doclabel01-2
    :end-before: doclabel01-3
    :language: cpp

A client itself is not enough to work with Tarantool instances--we
also need to create connection objects. A connection also takes the buffer and
the network provider as template parameters. Note that they must be the same
as ones of the client:

..  literalinclude:: /code_snippets/snippets/connectors/cpp/Simple.cpp
    :start-after: doclabel04-1
    :end-before: doclabel04-2
    :language: cpp
    :dedent: 1

.. _gs_cxx_connect_connecting:

Connecting
~~~~~~~~~~

Our :ref:`Tarantool instance <gs_cxx_prereq_tnt_run>` is listening to
the ``3301`` port on ``localhost``.
Let's define the corresponding variables as well as the ``WAIT_TIMEOUT`` variable
for connection timeout.

..  literalinclude:: /code_snippets/snippets/connectors/cpp/Simple.cpp
    :start-after: doclabel05-1
    :end-before: doclabel05-2
    :language: cpp

To connect to the Tarantool instance, we should invoke
the ``Connector::connect()`` method of the client object and
pass three arguments: connection instance, address, and port.

..  literalinclude:: /code_snippets/snippets/connectors/cpp/Simple.cpp
    :start-after: doclabel06-1
    :end-before: doclabel06-2
    :language: cpp
    :dedent: 1

.. _gs_cxx_connect_error:

Error handling
~~~~~~~~~~~~~~

Implementation of the connector is exception free, so we rely on the return
codes: in case of fail, the ``connect()`` method returns ``rc < 0``. To get the
error message corresponding to the last error occured during
communication with the instance, we can invoke the ``Connection::getError()``
method.

..  literalinclude:: /code_snippets/snippets/connectors/cpp/Simple.cpp
    :start-after: doclabel06-2
    :end-before: doclabel06-3
    :language: cpp
    :dedent: 1

To reset connection after errors, that is, to clean up the error message and
connection status, the ``Connection::reset()`` method is used.

.. // TBD For the detailed information on the connector's API, refer to <link to the API document parts related to the API used here> -- implement this line when API document is ready.

.. _gs_cxx_requests:

Working with requests
---------------------

In this section, we will show how to:

* :ref:`prepare different types of requests <gs_cxx_requests_prepare>`
* :ref:`send the requests <gs_cxx_requests_send>`
* :ref:`receive and handle responses <gs_cxx_requests_response>`.

We will also go through the :ref:`case of having several connections <gs_cxx_requests_several>`
and executing a number of requests from different connections simultaneously.

In our example C++ application, we execute the following types of requests:

* ``ping``
* ``replace``
* ``select``.

..  NOTE::

    Examples on other request types, namely, ``insert``, ``delete``, ``upsert``,
    and ``update``, will be added to this manual later.

Each request method returns a request ID that is a sort of `future <https://en.wikipedia.org/wiki/Futures_and_promises>`_.
This ID can be used to get the response message when it is ready.
Requests are queued in the output buffer of connection
until the ``Connector::wait()`` method is called.

.. _gs_cxx_requests_prepare:

Preparing requests
~~~~~~~~~~~~~~~~~~

At this step, requests are encoded in the `MessagePack <https://msgpack.org/>`_
format and saved in the
output connection buffer. They are ready to be sent but the network
communication itself will be done later.

Let's remind that for the requests manipulating with data we are dealing
with the Tarantool space ``t`` :ref:`created earlier <gs_cxx_prereq_tnt_run>`,
and the space has the following format:

..  code-block:: lua

    t:format({
             {name = 'id', type = 'unsigned'},
             {name = 'a', type = 'string'},
             {name = 'b', type = 'number'}
             })

**ping**

..  literalinclude:: /code_snippets/snippets/connectors/cpp/Simple.cpp
    :start-after: doclabel07-1
    :end-before: doclabel07-2
    :language: cpp
    :dedent: 1

**replace**

Equals to Lua request ``<space_name>:replace(pk_value, "111", 1)``.

..  literalinclude:: /code_snippets/snippets/connectors/cpp/Simple.cpp
    :start-after: doclabel08-1
    :end-before: doclabel08-2
    :language: cpp
    :dedent: 1

**select**

Equals to Lua request ``<space_name>.index[0]:select({pk_value}, {limit = 1})``.

..  literalinclude:: /code_snippets/snippets/connectors/cpp/Simple.cpp
    :start-after: doclabel09-1
    :end-before: doclabel09-2
    :language: cpp
    :dedent: 1

.. _gs_cxx_requests_send:

Sending requests
~~~~~~~~~~~~~~~~

To send requests to the server side, invoke the ``client.wait()``
method.

..  code-block:: c

    client.wait(conn, ping, WAIT_TIMEOUT);

The ``wait()`` method takes the connection to poll,
the request ID, and, optionally, the timeout as parameters. Once a response
for the specified request is ready, ``wait()`` terminates. It also
provides a negative return code in case of system related fails, for example,
a broken or timeouted connection. If ``wait()`` returns ``0``, then a response
has been received and expected to be parsed.

Now let's send our requests to the Tarantool instance.
The ``futureIsReady()`` function checks availability of a future and returns
``true`` or ``false``.

..  literalinclude:: /code_snippets/snippets/connectors/cpp/Simple.cpp
    :start-after: doclabel10-1
    :end-before: doclabel10-2
    :language: cpp
    :dedent: 1

.. // TBD For the detailed information on the connector's API, refer to <link to the API document parts related to the API used here> -- implement this line when API document is ready.

.. _gs_cxx_requests_response:

Receiving responses
~~~~~~~~~~~~~~~~~~~

To get the response when it is ready, use
the ``Connection::getResponse()`` method. It takes the request ID and returns
an optional object containing the response. If the response is not ready yet,
the method returns ``std::nullopt``. Note that on each future,
``getResponse()`` can be called only once: it erases the request ID from
the internal map once it is returned to a user.

A response consists of a header and a body (``response.header`` and
``response.body``). Depending on success of the request execution on the server
side, body may contain either runtime error(s) accessible by
``response.body.error_stack`` or data (tuples)--``response.body.data``.
In turn, data is a vector of tuples. However, tuples are not decoded and
come in the form of pointers to the start and the end of msgpacks.
See the :ref:`"Decoding and reading the data" <gs_cxx_reader>` section to
understand how to decode tuples.

There are two options for single connection it regards to receiving responses:
we can either wait for one specific future or for all of them at once.
We'll try both options in our example. For the ``ping`` request, let's use the
first option.

..  literalinclude:: /code_snippets/snippets/connectors/cpp/Simple.cpp
    :start-after: doclabel11-1
    :end-before: doclabel11-2
    :language: cpp
    :dedent: 1

For the ``replace`` and ``select`` requests, let's examine the option of
waiting for both futures at once.

..  literalinclude:: /code_snippets/snippets/connectors/cpp/Simple.cpp
    :start-after: doclabel11-2
    :end-before: doclabel11-3
    :language: cpp
    :dedent: 1

.. // TBD For the detailed information on the connector's API, refer to <link to the API document parts related to the API used here> -- implement this line when API document is ready.

.. _gs_cxx_requests_several:

Several connections at once
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now, let's have a look at the case when we establish two connections
to Tarantool instance simultaneously.

..  literalinclude:: /code_snippets/snippets/connectors/cpp/Simple.cpp
    :start-after: doclabel11-3
    :end-before: doclabel11-4
    :language: cpp
    :dedent: 1

.. // TBD For the detailed information on the connector's API, refer to <link to the API document parts related to the API used here> -- implement this line when API document is ready.

.. _gs_cxx_requests_close:

Closing connections
~~~~~~~~~~~~~~~~~~~

Finally, a user is responsible for closing connections.

..  literalinclude:: /code_snippets/snippets/connectors/cpp/Simple.cpp
    :start-after: doclabel12-1
    :end-before: doclabel12-2
    :language: cpp
    :dedent: 1

.. _gs_cxx_build:

Building and launching C++ application
--------------------------------------

Now, we are going to build our example C++ application, launch it
to connect to the Tarantool instance and execute all the requests defined.

Make sure you are in the root directory of the cloned C++ connector repository.
To build the example application:

..  code-block:: bash

    cd examples
    cmake .
    make

Make sure the :ref:`Tarantool session <gs_cxx_prereq_tnt_run>`
you started earlier is running. Launch the application:

..  code-block:: bash

    ./Simple

As you can see from the execution log, all the connections to Tarantool
defined in our application have been established and all the requests
have been executed successfully.

.. //TBD Maybe to quote here the full execution log (62 lines)

.. _gs_cxx_reader:

Decoding and reading the data
-----------------------------

Responses from a Tarantool instance contain raw data, that is, the data encoded
into the `MessagePack <https://msgpack.org/>`_ tuples. To decode client's data,
the user has to write their own
decoders (readers) based on the database schema and include them in one's
application:

..  literalinclude:: /code_snippets/snippets/connectors/cpp/Simple.cpp
    :start-after: doclabel01-3
    :end-before: doclabel01-4
    :language: cpp

To show the logic of decoding a response, we will use
`the reader from our example <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/connectors/cpp/Reader.hpp>`_.

First, the structure corresponding our :ref:`example space format <gs_cxx_prereq_tnt_run>`
is defined:

..  literalinclude:: /code_snippets/snippets/connectors/cpp/Reader.hpp
    :start-after: doclabel13-1
    :end-before: doclabel13-2
    :language: cpp

.. _gs_cxx_reader_base:

Base reader prototype
~~~~~~~~~~~~~~~~~~~~~

Prototype of the base reader is given in ``src/mpp/Dec.hpp``:

..  code-block:: c

    template <class BUFFER, Type TYPE>
    struct SimpleReaderBase : DefaultErrorHandler {
       using BufferIterator_t = typename BUFFER::iterator;
       /* Allowed type of values to be parsed. */
       static constexpr Type VALID_TYPES = TYPE;
       BufferIterator_t* StoreEndIterator() { return nullptr; }
    };

Every new reader should inherit from it or directly from the
``DefaultErrorHandler``.

.. _gs_cxx_reader_parse_value:

Parsing values
~~~~~~~~~~~~~~

To parse a particular value, we should define the ``Value()`` method.
First two arguments of the method are common and unused as a rule,
but the third one defines the parsed value. In case of `POD (Plain Old Data) <https://en.wikipedia.org/wiki/Passive_data_structure>`_
structures, it's enough to provide a byte-to-byte copy. Since there are
fields of three different types in our schema, let's define the corresponding
``Value()`` functions:

..  literalinclude:: /code_snippets/snippets/connectors/cpp/Reader.hpp
    :start-after: doclabel14-1
    :end-before: doclabel14-2
    :language: cpp

.. _gs_cxx_reader_parse_array:

Parsing array
~~~~~~~~~~~~~

It's also important to understand that a tuple itself is wrapped in an array,
so, in fact, we should parse the array first. Let's define another reader
for that purpose.

..  literalinclude:: /code_snippets/snippets/connectors/cpp/Reader.hpp
    :start-after: doclabel15-1
    :end-before: doclabel15-2
    :language: cpp

.. _gs_cxx_reader_set:

Setting reader
~~~~~~~~~~~~~~

The ``SetReader()`` method sets the reader that is invoked while
each of the array's entries is parsed. To make two readers defined above
work, we should create a decoder, set its iterator to the position of
the encoded tuple, and invoke the ``Read()`` method (the code block below is
from the `example application <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/connectors/cpp/Simple.cpp>`_).

..  literalinclude:: /code_snippets/snippets/connectors/cpp/Simple.cpp
    :start-after: doclabel16-1
    :end-before: doclabel16-2
    :language: cpp


..  toctree::
    :maxdepth: 1
    :hidden:

    tntcxx_api