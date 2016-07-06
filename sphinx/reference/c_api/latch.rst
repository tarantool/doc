===========================================================
                        Module `latch`
===========================================================

.. c:type:: box_latch_t

    A lock for cooperative multitasking environment

.. c:function:: box_latch_t *box_latch_new(void)

    Allocate and initialize the new latch.

    :return: allocated latch object
    :rtype: box_latch_t *

.. c:function:: void box_latch_delete(box_latch_t *latch)

    Destroy and free the latch.

    :param box_latch_t* latch: latch to destroy

.. c:function:: void box_latch_lock(box_latch_t *latch)

   Lock a latch. Waits indefinitely until the current fiber can gain access to
   the latch.

    :param box_latch_t* latch: latch to lock

.. c:function:: int box_latch_trylock(box_latch_t *latch)

    Try to lock a latch. Return immediately if the latch is locked.

    :param box_latch_t* latch: latch to lock
    :return: status of operation. 0 - success, 1 - latch is locked
    :rtype:  int

.. c:function:: void box_latch_unlock(box_latch_t *latch)

    Unlock a latch. The fiber calling this function must own the latch.

    :param box_latch_t* latch: latch to unlock
