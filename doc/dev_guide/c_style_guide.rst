
C Style Guide
=============

We use Git for revision control. The latest development is happening in the
default branch (currently ``master``). Our git repository is hosted on GitHub,
and can be checked out with ``git clone git://github.com/tarantool/tarantool.git``
(anonymous read-only access).

If you have any questions about Tarantool internals, please post them on
`StackOverflow <https://stackoverflow.com/questions/tagged/tarantool>`_ or
ask Tarantool developers directly in `telegram <http://telegram.me/tarantool>`_.

**General guidelines**

The project's coding style is inspired by the `Linux kernel coding style
<https://www.kernel.org/doc/html/v4.10/process/coding-style.html>`_.

However, we have some additional guidelines, either unique to Tarantool or
deviating from the Kernel guidelines. Below we rewrite the Linux kernel
coding style according to the Tarantool's style features.

Tarantool coding style
----------------------

This is a short document describing the preferred coding style for the
Tarantool developers and contributors. We **insist** on following these rules
in order to make our code consistent and understandable to any developer.

Chapter 1: Indentation
~~~~~~~~~~~~~~~~~~~~~~

Tabs are 8 characters (8-width tabs, not 8 whitespaces), and thus indentations
are also 8 characters. There are heretic movements that try to make indentations
4 (or even 2!) characters deep, and that is akin to trying to define the
value of PI to be 3.

Rationale: The whole idea behind indentation is to clearly define where
a block of control starts and ends. Especially when you've been looking
at your screen for 20 straight hours, you'll find it a lot easier to see
how the indentation works if you have large indentations.

Now, some people will claim that having 8-character indentations makes
the code move too far to the right, and makes it hard to read on a
80-character terminal screen. The answer to that is that if you need
more than 3 levels of indentation, you're screwed anyway, and should fix
your program.

8-char indents make things easier to read and have the added
benefit of warning you when you're nesting your functions too deep.
Heed that warning.

The preferred way to ease multiple indentation levels in a switch statement is
to align the ``switch`` and its subordinate ``case`` labels in the same column
instead of ``double-indenting`` the ``case`` labels. E.g.:

..  code-block:: c

    switch (suffix) {
    case 'G':
    case 'g':
      mem <<= 30;
      break;
    case 'M':
    case 'm':
      mem <<= 20;
      break;
    case 'K':
    case 'k':
      mem <<= 10;
      /* fall through */
    default:
      break;
    }

Don't put multiple statements on a single line unless you have
something to hide:

..  code-block:: c

    if (condition) do_this;
      do_something_everytime;

Don't put multiple assignments on a single line either. Avoid tricky expressions.

Outside of comments and documentation, spaces are never
used for indentation, and the above example is deliberately broken.

Get a decent editor and don't leave whitespace at the end of lines.

Chapter 2: Breaking long lines and strings
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Coding style is all about readability and maintainability using commonly
available tools.

The limit on the length of lines is 80 columns and this is a strongly
preferred limit. As for comments, the same limit of 80 columns is applied.

Statements longer than 80 columns will be broken into sensible chunks, unless
exceeding 80 columns significantly increases readability and does not hide
information. Descendants are always substantially shorter than the parent and
are placed substantially to the right. The same applies to function headers
with a long argument list.

Chapter 3: Placing Braces and Spaces
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The other issue that always comes up in C styling is the placement of
braces. Unlike the indent size, there are few technical reasons to
choose one placement strategy over the other, but the preferred way, as
shown to us by the prophets Kernighan and Ritchie, is to put the opening
brace last on the line, and put the closing brace first, thus:

..  code-block:: c

    if (x is true) {
      we do y
    }

This applies to all non-function statement blocks (if, switch, for,
while, do). E.g.:

..  code-block:: c

    switch (action) {
    case KOBJ_ADD:
      return "add";
    case KOBJ_REMOVE:
      return "remove";
    case KOBJ_CHANGE:
      return "change";
    default:
      return NULL;
    }

However, there is one special case, namely functions: they have the
opening brace at the beginning of the next line, thus:

..  code-block:: c

    int
    function(int x)
    {
      body of function
    }

