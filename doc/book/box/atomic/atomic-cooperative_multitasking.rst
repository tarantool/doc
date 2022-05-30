..  _atomic-cooperative_multitasking:

Cooperative multitasking
========================

Cooperative multitasking means that unless a running fiber deliberately yields
control, it is not preempted by some other fiber. But a running fiber will
deliberately yield when it encounters a “yield point”: a transaction commit,
an operating system call, or an explicit :ref:`"yield" <fiber-yield>` request.
Any system call which can block will be performed asynchronously, and any running
fiber which must wait for a system call will be preempted, so that another
ready-to-run fiber takes its place and becomes the new running fiber.

This model makes all programmatic locks unnecessary: cooperative multitasking
ensures that there will be no concurrency around a resource, no race conditions,
and no memory consistency issues. The way to achieve this is simple:
Use no yields, explicit or implicit in critical sections, and no one can 
interfere with code execution.

When dealing with small requests, such as simple UPDATE or INSERT or DELETE or 
SELECT, fiber scheduling is fair: it takes only a little time to process the 
request, schedule a disk write, and yield to a fiber serving the next client.

However, a function may perform complex computations or be written in
such a way that yields take a long time to occur. This can lead to
unfair scheduling when a single client throttles the rest of the system, or to
apparent stalls in request processing. Avoiding this situation is
the responsibility of the function’s author.
