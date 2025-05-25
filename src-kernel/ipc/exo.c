#include "mailbox.h"

int exo_send(struct exo_proc *proc, const void *data, size_t len)
{
    return mailbox_enqueue(&proc->mbox, data, len);
}

ssize_t exo_recv(struct exo_proc *proc, void *buf, size_t len)
{
    return mailbox_dequeue(&proc->mbox, buf, len);
}