Heretic people all over the world have claimed that this inconsistency
is ... well ... inconsistent, but all right-thinking people know that
(a) K&R are **right** and (b) K&R are right. Besides, functions are
special anyway (you can't nest them in C).

Note that the closing brace is empty on a line of its own, **except** in
the cases where it is followed by a continuation of the same statement,
i.e. a ``while`` in a do-statement or an ``else`` in an if-statement, like
this:

..  code-block:: c

    do {
      body of do-loop
    } while (condition);

and

..  code-block:: c

    if (x == y) {
      ..
    } else if (x > y) {
      ...
    } else {
      ....
    }

Rationale: K&R.

Also, note that this brace-placement also minimizes the number of empty
(or almost empty) lines, without any loss of readability. Thus, as the
supply of new-lines on your screen is not a renewable resource (think
25-line terminal screens here), you have more empty lines to put
comments on.

Do not unnecessarily use braces where a single statement will do.

..  code-block:: c

    if (condition)
      action();

and

..  code-block:: c

    if (condition)
      do_this();
    else
      do_that();

This does not apply if only one branch of a conditional statement is a single
statement; in the latter case use braces in both branches:

..  code-block:: c

    if (condition) {
      do_this();
      do_that();
    } else {
      otherwise();
    }

Chapter 3.1: Spaces
^^^^^^^^^^^^^^^^^^^

Tarantool style for use of spaces depends (mostly) on
function-versus-keyword usage. Use a space after (most) keywords. The
notable exceptions are ``sizeof``, ``typeof``, ``alignof``, and ``__attribute__``,
which look somewhat like functions (and are usually used with parentheses,
although they are not required in the language, as in: ``sizeof info`` after
``struct fileinfo info;`` is declared).

So use a space after these keywords:

..  code-block:: c

    if, switch, case, for, do, while

but not with ``sizeof``, ``typeof``, ``alignof``, or ``__attribute__``. E.g.,

..  code-block:: c

    s = sizeof(struct file);

Do not add spaces around (inside) parenthesized expressions. This example is
**bad**:

..  code-block:: c

    s = sizeof( struct file );

When declaring pointer data or a function that returns a pointer type, the
preferred use of ``*`` is adjacent to the data name or function name and not
adjacent to the type name. Examples:

..  code-block:: c

    char *linux_banner;
    unsigned long long memparse(char *ptr, char **retptr);
    char *match_strdup(substring_t *s);

Use one space around (on each side of) most binary and ternary operators,
such as any of these::

    =  +  -  <  >  *  /  %  |  &  ^  <=  >=  ==  !=  ?  :

but no space after unary operators::

    &  *  +  -  ~  !  sizeof  typeof  alignof  __attribute__  defined

no space before the postfix increment & decrement unary operators::

    ++  --

no space after the prefix increment & decrement unary operators::

    ++  --

and no space around the ``.`` and ``->`` structure member operators.

Do not split a cast operator from its argument with a whitespace,
e.g. ``(ssize_t)inj->iparam``.

Do not leave trailing whitespace at the ends of lines. Some editors with
``smart`` indentation will insert whitespace at the beginning of new lines as
appropriate, so you can start typing the next line of code right away.
However, some such editors do not remove the whitespace if you end up not
putting a line of code there, such as if you leave a blank line. As a result,
you end up with lines containing trailing whitespace.

Git will warn you about patches that introduce trailing whitespace, and can
optionally strip the trailing whitespace for you; however, if applying a series
of patches, this may make later patches in the series fail by changing their
context lines.

Chapter 4: Naming
~~~~~~~~~~~~~~~~~

C is a Spartan language, and so should your naming be. Unlike Modula-2
and Pascal programmers, C programmers do not use cute names like
ThisVariableIsATemporaryCounter. A C programmer would call that
variable ``tmp``, which is much easier to write, and not the least more
difficult to understand.

HOWEVER, while mixed-case names are frowned upon, descriptive names for
global variables are a must. To call a global function ``foo`` is a
shooting offense.

GLOBAL variables (to be used only if you **really** need them) need to
have descriptive names, as do global functions. If you have a function
that counts the number of active users, you should call that
``count_active_users()`` or similar, you should **not** call it ``cntusr()``.

Encoding the type of a function into the name (so-called Hungarian
notation) is brain damaged - the compiler knows the types anyway and can
check those, and it only confuses the programmer. No wonder MicroSoft
makes buggy programs.

LOCAL variable names should be short, and to the point. If you have
some random integer loop counter, it should probably be called ``i``.
Calling it ``loop_counter`` is non-productive, if there is no chance of it
being misunderstood. Similarly, ``tmp`` can be just about any type of
variable that is used to hold a temporary value.

If you are afraid to mix up your local variable names, you have another
problem, which is called the function-growth-hormone-imbalance syndrome.
See chapter 6 (Functions).

For function naming we have a convention is to use:

*    ``new``/``delete`` for functions which
     allocate + initialize and destroy + deallocate an object,
*    ``create``/``destroy`` for functions which initialize/destroy an object
     but do not handle memory management,
*    ``init``/``free`` for functions which initialize/destroy libraries and subsystems.

Chapter 5: Typedefs
~~~~~~~~~~~~~~~~~~~

Please don't use things like ``vps_t``.
It's a **mistake** to use typedef for structures and pointers. When you see a

..  code-block:: c

    vps_t a;

in the source, what does it mean?
In contrast, if it says

..  code-block:: c

    struct virtual_container *a;

you can actually tell what ``a`` is.

Lots of people think that typedefs ``help readability``. Not so. They are
useful only for:

#.  Totally opaque objects (where the typedef is actively used to **hide**
    what the object is).

    Example: ``pte_t`` etc. opaque objects that you can only access using
    the proper accessor functions.

    ..  note::

        Opaqueness and ``accessor functions`` are not good in themselves.
        The reason we have them for things like pte_t etc. is that there
        really is absolutely **zero** portably accessible information there.

