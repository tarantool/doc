===========================================================
                Module `lua/utils`
===========================================================

.. _c_api-utils-luaL_pushcdata:

.. c:function:: void *luaL_pushcdata(struct lua_State *L, uint32_t ctypeid)

    Push cdata of given ``ctypeid`` onto the stack.

    CTypeID must be used from FFI at least once. Allocated memory returned
    uninitialized. Only numbers and pointers are supported.

    :param lua_State*     L: Lua State
    :param uint32_t ctypeid: FFI's CTypeID of this cdata

    :return: memory associated with this cdata

    See also: :ref:`luaL_checkcdata()<c_api-utils-luaL_checkcdata>`

.. _c_api-utils-luaL_checkcdata:

.. c:function:: void *luaL_checkcdata(struct lua_State *L, int idx, uint32_t *ctypeid)

    Check whether the function argument ``idx`` is a cdata.

    :param lua_State*      L: Lua State
    :param int           idx: stack index
    :param uint32_t* ctypeid: output argument. FFI's CTypeID of returned cdata

    :return: memory associated with this cdata

    See also: :ref:`luaL_pushcdata()<c_api-utils-luaL_pushcdata>`

.. c:function:: void luaL_setcdatagc(struct lua_State *L, int idx)

    Set finalizer function on a cdata object.

    Equivalent to call `ffi.gc(obj, function)`. Finalizer function must be on
    the top of the stack.

    :param lua_State*      L: Lua State
    :param int           idx: stack index

.. c:function:: uint32_t luaL_ctypeid(struct lua_State *L, const char *ctypename)

    Return CTypeID (FFI) of given СDATA type.

    :param lua_State*          L: Lua State
    :param const char* ctypename: C type name as string (e.g. "struct request"
                                  or "uint32_t")

    :return: CTypeID

    See also: :ref:`luaL_pushcdata()<c_api-utils-luaL_pushcdata>`,
    :ref:`luaL_checkcdata()<c_api-utils-luaL_checkcdata>`

.. c:function:: int luaL_cdef(struct lua_State *L, const char *ctypename)

    Declare symbols for FFI.

    :param lua_State*          L: Lua State
    :param const char* ctypename: C definitions (e.g. "struct stat")

    :return: 0 on success
    :return: ``LUA_ERRRUN``, ``LUA_ERRMEM`` or ``LUA_ERRERR`` otherwise.

    See also: ``ffi.cdef(def)``

.. c:function:: void luaL_pushuint64(struct lua_State *L, uint64_t val)

    Push uint64_t onto the stack.

    :param lua_State*  L: Lua State
    :param uint64_t  val: value to push

.. c:function:: void luaL_pushint64(struct lua_State *L, int64_t val)

    Push int64_t onto the stack.

    :param lua_State* L: Lua State
    :param int64_t  val: value to push

.. c:function:: uint64_t luaL_checkuint64(struct lua_State *L, int idx)

    Check whether the argument idx is a uint64 or a convertable string and
    returns this number.

    :throws: error if the argument can't be converted

.. c:function:: uint64_t luaL_checkint64(struct lua_State *L, int idx)

    Check whether the argument idx is a int64 or a convertable string and
    returns this number.

    :throws: error if the argument can't be converted

.. c:function:: uint64_t luaL_touint64(struct lua_State *L, int idx)

    Check whether the argument idx is a uint64 or a convertable string and
    returns this number.

    :return: the converted number or 0 of argument can't be converted

.. c:function:: int64_t luaL_toint64(struct lua_State *L, int idx)

    Check whether the argument idx is a int64 or a convertable string and
    returns this number.

    :return: the converted number or 0 of argument can't be converted

.. c:function:: void luaT_pushtuple(struct lua_State *L, box_tuple_t *tuple)

    Push a tuple onto the stack.

    :param lua_State*     L: Lua State

    :throws: error on OOM

    See also: :ref:`luaT_istuple <c_api-utils-luaT_istuple>`

.. _c_api-utils-luaT_istuple:

.. c:function:: box_tuple_t *luaT_istuple(struct lua_State *L, int idx)

    Check whether ``idx`` is a tuple.

    :param lua_State*     L: Lua State
    :param int          idx: the stack index

    :return: non-NULL if ``idx`` is a tuple
    :return: NULL if ``idx`` is not a tuple

.. c:function:: int luaT_error(lua_State *L)

    Re-throw the last Tarantool error as a Lua object.

    See also: `lua_error() <https://www.lua.org/manual/5.1/manual.html#lua_error>`_,
              :ref:`box_error_last() <c_api-error-box_error_last>`.

.. c:function:: int luaT_cpcall(lua_State *L, lua_CFunction func, void *ud)

    Similar to `lua_cpcall() <https://www.lua.org/manual/5.1/manual.html#lua_cpcall>`_,
    but with the proper support of Tarantool errors.

.. c:function:: lua_State *luaT_state(void)

    Get the global Lua state used by Tarantool.
