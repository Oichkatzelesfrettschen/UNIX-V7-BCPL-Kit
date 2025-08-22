#include "mailbox.h"
#include <stdlib.h>
#include <string.h>

void mailbox_init(struct mailbox *mb) {
  mb->head = mb->tail = NULL;
  mb->lock.locked = 0;
}

ipc_status_t mailbox_enqueue(struct mailbox *mb, const void *data, size_t len) {
  struct mailbox_msg *m = malloc(sizeof(*m) + len);
  if (!m)
    return IPC_STATUS_ERROR;
  m->next = NULL;
  m->len = len;
  memcpy(m->data, data, len);

  spin_lock(&mb->lock);
  if (!mb->tail) {
    mb->head = mb->tail = m;
  } else {
    mb->tail->next = m;
    mb->tail = m;
  }
  spin_unlock(&mb->lock);
  return IPC_STATUS_SUCCESS;
}

ipc_status_t mailbox_dequeue(struct mailbox *mb, void *buf, size_t len, size_t *out_len) {
  spin_lock(&mb->lock);
  struct mailbox_msg *m = mb->head;
  if (!m) {
    spin_unlock(&mb->lock);
    return IPC_STATUS_EMPTY;
  }
  mb->head = m->next;
  if (!mb->head)
    mb->tail = NULL;
  spin_unlock(&mb->lock);

  size_t copy_len = len < m->len ? len : m->len;
  memcpy(buf, m->data, copy_len);
  if (out_len)
    *out_len = copy_len;
  free(m);
  return IPC_STATUS_SUCCESS;
}