#.  Clear integer types, where the abstraction **helps** avoid confusion
    whether it is ``int`` or ``long``.

    u8/u16/u32 are perfectly fine typedefs, although they fit into
    point 4 better than here.

    ..  note::

        Again - there needs to be a **reason** for this. If something is
        ``unsigned long``, then there's no reason to do
        typedef unsigned long myflags_t;

    but if there is a clear reason for why it under certain circumstances
    might be an ``unsigned int`` and under other configurations might be
    ``unsigned long``, then by all means go ahead and use a typedef.

#.  When you use sparse to literally create a **new** type for
    type-checking.

#.  New types which are identical to standard C99 types, in certain
    exceptional circumstances.

    Although it would only take a short amount of time for the eyes and
    brain to become accustomed to the standard types like ``uint32_t``,
    some people object to their use anyway.

    When editing existing code which already uses one or the other set
    of types, you should conform to the existing choices in that code.

Maybe there are other cases too, but the rule should basically be to NEVER
EVER use a typedef unless you can clearly match one of those rules.

In general, a pointer, or a struct that has elements that can reasonably
be directly accessed should **never** be a typedef.

Chapter 6: Functions
~~~~~~~~~~~~~~~~~~~~

Functions should be short and sweet, and do just one thing. They should
fit on one or two screenfuls of text (the ISO/ANSI screen size is 80x24,
as we all know), and do one thing and do that well.

The maximum length of a function is inversely proportional to the
complexity and indentation level of that function. So, if you have a
conceptually simple function that is just one long (but simple)
case-statement, where you have to do lots of small things for a lot of
different cases, it's OK to have a longer function.

However, if you have a complex function, and you suspect that a
less-than-gifted first-year high-school student might not even
understand what the function is all about, you should adhere to the
maximum limits all the more closely. Use helper functions with
descriptive names (you can ask the compiler to in-line them if you think
it's performance-critical, and it will probably do a better job of it
than you would have done).

Another measure of the function is the number of local variables. They
shouldn't exceed 5-10, or you're doing something wrong. Re-think the
function, and split it into smaller pieces. A human brain can
generally easily keep track of about 7 different things, anything more
and it gets confused. You know you're brilliant, but maybe you'd like
to understand what you did 2 weeks from now.

In function prototypes, include parameter names with their data types.
Although this is not required by the C language, it is preferred in Tarantool
because it is a simple way to add valuable information for the reader.

Note that we place the function return type on the line before the name and signature.

Chapter 7: Centralized exiting of functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Albeit deprecated by some people, the equivalent of the goto statement is
used frequently by compilers in form of the unconditional jump instruction.

