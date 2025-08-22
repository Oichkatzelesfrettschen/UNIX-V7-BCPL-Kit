#ifndef IPC_STATUS_H
#define IPC_STATUS_H

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    IPC_STATUS_SUCCESS = 0,
    IPC_STATUS_EMPTY = 1,
    IPC_STATUS_ERROR = -1
} ipc_status_t;

#ifdef __cplusplus
}
#endif

#endif /* IPC_STATUS_H */

