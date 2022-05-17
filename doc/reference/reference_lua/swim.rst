.. _swim-module:

-------------------------------------------------------------------------------
                            Module swim
-------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

The ``swim`` module contains Tarantool's implementation of
SWIM -- Scalable Weakly-consistent Infection-style Process Group Membership
Protocol. It is recommended for any type of Tarantool cluster where the
number of nodes can be large. Its job is to discover and monitor
the other members in the cluster and keep their information in a "member table".
It works by sending and receiving, in a background event loop, periodically,
via UDP, messages.

Each message has several parts, including:

* the ping such as "I am checking whether you are alive",
* the event such as "I am joining",
* the anti-entropy such as "I know that another member exists",
* the payload such as "I or another member could have user-generated data".

The maximum message size is about 1500 bytes.

SWIM sends messages periodically to a random subset of the member table.
SWIM processes replies from those members asynchronously.

Each entry in the member table has:

* a UUID,
* a status ("alive", "suspected", "dead", or "left").

When a member fails to acknowledge a certain number of pings,
its status is changed from "alive" to "suspected", that is, suspected of being
dead. But SWIM tries to **avoid false positives** (misidentifying members as dead)
which could happen when a member is overloaded and responds to pings too slowly,
or when there is network trouble and packets can not go through some channels.
When a member is suspected, SWIM randomly chooses other members and sends
requests to them: "please ping this suspected member".
This is called an **indirect ping**.
Thus via different routes and additional hops the suspected member gets
additional chances to reply, and thus "refute" the suspicion.

Because selection is random there is an **even network load** of about one message
per member per protocol step, regardless of the cluster size. This is a major
feature of SWIM. Because the protocol depends on members passing information on,
also known as "gossiping", members do not need to broadcast messages to every
member, which would cause a network load of N messages per member per protocol step,
where N is the number of members in the cluster. However, selection is not
entirely random, there is a preference for selecting least-recently-pinged
members, like a round-robin.

Regarding the **anti-entropy** part of a message: this is necessary for maintaining
the status in entries of the member table.
Consider an example where two members, #1 and #2, are both alive.
No events happen so only pings are being sent periodically.
Then a third member, #3 appears.
It knows about one of the existing members, #2.
How can it discover the other member?
Certainly #1 could notify #2 and #2 could notify #3, but messages go via UDP,
so any notification event can be lost.
However, regular messages containing "ping" and/or "event" also can contain
an "anti-entropy" section,
which is taken from a randomly-chosen part of the member table.
So for this example, #2 will eventually randomly add to a regular message
the anti-entropy note that #1 is alive, and thus #3 will discover #1
even though it did not receive a direct "I am alive" event message from #1.

Regarding the **UUID** part of an entry in the member table:
this is necessary for stable identification, because UUID changes more
rarely than URI (a combination of IP and port number).
But if the UUID does change,
SWIM will include both the new and old UUID in messages,
so all other members will eventually learn about the new UUID
and change the member table accordingly.

Regarding the **payload** part of a message:
this is not always necessary, it is a feature
which allows passing user-generated information via SWIM
instead of via node-to-node communication.
The swim module has methods for specifying a "payload", which is arbitrary
user data with a maximum size of about 1.2 KB.
The payload can be anything, and it will be eventually
disseminated over the cluster and available at other members.
Each member can have its own payload.

Messages can be **encrypted**. Encryption may not be necessary in a closed
network but is necessary for safety if the cluster is on the public Internet.
Users can specify an encryption algorithm, an encryption mode, and a private key.
All parts of all messages (including ping, acknowledgment, event, payload,
URI, and UUID) will be encrypted
with that private key, as well as a random public key generated for each message to
prevent pattern attacks.

In theory the event dissemination speed (the number of hops to pass information
throughout the cluster) is ``O(log(cluster_size))``. For that and other theoretical
information see the Cornell University
`paper <https://www.cs.cornell.edu/projects/Quicksilver/public_pdfs/SWIM.pdf>`_
which originally described SWIM.

.. module:: swim

.. _swim-new:

.. function:: new([cfg])

    Create a new SWIM instance. A SWIM instance maintains a member
    table and interacts with other members.
    Multiple SWIM instances can be created in a single Tarantool process.

    :param table cfg: an optional configuration parameter.

                      If ``cfg`` is not specified or is nil, then
                      the new SWIM instance is not bound to a socket
                      and has nil attributes, so it cannot interact with other
                      members and only a few methods are valid
                      until :ref:`swim_object:cfg() <swim-object_cfg>` is called.

                      If ``cfg`` is specified, then the effect is the same as
                      calling ``s = swim.new() s:cfg()``, except for
                      generation.
                      For configuration description see
                      :ref:`swim_object:cfg() <swim-object_cfg>`.

    The generation part of ``cfg`` can only be specified during ``new()``,
    it cannot be specified later during ``cfg()``.
    Generation is part of :ref:`incarnation <swim-incarnation_description>`.
    Usually generation is not specified because the default value
    (a timestamp) is sufficient, but if there is reason to mistrust
    timestamps (because the time is changed or because the instance
    is started on a different machine), then users may say
    ``swim.new({generation = <number>})``. In that case the latest
    value should be persisted somehow (for example in a file, or in a space,
    or in a global service), and the new value must be greater than
    any previous value of generation.

    :return: swim-object :ref:`a swim object <swim-object>`

    Example:

    .. code-block:: lua

        swim_object = swim.new({uri = 3333, uuid = '00000000-0000-1000-8000-000000000001', heartbeat_rate = 0.1})

.. _swim-object:

.. class:: swim_object

    A swim object is an object returned by :ref:`swim.new() <swim-new>`.
    It has methods:
    :ref:`cfg() <swim-object_cfg>`,
    :ref:`delete() <swim-delete>`,
    :ref:`is_configured() <swim-is_configured>`,
    :ref:`size() <swim-size>`,
    :ref:`quit() <swim-quit>`,
    :ref:`add_member() <swim-add_member>`,
    :ref:`remove_member() <swim-remove_member>`,
    :ref:`probe_member() <swim-probe_member>`,
    :ref:`broadcast() <swim-broadcast>`,
    :ref:`set_payload() <swim-set_payload>`,
    :ref:`set_payload_raw() <swim-set_payload_raw>`,
    :ref:`set_codec() <swim-set_codec>`,
    :ref:`self() <swim-self>`,
    :ref:`member_by_uuid() <swim-member_by_uuid>`,
    :ref:`pairs() <swim-pairs>`.

    .. _swim-object_cfg:

    .. method:: cfg(cfg)

        Configure or reconfigure a SWIM instance.

        :param table cfg: the options to describe instance behavior

        The ``cfg`` table may have these components:

        * ``heartbeat_rate`` (double) -- rate of sending round messages, in seconds.
          Setting ``heartbeat_rate`` to X does not mean that every member
          will be checked every X seconds, instead X is the protocol speed.
          Protocol period depends on member count and heartbeat_rate.
          Default = 1.

        * ``ack_timeout`` (double) -- time in seconds after which a ping is
          considered to be unacknowledged. Default = 30.

        * ``gc_mode`` (enum) -- dead member collection mode.

          If ``gc_mode == 'off'`` then SWIM never removes dead
          members from the member table (though users may remove them
          with :ref:`swim_object:remove_member() <swim-remove_member>`), and
          SWIM will continue to ping them as if they were alive.

          If ``gc_mode == 'on'`` then SWIM removes dead members
          from the member table after one round.

          Default = ``'on'``.

        * ``uri`` (string or number) -- either an ``'ip:port'`` address,
          or just a port number (if ip is omitted then 127.0.0.1 is
          assumed). If ``port == 0``, then the kernel will select any free
          port for the IP address.

        * ``uuid`` (string or cdata struct tt_uuid) -- a value which should
          be unique among SWIM instances. Users may choose any value
          but the recommendation is: use
          :ref:`box.cfg.instance_uuid <cfg_replication-instance_uuid>`,
          the Tarantool instance's UUID.

        All the ``cfg`` components are dynamic -- ``swim_object:cfg()``
        may be called more than once. If it is not being called for
        the first time and a component is not specified, then the
        component retains its previous value. If it is being called
        for the first time then uri and uuid are mandatory, since
        a SWIM instance cannot operate without URI and UUID.

        ``swim_object:cfg()`` is atomic -- if there is an error,
        then nothing changes.

        :return: true if configuration succeeds
        :return: nil, ``err`` if an error occurred. ``err`` is an error object

        Example:

        .. code-block:: lua

            swim_object:cfg({heartbeat_rate = 0.5})

        After ``swim_object:cfg()``, all other ``swim_object`` methods are callable.

    .. data:: .cfg

        Expose all non-nil components of the read-only table which was set up
        or changed by :ref:`swim_object:cfg() <swim-object_cfg>`.

        Example:

        .. code-block:: tarantoolsession

            tarantool> swim_object.cfg
            ---
            - gc_mode: off
              uri: 3333
              uuid: 00000000-0000-1000-8000-000000000001
            ...

    .. _swim-delete:

    .. method:: delete()

        Delete a SWIM instance immediately. Its memory is freed,
        its member table entry is deleted,
        and it can no longer be used.
        Other members will treat this member as 'dead'.

        After ``swim_object:delete()`` any attempt to use the
        deleted instance will cause an exception to be thrown.

        :return: none, this method does not fail

        Example: ``swim_object:delete()``

    .. _swim-is_configured:

    .. method:: is_configured()

        Return false if
        a SWIM instance was created via
        :ref:`swim.new() <swim-new>` without an optional ``cfg`` argument,
        and was not configured with :ref:`swim_object:cfg() <swim-object_cfg>`.
        Otherwise return true.

        :return: boolean result, true if configured, otherwise false

        Example: ``swim_object:is_configured()``

    .. _swim-size:

    .. method:: size()

        Return the size of the member table. It will be at least 1
        because the "self" member is included.

        :return: integer size

        Example: ``swim_object:size()``

    .. _swim-quit:

    .. method:: quit()

        Leave the cluster.

        This is a graceful equivalent of
        :ref:`swim_object:delete() <swim-delete>` -- the instance is
        deleted, but before deletion it sends to each member in its
        member table a message, that this instance has left the cluster, and
        should not be considered dead.

        Other instances will mark such a member
        in their tables as 'left', and drop it after one round of
        dissemination.

        Consequences to the caller are the same as after
        ``swim_object:delete()`` -- the instance is no longer usable,
        and an error will be thrown if there is an attempt to use it.

        :return: none, the method does not fail

        Example: ``swim_object:quit()``

    .. _swim-add_member:

    .. method:: add_member(cfg)

        Explicitly add a member into the member table.

        This method is useful when a new member is joining
        the cluster and does not yet know what members already exist.
        In that case it can start interaction explicitly by
        adding the details about an already-existing member
        into its member table.
        Subsequently SWIM will discover other members automatically
        via messages from the already-existing member.

        :param table cfg: description of the member

        The ``cfg`` table has two mandatory components, ``uuid`` and ``uri``, which have
        the same format as ``uuid`` and ``uri`` in the table for :ref:`swim_object:cfg() <swim-object_cfg>`.

        :return: true if member is added
        :return: nil, ``err`` if an error occurred. ``err`` is an error object

        Example:

        .. code-block:: lua

            swim_member_object = swim_object:add_member({uuid = ..., uri = ...})

    .. _swim-remove_member:

    .. method:: remove_member(uuid)

        Explicitly and immediately remove a member from the member
        table.

        :param string-or-cdata-struct-tt_uuid uuid: UUID

        :return: true if member is removed
        :return: nil, ``err`` if an error occurred. ``err`` is an error object.

        Example: ``swim_object:delete('00000000-0000-1000-8000-000000000001')``

    .. _swim-probe_member:

    .. method:: probe_member(uri)

        Send a ping request to the specified ``uri`` address. If another member
        is listening at that address, it will receive the ping, and respond with
        an ACK (acknowledgment) message containing information such as UUID.
        That information will be added to the
        member table.

        ``swim_object:probe_member()`` is similar to
        :ref:`swim_object:add_member() <swim-add_member>`, but it
        does not require UUID, and it is not reliable because it uses UDP.

        :param string-or-number uri: URI. Format is the same as for ``uri``
                                     in :ref:`swim_object:cfg() <swim-object_cfg>`.

        :return: true if member is pinged
        :return: nil, ``err`` if an error occurred. ``err`` is an error object.

        Example: ``swim_object:probe_member(3333)``

    .. _swim-broadcast:

    .. method:: broadcast([port])

        Broadcast a ping request to all the network interfaces in the
        system.

        ``swim_object:broadcast()`` is like
        :ref:`swim_object:probe_member() <swim-probe_member>`
        to many members at once.

        :param number port: All the sent ping requests
                            have this port as destination port in their UDP headers.
                            By default a currently bound port is used.

        :return: true if broadcast is sent
        :return: nil, ``err`` if an error occurred. ``err`` is an error object.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> fiber = require('fiber')
            ---
            ...
            tarantool> swim = require('swim')
            ---
            ...
            tarantool> s1 = swim.new({uri = 3333, uuid = '00000000-0000-1000-8000-000000000001', heartbeat_rate = 0.1})
            ---
            ...
            tarantool> s2 = swim.new({uri = 3334, uuid = '00000000-0000-1000-8000-000000000002', heartbeat_rate = 0.1})
            ---
            ...
            tarantool> s1:size()
            ---
            - 1
            ...
            tarantool> s1:add_member({uri = s2:self():uri(), uuid = s2:self():uuid()})
            ---
            - true
            ...
            tarantool> s1:size()
            ---
            - 1
            ...
            tarantool> s2:size()
            ---
            - 1
            ...

            tarantool> fiber.sleep(0.2)
            ---
            ...
            tarantool> s1:size()
            ---
            - 2
            ...
            tarantool> s2:size()
            ---
            - 2
            ...
            tarantool> s1:remove_member(s2:self():uuid()) s2:remove_member(s1:self():uuid())
            ---
            ...
            tarantool> s1:size()
            ---
            - 1
            ...
            tarantool> s2:size()
            ---
            - 1
            ...

            tarantool> s1:probe_member(s2:self():uri())
            ---
            - true
            ...
            tarantool> fiber.sleep(0.1)
            ---
            ...
            tarantool> s1:size()
            ---
            - 2
            ...
            tarantool> s2:size()
            ---
            - 2
            ...
            tarantool> s1:remove_member(s2:self():uuid()) s2:remove_member(s1:self():uuid())
            ---
            ...
            tarantool> s1:size()
            ---
            - 1
            ...
            tarantool> s2:size()
            ---
            - 1
            ...
            tarantool> s1:broadcast(3334)
            ---
            - true
            ...
            tarantool> fiber.sleep(0.1)
            ---
            ...
            tarantool> s1:size()
            ---
            - 2
            ...

            tarantool> s2:size()
            ---
            - 2
            ...

    .. _swim-set_payload:

    .. method:: set_payload(payload)

        Set a payload, as formatted data.

        Payload is arbitrary user defined data up to 1200 bytes in size
        and disseminated over the cluster. So each cluster member
        will eventually learn what is the payload of other members in
        the cluster, because it is stored in the member table and can be
        queried with :ref:`swim_member_object:payload() <swim-payload>`.

        Different members may have different payloads.

        :param object payload:  Arbitrary Lua object to disseminate. Set to nil
                                to remove the payload, in which case it will be eventually removed
                                on other instances. The object is serialized in
                                MessagePack.

        :return: true if payload is set
        :return: nil, ``err`` if an error occurred. ``err`` is an error object

        Example:

        .. code-block:: lua

            swim_object:set_payload({field1 = 100, field2 = 200})

    .. _swim-set_payload_raw:

    .. method:: set_payload_raw(payload[, size])

        Set a payload, as raw data.

        Sometimes a payload does not need to be a Lua object.
        For example, a user may already have a well formatted
        MessagePack object and just wants to set it as a payload.
        Or cdata needs to be exposed.

        ``set_payload_raw`` allows setting
        a payload as is, without MessagePack serialization.

        :param string-or-cdata payload: any value

        :param number size:  Payload size in bytes. If ``payload`` is string then ``size`` is
                             optional, and if specified, then should not be larger
                             than actual ``payload`` size. If ``size`` is less than
                             actual ``payload`` size, then only the first ``size``
                             bytes of ``payload`` are used. If ``payload`` is cdata then
                             ``size`` is mandatory.

        :return: true if payload is set
        :return: nil, ``err`` if an error occurred. ``err`` is an error object

        Example:

        .. code-block:: tarantoolsession

            tarantool> tarantool> ffi = require('ffi')
            ---
            ...
            tarantool> fiber = require('fiber')
            ---
            ...
            tarantool> swim = require('swim')
            ---
            ...
            tarantool> s1 = swim.new({uri = 0, uuid = '00000000-0000-1000-8000-000000000001', heartbeat_rate = 0.1})
            ---
            ...
            tarantool> s2 = swim.new({uri = 0, uuid = '00000000-0000-1000-8000-000000000002', heartbeat_rate = 0.1})
            ---
            ...
            tarantool> s1:add_member({uri = s2:self():uri(), uuid = s2:self():uuid()})
            ---
            - true
            ...
            tarantool> s1:set_payload({a = 100, b = 200})
            ---
            - true
            ...
            tarantool> s2:set_payload('any payload')
            ---
            - true
            ...
            tarantool> fiber.sleep(0.2)
            ---
            ...
            tarantool> s1_view = s2:member_by_uuid(s1:self():uuid())
            ---
            ...
            tarantool> s2_view = s1:member_by_uuid(s2:self():uuid())
            ---
            ...
            tarantool> s1_view:payload()
            ---
            - {'a': 100, 'b': 200}
            ...
            tarantool> s2_view:payload()
            ---
            - any payload
            ...
            tarantool> cdata = ffi.new('char[?]', 2)
            ---
            ...
            tarantool> cdata[0] = 1
            ---
            ...
            tarantool> cdata[1] = 2
            ---
            ...
            tarantool> s1:set_payload_raw(cdata, 2)
            ---
            - true
            ...
            tarantool> fiber.sleep(0.2)
            ---
            ...
            tarantool> cdata, size = s1_view:payload_cdata()
            ---
            ...
            tarantool> cdata[0]
            ---
            - 1
            ...
            tarantool> cdata[1]
            ---
            - 2
            ...
            tarantool> size
            ---
            - 2
            ...

    .. _swim-set_codec:

    .. method:: set_codec(codec_cfg)

        Enable encryption for all following messages.

        For a brief description of encryption
        algorithms see "enum_crypto_algo" and "enum crypto_mode"
        in the Tarantool source code file
        `crypto.h <https://github.com/tarantool/tarantool/blob/master/src/lib/crypto/crypto.h>`_.

        When encryption is enabled, all the
        messages are encrypted with a chosen private key, and a
        randomly generated and updated public key.

        :param table codec_cfg: description of the encryption

        The components of the ``codec_cfg`` table may be:

        * ``algo`` (string) -- encryption algorithm name.
          All the names in :ref:`module crypto <crypto>` are supported:
          'aes128', 'aes192', 'aes256', 'des'.
          Specify 'none' to disable encryption.

        * ``mode`` (string) -- encryption algorithm mode. All the modes in
          module ``crypto`` are supported: 'ecb', 'cbc', 'cfb', 'ofb'.
          Default = 'cbc'.

        * ``key`` (cdata or string) -- a private secret key which is kept
          secret and should never be stored hard-coded in source code.

        * ``key_size`` (integer) -- size of the key in bytes.

          ``key_size`` is mandatory if key is cdata.

          ``key_size`` is optional if key is
          string, and if ``key_size`` is shorter than than actual key size
          then the key is truncated.

        All of ``algo``, ``mode``, ``key``, and ``key_size`` should be
        the same for all SWIM instances, so that members can understand
        each others' messages.

        Example;

        .. code-block:: tarantoolsession

            tarantool> tarantool> swim = require('swim')
            ---
            ...
            tarantool> s1 = swim.new({uri = 0, uuid = '00000000-0000-1000-8000-000000000001'})
            ---
            ...
            tarantool> s1:set_codec({algo = 'aes128', mode = 'cbc', key = '1234567812345678'})
            ---
            - true
            ...

    .. _swim-self:

    .. method:: self()

        Return a :ref:`swim member object <swim-member_object>` (of self) from the member table,
        or from a cache containing earlier results of ``swim_object:self()`` or
        ``swim_object:member_by_uuid()`` or ``swim_object:pairs()``.

        :return: :ref:`swim member object <swim-member_object>`, not nil because self() will not fail

        Example: ``swim_member_object = swim_object:self()``

    .. _swim-member_by_uuid:

    .. method:: member_by_uuid(uuid)

        Return a :ref:`swim member object <swim-member_object>` (given UUID) from the member table,
        or from a cache containing earlier results of ``swim_object:self()`` or
        ``swim_object:member_by_uuid()`` or ``swim_object:pairs()``.

        :param string-or-cdata-struct-tt-uuid uuid: UUID

        :return: :ref:`swim member object <swim-member_object>`, or nil if not found

        Example:

        .. code-block:: lua

            swim_member_object = swim_object:member_by_uuid('00000000-0000-1000-8000-000000000001')

    .. _swim-pairs:

    .. method:: pairs()

        Set up an iterator for returning
        :ref:`swim member objects <swim-member_object>` from the member table,
        or from a cache containing earlier results of ``swim_object:self()`` or
        ``swim_object:member_by_uuid()`` or ``swim_object:pairs()``.

        ``swim_object:pairs()`` should be in a 'for' loop, and
        there should only be one iterator in operation
        at one time. (The iterator is implemented in an extra light fashion so only
        one iterator object is available per SWIM instance.)

        :param varies generator+object+key: as for any Lua pairs() iterators.
                                            generator function, iterator
                                            object (a swim member object),
                                            and initial key (a UUID).

        Example:

        .. code-block:: tarantoolsession

            tarantool> fiber = require('fiber')
            ---
            ...
            tarantool> swim = require('swim')
            ---
            ...
            tarantool> s1 = swim.new({uri = 0, uuid = '00000000-0000-1000-8000-000000000001', heartbeat_rate = 0.1})
            ---
            ...
            tarantool> s2 = swim.new({uri = 0, uuid = '00000000-0000-1000-8000-000000000002', heartbeat_rate = 0.1})
            ---
            ...
            tarantool> s1:add_member({uri = s2:self():uri(), uuid = s2:self():uuid()})
            ---
            - true
            ...
            tarantool> fiber.sleep(0.2)
            ---
            ...
            tarantool> s1:self()
            ---
            - uri: 127.0.0.1:55845
              status: alive
              incarnation: cdata {generation = 1569353431853325ULL, version = 1ULL}
              uuid: 00000000-0000-1000-8000-000000000001
              payload_size: 0
            ...
            tarantool> s1:member_by_uuid(s1:self():uuid())
            ---
            - uri: 127.0.0.1:55845
              status: alive
              incarnation: cdata {generation = 1569353431853325ULL, version = 1ULL}
              uuid: 00000000-0000-1000-8000-000000000001
              payload_size: 0
            ...
            tarantool> s1:member_by_uuid(s2:self():uuid())
            ---
            - uri: 127.0.0.1:53666
              status: alive
              incarnation: cdata {generation = 1569353431865138ULL, version = 1ULL}
              uuid: 00000000-0000-1000-8000-000000000002
              payload_size: 0
            ...
            tarantool> t = {}
            ---
            ...
            tarantool> for k, v in s1:pairs() do table.insert(t, {k, v}) end
            ---
            ...
            tarantool> t
            ---
            - - - 00000000-0000-1000-8000-000000000002
                - uri: 127.0.0.1:53666
                  status: alive
                  incarnation: cdata {generation = 1569353431865138ULL, version = 1ULL}
                  uuid: 00000000-0000-1000-8000-000000000002
                  payload_size: 0
              - - 00000000-0000-1000-8000-000000000001
                - uri: 127.0.0.1:55845
                  status: alive
                  incarnation: cdata {generation = 1569353431853325ULL, version = 1ULL}
                  uuid: 00000000-0000-1000-8000-000000000001
                  payload_size: 0
            ...

    .. _swim-member_object:

.. class:: swim_member_object

    Methods
    :ref:`swim_object:member_by_uuid() <swim-member_by_uuid>`,
    :ref:`swim_object:self() <swim-self>`, and
    :ref:`swim_object:pairs() <swim-pairs>` return swim
    member objects.

    A swim member object has methods for reading
    its attributes:
    :ref:`status() <swim-status>`,
    :ref:`uuid <swim-uuid>`,
    :ref:`uri() <swim-uri>`,
    :ref:`incarnation() <swim-incarnation>`,
    :ref:`payload_cdata <swim-payload_cdata>`,
    :ref:`payload_str() <swim-payload_str>`,
    :ref:`payload() <swim-payload>`,
    :ref:`is_dropped() <swim-is_dropped>`.

    .. _swim-status:

    .. method:: status()

        Return the status, which may be 'alive', 'suspected',
        'left', or 'dead'.

        :return: string 'alive' | 'suspected' | 'left' | dead'

    .. _swim-uuid:

    .. method:: uuid()

        Return the UUID as cdata struct tt_uuid.

        :return: cdata-struct-tt-uuid UUID

    .. _swim-uri:

    .. method:: uri()

        Return the URI as a string 'ip:port'.
        Via this method a user
        can learn a real assigned port, if port = 0 was specified in
        :ref:`swim_object:cfg() <swim-object_cfg>`.

        :return: string ip:port

    .. _swim-incarnation:

    .. method:: incarnation()

        Return a cdata object with the :ref:`incarnation <swim-incarnation_description>`.
        The cdata object has two attributes: incarnation().generation and
        incarnation().version.

        Incarnations can be compared to each other with
        any comparison operator (==, <, >, <=, >=, ~=).

        Incarnations, when printed, will appear as
        strings with both generation and version.

        :return: cdata incarnation

    .. _swim-payload_cdata:

    .. method:: payload_cdata()

        Return member's payload.

        :return: pointer-to-cdata payload and size in bytes

    .. _swim-payload_Str:

    .. method:: payload_str()

        Return payload as a string object. Payload is not decoded. It
        is just returned as a string instead of cdata. If payload was
        not specified
        by :ref:`swim_object:set_payload() <swim-set_payload>` or
        by :ref:`swim_object:set_payload_raw() <swim-set_payload_raw>`,
        then its size is 0 and nil is returned.

        :return: string-object payload, or nil if there is no payload

    .. _swim-payload:

    .. method:: payload()

        Since the ``swim`` module is a Lua module, a user is likely to use Lua objects
        as a payload -- tables, numbers, strings etc. And it is natural
        to expect that
        :ref:`swim_member_object:payload() <swim-payload>`
        should return the same object
        which was passed into
        :ref:`swim_object:set_payload() <swim-set_payload>`
        by another instance.
        ``swim_member_object:payload()`` tries to interpret payload as MessagePack,
        and if that fails then it returns the payload as a string.

        ``swim_member_object:payload()`` caches its result. Therefore only the first call
        actually decodes cdata payload. All following calls return a
        pointer to the same result, unless payload is changed with a new
        incarnation. If payload was not specified (its size is 0), then nil is
        returned.

    .. _swim-is_dropped:

    .. method:: is_dropped()

        Returns true if this member object is a stray reference to a
        member which has already been dropped from the member table.

        :return: boolean true if member is dropped, otherwise false

        Example:

        .. code-block:: tarantoolsession

            tarantool> swim = require('swim')
            ---
            ...
            tarantool> s = swim.new({uri = 0, uuid = '00000000-0000-1000-8000-000000000001'})
            ---
            ...
            tarantool> self = s:self()
            ---
            ...
            tarantool> self:status()
            ---
            - alive
            ...
            tarantool> self:uuid()
            ---
            - 00000000-0000-1000-8000-000000000001
            ...
            tarantool> self:uri()
            ---
            - 127.0.0.1:56367
            ...
            tarantool> self:incarnation()
            ---
            - - cdata {generation = 1569354463981551ULL, version = 1ULL}
            ...
            tarantool> self:is_dropped()
            ---
            - false
            ...
            tarantool> s:set_payload_raw('123')
            ---
            - true
            ...
            tarantool> self:payload_cdata()
            ---
            - 'cdata<const char *>: 0x0103500050'
            - 3
            ...
            tarantool> self:payload_str()
            ---
            - '123'
            ...
            tarantool> s:set_payload({a = 100})
            ---
            - true
            ...
            tarantool> self:payload_cdata()
            ---
            - 'cdata<const char *>: 0x0103500050'
            - 4
            ...
            tarantool> self:payload_str()
            ---
            - !!binary gaFhZA==
            ...
            tarantool> self:payload()
            ---
            - {'a': 100}
            ...

    .. _swim-on_member_event:

    .. method:: on_member_event(trigger-function[, ctx])

        Create an "on_member :ref:`trigger <triggers>`".
        The ``trigger-function`` will be executed when a member in the member table is updated.

        :param function trigger-function: this will become the trigger function
        :param cdata ctx: (optional) this will be passed to trigger-function

        :return: nil or function pointer.

        The **trigger-function** should have three parameter declarations
        (Tarantool will pass values for them when it invokes the function):

        * the member which is having the member event,
        * the event object,
        * the ``ctx`` which will be the same value as what is passed to
          ``swim_object:on_member_event``.

        A **member event** is any of:

        * appearance of a new member,
        * drop of an existing member, or
        * update of an existing member.

        An **event object** is an object which the trigger-function
        can use for determining what type of member event has happened.
        The object's methods -- such as ``is_new_status()``, ``is_new_uri()``,
        ``is_new_incarnation()``, ``is_new_payload()``, ``is_drop()`` --
        return boolean values.

        A member event may have more than one associated **trigger**.
        Triggers are executed sequentially.
        Therefore if a trigger function causes yields or sleeps,
        other triggers may be forced to wait.
        However, since trigger execution is done in a separate fiber,
        SWIM itself is not forced to wait.

        Example of an on-member trigger function:

        .. code-block:: none

            tarantool> swim = require('swim')

            local function on_event(member, event, ctx)
                if event:is_new() then
                    ...
                elseif event:is_drop() then
                    ...
                end

                if event:is_update() then
                    -- All next conditions can be
                    -- true simultaneously.
                    if event:is_new_status() then
            ...
                    end
                    if event:is_new_uri() then
            ...
                    end
                    if event:is_new_incarnation() then
            ...
                    end
                    if event:is_new_payload() then
            ...
                    end
                end
            end

        Notice in the above example that the function is ready
        for the possibility that multiple events can happen
        simultaneously for a single trigger activation.
        ``is_new()`` and ``is_drop()`` can not both be true,
        but ``is_new()`` and ``is_update()`` can both be true,
        or ``is_drop()`` and ``is_update()`` can both be true.
        Multiple simultaneous events are especially likely if
        there are many events and trigger functions are slow --
        in that case, for example, a member might be added
        and then updated after a while, and then after a while
        there will be a single trigger activation.

        Also: ``is_new()`` and ``is_new_payload()`` can both be true.
        This case is not due to trigger functions that are slow.
        It occurs because "omitted payload" and "size-zero payload"
        are not the same thing. For example: when a ping is received,
        a new member might be added, but ping messages do not include
        payload. The payload will appear later in a different message.
        If that is important for the application, then the function
        should not assume when ``is_new()`` is true that the member
        already has a payload, and should not assume that payload size
        says something about the payload's presence or absence.

        Also: functions should not assume that ``is_new()`` and ``is_drop()``
        will always be seen.
        If a new member appears but then is dropped before its appearance has
        caused a trigger activation, then there will be no trigger
        activation.

        ``is_new_generation()`` will be true if the generation part
        of :ref:`incarnation <swim-incarnation_description>` changes.
        ``is_new_version()`` will be true if the version part
        of incarnation changes.
        ``is_new_incarnation()`` will be true if either the generation part
        or the version part of incarnation changes.
        For example a combination of these methods can be used within a
        user-defined trigger to check whether a process has restarted,
        or a member has changed ...

        .. code-block:: none

            swim = require('swim')
            s = swim.new()
            s:on_member_event(function(m, e)
            ...
                if e:is_new_incarnation() then
                    if e:is_new_generation() then
                        -- Process restart.
                    end
                    if e:is_new_version() then
                        -- Process version update. It means
                        -- the member is somehow changed.
                    end
                end
            end

    .. method:: on_member_event(nil, old-trigger)

        Delete an on-member trigger.

        :param function old-trigger: old-trigger

        The old-trigger value should be the value returned by
        ``on_member_event(trigger-function[, ctx])``.

    .. method:: on_member_event(new-trigger, old-trigger [, ctx])

        This is a variation of ``on_member_event(new-trigger, [, ctx])``.

        The additional parameter is ``old-trigger``.
        Instead of adding the new-trigger at the end of a
        list of triggers, this function will replace the entry in
        the list of triggers that matches old-trigger.
        The position within a list may be important because
        triggers are activated sequentially starting
        with the first trigger in the list.

        The old-trigger value should be the value returned by
        ``on_member_event(trigger-function[, ctx])``.

    .. method:: on_member_event()

        Return the list of on-member triggers.

===============================================================================
SWIM internals
===============================================================================

The SWIM internals section is not necessary for programmers who wish to use the SWIM module,
it is for programmers who wish to change or replace the SWIM module.

The SWIM wire protocol is open, will be backward compatible in case of
any changes, and can be implemented by users who wish to simulate their
own SWIM cluster members because they use another language than Lua,
or another environment unrelated to Tarantool.
The protocol is encoded as
`MsgPack <https://en.wikipedia.org/wiki/MessagePack>`_.

.. code-block:: none

    SWIM packet structure:

    +-----------------Public data, not encrypted------------------+
    |                                                             |
    |      Initial vector, size depends on chosen algorithm.      |
    |                   Next data is encrypted.                   |
    |                                                             |
    +----------Meta section, handled by transport level-----------+
    | map {                                                       |
    |     0 = SWIM_META_TARANTOOL_VERSION: uint, Tarantool        |
    |                                      version ID,            |
    |     1 = SWIM_META_SRC_ADDRESS: uint, ip,                    |
    |     2 = SWIM_META_SRC_PORT: uint, port,                     |
    |     3 = SWIM_META_ROUTING: map {                            |
    |         0 = SWIM_ROUTE_SRC_ADDRESS: uint, ip,               |
    |         1 = SWIM_ROUTE_SRC_PORT: uint, port,                |
    |         2 = SWIM_ROUTE_DST_ADDRESS: uint, ip,               |
    |         3 = SWIM_ROUTE_DST_PORT: uint, port                 |
    |     }                                                       |
    | }                                                           |
    +-------------------Protocol logic section--------------------+
    | map {                                                       |
    |     0 = SWIM_SRC_UUID: 16 byte UUID,                        |
    |                                                             |
    |                 AND                                         |
    |                                                             |
    |     2 = SWIM_FAILURE_DETECTION: map {                       |
    |         0 = SWIM_FD_MSG_TYPE: uint, enum swim_fd_msg_type,  |
    |         1 = SWIM_FD_GENERATION: uint,                       |
    |         2 = SWIM_FD_VERSION: uint                           |
    |     },                                                      |
    |                                                             |
    |               OR/AND                                        |
    |                                                             |
    |     3 = SWIM_DISSEMINATION: array [                         |
    |         map {                                               |
    |             0 = SWIM_MEMBER_STATUS: uint,                   |
    |                                     enum member_status,     |
    |             1 = SWIM_MEMBER_ADDRESS: uint, ip,              |
    |             2 = SWIM_MEMBER_PORT: uint, port,               |
    |             3 = SWIM_MEMBER_UUID: 16 byte UUID,             |
    |             4 = SWIM_MEMBER_GENERATION: uint,               |
    |             5 = SWIM_MEMBER_VERSION: uint,                  |
    |             6 = SWIM_MEMBER_PAYLOAD: bin                    |
    |         },                                                  |
    |         ...                                                 |
    |     ],                                                      |
    |                                                             |
    |               OR/AND                                        |
    |                                                             |
    |     1 = SWIM_ANTI_ENTROPY: array [                          |
    |         map {                                               |
    |             0 = SWIM_MEMBER_STATUS: uint,                   |
    |                                     enum member_status,     |
    |             1 = SWIM_MEMBER_ADDRESS: uint, ip,              |
    |             2 = SWIM_MEMBER_PORT: uint, port,               |
    |             3 = SWIM_MEMBER_UUID: 16 byte UUID,             |
    |             4 = SWIM_MEMBER_GENERATION: uint,               |
    |             5 = SWIM_MEMBER_VERSION: uint,                  |
    |             6 = SWIM_MEMBER_PAYLOAD: bin                    |
    |         },                                                  |
    |         ...                                                 |
    |     ],                                                      |
    |                                                             |
    |               OR/AND                                        |
    |                                                             |
    |     4 = SWIM_QUIT: map {                                    |
    |         0 = SWIM_QUIT_GENERATION: uint,                     |
    |         1 = SWIM_QUIT_VERSION: uint                         |
    |     }                                                       |
    | }                                                           |
    +-------------------------------------------------------------+

The **Initial vector section** appears only when encryption
is enabled. This section contains a public key. For example,
for AES algorithms it is a 16-byte initial vector stored as is. When
no encryption is used, the section size is 0.

The later sections (Meta and Protocol Logic) are encrypted as one
big data chunk if encryption is enabled.

The **Meta section** handles routing and protocol versions compatibility. It
works at the 'transport' level of the SWIM protocol, and is always present.
Keys in the meta section are:

* SWIM_META_TARANTOOL_VERSION -- mandatory field. Tarantool sets
  here its version as a 3 byte integer:

  * 1 byte for major,
  * 1 byte for minor,
  * 1 byte for patch.

  For example, Tarantool version 2.1.3 would
  be encoded like this: ``(((2 << 8) | 1) << 8) | 3;``. This field
  will be used to support multiple versions of the protocol.

* SWIM_META_SRC_ADDRESS and SWIM_META_SRC_PORT -- mandatory.
  source IP address and port. IP is encoded as 4 bytes.
  "xxx.xxx.xxx.xxx" where each 'xxx' is encoding of one byte. Port is encoded
  as an integer. Example of how to encode "127.0.0.1:3313":

  .. code-block:: none

      struct in_addr addr;
      inet_aton("127.0.0.1", &addr);
      pos = mp_encode_uint(pos, SWIM_META_SRC_ADDRESS);
      pos = mp_encode_uint(pos, addr->s_addr);
      pos = mp_encode_uint(pos, SWIM_META_SRC_PORT);
      pos = mp_encode_uint(pos, 3313);

* SWIM_META_ROUTING subsection -- not mandatory.
  Responsible for packet forwarding. Used by SWIM
  suspicion mechanism. Read about suspicion in the SWIM paper.

  If this subsection is present then the following fields are
  mandatory:

  * SWIM_ROUTE_SRC_ADDRESS and SWIM_ROUTE_SRC_PORT (source
    IP address and port) (should be an address of the
    message originator (can differ from
  * SWIM_META_SRC_ADDRESS and from SWIM_META_SRC_ADDRESS_PORT);
  * SWIM_ROUTE_DST_ADDRESS and SWIM_ROUTE_DST_PORT (destination
    IP address and port, for the the message's final destination).

  If a message was sent indirectly with the help of SWIM_META_ROUTING,
  then the reply should be sent back by the same route.

  For an example of how SWIM uses routing for indirect pings ...
  Assume there are 3 nodes: S1, S2, S3. S1 sends a message to
  S3 via S2. The following steps are executed in order to
  deliver the message:

  .. code-block:: none

      S1 -> S2
      { src: S1, routing: {src: S1, dst: S3}, body: ... }

  S2 receives the message and sees that routing.dst is not equal to S2,
  so it is a foreign packet. S2 forwards the packet to S3 preserving all the
  data including body and routing sections.

  .. code-block:: none

      S2 -> S3

  S3 receives the message and sees that routing.dst is equal to S3,
  so the message is delivered. If S3 wants to answer, it sends a
  response via the same proxy. It knows that the message was
  delivered from S2, so it sends an answer via S2.

The **Protocol logic section** handles SWIM logical protocol steps and actions.

* SWIM_SRC_UUID -- mandatory field. SWIM uses UUID as a unique
  identifier of a member, not IP/port. This field stores UUID of
  sender. Its type is MP_BIN. Size is always 16 bytes. UUID is
  encoded in host byte order, no bswaps are needed.

Following SWIM_SRC_UUID there are four possible subsections:
SWIM_FAILURE_DETECTION, SWIM_DISSEMINATION, SWIM_ANTI_ENTROPY, SWIM_QUIT.
Any or all of these subsections may be present.
A connector should be ready to handle any combination.

* SWIM_FAILURE_DETECTION subsection -- describes a ping or ACK.
  In the SWIM_FAILURE_DETECTION subsection are:

  * SWIM_FD_MSG_TYPE (0 is ping, 1 is ack);
  * SWIM_FD_GENERATION + SWIM_FD_VERSION (the :ref:`incarnation <swim-incarnation_description>`).

* SWIM_DISSEMINATION subsection -- a list of
  changed cluster members. It may include only a subset of changed
  cluster members if there are too many changes to fit into one UDP packet.

  In the SWIM_DISSEMINATION subsection are:

  * SWIM_MEMBER_STATUS (mandatory) (0 = alive, 1 = suspected, 2 = dead, 3 = left);
  * SWIM_MEMBER_ADDRESS and SWIM_MEMBER_PORT (mandatory) member IP and port;
  * SWIM_MEMBER_UUID (mandatory) (member UUID);
  * SWIM_MEMBER_GENERATION + SWIM_MEMBER_VERSION (mandatory) (the member :ref:`incarnation <swim-incarnation_description>`);
  * SWIM_MEMBER_PAYLOAD (not mandatory) (member payload)
    (MessagePack type is MP_BIN).

  Note that absence of SWIM_MEMBER_PAYLOAD means nothing -
  it is not the same as a payload with zero size.

* SWIM_ANTI_ENTROPY subsection -- a helper for the
  dissemination. It contains all the same fields as the
  dissemination sub, but all of them are mandatory, including
  payload even when payload size is 0. Anti-entropy eventually
  spreads changes which for any reason are not spread by the dissemination.

* SWIM_QUIT subsection -- statement that the sender has left the
  cluster gracefully, for example via :ref:`swim_object:quit() <swim-quit>`,
  and should not be considered dead. Sender
  status should be changed to 'left'.

  In the SWIM_QUIT subsection are:

  * SWIM_QUIT_GENERATION + SWIM_QUIT_VERSION (the sender :ref:`incarnation <swim-incarnation_description>`).

.. _swim-incarnation_description:

The **incarnation** is a 128-bit cdata value which is part of
each member's configuration and is present in most messages.
It has two parts: generation and version.

Generation is persistent. By default it has the number of
microseconds since the epoch (compare the value returned by
:ref:`clock_realtime64() <clock-time>`). Optionally a user
can set generation during :ref:`new() <swim-new>`.

Version is volatile. It is initially 0.
It is incremented automatically every time that a change occurs.

The incarnation, or sometimes the version alone,
is useful for deciding to ignore obsolete messages,
for updating a member's attributes on remote nodes,
and for refuting messages that say a member is dead.

If the member's incarnation is less than the locally stored incarnation,
then the message is obsolete.
This can happen because UDP allows reordering and duplication.

If the member's incarnation in a message is greater than the locally stored incarnation,
then most of its attributes  (IP,
port, status) should be updated with the values received in the message.
However, the payload attribute should not be updated
unless it is present in the message. Because of its relatively large size,
payload is not always included in every message.

Refutation usually happens when a false-positive failure
detection has happened. In such a case the member thought to be
dead receives that information from other members, increases its own
incarnation, and spreads a message saying the member is
alive (a "refutation").

Note: in the original version of Tarantool SWIM, and in the original
SWIM specification, there is no generation and the incarnation consists
of only the version. Generation was added because it is useful for
detecting obsolete messages left over from a previous life of an instance
that has restarted.