The goto statement comes in handy when a function exits from multiple
locations and some common work such as cleanup has to be done. If there is no
cleanup needed then just return directly.

Choose label names which say what the goto does or why the goto exists. An
example of a good name could be ``out_free_buffer:`` if the goto frees ``buffer``.
Avoid using GW-BASIC names like ``err1:`` and ``err2:``, as you would have to
renumber them if you ever add or remove exit paths, and they make correctness
difficult to verify anyway.

The rationale for using gotos is:

- unconditional statements are easier to understand and follow
- nesting is reduced
- errors by not updating individual exit points when making
  modifications are prevented
- saves the compiler work to optimize redundant code away ;)

..  code-block:: c

    int
    fun(int a)
    {
      int result = 0;
      char *buffer;

      buffer = kmalloc(SIZE, GFP_KERNEL);
      if (!buffer)
        return -ENOMEM;

      if (condition1) {
        while (loop1) {
          ...
        }
        result = 1;
        goto out_free_buffer;
      }
      ...
    out_free_buffer:
      kfree(buffer);
      return result;
    }

A common type of bug to be aware of is ``one err bugs`` which look like this:

..  code-block:: c

    err:
      kfree(foo->bar);
      kfree(foo);
      return ret;

The bug in this code is that on some exit paths ``foo`` is NULL. Normally the
fix for this is to split it up into two error labels ``err_free_bar:`` and
``err_free_foo:``:

..  code-block:: c

    err_free_bar:
     kfree(foo->bar);
    err_free_foo:
     kfree(foo);
     return ret;

Ideally you should simulate errors to test all exit paths.

Chapter 8: Commenting
~~~~~~~~~~~~~~~~~~~~~

Comments are good, but there is also a danger of over-commenting. NEVER
try to explain HOW your code works in a comment: it's much better to
write the code so that the **working** is obvious, and it's a waste of
time to explain badly written code.

Generally, you want your comments to tell WHAT your code does, not HOW.
Also, try to avoid putting comments inside a function body: if the
function is so complex that you need to separately comment parts of it,
you should probably go back to chapter 6 for a while. You can make
small comments to note or warn about something particularly clever (or
ugly), but try to avoid excess. Instead, put the comments at the head
of the function, telling people what it does, and possibly WHY it does
it.

When commenting the Tarantool C API functions, please use Doxygen comment format,
Javadoc flavor, i.e. `@tag` rather than `\\tag`.
The main tags in use are ``@param``, ``@retval``, ``@return``, ``@see``,
``@note`` and ``@todo``.

Every function, except perhaps a very short and obvious one, should have a
comment. A sample function comment may look like below:

..  code-block:: c

    /**
     * Write all data to a descriptor.
     *
     * This function is equivalent to 'write', except it would ensure
     * that all data is written to the file unless a non-ignorable
     * error occurs.
     *
     * @retval 0  Success
     * @retval 1 An error occurred (not EINTR)
     */
    static int
    write_all(int fd, void *data, size_t len);

It's also important to comment data types, whether they are basic types or
derived ones. To this end, use just one data declaration per line (no commas
for multiple data declarations). This leaves you room for a small comment on
each item, explaining its use.

Public structures and important structure members should be commented as well.

In C comments out of functions and inside of functions should be different in
how they are started. Everything else is wrong. Below are correct examples.
``/**`` comes for documentation comments, ``/*`` for local not documented comments.
However the difference is vague already, so the rule is simple:
out of function use ``/**``, inside use ``/*``.

..  code-block:: c

    /**
     * Out of function comment, option 1.
     */

    /** Out of function comment, option 2. */

    int
    function()
    {
        /* Comment inside function, option 1. */

        /*
         * Comment inside function, option 2.
         */
    }

If a function has declaration and implementation separated, the function comment
should be for the declaration. Usually in the header file. Don't duplicate the
comment.

A comment and the function signature should be synchronized. Double-check if the
parameter names are the same as used in the comment, and mean the same.
Especially when you change one of them - ensure you changed the other.

Chapter 9: Macros, Enums and RTL
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Names of macros defining constants and labels in enums are capitalized.

