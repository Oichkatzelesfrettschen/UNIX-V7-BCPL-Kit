#ifndef MAILBOX_H
#define MAILBOX_H

#include <ipc_status.h>
#include <spinlock.h>
#include <stddef.h>
#include <sys/types.h>

#ifdef __cplusplus
extern "C" {
#endif

struct mailbox_msg {
  struct mailbox_msg *next;
  size_t len;
  char data[];
};

struct mailbox {
  struct mailbox_msg *head;
  struct mailbox_msg *tail;
  struct spinlock lock;
};

void mailbox_init(struct mailbox *mb);
ipc_status_t mailbox_enqueue(struct mailbox *mb, const void *data, size_t len);
ipc_status_t mailbox_dequeue(struct mailbox *mb, void *buf, size_t len, size_t *out_len);

struct exo_proc {
  struct mailbox mbox;
};

ipc_status_t exo_send(struct exo_proc *proc, const void *data, size_t len);
ipc_status_t exo_recv(struct exo_proc *proc, void *buf, size_t len, size_t *out_len);

#ifdef __cplusplus
}
#endif

#endif /* MAILBOX_H */
