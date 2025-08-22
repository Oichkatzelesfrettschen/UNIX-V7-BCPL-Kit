#include "mailbox.h"

ipc_status_t exo_send(struct exo_proc *proc, const void *data, size_t len) {
  return mailbox_enqueue(&proc->mbox, data, len);
}

ipc_status_t exo_recv(struct exo_proc *proc, void *buf, size_t len, size_t *out_len) {
  return mailbox_dequeue(&proc->mbox, buf, len, out_len);
}