..  code-block:: c

    #define CONSTANT 0x12345

Enums are preferred when defining several related constants.

CAPITALIZED macro names are appreciated but macros resembling functions
may be named in lower case.

Generally, inline functions are preferable to macros resembling functions.

Macros with multiple statements should be enclosed in a do - while block:

..  code-block:: c

    #define macrofun(a, b, c)       \
      do {                          \
        if (a == 5)                 \
          do_this(b, c);            \
      } while (0)

Things to avoid when using macros:

1)  macros that affect control flow:

    ..  code-block:: c

        #define FOO(x)                  \
          do {                          \
            if (blah(x) < 0)            \
              return -EBUGGERED;        \
          } while (0)

    is a **very** bad idea. It looks like a function call but exits the ``calling``
    function; don't break the internal parsers of those who will read the code.

2)  macros that depend on having a local variable with a magic name:

    ..  code-block:: c

        #define FOO(val) bar(index, val)

    might look like a good thing, but it's confusing as hell when one reads the
    code and it's prone to breakage from seemingly innocent changes.

3)  macros with arguments that are used as l-values: ``FOO(x) = y;`` will
    bite you if somebody e.g. turns FOO into an inline function.

4)  forgetting about precedence: macros defining constants using expressions
    must enclose the expression in parentheses. Beware of similar issues with
    macros using parameters.

    ..  code-block:: c

        #define CONSTANT 0x4000
        #define CONSTEXP (CONSTANT | 3)

5)  namespace collisions when defining local variables in macros resembling
    functions:

    ..  code-block:: c

        #define FOO(x)            \
        ({                        \
          typeof(x) ret;          \
          ret = calc_ret(x);      \
          (ret);                  \
        })

    ret is a common name for a local variable - ``__foo_ret`` is less likely
    to collide with an existing variable.

Chapter 10: Allocating memory
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Prefer specialized allocators like ``region``, ``mempool``, ``smalloc`` to
``malloc()/free()`` for any performance-intensive or large memory allocations.
Repetitive use of ``malloc()``/``free()`` can lead to memory fragmentation
and should therefore be avoided.

Always free all allocated memory, even allocated  at start-up. We aim at being
valgrind leak-check clean, and in most cases it's just as easy to ``free()`` the
allocated memory as it is to write a valgrind suppression. Freeing all allocated
memory is also dynamic-load friendly: assuming a plug-in can be dynamically
loaded and unloaded multiple times, reload should not lead to a memory leak.

Chapter 11: The inline disease
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There appears to be a common misperception that gcc has a magic "make me
faster" speedup option called ``inline``. While the use of inlines can be
appropriate, it very often is not. Abundant use of the inline keyword leads to
a much bigger kernel, which in turn slows the system as a whole down, due to a
bigger icache footprint for the CPU and simply because there is less memory
available for the pagecache. Just think about it; a pagecache miss causes a
disk seek, which easily takes 5 milliseconds. There are a LOT of cpu cycles
that can go into these 5 milliseconds.

A reasonable rule of thumb is to not put inline at functions that have more
than 3 lines of code in them. An exception to this rule are the cases where
a parameter is known to be a compiletime constant, and as a result of this
constantness you *know* the compiler will be able to optimize most of your
function away at compile time.

Often people argue that adding inline to functions that are static and used
only once is always a win since there is no space tradeoff. While this is
technically correct, gcc is capable of inlining these automatically without
help, and the maintenance issue of removing the inline when a second user
appears outweighs the potential value of the hint that tells gcc to do
something it would have done anyway.

Chapter 12: Function return values and names
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Functions can return values of many different kinds, and one of the
most common is a value indicating whether the function succeeded or
failed.

In 99.99999% of all cases in Tarantool we return 0 on success, non-zero on error
(-1 usually). Errors are saved into a diagnostics area which is global per fiber.
We never return error codes as a result of a function.

Functions whose return value is the actual result of a computation, rather
than an indication of whether the computation succeeded, are not subject to
this rule. Generally they indicate failure by returning some out-of-range
result. Typical examples would be functions that return pointers; they use
NULL or the mechanism to report failure.

Chapter 13: Editor modelines and other cruft
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Some editors can interpret configuration information embedded in source files,
indicated with special markers. For example, emacs interprets lines marked
like this:

..  code-block:: c

    -*- mode: c -*-

Or like this:

..  code-block:: c

    /*
    Local Variables:
    compile-command: "gcc -DMAGIC_DEBUG_FLAG foo.c"
    End:
    */

Vim interprets markers that look like this:

..  code-block:: c

    /* vim:set sw=8 noet */

Do not include any of these in source files. People have their own personal
editor configurations, and your source files should not override them. This
includes markers for indentation and mode configuration. People may use their
own custom mode, or may have some other magic method for making indentation
work correctly.

Chapter 14: Conditional Compilation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Wherever possible, don't use preprocessor conditionals (``#if``, ``#ifdef``) in
.c files; doing so makes code harder to read and logic harder to follow. Instead,
use such conditionals in a header file defining functions for use in those .c
files, providing no-op stub versions in the #else case, and then call those
functions unconditionally from .c files. The compiler will avoid generating
any code for the stub calls, producing identical results, but the logic will
remain easy to follow.

Prefer to compile out entire functions, rather than portions of functions or
portions of expressions. Rather than putting an ``#ifdef`` in an expression,
factor out part or all of the expression into a separate helper function and
apply the condition to that function.

If you have a function or variable which may potentially go unused in a
particular configuration, and the compiler would warn about its definition
going unused, do not compile it and use #if for this.

At the end of any non-trivial ``#if`` or ``#ifdef`` block (more than a few lines),
place a comment after the #endif on the same line, noting the conditional
expression used. For instance:

..  code-block:: c

    #ifdef CONFIG_SOMETHING
    ...
    #endif /* CONFIG_SOMETHING */

Chapter 15: Header files
~~~~~~~~~~~~~~~~~~~~~~~~

Use ``#pragma once`` in the headers. As the header guards we refer to this
construction:

..  code-block:: c

    #ifndef THE_HEADER_IS_INCLUDED
    #define THE_HEADER_IS_INCLUDED

    // ... the header code ...

    #endif // THE_HEADER_IS_INCLUDED

It works fine, but the guard name ``THE_HEADER_IS_INCLUDED`` tends to
become outdated when the file is moved or renamed. This is especially
painful with multiple files having the same name in the project, but
different path. For instance, we have 3 ``error.h`` files, which means for
each of them we need to invent a new header guard name, and not forget to
update them if the files are moved or renamed.

For that reason we use ``#pragma once`` in all the new code, which shortens
the header file down to this:

..  code-block:: c

    #pragma once

    // ... header code ...

Chapter 16: Other
~~~~~~~~~~~~~~~~~

*   We don't apply ``!`` operator to non-boolean values. It means, to check
    if an integer is not 0, you use ``!= 0``. To check if a pointer is not NULL,
    you use ``!= NULL``. The same for ``==``.

*   Select GNU C99 extensions are acceptable. It's OK to mix declarations and
    statements, use true and false.

*   The not-so-current list of all GCC C extensions can be found at:
    http://gcc.gnu.org/onlinedocs/gcc-4.3.5/gcc/C-Extensions.html

Appendix I: References
~~~~~~~~~~~~~~~~~~~~~~

*   `The C Programming Language, Second Edition <https://en.wikipedia.org/wiki/The_C_Programming_Language>`_
    by Brian W. Kernighan and Dennis M. Ritchie.
    Prentice Hall, Inc., 1988.
    ISBN 0-13-110362-8 (paperback), 0-13-110370-9 (hardback).

*   `The Practice of Programming <https://en.wikipedia.org/wiki/The_Practice_of_Programming>`_
    by Brian W. Kernighan and Rob Pike.
    Addison-Wesley, Inc., 1999.
    ISBN 0-201-61586-X.

*   `GNU manuals <http://www.gnu.org/manual/>`_ - where in compliance with K&R
    and this text - for **cpp**, **gcc**, **gcc internals** and **indent**

*   `WG14 International standardization workgroup for the programming
    language C <http://www.open-std.org/JTC1/SC22/WG14/>`_

*   `Kernel CodingStyle, by greg@kroah.com at OLS 2002
    <http://www.kroah.com/linux/talks/ols_2002_kernel_codingstyle_talk/html/>`_

