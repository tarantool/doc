.. _membership:

-------------------------------------------------------------------------------
Module `membership`
-------------------------------------------------------------------------------

This module is a ``membership`` library for Tarantool based on a gossip protocol.

This library builds a mesh from multiple Tarantool instances. The mesh monitors
itself, helps members discover everyone else in the group and get notified about
their status changes with low latency. It is built upon the ideas from Consul or,
more precisely, the SWIM algorithm.

The ``membership`` module works over UDP protocol and can operate even before
the ``box.cfg`` initialization.

.. _membership-datastruct:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Member data structure
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A member is represented by the table with the following fields:

* ``uri`` (string) is a Uniform Resource Identifier.
* ``status`` (string) is a string that takes one of the values below.

  * ``alive``: a member that replies to ping-messages is ``alive`` and well.
  * ``suspect``: if any member in the group cannot get a reply from any other
    member, the first member asks three other ``alive`` members to send a
    ping-message to the member in question. If there is no response, the latter
    becomes a ``suspect``.
  * ``dead``: a ``suspect`` becomes ``dead`` after a timeout.
  * ``left``: a member gets the ``left`` status after executing the
    :ref:`leave() <membership-leave>` function.

    .. note:: The gossip protocol guarantees that every member in the group
       becomes aware of any status change in two communication cycles.

* ``incarnation`` (number) is a value incremented every time the instance is
  becomes a ``suspect``, ``dead``, or updates its payload.
* ``payload`` (table) is auxiliary data that can be used by various modules.
* ``timestamp`` (number) is a value of ``fiber.time64()`` which:

  * corresponds to the last update of ``status`` or ``incarnation``;
  * is always local;
  * does not depend on other members' clock setting.

Below is an example of the table:

.. code-block:: tarantoolsession

   tarantool> membership.myself()
   ---
   uri: localhost:33001
   status: alive
   incarnation: 1
   payload:
       uuid: 2d00c500-2570-4019-bfcc-ab25e5096b73
   timestamp: 1522427330993752
   ...

