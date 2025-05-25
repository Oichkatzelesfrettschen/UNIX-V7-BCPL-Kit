#include <linux/init.h>
#include <linux/module.h>
#include <linux/spinlock.h>
#include <linux/interrupt.h>

#define QUEUE_SIZE 4
static spinlock_t test_lock;
static int queue[QUEUE_SIZE];
static int head, tail;
static struct tasklet_struct test_tasklet;

static void irq_handler(unsigned long data)
{
    unsigned long flags;
    spin_lock_irqsave(&test_lock, flags);
    if ((tail + 1) % QUEUE_SIZE == head) {
        pr_info("IRQ queue overflow occurred\n");
    } else {
        queue[tail] = (int)data;
        tail = (tail + 1) % QUEUE_SIZE;
    }
    spin_unlock_irqrestore(&test_lock, flags);
}

static int __init irq_spin_test_init(void)
{
    spin_lock_init(&test_lock);
    head = tail = 0;
    tasklet_init(&test_tasklet, irq_handler, 1);
    tasklet_schedule(&test_tasklet);
    tasklet_schedule(&test_tasklet); /* trigger overflow */
    for (int i = 0; i < 1000; ++i) {
        spin_lock(&test_lock);
        spin_unlock(&test_lock);
    }
    pr_info("irq_spin_test loaded\n");
    return 0;
}

static void __exit irq_spin_test_exit(void)
{
    tasklet_kill(&test_tasklet);
    pr_info("irq_spin_test unloaded\n");
}

module_init(irq_spin_test_init);
module_exit(irq_spin_test_exit);
MODULE_LICENSE("GPL");
