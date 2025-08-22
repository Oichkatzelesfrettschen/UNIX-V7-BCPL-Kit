# Mailbox Design

This repository uses a simple mailbox abstraction for inter-process
communication. Each mailbox is a fixed-size circular buffer that stores
messages in the order they are posted. Mailboxes live in kernel space and
are referenced through small integer identifiers. Every message consists of
a user-defined payload up to a predetermined limit.

Processes send messages by copying bytes into a mailbox and receive them by
reading from the same buffer. The kernel serialises concurrent access so
that senders and receivers never interfere with one another. When the
buffer becomes full, further send attempts block until space becomes
available or a timeout expires.

## API Functions

The interface exposes four primitive operations:

| Function          | Description                                           |
|-------------------|-------------------------------------------------------|
| `mbox_create(n)`  | Create a mailbox that can hold up to `n` messages and
                      return its identifier. |
| `mbox_send(id, p, len, timeout)` | Copy `len` bytes from address `p` into
  the mailbox `id`. The call blocks until space is available or the timeout
  elapses. Returns `0` on success or a negative error code. |
| `mbox_recv(id, p, len, timeout)` | Retrieve the next message from mailbox
  `id` and copy up to `len` bytes to address `p`. Blocks if no message is
  present. On timeout it returns an error. |
| `mbox_destroy(id)`| Remove the mailbox and wake any waiting senders or
  receivers with an error code. |

All functions are thread safe and may be called from either user or kernel
context depending on the system configuration.

### Status Codes

Kernel helpers such as `mailbox_enqueue` and `mailbox_dequeue` return an
`ipc_status_t` value. `IPC_STATUS_SUCCESS` indicates a successful transfer,
`IPC_STATUS_EMPTY` signals that no message was available, and
`IPC_STATUS_ERROR` reports a generic failure.

## Timeout Semantics

Send and receive operations accept a timeout value measured in
milliseconds. A value of `0` means the call should return immediately if
it cannot proceed without blocking. A negative value requests an infinite
wait. Timeouts are relative; the kernel measures the requested interval
from the moment it begins waiting. If the timeout expires before the
operation completes, the function returns `-ETIMEDOUT` and no data is
transferred.

## Example

```c
int id = mbox_create(16);           /* 16 message slots */
char msg[] = "hello";
if (mbox_send(id, msg, sizeof msg, 1000) < 0)
    error("send failed\n");
```