.. _membership-api:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
API reference
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Below is a list of ``membership``'s common, encryption, subscription
functions, and options.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | Common functions                                                       |
    +--------------------------------------+---------------------------------+
    | :ref:`init(advertise_host, port)     | Initialize the ``membership``   |
    | <membership-init>`                   | module.                         |
    +--------------------------------------+---------------------------------+
    | :ref:`myself()                       | Get the member data structure   |
    | <membership-myself>`                 | of the current instance.        |
    +--------------------------------------+---------------------------------+
    | :ref:`get_member(uri)                | Get the member data structure   |
    | <membership-get-member>`             | for a given URI.                |
    +--------------------------------------+---------------------------------+
    | :ref:`members()                      | Obtain a table with all members |
    | <membership-members>`                | known to the current instance.  |
    +--------------------------------------+---------------------------------+
    | :ref:`pairs()                        | Shorthand for                   |
    | <membership-pairs>`                  | ``pairs(membership.members())``.|
    +--------------------------------------+---------------------------------+
    | :ref:`add_member(uri)                | Add a member to the group.      |
    | <membership-add-member>`             |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`probe_uri(uri)                 | Check if the member is in the   |
    | <membership-probe-uri>`              | group.                          |
    +--------------------------------------+---------------------------------+
    | :ref:`broadcast()                    | Discover members in LAN by      |
    | <membership-broadcast>`              | sending a UDP broadcast message.|
    +--------------------------------------+---------------------------------+
    | :ref:`set_payload(key, value)        | Update ``myself().payload`` and |
    | <membership-set-payload>`            | disseminate it.                 |
    +--------------------------------------+---------------------------------+
    | :ref:`leave()                        | Gracefully leave the group.     |
    | <membership-leave>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`is_encrypted()                 | Check if encryption is enabled. |
    | <membership-is-encrypted>`           |                                 |
    +--------------------------------------+---------------------------------+
    | Encryption functions                                                   |
    +--------------------------------------+---------------------------------+
    | :ref:`set_encryption_key(key)        | Set the key for low-level       |
    | <membership-set-enc-key>`            | message encryption.             |
    +--------------------------------------+---------------------------------+
    | :ref:`get_encryption_key()           | Retrieve the encryption key     |
    | <membership-get-enc-key>`            | in use.                         |
    +--------------------------------------+---------------------------------+
    | Subscription functions                                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`subscribe()                    | Subscribe for the members table |
    | <membership-subscribe>`              | updates.                        |
    +--------------------------------------+---------------------------------+
    | :ref:`unsubscribe()                  | Remove the subscription.        |
    | <membership-unsubscribe>`            |                                 |
    +--------------------------------------+---------------------------------+
    | Options                                                                |
    +--------------------------------------+---------------------------------+
    | :ref:`PROTOCOL_PERIOD_SECONDS        | Direct ping period.             |
    | <membership-protocol_period_seconds>`|                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`ACK_TIMEOUT_SECONDS            | ACK message wait time.          |
    | <membership-ack_timeout_seconds>`    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`ANTI_ENTROPY_PERIOD_SECONDS    | Anti-entropy synchronization    |
    | <member-anti_entropy_period_seconds>`| period.                         |
    +--------------------------------------+---------------------------------+
    | :ref:`SUSPECT_TIMEOUT_SECONDS        | Timeout to mark a ``suspect``   |
    | <membership-suspect_timeout_seconds>`| ``dead``.                       |
    +--------------------------------------+---------------------------------+
    | :ref:`NUM_FAILURE_DETECTION_SUBGROUPS| Number of members to ping a     |
    | <membership-num_fail_detect_subgr>`  | ``suspect`` indirectly.         |
    +--------------------------------------+---------------------------------+

.. module:: membership
   :noindex:

Common functions:

.. _membership-init:

.. function:: init(advertise_host, port)

   Initialize the ``membership`` module. This binds a UDP socket to ``0.0.0.0:<port>``,
   sets the ``advertise_uri`` parameter to ``<advertise_host>:<port>``, and
   ``incarnation`` to ``1``.

   The ``init()`` function can be called several times, the old socket will be
   closed and a new one opened.

   If the ``advertise_uri`` changes during the next ``init()``, the old URI is
   considered ``DEAD``. In order to leave the group gracefully, use the
   :ref:`leave() <membership-leave>` function.

   :param string advertise_host: a hostname or IP address to advertise to other members
   :param number port: a UDP port to bind
   :return: ``true``
   :rtype:  boolean
   :raises: socket bind error

.. _membership-myself:

.. function:: myself()

   :return: the :ref:`member data structure <membership-datastruct>`
             of the current instance.
   :rtype:  table

.. _membership-get-member:

.. function:: get_member(uri)

   :param string uri: the given member's ``advertise_uri``
   :return: the :ref:`member data structure <membership-datastruct>` of the
             instance with the given URI.
   :rtype:  table

.. _membership-members:

.. function:: members()

   Obtain all members known to the current instance.

   Editing this table has no effect.

   :return: a table with URIs as keys and corresponding
            :ref:`member data structures <membership-datastruct>`
            as values.
   :rtype:  table

.. _membership-pairs:

.. function:: pairs()

   A shorthand for ``pairs(membership.members())``.

   :return: Lua iterator

   It can be used in the following way:

   .. code-block:: lua

      for uri, member in memberhip.pairs()
        -- do something
      end

.. _membership-add-member:

.. function:: add_member(uri)

   Add a member with the given URI to the group and propagate this event to other
   members. Adding a member to a single instance is enough as everybody else
   in the group will receive the update with time. It does not matter who adds
   whom.

   :param string uri: the ``advertise_uri`` of the member to add
   :return: ``true`` or ``nil`` in case of an error
   :rtype:  boolean
   :raises: parse error if the URI cannot be parsed

.. _membership-probe-uri:

.. function:: probe_uri(uri)

   Send a message to a member to make sure it is in the group. If the member is ``alive``
   but not in the group, it is added. If it already is in the group, nothing happens.

   :param string uri: the ``advertise_uri`` of the member to ping
   :return: ``true`` if the member responds within 0.2 seconds, otherwise ``no response``
   :rtype:  boolean
   :raises: ``ping was not sent`` if the hostname could not be resolved

.. _membership-broadcast:

.. function:: broadcast()

   Discover members in local network by sending a UDP broadcast message to all
   networks discovered by a ``getifaddrs()`` C call.

   :return: ``true`` if broadcast was sent, ``false`` if ``getaddrinfo()`` fails.
   :rtype:  boolean

.. _membership-set-payload:

.. function:: set_payload(key, value)

   Update ``myself().payload`` and disseminate it along with the member status.

   Increments ``incarnation``.

   :param string key: a key to set in payload table
   :param value: auxiliary data
   :return: ``true``
   :rtype:  boolean

.. _membership-leave:

.. function:: leave()

   Gracefully leave the ``membership`` group. The node will be marked with
   the ``left`` status and no other members will ever try to reconnect it.

   :return: ``true``
   :rtype:  boolean

.. _membership-is-encrypted:

.. function:: is_encrypted()

   :return: ``true`` if encryption is enabled, ``false`` otherwise.
   :rtype:  boolean

Encryption functions:

.. _membership-set-enc-key:

.. function:: set_encryption_key(key)

   Set the key used for low-level message encryption.
   The key is either trimmed or padded automatically to be exactly 32 bytes.
   If the ``key`` value is ``nil``, the encryption is disabled.

   The encryption is handled by the ``crypto.cipher.aes256.cbc`` Tarantool
   module.

   For proper communication, all members must be configured to use the
   same encryption key. Otherwise, members report either ``dead`` or
   ``non-decryptable`` in their status.

   :param string key: encryption key
   :return: ``nil``.

.. _membership-get-enc-key:

.. function:: get_encryption_key()

   Retrieve the encryption key that is currently in use.

   :return: encryption key or ``nil`` if the encryption is disabled.
   :rtype: string

Subscription functions:

.. _membership-subscribe:

.. function:: subscribe()

   Subscribe for updates in the members table.

   :return: a ``fiber.cond`` object broadcasted whenever the members table changes.
   :rtype: object

.. _membership-unsubscribe:

.. function:: unsubscribe(cond)

   Remove subscription on ``cond`` obtained by the :ref:`subscribe() function <membership-subscribe>`.

   The ``cond``'s validity is not checked.

   :param cond: the ``fiber.cond`` object obtained from :ref:`subscribe() <membership-subscribe>`
   :return: ``nil``.

Below is a list of ``membership`` options. They can be set as follows:

.. code-block:: Lua

   options = require('membership.options')
   options.<option> = <value>

.. _membership-protocol_period_seconds:

.. option:: options.PROTOCOL_PERIOD_SECONDS

   Period of sending direct pings. Denoted as ``T'`` in the SWIM protocol.

.. _membership-ack_timeout_seconds:

.. option:: options.ACK_TIMEOUT_SECONDS

   Time to wait for ACK message after a ping. If a member is late to reply,
   the indirect ping algorithm is invoked.

.. _member-anti_entropy_period_seconds:

.. option:: options.ANTI_ENTROPY_PERIOD_SECONDS

   Period to perform the anti-entropy synchronization algorithm of the SWIM
   protocol.

.. _membership-suspect_timeout_seconds:

.. option:: options.SUSPECT_TIMEOUT_SECONDS

   Timeout to mark ``suspect`` members as ``dead``.

.. _membership-num_fail_detect_subgr:

.. option:: options.NUM_FAILURE_DETECTION_SUBGROUPS

   Number of members to try pinging a ``suspect`` indirectly. Denoted as ``k``
   in the SWIM protocol.
