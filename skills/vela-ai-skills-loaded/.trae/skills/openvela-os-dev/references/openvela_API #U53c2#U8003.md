# API 参考

> 来源: openvela官方
> 共 66 篇文档

---

## API 参考文档

> 路径: API 参考文档
> 来源: [https://doc.openvela.com/document?id=1104&language=cn&version=dev](https://doc.openvela.com/document?id=1104&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/index.md>) | 简体中文 ]

# API 参考文档

本文档提供 openvela 操作系统的 API 参考，涵盖从内核系统调用到应用框架的完整接口说明。

openvela 基于 Apache NuttX RTOS 构建，遵循 POSIX 标准，支持 ARM、ARM64、RISC-V、x86_64 等多种架构。开发者可通过以下章节查阅各层级的 API 接口：

  * **[内核接口](</document?id=1106&version=dev&language=cn>)** — 进程/线程管理、任务调度、内存管理、信号机制、消息队列等 POSIX 兼容的系统接口
  * **[网络接口](</document?id=1113&version=dev&language=cn>)** — BSD 套接字、DNS 解析等标准网络编程接口
  * **[应用框架](</document?id=1120&version=dev&language=cn>)** — Binder IPC、蓝牙、多媒体、安全（TEE + Keystore）、uORB 消息总线等上层能力接口

---

## 内核接口总览

> 路径: 内核接口 > 内核接口总览
> 来源: [https://doc.openvela.com/document?id=1106&language=cn&version=dev](https://doc.openvela.com/document?id=1106&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/kernel/index.md>) | 简体中文 ]

# 内核接口

openvela 内核基于 Apache NuttX RTOS，提供符合 POSIX 标准的系统接口，涵盖进程/线程管理、任务调度、内存管理、信号机制、消息队列等核心功能。本章节详细介绍各内核子系统的 API 接口及使用说明。

  * **[线程管理](</document?id=1107&version=dev&language=cn>)** — POSIX Thread (pthread) 接口
  * **[任务调度](</document?id=1108&version=dev&language=cn>)** — 调度策略、优先级、任务属性
  * **[内存管理](</document?id=1109&version=dev&language=cn>)** — 堆内存分配、内存池、内存信息查询
  * **[信号机制](</document?id=1110&version=dev&language=cn>)** — POSIX 信号、信号处理、信号集
  * **[消息队列](</document?id=1111&version=dev&language=cn>)** — POSIX 消息队列

---

## 线程 API

> 路径: 内核接口 > 线程 API
> 来源: [https://doc.openvela.com/document?id=1107&language=cn&version=dev](https://doc.openvela.com/document?id=1107&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/kernel/thread.md>) | 简体中文 ]

# 线程 API

openvela 提供 POSIX 兼容的线程（pthread）接口，支持线程创建、同步、属性管理等功能。

头文件：#include <pthread.h>

# openvela 实现说明

openvela 的 pthread 实现基于 NuttX RTOS 内核，与标准 Linux 实现存在以下差异：

  * **pthread_t 即 pid_t**：在 openvela 中，线程 ID 的底层类型是 pid_t（进程 ID），可以直接用于 kill() 等系统调用。
  * **无进程隔离** ：openvela 不支持 Linux 意义上的进程，所有线程运行在同一地址空间。PTHREAD_PROCESS_SHARED 属性可设置但行为与 PTHREAD_PROCESS_PRIVATE 相同。
  * **竞争范围固定** ：仅支持 PTHREAD_SCOPE_SYSTEM，PTHREAD_SCOPE_PROCESS 返回 ENOTSUP。
  * **fork() 支持有限**：pthread_atfork() 接口存在但 fork() 在 RTOS 环境中可能不可用，主要用于 POSIX 兼容性。
  * **条件编译依赖** ：部分功能需要特定配置项：
  * CONFIG_SMP：CPU 亲和性接口（pthread_setaffinity_np 等）
  * CONFIG_PRIORITY_INHERITANCE：优先级继承协议（PTHREAD_PRIO_INHERIT）
  * CONFIG_PRIORITY_PROTECT：优先级上限保护（PTHREAD_PRIO_PROTECT、prioceiling 相关接口）
  * CONFIG_RR_INTERVAL > 0：SCHED_RR 调度策略
  * CONFIG_SCHED_SPORADIC：SCHED_SPORADIC 调度策略


# 线程创建与管理

## pthread_create
    
    
    int pthread_create(pthread_t *thread, const pthread_attr_t *attr,
                       pthread_startroutine_t start_routine, pthread_addr_t arg);

> **类型说明** ：pthread_startroutine_t 等价于 void *(*)(void *)，pthread_addr_t 等价于 void *，均为 NuttX 的类型别名。

创建一个新线程并使其可运行。新线程从 start_routine 函数开始执行，该函数接收 arg 作为唯一参数。线程属性对象 attr 指定了新线程的各种属性，如栈大小、调度策略、优先级等。

如果 attr 为 NULL，则使用默认属性创建线程。默认情况下，线程是可连接的（joinable），具有默认的栈大小和调度策略。

**参数** ：

  * thread 指向 pthread_t 类型的指针，用于存储新创建线程的 ID。成功时，线程 ID 会被写入此位置。
  * attr 指向线程属性对象的指针。如果为 NULL，使用默认属性（栈大小为 PTHREAD_STACK_DEFAULT，调度策略为 SCHED_OTHER，可连接状态）。
  * start_routine 线程入口函数，函数签名为 void *(*)(void *)。新线程将从此函数开始执行。
  * arg 传递给入口函数的参数。如果需要传递多个参数，可以传递结构体指针。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EAGAIN 系统资源不足，无法创建新线程，或达到了系统线程数限制。
  * EINVAL attr 中的设置无效。
  * EPERM 没有权限设置指定的调度策略或参数。


**注意** ：

  * 新创建的线程与调用线程共享相同的地址空间、文件描述符和信号处理。
  * 如果线程创建时指定了 PTHREAD_CREATE_DETACHED 状态，线程终止后会自动释放资源，无需调用 pthread_join()。
  * 线程创建后立即可调度运行，不保证创建顺序就是执行顺序。
  * 线程的返回值可以通过 pthread_join() 获取，或通过 pthread_exit() 显式返回。
  * 确保传递给线程的参数在线程执行期间保持有效，避免传递栈上的局部变量地址。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_exit
    
    
    void pthread_exit(void *exit_value);

终止调用线程并返回一个值，该值可被其他调用 pthread_join() 等待此线程的线程获取。此函数不会返回到调用者。

调用 pthread_exit() 等效于从线程入口函数返回，但可以在线程调用的任何函数中调用。线程终止时，会执行以下清理操作：

  1. 调用通过 pthread_cleanup_push() 注册的清理函数（按注册顺序的逆序）。
  2. 调用线程特定数据的析构函数（对于所有非 NULL 的线程特定数据键）。
  3. 如果线程是可连接的，保留线程 ID 和返回值，直到其他线程调用 pthread_join()。
  4. 如果线程是分离的，立即释放所有资源。


**参数** ：

  * exit_value 线程返回值，这是一个无类型指针，可以传递任何数据的地址。等待此线程的 pthread_join() 调用可以获取此值。如果线程被取消，返回值为 PTHREAD_CANCELED。


**返回值** ：

此函数不返回。调用后，调用线程终止。

**注意** ：

  * 不要在 main() 函数中调用 pthread_exit()，这会终止主线程但不终止进程，可能导致其他线程成为孤儿。
  * 如果线程已分离，exit_value 将被忽略，因为没有线程可以通过 pthread_join() 获取返回值。
  * 线程终止时，不会自动关闭打开的文件描述符或释放分配的内存，这些资源由整个进程共享。
  * 从线程入口函数返回隐式调用 pthread_exit()，返回值作为线程的退出值。
  * 如果线程持有互斥锁，在调用 pthread_exit() 前应释放，否则可能导致死锁。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_join
    
    
    int pthread_join(pthread_t thread, pthread_addr_t *value);

> **类型说明** ：pthread_addr_t 等价于 void *，为 NuttX 的类型别名。

阻塞调用线程，直到指定的线程 thread 终止。如果该线程已经终止，pthread_join() 立即返回。成功返回后，目标线程被"连接"（joined），其资源被回收。

每个可连接的线程只能被连接一次。尝试连接已被连接或分离的线程会导致未定义行为。线程不能连接自己，否则会导致死锁。

**参数** ：

  * thread 要等待的线程 ID，必须是可连接状态的线程。不能是分离状态的线程，也不能是已被连接过的线程。
  * value 指向指针的指针，用于接收线程的返回值。如果非 NULL，目标线程的返回值（通过 pthread_exit() 或从入口函数返回）会被写入 *value。如果线程被取消，*value 设置为 PTHREAD_CANCELED。如果不关心返回值，可以传递 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EDEADLK 检测到死锁（如线程尝试连接自己），或 thread 指定另一个正在等待连接调用线程的线程。
  * EINVAL thread 不是可连接的线程，或者已有其他线程正在等待连接该线程。
  * ESRCH 找不到 ID 为 thread 的线程。


**注意** ：

  * pthread_join() 会阻塞调用线程，直到目标线程终止。如果目标线程已经终止，调用立即返回。
  * 连接线程后，线程 ID 被回收，不应再使用。
  * 如果多个线程同时尝试连接同一个线程，行为是未定义的。
  * 不连接可连接的线程会导致资源泄漏（类似于内存泄漏），线程资源不会被回收。
  * 对于不需要获取返回值的线程，建议在创建时设置为分离状态，或创建后调用 pthread_detach()。
  * 在 openvela 中，线程 ID 实际上是进程 ID（pid_t），可以用于其他系统调用。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_detach
    
    
    int pthread_detach(pthread_t thread);

将指定线程标记为分离状态。分离状态的线程在终止时会自动释放所有资源，无需其他线程调用 pthread_join() 来回收。一旦线程被分离，就不能再被连接，线程的返回值也无法获取。

线程可以通过两种方式变为分离状态：  
1\. 创建时在属性对象中设置 PTHREAD_CREATE_DETACHED。  
2\. 创建后调用 pthread_detach()。

线程也可以分离自己，通过 pthread_detach(pthread_self())。

**参数** ：

  * thread 要分离的线程 ID。可以是其他线程的 ID，也可以是调用线程自己的 ID（通过 pthread_self() 获取）。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL thread 不是可连接的线程（可能已经是分离状态）。
  * ESRCH 找不到 ID 为 thread 的线程。


**注意** ：

  * 分离线程后，不能再调用 pthread_join() 等待该线程，否则会返回错误。
  * 分离状态是不可逆的，一旦分离就无法再变回可连接状态。
  * 对于不需要获取返回值或等待其完成的线程，应该设置为分离状态，以避免资源泄漏。
  * 分离状态不影响线程的执行，只影响线程终止后的资源回收方式。
  * 如果对已分离的线程再次调用 pthread_detach()，会返回 EINVAL 错误。
  * 主线程可以是分离的，但这通常不是好的做法，因为主线程终止会导致整个进程终止。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_cancel
    
    
    int pthread_cancel(pthread_t thread);

向指定线程发送取消请求。线程是否响应取消请求取决于其取消状态（由 pthread_setcancelstate() 设置）和取消类型（由 pthread_setcanceltype() 设置）。

如果取消请求成功传递，目标线程的取消状态和类型决定了何时以及如何处理取消：

  * 如果取消状态为 PTHREAD_CANCEL_DISABLE，取消请求被挂起，直到取消状态变为 PTHREAD_CANCEL_ENABLE。
  * 如果取消状态为 PTHREAD_CANCEL_ENABLE，且取消类型为 PTHREAD_CANCEL_DEFERRED，取消在下一个取消点发生。
  * 如果取消类型为 PTHREAD_CANCEL_ASYNCHRONOUS，取消可能立即发生（但也可能延迟）。


**参数** ：

  * thread 要取消的线程 ID。不能取消自己（应使用 pthread_exit()）。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * ESRCH 找不到 ID 为 thread 的线程。


**注意** ：

  * pthread_cancel() 只是发送取消请求，不会等待线程实际终止。
  * 被取消的线程的退出值为 PTHREAD_CANCELED。
  * 异步取消（PTHREAD_CANCEL_ASYNCHRONOUS）是危险的，应仅在特定情况下使用，因为线程可能在任意点被取消，可能导致资源泄漏或数据不一致。
  * 延迟取消（PTHREAD_CANCEL_DEFERRED，默认）更安全，线程只在取消点被取消，这些点包括 pthread_testcancel()、pthread_join()、pthread_cond_wait() 等阻塞调用。
  * 取消线程时，会执行清理处理程序（通过 pthread_cleanup_push() 注册）和线程特定数据析构函数。
  * 如果线程持有锁或其他资源，应通过清理处理程序确保资源被正确释放。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_setcancelstate
    
    
    int pthread_setcancelstate(int state, int *oldstate);

设置调用线程的取消状态。取消状态决定了线程是否可以被取消。

**参数** ：

  * state 新的取消状态。有效值为：
  * PTHREAD_CANCEL_ENABLE 启用取消（默认）。线程可以响应取消请求。
  * PTHREAD_CANCEL_DISABLE 禁用取消。取消请求会被挂起，直到取消状态变为启用。
  * oldstate 如果非 NULL，用于存储之前的取消状态。可以传递 NULL 如果不需要获取旧值。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL state 不是有效的取消状态值。


**注意** ：

  * 新创建的线程默认取消状态为 PTHREAD_CANCEL_ENABLE。
  * 禁用取消不会丢弃挂起的取消请求，只是延迟其处理。
  * 即使禁用取消，线程仍可以通过 pthread_exit() 自行终止。
  * 在执行关键代码段（如资源分配和初始化）时，应临时禁用取消，完成后再启用。
  * 取消状态是线程局部的，每个线程有自己独立的取消状态。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_setcanceltype
    
    
    int pthread_setcanceltype(int type, int *oldtype);

设置调用线程的取消类型。取消类型决定了线程如何响应取消请求。

**参数** ：

  * type 新的取消类型。有效值为：
  * PTHREAD_CANCEL_DEFERRED 延迟取消（默认）。取消请求在下一个取消点才会处理。取消点包括 pthread_testcancel()、pthread_join()、pthread_cond_wait()、pthread_cond_timedwait()、sem_wait() 等阻塞函数。
  * PTHREAD_CANCEL_ASYNCHRONOUS 异步取消。线程可以在任何时刻被取消（实际行为依赖于实现）。这种模式非常危险，应避免使用。
  * oldtype 如果非 NULL，用于存储之前的取消类型。可以传递 NULL 如果不需要获取旧值。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL type 不是有效的取消类型值。


**注意** ：

  * 新创建的线程默认取消类型为 PTHREAD_CANCEL_DEFERRED。
  * 延迟取消是推荐的取消类型，因为它只在定义明确的取消点响应取消，确保线程处于已知状态。
  * 异步取消可能在任意指令处中断线程，可能导致资源泄漏、数据损坏或未定义行为。只有确保线程代码是异步取消安全的，才应使用异步取消。
  * 如果使用异步取消，线程不应调用非异步取消安全的函数，包括大多数库函数。
  * 取消类型是线程局部的，每个线程有自己独立的取消类型。
  * 即使设置了异步取消，实现也可能将其视为延迟取消。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_testcancel
    
    
    void pthread_testcancel(void);

创建一个取消点。如果有挂起的取消请求且取消状态为启用，则线程将被取消并不返回。这是一种显式检查并响应取消请求的方式。

取消点是线程可以响应取消请求的位置。POSIX 定义了一些函数必须是取消点（如 pthread_join()、sem_wait() 等阻塞调用），而 pthread_testcancel() 允许在任意位置创建取消点。

**参数** ：

无参数。

**返回值** ：

如果没有挂起的取消请求，函数正常返回。如果有挂起的取消请求，函数不返回，线程被取消。

**注意** ：

  * 如果线程取消状态为 PTHREAD_CANCEL_DISABLE，pthread_testcancel() 不起作用，直接返回。
  * 此函数通常用于长时间运行的计算密集型代码中，以提供响应取消请求的机会。
  * 应在适当的位置（如循环中）定期调用 pthread_testcancel()，以确保线程能够及时响应取消请求。
  * 如果线程被取消，会执行清理处理程序和线程特定数据析构函数。
  * 过于频繁地调用 pthread_testcancel() 可能影响性能；应在逻辑上合理的位置调用。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_self
    
    
    pthread_t pthread_self(void);

获取调用线程的线程 ID。线程 ID 在进程内唯一标识一个线程，可用于 pthread_join()、pthread_detach()、pthread_equal() 等函数。

在 openvela 中，pthread_t 实际上是 pid_t 类型，即线程 ID 与进程 ID 相同。

**参数** ：

无参数。

**返回值** ：

返回调用线程的线程 ID。此函数总是成功，不会失败。

**注意** ：

  * 线程 ID 在线程生命周期内保持不变。
  * 线程 ID 在线程终止并被连接后可能被重用。
  * 不要依赖线程 ID 的数值或顺序，它们是不透明的标识符。
  * 可以用 pthread_self() 获取的 ID 调用 pthread_detach(pthread_self()) 来分离当前线程。
  * 在 openvela 中，可以将线程 ID 用于系统调用，如信号发送等。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_equal
    
    
    int pthread_equal(pthread_t t1, pthread_t t2);

比较两个线程 ID 是否相等。由于线程 ID 的内部表示可能是复杂的数据结构，POSIX 要求使用此函数而不是直接用 == 比较。

**参数** ：

  * t1 第一个线程 ID。
  * t2 第二个线程 ID。


**返回值** ：

如果两个线程 ID 相等，返回非零值；否则返回 0。

**注意** ：

  * 在 openvela 中，pthread_t 是简单的整数类型（pid_t），可以直接用 == 比较，但为了可移植性，建议使用 pthread_equal()。
  * 终止的线程 ID 可能被重用，因此不应假设 ID 的唯一性跨越线程生命周期。
  * 常用于判断某个线程 ID 是否是当前线程：pthread_equal(thread_id, pthread_self())。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_yield
    
    
    void pthread_yield(void);

主动让出处理器，允许其他线程运行。这是一个优化提示，实际行为取决于调度策略。

调用 pthread_yield() 后，调用线程被放置在其优先级队列的末尾，调度器选择下一个可运行的线程。如果没有其他同等或更高优先级的就绪线程，调用线程可能立即继续执行。

**参数** ：

无参数。

**返回值** ：

无返回值。

**注意** ：

  * 此函数是非标准的扩展接口，但在许多系统上可用（Linux、BSD 等）。
  * 在 POSIX 标准中，应使用 sched_yield() 替代。
  * 适用于协作式多任务场景，线程主动让出 CPU 给其他线程。
  * 不应依赖 pthread_yield() 来解决同步问题，应使用适当的同步原语（如互斥锁、条件变量）。
  * 过度使用 pthread_yield() 可能导致性能下降，应仅在明确需要时使用。
  * 在实时系统中，pthread_yield() 的行为取决于调度策略（FIFO、RR 等）。


**POSIX 兼容性** ：兼容扩展接口（非 POSIX 标准，但广泛支持）。

## pthread_once
    
    
    int pthread_once(pthread_once_t *once_control, void (*init_routine)(void));

确保初始化函数 init_routine 在进程生命周期内只被调用一次，无论有多少线程调用 pthread_once()。这是一种线程安全的单次初始化机制，常用于全局资源的延迟初始化。

once_control 必须是静态或全局变量，并使用 PTHREAD_ONCE_INIT 初始化。多个线程可以同时调用 pthread_once()，但 init_routine 只会被执行一次，其他线程会阻塞等待直到初始化完成。

**参数** ：

  * once_control 控制变量，用于跟踪初始化状态。必须使用 PTHREAD_ONCE_INIT 初始化（如 pthread_once_t once = PTHREAD_ONCE_INIT;）。
  * init_routine 初始化函数，无参数无返回值。此函数在整个进程生命周期内只会被调用一次。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL once_control 或 init_routine 为 NULL。


**注意** ：

  * pthread_once() 是线程安全的，可以从多个线程同时调用。
  * 初始化函数应快速完成，避免阻塞其他等待初始化完成的线程。
  * 如果初始化函数内部调用 pthread_once() 使用相同的 once_control，行为是未定义的（可能死锁）。
  * 初始化函数不应调用 pthread_exit() 或被取消，否则初始化被视为未完成，下次调用 pthread_once() 会再次执行初始化。
  * 常用于单例模式、全局资源初始化等场景。
  * once_control 变量不应被直接修改，只能通过 pthread_once() 操作。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_atfork
    
    
    int pthread_atfork(void (*prepare)(void), void (*parent)(void), void (*child)(void));

注册在 fork() 调用时执行的处理函数。这些函数用于处理多线程环境中 fork() 带来的问题，特别是锁状态的一致性。

当调用 fork() 时，处理函数按以下顺序执行：  
1\. 在 fork() 之前，在父进程中调用所有 prepare 函数（按注册顺序的逆序）。  
2\. fork() 创建子进程。  
3\. 在子进程中调用所有 child 函数（按注册顺序）。  
4\. 在父进程中调用所有 parent 函数（按注册顺序）。

**参数** ：

  * prepare 在 fork() 前在父进程中调用。通常用于获取所有锁，确保一致状态。可以为 NULL。
  * parent 在 fork() 后在父进程中调用。通常用于释放 prepare 中获取的锁。可以为 NULL。
  * child 在 fork() 后在子进程中调用。通常用于重新初始化锁状态和其他资源。可以为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * ENOMEM 内存不足，无法分配记录处理函数所需的空间。


**注意** ：

  * 可以多次调用 pthread_atfork() 注册多组处理函数。
  * prepare 函数按注册顺序的逆序调用，parent 和 child 函数按注册顺序调用。
  * 在多线程程序中使用 fork() 是危险的，因为子进程只继承调用 fork() 的线程，其他线程在子进程中不存在，但它们持有的锁状态被继承，可能导致死锁。
  * pthread_atfork() 处理函数应快速执行，避免调用可能阻塞或使用锁的复杂函数。
  * 在子进程中，只应调用异步信号安全的函数（如 exec() 系列函数）。
  * openvela 作为 RTOS，fork() 支持可能有限或不存在，此接口主要用于兼容性。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

# 线程属性

## pthread_attr_init
    
    
    int pthread_attr_init(pthread_attr_t *attr);

初始化线程属性对象为默认值。属性对象用于在创建线程时指定线程的各种属性，如栈大小、调度策略、优先级、分离状态等。

初始化后的属性对象包含以下默认值：  
\- 分离状态：PTHREAD_CREATE_JOINABLE（可连接）  
\- 栈大小：PTHREAD_STACK_DEFAULT（系统默认）  
\- 调度策略：SCHED_OTHER（或系统默认策略）  
\- 调度继承：PTHREAD_INHERIT_SCHED（继承父线程）  
\- 作用域：PTHREAD_SCOPE_SYSTEM

**参数** ：

  * attr 指向要初始化的线程属性对象。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * ENOMEM 内存不足，无法初始化属性对象。


**注意** ：

  * 属性对象初始化后，可以通过各种 pthread_attr_set*() 函数修改具体属性。
  * 同一个属性对象可以用于创建多个线程。
  * 使用完毕后，应调用 pthread_attr_destroy() 销毁属性对象，释放资源。
  * 属性对象的修改不影响已创建的线程，只影响后续使用该属性对象创建的线程。
  * 在 openvela 中，属性对象是简单的结构体，不涉及动态内存分配。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_attr_destroy
    
    
    int pthread_attr_destroy(pthread_attr_t *attr);

销毁线程属性对象，释放其占用的资源。销毁后的属性对象不能再使用，除非重新初始化。

**参数** ：

  * attr 指向要销毁的属性对象。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 不是有效的属性对象。


**注意** ：

  * 销毁属性对象不影响已使用该对象创建的线程。
  * 销毁后的属性对象可以通过 pthread_attr_init() 重新初始化并使用。
  * 在 openvela 中，属性对象通常不涉及动态内存，此函数主要用于 POSIX 兼容性。
  * 应始终配对调用 pthread_attr_init() 和 pthread_attr_destroy()，遵循资源管理的最佳实践。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_attr_setdetachstate
    
    
    int pthread_attr_setdetachstate(pthread_attr_t *attr, int detachstate);

设置线程属性对象中的分离状态。分离状态决定线程终止后资源的回收方式。

**参数** ：

  * attr 指向线程属性对象。不能为 NULL。
  * detachstate 分离状态，有效值为：
  * PTHREAD_CREATE_JOINABLE 可连接（默认），需要其他线程调用 pthread_join() 回收资源。
  * PTHREAD_CREATE_DETACHED 分离状态，线程终止后自动释放资源。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 为 NULL，或 detachstate 不是有效值。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_attr_getdetachstate
    
    
    int pthread_attr_getdetachstate(const pthread_attr_t *attr, int *detachstate);

获取线程属性对象中的分离状态。

**参数** ：

  * attr 指向线程属性对象。不能为 NULL。
  * detachstate 指向整型变量，用于存储分离状态。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 或 detachstate 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_attr_setstacksize
    
    
    int pthread_attr_setstacksize(pthread_attr_t *attr, size_t stacksize);

设置线程属性对象中的栈大小。

**参数** ：

  * attr 指向线程属性对象。不能为 NULL。
  * stacksize 栈大小（字节）。不能小于 PTHREAD_STACK_MIN。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 为 NULL，或 stacksize 小于 PTHREAD_STACK_MIN。


**注意** ：

  * 栈大小应根据线程的实际需求设置，过小可能导致栈溢出。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_attr_getstacksize
    
    
    int pthread_attr_getstacksize(const pthread_attr_t *attr, size_t *stacksize);

获取线程属性对象中的栈大小。

**参数** ：

  * attr 指向线程属性对象。
  * stacksize 指向 size_t 变量，用于存储栈大小。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL stacksize 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_attr_setstackaddr
    
    
    int pthread_attr_setstackaddr(pthread_attr_t *attr, void *stackaddr);

设置线程属性对象中的栈地址。允许应用程序为线程指定预分配的栈内存。

**参数** ：

  * attr 指向线程属性对象。不能为 NULL。
  * stackaddr 栈内存的起始地址。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 或 stackaddr 为 NULL。


**注意** ：

  * 此接口已被 POSIX 标记为废弃（obsolete），建议使用 pthread_attr_setstack() 替代，后者可同时设置栈地址和栈大小。
  * 使用自定义栈时，应用程序负责栈内存的分配和释放。
  * 栈内存必须在线程生命周期内保持有效。


**POSIX 兼容性** ：兼容 POSIX 同名接口（已废弃）。

## pthread_attr_getstackaddr
    
    
    int pthread_attr_getstackaddr(const pthread_attr_t *attr, void **stackaddr);

获取线程属性对象中的栈地址。

**参数** ：

  * attr 指向线程属性对象。不能为 NULL。
  * stackaddr 指向指针变量，用于存储栈地址。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 或 stackaddr 为 NULL。


**注意** ：

  * 此接口已被 POSIX 标记为废弃，建议使用 pthread_attr_getstack() 替代。


**POSIX 兼容性** ：兼容 POSIX 同名接口（已废弃）。

## pthread_attr_setstack
    
    
    int pthread_attr_setstack(pthread_attr_t *attr, void *stackaddr, size_t stacksize);

同时设置线程属性对象中的栈地址和栈大小。这是 pthread_attr_setstackaddr() 和 pthread_attr_setstacksize() 的组合替代接口。

**参数** ：

  * attr 指向线程属性对象。不能为 NULL。
  * stackaddr 栈内存的起始地址。不能为 NULL。
  * stacksize 栈大小（字节）。不能小于 PTHREAD_STACK_MIN。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 或 stackaddr 为 NULL，或 stacksize 小于 PTHREAD_STACK_MIN。


**注意** ：

  * 使用自定义栈时，应用程序负责栈内存的分配和释放，且内存必须在线程生命周期内有效。
  * 栈大小应考虑线程的实际需求，包括局部变量、函数调用深度等。
  * 在 openvela 中，PTHREAD_STACK_MIN 的值取决于系统配置。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_attr_getstack
    
    
    int pthread_attr_getstack(const pthread_attr_t *attr, void **stackaddr, size_t *stacksize);

同时获取线程属性对象中的栈地址和栈大小。

**参数** ：

  * attr 指向线程属性对象。不能为 NULL。
  * stackaddr 指向指针变量，用于存储栈地址。不能为 NULL。
  * stacksize 指向 size_t 变量，用于存储栈大小。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr、stackaddr 或 stacksize 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_attr_setguardsize
    
    
    int pthread_attr_setguardsize(pthread_attr_t *attr, size_t guardsize);

设置线程属性对象中的栈保护区大小。保护区是栈末尾的一段不可访问内存，用于检测栈溢出。

**参数** ：

  * attr 指向线程属性对象。不能为 NULL。
  * guardsize 保护区大小（字节）。设置为 0 表示禁用栈保护。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 为 NULL。


**注意** ：

  * 如果使用 pthread_attr_setstack() 指定了自定义栈，保护区设置可能被忽略。
  * 实际保护区大小可能被系统向上取整到页大小的整数倍。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_attr_getguardsize
    
    
    int pthread_attr_getguardsize(const pthread_attr_t *attr, size_t *guardsize);

获取线程属性对象中的栈保护区大小。

**参数** ：

  * attr 指向线程属性对象。
  * guardsize 指向 size_t 变量，用于存储保护区大小。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL guardsize 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_attr_setschedpolicy
    
    
    int pthread_attr_setschedpolicy(pthread_attr_t *attr, int policy);

设置线程属性对象中的调度策略。

**参数** ：

  * attr 指向线程属性对象。不能为 NULL。
  * policy 调度策略，有效值为：
  * SCHED_OTHER 默认调度策略。
  * SCHED_FIFO 先进先出实时调度。
  * SCHED_RR 时间片轮转实时调度（需 CONFIG_RR_INTERVAL > 0）。
  * SCHED_SPORADIC 偶发调度（需 CONFIG_SCHED_SPORADIC）。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 为 NULL，或 policy 不是有效的调度策略。


**注意** ：

  * SCHED_RR 和 SCHED_SPORADIC 的可用性取决于系统配置。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_attr_getschedpolicy
    
    
    int pthread_attr_getschedpolicy(const pthread_attr_t *attr, int *policy);

获取线程属性对象中的调度策略。

**参数** ：

  * attr 指向线程属性对象。不能为 NULL。
  * policy 指向整型变量，用于存储调度策略。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 或 policy 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_attr_setschedparam
    
    
    int pthread_attr_setschedparam(pthread_attr_t *attr, const struct sched_param *param);

设置线程属性对象中的调度参数。

**参数** ：

  * attr 指向线程属性对象。不能为 NULL。
  * param 指向调度参数结构体。不能为 NULL。主要字段：
  * sched_priority 线程优先级。
  * sched_ss_low_priority 偶发调度低优先级（需 CONFIG_SCHED_SPORADIC）。
  * sched_ss_repl_period 偶发调度补充周期。
  * sched_ss_init_budget 偶发调度初始预算。
  * sched_ss_max_repl 偶发调度最大补充次数。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 或 param 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_attr_getschedparam
    
    
    int pthread_attr_getschedparam(const pthread_attr_t *attr, struct sched_param *param);

获取线程属性对象中的调度参数。

**参数** ：

  * attr 指向线程属性对象。不能为 NULL。
  * param 指向调度参数结构体，用于存储结果。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 或 param 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_attr_setinheritsched
    
    
    int pthread_attr_setinheritsched(pthread_attr_t *attr, int inheritsched);

设置线程属性对象中的调度继承方式。决定新线程是继承创建者的调度属性，还是使用属性对象中显式指定的值。

**参数** ：

  * attr 指向线程属性对象。不能为 NULL。
  * inheritsched 继承方式，有效值为：
  * PTHREAD_INHERIT_SCHED 继承创建线程的调度策略和参数（默认）。
  * PTHREAD_EXPLICIT_SCHED 使用属性对象中设置的调度策略和参数。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 为 NULL，或 inheritsched 不是有效值。


**注意** ：

  * 如果设置为 PTHREAD_EXPLICIT_SCHED，需要同时通过 pthread_attr_setschedpolicy() 和 pthread_attr_setschedparam() 设置调度策略和参数。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_attr_getinheritsched
    
    
    int pthread_attr_getinheritsched(const pthread_attr_t *attr, int *inheritsched);

获取线程属性对象中的调度继承方式。

**参数** ：

  * attr 指向线程属性对象。不能为 NULL。
  * inheritsched 指向整型变量，用于存储继承方式。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 或 inheritsched 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_attr_setscope
    
    
    int pthread_attr_setscope(pthread_attr_t *attr, int scope);

设置线程属性对象中的竞争范围。竞争范围定义了线程与哪些线程竞争 CPU 等资源。

**参数** ：

  * attr 指向线程属性对象。
  * scope 竞争范围，有效值为：
  * PTHREAD_SCOPE_SYSTEM 系统级竞争，线程与系统中所有线程竞争资源。
  * PTHREAD_SCOPE_PROCESS 进程级竞争，线程仅与同一进程内的线程竞争。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL scope 不是有效值。
  * ENOTSUP 不支持请求的竞争范围。在 openvela 中，PTHREAD_SCOPE_PROCESS 不受支持。


**注意** ：

  * openvela 仅支持 PTHREAD_SCOPE_SYSTEM，这也是默认值。传入 PTHREAD_SCOPE_PROCESS 会返回 ENOTSUP。
  * 在 RTOS 环境中，所有线程天然在系统级别竞争资源。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_attr_getscope
    
    
    int pthread_attr_getscope(const pthread_attr_t *attr, int *scope);

获取线程属性对象中的竞争范围。

**参数** ：

  * attr 指向线程属性对象。
  * scope 指向整型变量，用于存储竞争范围。


**返回值** ：

成功时返回 0。

**注意** ：

  * 在 openvela 中，始终返回 PTHREAD_SCOPE_SYSTEM。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_attr_setaffinity_np
    
    
    int pthread_attr_setaffinity_np(pthread_attr_t *attr, size_t cpusetsize, const cpu_set_t *cpuset);

设置线程属性对象中的 CPU 亲和性掩码。使用该属性创建的线程将被限制在指定的 CPU 集合上运行。

**参数** ：

  * attr 指向线程属性对象。不能为 NULL。
  * cpusetsize cpuset 缓冲区的大小（字节），必须为 sizeof(cpu_set_t)。
  * cpuset 指向 CPU 集合，指定线程可运行的 CPU。不能为 NULL，且集合不能为空。


**返回值** ：

成功时返回 0。

**注意** ：

  * 仅在启用 SMP（CONFIG_SMP）时可用。
  * 与 pthread_setaffinity_np() 不同，此函数设置的是属性对象中的亲和性，在 pthread_create() 时生效。
  * 使用 CPU_ZERO()、CPU_SET() 等宏操作 cpu_set_t。


**POSIX 兼容性** ：兼容 Linux 扩展接口（非 POSIX 标准）。

## pthread_attr_getaffinity_np
    
    
    int pthread_attr_getaffinity_np(const pthread_attr_t *attr, size_t cpusetsize, cpu_set_t *cpuset);

获取线程属性对象中的 CPU 亲和性掩码。

**参数** ：

  * attr 指向线程属性对象。不能为 NULL。
  * cpusetsize cpuset 缓冲区的大小（字节），必须为 sizeof(cpu_set_t)。
  * cpuset 指向 CPU 集合，用于存储亲和性掩码。不能为 NULL。


**返回值** ：

成功时返回 0。

**注意** ：

  * 仅在启用 SMP（CONFIG_SMP）时可用。


**POSIX 兼容性** ：兼容 Linux 扩展接口（非 POSIX 标准）。

# 线程调度

## pthread_getschedparam
    
    
    int pthread_getschedparam(pthread_t thread, int *policy, struct sched_param *param);

获取指定线程的调度策略和调度参数。

**参数** ：

  * thread 线程 ID。
  * policy 指向整型变量，用于存储调度策略。不能为 NULL。
  * param 指向调度参数结构体，用于存储结果。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL policy 或 param 为 NULL。
  * ESRCH 找不到指定线程。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_setschedparam
    
    
    int pthread_setschedparam(pthread_t thread, int policy, const struct sched_param *param);

设置指定线程的调度策略和调度参数。

**参数** ：

  * thread 线程 ID。
  * policy 调度策略：SCHED_FIFO、SCHED_RR、SCHED_OTHER 或 SCHED_SPORADIC。
  * param 指向调度参数结构体。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL 参数无效。
  * ESRCH 找不到指定线程。
  * EPERM 没有权限修改调度参数。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_setschedprio
    
    
    int pthread_setschedprio(pthread_t thread, int prio);

设置指定线程的优先级，不改变调度策略。

**参数** ：

  * thread 线程 ID。
  * prio 新的优先级值。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL 优先级值无效。
  * ESRCH 找不到指定线程。


**注意** ：

  * 此函数仅修改优先级，保留当前调度策略和其他调度参数（如偶发调度参数）不变。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_setaffinity_np
    
    
    int pthread_setaffinity_np(pthread_t thread, size_t cpusetsize, const cpu_set_t *cpuset);

设置线程的 CPU 亲和性掩码。如果线程当前未运行在 cpuset 指定的 CPU 上，将被迁移到其中一个 CPU。

**参数** ：

  * thread 线程 ID。
  * cpusetsize cpuset 缓冲区的大小（字节），通常为 sizeof(cpu_set_t)。
  * cpuset 指向 CPU 集合，指定线程可以运行的 CPU。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL 参数无效。
  * ESRCH 找不到指定线程。


**注意** ：

  * 仅在启用 SMP（CONFIG_SMP）时可用。
  * 使用 CPU_ZERO()、CPU_SET() 等宏操作 cpu_set_t。


**POSIX 兼容性** ：兼容 Linux 扩展接口（非 POSIX 标准）。

## pthread_getaffinity_np
    
    
    int pthread_getaffinity_np(pthread_t thread, size_t cpusetsize, cpu_set_t *cpuset);

获取线程的 CPU 亲和性掩码。

**参数** ：

  * thread 线程 ID。
  * cpusetsize cpuset 缓冲区的大小（字节），通常为 sizeof(cpu_set_t)。
  * cpuset 指向 CPU 集合，用于存储线程的亲和性掩码。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL 参数无效。
  * ESRCH 找不到指定线程。


**注意** ：

  * 仅在启用 SMP（CONFIG_SMP）时可用。


**POSIX 兼容性** ：兼容 Linux 扩展接口（非 POSIX 标准）。

## pthread_setconcurrency
    
    
    int pthread_setconcurrency(int new_level);

设置并发级别提示。此函数向系统提示应用程序期望的并发线程数，系统可以据此优化线程调度。

**参数** ：

  * new_level 期望的并发级别。值为 0 表示由系统自行决定。不能为负数。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL new_level 为负数。


**注意** ：

  * 此函数仅为提示，系统不保证实际并发级别与设置值一致。
  * 在 openvela 中，此值存储在全局变量中，不影响实际调度行为。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_getconcurrency
    
    
    int pthread_getconcurrency(void);

获取当前的并发级别提示值。

**参数** ：

无参数。

**返回值** ：

返回之前通过 pthread_setconcurrency() 设置的值。如果从未设置，返回 0。

**POSIX 兼容性** ：兼容 POSIX 同名接口。

# 互斥锁

## pthread_mutex_init
    
    
    int pthread_mutex_init(pthread_mutex_t *mutex, const pthread_mutexattr_t *attr);

初始化互斥锁。互斥锁用于保护共享资源，确保同一时刻只有一个线程可以访问被保护的临界区。

如果 attr 为 NULL，使用默认属性：类型为 PTHREAD_MUTEX_NORMAL，不支持优先级继承或保护协议，进程私有。

互斥锁也可以使用 PTHREAD_MUTEX_INITIALIZER 静态初始化：  

    
    
    pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

**参数** ：

  * mutex 指向要初始化的互斥锁对象。
  * attr 指向互斥锁属性对象。如果为 NULL，使用默认属性。属性包括互斥锁类型（normal、recursive、errorcheck）、优先级协议、健壮性等。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EAGAIN 系统资源不足，无法初始化互斥锁。
  * ENOMEM 内存不足。
  * EPERM 调用者没有权限。
  * EINVAL attr 中的属性值无效。


**注意** ：

  * 初始化后的互斥锁处于未锁定状态。
  * 不要重复初始化已初始化的互斥锁，这会导致未定义行为。
  * 使用完毕后应调用 pthread_mutex_destroy() 销毁互斥锁。
  * 静态初始化的互斥锁不需要显式销毁。
  * 互斥锁类型影响重复加锁和错误检测行为：
  * PTHREAD_MUTEX_NORMAL：不检测死锁，重复加锁会导致死锁。
  * PTHREAD_MUTEX_ERRORCHECK：检测死锁和错误，性能略低。
  * PTHREAD_MUTEX_RECURSIVE：允许同一线程多次加锁，需要相同次数的解锁。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_mutex_destroy
    
    
    int pthread_mutex_destroy(pthread_mutex_t *mutex);

销毁互斥锁，释放其占用的资源。

**参数** ：

  * mutex 指向要销毁的互斥锁。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL mutex 为 NULL 或未正确初始化。
  * EBUSY 互斥锁当前被锁定，无法销毁。


**注意** ：

  * 不能销毁正在被使用（锁定）的互斥锁。
  * 销毁后的互斥锁不能再使用，除非重新初始化。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_mutex_lock
    
    
    int pthread_mutex_lock(pthread_mutex_t *mutex);

锁定互斥锁。如果互斥锁当前未被锁定，调用线程获得锁并立即返回。如果互斥锁已被其他线程锁定，调用线程阻塞等待，直到锁可用。

具体行为取决于互斥锁类型：  
\- **NORMAL（默认）** ：如果锁已被当前线程持有，再次加锁会导致死锁。  
\- **ERRORCHECK** ：如果锁已被当前线程持有，返回 EDEADLK 错误。  
\- **RECURSIVE** ：如果锁已被当前线程持有，递增锁计数，需要相同次数的解锁。

**参数** ：

  * mutex 指向要锁定的互斥锁。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EDEADLK 互斥锁类型为 PTHREAD_MUTEX_ERRORCHECK，且当前线程已持有该锁（死锁检测）。
  * EINVAL 互斥锁未正确初始化。
  * EOWNERDEAD 互斥锁是健壮互斥锁，前一个持有者终止时未释放锁。调用者现在拥有该锁，应调用 pthread_mutex_consistent() 使其一致，或解锁并不再使用。
  * ENOTRECOVERABLE 健壮互斥锁处于不可恢复状态，无法再使用。


**注意** ：

  * 持有锁的线程应尽快释放锁，避免其他线程长时间等待。
  * 避免在持有锁时调用可能阻塞的函数（如 I/O 操作），这可能导致性能问题。
  * 避免嵌套锁定多个互斥锁，这可能导致死锁。如果必须，应保持固定的加锁顺序。
  * 锁定互斥锁后，应使用 try-finally 模式或清理处理程序确保锁始终被释放。
  * 如果线程被取消，应通过清理处理程序（pthread_cleanup_push/pop）确保锁被释放。
  * 优先级反转问题：如果启用优先级继承协议，低优先级线程持有锁时，其优先级临时提升到等待线程的最高优先级。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_mutex_trylock
    
    
    int pthread_mutex_trylock(pthread_mutex_t *mutex);

尝试锁定互斥锁（非阻塞）。如果互斥锁当前可用，函数获得锁并立即返回成功。如果互斥锁已被锁定，函数立即返回 EBUSY，不会阻塞等待。

这是 pthread_mutex_lock() 的非阻塞版本，适用于不希望等待锁的场景，如轮询、避免死锁等。

**参数** ：

  * mutex 指向要尝试锁定的互斥锁。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EBUSY 互斥锁已被锁定，无法获取。这不是真正的错误，只是表示锁当前不可用。
  * EINVAL 互斥锁未正确初始化。
  * EDEADLK 互斥锁类型为 PTHREAD_MUTEX_ERRORCHECK，且当前线程已持有该锁。
  * EOWNERDEAD 健壮互斥锁的前一个持有者终止时未释放锁。
  * ENOTRECOVERABLE 健壮互斥锁处于不可恢复状态。


**注意** ：

  * 如果返回 EBUSY，调用者可以选择稍后重试或执行其他操作。
  * 对于递归互斥锁，如果当前线程已持有锁，pthread_mutex_trylock() 会成功并递增锁计数。
  * 常用于避免死锁的场景：尝试获取多个锁时，如果无法获取某个锁，可以释放已持有的锁并重试。
  * 不应在循环中持续调用 pthread_mutex_trylock()（忙等待），这会浪费 CPU 资源。
  * 适用于实现非阻塞算法或超时机制。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_mutex_timedlock
    
    
    int pthread_mutex_timedlock(pthread_mutex_t *mutex, const struct timespec *abstime);

带超时的锁定互斥锁。如果互斥锁不能立即获取，阻塞等待直到锁可用或超时。

**参数** ：

  * mutex 指向要锁定的互斥锁。不能为 NULL。
  * abstime 绝对超时时间（基于 CLOCK_REALTIME）。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * ETIMEDOUT 在超时时间内未能获取锁。
  * EINVAL mutex 为 NULL 或未正确初始化。
  * EDEADLK 互斥锁类型为 PTHREAD_MUTEX_ERRORCHECK，且当前线程已持有该锁。


**注意** ：

  * 对于递归互斥锁，如果当前线程已持有锁，会成功并递增锁计数，不受超时影响。
  * 超时时间是绝对时间，不是相对时间。应基于 clock_gettime(CLOCK_REALTIME, ...) 计算。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_mutex_unlock
    
    
    int pthread_mutex_unlock(pthread_mutex_t *mutex);

解锁互斥锁，使其可供其他等待的线程获取。只有持有锁的线程才能解锁，否则行为取决于互斥锁类型。

对于递归互斥锁，每次 pthread_mutex_unlock() 调用递减锁计数，当计数降到零时锁才真正被释放。

**参数** ：

  * mutex 指向要解锁的互斥锁。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EPERM 当前线程不拥有该互斥锁。对于 PTHREAD_MUTEX_ERRORCHECK 类型，尝试解锁未持有的锁会返回此错误。对于 PTHREAD_MUTEX_NORMAL 类型，这是未定义行为。
  * EINVAL 互斥锁未正确初始化或已被销毁。


**注意** ：

  * 必须由锁定互斥锁的同一线程解锁，不能由其他线程代为解锁。
  * 解锁未锁定的互斥锁是未定义行为（对于 NORMAL 类型）或返回错误（对于 ERRORCHECK 类型）。
  * 解锁互斥锁后，如果有线程正在等待该锁，其中一个等待线程会被唤醒并获得锁。具体哪个线程被唤醒取决于调度策略。
  * 在持有锁期间发生异常或取消时，应确保锁被释放，通过清理处理程序或异常处理机制。
  * 解锁操作应尽可能快，避免在锁保护的临界区外调用 unlock。
  * 对于优先级继承互斥锁，解锁时会恢复线程的原始优先级。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_mutex_consistent
    
    
    int pthread_mutex_consistent(pthread_mutex_t *mutex);

将健壮互斥锁标记为一致状态。当健壮互斥锁的前一个持有者终止时未释放锁，pthread_mutex_lock() 会返回 EOWNERDEAD，此时新的持有者应调用此函数使互斥锁恢复一致。

**参数** ：

  * mutex 指向处于不一致状态的健壮互斥锁。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL mutex 为 NULL，或互斥锁不是健壮互斥锁，或不处于不一致状态。


**注意** ：

  * 需要互斥锁属性中设置了 PTHREAD_MUTEX_ROBUST。
  * 如果不调用此函数而直接解锁，互斥锁将进入不可恢复状态，后续 pthread_mutex_lock() 会返回 ENOTRECOVERABLE。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_mutex_setprioceiling
    
    
    int pthread_mutex_setprioceiling(pthread_mutex_t *mutex, int prioceiling, int *old_ceiling);

动态修改互斥锁的优先级上限。此函数会先锁定互斥锁，修改优先级上限后再解锁，确保操作的原子性。

**参数** ：

  * mutex 指向互斥锁。
  * prioceiling 新的优先级上限值。
  * old_ceiling 如果非 NULL，用于存储之前的优先级上限值。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL 参数无效，或未启用 CONFIG_PRIORITY_PROTECT。
  * EPERM 无法锁定互斥锁。


**注意** ：

  * 需要启用 CONFIG_PRIORITY_PROTECT 配置项。未启用时始终返回 EINVAL。
  * 互斥锁的协议必须为 PTHREAD_PRIO_PROTECT 才有意义。
  * 此函数内部会执行 lock/unlock 操作，调用时不应持有该互斥锁。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_mutex_getprioceiling
    
    
    int pthread_mutex_getprioceiling(const pthread_mutex_t *mutex, int *prioceiling);

获取互斥锁当前的优先级上限。

**参数** ：

  * mutex 指向互斥锁。
  * prioceiling 指向整型变量，用于存储优先级上限值。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL 参数无效，或未启用 CONFIG_PRIORITY_PROTECT。


**注意** ：

  * 需要启用 CONFIG_PRIORITY_PROTECT 配置项。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

# 互斥锁属性

## pthread_mutexattr_init
    
    
    int pthread_mutexattr_init(pthread_mutexattr_t *attr);

初始化互斥锁属性对象为默认值。默认属性：类型 PTHREAD_MUTEX_NORMAL，协议 PTHREAD_PRIO_NONE，进程私有，非健壮。

**参数** ：

  * attr 指向要初始化的互斥锁属性对象。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_mutexattr_destroy
    
    
    int pthread_mutexattr_destroy(pthread_mutexattr_t *attr);

销毁互斥锁属性对象。

**参数** ：

  * attr 指向要销毁的互斥锁属性对象。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_mutexattr_settype
    
    
    int pthread_mutexattr_settype(pthread_mutexattr_t *attr, int type);

设置互斥锁类型。类型决定了重复加锁和错误检测的行为。

**参数** ：

  * attr 指向互斥锁属性对象。不能为 NULL。
  * type 互斥锁类型：
  * PTHREAD_MUTEX_NORMAL 不检测死锁，重复加锁导致死锁（默认）。
  * PTHREAD_MUTEX_ERRORCHECK 检测死锁，重复加锁返回 EDEADLK。
  * PTHREAD_MUTEX_RECURSIVE 允许同一线程多次加锁，需相同次数解锁。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 为 NULL，或 type 不是有效值。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_mutexattr_gettype
    
    
    int pthread_mutexattr_gettype(const pthread_mutexattr_t *attr, int *type);

获取互斥锁类型。

**参数** ：

  * attr 指向互斥锁属性对象。不能为 NULL。
  * type 指向整型变量，用于存储互斥锁类型。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 或 type 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_mutexattr_setpshared
    
    
    int pthread_mutexattr_setpshared(pthread_mutexattr_t *attr, int pshared);

设置互斥锁属性对象中的进程共享属性。

**参数** ：

  * attr 指向互斥锁属性对象。不能为 NULL。
  * pshared 进程共享属性值：
  * PTHREAD_PROCESS_PRIVATE（0）进程私有（默认）。
  * PTHREAD_PROCESS_SHARED（1）进程间共享。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 为 NULL，或 pshared 不是 0 或 1。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_mutexattr_getpshared
    
    
    int pthread_mutexattr_getpshared(const pthread_mutexattr_t *attr, int *pshared);

获取互斥锁属性对象中的进程共享属性。

**参数** ：

  * attr 指向互斥锁属性对象。不能为 NULL。
  * pshared 指向整型变量，用于存储进程共享属性值。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 或 pshared 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_mutexattr_setprotocol
    
    
    int pthread_mutexattr_setprotocol(pthread_mutexattr_t *attr, int protocol);

设置互斥锁优先级协议。协议决定了持有锁的线程如何处理优先级反转问题。

**参数** ：

  * attr 指向互斥锁属性对象。不能为 NULL。
  * protocol 优先级协议：
  * PTHREAD_PRIO_NONE 不使用优先级协议（默认）。
  * PTHREAD_PRIO_INHERIT 优先级继承，持有锁的低优先级线程临时提升到等待线程的最高优先级（需 CONFIG_PRIORITY_INHERITANCE）。
  * PTHREAD_PRIO_PROTECT 优先级上限保护（需 CONFIG_PRIORITY_PROTECT）。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 为 NULL，或 protocol 不是有效值或不受支持。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_mutexattr_getprotocol
    
    
    int pthread_mutexattr_getprotocol(const pthread_mutexattr_t *attr, int *protocol);

获取互斥锁优先级协议。

**参数** ：

  * attr 指向互斥锁属性对象。不能为 NULL。
  * protocol 指向整型变量，用于存储协议值。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 或 protocol 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_mutexattr_setrobust
    
    
    int pthread_mutexattr_setrobust(pthread_mutexattr_t *attr, int robust);

设置互斥锁健壮性属性。健壮互斥锁在持有者异常终止时不会永久锁死。

**参数** ：

  * attr 指向互斥锁属性对象。不能为 NULL。
  * robust 健壮性属性：
  * PTHREAD_MUTEX_STALLED 非健壮（默认），持有者终止后锁永久不可用。
  * PTHREAD_MUTEX_ROBUST 健壮，持有者终止后下一个加锁者收到 EOWNERDEAD，可通过 pthread_mutex_consistent() 恢复。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 为 NULL，或 robust 不是有效值。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_mutexattr_getrobust
    
    
    int pthread_mutexattr_getrobust(const pthread_mutexattr_t *attr, int *robust);

获取互斥锁健壮性属性。

**参数** ：

  * attr 指向互斥锁属性对象。不能为 NULL。
  * robust 指向整型变量，用于存储健壮性属性。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 或 robust 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_mutexattr_setprioceiling
    
    
    int pthread_mutexattr_setprioceiling(pthread_mutexattr_t *attr, int prioceiling);

设置互斥锁属性对象中的优先级上限。当互斥锁协议为 PTHREAD_PRIO_PROTECT 时，持有锁的线程优先级会被提升到此上限值，以避免优先级反转。

**参数** ：

  * attr 指向互斥锁属性对象。不能为 NULL。
  * prioceiling 优先级上限值，必须在 sched_get_priority_min(SCHED_FIFO) 和 sched_get_priority_max(SCHED_FIFO) 之间。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 为 NULL，或 prioceiling 超出有效优先级范围。


**注意** ：

  * 需要启用 CONFIG_PRIORITY_PROTECT 配置项。未启用时，此函数始终返回 EINVAL。
  * 应与 pthread_mutexattr_setprotocol(attr, PTHREAD_PRIO_PROTECT) 配合使用。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_mutexattr_getprioceiling
    
    
    int pthread_mutexattr_getprioceiling(const pthread_mutexattr_t *attr, int *prioceiling);

获取互斥锁属性对象中的优先级上限。

**参数** ：

  * attr 指向互斥锁属性对象。不能为 NULL。
  * prioceiling 指向整型变量，用于存储优先级上限值。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 或 prioceiling 为 NULL，或未启用 CONFIG_PRIORITY_PROTECT。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

# 条件变量

## pthread_cond_init
    
    
    int pthread_cond_init(pthread_cond_t *cond, const pthread_condattr_t *attr);

初始化条件变量。也可使用 PTHREAD_COND_INITIALIZER 静态初始化。

**参数** ：

  * cond 指向要初始化的条件变量。不能为 NULL。
  * attr 条件变量属性。如果为 NULL，使用默认属性（CLOCK_REALTIME，进程私有）。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL cond 为 NULL。
  * ENOMEM 内存不足。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_cond_destroy
    
    
    int pthread_cond_destroy(pthread_cond_t *cond);

销毁条件变量。

**参数** ：

  * cond 指向要销毁的条件变量。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL cond 为 NULL 或未正确初始化。
  * EBUSY 有线程正在等待该条件变量。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_cond_wait
    
    
    int pthread_cond_wait(pthread_cond_t *cond, pthread_mutex_t *mutex);

等待条件变量被通知。此函数原子性地释放互斥锁并阻塞在条件变量上。当条件变量被 pthread_cond_signal() 或 pthread_cond_broadcast() 通知时，线程被唤醒，重新获取互斥锁，然后返回。

条件变量通常用于实现生产者-消费者模式或其他需要线程间协调的场景。典型用法：  

    
    
    pthread_mutex_lock(&mutex);
    while (!condition) {
        pthread_cond_wait(&cond, &mutex);
    }
    // 条件满足，处理数据
    pthread_mutex_unlock(&mutex);

**参数** ：

  * cond 指向条件变量。
  * mutex 指向关联的互斥锁。调用前必须已被当前线程锁定。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL cond 或 mutex 未正确初始化，或使用了不同的互斥锁。
  * EPERM 调用线程未持有互斥锁。


**注意** ：

  * 调用前必须持有关联的互斥锁，否则行为未定义。
  * 函数返回时，互斥锁已重新被锁定，即使发生错误。
  * 由于虚假唤醒的可能性，必须在循环中检查条件：while (!condition) pthread_cond_wait(...)。虚假唤醒是指线程在没有信号通知的情况下被唤醒。
  * 条件变量本身不保存状态，它只是一个同步原语。实际条件（布尔表达式）由应用程序维护，通常通过共享变量表示。
  * 等待时互斥锁被原子性地释放，避免了释放锁和阻塞之间的竞态条件。
  * 如果线程被取消，互斥锁会被重新锁定，然后清理处理程序被调用。应在清理处理程序中释放锁。
  * 多个线程可以同时等待同一个条件变量。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_cond_timedwait
    
    
    int pthread_cond_timedwait(pthread_cond_t *cond, pthread_mutex_t *mutex,
                               const struct timespec *abstime);

带超时的等待条件变量。行为与 pthread_cond_wait() 相同，但在超时后自动返回。

**参数** ：

  * cond 指向条件变量。
  * mutex 指向关联的互斥锁，调用前必须已锁定。
  * abstime 绝对超时时间。时钟源取决于条件变量属性中的时钟设置（默认 CLOCK_REALTIME）。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * ETIMEDOUT 在超时时间内未收到通知。
  * EINVAL 参数无效。


**注意** ：

  * 即使超时返回，互斥锁也会被重新锁定。
  * 仍需在循环中检查条件，因为可能存在虚假唤醒。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_cond_clockwait
    
    
    int pthread_cond_clockwait(pthread_cond_t *cond, pthread_mutex_t *mutex,
                               clockid_t clockid, const struct timespec *abstime);

使用指定时钟等待条件变量。允许在等待时直接指定时钟源，而不依赖属性对象中的设置。

**参数** ：

  * cond 指向条件变量。
  * mutex 指向关联的互斥锁，调用前必须已锁定。
  * clockid 时钟 ID，如 CLOCK_REALTIME 或 CLOCK_MONOTONIC。
  * abstime 基于指定时钟的绝对超时时间。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * ETIMEDOUT 在超时时间内未收到通知。
  * EINVAL 参数无效。


**POSIX 兼容性** ：兼容扩展接口。

## pthread_cond_signal
    
    
    int pthread_cond_signal(pthread_cond_t *cond);

唤醒至少一个正在等待条件变量的线程。如果有多个线程在等待，调度策略决定哪个线程被唤醒。如果没有线程在等待，此调用不起作用（信号丢失）。

与 pthread_cond_broadcast() 不同，pthread_cond_signal() 只唤醒一个线程，适用于只有一个线程能够处理条件的场景，可以避免不必要的线程唤醒和上下文切换。

**参数** ：

  * cond 指向要通知的条件变量。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL cond 未正确初始化。


**注意** ：

  * 调用 pthread_cond_signal() 时不需要持有关联的互斥锁，但通常建议在持有锁时调用，以避免竞态条件。
  * 被唤醒的线程不会立即执行，它会先尝试重新获取互斥锁。因此在调用 signal 后立即释放锁是一个好的做法。
  * 如果在修改条件后不持有锁就调用 signal，可能导致"唤醒丢失"问题：等待线程可能在检查条件和调用 wait 之间被抢占。
  * 典型模式：  

        
        pthread_mutex_lock(&mutex);
        // 修改共享状态，使条件成立
        condition = true;
        pthread_cond_signal(&cond);
        pthread_mutex_unlock(&mutex);

  * 如果条件可能满足多个等待线程的需求，应使用 pthread_cond_broadcast()。
  * POSIX 不保证信号的公平性，可能出现线程饥饿。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_cond_broadcast
    
    
    int pthread_cond_broadcast(pthread_cond_t *cond);

唤醒所有正在等待条件变量的线程。所有等待线程被唤醒后，会竞争重新获取关联的互斥锁。如果没有线程在等待，此调用不起作用。

与 pthread_cond_signal() 不同，broadcast 唤醒所有等待线程，适用于条件变化可能影响多个线程的场景，或者不确定哪个线程应该被唤醒时。

**参数** ：

  * cond 指向要广播的条件变量。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL cond 未正确初始化。


**注意** ：

  * 类似 pthread_cond_signal()，调用时通常应持有关联的互斥锁。
  * 所有被唤醒的线程会串行竞争互斥锁，一次只有一个线程能获得锁并继续执行。
  * 使用 broadcast 可能导致"惊群效应"（thundering herd）：多个线程被唤醒但只有少数能真正处理条件，其他线程发现条件不满足后又回到等待状态，造成不必要的上下文切换。
  * 适用场景：
  * 条件变化影响所有等待线程（如资源状态变化、系统关闭信号）
  * 不确定哪个线程应该处理条件
  * 需要所有线程重新评估其等待条件
  * 典型模式：  

        
        pthread_mutex_lock(&mutex);
        // 修改影响所有等待线程的共享状态
        shutdown = true;
        pthread_cond_broadcast(&cond);
        pthread_mutex_unlock(&mutex);

  * 如果只需要唤醒一个线程，优先使用 pthread_cond_signal() 以提高效率。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

# 条件变量属性

## pthread_condattr_init
    
    
    int pthread_condattr_init(pthread_condattr_t *attr);

初始化条件变量属性对象为默认值。初始化后的属性对象包含以下默认值：

  * 进程共享属性：PTHREAD_PROCESS_PRIVATE（进程私有）
  * 时钟属性：CLOCK_REALTIME（系统实时时钟）


属性对象用于在调用 pthread_cond_init() 时指定条件变量的行为特性。同一个属性对象可以用于初始化多个条件变量。

**参数** ：

  * attr 指向要初始化的条件变量属性对象。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 为 NULL。


**注意** ：

  * 使用完毕后应调用 pthread_condattr_destroy() 销毁属性对象。
  * 属性对象的修改不影响已使用该对象创建的条件变量。
  * 如果需要使用 CLOCK_MONOTONIC 作为超时时钟（避免系统时间调整的影响），应在初始化后调用 pthread_condattr_setclock() 修改时钟属性。
  * 在 openvela 中，属性对象是简单的结构体（包含 pshared 和 clockid 两个字段），不涉及动态内存分配。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_condattr_destroy
    
    
    int pthread_condattr_destroy(pthread_condattr_t *attr);

销毁条件变量属性对象，释放其占用的资源。销毁后的属性对象不能再使用，除非重新调用 pthread_condattr_init() 初始化。

**参数** ：

  * attr 指向要销毁的条件变量属性对象。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 为 NULL 或不是有效的属性对象。


**注意** ：

  * 销毁属性对象不影响已使用该对象创建的条件变量。
  * 在 openvela 中，属性对象不涉及动态内存分配，此函数主要用于 POSIX 兼容性。
  * 应始终配对调用 pthread_condattr_init() 和 pthread_condattr_destroy()。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_condattr_getpshared
    
    
    int pthread_condattr_getpshared(const pthread_condattr_t *attr, int *pshared);

获取条件变量属性对象中的进程共享属性。进程共享属性决定了条件变量是否可以被多个进程中的线程访问。

**参数** ：

  * attr 指向条件变量属性对象。不能为 NULL。
  * pshared 指向整型变量的指针，用于存储当前的进程共享属性值。不能为 NULL。返回值为以下之一：
  * PTHREAD_PROCESS_PRIVATE 条件变量只能被同一进程内的线程使用（默认值）。
  * PTHREAD_PROCESS_SHARED 条件变量可以被多个进程中的线程使用，前提是条件变量分配在共享内存中。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 或 pshared 为 NULL。


**注意** ：

  * 在 openvela 中，由于 RTOS 的内存模型，PTHREAD_PROCESS_SHARED 的行为可能与 Linux 等系统不同。
  * 默认值为 PTHREAD_PROCESS_PRIVATE。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_condattr_setpshared
    
    
    int pthread_condattr_setpshared(pthread_condattr_t *attr, int pshared);

设置条件变量属性对象中的进程共享属性。该属性决定条件变量是否可以被不同进程中的线程操作。

如果设置为 PTHREAD_PROCESS_SHARED，任何能够访问条件变量所在内存的线程都可以操作该条件变量。如果设置为 PTHREAD_PROCESS_PRIVATE，只有与初始化条件变量的线程在同一进程内的线程才能操作。不同进程的线程尝试操作私有条件变量的行为是未定义的。

**参数** ：

  * attr 指向条件变量属性对象。不能为 NULL。
  * pshared 进程共享属性值，必须为以下之一：
  * PTHREAD_PROCESS_PRIVATE 进程私有（默认）。
  * PTHREAD_PROCESS_SHARED 进程间共享。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 为 NULL，或 pshared 不是 PTHREAD_PROCESS_SHARED 或 PTHREAD_PROCESS_PRIVATE。


**注意** ：

  * 使用 PTHREAD_PROCESS_SHARED 时，条件变量必须分配在所有相关进程都能访问的共享内存区域中。
  * 与条件变量关联的互斥锁也应设置为进程共享。
  * 修改属性对象不影响已创建的条件变量。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_condattr_getclock
    
    
    int pthread_condattr_getclock(const pthread_condattr_t *attr, clockid_t *clock_id);

获取条件变量属性对象中的时钟属性。时钟属性决定了 pthread_cond_timedwait() 使用哪个时钟来计算超时时间。

**参数** ：

  * attr 指向条件变量属性对象。不能为 NULL。
  * clock_id 指向 clockid_t 变量的指针，用于存储当前的时钟属性值。返回值为以下之一：
  * CLOCK_REALTIME 系统实时时钟（默认值）。受系统时间调整（如 NTP）影响。
  * CLOCK_MONOTONIC 单调递增时钟。不受系统时间调整影响。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 为 NULL。


**注意** ：

  * 默认时钟为 CLOCK_REALTIME。
  * 如果应用程序对超时精度有要求，或系统时间可能被调整，建议使用 CLOCK_MONOTONIC。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_condattr_setclock
    
    
    int pthread_condattr_setclock(pthread_condattr_t *attr, clockid_t clock_id);

设置条件变量属性对象中的时钟属性。该属性指定 pthread_cond_timedwait() 用于计算超时的时钟源。

选择合适的时钟对于超时行为至关重要：  
\- CLOCK_REALTIME：使用系统实时时钟，超时时间是绝对时间点。如果系统时间被向前调整，可能导致提前超时；向后调整则可能导致超时延迟。  
\- CLOCK_MONOTONIC：使用单调递增时钟，不受系统时间调整影响，适合需要精确超时控制的场景。

**参数** ：

  * attr 指向条件变量属性对象。不能为 NULL。
  * clock_id 时钟 ID，必须为以下之一：
  * CLOCK_REALTIME 系统实时时钟（默认）。
  * CLOCK_MONOTONIC 单调递增时钟。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 为 NULL，或 clock_id 不是 CLOCK_REALTIME 或 CLOCK_MONOTONIC。


**注意** ：

  * 在 openvela 中，仅支持 CLOCK_REALTIME 和 CLOCK_MONOTONIC 两种时钟，传入其他时钟 ID（如 CLOCK_PROCESS_CPUTIME_ID）会返回 EINVAL。
  * 修改时钟属性不影响已创建的条件变量，仅影响后续使用该属性对象创建的条件变量。
  * 如果使用 CLOCK_MONOTONIC，传递给 pthread_cond_timedwait() 的 abstime 应基于 clock_gettime(CLOCK_MONOTONIC, ...) 获取的时间计算。
  * 也可以使用 pthread_cond_clockwait() 在等待时直接指定时钟，而不依赖属性对象中的设置。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

# 读写锁

## pthread_rwlock_init
    
    
    int pthread_rwlock_init(pthread_rwlock_t *rwlock, const pthread_rwlockattr_t *attr);

初始化读写锁。读写锁允许多个线程同时持有读锁，但写锁是排他的。

**参数** ：

  * rwlock 指向要初始化的读写锁。不能为 NULL。
  * attr 读写锁属性。如果为 NULL，使用默认属性。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL rwlock 为 NULL。
  * ENOMEM 内存不足。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_rwlock_destroy
    
    
    int pthread_rwlock_destroy(pthread_rwlock_t *rwlock);

销毁读写锁。

**参数** ：

  * rwlock 指向要销毁的读写锁。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL rwlock 为 NULL。
  * EBUSY 读写锁当前被锁定。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_rwlock_rdlock
    
    
    int pthread_rwlock_rdlock(pthread_rwlock_t *rwlock);

获取读锁。如果当前没有写锁被持有，立即获取成功；否则阻塞等待。多个线程可同时持有读锁。

**参数** ：

  * rwlock 指向读写锁。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL rwlock 未正确初始化。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_rwlock_tryrdlock
    
    
    int pthread_rwlock_tryrdlock(pthread_rwlock_t *rwlock);

尝试获取读锁（非阻塞）。

**参数** ：

  * rwlock 指向读写锁。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EBUSY 有写锁被持有，无法获取读锁。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_rwlock_timedrdlock
    
    
    int pthread_rwlock_timedrdlock(pthread_rwlock_t *rwlock, const struct timespec *abstime);

带超时的获取读锁。如果读锁不能立即获取，阻塞等待直到锁可用或超时。超时基于 CLOCK_REALTIME。

**参数** ：

  * rwlock 指向读写锁。
  * abstime 绝对超时时间（基于 CLOCK_REALTIME）。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * ETIMEDOUT 在超时时间内未能获取读锁。
  * EBUSY 读锁不可用。
  * EINVAL 参数无效。


**注意** ：

  * 内部调用 pthread_rwlock_clockrdlock() 并使用 CLOCK_REALTIME 作为时钟源。
  * 如果需要使用 CLOCK_MONOTONIC，请使用 pthread_rwlock_clockrdlock()。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_rwlock_clockrdlock
    
    
    int pthread_rwlock_clockrdlock(pthread_rwlock_t *rwlock, clockid_t clockid,
                                   const struct timespec *abstime);

使用指定时钟带超时获取读锁。

**参数** ：

  * rwlock 指向读写锁。
  * clockid 时钟 ID，如 CLOCK_REALTIME 或 CLOCK_MONOTONIC。
  * abstime 基于指定时钟的绝对超时时间。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * ETIMEDOUT 在超时时间内未能获取读锁。
  * EINVAL 参数无效。


**POSIX 兼容性** ：兼容扩展接口。

## pthread_rwlock_wrlock
    
    
    int pthread_rwlock_wrlock(pthread_rwlock_t *rwlock);

获取写锁。写锁是排他的，必须等待所有读锁和写锁释放后才能获取。

**参数** ：

  * rwlock 指向读写锁。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL rwlock 未正确初始化。
  * EAGAIN 写者数量已达上限。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_rwlock_trywrlock
    
    
    int pthread_rwlock_trywrlock(pthread_rwlock_t *rwlock);

尝试获取写锁（非阻塞）。

**参数** ：

  * rwlock 指向读写锁。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EBUSY 有读锁或写锁被持有，无法获取写锁。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_rwlock_timedwrlock
    
    
    int pthread_rwlock_timedwrlock(pthread_rwlock_t *rwlock, const struct timespec *abstime);

带超时的获取写锁。如果写锁不能立即获取，阻塞等待直到锁可用或超时。超时基于 CLOCK_REALTIME。

**参数** ：

  * rwlock 指向读写锁。
  * abstime 绝对超时时间（基于 CLOCK_REALTIME）。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * ETIMEDOUT 在超时时间内未能获取写锁。
  * EAGAIN 写者数量已达上限。
  * EINVAL 参数无效。


**注意** ：

  * 内部调用 pthread_rwlock_clockwrlock() 并使用 CLOCK_REALTIME 作为时钟源。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_rwlock_clockwrlock
    
    
    int pthread_rwlock_clockwrlock(pthread_rwlock_t *rwlock, clockid_t clockid,
                                   const struct timespec *abstime);

使用指定时钟带超时获取写锁。

**参数** ：

  * rwlock 指向读写锁。
  * clockid 时钟 ID，如 CLOCK_REALTIME 或 CLOCK_MONOTONIC。
  * abstime 基于指定时钟的绝对超时时间。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * ETIMEDOUT 在超时时间内未能获取写锁。
  * EAGAIN 写者数量已达上限。
  * EINVAL 参数无效。


**POSIX 兼容性** ：兼容扩展接口。

## pthread_rwlock_unlock
    
    
    int pthread_rwlock_unlock(pthread_rwlock_t *rwlock);

释放读写锁（读锁或写锁）。

**参数** ：

  * rwlock 指向读写锁。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL rwlock 未正确初始化。
  * EPERM 当前线程未持有该锁。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

# 读写锁属性

## pthread_rwlockattr_init
    
    
    int pthread_rwlockattr_init(pthread_rwlockattr_t *attr);

初始化读写锁属性对象为默认值。默认进程共享属性为 PTHREAD_PROCESS_PRIVATE。

**参数** ：

  * attr 指向要初始化的读写锁属性对象。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_rwlockattr_destroy
    
    
    int pthread_rwlockattr_destroy(pthread_rwlockattr_t *attr);

销毁读写锁属性对象。

**参数** ：

  * attr 指向要销毁的读写锁属性对象。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_rwlockattr_setpshared
    
    
    int pthread_rwlockattr_setpshared(pthread_rwlockattr_t *attr, int pshared);

设置读写锁属性对象中的进程共享属性。

**参数** ：

  * attr 指向读写锁属性对象。不能为 NULL。
  * pshared 进程共享属性值：PTHREAD_PROCESS_PRIVATE 或 PTHREAD_PROCESS_SHARED。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 为 NULL，或 pshared 不是有效值。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_rwlockattr_getpshared
    
    
    int pthread_rwlockattr_getpshared(const pthread_rwlockattr_t *attr, int *pshared);

获取读写锁属性对象中的进程共享属性。

**参数** ：

  * attr 指向读写锁属性对象。不能为 NULL。
  * pshared 指向整型变量，用于存储进程共享属性值。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 或 pshared 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

# 屏障

## pthread_barrier_init
    
    
    int pthread_barrier_init(pthread_barrier_t *barrier,
                             const pthread_barrierattr_t *attr, unsigned int count);

初始化屏障。屏障用于同步多个线程，所有线程到达屏障后才能继续执行。

**参数** ：

  * barrier 指向要初始化的屏障。不能为 NULL。
  * attr 屏障属性。如果为 NULL，使用默认属性。
  * count 需要到达屏障的线程数。必须大于 0。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL barrier 为 NULL，或 count 为 0。
  * ENOMEM 内存不足。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_barrier_destroy
    
    
    int pthread_barrier_destroy(pthread_barrier_t *barrier);

销毁屏障。

**参数** ：

  * barrier 指向要销毁的屏障。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL barrier 为 NULL。
  * EBUSY 有线程正在等待该屏障。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_barrier_wait
    
    
    int pthread_barrier_wait(pthread_barrier_t *barrier);

在屏障处等待。当所有线程（数量由 pthread_barrier_init 的 count 参数指定）都调用此函数后，所有线程同时被释放继续执行。

**参数** ：

  * barrier 指向屏障。


**返回值** ：

其中一个线程返回 PTHREAD_BARRIER_SERIAL_THREAD（该线程可用于执行清理工作），其他线程返回 0。

**POSIX 兼容性** ：兼容 POSIX 同名接口。

# 屏障属性

## pthread_barrierattr_init
    
    
    int pthread_barrierattr_init(pthread_barrierattr_t *attr);

初始化屏障属性对象为默认值。默认进程共享属性为 PTHREAD_PROCESS_PRIVATE。

**参数** ：

  * attr 指向要初始化的屏障属性对象。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_barrierattr_destroy
    
    
    int pthread_barrierattr_destroy(pthread_barrierattr_t *attr);

销毁屏障属性对象。

**参数** ：

  * attr 指向要销毁的屏障属性对象。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_barrierattr_setpshared
    
    
    int pthread_barrierattr_setpshared(pthread_barrierattr_t *attr, int pshared);

设置屏障属性对象中的进程共享属性。

**参数** ：

  * attr 指向屏障属性对象。不能为 NULL。
  * pshared 进程共享属性值：PTHREAD_PROCESS_PRIVATE 或 PTHREAD_PROCESS_SHARED。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 为 NULL，或 pshared 不是有效值。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_barrierattr_getpshared
    
    
    int pthread_barrierattr_getpshared(const pthread_barrierattr_t *attr, int *pshared);

获取屏障属性对象中的进程共享属性。

**参数** ：

  * attr 指向屏障属性对象。不能为 NULL。
  * pshared 指向整型变量，用于存储进程共享属性值。不能为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL attr 或 pshared 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

# 自旋锁

## pthread_spin_init
    
    
    int pthread_spin_init(pthread_spinlock_t *lock, int pshared);

初始化自旋锁。自旋锁使用忙等待方式获取锁，适用于锁持有时间极短的场景。

**参数** ：

  * lock 指向要初始化的自旋锁。不能为 NULL。
  * pshared 共享属性：PTHREAD_PROCESS_PRIVATE 或 PTHREAD_PROCESS_SHARED。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL lock 为 NULL。


**注意** ：

  * 自旋锁不应在持有时间较长的场景使用，会浪费 CPU 资源。
  * 持有自旋锁时不应调用可能阻塞的函数。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_spin_destroy
    
    
    int pthread_spin_destroy(pthread_spinlock_t *lock);

销毁自旋锁。

**参数** ：

  * lock 指向要销毁的自旋锁。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL lock 未正确初始化。
  * EBUSY 自旋锁当前被锁定。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_spin_lock
    
    
    int pthread_spin_lock(pthread_spinlock_t *lock);

获取自旋锁。如果锁已被持有，调用线程忙等待直到锁可用。

**参数** ：

  * lock 指向自旋锁。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL lock 未正确初始化。
  * EDEADLK 当前线程已持有该锁（实现相关）。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_spin_trylock
    
    
    int pthread_spin_trylock(pthread_spinlock_t *lock);

尝试获取自旋锁（非阻塞）。

**参数** ：

  * lock 指向自旋锁。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EBUSY 自旋锁已被锁定。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_spin_unlock
    
    
    int pthread_spin_unlock(pthread_spinlock_t *lock);

释放自旋锁。

**参数** ：

  * lock 指向自旋锁。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL lock 未正确初始化。
  * EPERM 当前线程未持有该锁。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

# 线程特定数据

## pthread_key_create
    
    
    int pthread_key_create(pthread_key_t *key, void (*destructor)(void *));

创建线程特定数据键。每个线程可以通过该键存储和获取自己的私有数据。

**参数** ：

  * key 指向 pthread_key_t 变量，用于存储创建的键。不能为 NULL。
  * destructor 析构函数，线程退出时对非 NULL 的数据自动调用。可以为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EAGAIN 已达系统键数量上限（PTHREAD_KEYS_MAX）。
  * ENOMEM 内存不足。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_key_delete
    
    
    int pthread_key_delete(pthread_key_t key);

删除线程特定数据键。不会调用析构函数，也不会释放各线程关联的数据。

**参数** ：

  * key 要删除的键。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL key 无效。


**注意** ：

  * 删除键后，各线程应自行释放关联的数据，否则会导致内存泄漏。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_setspecific
    
    
    int pthread_setspecific(pthread_key_t key, const void *value);

设置调用线程的线程特定数据。

**参数** ：

  * key 数据键，必须是通过 pthread_key_create() 创建的有效键。
  * value 要存储的值。可以为 NULL。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * EINVAL key 无效。
  * ENOMEM 内存不足。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_getspecific
    
    
    void *pthread_getspecific(pthread_key_t key);

获取调用线程的线程特定数据。

**参数** ：

  * key 数据键。


**返回值** ：

返回与键关联的值。如果键无效或未设置过值，返回 NULL。

**注意** ：

  * 此函数不返回错误码，无法区分"未设置"和"设置为 NULL"两种情况。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

# 线程清理

## pthread_cleanup_push
    
    
    void pthread_cleanup_push(void (*routine)(void *), void *arg);

注册线程清理函数。清理函数在线程被取消、调用 pthread_exit() 或调用 pthread_cleanup_pop(1) 时执行。

**参数** ：

  * routine 清理函数。不能为 NULL。
  * arg 传递给清理函数的参数。


**返回值** ：

无返回值。

**注意** ：

  * 必须与 pthread_cleanup_pop() 配对使用，且在同一函数作用域内。
  * 清理函数按注册顺序的逆序执行（后注册先执行）。
  * 常用于确保互斥锁在线程取消时被释放。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## pthread_cleanup_pop
    
    
    void pthread_cleanup_pop(int execute);

移除最近注册的清理函数，并可选择执行它。

**参数** ：

  * execute 如果非零，移除并执行清理函数；如果为零，仅移除不执行。


**返回值** ：

无返回值。

**注意** ：

  * 必须与 pthread_cleanup_push() 配对使用。
  * 即使 execute 为 0，清理函数也会从栈中移除。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

# 扩展接口

## pthread_setname_np
    
    
    int pthread_setname_np(pthread_t thread, const char *name);

设置线程名称。线程名称用于调试和日志，可通过 ps 命令或调试器查看。

**参数** ：

  * thread 线程 ID。
  * name 线程名称字符串。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * ESRCH 找不到指定线程。
  * EINVAL name 为 NULL。


**POSIX 兼容性** ：兼容 Linux 扩展接口。

## pthread_getname_np
    
    
    int pthread_getname_np(pthread_t thread, char *name, size_t len);

获取线程名称。

**参数** ：

  * thread 线程 ID。
  * name 用于存储名称的缓冲区。
  * len 缓冲区大小。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * ESRCH 找不到指定线程。
  * EINVAL name 为 NULL。


**POSIX 兼容性** ：兼容 Linux 扩展接口。

## pthread_gettid_np
    
    
    pid_t pthread_gettid_np(pthread_t thread);

获取线程的内核线程 ID（pid_t）。

**参数** ：

  * thread 线程 ID。


**返回值** ：

返回内核线程 ID。

**注意** ：

  * 在 openvela 中，pthread_t 本身就是 pid_t，因此此函数直接返回输入值。


**POSIX 兼容性** ：兼容扩展接口。

## pthread_getcpuclockid
    
    
    int pthread_getcpuclockid(pthread_t thread, clockid_t *clockid);

获取线程的 CPU 时钟 ID。该时钟测量指定线程消耗的 CPU 时间。

**参数** ：

  * thread 线程 ID。
  * clockid 指向 clockid_t 变量，用于存储时钟 ID。


**返回值** ：

成功时返回 0，失败时返回错误码：

  * ESRCH 找不到指定线程。
  * EINVAL clockid 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

---

## 调度管理 API

> 路径: 内核接口 > 调度管理 API
> 来源: [https://doc.openvela.com/document?id=1108&language=cn&version=dev](https://doc.openvela.com/document?id=1108&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/kernel/sched.md>) | 简体中文 ]

# 调度管理 API

openvela 提供符合 POSIX 标准的任务调度接口，支持多种调度策略和任务管理功能。

头文件：#include <sched.h>

# openvela 实现说明

  * **调度策略** ：支持 SCHED_FIFO（先进先出）、SCHED_RR（轮转，需 CONFIG_RR_INTERVAL > 0）、SCHED_SPORADIC（零星，需 CONFIG_SCHED_SPORADIC）和 SCHED_OTHER（映射到 SCHED_FIFO）。
  * **优先级范围** ：通常 1~255，数值越大优先级越高。优先级 0 保留给 idle 任务。
  * **返回值风格** ：task__系列返回负的错误码（如 -EINVAL），sched__ 系列遵循 POSIX 标准返回 -1 并设置 errno。
  * **SMP 支持** ：CPU 亲和性接口需要启用 CONFIG_SMP。
  * **task vs pthread** ：task_create() 创建 openvela 原生任务，pthread_create() 创建 POSIX 线程。两者底层共享调度器，但 task 不支持 pthread 特有功能（如 TSD、cleanup handler）。


# 任务管理

## task_create
    
    
    int task_create(const char *name, int priority, int stack_size,
                    main_t entry, char * const argv[]);

创建一个新任务并使其就绪。新任务从 entry 函数开始执行，可以接收参数数组 argv。任务创建后立即处于就绪状态，根据优先级和调度策略决定何时运行。

与 pthread_create() 不同，task_create() 是 openvela 特有的轻量级任务创建接口，创建的任务不是 POSIX 线程，而是 openvela 原生任务。任务栈由系统自动分配和管理。

**参数** ：

  * name 任务名称（字符串），用于调试和识别。最大长度由 CONFIG_TASK_NAME_SIZE 配置决定。名称可以为 NULL，但建议提供有意义的名称以便调试。
  * priority 任务优先级（整数）。有效范围取决于调度策略：
  * 实时优先级：通常 1-255（可通过 sched_get_priority_min/max() 查询）
  * 数值越大，优先级越高
  * 优先级 0 通常保留给 idle 任务
  * 建议使用 SCHED_PRIORITY_DEFAULT 或根据系统需求设置
  * stack_size 任务栈大小（字节）。必须足够容纳局部变量、函数调用和中断处理。推荐至少 2048 字节，复杂任务可能需要更大栈。栈大小会自动对齐到系统要求的边界。
  * entry 任务入口函数，类型为 main_t，签名为 int (*)(int argc, char *argv[])。函数返回时任务终止，返回值作为任务退出状态。
  * argv 传递给任务的参数数组（字符串指针数组），必须以 NULL 结尾。类似于 main() 函数的 argv。参数字符串会被复制，原字符串可以在调用后释放。如果不需要参数，可以传递 NULL 或空数组 {NULL}。


**返回值** ：

  * 成功：返回新任务的 PID（进程 ID，正整数）。可用于后续的任务控制操作（如 task_delete()、sched_setparam() 等）。
  * 失败：返回负的错误码：
  * -EINVAL：参数无效（如优先级超出范围、栈大小为 0）
  * -ENOMEM：内存不足，无法分配任务控制块或栈
  * -EAGAIN：系统资源不足，达到任务数量限制


**注意** ：

  * **任务 vs 线程** ：task_create() 创建的是 openvela 原生任务，不是 POSIX 线程。任务比线程更轻量，但不支持某些 pthread 特性（如线程局部存储、线程清理函数等）。对于 POSIX 兼容性，应使用 pthread_create()。
  * **栈分配** ：栈由系统自动分配（通常从堆中），任务终止时自动释放。如果需要使用预分配的栈，使用 task_create_with_stack()。
  * **参数传递** ：argv 数组及其字符串会被复制到任务的上下文中，因此调用者可以在函数返回后释放或修改原参数。但要注意，参数是浅拷贝（指针本身复制，指针指向的数据不复制）。
  * **任务调度** ：任务创建后立即处于就绪状态。如果新任务优先级高于当前任务，会立即抢占当前任务（抢占式调度）。
  * **任务终止** ：入口函数返回后任务自动终止。也可以调用 exit()、task_delete() 或接收信号（如 SIGKILL）终止。
  * **资源管理** ：任务终止后，系统会自动清理其资源（栈、任务控制块等），但不会清理任务分配的其他资源（如打开的文件、分配的内存等），需要任务自己负责清理。
  * **初始调度策略** ：新任务的调度策略默认为 SCHED_FIFO（或系统默认策略），可以在创建后使用 sched_setscheduler() 修改。
  * **典型用法** ：  

        
        char *argv[] = {"arg1", "arg2", NULL};
        int pid = task_create("my_task", 100, 4096, task_main, argv);
        if (pid < 0) {
            printf("Failed to create task: %d\n", pid);
        }

  * **与 fork() 的区别** ：不同于 fork()，task_create() 不复制父任务的地址空间，新任务从指定入口函数开始执行，不共享父任务的代码段以外的资源。


**POSIX 兼容性** ：openvela 扩展接口（非 POSIX 标准）。

## task_create_with_stack
    
    
    int task_create_with_stack(const char *name, int priority,
                               void *stack, int stack_size,
                               main_t entry, char * const argv[]);

使用预分配的栈创建一个新任务。与 task_create() 类似，但允许调用者提供栈内存，而不是由系统自动分配。这在需要精确控制内存布局、使用特殊内存区域（如共享内存、DMA 可访问内存）或优化启动性能时非常有用。

预分配栈给予程序员更多控制权，但也带来了更多责任（如栈大小验证、内存对齐、生命周期管理）。

**参数** ：

  * name 任务名称，用于调试和标识。字符串会被复制，因此可以是临时缓冲区。最大长度通常由 CONFIG_TASK_NAME_SIZE 定义（如 31 字符 + NULL）。如果为 NULL，任务将有一个自动生成的名称。
  * priority 任务优先级，数值越大优先级越高。有效范围通常为 1 到 255，可以通过 sched_get_priority_min() / sched_get_priority_max() 查询。优先级决定任务的调度顺序。
  * stack 指向预分配栈内存的指针。必须：
  * **非 NULL** ：不能为 NULL，否则返回错误
  * **足够大小** ：至少为 stack_size 字节
  * **正确对齐** ：通常需要对齐到架构要求的边界（如 8 字节或 16 字节）
  * **可写** ：栈内存必须可读写
  * **生命周期管理** ：调用者负责在任务终止后释放栈内存（如果动态分配）
  * stack_size 栈大小（字节）。必须满足：
  * **最小要求** ：至少为 PTHREAD_STACK_MIN（通常几百字节）
  * **任务需求** ：足够容纳任务的局部变量、函数调用深度、中断/异常处理
  * **对齐** ：某些架构可能要求大小也对齐（如 8 字节的倍数）
  * entry 任务入口函数，签名为 int main(int argc, char *argv[])。不能为 NULL，否则返回错误。
  * argv 传递给任务的参数数组（类似 main() 的 argv）。数组必须以 NULL 指针结尾。可以为 NULL，表示无参数（等同于空数组）。


**返回值** ：

  * 成功：返回新任务的 PID（正整数）
  * 失败：返回负的错误码：
  * -EINVAL：参数无效（如 stack 为 NULL、entry 为 NULL、priority 超出范围）
  * -ENOMEM：内存不足（虽然栈已提供，但任务控制块等仍需分配）
  * -EAGAIN：系统任务数已达上限（CONFIG_MAX_TASKS）


**注意** ：

  * **与 task_create 的区别** ：
  * **task_create** ：系统自动分配和释放栈
  * **task_create_with_stack** ：调用者提供栈，并负责释放
  * **栈生命周期管理** ：
  * 栈内存必须在任务的整个生命周期内保持有效
  * 任务终止后，调用者负责释放栈内存（如果是动态分配的）
  * 如果栈是静态数组或全局变量，无需显式释放
  * **典型用法（动态分配栈）** ：  

        
        void *stack = malloc(8192);
        if (stack == NULL) {
            perror("malloc");
            return -1;
        }
          
        int pid = task_create_with_stack("worker", 100, stack, 8192,
                                         worker_func, NULL);
        if (pid < 0) {
            perror("task_create_with_stack");
            free(stack);
            return -1;
        }
          
        // ... 等待任务结束 ...
        waitpid(pid, NULL, 0);
        free(stack);  // 释放栈

  * **静态栈示例** ：  

        
        static uint8_t worker_stack[4096] __attribute__((aligned(16)));
          
        int pid = task_create_with_stack("worker", 100, worker_stack,
                                         sizeof(worker_stack), worker_func, NULL);

  * **栈方向** ：某些架构栈向下增长，某些向上增长。openvela 会自动处理栈方向，调用者只需提供起始地址和大小。
  * **栈对齐** ：确保栈地址正确对齐（通常 8 字节或 16 字节），否则可能导致未定义行为或性能下降：  

        
        void *stack = aligned_alloc(16, 8192);  // 16 字节对齐

  * **栈溢出保护** ：预分配栈不自动提供溢出保护（guard page）。如果需要，应在栈顶/底额外分配保护页，并设置为不可访问：  

        
        void *stack_with_guard = malloc(8192 + 4096);  // 多分配一页保护
        mprotect(stack_with_guard, 4096, PROT_NONE);   // 保护页不可访问
        void *usable_stack = (char*)stack_with_guard + 4096;
        task_create_with_stack("worker", 100, usable_stack, 8192, worker_func, NULL);

  * **共享内存栈** ：可以使用共享内存作为栈，实现跨进程的栈共享（高级用法，需要仔细同步）：  

        
        int shm_fd = shm_open("/worker_stack", O_CREAT | O_RDWR, 0666);
        ftruncate(shm_fd, 8192);
        void *stack = mmap(NULL, 8192, PROT_READ | PROT_WRITE, MAP_SHARED, shm_fd, 0);
        task_create_with_stack("worker", 100, stack, 8192, worker_func, NULL);

  * **性能考虑** ：使用预分配栈可以减少任务创建时的内存分配开销，提高启动性能。在需要频繁创建/销毁任务的场景中（如任务池），可以维护一个栈缓存池。
  * **调试建议** ：在调试阶段，可以在栈边界填充魔数（如 0xDEADBEEF），然后定期检查，及早发现栈溢出：  

        
        uint32_t *stack_end = (uint32_t*)((char*)stack + stack_size - sizeof(uint32_t));
        *stack_end = 0xDEADBEEF;
        // ... 任务运行 ...
        if (*stack_end != 0xDEADBEEF) {
            printf("Stack overflow detected!\n");
        }

  * **实时系统优化** ：在实时系统中，使用预分配栈可以避免动态分配的不确定性，提高任务创建的确定性和速度。
  * **陷阱** ：
  * 栈过小会导致栈溢出，难以调试（通常表现为随机崩溃或数据损坏）
  * 忘记释放动态分配的栈会导致内存泄漏
  * 栈未对齐可能导致未定义行为（某些架构会崩溃，某些只是性能下降）
  * 在任务仍在运行时释放栈会导致严重错误


**POSIX 兼容性** ：openvela 扩展接口（非 POSIX 标准，类似于某些 RTOS 的接口）。

## task_delete
    
    
    int task_delete(pid_t pid);

删除（终止）指定的任务，释放其占用的系统资源。与 pthread_cancel() 或 kill(pid, SIGKILL) 类似，但这是 openvela 的原生接口，更直接和高效。

任务删除是强制性的，不经过正常的清理流程（如 atexit 处理程序），应谨慎使用。通常应优先使用协作式终止机制（如设置退出标志，让任务自行退出）。

**参数** ：

  * pid 要删除的任务 PID。特殊值 0 表示删除调用任务自身（等同于 exit()）。必须是有效的任务 PID。


**返回值** ：

  * 成功：返回 0（OK）
  * 失败：返回负的错误码：
  * -EINVAL：pid 无效（如为负值）
  * -ESRCH：指定的任务不存在（PID 无效或任务已终止）
  * -EPERM：调用者没有权限删除目标任务（取决于系统配置）


**注意** ：

  * **强制终止** ：任务被立即终止，不会执行清理代码（如 pthread_cleanup_push 注册的处理程序、atexit 回调等）。这可能导致资源泄漏（如未释放的内存、未关闭的文件、未解锁的互斥锁）。
  * **资源清理** ：内核会自动回收任务的核心资源（如栈内存、任务控制块），但应用层资源（如堆内存、打开的文件）可能不会自动清理。
  * **删除自身** ：如果 pid 为 0，任务会删除自己，永不返回（类似调用 exit(0)）：  

        
        task_delete(0);
        // 这行代码永远不会执行

  * **与 pthread_cancel 的区别** ：
  * task_delete() 立即强制终止，无取消点概念
  * pthread_cancel() 在下一个取消点才生效，允许清理
  * task_delete() 是 openvela 扩展，pthread_cancel() 是 POSIX 标准
  * **典型用法** ：  

        
        int pid = task_create("worker", 100, 2048, worker_func, NULL);
        // ... 任务运行 ...
          
        // 终止任务
        if (task_delete(pid) == 0) {
            printf("Task %d deleted\n", pid);
        } else {
            perror("task_delete");
        }

  * **互斥锁陷阱** ：如果被删除的任务正持有互斥锁，其他等待该锁的任务将永远阻塞（死锁）。应确保任务在被删除前释放所有锁。
  * **子任务清理** ：删除父任务不会自动删除其子任务。如果需要清理整个任务树，必须显式删除所有子任务。
  * **替代方案** ：
  * **协作式退出** ：设置退出标志，让任务自行检查并退出
  * **pthread_cancel** ：使用 POSIX 取消机制，允许清理处理程序运行
  * **信号** ：发送 SIGTERM，让任务捕获并优雅退出
  * **实时系统注意** ：在实时系统中，强制删除任务可能影响系统的确定性和可预测性，应谨慎使用。
  * **调试建议** ：在调试阶段，可以在任务入口和退出点添加日志，帮助跟踪任务生命周期。
  * **批量删除** ：如果需要删除多个任务，应按依赖顺序删除（先删除子任务，后删除父任务），避免悬空引用。


**POSIX 兼容性** ：openvela 扩展接口（非 POSIX 标准）。

## task_restart
    
    
    int task_restart(pid_t pid);

重启指定的任务，任务将使用原始的入口点、参数、优先级和栈大小重新开始执行。这相当于先终止任务，然后用相同参数重新创建。

任务重启是一种特殊的恢复机制，用于处理任务异常或需要重置任务状态的场景。与删除后重新创建相比，重启保留了原始任务的配置信息。

**参数** ：

  * pid 要重启的任务 PID。必须是有效的任务 PID（不能为 0，因为不能重启自己）。


**返回值** ：

  * 成功：返回 0（OK）
  * 失败：返回负的错误码：
  * -EINVAL：pid 无效（如为 0 或负值）
  * -ESRCH：指定的任务不存在（PID 无效或任务已终止）
  * -EPERM：调用者没有权限重启目标任务（取决于系统配置）
  * -ENOMEM：内存不足，无法重启任务


**注意** ：

  * **不能重启自己** ：不能用 task_restart(0) 或 task_restart(getpid()) 重启自己，因为重启会销毁当前执行上下文。如果尝试这样做，通常会返回 -EINVAL。
  * **任务状态重置** ：重启后，任务的所有状态（包括局部变量、堆栈内容、寄存器）都会重置，就像刚刚创建一样。任务会从入口函数开始执行。
  * **保留配置** ：重启后的任务保留原始配置：
  * 任务名称（name）
  * 优先级（priority）
  * 栈大小（stack_size）
  * 入口函数（entry）
  * 入口参数（argv）
  * **PID 保持不变** ：重启后，任务的 PID 保持不变，其他任务引用此 PID 仍然有效。
  * **典型用法** ：  

        
        int pid = task_create("monitor", 150, 2048, monitor_task, NULL);
          
        // ... 任务运行一段时间后检测到异常 ...
          
        // 重启任务
        if (task_restart(pid) == 0) {
            printf("Task %d restarted\n", pid);
        } else {
            perror("task_restart");
        }

  * **与 task_delete + task_create 的区别** ：
  * **task_restart** ：PID 不变，保留原始配置，一步完成
  * **task_delete + task_create** ：PID 改变，需要重新指定所有参数，两步操作
  * **资源清理** ：重启前，任务持有的资源（如打开的文件、分配的内存、持有的锁）可能不会自动释放，这可能导致资源泄漏。应在任务设计时考虑异常恢复机制。
  * **互斥锁陷阱** ：如果任务正持有互斥锁，重启会导致锁永远无法释放（死锁）。应确保任务在重启前释放所有锁，或使用鲁棒互斥锁（robust mutex）。
  * **看门狗场景** ：常用于看门狗系统，当检测到任务无响应或异常时，自动重启任务恢复服务：  

        
        void watchdog_task(void *arg) {
            while (1) {
                if (check_task_health(worker_pid) == FAILED) {
                    printf("Worker unhealthy, restarting...\n");
                    task_restart(worker_pid);
                }
                sleep(5);
            }
        }

  * **重启计数** ：在生产系统中，应限制重启次数，避免陷入无限重启循环：  

        
        int restart_count = 0;
        const int MAX_RESTARTS = 3;
          
        if (task_restart(pid) == 0) {
            restart_count++;
            if (restart_count >= MAX_RESTARTS) {
                printf("Max restarts reached, giving up\n");
                task_delete(pid);
            }
        }

  * **异步操作** ：重启是异步的，函数返回时任务可能还在初始化中。如果需要等待任务完成初始化，应使用额外的同步机制（如信号量）。
  * **调试建议** ：在任务入口函数中添加日志，记录每次启动时间和原因，有助于分析重启历史。
  * **实时系统影响** ：频繁重启任务可能影响系统的实时性和可预测性，应通过改进任务健壮性来减少重启需求。


**POSIX 兼容性** ：openvela 扩展接口（非 POSIX 标准）。

# 任务取消

## task_setcancelstate
    
    
    int task_setcancelstate(int state, int *oldstate);

设置调用任务的取消状态（cancel state），控制任务是否可以被取消。与 pthread_setcancelstate() 类似，但适用于所有任务（不仅限于 pthread）。

取消状态是任务取消机制的一部分，允许任务临时禁止取消，保护关键代码段不被中断。

**参数** ：

  * state 新的取消状态，有效值：
  * TASK_CANCEL_ENABLE (0)：允许取消（默认），任务可以响应取消请求
  * TASK_CANCEL_DISABLE (1)：禁止取消，任务忽略取消请求（请求被推迟）
  * oldstate 如果非 NULL，用于接收之前的取消状态。如果不关心旧值，可以传 NULL。


**返回值** ：

  * 成功：返回 0（OK）
  * 失败：返回负的错误码：
  * -EINVAL：state 参数无效（不是 TASK_CANCEL_ENABLE 或 TASK_CANCEL_DISABLE）


**注意** ：

  * **保护关键区域** ：在执行不可中断的关键操作时（如更新共享数据结构、持有互斥锁），应禁用取消：  

        
        task_setcancelstate(TASK_CANCEL_DISABLE, NULL);
        // 关键操作，不能被取消中断
        update_critical_data();
        task_setcancelstate(TASK_CANCEL_ENABLE, NULL);

  * **推迟取消** ：当取消状态为 TASK_CANCEL_DISABLE 时，取消请求不会丢失，而是被推迟。当取消状态重新设置为 TASK_CANCEL_ENABLE 时，如果有待处理的取消请求，任务会在下一个取消点被取消。
  * **取消类型交互** ：取消状态与取消类型（task_setcanceltype()）共同决定取消行为：
  * **状态=ENABLE, 类型=DEFERRED** ：在取消点才取消（默认，最安全）
  * **状态=ENABLE, 类型=ASYNCHRONOUS** ：任何时候都可以取消（危险）
  * **状态=DISABLE** ：无论类型如何，都不会取消
  * **典型用法（保存旧状态）** ：  

        
        int oldstate;
        task_setcancelstate(TASK_CANCEL_DISABLE, &oldstate);
        // 关键操作
        critical_section();
        task_setcancelstate(oldstate, NULL);  // 恢复原状态

  * **与互斥锁配合** ：  

        
        pthread_mutex_lock(&mutex);
        task_setcancelstate(TASK_CANCEL_DISABLE, NULL);
          
        // 受保护的操作
        modify_shared_data();
          
        task_setcancelstate(TASK_CANCEL_ENABLE, NULL);
        pthread_mutex_unlock(&mutex);

  * **默认状态** ：新创建的任务默认取消状态为 TASK_CANCEL_ENABLE，允许被取消。
  * **不影响信号** ：取消状态只影响通过 task_delete() 或类似机制的取消，不影响信号（如 SIGTERM）的处理。
  * **与 pthread 的兼容性** ：在 pthread 线程中，task_setcancelstate() 和 pthread_setcancelstate() 通常是等价的，操作同一底层状态。
  * **嵌套禁用** ：可以多次调用 TASK_CANCEL_DISABLE，但每次都应对应一次 TASK_CANCEL_ENABLE（或恢复旧状态），否则可能导致永久禁用取消：  

        
        int old1, old2;
        task_setcancelstate(TASK_CANCEL_DISABLE, &old1);  // 第一次禁用
        task_setcancelstate(TASK_CANCEL_DISABLE, &old2);  // 第二次禁用（无效果）
        task_setcancelstate(old2, NULL);  // 恢复到old2（仍然禁用）
        task_setcancelstate(old1, NULL);  // 恢复到old1（可能启用）

  
更简单的做法是只在最外层操作取消状态。
  * **清理处理程序** ：即使禁用了取消，清理处理程序（pthread_cleanup_push）仍然会在任务正常退出时执行。
  * **性能考虑** ：设置取消状态是轻量操作，但应避免在紧密循环中频繁切换，以免影响性能。


**POSIX 兼容性** ：类似 pthread_setcancelstate()，但适用于所有任务类型。

## task_setcanceltype
    
    
    int task_setcanceltype(int type, int *oldtype);

设置调用任务的取消类型（cancel type），控制取消请求何时生效。与 pthread_setcanceltype() 类似，但适用于所有任务（不仅限于 pthread）。

取消类型决定了任务响应取消请求的时机，影响任务取消的安全性和响应性。

**参数** ：

  * type 新的取消类型，有效值：
  * TASK_CANCEL_DEFERRED (0)：延迟取消（默认），仅在取消点（cancellation point）才响应取消请求，如 pthread_testcancel()、sleep()、read() 等阻塞调用
  * TASK_CANCEL_ASYNCHRONOUS (1)：异步取消，任务可以在任意时刻被取消（危险，可能导致资源泄漏或数据不一致）
  * oldtype 如果非 NULL，用于接收之前的取消类型。如果不关心旧值，可以传 NULL。


**返回值** ：

  * 成功：返回 0（OK）
  * 失败：返回负的错误码：
  * -EINVAL：type 参数无效（不是 TASK_CANCEL_DEFERRED 或 TASK_CANCEL_ASYNCHRONOUS）


**注意** ：

  * **默认类型（DEFERRED）最安全** ：延迟取消是默认且推荐的类型，它只在明确定义的取消点才生效，允许任务在取消前完成当前操作并清理资源。
  * **异步取消的危险性** ：TASK_CANCEL_ASYNCHRONOUS 极其危险，因为任务可能在任何时刻被取消：
  * 可能在持有互斥锁时被取消，导致死锁
  * 可能在更新数据结构的中途被取消，导致数据不一致
  * 可能在分配内存后、保存指针前被取消，导致内存泄漏
  * 只有非常特殊的代码（如纯计算任务，不访问共享资源）才应使用异步取消
  * **取消点** ：常见的取消点包括：
  * task_testcancel() / pthread_testcancel()：显式取消点
  * 阻塞的系统调用：sleep()、usleep()、read()、write()、recv()、send()
  * 同步原语：pthread_cond_wait()、sem_wait()
  * 某些库函数：printf()（可能）
  * **典型用法（临时启用异步取消）** ：  

        
        int oldtype;
        task_setcanceltype(TASK_CANCEL_ASYNCHRONOUS, &oldtype);
        // 纯计算任务，不访问共享资源
        perform_long_computation();
        task_setcanceltype(oldtype, NULL);  // 恢复原类型

  
但通常更好的做法是在循环中定期调用 task_testcancel()。
  * **推荐做法（在循环中添加取消点）** ：  

        
        while (processing) {
            process_chunk();
            task_testcancel();  // 定期检查取消请求
        }

  
这比使用异步取消更安全，且仍能及时响应取消。
  * **与取消状态交互** ：取消类型与取消状态共同决定取消行为：
  * **状态=ENABLE, 类型=DEFERRED** ：在取消点才取消（默认，最安全）
  * **状态=ENABLE, 类型=ASYNCHRONOUS** ：任何时候都可以取消（危险）
  * **状态=DISABLE** ：无论类型如何，都不会取消
  * **清理处理程序** ：无论取消类型如何，任务被取消时都会执行清理处理程序（pthread_cleanup_push 注册）。但异步取消可能在不一致的状态下触发清理，导致问题。
  * **实时系统考虑** ：在实时系统中，异步取消可能影响系统的可预测性，应避免使用。优先使用延迟取消或协作式退出机制。
  * **与 pthread 的兼容性** ：在 pthread 线程中，task_setcanceltype() 和 pthread_setcanceltype() 通常是等价的。
  * **默认值** ：新创建的任务默认取消类型为 TASK_CANCEL_DEFERRED（延迟取消）。
  * **避免混用** ：不要在同一任务中混用延迟和异步取消类型，这会使代码难以理解和维护。选择一种类型并坚持使用。
  * **异步安全代码** ：如果必须使用异步取消，确保任务代码是异步安全的（async-cancel-safe），类似于信号处理程序的要求：
  * 不调用非异步安全的函数（如 malloc()、printf()）
  * 不访问共享数据（或使用原子操作）
  * 不持有任何锁


**POSIX 兼容性** ：类似 pthread_setcanceltype()，但适用于所有任务类型。

## task_testcancel
    
    
    void task_testcancel(void);

创建一个显式的取消点（cancellation point）。如果有待处理的取消请求，且任务的取消状态为允许（TASK_CANCEL_ENABLE），则任务将在此处被取消并终止。

这是延迟取消机制的核心，允许任务在安全的位置响应取消请求，确保资源正确释放和状态一致性。

**参数** ：

无参数。

**返回值** ：

  * 无返回值（如果任务被取消，函数永不返回）
  * 如果没有待处理的取消请求，或取消状态为禁止，函数正常返回


**注意** ：

  * **显式取消点** ：此函数是程序员主动创建的取消点，与隐式取消点（如 sleep()、read()）不同。显式取消点提供了更精确的控制，允许任务在安全的位置检查取消请求。
  * **典型用法（长时间循环）** ：  

        
        while (processing) {
            process_data_chunk();
            task_testcancel();  // 定期检查取消请求
        }

  
这确保任务能及时响应取消，同时保证每次循环迭代完整完成。
  * **取消条件** ：任务仅在以下所有条件都满足时被取消：  
1\. 有待处理的取消请求（通过 task_delete() 或类似机制触发）  
2\. 取消状态为 TASK_CANCEL_ENABLE（默认）  
3\. 取消类型为 TASK_CANCEL_DEFERRED（默认），或者无论类型（如果状态为 ENABLE）
  * **清理处理程序** ：如果任务被取消，会执行清理处理程序（pthread_cleanup_push 注册），然后终止。确保在关键资源（如互斥锁）使用时注册清理处理程序：  

        
        pthread_mutex_lock(&mutex);
        pthread_cleanup_push((void(*)(void*))pthread_mutex_unlock, &mutex);
          
        // 可能被取消的操作
        while (condition) {
            process_data();
            task_testcancel();
        }
          
        pthread_cleanup_pop(1);  // 正常退出也解锁

  * **不影响异步取消** ：如果取消类型为 TASK_CANCEL_ASYNCHRONOUS，任务可能在任何时刻被取消，不仅限于取消点。
  * **与 pthread_testcancel 的兼容性** ：task_testcancel() 和 pthread_testcancel() 通常是等价的，可以互换使用。
  * **性能考虑** ：检查取消请求是轻量操作，但应避免在极紧密的循环中调用（如每次循环耗时微秒级），以免影响性能。可以每处理 N 个项目后调用一次：  

        
        for (int i = 0; i < items; i++) {
            process_item(i);
            if (i % 100 == 0) task_testcancel();  // 每100次检查一次
        }

  * **取消安全的位置** ：应在以下位置调用 task_testcancel()：
  * 不持有任何互斥锁
  * 所有数据结构处于一致状态
  * 没有未释放的临时资源
  * **实时系统影响** ：在实时系统中，取消点会增加任务的响应时间不确定性（虽然很小）。如果需要极高的确定性，可以在任务设计时避免取消机制，改用协作式退出。
  * **调试建议** ：在调试取消相关问题时，可以在 task_testcancel() 前后添加日志，跟踪取消点的执行：  

        
        printf("Before testcancel\n");
        task_testcancel();
        printf("After testcancel (not cancelled)\n");

  * **与退出标志的比较** ：
  * **task_testcancel()** ：内核机制，更轻量，与清理处理程序集成
  * **退出标志** ：用户态机制，更灵活，但需要手动管理清理  

        
        // 退出标志方式
        volatile bool should_exit = false;
        while (!should_exit) {
            process_data();
        }

  * **无操作返回** ：如果没有取消请求，函数立即返回，几乎无开销（只是检查一个标志位）。


**POSIX 兼容性** ：类似 pthread_testcancel()，但适用于所有任务类型。

# 调度策略与参数

## sched_setscheduler
    
    
    int sched_setscheduler(pid_t pid, int policy, const struct sched_param *param);

设置指定任务的调度策略和调度参数（如优先级）。这是控制任务调度行为的主要接口，允许在运行时动态调整任务的调度特性。

调度策略决定了任务如何竞争 CPU 时间，不同策略适用于不同类型的任务（实时、批处理、交互等）。修改调度策略通常需要适当的权限。

**参数** ：

  * pid 目标任务的 PID。特殊值 0 表示调用任务自身。必须是有效的任务 PID。
  * policy 新的调度策略，有效值包括：
  * SCHED_FIFO (0)：先进先出实时调度，无时间片，适合硬实时任务
  * SCHED_RR (1)：轮转实时调度，有时间片，适合需要公平性的实时任务
  * SCHED_SPORADIC (2)：零星调度，适合周期性实时任务（需要 CONFIG_SCHED_SPORADIC）
  * SCHED_OTHER (3)：标准分时调度，映射到 SCHED_FIFO 或 SCHED_RR
  * SCHED_NORMAL (3)：SCHED_OTHER 的别名
  * SCHED_BATCH (4)：批处理调度（如果支持）
  * SCHED_IDLE (5)：空闲调度，最低优先级（如果支持）
  * param 指向 struct sched_param 结构的指针，包含调度参数。至少需要设置 sched_priority 字段（基本优先级）。对于 SCHED_SPORADIC，还需要设置零星服务器参数（低优先级、补充周期、初始预算、最大补充次数）。


**返回值** ：

  * 成功：返回任务之前的调度策略（SCHED_FIFO、SCHED_RR 等）
  * 失败：返回 -1 并设置 errno：
  * EINVAL：policy 无效，或 param 中的优先级超出该策略允许的范围
  * ESRCH：指定的任务不存在（PID 无效或任务已终止）
  * EPERM：调用者没有权限修改目标任务的调度策略（通常需要超级用户权限或同一用户）
  * EFAULT：param 指向无效内存


**注意** ：

  * **优先级范围** ：不同调度策略有不同的有效优先级范围，可以通过 sched_get_priority_min(policy) 和 sched_get_priority_max(policy) 查询。设置超出范围的优先级会导致 EINVAL 错误。
  * **策略切换影响** ：
  * 切换到更高优先级的策略可能导致任务立即抢占当前任务
  * 切换到较低优先级可能导致任务被其他任务抢占
  * 策略切换不会改变任务的就绪状态，已阻塞的任务仍然阻塞
  * **SCHED_SPORADIC 参数** ：使用此策略时，必须在 param 中设置：
  * sched_ss_low_priority：预算耗尽后的低优先级
  * sched_ss_repl_period：补充周期
  * sched_ss_init_budget：初始预算
  * sched_ss_max_repl：最大待处理补充次数（<= SS_REPL_MAX）
  * **实时调度策略** ：SCHED_FIFO 和 SCHED_RR 是实时策略，通常需要提升权限。实时任务可能影响系统响应性，应谨慎使用。
  * **调度策略继承** ：子任务（通过 fork() 或 task_create() 创建）通常继承父任务的调度策略和优先级，除非在创建时指定或稍后修改。
  * **典型用法** ：  

        
        struct sched_param param;
        param.sched_priority = 150;  // 设置高优先级
          
        int old_policy = sched_setscheduler(0, SCHED_FIFO, &param);
        if (old_policy < 0) {
            perror("sched_setscheduler");
        } else {
            printf("Changed from policy %d to SCHED_FIFO\n", old_policy);
        }

  * **查询当前策略** ：使用 sched_getscheduler(pid) 查询任务当前的调度策略。
  * **仅修改优先级** ：如果只想修改优先级而不改变策略，使用 sched_setparam()，它更高效且语义更清晰。
  * **原子性** ：策略和参数的修改是原子的，不会出现中间状态。
  * **对运行任务的影响** ：如果修改当前正在运行的任务（pid=0），调度器会立即重新评估任务优先级，可能导致任务被抢占。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## sched_getscheduler
    
    
    int sched_getscheduler(pid_t pid);

查询指定任务的当前调度策略。这是一个轻量级查询接口，用于获取任务的调度策略类型（如 SCHED_FIFO、SCHED_RR 等）。

调度策略决定了任务的调度行为，了解当前策略有助于调试和监控任务的实时特性。

**参数** ：

  * pid 目标任务的 PID。特殊值 0 表示查询调用任务自身的调度策略。必须是有效的任务 PID。


**返回值** ：

  * 成功：返回任务当前的调度策略（非负整数）：
  * SCHED_FIFO (0)：先进先出实时调度
  * SCHED_RR (1)：轮转实时调度
  * SCHED_SPORADIC (2)：零星调度（如果支持）
  * SCHED_OTHER (3)：标准分时调度
  * SCHED_BATCH (4)：批处理调度（如果支持）
  * SCHED_IDLE (5)：空闲调度（如果支持）
  * 失败：返回 -1 并设置 errno：
  * ESRCH：指定的任务不存在（PID 无效或任务已终止）
  * EINVAL：参数 pid 为负值


**注意** ：

  * **只读查询** ：此函数不修改任务状态，是纯查询操作，开销很小。
  * **配合使用** ：通常与 sched_getparam() 配合使用，以获取完整的调度信息（策略 + 参数）。
  * **典型用法** ：  

        
        int policy = sched_getscheduler(0);  // 查询自己的策略
        if (policy >= 0) {
            const char *policy_names[] = {"SCHED_FIFO", "SCHED_RR", "SCHED_SPORADIC", "SCHED_OTHER"};
            printf("Current policy: %s\n", policy_names[policy]);
        } else {
            perror("sched_getscheduler");
        }

  * **任务诊断** ：在调试实时系统时，可以用此函数验证任务是否运行在预期的调度策略下。
  * **监控工具** ：系统监控工具常用此函数显示任务的调度策略，帮助分析系统调度行为。
  * **修改策略** ：如果需要修改调度策略，使用 sched_setscheduler()。
  * **策略名称映射** ：可以使用 switch 或数组将返回的整数值映射为策略名称，提高可读性。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## sched_setparam
    
    
    int sched_setparam(pid_t pid, const struct sched_param *param);

修改指定任务的调度参数（主要是优先级），但不改变调度策略。这是调整任务优先级的标准接口，比 sched_setscheduler() 更轻量，语义更清晰。

优先级是调度系统中最重要的参数，决定了任务在同一策略下的执行顺序。动态调整优先级是实时系统中常见的需求，例如实现优先级继承或优先级天花板协议。

**参数** ：

  * pid 目标任务的 PID。特殊值 0 表示修改调用任务自身的参数。必须是有效的任务 PID。
  * param 指向 struct sched_param 结构的指针，包含新的调度参数。主要字段：
  * sched_priority：新的优先级值（必需），必须在当前调度策略的有效范围内
  * 对于 SCHED_SPORADIC 策略，还包括 sched_ss_low_priority、sched_ss_repl_period、sched_ss_init_budget、sched_ss_max_repl 等零星服务器参数


**返回值** ：

  * 成功：返回 0
  * 失败：返回 -1 并设置 errno：
  * EINVAL：param 中的优先级超出当前策略允许的范围，或 SCHED_SPORADIC 参数无效
  * ESRCH：指定的任务不存在（PID 无效或任务已终止）
  * EPERM：调用者没有权限修改目标任务的调度参数（通常需要超级用户权限或同一用户）
  * EFAULT：param 指向无效内存


**注意** ：

  * **保持策略不变** ：此函数只修改调度参数，不改变调度策略。如果需要同时修改策略和参数，使用 sched_setscheduler()。
  * **优先级范围** ：每种调度策略有其有效的优先级范围，可以通过 sched_get_priority_min() 和 sched_get_priority_max() 查询。超出范围会导致 EINVAL 错误。
  * **立即生效** ：优先级修改立即生效，调度器会重新评估任务优先级：
  * 如果新优先级更高，任务可能立即抢占当前任务
  * 如果新优先级更低，任务可能被其他高优先级任务抢占
  * 对于阻塞任务，新优先级在任务恢复运行时生效
  * **优先级继承** ：在实现互斥锁的优先级继承协议时，通常使用此函数临时提升低优先级任务的优先级，避免优先级反转。
  * **典型用法** ：  

        
        struct sched_param param;
        param.sched_priority = 100;  // 设置新优先级
          
        if (sched_setparam(0, &param) == 0) {
            printf("Priority changed to %d\n", param.sched_priority);
        } else {
            perror("sched_setparam");
        }

  * **查询当前参数** ：使用 sched_getparam() 获取任务当前的调度参数，然后修改需要改变的字段。
  * **实时系统调优** ：在实时系统中，根据任务的实际执行情况动态调整优先级，可以优化系统响应性和吞吐量。
  * **权限要求** ：修改其他任务的优先级通常需要特权。在嵌入式系统中，通常所有任务运行在同一权限级别，这一限制可能较宽松。
  * **对运行任务的影响** ：修改当前运行任务（pid=0）的优先级可能立即触发重新调度，如果系统中有更高优先级的就绪任务。
  * **SCHED_SPORADIC 参数** ：对于零星调度任务，param 中的其他字段（如 sched_ss_low_priority）也可以通过此函数修改，实现动态调整零星服务器行为。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## sched_getparam
    
    
    int sched_getparam(pid_t pid, struct sched_param *param);

查询指定任务的当前调度参数（主要是优先级）。这是获取任务优先级和其他调度参数的标准接口，常用于监控、调试和动态调度决策。

调度参数包括基本优先级以及特定策略相关的参数（如零星调度的补充周期），了解这些参数有助于理解任务的调度行为。

**参数** ：

  * pid 目标任务的 PID。特殊值 0 表示查询调用任务自身的参数。必须是有效的任务 PID。
  * param 指向 struct sched_param 结构的指针，用于接收查询结果。函数会填充此结构：
  * sched_priority：任务的基本优先级（始终设置）
  * 对于 SCHED_SPORADIC 策略，还包括 sched_ss_low_priority、sched_ss_repl_period、sched_ss_init_budget、sched_ss_max_repl 等零星服务器参数
  * 其他策略（SCHED_FIFO、SCHED_RR、SCHED_OTHER）通常只设置 sched_priority


**返回值** ：

  * 成功：返回 0，并在 param 中填充任务的调度参数
  * 失败：返回 -1 并设置 errno：
  * ESRCH：指定的任务不存在（PID 无效或任务已终止）
  * EINVAL：参数 pid 为负值
  * EFAULT：param 指向无效内存（NULL 或不可写）


**注意** ：

  * **只读查询** ：此函数不修改任务状态，是纯查询操作，开销很小。
  * **完整调度信息** ：通常与 sched_getscheduler() 配合使用，获取完整的调度信息（策略 + 参数）：  

        
        int policy = sched_getscheduler(0);
        struct sched_param param;
        sched_getparam(0, &param);
        printf("Policy: %d, Priority: %d\n", policy, param.sched_priority);

  * **典型用法** ：  

        
        struct sched_param param;
        if (sched_getparam(0, &param) == 0) {
            printf("Current priority: %d\n", param.sched_priority);
        } else {
            perror("sched_getparam");
        }

  * **动态调整参考** ：在动态调整优先级前，先用此函数获取当前参数，然后修改特定字段，最后用 sched_setparam() 应用更改。
  * **监控工具** ：系统监控工具常用此函数显示任务的优先级，帮助分析调度行为和诊断优先级反转等问题。
  * **零星调度参数** ：对于 SCHED_SPORADIC 策略的任务，此函数返回完整的零星服务器配置，包括预算、补充周期等。
  * **参数初始化** ：在调用前无需初始化 param 结构，函数会完全覆盖其内容。但确保 param 指向有效内存。
  * **任务诊断** ：在调试实时系统时，可以定期查询关键任务的优先级，验证优先级继承等机制是否正常工作。
  * **原子性** ：查询操作是原子的，返回的参数是一致的快照，不会出现部分更新的情况。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

# 调度控制

## sched_yield
    
    
    int sched_yield(void);

主动放弃 CPU，使调用任务重新进入就绪队列，允许调度器选择其他同等或更高优先级的任务运行。这是一种协作式调度机制，用于实现任务间的公平性和响应性。

对于 SCHED_FIFO 策略，任务会被移到其优先级队列的末尾；对于 SCHED_RR 策略，效果类似于时间片到期。这允许相同优先级的任务有机会运行。

**参数** ：

无参数。

**返回值** ：

  * 成功：返回 0（OK）
  * 失败：返回 -1 并设置 errno（通常总是成功）


**注意** ：

  * **协作式调度** ：此函数是协作式多任务的关键，允许任务主动让出 CPU，提高系统整体响应性。
  * **不降低优先级** ：sched_yield() 不改变任务优先级，只是暂时放弃执行权。任务仍然在相同优先级的就绪队列中。
  * **策略相关行为** ：
  * **SCHED_FIFO** ：任务移到其优先级队列的末尾，如果有其他同优先级任务就绪，它们会先运行
  * **SCHED_RR** ：类似 SCHED_FIFO，且时间片计数器重置
  * **单任务情况** ：如果没有其他同等或更高优先级的就绪任务，调用任务会立即继续运行（yield 无效果）
  * **典型用法** ：  

        
        while (processing) {
            // 处理一批数据
            process_data_chunk();
              
            // 主动让出 CPU，允许其他任务运行
            sched_yield();
        }

  * **提高响应性** ：在长时间运行的循环中定期调用 sched_yield()，可以避免低优先级任务饿死，提高系统交互性。
  * **轮询优化** ：在轮询循环中使用 sched_yield() 可以减少 CPU 占用，给其他任务更多运行机会：  

        
        while (!flag_is_set()) {
            sched_yield();  // 避免空转占用 CPU
        }

  
但通常更好的方案是使用阻塞式等待（如信号量、条件变量）。
  * **与 sleep 的区别** ：
  * sched_yield() 不保证任务会被阻塞，如果没有其他就绪任务，会立即继续运行
  * sleep() / usleep() 会使任务至少休眠指定时间，期间不消耗 CPU
  * **实时系统注意** ：在实时系统中，过度使用 sched_yield() 可能导致不确定性，应谨慎使用。优先使用显式同步机制（互斥锁、条件变量、信号量）。
  * **高优先级任务** ：如果调用任务是系统中优先级最高的任务，sched_yield() 通常无实际效果（立即返回继续运行）。
  * **时间片重置** ：对于 SCHED_RR 策略，sched_yield() 会重置时间片，相当于任务自愿放弃当前时间片。
  * **不可中断** ：即使调用 sched_yield() 后立即返回，也会发生上下文切换检查，调度器会重新评估调度决策。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## sched_get_priority_max
    
    
    int sched_get_priority_max(int policy);

查询指定调度策略允许的最大（highest）优先级值。不同调度策略有不同的优先级范围，此函数用于获取有效的优先级上限，确保设置的优先级值在合法范围内。

在 openvela 中，数值越大表示优先级越高（与 Linux 相同，但与某些 RTOS 相反）。了解优先级范围对于正确配置实时任务至关重要。

**参数** ：

  * policy 调度策略，有效值包括：
  * SCHED_FIFO (0)：先进先出实时调度
  * SCHED_RR (1)：轮转实时调度
  * SCHED_SPORADIC (2)：零星调度（如果支持）
  * SCHED_OTHER (3)：标准分时调度
  * 其他系统支持的策略


**返回值** ：

  * 成功：返回指定策略的最大优先级值（正整数，通常为 255）
  * 失败：返回 -1 并设置 errno：
  * EINVAL：policy 参数无效或不支持


**注意** ：

  * **配合使用** ：通常与 sched_get_priority_min() 配合使用，获取完整的优先级范围：  

        
        int min_prio = sched_get_priority_min(SCHED_FIFO);
        int max_prio = sched_get_priority_max(SCHED_FIFO);
        printf("SCHED_FIFO priority range: %d to %d\n", min_prio, max_prio);

  * **openvela 默认范围** ：在 openvela 中，大多数策略的优先级范围通常为 1 到 255，其中：
  * 1：最低优先级（通常是 IDLE 任务）
  * 255：最高优先级（紧急实时任务）
  * 100-200：典型应用任务优先级范围
  * **策略无关性** ：在 openvela 中，通常所有实时策略（SCHED_FIFO、SCHED_RR、SCHED_SPORADIC）共享相同的优先级空间，因此最大值相同。
  * **参数验证** ：在调用 sched_setparam() 或 sched_setscheduler() 前，使用此函数验证优先级是否在有效范围内，避免 EINVAL 错误：  

        
        int new_priority = 200;
        if (new_priority <= sched_get_priority_max(SCHED_FIFO)) {
            struct sched_param param = {.sched_priority = new_priority};
            sched_setscheduler(0, SCHED_FIFO, &param);
        }

  * **可移植性** ：不同操作系统的优先级范围可能不同，使用此函数可以编写可移植的代码，避免硬编码优先级值。
  * **典型用法** ：  

        
        int max = sched_get_priority_max(SCHED_FIFO);
        if (max < 0) {
            perror("sched_get_priority_max");
        } else {
            printf("Max priority for SCHED_FIFO: %d\n", max);
        }

  * **实时任务配置** ：在配置关键实时任务时，通常使用接近最大值的优先级，以确保任务能抢占其他任务。
  * **优先级分层** ：在复杂系统中，可以将优先级范围分为几个层次（如系统层、驱动层、应用层），每层使用不同的优先级子范围。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## sched_get_priority_min
    
    
    int sched_get_priority_min(int policy);

查询指定调度策略允许的最小（lowest）优先级值。不同调度策略有不同的优先级范围，此函数用于获取有效的优先级下限，确保设置的优先级值在合法范围内。

在 openvela 中，数值越小表示优先级越低。最小优先级通常留给后台任务或空闲任务使用。

**参数** ：

  * policy 调度策略，有效值包括：
  * SCHED_FIFO (0)：先进先出实时调度
  * SCHED_RR (1)：轮转实时调度
  * SCHED_SPORADIC (2)：零星调度（如果支持）
  * SCHED_OTHER (3)：标准分时调度
  * 其他系统支持的策略


**返回值** ：

  * 成功：返回指定策略的最小优先级值（正整数，通常为 1）
  * 失败：返回 -1 并设置 errno：
  * EINVAL：policy 参数无效或不支持


**注意** ：

  * **配合使用** ：通常与 sched_get_priority_max() 配合使用，获取完整的优先级范围：  

        
        int min_prio = sched_get_priority_min(SCHED_RR);
        int max_prio = sched_get_priority_max(SCHED_RR);
        printf("SCHED_RR priority range: [%d, %d]\n", min_prio, max_prio);

  * **openvela 默认值** ：在 openvela 中，最小优先级通常为 1（优先级 0 有时保留给系统或特殊用途）。
  * **IDLE 任务** ：系统空闲任务（IDLE task）通常运行在最小优先级，仅在没有其他任务就绪时运行。
  * **后台任务** ：低优先级后台任务（如日志记录、统计）通常使用接近最小值的优先级，避免影响前台任务。
  * **参数验证** ：在设置优先级前，使用此函数验证优先级是否在有效范围内：  

        
        int new_priority = 5;
        if (new_priority >= sched_get_priority_min(SCHED_FIFO) &&
            new_priority <= sched_get_priority_max(SCHED_FIFO)) {
            struct sched_param param = {.sched_priority = new_priority};
            sched_setparam(0, &param);
        }

  * **可移植性** ：不同操作系统的优先级范围可能不同，使用此函数可以编写可移植的代码，避免硬编码优先级值。
  * **典型用法** ：  

        
        int min = sched_get_priority_min(SCHED_FIFO);
        if (min < 0) {
            perror("sched_get_priority_min");
        } else {
            printf("Min priority for SCHED_FIFO: %d\n", min);
        }

  * **优先级分配策略** ：在设计系统时，应避免使用最小优先级（除非是真正的后台任务），以免任务长时间得不到 CPU 时间。
  * **策略无关性** ：在 openvela 中，通常所有实时策略共享相同的优先级空间，因此最小值也相同。
  * **调试工具** ：使用这些函数可以编写通用的优先级检查工具，验证系统中所有任务的优先级配置是否合理。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## sched_rr_get_interval
    
    
    int sched_rr_get_interval(pid_t pid, struct timespec *interval);

查询使用 SCHED_RR（轮转）调度策略的任务的时间片长度。时间片是 SCHED_RR 策略中，任务在被强制让出 CPU 前可以连续运行的最大时间。

此函数用于了解系统的调度时间粒度，有助于调优实时应用的性能和响应性。

**参数** ：

  * pid 目标任务的 PID。特殊值 0 表示查询调用任务自身的时间片。必须是有效的任务 PID。
  * interval 指向 struct timespec 结构的指针，用于接收时间片长度。函数会填充此结构：
  * tv_sec：秒部分（通常为 0，因为时间片通常小于 1 秒）
  * tv_nsec：纳秒部分（例如 10,000,000 纳秒 = 10 毫秒）


**返回值** ：

  * 成功：返回 0（OK），并在 interval 中填充时间片长度
  * 失败：返回 -1 并设置 errno：
  * ESRCH：指定的任务不存在（PID 无效或任务已终止）
  * EINVAL：pid 为负值
  * EFAULT：interval 指向无效内存（NULL 或不可写）
  * ENOSYS：系统不支持此功能（SCHED_RR 未启用）


**注意** ：

  * **仅适用于 SCHED_RR** ：时间片概念仅对 SCHED_RR 策略有意义。对于 SCHED_FIFO，任务运行直到阻塞或被更高优先级任务抢占，没有时间片限制。
  * **系统级配置** ：时间片长度通常是系统级配置（编译时或启动时设置），不能针对单个任务修改。查询不同任务的时间片通常返回相同的值。
  * **典型值** ：在 openvela 中，默认时间片通常为 10 毫秒（10,000,000 纳秒），但可以通过配置选项调整（如 CONFIG_RR_INTERVAL）。
  * **典型用法** ：  

        
        struct timespec ts;
        if (sched_rr_get_interval(0, &ts) == 0) {
            long ms = ts.tv_sec * 1000 + ts.tv_nsec / 1000000;
            printf("Time slice: %ld ms\n", ms);
        } else {
            perror("sched_rr_get_interval");
        }

  * **性能调优** ：了解时间片长度有助于调优任务设计：
  * 如果任务的关键操作时间接近时间片长度，可能需要优化算法或考虑使用 SCHED_FIFO
  * 如果多个同优先级 SCHED_RR 任务需要公平共享 CPU，应确保它们的工作单元小于时间片
  * **实时性分析** ：时间片是实时系统响应时间分析的重要参数，影响任务的最坏响应时间。
  * **时间片耗尽** ：当 SCHED_RR 任务的时间片耗尽时，任务被移到其优先级队列末尾，时间片重新计数。
  * **调用 sched_yield()** ：对于 SCHED_RR 任务，调用 sched_yield() 会重置时间片计数器。
  * **非 SCHED_RR 任务** ：即使任务当前不是 SCHED_RR 策略，此函数通常也会成功返回系统默认的时间片值，但此值对非 SCHED_RR 任务无实际意义。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## sched_lock
    
    
    void sched_lock(void);

禁止任务调度（抢占）。调用后，当前任务不会被其他同优先级或更高优先级的任务抢占，直到调用 sched_unlock() 恢复调度。支持嵌套调用，每次 sched_lock() 必须对应一次 sched_unlock()。

**参数** ：

无参数。

**返回值** ：

无返回值。

**注意** ：

  * **嵌套支持** ：sched_lock() 维护一个锁计数器，每次调用递增，sched_unlock() 递减。只有计数器归零时才真正恢复调度。
  * **中断不受影响** ：sched_lock() 只禁止任务级抢占，不禁止中断。中断处理程序仍然可以执行。
  * **与关中断的区别** ：
  * sched_lock()：禁止任务切换，中断仍可响应
  * enter_critical_section()：禁止中断，更强的保护但延迟更大
  * **典型用法** ：  

        
        sched_lock();
        // 临界区：不会被其他任务抢占
        update_shared_data();
        sched_lock();  // 嵌套调用
        do_more_work();
        sched_unlock(); // 计数器减 1，仍然锁定
        sched_unlock(); // 计数器归零，恢复调度

  * **SMP 注意** ：在多核系统中，sched_lock() 只保护当前 CPU 上的调度，其他 CPU 上的任务仍可运行。如需跨核保护，应使用自旋锁或其他 SMP 同步机制。
  * **避免长时间持有** ：长时间禁止调度会影响系统实时性，应尽量缩短临界区。


**POSIX 兼容性** ：openvela/NuttX 扩展接口（非 POSIX 标准）。

## sched_unlock
    
    
    void sched_unlock(void);

恢复任务调度（抢占）。递减调度锁计数器，当计数器归零时恢复正常调度。必须与 sched_lock() 配对使用。

**参数** ：

无参数。

**返回值** ：

无返回值。

**注意** ：

  * 每次 sched_unlock() 对应一次 sched_lock()，不能多调用。
  * 计数器归零时，如果有更高优先级的任务就绪，会立即发生任务切换。


**POSIX 兼容性** ：openvela/NuttX 扩展接口（非 POSIX 标准）。

## sched_lockcount
    
    
    int sched_lockcount(void);

查询当前任务的调度锁嵌套计数。返回值表示 sched_lock() 被调用但尚未被 sched_unlock() 匹配的次数。

**参数** ：

无参数。

**返回值** ：

返回当前任务的调度锁计数（非负整数）。0 表示调度未被锁定。

**注意** ：

  * 主要用于调试，验证 sched_lock() / sched_unlock() 是否正确配对。
  * 典型用法：  

        
        int count = sched_lockcount();
        if (count > 0) {
            printf("Scheduler locked, count=%d\n", count);
        }


**POSIX 兼容性** ：openvela/NuttX 扩展接口（非 POSIX 标准）。

# CPU 亲和性

## sched_getcpu
    
    
    int sched_getcpu(void);

获取调用任务当前正在其上运行的 CPU 核心编号。此函数仅在 SMP（对称多处理）系统中有意义，用于查询任务与 CPU 的绑定关系。

在多核系统中，了解任务运行在哪个 CPU 上，有助于性能分析、调试和优化 CPU 亲和性策略。

**参数** ：

无参数。

**返回值** ：

  * 成功：返回当前运行的 CPU 编号（非负整数，从 0 开始编号）
  * 0：第一个 CPU 核心
  * 1：第二个 CPU 核心
  * ...依此类推
  * 失败：返回 -1 并设置 errno（通常不会失败）
  * ENOSYS：系统不支持 SMP（未启用 CONFIG_SMP）


**注意** ：

  * **SMP 系统专用** ：此函数仅在启用 CONFIG_SMP 配置的多核系统中有效。在单核系统中，通常总是返回 0。
  * **瞬时值** ：返回的 CPU 编号是查询时的瞬时值。在抢占式多任务系统中，任务可能在函数返回后立即被迁移到其他 CPU。
  * **典型用法** ：  

        
        int cpu = sched_getcpu();
        if (cpu >= 0) {
            printf("Running on CPU %d\n", cpu);
        } else {
            perror("sched_getcpu");
        }

  * **性能分析** ：在性能分析工具中，记录任务运行的 CPU 有助于分析 CPU 负载分布和任务迁移频率。
  * **调试工具** ：在调试 CPU 亲和性问题时，可以定期查询 CPU 编号，验证任务是否运行在预期的 CPU 上。
  * **配合亲和性** ：通常与 sched_setaffinity() 和 sched_getaffinity() 配合使用：  

        
        cpu_set_t set;
        CPU_ZERO(&set);
        CPU_SET(2, &set);  // 绑定到 CPU 2
        sched_setaffinity(0, sizeof(set), &set);
          
        int cpu = sched_getcpu();
        assert(cpu == 2);  // 验证绑定成功

  * **不可靠用于同步** ：不应依赖此函数实现同步机制，因为返回值可能在使用前失效。
  * **NUMA 系统** ：在 NUMA（非统一内存访问）架构中，了解任务运行的 CPU 有助于优化内存访问模式，减少跨节点内存访问。
  * **热点分析** ：如果多个任务频繁运行在同一 CPU，可能表明负载不均衡，需要调整亲和性或优先级。
  * **中断上下文** ：此函数也可以在中断处理程序中调用，查询中断在哪个 CPU 上被处理。
  * **与线程绑定** ：在多线程应用中，可以将不同线程绑定到不同 CPU，然后用此函数验证绑定效果。


**POSIX 兼容性** ：兼容 Linux 扩展接口（非 POSIX 标准，但广泛支持）。

## sched_setaffinity
    
    
    int sched_setaffinity(pid_t pid, size_t cpusetsize, const cpu_set_t *mask);

设置任务的 CPU 亲和性掩码（affinity mask），指定任务允许运行的 CPU 核心集合。此功能仅在 SMP（对称多处理）系统中有效，需要启用 CONFIG_SMP 配置。

CPU 亲和性允许将任务绑定到特定的 CPU 核心，这在优化缓存局部性、减少上下文切换开销、隔离关键任务等场景中非常有用。

**参数** ：

  * pid 目标任务的 PID。特殊值 0 表示设置调用任务自身的亲和性。必须是有效的任务 PID。
  * cpusetsize mask 指向的 CPU 集合的大小（字节）。通常使用 sizeof(cpu_set_t)。此参数允许未来扩展支持更多 CPU。
  * mask 指向 CPU 亲和性掩码的指针（cpu_set_t 类型）。位图中每一位对应一个 CPU：
  * 位为 1：任务允许在该 CPU 上运行
  * 位为 0：任务不允许在该 CPU 上运行  
使用 CPU_ZERO()、CPU_SET()、CPU_CLR() 等宏操作此掩码


**返回值** ：

  * 成功：返回 0（OK）
  * 失败：返回 -1 并设置 errno：
  * ESRCH：指定的任务不存在（PID 无效或任务已终止）
  * EINVAL：mask 指定的 CPU 集合无效（例如全为 0，或包含不存在的 CPU）
  * EFAULT：mask 指向无效内存（NULL 或不可读）
  * EPERM：调用者没有权限修改目标任务的亲和性（通常需要超级用户权限或同一用户）
  * ENOSYS：系统不支持 SMP（未启用 CONFIG_SMP）


**注意** ：

  * **SMP 系统专用** ：此函数仅在多核系统（CONFIG_SMP 启用）中有效。单核系统通常返回 ENOSYS。
  * **立即生效** ：亲和性修改立即生效。如果任务当前运行在不在新掩码中的 CPU 上，调度器会立即将其迁移到允许的 CPU 之一。
  * **典型用法** ：  

        
        cpu_set_t set;
        CPU_ZERO(&set);           // 清空掩码
        CPU_SET(0, &set);         // 允许 CPU 0
        CPU_SET(1, &set);         // 允许 CPU 1
          
        if (sched_setaffinity(0, sizeof(set), &set) == 0) {
            printf("Affinity set to CPU 0 and 1\n");
        } else {
            perror("sched_setaffinity");
        }

  * **绑定到单个 CPU** ：  

        
        cpu_set_t set;
        CPU_ZERO(&set);
        CPU_SET(2, &set);  // 只允许 CPU 2
        sched_setaffinity(0, sizeof(set), &set);

  * **性能优化** ：
  * **缓存局部性** ：将任务绑定到特定 CPU 可以提高缓存命中率，减少缓存失效
  * **减少迁移开销** ：避免任务在 CPU 间频繁迁移，降低上下文切换成本
  * **负载隔离** ：将关键实时任务绑定到专用 CPU，避免其他任务干扰
  * **NUMA 系统** ：在 NUMA 架构中，应将任务绑定到靠近其访问内存的 CPU，减少跨节点内存访问延迟。
  * **权限要求** ：修改其他任务的亲和性通常需要特权。在嵌入式系统中，这一限制可能较宽松。
  * **子任务继承** ：子任务（通过 fork() 或 task_create() 创建）通常继承父任务的 CPU 亲和性。
  * **配合使用** ：通常与 sched_getaffinity() 配合，先查询当前亲和性，修改后设置回去：  

        
        cpu_set_t set;
        sched_getaffinity(0, sizeof(set), &set);
        CPU_CLR(3, &set);  // 移除 CPU 3
        sched_setaffinity(0, sizeof(set), &set);

  * **验证设置** ：设置后可以用 sched_getcpu() 验证任务是否运行在预期的 CPU 上。
  * **陷阱** ：
  * 如果 mask 全为 0（不允许任何 CPU），会返回 EINVAL
  * 如果指定的 CPU 超出系统范围（如系统只有 4 核，但设置了 CPU 5），会返回 EINVAL
  * 过度绑定可能导致负载不均衡，某些 CPU 过载而其他 CPU 空闲
  * **动态调整** ：在运行时根据系统负载动态调整亲和性，可以实现灵活的负载均衡策略。


**POSIX 兼容性** ：兼容 Linux 扩展接口（非 POSIX 标准，但广泛支持）。

## sched_getaffinity
    
    
    int sched_getaffinity(pid_t pid, size_t cpusetsize, cpu_set_t *mask);

查询任务的 CPU 亲和性掩码（affinity mask），获取任务允许运行的 CPU 核心集合。此功能仅在 SMP（对称多处理）系统中有效，需要启用 CONFIG_SMP 配置。

通过查询 CPU 亲和性，可以了解任务的 CPU 绑定策略，用于监控、调试和动态调整亲和性。

**参数** ：

  * pid 目标任务的 PID。特殊值 0 表示查询调用任务自身的亲和性。必须是有效的任务 PID。
  * cpusetsize mask 指向的 CPU 集合的大小（字节）。通常使用 sizeof(cpu_set_t)。
  * mask 指向 CPU 亲和性掩码的指针，用于接收查询结果。函数会填充此 cpu_set_t 结构，其中：
  * 位为 1：任务允许在该 CPU 上运行
  * 位为 0：任务不允许在该 CPU 上运行


**返回值** ：

  * 成功：返回 0（OK），并在 mask 中填充任务的 CPU 亲和性掩码
  * 失败：返回 -1 并设置 errno：
  * ESRCH：指定的任务不存在（PID 无效或任务已终止）
  * EINVAL：cpusetsize 过小，无法容纳系统的 CPU 数量
  * EFAULT：mask 指向无效内存（NULL 或不可写）
  * ENOSYS：系统不支持 SMP（未启用 CONFIG_SMP）


**注意** ：

  * **SMP 系统专用** ：此函数仅在多核系统（CONFIG_SMP 启用）中有效。单核系统通常返回 ENOSYS。
  * **只读查询** ：此函数不修改任务状态，是纯查询操作，开销很小。
  * **典型用法** ：  

        
        cpu_set_t set;
        if (sched_getaffinity(0, sizeof(set), &set) == 0) {
            printf("Task can run on CPUs: ");
            for (int i = 0; i < CPU_SETSIZE; i++) {
                if (CPU_ISSET(i, &set)) {
                    printf("%d ", i);
                }
            }
            printf("\n");
        } else {
            perror("sched_getaffinity");
        }

  * **检查特定 CPU** ：  

        
        cpu_set_t set;
        sched_getaffinity(0, sizeof(set), &set);
        if (CPU_ISSET(2, &set)) {
            printf("Task can run on CPU 2\n");
        }

  * **修改前查询** ：在修改亲和性前，通常先查询当前亲和性，然后基于当前值进行修改：  

        
        cpu_set_t set;
        sched_getaffinity(0, sizeof(set), &set);
        CPU_CLR(1, &set);  // 移除 CPU 1
        sched_setaffinity(0, sizeof(set), &set);

  * **监控工具** ：系统监控工具常用此函数显示任务的 CPU 绑定情况，帮助分析负载分布。
  * **调试亲和性问题** ：如果任务性能异常，可以查询亲和性，检查是否被意外绑定到负载过重的 CPU。
  * **统计 CPU 数量** ：  

        
        cpu_set_t set;
        sched_getaffinity(0, sizeof(set), &set);
        int count = CPU_COUNT(&set);
        printf("Task can run on %d CPUs\n", count);

  * **默认亲和性** ：新创建的任务默认可以运行在所有 CPU 上（除非父任务有限制）。查询时会看到所有 CPU 位都为 1。
  * **CPU_SETSIZE 常量** ：CPU_SETSIZE 定义了 cpu_set_t 支持的最大 CPU 数量（通常为 1024），但实际系统 CPU 数量可能更少。
  * **CPU 集合操作宏** ：
  * CPU_ZERO(&set)：清空集合
  * CPU_SET(cpu, &set)：添加 CPU
  * CPU_CLR(cpu, &set)：移除 CPU
  * CPU_ISSET(cpu, &set)：检查 CPU 是否在集合中
  * CPU_COUNT(&set)：统计集合中的 CPU 数量
  * CPU_EQUAL(&set1, &set2)：比较两个集合是否相等
  * **可移植性** ：不同系统的 cpu_set_t 大小可能不同，始终使用 sizeof(cpu_set_t) 而不是硬编码大小。
  * **与 getcpu 配合** ：  

        
        int cpu = sched_getcpu();
        cpu_set_t set;
        sched_getaffinity(0, sizeof(set), &set);
        assert(CPU_ISSET(cpu, &set));  // 当前 CPU 应该在亲和性集合中


**POSIX 兼容性** ：兼容 Linux 扩展接口（非 POSIX 标准，但广泛支持）。

## sched_cpucount
    
    
    int sched_cpucount(const cpu_set_t *set);

统计 CPU 集合中包含的 CPU 数量。等价于 Linux 的 CPU_COUNT() 宏。

**参数** ：

  * set 指向 CPU 集合。


**返回值** ：

返回集合中被设置的 CPU 数量。

**注意** ：

  * 在非 SMP 系统中，宏定义为始终返回 1。
  * 典型用法：  

        
        cpu_set_t set;
        sched_getaffinity(0, sizeof(set), &set);
        printf("Can run on %d CPUs\n", sched_cpucount(&set));


**POSIX 兼容性** ：兼容 Linux 扩展接口（非 POSIX 标准）。

# 调试与诊断

## sched_backtrace
    
    
    int sched_backtrace(pid_t tid, void **buffer, int size, int skip);

获取指定任务的调用栈回溯信息。将栈帧地址存入 buffer 数组，用于调试和崩溃分析。

**参数** ：

  * tid 目标任务的 PID。0 表示当前任务。
  * buffer 指向指针数组，用于存储栈帧地址。
  * size buffer 数组的最大容量（元素个数）。
  * skip 跳过的栈帧数（从栈顶开始），用于过滤调试框架本身的栈帧。


**返回值** ：

返回实际获取的栈帧数（非负整数）。如果返回值等于 size，可能还有更多栈帧未获取。

**注意** ：

  * 需要启用 CONFIG_SCHED_BACKTRACE 配置。未启用时，宏定义为返回 0。
  * 获取其他任务的调用栈时，目标任务应处于阻塞状态，否则结果可能不准确。


**POSIX 兼容性** ：openvela/NuttX 扩展接口（非 POSIX 标准）。

## sched_dumpstack
    
    
    void sched_dumpstack(pid_t tid);

打印指定任务的调用栈到系统日志。内部调用 sched_backtrace() 获取栈帧，然后格式化输出。

**参数** ：

  * tid 目标任务的 PID。0 表示当前任务。


**返回值** ：

无返回值。

**注意** ：

  * 主要用于调试和崩溃分析，输出到系统日志（syslog）。
  * 需要启用 CONFIG_SCHED_BACKTRACE 配置。


**POSIX 兼容性** ：openvela/NuttX 扩展接口（非 POSIX 标准）。

---

## 内存管理 API

> 路径: 内核接口 > 内存管理 API
> 来源: [https://doc.openvela.com/document?id=1109&language=cn&version=dev](https://doc.openvela.com/document?id=1109&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/kernel/mem.md>) | 简体中文 ]

# 内存管理 API

openvela 提供灵活的内存管理系统，支持标准 POSIX 内存分配接口以及扩展的内存管理功能。

头文件：#include <stdlib.h>（标准分配）、#include <nuttx/mm/mm.h>（内核堆/堆管理）

# openvela 实现说明

  * **构建模式影响** ：
  * **Flat Build** ：只有一个用户堆，malloc/free 直接操作
  * **Protected Build** ：内核堆 + 用户堆，通过 MPU 保护隔离
  * **Kernel Build** ：内核堆 + 多个用户堆（每个任务组一个）
  * **对齐保证** ：malloc() 返回的内存按 MM_ALIGN（默认 8 或 16 字节）对齐
  * **线程安全** ：所有标准分配接口（malloc/free/calloc 等）在多任务环境中是线程安全的
  * **延迟释放** ：*_delayfree() 系列接口用于中断上下文中无法立即释放内存的场景
  * **已知不兼容** ：posix_memalign() 当前不检查 alignment 参数有效性，不返回 EINVAL


# 标准内存分配

## malloc
    
    
    void *malloc(size_t size);

从用户堆中分配指定大小的内存块。malloc() 会在堆中查找一个足够大的空闲块，从中分配所需的内存。如果 size 为 0，行为取决于实现，可能返回 NULL 或返回一个唯一的指针。

分配的内存保证按照 MM_ALIGN（默认为 2 * sizeof(uintptr_t)，即 8 或 16 字节）对齐，这确保了对任何基本数据类型的访问都是对齐的。

**参数** ：

  * size 要分配的内存大小（字节）。


**返回值** ：

成功时返回指向分配内存的指针，失败时返回 NULL 并设置 errno：

  * ENOMEM 可用内存不足。


**注意** ：

  * 分配的内存内容是未初始化的，可能包含任意数据。
  * 返回的指针可以传递给 free()、realloc() 等函数。
  * 在多任务环境中，malloc() 是线程安全的。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## free
    
    
    void free(void *ptr);

释放之前通过 malloc()、calloc()、realloc()、memalign() 等分配的内存块，使其可供后续分配使用。

如果 ptr 为 NULL，则不执行任何操作。如果 ptr 不是之前分配函数返回的指针，或者已经被释放过，则行为是未定义的。

**参数** ：

  * ptr 指向要释放的内存块的指针。


**返回值** ：

无返回值。

**注意** ：

  * 释放后的指针不应再被使用（悬空指针）。
  * 不要重复释放同一块内存（双重释放会导致堆损坏）。
  * 不要释放非动态分配的内存（如栈上的变量或全局变量）。
  * 释放内存后，该内存可能不会立即返回给系统，而是保留在堆中供后续分配使用。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## calloc
    
    
    void *calloc(size_t n, size_t elem_size);

分配一个包含 n 个元素的数组，每个元素大小为 elem_size 字节，总共分配 n * elem_size 字节的内存，并将所有字节初始化为零。

与 malloc() 相比，calloc() 有两个优点：它会将内存清零，并且在计算总大小时可以检测乘法溢出（取决于实现）。

**参数** ：

  * n 要分配的元素数量。
  * elem_size 每个元素的大小（字节）。


**返回值** ：

成功时返回指向分配并清零的内存的指针，失败时返回 NULL 并设置 errno：

  * ENOMEM 可用内存不足。


**注意** ：

  * 如果 n 或 elem_size 为 0，可能返回 NULL 或返回一个唯一的指针。
  * 返回的内存所有字节都被设置为 0。
  * 对于需要零初始化的数据结构，推荐使用 calloc() 而不是 malloc() \+ memset()。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## realloc
    
    
    void *realloc(void *ptr, size_t size);

改变之前分配的内存块的大小。realloc() 可能会在原位置扩展或收缩内存块，也可能分配一个新的内存块并复制原有数据。

如果 ptr 为 NULL，则 realloc() 的行为等同于 malloc(size)。如果 size 为 0 且 ptr 不为 NULL，则行为等同于 free(ptr) 并返回 NULL。

**参数** ：

  * ptr 指向之前分配的内存块的指针。如果为 NULL，则等同于 malloc(size)。
  * size 新的内存大小（字节）。如果为 0，则释放内存并返回 NULL。


**返回值** ：

成功时返回指向重新分配内存的指针（可能与原指针不同），失败时返回 NULL 并设置 errno：

  * ENOMEM 可用内存不足。此时原内存块保持不变，仍然有效。


**注意** ：

  * 如果新大小大于原大小，新增部分的内容是未初始化的。
  * 如果新大小小于原大小，超出部分的数据会丢失。
  * 返回的指针可能与原指针不同，成功调用后原指针不应再使用。
  * 如果 realloc() 失败，原内存块不会被释放，调用者仍需负责释放它。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## reallocarray
    
    
    void *reallocarray(void *ptr, size_t n, size_t elem_size);

改变之前分配的内存块的大小为 n * elem_size 字节。与 realloc() 不同的是，reallocarray() 会安全地检查乘法溢出，防止整数溢出导致的安全问题。

这个函数特别适用于重新分配数组，因为直接使用 realloc(ptr, n * elem_size) 可能会因为乘法溢出而分配一个比预期小得多的内存块。

**参数** ：

  * ptr 指向之前分配的内存块的指针。如果为 NULL，则等同于分配新内存。
  * n 元素数量。
  * elem_size 每个元素的大小（字节）。


**返回值** ：

成功时返回指向重新分配内存的指针，失败时返回 NULL 并设置 errno：

  * ENOMEM 可用内存不足，或者 n * elem_size 溢出。


**注意** ：

  * 如果 n * elem_size 会导致整数溢出，函数会安全地返回 NULL。
  * 与 realloc() 相同，失败时原内存块保持不变。


**POSIX 兼容性** ：兼容 BSD/glibc 扩展接口。

## zalloc
    
    
    void *zalloc(size_t size);

分配指定大小的内存块并将所有字节初始化为零。这是 openvela 提供的便捷函数，功能等同于 calloc(1, size)，但语义更清晰。

**参数** ：

  * size 要分配的内存大小（字节）。


**返回值** ：

成功时返回指向分配并清零的内存的指针，失败时返回 NULL 并设置 errno：

  * ENOMEM 可用内存不足。


**注意** ：

  * 与 malloc() 不同，返回的内存已被清零。
  * 与 calloc(1, size) 功能相同，但调用更简洁。


**POSIX 兼容性** ：openvela 扩展接口。

* * *

以下接口用于查询堆的使用情况和内存分配统计信息，对于调试和监控内存使用非常有用。

# 对齐内存分配

## memalign
    
    
    void *memalign(size_t alignment, size_t size);

分配按指定边界对齐的内存。这对于需要特定对齐要求的硬件访问（如 DMA 缓冲区）或 SIMD 操作非常有用。

**参数** ：

  * alignment 对齐边界，必须是 2 的幂次方（如 16、32、64、4096 等）。
  * size 要分配的内存大小（字节）。


**返回值** ：

成功时返回按指定边界对齐的内存指针，失败时返回 NULL 并设置 errno：

  * ENOMEM 可用内存不足。
  * EINVAL alignment 不是 2 的幂次方。


**注意** ：

  * 分配的内存可以使用 free() 正常释放。
  * 对于需要页对齐的内存，可以使用 valloc() 或 posix_memalign()。


**POSIX 兼容性** ：兼容 POSIX 同名接口（已过时，推荐使用 posix_memalign()）。

## posix_memalign
    
    
    int posix_memalign(void **memptr, size_t alignment, size_t size);

分配按指定边界对齐的内存，并将指针存储在 memptr 中。这是 memalign() 的 POSIX 标准替代接口。

与 memalign() 的主要区别是：posix_memalign() 通过返回值报告错误，而不是设置 errno，这使得错误处理更加明确。

**参数** ：

  * memptr 存储分配内存指针的地址。成功时，*memptr 会被设置为分配的内存地址。
  * alignment 对齐边界，必须是 sizeof(void *) 的倍数，且是 2 的幂次方。
  * size 要分配的内存大小（字节）。


**返回值** ：

  * 0 成功，*memptr 指向分配的内存。
  * ENOMEM 可用内存不足。


**注意** ：

  * 与 memalign() 不同，错误通过返回值报告，而不是 errno。
  * 分配的内存可以使用 free() 正常释放。
  * openvela 当前实现不检查 alignment 参数的有效性，不返回 EINVAL（POSIX 标准要求在参数无效时返回 EINVAL）。


**POSIX 兼容性** ：部分兼容 POSIX 同名接口（不返回 EINVAL）。

## aligned_alloc
    
    
    void *aligned_alloc(size_t alignment, size_t size);

分配按指定边界对齐的内存。这是 C11 标准引入的对齐内存分配函数。

**参数** ：

  * alignment 对齐边界，必须是 2 的幂次方。
  * size 要分配的内存大小（字节）。C11 标准要求 size 应该是 alignment 的倍数，但许多实现不强制此要求。


**返回值** ：

成功时返回按指定边界对齐的内存指针，失败时返回 NULL。

**注意** ：

  * 分配的内存可以使用 free() 正常释放。
  * 此函数是 C11 标准的一部分，比 memalign() 更具可移植性。


**POSIX 兼容性** ：兼容 C11 标准接口。

## valloc
    
    
    void *valloc(size_t size);

分配按页边界对齐的内存。页大小由系统决定，通常为 4096 字节。

此函数等效于 memalign(sysconf(_SC_PAGESIZE), size)。

**参数** ：

  * size 要分配的内存大小（字节）。


**返回值** ：

成功时返回按页边界对齐的内存指针，失败时返回 NULL。

**注意** ：

  * 页大小可以通过 sysconf(_SC_PAGESIZE) 获取。
  * 分配的内存可以使用 free() 正常释放。
  * 此函数已过时，新代码应使用 posix_memalign() 替代。


**POSIX 兼容性** ：兼容 BSD 扩展接口（已过时，推荐使用 posix_memalign()）。

# 内存信息查询

## mallinfo
    
    
    struct mallinfo mallinfo(void);

获取用户堆的内存分配统计信息。这对于监控应用程序的内存使用情况、检测内存泄漏和优化内存使用非常有用。

**参数** ：

无参数。

**返回值** ：

返回 struct mallinfo 结构体，包含以下字段：

  * arena 堆分配的总内存大小（字节），即堆管理的内存总量。
  * ordblks 空闲块的数量。
  * aordblks 已分配块的数量。
  * mxordblk 最大空闲块的大小（字节），表示单次分配可用的最大内存。
  * uordblks 已分配内存的总大小（字节）。
  * fordblks 空闲内存的总大小（字节）。
  * usmblks 曾经分配的最大内存量（高水位线）。


**注意** ：

  * uordblks + fordblks 应该接近 arena（可能略小，因为有堆管理开销）。
  * mxordblk 表示当前可以成功分配的最大内存块大小。


**POSIX 兼容性** ：兼容 glibc 扩展接口。

## mallinfo_task
    
    
    struct mallinfo_task mallinfo_task(FAR const struct malltask *task);

获取指定任务或特定类型的内存分配信息。这是 openvela 提供的扩展接口，可以用于追踪每个任务的内存使用情况，帮助定位内存泄漏。

**参数** ：

  * task 指向 struct malltask 结构体的指针，包含：
  * pid 进程 ID。可以是具体的进程 ID，也可以是以下特殊值：
    * PID_MM_MEMPOOL（-1）：查询内存池分配。
    * PID_MM_LEAK（-2）：查询可能的内存泄漏（分配者已退出）。
    * PID_MM_ALLOC（-3）：查询所有已分配的内存。
    * PID_MM_FREE（-4）：查询空闲内存。
    * PID_MM_BIGGEST（-5）：查询最大内存块。
    * PID_MM_ORPHAN（-6）：查询孤立内存块。
  * seqmin 最小序列号（需要配置 CONFIG_MM_RECORD_SEQNO）。
  * seqmax 最大序列号（需要配置 CONFIG_MM_RECORD_SEQNO）。


**返回值** ：

返回 struct mallinfo_task 结构体，包含：

  * aordblks 该任务已分配块的数量。
  * uordblks 该任务已分配内存的总大小（字节）。


**注意** ：

  * 使用 PID_MM_LEAK 可以快速发现已退出任务遗留的内存块，这些很可能是内存泄漏。
  * 序列号功能需要启用 CONFIG_MM_RECORD_SEQNO，可以用于追踪特定时间段内的分配。


**POSIX 兼容性** ：openvela 扩展接口。

## malloc_size
    
    
    size_t malloc_size(void *ptr);

获取之前分配的内存块的实际可用大小。由于内存对齐和堆管理的需要，实际分配的内存可能比请求的大小更大。

**参数** ：

  * ptr 指向之前分配的内存块的指针。


**返回值** ：

返回内存块的实际可用大小（字节）。这个值通常大于或等于分配时请求的大小。

**注意** ：

  * 也可以使用别名 malloc_usable_size()（与 glibc 兼容）。
  * 可以安全地使用返回值范围内的所有内存。
  * 如果 ptr 不是有效的分配指针，行为是未定义的。


**POSIX 兼容性** ：兼容 glibc/macOS 扩展接口。

## mallopt
    
    
    int mallopt(int param, int value);

调整内存分配器的参数。此函数提供了一种控制内存分配器行为的方式。

**参数** ：

  * param 要调整的参数，定义的选项包括：
  * M_TRIM_THRESHOLD 收缩阈值
  * M_TOP_PAD 顶部填充
  * M_MMAP_THRESHOLD mmap 阈值
  * M_MMAP_MAX 最大 mmap 数量
  * M_CHECK_ACTION 检查动作
  * M_PERTURB 内存扰动
  * M_ARENA_TEST arena 测试
  * M_ARENA_MAX 最大 arena 数量
  * value 参数值。


**返回值** ：

成功返回非零值，失败返回 0。

**注意** ：

  * openvela 当前实现总是返回 1（成功），不实际处理任何参数。
  * 此接口仅为兼容性目的提供。


**POSIX 兼容性** ：兼容 glibc 扩展接口（仅接口兼容，无实际功能）。

* * *

# 内核堆接口

## kmm_initialize
    
    
    void kmm_initialize(void *heap_start, size_t heap_size);

初始化内核堆。此函数通常在系统启动早期由板级初始化代码调用。

**参数** ：

  * heap_start 内核堆内存的起始地址。
  * heap_size 内核堆的大小（字节）。


**返回值** ：

无返回值。

**注意** ：

  * 此函数只应调用一次，重复调用会导致未定义行为。
  * 需要启用 CONFIG_MM_KERNEL_HEAP 配置。


## kmm_malloc
    
    
    void *kmm_malloc(size_t size);

从内核堆分配内存。功能与 malloc() 相同，但从内核堆而非用户堆分配。

**参数** ：

  * size 要分配的内存大小（字节）。


**返回值** ：

成功时返回指向分配内存的指针，失败时返回 NULL。

**注意** ：

  * 分配的内存只能使用 kmm_free() 释放。
  * 内核堆分配的内存不应传递给用户态代码。


## kmm_free
    
    
    void kmm_free(void *mem);

释放之前通过 kmm_malloc()、kmm_calloc() 等从内核堆分配的内存。

**参数** ：

  * mem 指向要释放的内存块的指针。如果为 NULL，则不执行任何操作。


**返回值** ：

无返回值。

**注意** ：

  * 只能释放内核堆分配的内存，不能用于释放用户堆内存。
  * 可以使用 kmm_heapmember() 检查指针是否属于内核堆。


## kmm_calloc
    
    
    void *kmm_calloc(size_t n, size_t elem_size);

从内核堆分配内存并清零。功能与 calloc() 相同，但从内核堆分配。

**参数** ：

  * n 要分配的元素数量。
  * elem_size 每个元素的大小（字节）。


**返回值** ：

成功时返回指向分配并清零的内存的指针，失败时返回 NULL。

## kmm_realloc
    
    
    void *kmm_realloc(void *oldmem, size_t newsize);

重新分配内核堆内存。功能与 realloc() 相同，但在内核堆上操作。

**参数** ：

  * oldmem 指向之前从内核堆分配的内存块的指针。如果为 NULL，则等同于 kmm_malloc(newsize)。
  * newsize 新的内存大小（字节）。如果为 0，则释放内存。


**返回值** ：

成功时返回指向重新分配内存的指针（可能与原指针不同），失败时返回 NULL（原内存块保持不变）。

## kmm_zalloc
    
    
    void *kmm_zalloc(size_t size);

从内核堆分配内存并清零。功能与 zalloc() 相同，但从内核堆分配。

**参数** ：

  * size 要分配的内存大小（字节）。


**返回值** ：

成功时返回指向分配并清零的内存的指针，失败时返回 NULL。

## kmm_memalign
    
    
    void *kmm_memalign(size_t alignment, size_t size);

从内核堆分配对齐内存。功能与 memalign() 相同，但从内核堆分配。

**参数** ：

  * alignment 对齐边界，必须是 2 的幂次方。
  * size 要分配的内存大小（字节）。


**返回值** ：

成功时返回按指定边界对齐的内存指针，失败时返回 NULL。

**注意** ：

  * 用于内核需要对齐内存的场景，如 DMA 缓冲区。


## kmm_malloc_size
    
    
    size_t kmm_malloc_size(void *mem);

获取内核堆中已分配内存块的实际可用大小。

**参数** ：

  * mem 指向内核堆中已分配的内存块。


**返回值** ：

返回内存块的实际可用大小（字节）。

**POSIX 兼容性** ：openvela/NuttX 扩展接口。

## kmm_mallinfo
    
    
    struct mallinfo kmm_mallinfo(void);

获取内核堆的分配信息。功能与 mallinfo() 相同，但返回内核堆的统计信息。

**参数** ：

无参数。

**返回值** ：

返回 struct mallinfo 结构体，包含内核堆的内存分配统计信息：

  * arena 内核堆的总大小（字节）。
  * ordblks 空闲块的数量。
  * uordblks 已使用的内存大小（字节）。
  * fordblks 空闲内存大小（字节）。
  * mxordblk 最大连续空闲块大小（字节）。


**注意** ：

  * 可用于监控内核内存使用情况。


## kmm_heapmember
    
    
    bool kmm_heapmember(void *mem);

检查内存地址是否属于内核堆。

**参数** ：

  * mem 要检查的内存地址。


**返回值** ：

如果内存地址属于内核堆，返回 true；否则返回 false。

**注意** ：

  * 可用于确定内存块应该使用 kmm_free() 还是 free() 释放。
  * 在内存管理代码中用于路由释放请求到正确的堆。


## kmm_addregion
    
    
    void kmm_addregion(void *heapstart, size_t heapsize);

向内核堆添加一个新的内存区域。允许内核堆使用非连续的内存区域。

**参数** ：

  * heapstart 新内存区域的起始地址。
  * heapsize 新内存区域的大小（字节）。


**返回值** ：

无返回值。

**注意** ：

  * 需要启用 CONFIG_MM_KERNEL_HEAP。
  * 最大区域数量由 CONFIG_MM_REGIONS 配置。


**POSIX 兼容性** ：openvela/NuttX 扩展接口。

## kmm_extend
    
    
    void kmm_extend(void *mem, size_t size, int region);

扩展内核堆的指定内存区域。新增内存必须与现有区域在物理地址上相邻。

**参数** ：

  * mem 新增内存的起始地址。
  * size 新增内存的大小（字节）。
  * region 区域索引（从 0 开始）。


**返回值** ：

无返回值。

**POSIX 兼容性** ：openvela/NuttX 扩展接口。

## kmm_delayfree
    
    
    void kmm_delayfree(void *mem);

延迟释放内核堆内存。将释放操作推迟到安全的时机执行，适用于中断上下文或持有自旋锁时无法立即释放内存的场景。

**参数** ：

  * mem 指向要释放的内核堆内存。


**返回值** ：

无返回值。

**注意** ：

  * 在中断处理程序中释放内存时应使用此函数，而非 kmm_free()。


**POSIX 兼容性** ：openvela/NuttX 扩展接口。

## kmm_memdump
    
    
    void kmm_memdump(const struct mm_memdump_s *dump);

转储内核堆的内存分配信息到系统日志，用于调试内存泄漏。

**参数** ：

  * dump 指向转储条件结构体，指定过滤条件（PID、序列号范围等）。


**返回值** ：

无返回值。

**注意** ：

  * 需要启用 CONFIG_MM_BACKTRACE 以获取分配调用栈信息。


**POSIX 兼容性** ：openvela/NuttX 扩展接口。

## kmm_checkcorruption
    
    
    void kmm_checkcorruption(void);

检查内核堆是否存在内存损坏。

**参数** ：

无参数。

**返回值** ：

无返回值。如果检测到内存损坏，将触发断言或输出调试信息。

**注意** ：

  * 需要启用 CONFIG_MM_HEAP_CHECK 配置。
  * 用于调试内存相关问题。


* * *

# 堆管理接口

## mm_initialize
    
    
    struct mm_heap_s *mm_initialize(const char *name, void *heapstart, size_t heapsize);

初始化一个新的堆。分配并初始化堆管理结构，设置初始空闲块。

**参数** ：

  * name 堆的名称，用于调试和识别。
  * heapstart 堆内存的起始地址。
  * heapsize 堆的大小（字节）。


**返回值** ：

成功时返回指向初始化的堆结构的指针，失败时返回 NULL。

**注意** ：

  * 堆大小必须足够大以容纳堆管理开销。
  * 系统可以有多个独立的堆，如用户堆、内核堆、图形堆等。


## mm_uninitialize
    
    
    void mm_uninitialize(struct mm_heap_s *heap);

销毁一个堆，释放堆管理结构占用的资源。

**参数** ：

  * heap 要销毁的堆结构指针。


**返回值** ：

无返回值。

**注意** ：

  * 销毁前应确保堆中没有活动的分配。


## mm_addregion
    
    
    void mm_addregion(struct mm_heap_s *heap, void *heapstart, size_t heapsize);

向现有堆添加一个新的内存区域。这允许堆使用非连续的内存区域。

**参数** ：

  * heap 堆结构指针。
  * heapstart 新内存区域的起始地址。
  * heapsize 新内存区域的大小（字节）。


**返回值** ：

无返回值。

**注意** ：

  * 新增区域可以在物理上与已有区域不连续。
  * 最大区域数量由 CONFIG_MM_REGIONS 配置。


## mm_extend
    
    
    void mm_extend(struct mm_heap_s *heap, void *mem, size_t size, int region);

扩展堆的指定内存区域。新增内存必须与现有区域相邻。

**参数** ：

  * heap 堆结构指针。
  * mem 新增内存区域的起始地址。
  * size 新增内存区域的大小（字节）。
  * region 区域索引（从 0 开始）。


**返回值** ：

无返回值。

**注意** ：

  * 新增的内存区域必须与现有区域在物理地址上相邻。
  * 与 mm_addregion() 不同，此函数用于扩展已有区域而非添加新区域。


## mm_brkaddr
    
    
    void *mm_brkaddr(struct mm_heap_s *heap, int region);

获取堆指定区域的当前 break 地址（区域末尾地址）。

**参数** ：

  * heap 堆结构指针。
  * region 区域索引（从 0 开始）。


**返回值** ：

返回指定区域的当前 break 地址。

**注意** ：

  * 用于确定可以扩展的内存位置。


## mm_sbrk
    
    
    int mm_sbrk(struct mm_heap_s *heap, intptr_t incr, void **mem);

扩展或收缩堆的 break 地址（类似 UNIX sbrk 语义）。

**参数** ：

  * heap 堆结构指针。
  * incr 增量（正值扩展，负值收缩）。
  * mem 输出参数，返回之前的 break 地址。


**返回值** ：

成功返回 0，失败返回 -1。

**POSIX 兼容性** ：openvela/NuttX 扩展接口。

## mm_heapmember
    
    
    bool mm_heapmember(struct mm_heap_s *heap, void *mem);

检查内存地址是否属于指定堆的任意区域。

**参数** ：

  * heap 堆结构指针。
  * mem 要检查的内存地址。


**返回值** ：

如果内存地址属于指定堆，返回 true；否则返回 false。

**注意** ：

  * 用于确定内存分配来源，以便使用正确的接口释放。


## mm_free
    
    
    void mm_free(struct mm_heap_s *heap, void *mem);

从指定堆释放内存。这是底层堆释放接口，free() 和 kmm_free() 内部调用此函数。

**参数** ：

  * heap 堆结构指针。
  * mem 指向要释放的内存块。


**返回值** ：

无返回值。

**POSIX 兼容性** ：openvela/NuttX 扩展接口。

## mm_malloc_size
    
    
    size_t mm_malloc_size(struct mm_heap_s *heap, void *mem);

获取指定堆中已分配内存块的实际可用大小。

**参数** ：

  * heap 堆结构指针。
  * mem 指向已分配的内存块。


**返回值** ：

返回内存块的实际可用大小（字节）。

**POSIX 兼容性** ：openvela/NuttX 扩展接口。

## mm_delayfree
    
    
    void mm_delayfree(struct mm_heap_s *heap, void *mem);

延迟释放指定堆的内存。适用于中断上下文或持有自旋锁时无法立即释放的场景。

**参数** ：

  * heap 堆结构指针。
  * mem 指向要释放的内存块。


**返回值** ：

无返回值。

**POSIX 兼容性** ：openvela/NuttX 扩展接口。

## mm_heapfree
    
    
    size_t mm_heapfree(struct mm_heap_s *heap);

查询指定堆的空闲内存总量。

**参数** ：

  * heap 堆结构指针。


**返回值** ：

返回堆中空闲内存的总大小（字节）。

**POSIX 兼容性** ：openvela/NuttX 扩展接口。

## mm_heapfree_largest
    
    
    size_t mm_heapfree_largest(struct mm_heap_s *heap);

查询指定堆中最大的连续空闲块大小。这决定了单次分配可用的最大内存。

**参数** ：

  * heap 堆结构指针。


**返回值** ：

返回最大连续空闲块的大小（字节）。

**POSIX 兼容性** ：openvela/NuttX 扩展接口。

## mm_notify_pressure
    
    
    void mm_notify_pressure(size_t remaining, size_t largest);

发送内存压力通知。当堆空闲内存低于阈值时，通知注册的监听者释放缓存等可回收内存。

**参数** ：

  * remaining 当前剩余空闲内存（字节）。
  * largest 当前最大连续空闲块（字节）。


**返回值** ：

无返回值。

**POSIX 兼容性** ：openvela/NuttX 扩展接口。

# 用户堆接口

## umm_initialize
    
    
    void umm_initialize(void *heap_start, size_t heap_size);

初始化用户堆。此函数通常在系统启动时由初始化代码调用。

**参数** ：

  * heap_start 堆内存的起始地址。
  * heap_size 堆的大小（字节）。


**返回值** ：

无返回值。

**注意** ：

  * 此函数只应调用一次。
  * 用户堆是 malloc() 等标准接口的默认堆。


## umm_heapmember
    
    
    bool umm_heapmember(void *mem);

检查内存地址是否属于用户堆。

**参数** ：

  * mem 要检查的内存地址。


**返回值** ：

如果内存地址属于用户堆，返回 true；否则返回 false。

**注意** ：

  * 与 kmm_heapmember() 配合使用，可以确定内存来源。


* * *

## umm_addregion
    
    
    void umm_addregion(void *heapstart, size_t heapsize);

向用户堆添加一个新的内存区域。

**参数** ：

  * heapstart 新内存区域的起始地址。
  * heapsize 新内存区域的大小（字节）。


**返回值** ：

无返回值。

**POSIX 兼容性** ：openvela/NuttX 扩展接口。

## umm_extend
    
    
    void umm_extend(void *mem, size_t size, int region);

扩展用户堆的指定内存区域。新增内存必须与现有区域相邻。

**参数** ：

  * mem 新增内存的起始地址。
  * size 新增内存的大小（字节）。
  * region 区域索引。


**返回值** ：

无返回值。

**POSIX 兼容性** ：openvela/NuttX 扩展接口。

## umm_delayfree
    
    
    void umm_delayfree(void *mem);

延迟释放用户堆内存。适用于中断上下文。

**参数** ：

  * mem 指向要释放的用户堆内存。


**返回值** ：

无返回值。

**POSIX 兼容性** ：openvela/NuttX 扩展接口。

# 调试与诊断

## mm_memdump
    
    
    void mm_memdump(struct mm_heap_s *heap, const struct mm_memdump_s *dump);

转储堆的内存分配信息，用于调试内存泄漏和分析内存使用情况。

**参数** ：

  * heap 堆结构指针。如果为 NULL，则转储用户堆。
  * dump 指向 struct mm_memdump_s 结构体的指针，用于指定转储条件。


**返回值** ：

无返回值。

**注意** ：

  * mm_memdump_s 是 malltask 的类型别名，结构体字段与 mallinfo_task() 中描述的 malltask 相同。
  * 输出信息包括每个分配块的地址、大小、分配者 PID 和分配时的调用栈（如果启用了 CONFIG_MM_BACKTRACE）。
  * 常用于诊断内存泄漏，找出哪些代码分配了内存但未释放。


## mm_checkcorruption
    
    
    void mm_checkcorruption(struct mm_heap_s *heap);

检查堆是否存在内存损坏。此函数遍历堆中所有内存块，验证其完整性。

**参数** ：

  * heap 要检查的堆结构指针。


**返回值** ：

无返回值。如果检测到内存损坏，将触发断言或输出调试信息。

**注意** ：

  * 需要启用 CONFIG_DEBUG_MM 配置。
  * 检测的问题包括：块头损坏、双重释放、越界写入等。
  * 此函数会遍历整个堆，对性能有影响，主要用于调试。


## umm_checkcorruption
    
    
    void umm_checkcorruption(void);

检查用户堆是否存在内存损坏。这是 mm_checkcorruption() 对用户堆的便捷包装。

**参数** ：

无参数。

**返回值** ：

无返回值。如果检测到内存损坏，将触发断言或输出调试信息。

**注意** ：

  * 需要启用 CONFIG_DEBUG_MM 配置。
  * 可以在怀疑有内存问题时调用此函数进行检查。


## umm_memdump
    
    
    void umm_memdump(const struct mm_memdump_s *dump);

转储用户堆的内存分配信息到系统日志。

**参数** ：

  * dump 指向转储条件结构体。


**返回值** ：

无返回值。

**注意** ：

  * 需要启用 CONFIG_MM_BACKTRACE 以获取调用栈。


**POSIX 兼容性** ：openvela/NuttX 扩展接口。

---

## 信号 API

> 路径: 内核接口 > 信号 API
> 来源: [https://doc.openvela.com/document?id=1110&language=cn&version=dev](https://doc.openvela.com/document?id=1110&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/kernel/signal.md>) | 简体中文 ]

# 信号 API

openvela 提供完整的 POSIX 信号机制，用于进程和线程间的异步通信和事件通知。

头文件：#include <signal.h>

# openvela 实现说明

  * **信号范围** ：标准信号 1~31，实时信号 SIGRTMIN(32) ~ SIGRTMAX(63)
  * **默认动作** ：在 openvela 中，大多数信号的默认动作是忽略（与 Linux 不同），除非启用了相应配置
  * **实时信号特性** ：支持排队、携带附加数据（sigqueue）、按 FIFO 顺序递送
  * **SIGKILL /SIGSTOP**：不可捕获、阻塞或忽略
  * **信号栈** ：sigaltstack() 当前不支持 SS_ONSTACK，仅支持 SS_DISABLE
  * **已废弃接口** ：signal()、sighold()、sigrelse()、sigignore()、sigset()、sigpause() 为旧式接口，建议使用 sigaction() 和 sigprocmask() 替代


# 信号概述

信号是一种软件中断机制，允许内核或其他进程向目标进程发送异步通知。

## 信号类型

  1. **标准信号** （1~31）：不排队，不携带额外数据，大多数有预定义默认动作
  2. **实时信号** （SIGRTMIN~SIGRTMAX）：支持排队，可携带附加数据，按 FIFO 递送


## 信号处理方式

  1. **忽略** （SIG_IGN）：信号被丢弃
  2. **默认处理** （SIG_DFL）：执行默认动作
  3. **自定义处理** ：注册信号处理函数


## 信号掩码

每个线程有独立的信号掩码，被阻塞的信号保持挂起状态直到解除阻塞。

# 信号发送

## kill
    
    
    int kill(pid_t pid, int signo);

向指定进程或进程组发送信号。这是最基本和常用的信号发送函数，可用于进程间通信、进程控制和事件通知。

kill() 的名称源于历史原因，但它不仅用于"杀死"进程，也可以发送任意信号进行通信。信号 0 是特殊的"空信号"，不会实际发送，但会执行错误检查，可用于测试进程是否存在。

**参数** ：

  * pid 目标进程或进程组的标识。取值含义：
  * > 0：向指定 PID 的进程发送信号。
  * 0：向调用进程所在进程组的所有进程发送信号（广播）。
  * -1：向所有有权限发送信号的进程发送信号（除了 init 和自己），需要超级用户权限。这是一种系统级广播。
  * < -1：向进程组 ID 为 |pid|（绝对值）的所有进程发送信号。例如 kill(-100, SIGTERM) 向进程组 100 发送 SIGTERM。
  * signo 要发送的信号编号（1-63）。有效信号定义在 <signal.h> 中（如 SIGTERM、SIGKILL）。特殊值 0 表示"空信号"，不发送实际信号，仅执行错误检查（用于检测进程是否存在）。


**返回值** ：

成功时返回 0，失败时返回 -1 并设置 errno：

  * EINVAL 信号编号无效（小于 0 或大于 MAX_SIGNO）。
  * ESRCH 指定的进程或进程组不存在，或进程已终止。
  * EPERM 调用进程没有权限向目标进程发送信号。通常只能向同一用户的进程或子进程发送信号。


**注意** ：

  * SIGKILL（信号 9）和 SIGSTOP（信号 19）是特殊信号，无法被捕获、阻塞或忽略，保证能终止或停止目标进程。
  * 发送信号只是一个请求，目标进程可能忽略信号（如果信号处理设置为 SIG_IGN）或阻塞信号。
  * 信号可能不会立即递送，如果目标进程阻塞了该信号，信号会挂起直到解除阻塞。
  * 在多线程程序中，信号被递送到进程中的某个未阻塞该信号的线程（由系统选择）。要向特定线程发送信号，使用 pthread_kill() 或 tgkill()。
  * 使用 kill(pid, 0) 可以测试进程是否存在：如果返回 0，进程存在；如果返回 -1 且 errno 为 ESRCH，进程不存在。
  * 向进程组发送信号时，如果进程组为空或所有进程都无权访问，会返回 ESRCH 错误。
  * 某些信号有特殊的语义，例如 SIGCHLD 通知父进程子进程状态变化，SIGPIPE 在向已关闭的管道写入时产生。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## killpg
    
    
    int killpg(pid_t pgrp, int signo);

向指定进程组的所有进程发送信号。等效于 kill(-pgrp, signo)。

**参数** ：

  * pgrp 目标进程组 ID。如果为 0，则向调用进程所在的进程组发送信号。
  * signo 要发送的信号编号。


**返回值** ：

成功时返回 0，失败时返回 -1 并设置 errno：

  * EINVAL 信号编号无效。
  * ESRCH 指定的进程组不存在。
  * EPERM 没有权限向目标进程组发送信号。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## tgkill
    
    
    int tgkill(pid_t pid, pid_t tid, int signo);

向指定线程组（进程）中的特定线程发送信号。这是向多线程程序中的特定线程发送信号的最安全方式。

**参数** ：

  * pid 目标进程（线程组）ID。如果为 -1，则忽略此参数，仅根据 tid 查找目标线程。
  * tid 目标线程 ID。
  * signo 要发送的信号编号。


**返回值** ：

成功时返回 0，失败时返回 -1 并设置 errno：

  * EINVAL 信号编号无效。
  * ESRCH 线程不存在或不属于指定进程。
  * EPERM 没有权限向目标线程发送信号。


**注意** ：

  * 比 pthread_kill() 更安全，因为可以验证线程属于预期的进程。
  * 避免了线程 ID 被回收后误发信号的问题。


**POSIX 兼容性** ：兼容 Linux 扩展接口。

## raise
    
    
    int raise(int signo);

向调用线程自身发送信号。这是进程或线程自我发送信号的标准方法，等效于：  
\- 单线程程序：kill(getpid(), signo)  
\- 多线程程序：pthread_kill(pthread_self(), signo)

raise() 常用于程序主动触发信号处理，如自我终止、触发断点、或测试信号处理器。

**参数** ：

  * signo 要发送的信号编号（1-63）。常用值包括：
  * SIGABRT：异常终止（如 abort() 调用）
  * SIGTERM：请求终止
  * SIGUSR1/SIGUSR2：用户自定义信号
  * SIGTRAP：触发调试器断点


**返回值** ：

成功时返回 0，失败时返回非零值。

**注意** ：

  * 如果信号的处理动作是终止进程（如 SIGTERM 的默认动作，如果启用），raise() 不会返回，进程直接终止。
  * 信号会立即被处理（如果未阻塞）或挂起（如果被阻塞），然后函数返回。
  * 如果信号被阻塞，信号会挂起直到解除阻塞，此时 raise() 已经返回。
  * 在信号处理函数内调用 raise() 发送当前信号可能导致递归，除非设置了 SA_NODEFER 标志。
  * raise() 是线程安全的，在多线程程序中只影响调用线程。
  * 相比 kill(getpid(), signo)，raise() 更高效且语义更清晰。
  * 常见用法：
  * raise(SIGABRT) \- 异常终止程序（等效于 abort()）
  * raise(SIGTERM) \- 自我终止
  * raise(SIGUSR1) \- 触发用户定义的信号处理


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## sigqueue
    
    
    int sigqueue(int pid, int signo, const union sigval value);

向指定进程发送带数据的信号。这是 kill() 的增强版本，支持随信号传递额外的数据（整数或指针），主要用于实时信号和需要携带数据的通信场景。

与 kill() 的关键区别：  
1\. **携带数据** ：可以通过 value 传递一个整数或指针给接收进程  
2\. **支持排队** ：实时信号会排队，多次发送会排队等待递送  
3\. **更详细的信息** ：接收方可以通过 siginfo_t 获取信号来源和携带的数据

sigqueue() 常用于实时信号通信、事件通知、异步 I/O 完成通知等需要携带额外信息的场景。

**参数** ：

  * pid 目标进程 ID。必须 > 0，不支持进程组（不能使用 0 或负值）。
  * signo 要发送的信号编号（1-63）。虽然标准信号也可以使用，但建议使用实时信号（SIGRTMIN 到 SIGRTMAX），因为：
  * 实时信号支持排队（多次发送都会递送）
  * 标准信号不排队（多次发送可能只递送一次）
  * 实时信号按 FIFO 顺序递送
  * value 随信号传递的数据，union sigval 类型包含两个成员（只能使用其中一个）：
  * sival_int：传递整数值，如错误码、序列号、计数器等
  * sival_ptr：传递指针值，注意指针在接收进程中可能无效（除非是共享内存地址）


**返回值** ：

成功时返回 0，失败时返回 -1 并设置 errno：

  * EINVAL 信号编号无效（<= 0 或 > MAX_SIGNO）。
  * ESRCH 指定的进程不存在或已终止。
  * EPERM 调用进程没有权限向目标进程发送信号（不同用户、不同会话等）。
  * EAGAIN 信号排队资源耗尽。系统对每个进程的挂起信号数有限制（通常数百个），超过限制会返回此错误。这主要影响实时信号。


**注意** ：

  * **实时信号排队** ：实时信号（SIGRTMIN-SIGRTMAX）支持排队，同一信号发送多次会排队等待递送，不会丢失。每个信号实例都携带独立的 value。
  * **标准信号不排队** ：标准信号（如 SIGUSR1、SIGTERM）不排队，多次发送可能只递送一次，后续的 value 可能丢失。
  * **接收数据** ：接收方需要使用以下方式获取 value：
  * 使用 sigaction() 设置处理函数时，设置 SA_SIGINFO 标志，使用三参数处理函数：  

        
        void handler(int sig, siginfo_t *info, void *context) {
            int data = info->si_value.sival_int;
            // 或 void *ptr = info->si_value.sival_ptr;
        }

  * 或使用 sigwaitinfo()/sigtimedwait() 同步等待信号并获取 siginfo_t
  * **指针参数注意** ：sival_ptr 在跨进程时通常无效，因为不同进程有独立的地址空间。只有在以下情况下才有意义：
  * 共享内存地址
  * 传递给同一进程的其他线程（使用 pthread_sigqueue()，如果可用）
  * 传递的不是真实指针，而是编码的整数值
  * **排队限制** ：系统对挂起信号数有限制（SIGQUEUE_MAX），可以通过 sysconf(_SC_SIGQUEUE_MAX) 查询。超过限制会返回 EAGAIN。
  * **信号优先级** ：实时信号有隐含的优先级，编号小的优先递送。SIGRTMIN 优先级最高，SIGRTMAX 最低。
  * **典型用法** ：  

        
        // 发送方
        union sigval val;
        val.sival_int = 42;  // 或任何数据
        sigqueue(target_pid, SIGRTMIN, val);
          
        // 接收方
        struct sigaction sa;
        sa.sa_flags = SA_SIGINFO;
        sa.sa_sigaction = handler;
        sigemptyset(&sa.sa_mask);
        sigaction(SIGRTMIN, &sa, NULL);

  * **与 kill() 的选择**：
  * 如果不需要携带数据且使用标准信号，用 kill() 更简单
  * 如果需要携带数据或使用实时信号，用 sigqueue()
  * sigqueue() 设置 siginfo_t 的 si_code 为 SI_QUEUE，可用于区分信号来源。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

# 信号处理设置

## sigaction
    
    
    int sigaction(int signo, const struct sigaction *act, struct sigaction *oact);

设置或查询信号的处理动作。这是设置信号处理器的首选方法，比 signal() 提供更多控制和更可预测的行为。sigaction() 是 POSIX 标准推荐的信号处理接口。

struct sigaction 结构允许精确控制信号处理行为，包括处理函数、信号掩码、各种标志等。这比简单的 signal() 接口更强大和灵活。

**参数** ：

  * signo 要设置的信号编号（1-63）。不能是 SIGKILL（9）或 SIGSTOP（19），因为这两个信号的处理动作不能被修改。
  * act 指向新的信号处理动作结构。如果为 NULL，则不修改当前处理动作，仅通过 oact 查询。结构字段：
  * sa_handler 或 sa_sigaction：信号处理函数
    * SIG_DFL：恢复默认处理动作
    * SIG_IGN：忽略该信号
    * 函数指针：自定义处理函数
  * sa_mask：信号掩码，指定在执行处理函数期间要额外阻塞的信号集。处理的信号本身会自动阻塞（除非设置 SA_NODEFER）。
  * sa_flags：控制信号处理行为的标志（见下文）
  * oact 指向保存旧处理动作的结构。如果为 NULL，则不返回旧动作。可用于保存并稍后恢复原处理动作。


**sa_flags 标志说明**：

  * SA_SIGINFO (0x02)：使用扩展的三参数处理函数 sa_sigaction(int sig, siginfo_t *info, void *context)，而不是简单的 sa_handler(int sig)。这允许获取信号的详细信息（发送者 PID、信号值等）。
  * SA_RESTART (0x10)：被信号中断的系统调用自动重启，而不是返回 EINTR 错误。这简化了错误处理，避免需要手动重试中断的系统调用。
  * SA_NODEFER (0x20)：不自动阻塞正在处理的信号。默认情况下，处理信号 X 时会阻塞信号 X，防止递归。设置此标志后允许信号处理函数递归调用。
  * SA_RESETHAND (0x40)：信号递送后自动重置处理动作为 SIG_DFL（一次性处理器）。类似于旧的不可靠信号语义。
  * SA_ONSTACK (0x08)：在备用信号栈上执行处理函数（需要先用 sigaltstack() 设置）。用于避免栈溢出信号处理器自身溢出栈。
  * SA_NOCLDSTOP (0x01)：如果 signo 是 SIGCHLD，则子进程停止（SIGSTOP）或继续（SIGCONT）时不产生信号，只在终止时产生。
  * SA_NOCLDWAIT (0x04)：如果 signo 是 SIGCHLD，子进程终止时自动回收，不产生僵尸进程，父进程无需调用 wait()。


**返回值** ：

成功时返回 0，失败时返回 -1 并设置 errno：

  * EINVAL signo 无效，或尝试修改 SIGKILL/SIGSTOP 的处理动作。
  * EFAULT act 或 oact 指向无效内存地址（段错误）。


**注意** ：

  * 信号处理函数应尽量简短和高效，避免调用不可重入函数（如 malloc()、printf()）。只应调用异步信号安全（async-signal-safe）的函数。
  * sa_mask 在处理函数执行期间生效，处理函数返回后自动恢复原信号掩码。
  * 多次调用 sigaction() 修改同一信号的处理动作是安全的，新动作会覆盖旧动作。
  * 如果需要临时修改并恢复信号处理，模式为：  

        
        struct sigaction old_act;
        sigaction(SIGINT, &new_act, &old_act);  // 设置新处理
        // ... 做某些操作 ...
        sigaction(SIGINT, &old_act, NULL);       // 恢复旧处理

  * 在信号处理函数中修改全局变量时，应将其声明为 volatile sig_atomic_t 类型，确保原子性和可见性。
  * 使用 SA_SIGINFO 标志可以获取信号的详细信息，如发送者 PID、信号携带的数据等，这对于调试和高级信号处理很有用。
  * sa_mask 中应包含所有在处理函数执行期间需要阻塞的信号，防止信号处理函数被其他信号中断导致的竞态条件。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## signal
    
    
    sighandler_t signal(int signo, sighandler_t handler);

设置信号的处理函数。这是 sigaction() 的简化版本，但行为在不同系统上可能有差异，建议使用 sigaction()。

**参数** ：

  * signo 信号编号。不能是 SIGKILL 或 SIGSTOP。
  * handler 信号处理函数：
  * SIG_IGN 忽略该信号。
  * SIG_DFL 使用默认处理动作。
  * 用户定义的函数指针，原型为 void handler(int signo)。


**返回值** ：

成功时返回之前的信号处理函数，失败时返回 SIG_ERR 并设置 errno。

**注意** ：

  * 信号处理函数应尽量简短，只调用异步信号安全的函数。
  * 在 openvela 中，signal() 的行为与 BSD 语义一致：信号处理后不会重置为默认，系统调用会自动重启。
  * 对于需要精确控制信号行为的场景，建议使用 sigaction()。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## sigset
    
    
    sighandler_t sigset(int signo, sighandler_t handler);

设置信号处理函数（类似 signal，但支持 SIG_HOLD）。

**参数** ：

  * signo 信号编号。
  * handler 信号处理函数，可以是 SIG_IGN、SIG_DFL、SIG_HOLD 或用户定义的函数。


**返回值** ：

成功时返回之前的信号处理函数，失败时返回 SIG_ERR。

**POSIX 兼容性** ：兼容 POSIX 同名接口（已过时）。

## sigignore
    
    
    int sigignore(int signo);

将指定信号的处理设置为忽略。

**参数** ：

  * signo 要忽略的信号编号。


**返回值** ：

成功时返回 0，失败时返回 -1。

**注意** ：

  * 已废弃接口，等价于 sigaction() 设置 SIG_IGN。建议使用 sigaction()。
  * SIGKILL 和 SIGSTOP 不能被忽略。  
**POSIX 兼容性** ：兼容 POSIX 同名接口（已过时）。


## siginterrupt
    
    
    int siginterrupt(int signo, int flag);

设置信号是否中断系统调用。

**参数** ：

  * signo 信号编号。
  * flag 如果非零，信号将中断系统调用；否则系统调用会自动重启。


**返回值** ：

成功时返回 0，失败时返回 -1。

**注意** ：

  * flag 非零：清除 SA_RESTART，被信号中断的系统调用返回 EINTR。
  * flag 为零：设置 SA_RESTART，被信号中断的系统调用自动重启。  
**POSIX 兼容性** ：兼容 BSD 扩展接口。


# 信号集操作

## sigemptyset
    
    
    int sigemptyset(sigset_t *set);

初始化信号集为空集（不包含任何信号）。这是使用信号集之前必须执行的初始化操作。未初始化的信号集内容不确定，直接使用会导致未定义行为。

初始化为空集后，可以使用 sigaddset() 逐个添加需要的信号，构建自定义信号集。

**参数** ：

  * set 指向要初始化的信号集。必须是已分配的 sigset_t 变量（自动变量、静态变量或动态分配）。


**返回值** ：

成功时返回 0。按照 POSIX 标准，此函数总是成功，但某些实现在参数无效时可能返回 -1。

**注意** ：

  * **必须初始化** ：所有信号集在使用前必须调用 sigemptyset() 或 sigfillset() 初始化。不要假设新分配的信号集是空的，自动变量的初始值不确定。
  * 初始化后的空集不包含任何信号，所有信号的成员测试（sigismember()）都返回 0。
  * 典型用法模式：  

        
        sigset_t set;
        sigemptyset(&set);           // 初始化为空
        sigaddset(&set, SIGINT);     // 添加 SIGINT
        sigaddset(&set, SIGTERM);    // 添加 SIGTERM
        // 现在 set 包含 SIGINT 和 SIGTERM

  * 空集常用于 sigprocmask(SIG_SETMASK, &empty_set, ...) 解除所有信号的阻塞。
  * 即使信号集已经初始化，也可以再次调用 sigemptyset() 清空它。
  * 与 sigfillset() 配合：sigemptyset() \+ sigaddset() 用于构建稀疏信号集（包含少数信号），sigfillset() \+ sigdelset() 用于构建稠密信号集（排除少数信号）。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## sigfillset
    
    
    int sigfillset(sigset_t *set);

初始化信号集为满集（包含所有有效信号）。初始化后，信号集包含系统支持的所有信号（1 到 MAX_SIGNO，即 1-63）。

满集常用于需要阻塞所有信号的场景，或作为起点，再用 sigdelset() 移除不需要阻塞的信号。

**参数** ：

  * set 指向要初始化的信号集。


**返回值** ：

成功时返回 0。按照 POSIX 标准，此函数总是成功，但某些实现在参数无效时可能返回 -1。

**注意** ：

  * 初始化后的满集包含所有信号（包括 SIGKILL 和 SIGSTOP），但注意 SIGKILL 和 SIGSTOP 即使在信号集中也无法被实际阻塞。
  * 满集中包含的信号数量取决于系统，在 openvela 中是 63 个（MIN_SIGNO=1 到 MAX_SIGNO=63）。
  * 典型用法模式：  

        
        sigset_t set;
        sigfillset(&set);             // 初始化为满集
        sigdelset(&set, SIGUSR1);     // 移除 SIGUSR1
        sigdelset(&set, SIGUSR2);     // 移除 SIGUSR2
        sigprocmask(SIG_SETMASK, &set, NULL);  // 阻塞除 SIGUSR1/SIGUSR2 外的所有信号

  * 常见应用：
  * 阻塞所有信号保护临界区：sigfillset(&set); sigprocmask(SIG_BLOCK, &set, ...);
  * 在 sigaction() 的 sa_mask 中使用，在处理信号期间阻塞所有其他信号
  * 创建"反向"信号集：先填满，再移除不需要的信号
  * 与 sigemptyset() 的选择：
  * 如果需要包含少数信号，用 sigemptyset() \+ sigaddset()
  * 如果需要排除少数信号，用 sigfillset() \+ sigdelset()
  * 即使信号集已经初始化，也可以再次调用 sigfillset() 重新填充。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## sigaddset
    
    
    int sigaddset(sigset_t *set, int signo);

将指定信号添加到信号集中。如果信号已在集合中，操作无影响（幂等操作）。

这是构建自定义信号集的基本操作，通常在 sigemptyset() 初始化后使用，逐个添加需要的信号。

**参数** ：

  * set 指向要修改的信号集。必须已用 sigemptyset() 或 sigfillset() 初始化。
  * signo 要添加的信号编号（1-63）。必须是有效的信号编号，无效值会导致未定义行为或返回错误。


**返回值** ：

成功时返回 0，失败时返回 -1 并设置 errno：

  * EINVAL signo 不是有效的信号编号（<= 0 或 > MAX_SIGNO）。


**注意** ：

  * 必须在已初始化的信号集上操作，否则行为未定义。
  * 添加已存在的信号不会产生错误或副作用。
  * 可以多次调用添加多个信号：  

        
        sigset_t set;
        sigemptyset(&set);
        sigaddset(&set, SIGINT);
        sigaddset(&set, SIGTERM);
        sigaddset(&set, SIGUSR1);

  * 可以添加 SIGKILL 和 SIGSTOP 到信号集，但在实际使用时（如 sigprocmask()），这两个信号会被忽略。
  * 常见用途：
  * 构建要阻塞的信号掩码
  * 指定 sigwait() 等待的信号集
  * 设置 sigaction() 的 sa_mask
  * 与 sigdelset() 配对使用可以灵活操作信号集。
  * 可以使用 sigismember() 检查信号是否在集合中。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## sigdelset
    
    
    int sigdelset(sigset_t *set, int signo);

从信号集中移除指定信号。如果信号不在集合中，操作无影响（幂等操作）。

这通常与 sigfillset() 配合使用，先填充所有信号，再移除不需要的信号，构建"排除型"信号集。

**参数** ：

  * set 指向要修改的信号集。必须已用 sigemptyset() 或 sigfillset() 初始化。
  * signo 要移除的信号编号（1-63）。必须是有效的信号编号，无效值会导致未定义行为或返回错误。


**返回值** ：

成功时返回 0，失败时返回 -1 并设置 errno：

  * EINVAL signo 不是有效的信号编号（<= 0 或 > MAX_SIGNO）。


**注意** ：

  * 必须在已初始化的信号集上操作，否则行为未定义。
  * 移除不存在的信号不会产生错误或副作用。
  * 可以多次调用移除多个信号：  

        
        sigset_t set;
        sigfillset(&set);              // 包含所有信号
        sigdelset(&set, SIGINT);       // 移除 SIGINT
        sigdelset(&set, SIGTERM);      // 移除 SIGTERM
        // 现在 set 包含除 SIGINT 和 SIGTERM 外的所有信号

  * 常见用途：
  * 从满集中排除某些信号
  * 修改已有信号集，去除某些信号
  * 精细控制信号掩码
  * 与 sigaddset() 相反操作，两者可以组合使用灵活操作信号集。
  * 移除 SIGKILL 或 SIGSTOP 不会有实际效果，因为它们本身就无法被阻塞。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## sigismember
    
    
    int sigismember(const sigset_t *set, int signo);

检查指定信号是否在信号集中。这是查询信号集成员关系的标准方法。

**参数** ：

  * set 指向要查询的信号集。必须已初始化。
  * signo 要检查的信号编号（1-63）。


**返回值** ：

  * 返回 1：信号在集合中（是成员）
  * 返回 0：信号不在集合中（非成员）
  * 返回 -1：失败，signo 无效，设置 errno 为 EINVAL


**注意** ：

  * 返回值是 1 或 0，而不是非零或零，这与某些布尔函数不同，需要显式检查 1。
  * 正确用法：  

        
        if (sigismember(&set, SIGINT) == 1) {
            // SIGINT 在集合中
        } else if (sigismember(&set, SIGINT) == 0) {
            // SIGINT 不在集合中
        } else {
            // 错误
        }

  * 简化用法（作为布尔值）：  

        
        if (sigismember(&set, SIGINT)) {
            // SIGINT 在集合中（返回 1，真值）
        }

  * 必须在已初始化的信号集上操作，未初始化的信号集返回值不确定。
  * 常见用途：
  * 检查信号是否被阻塞（查询 sigprocmask() 返回的掩码）
  * 检查信号是否挂起（查询 sigpending() 返回的集合）
  * 验证信号集的内容
  * 与集合操作配合：  

        
        sigset_t set;
        sigemptyset(&set);
        sigaddset(&set, SIGINT);
        assert(sigismember(&set, SIGINT) == 1);
        assert(sigismember(&set, SIGTERM) == 0);


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## sigisemptyset
    
    
    int sigisemptyset(sigset_t *set);

检查信号集是否为空。

**参数** ：

  * set 信号集。


**返回值** ：

如果信号集为空返回 1，否则返回 0。

**注意** ：

  * glibc 扩展接口，非 POSIX 标准，用于快速检查信号集是否为空。  
**POSIX 兼容性** ：兼容 glibc 扩展接口。


## sigandset
    
    
    int sigandset(sigset_t *dest, const sigset_t *left, const sigset_t *right);

计算两个信号集的交集。

**参数** ：

  * dest 存储结果的信号集。
  * left 第一个信号集。
  * right 第二个信号集。


**返回值** ：

成功时返回 0，失败时返回 -1。

**注意** ：

  * glibc 扩展接口，用于计算两个信号集的交集。dest 可以与 left 或 right 相同。  
**POSIX 兼容性** ：兼容 glibc 扩展接口。


## sigorset
    
    
    int sigorset(sigset_t *dest, const sigset_t *left, const sigset_t *right);

计算两个信号集的并集。

**参数** ：

  * dest 存储结果的信号集。
  * left 第一个信号集。
  * right 第二个信号集。


**返回值** ：

成功时返回 0，失败时返回 -1。

**注意** ：

  * glibc 扩展接口，用于计算两个信号集的并集。dest 可以与 left 或 right 相同。  
**POSIX 兼容性** ：兼容 glibc 扩展接口。


# 信号等待

## sigwait
    
    
    int sigwait(const sigset_t *set, int *sig);

同步等待信号集 set 中的任意信号到达。这是以同步方式处理信号的关键函数，允许将信号作为普通事件处理，而不是异步中断。

与异步信号处理不同，sigwait() 将信号转换为同步事件：线程主动等待信号，信号到达时函数返回信号编号，而不是调用信号处理函数。这大大简化了信号处理，避免了异步信号处理的复杂性（如可重入性、竞态条件等）。

典型用法是创建专门的信号处理线程，阻塞感兴趣的信号，然后循环调用 sigwait() 等待并处理信号。

**参数** ：

  * set 要等待的信号集。通常应先使用 sigprocmask() 或 pthread_sigmask() 阻塞这些信号，否则信号可能被异步处理函数捕获而不是 sigwait() 接收。必须包含至少一个有效信号。
  * sig 返回接收到的信号编号（输出参数）。如果等待多个信号，无法预测哪个信号先到达，需要根据返回的编号进行处理。


**返回值** ：

成功时返回 0，失败时返回错误码（注意：不设置 errno，直接返回错误码）：

  * EINVAL set 包含无效的信号编号（<= 0 或 > MAX_SIGNO）。
  * EINTR 被未在 set 中的信号中断（某些实现，openvela 通常不会返回此错误）。


**注意** ：

  * **关键** ：等待的信号必须被阻塞。否则信号可能在 sigwait() 调用前或期间被信号处理函数捕获，导致 sigwait() 错过信号。推荐模式：  

        
        sigset_t set;
        sigemptyset(&set);
        sigaddset(&set, SIGUSR1);
        sigaddset(&set, SIGUSR2);
          
        // 先阻塞信号
        pthread_sigmask(SIG_BLOCK, &set, NULL);
          
        // 然后等待
        int sig;
        while (1) {
            sigwait(&set, &sig);
            switch (sig) {
                case SIGUSR1: /* 处理 SIGUSR1 */ break;
                case SIGUSR2: /* 处理 SIGUSR2 */ break;
            }
        }

  * sigwait() 从挂起信号队列中移除信号，不会触发信号处理函数。即使注册了信号处理函数，sigwait() 接收的信号也不会调用处理函数。
  * 如果多个线程同时等待同一信号，只有一个线程会接收到信号（由系统选择）。
  * 如果信号已经挂起（在调用 sigwait() 前到达），函数会立即返回，不会阻塞。
  * sigwait() 是取消点（cancellation point）：如果线程被取消（pthread_cancel()），函数会立即返回。
  * 相比异步信号处理，同步等待的优势：
  * 不需要考虑函数可重入性
  * 可以使用普通的 C 库函数（malloc、printf 等）
  * 不需要使用 volatile sig_atomic_t 类型
  * 更容易推理和调试
  * 常用于实现信号处理线程模式：主线程和工作线程阻塞所有信号，专门的信号线程循环调用 sigwait() 处理信号。
  * 标准信号不排队，如果同一信号发送多次，可能只有一个实例被 sigwait() 接收。实时信号支持排队。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## sigwaitinfo
    
    
    int sigwaitinfo(const sigset_t *set, siginfo_t *info);

等待 set 中的任意信号，并获取信号的详细信息。与 sigwait() 类似，但提供更多信号信息。

**参数** ：

  * set 要等待的信号集。
  * info 如果非 NULL，返回信号的详细信息，包括：
  * si_signo 信号编号。
  * si_code 信号来源代码（如 SI_USER、SI_QUEUE、SI_TIMER）。
  * si_pid 发送进程的 PID。
  * si_value 随信号传递的数据（用于 sigqueue() 发送的信号）。


**返回值** ：

成功时返回信号编号，失败时返回 -1 并设置 errno：

  * EINTR 被其他信号中断。
  * EINVAL set 包含无效信号编号。


**注意** ：

  * 等价于 sigtimedwait(set, info, NULL)，即无超时的无限等待。
  * 与 sigwait() 的区别是返回更详细的 siginfo_t 信息。


**注意** ：

  * 等价于 sigtimedwait(set, info, NULL)，即无超时的无限等待。
  * 与 sigwait() 的区别是返回更详细的 siginfo_t 信息。
  * 失败时 errno 可能为 EINTR（被中断）或 EINVAL（无效信号集）。  
**POSIX 兼容性** ：兼容 POSIX 同名接口。


## sigtimedwait
    
    
    int sigtimedwait(const sigset_t *set, siginfo_t *info, const struct timespec *timeout);

等待 set 中的任意信号，带超时限制。在指定时间内如果没有信号到达，函数返回错误。

**参数** ：

  * set 要等待的信号集。
  * info 如果非 NULL，返回信号的详细信息。
  * timeout 超时时间：
  * tv_sec 秒数。
  * tv_nsec 纳秒数。
  * 如果为 NULL，则无限等待（等效于 sigwaitinfo()）。
  * 如果为 {0, 0}，则立即返回（轮询模式）。


**返回值** ：

成功时返回信号编号，失败时返回 -1 并设置 errno：

  * EAGAIN 超时时间内没有信号到达。
  * EINTR 被其他（未在 set 中的）信号中断。
  * EINVAL timeout 参数无效（如负值）。


**注意** ：

  * 常用于实现有超时的信号等待逻辑。
  * 结合实时信号使用，可以实现可靠的事件通知机制。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## sigsuspend
    
    
    int sigsuspend(const sigset_t *mask);

临时替换信号掩码并挂起任务，直到收到未被阻塞的信号。这是一个原子操作，避免了分别调用 sigprocmask() 和 pause() 之间的竞态条件。

**参数** ：

  * mask 临时信号掩码。在等待期间，进程的信号掩码会被替换为此值。


**返回值** ：

总是返回 -1，errno 设置为 EINTR（被信号中断）。

**注意** ：

  * 函数返回后，信号掩码会自动恢复为调用前的值。
  * 常用于等待特定信号，同时不阻塞该信号。
  * 示例：解除阻塞 SIGUSR1 并等待它：  

        
        sigset_t mask;
        sigemptyset(&mask);  // 只解除阻塞 SIGUSR1
        sigsuspend(&mask);   // 等待任意信号


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## sigpause
    
    
    int sigpause(int signo);

从信号掩码中移除指定信号并挂起任务，直到收到信号。

**参数** ：

  * signo 要解除阻塞的信号编号。


**返回值** ：

总是返回 -1，errno 设置为 EINTR。

**POSIX 兼容性** ：兼容 POSIX 同名接口（已过时）。

# 信号掩码

## sigprocmask
    
    
    int sigprocmask(int how, const sigset_t *set, sigset_t *oset);

设置或查询调用线程的信号掩码（signal mask）。信号掩码决定哪些信号当前被阻塞。被阻塞的信号不会被递送给进程，而是保持挂起状态（pending），直到从信号掩码中移除（解除阻塞）。

信号掩码是线程局部的，每个线程维护自己独立的信号掩码。新创建的线程继承创建者的信号掩码。阻塞信号可以保护临界区代码不被信号中断，是编写健壮信号处理代码的重要工具。

**参数** ：

  * how 指定如何修改信号掩码，必须是以下值之一：
  * SIG_BLOCK (1)：将 set 中的信号添加到当前掩码。新掩码 = 旧掩码 ∪ set。用于阻塞更多信号。
  * SIG_UNBLOCK (2)：从当前掩码中移除 set 中的信号。新掩码 = 旧掩码 - set。用于解除阻塞。
  * SIG_SETMASK (3)：将当前掩码完全替换为 set。新掩码 = set。用于设置精确的信号掩码。
  * set 要操作的信号集。如果为 NULL，则不修改当前掩码，仅通过 oset 查询当前掩码（此时 how 参数被忽略）。信号集应先用 sigemptyset()、sigfillset()、sigaddset() 等函数初始化和设置。
  * oset 如果非 NULL，返回操作前的信号掩码（旧值）。可用于保存当前掩码以便稍后恢复。如果只想查询不修改，可设置 set=NULL。


**返回值** ：

成功时返回 0，失败时返回 -1 并设置 errno：

  * EINVAL how 参数值无效（不是 SIG_BLOCK、SIG_UNBLOCK 或 SIG_SETMASK）。
  * EFAULT set 或 oset 指向无效内存地址。


**注意** ：

  * SIGKILL（9）和 SIGSTOP（19）无法被阻塞，尝试阻塞它们会被静默忽略（不返回错误）。这确保进程始终可以被终止或停止。
  * 在多线程程序中，每个线程有独立的信号掩码，sigprocmask() 只影响调用线程。对于多线程程序，POSIX 标准建议使用 pthread_sigmask()（功能完全相同，但返回错误码而非设置 errno）。
  * 解除阻塞信号后，如果该信号处于挂起状态，会立即递送（在 sigprocmask() 返回前）。
  * 阻塞信号期间，同一信号发送多次只会有一个实例挂起（标准信号不排队）。实时信号（SIGRTMIN-SIGRTMAX）支持排队。
  * 典型使用模式 - 临界区保护：  

        
        sigset_t new_mask, old_mask;
        sigemptyset(&new_mask);
        sigaddset(&new_mask, SIGINT);
        sigaddset(&new_mask, SIGTERM);
          
        // 进入临界区，阻塞信号
        sigprocmask(SIG_BLOCK, &new_mask, &old_mask);
          
        // 临界区代码，不会被 SIGINT/SIGTERM 中断
        // ...
          
        // 离开临界区，恢复信号掩码
        sigprocmask(SIG_SETMASK, &old_mask, NULL);

  * 信号掩码在 fork() 后被子进程继承，但在 exec() 后重置为空（所有信号解除阻塞）。
  * 信号掩码不影响信号处理动作的设置，只影响信号的递送。即使信号被阻塞，仍可以用 sigaction() 修改其处理动作。
  * 可以通过 sigpending() 查询当前哪些信号被阻塞且正在挂起。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## sigpending
    
    
    int sigpending(sigset_t *set);

获取当前被阻塞且正在挂起（待处理）的信号集。这些信号已经被发送给进程，但因为被阻塞而尚未递送。

**参数** ：

  * set 用于返回挂起信号集的指针。


**返回值** ：

成功时返回 0，失败时返回 -1 并设置 errno。

**注意** ：

  * 可用于检查在解除阻塞前是否有信号等待处理。
  * 配合 sigismember() 检查特定信号是否挂起。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## sighold
    
    
    int sighold(int signo);

将指定信号添加到信号掩码中（阻塞该信号）。

**参数** ：

  * signo 要阻塞的信号编号。


**返回值** ：

成功时返回 0，失败时返回 -1。

**注意** ：

  * 已废弃接口，等价于 sigprocmask(SIG_BLOCK, ...)。建议使用 sigprocmask()。
  * 失败时设置 errno 为 EINVAL（信号编号无效）。  
**POSIX 兼容性** ：兼容 POSIX 同名接口（已过时）。


## sigrelse
    
    
    int sigrelse(int signo);

从信号掩码中移除指定信号（解除阻塞）。

**参数** ：

  * signo 要解除阻塞的信号编号。


**返回值** ：

成功时返回 0，失败时返回 -1。

**注意** ：

  * 已废弃接口，等价于 sigprocmask(SIG_UNBLOCK, ...)。建议使用 sigprocmask()。
  * 失败时设置 errno 为 EINVAL（信号编号无效）。  
**POSIX 兼容性** ：兼容 POSIX 同名接口（已过时）。


## pthread_sigmask
    
    
    int pthread_sigmask(int how, const sigset_t *set, sigset_t *oset);

设置或查询调用线程的信号掩码。功能与 sigprocmask() 完全相同，但这是 POSIX 多线程程序中推荐使用的接口。

主要区别是错误报告方式：pthread_sigmask() 直接返回错误码（不设置 errno），而 sigprocmask() 返回 -1 并设置 errno。这符合 pthread 函数的一般约定。

**参数** ：

  * how 指定如何修改信号掩码：
  * SIG_BLOCK (1)：阻塞更多信号，新掩码 = 旧掩码 ∪ set
  * SIG_UNBLOCK (2)：解除阻塞，新掩码 = 旧掩码 - set
  * SIG_SETMASK (3)：替换掩码，新掩码 = set
  * set 要操作的信号集。如果为 NULL，则不修改掩码，仅查询当前掩码（通过 oset 返回）。
  * oset 如果非 NULL，返回操作前的信号掩码。


**返回值** ：

成功时返回 0，失败时返回错误码（不设置 errno）：

  * EINVAL how 参数无效。
  * EFAULT set 或 oset 指向无效内存（某些实现）。


**注意** ：

  * **多线程专用** ：在多线程程序中，应使用 pthread_sigmask() 而不是 sigprocmask()，虽然功能相同，但 pthread_sigmask() 语义更明确。
  * **线程局部掩码** ：每个线程有独立的信号掩码，修改只影响调用线程。
  * **新线程继承** ：通过 pthread_create() 创建的新线程继承创建者的信号掩码。
  * SIGKILL 和 SIGSTOP 无法被阻塞，尝试阻塞会被静默忽略。
  * 解除阻塞信号后，挂起的信号会立即递送（在函数返回前）。
  * 典型用法 - 专用信号处理线程模式：  

        
        // 主线程：阻塞所有信号
        sigset_t mask;
        sigfillset(&mask);
        pthread_sigmask(SIG_SETMASK, &mask, NULL);
          
        // 创建工作线程（继承阻塞所有信号的掩码）
        pthread_create(&worker, NULL, worker_func, NULL);
          
        // 创建信号处理线程
        pthread_create(&sig_thread, NULL, signal_handler_thread, NULL);
          
        // 信号处理线程：解除阻塞并同步等待信号
        void *signal_handler_thread(void *arg) {
            sigset_t wait_mask;
            sigemptyset(&wait_mask);
            sigaddset(&wait_mask, SIGINT);
            sigaddset(&wait_mask, SIGTERM);
              
            int sig;
            while (1) {
                sigwait(&wait_mask, &sig);
                // 处理信号...
            }
        }

  * **错误处理差异** ：  

        
        // sigprocmask() 风格
        if (sigprocmask(SIG_BLOCK, &set, NULL) == -1) {
            perror("sigprocmask");  // errno 已设置
        }
          
        // pthread_sigmask() 风格
        int err = pthread_sigmask(SIG_BLOCK, &set, NULL);
        if (err != 0) {
            errno = err;
            perror("pthread_sigmask");  // 需要手动设置 errno
        }

  * 与 pthread_kill() 配合使用可以实现线程间的精确信号通信。
  * 在单线程程序中，pthread_sigmask() 和 sigprocmask() 完全等效。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

# 信号栈

## sigaltstack
    
    
    int sigaltstack(const stack_t *ss, stack_t *oss);

设置或获取信号处理的备用栈。

**参数** ：

  * ss 如果非 NULL，指向新的备用栈配置：
  * ss_sp 栈内存指针。
  * ss_size 栈大小。
  * ss_flags 标志（SS_DISABLE 禁用备用栈）。
  * oss 如果非 NULL，返回之前的备用栈配置。


**返回值** ：

成功时返回 0，失败时返回 -1 并设置 errno。

**注意** ：

  * openvela 当前不支持 SS_ONSTACK，设置非 SS_DISABLE 的栈返回 EINVAL。
  * ss->ss_size 小于 MINSIGSTKSZ 时返回 ENOMEM。  
**POSIX 兼容性** ：兼容 POSIX 同名接口。


# 线程信号

## pthread_kill
    
    
    int pthread_kill(pthread_t thread, int signo);

向指定线程发送信号。这是多线程程序中向特定线程发送信号的标准方法，比 kill() 更精确，可以指定信号的接收线程。

在多线程程序中，信号可以被递送给进程中的任意未阻塞该信号的线程。使用 pthread_kill() 可以明确指定接收线程，确保信号被期望的线程处理。

**参数** ：

  * thread 目标线程的线程 ID（通过 pthread_create() 返回或 pthread_self() 获取）。
  * signo 要发送的信号编号（1-63）。特殊值 0 是"空信号"，不发送实际信号，仅检查线程是否存在（用于存活性测试）。


**返回值** ：

成功时返回 0，失败时返回错误码（注意：不设置 errno，直接返回错误码）：

  * EINVAL signo 无效（<= 0 或 > MAX_SIGNO）。
  * ESRCH 线程不存在或已终止。线程 ID 可能已被回收并指向新线程，导致信号发送给错误的线程。


**注意** ：

  * **线程特定性** ：信号会被递送给指定线程，即使该线程阻塞了该信号，信号也会挂起在该线程上（而不是其他线程）。
  * **存活性测试** ：使用 pthread_kill(thread, 0) 可以测试线程是否存在：  

        
        if (pthread_kill(thread, 0) == 0) {
            // 线程存在
        } else {
            // 线程不存在（ESRCH）
        }

  * **信号处理** ：即使向特定线程发送信号，信号处理函数仍然可能在其他线程中执行（取决于信号掩码）。如果只有目标线程未阻塞该信号，则一定在该线程中处理。
  * **线程 ID 重用** ：线程终止后，其 ID 可能被重用。如果在线程终止后发送信号，可能发送给新线程。推荐使用 tgkill() 避免此问题（它会验证线程属于预期的进程）。
  * **与 kill() 的区别**：
  * kill() 发送给整个进程，由任意线程处理
  * pthread_kill() 发送给特定线程，更精确
  * **与 raise() 的关系**：raise(sig) 在多线程程序中等效于 pthread_kill(pthread_self(), sig)。
  * **信号掩码继承** ：新线程继承创建者的信号掩码。如果需要不同的掩码，在线程启动时调用 pthread_sigmask()。
  * **典型用途** ：
  * 取消或终止特定线程（发送 SIGTERM、SIGUSR1 等）
  * 向工作线程发送通知信号
  * 向信号处理线程发送信号
  * 测试线程是否存活
  * **线程安全** ：pthread_kill() 本身是线程安全的，可以从多个线程并发调用。
  * **POSIX 一致性** ：在 openvela 中，pthread_t 与 pid_t 相同，线程 ID 即任务 ID。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

# 调试与诊断

## psignal
    
    
    void psignal(int signo, const char *message);

打印信号描述信息。

**参数** ：

  * signo 信号编号。
  * message 前缀消息。


**返回值** ：

无返回值。

**注意** ：

  * 输出格式为 message: signal_description，主要用于调试和错误日志。  
**POSIX 兼容性** ：兼容 BSD 扩展接口。


## psiginfo
    
    
    void psiginfo(const siginfo_t *info, const char *message);

打印信号信息结构的描述。

**参数** ：

  * info 信号信息结构。
  * message 前缀消息。


**返回值** ：

无返回值。

**注意** ：

  * 比 psignal() 提供更详细的信息，包括信号来源代码。  
**POSIX 兼容性** ：兼容 POSIX 同名接口。

---

## 消息队列 API

> 路径: 内核接口 > 消息队列 API
> 来源: [https://doc.openvela.com/document?id=1111&language=cn&version=dev](https://doc.openvela.com/document?id=1111&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/kernel/msgqueue.md>) | 简体中文 ]

# 消息队列 API

openvela 提供符合 POSIX 标准的消息队列接口，用于任务间的异步消息传递。消息队列支持优先级排序，高优先级消息优先被接收。

头文件：#include <mqueue.h>

# openvela 实现说明

  * **中断中发送** ：mq_send() 可在中断上下文中调用，但行为不同：不检查队列大小，使用预分配消息（数量由 PREALLOC_MQ_IRQ_MSGS 配置）
  * **通知行为差异** ：mq_notify() 即使有任务在等待接收消息，仍会发送通知信号，与 POSIX 规范不完全一致
  * **超时时间** ：mq_timedsend() 和 mq_timedreceive() 使用基于 Epoch 的绝对时间


# 队列管理

## mq_open
    
    
    mqd_t mq_open(const char *mqName, int oflags, ...);

在调用任务和消息队列之间建立连接。成功调用后，返回的消息队列描述符可用于后续操作，直到调用 mq_close()。

**参数** ：

  * mqName 消息队列的名称。
  * oflags 打开标志位，可以是以下的任意组合：
  * O_RDONLY 只读。
  * O_WRONLY 只写。
  * O_RDWR 读写。
  * O_CREAT 如果消息队列不存在则创建。
  * O_EXCL 与 O_CREAT 配合，如果队列已存在则失败。
  * O_NONBLOCK 非阻塞模式。
  * ... 可选参数，当使用 O_CREAT 时需要提供：
  * mode（mode_t）文件权限位。当前实现中未使用，但 POSIX 要求提供。
  * attr（struct mq_attr *）队列属性。如果为 NULL 则使用默认值。mq_maxmsg 设置最大消息数，mq_msgsize 设置最大消息大小。


**返回值** ：

成功时返回消息队列描述符（mqd_t），失败时返回 -1（ERROR）并设置 errno：

  * ENOENT 未设置 O_CREAT 且指定的队列不存在。
  * EEXIST 同时设置了 O_CREAT 和 O_EXCL，但队列已存在。
  * EINVAL 参数无效（如 mqName 为 NULL）。
  * ENOMEM 内存不足，无法创建队列。
  * ENFILE 系统消息队列数量已达上限。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## mq_close
    
    
    int mq_close(mqd_t mqdes);

关闭消息队列描述符，释放系统分配给该任务的资源。如果任务在该队列上注册了通知请求，通知会被取消。

**参数** ：

  * mqdes 消息队列描述符。


**返回值** ：

成功时返回 0，失败时返回 -1（ERROR）并设置 errno：

  * EBADF mqdes 不是有效的消息队列描述符。


**注意** ：

  * 在 mq_send() 或 mq_receive() 阻塞时调用 mq_close() 的行为是未定义的。
  * 关闭后再次使用同一 mqdes 的行为是未定义的。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## mq_unlink
    
    
    int mq_unlink(const char *mqName);

删除指定名称的消息队列。如果有任务仍然打开了该队列，删除会推迟到所有描述符都关闭后执行。

**参数** ：

  * mqName 消息队列的名称。


**返回值** ：

成功时返回 0，失败时返回 -1（ERROR）并设置 errno：

  * ENOENT 指定名称的队列不存在。
  * EINVAL mqName 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

# 消息发送

## mq_send
    
    
    int mq_send(mqd_t mqdes, const void *msg, size_t msglen, int prio);

将消息发送到消息队列。消息按优先级排序，高优先级消息排在低优先级之前。prio 不能超过 MQ_PRIO_MAX。

如果队列已满且未设置 O_NONBLOCK，调用阻塞直到有空间可用。如果设置了 O_NONBLOCK，立即返回错误。

**参数** ：

  * mqdes 消息队列描述符。
  * msg 要发送的消息。
  * msglen 消息的字节长度，不能超过 mq_msgsize。
  * prio 消息优先级。


**返回值** ：

成功时返回 0，失败时返回 -1（ERROR）并设置 errno：

  * EAGAIN 队列已满且设置了 O_NONBLOCK。
  * EINVAL msg 或 mqdes 为 NULL，或 prio 无效。
  * EPERM 消息队列未以写模式打开。
  * EMSGSIZE msglen 超过队列的 mq_msgsize。
  * EINTR 被信号中断。


**注意** ：

  * mq_send() 可在中断上下文中调用，但行为不同：不检查队列大小（总是发送），使用预分配消息（数量由 PREALLOC_MQ_IRQ_MSGS 配置），不分配新内存。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## mq_timedsend
    
    
    int mq_timedsend(mqd_t mqdes, const void *msg, size_t msglen, int prio,
                     const struct timespec *abstime);

带超时的消息发送。行为与 mq_send() 相同，但在队列满时最多阻塞到 abstime 指定的绝对时间。

**参数** ：

  * mqdes 消息队列描述符。
  * msg 要发送的消息。
  * msglen 消息的字节长度。
  * prio 消息优先级。
  * abstime 绝对超时时间（基于 Epoch）。


**返回值** ：

成功时返回 0，失败时返回 -1（ERROR）并设置 errno：

  * EAGAIN 队列已满且设置了 O_NONBLOCK。
  * EINVAL msg 或 mqdes 为 NULL，或 prio 无效。
  * EPERM 消息队列未以写模式打开。
  * EMSGSIZE msglen 超过队列的 mq_msgsize。
  * EINTR 被信号中断。
  * ETIMEDOUT 超时。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

# 消息接收

## mq_receive
    
    
    ssize_t mq_receive(mqd_t mqdes, void *msg, size_t msglen, int *prio);

从消息队列接收优先级最高且最早的消息。msglen 不能小于队列的 mq_msgsize，否则返回错误。

如果队列为空且未设置 O_NONBLOCK，调用阻塞直到有消息可用。多个等待任务中，优先级最高且等待最久的任务优先接收。

**参数** ：

  * mqdes 消息队列描述符。
  * msg 接收消息的缓冲区。
  * msglen 缓冲区大小（字节）。
  * prio 如果非 NULL，存储接收到的消息的优先级。


**返回值** ：

成功时返回消息长度（字节），失败时返回 -1（ERROR）并设置 errno：

  * EAGAIN 队列为空且设置了 O_NONBLOCK。
  * EPERM 消息队列未以读模式打开。
  * EMSGSIZE msglen 小于队列的 mq_msgsize。
  * EINTR 被信号中断。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## mq_timedreceive
    
    
    ssize_t mq_timedreceive(mqd_t mqdes, char *msg, size_t msglen,
                            unsigned int *prio, const struct timespec *abstime);

带超时的消息接收。行为与 mq_receive() 相同，但在队列空时最多阻塞到 abstime 指定的绝对时间。

**参数** ：

  * mqdes 消息队列描述符。
  * msg 接收消息的缓冲区。
  * msglen 缓冲区大小（字节）。
  * prio 如果非 NULL，存储接收到的消息的优先级。
  * abstime 绝对超时时间（基于 Epoch）。


**返回值** ：

成功时返回消息长度（字节），失败时返回 -1（ERROR）并设置 errno：

  * EAGAIN 队列为空且设置了 O_NONBLOCK。
  * EPERM 消息队列未以读模式打开。
  * EMSGSIZE msglen 小于队列的 mq_msgsize。
  * EINTR 被信号中断。
  * ETIMEDOUT 超时。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

# 队列属性

## mq_setattr
    
    
    int mq_setattr(mqd_t mqdes, const struct mq_attr *mqStat, struct mq_attr *oldMqStat);

设置消息队列属性。mq_flags 中只有 O_NONBLOCK 位可以被修改。

**参数** ：

  * mqdes 消息队列描述符。
  * mqStat 新属性。
  * oldMqStat 如果非 NULL，存储修改前的属性。


**返回值** ：

成功时返回 0，失败时返回 -1（ERROR）并设置 errno：

  * EBADF mqdes 不是有效的描述符。
  * EINVAL mqStat 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

## mq_getattr
    
    
    int mq_getattr(mqd_t mqdes, struct mq_attr *mqStat);

获取消息队列的当前属性。

**参数** ：

  * mqdes 消息队列描述符。
  * mqStat 返回属性结构体：
  * mq_maxmsg 队列中的最大消息数。
  * mq_msgsize 最大消息大小（字节）。
  * mq_flags 消息队列标志。
  * mq_curmsgs 当前队列中的消息数。


**返回值** ：

成功时返回 0，失败时返回 -1（ERROR）并设置 errno：

  * EBADF mqdes 不是有效的描述符。
  * EINVAL mqStat 为 NULL。


**POSIX 兼容性** ：兼容 POSIX 同名接口。

# 通知

## mq_notify
    
    
    int mq_notify(mqd_t mqdes, const struct sigevent *notification);

注册或取消消息到达通知。当消息到达先前为空的队列时，向注册的任务发送信号通知。

如果 notification 为 NULL，取消当前注册。通知发送后注册自动取消，需要重新注册。

**参数** ：

  * mqdes 消息队列描述符。
  * notification 通知配置，包括：
  * sigev_notify 通知方式（应为 SIGEV_SIGNAL）。
  * sigev_signo 通知使用的信号编号。
  * sigev_value 随信号传递的值。


**返回值** ：

成功时返回 0，失败时返回 -1（ERROR）并设置 errno：

  * EBADF mqdes 不是有效的描述符。
  * EBUSY 另一个任务已注册了该队列的通知。
  * EINVAL sigev_notify 不是有效值，或信号编号无效。
  * ENOMEM 内存不足。


**注意** ：

  * **与 POSIX 的行为差异** ：在 openvela 中，即使有任务正在 mq_receive() 上阻塞等待消息，通知信号仍会发送给注册的任务。POSIX 规范要求此时不发送通知（消息直接满足等待的 mq_receive()）。


**POSIX 兼容性** ：部分兼容 POSIX 同名接口（通知时机与 POSIX 规范有差异）。

---

## 网络接口总览

> 路径: 网络接口 > 网络接口总览
> 来源: [https://doc.openvela.com/document?id=1113&language=cn&version=dev](https://doc.openvela.com/document?id=1113&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/network/index.md>) | 简体中文 ]

# 网络接口

openvela 包括一个全面的网络子系统，提供标准的 BSD 套接字接口和 DNS 解析功能。网络子系统是可选的，可以根据应用需求进行配置。openvela 提供的网络接口遵循 POSIX 标准，可以很容易地将现有的网络应用程序移植到 openvela。

# 核心接口

  * **[网络接口](</document?id=1114&version=dev&language=cn>)** — BSD 套接字接口（socket/bind/connect/send/recv）与 DNS 解析


# 地址管理与配置

  * **[DHCP](</document?id=1115&version=dev&language=cn>)** — DHCP 客户端（IPv4）、DHCPv6 客户端与 DHCP 服务器
  * **[网络工具库 netlib](</document?id=1116&version=dev&language=cn>)** — IPv4/IPv6 地址、路由、MAC、MTU、iptables、连通性检查等辅助接口


# 无线网络

  * **[WAPI 无线接口](</document?id=1117&version=dev&language=cn>)** — Wi-Fi 接口配置、扫描、关联、功率管理（基于 Linux Wireless Extensions）


# 文件服务

  * **[FTP 服务器](</document?id=1118&version=dev&language=cn>)** — 轻量 FTP 服务器接口

---

## 网络 API

> 路径: 网络接口 > 网络 API
> 来源: [https://doc.openvela.com/document?id=1114&language=cn&version=dev](https://doc.openvela.com/document?id=1114&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/network/net.md>) | 简体中文 ]

# 网络 API

openvela 提供与 BSD 兼容的套接字接口，支持 IPv4（AF_INET）、IPv6（AF_INET6）等协议族，以及流套接字（SOCK_STREAM）、数据报套接字（SOCK_DGRAM）和原始套接字（SOCK_RAW）。

头文件：#include <sys/socket.h>、#include <netinet/in.h>、#include <arpa/inet.h>

# openvela 实现说明

  * **协议族支持** ：AF_INET（IPv4）、AF_INET6（IPv6）、AF_LOCAL/AF_UNIX（本地套接字）、AF_PACKET（原始链路层）等，具体取决于网络栈配置
  * **配置依赖** ：网络子系统是可选的，需要启用 CONFIG_NET 及相关协议配置（如 CONFIG_NET_TCP、CONFIG_NET_UDP）
  * **非阻塞 I/O** ：通过 fcntl(fd, F_SETFL, O_NONBLOCK) 或 SOCK_NONBLOCK 标志设置
  * **DNS 解析** ：需要启用 CONFIG_NETDB_DNSCLIENT，通过 nuttx/net/dns.h 接口管理 DNS 服务器


# 套接字创建与管理

## socket
    
    
    int socket(int domain, int type, int protocol);

创建一个通信端点（套接字），返回文件描述符。

**参数** ：

  * domain 协议族：
  * AF_INET IPv4
  * AF_INET6 IPv6
  * AF_LOCAL / AF_UNIX 本地套接字
  * AF_PACKET 原始链路层
  * type 套接字类型：
  * SOCK_STREAM 面向连接的流套接字（TCP）
  * SOCK_DGRAM 无连接的数据报套接字（UDP）
  * SOCK_RAW 原始套接字
  * 可与 SOCK_NONBLOCK、SOCK_CLOEXEC 按位或组合
  * protocol 协议编号，通常为 0（自动选择）。也可指定 IPPROTO_TCP、IPPROTO_UDP 等。


**返回值** ：

成功时返回非负文件描述符，失败时返回 -1 并设置 errno：

  * EAFNOSUPPORT 不支持的协议族。
  * EPROTONOSUPPORT 不支持的协议类型。
  * EMFILE 进程文件描述符数量已达上限。
  * ENOMEM 内存不足。


**POSIX 兼容性** ：兼容 POSIX/BSD 同名接口。

## socketpair
    
    
    int socketpair(int domain, int type, int protocol, int sv[2]);

创建一对已连接的套接字，常用于父子进程间通信。

**参数** ：

  * domain 协议族，通常为 AF_LOCAL。
  * type 套接字类型（SOCK_STREAM 或 SOCK_DGRAM）。
  * protocol 通常为 0。
  * sv 输出参数，存储两个已连接的文件描述符。


**返回值** ：

成功时返回 0，失败时返回 -1 并设置 errno：

  * EAFNOSUPPORT 不支持的协议族。
  * EMFILE 文件描述符数量已达上限。


**POSIX 兼容性** ：兼容 POSIX/BSD 同名接口。

## shutdown
    
    
    int shutdown(int sockfd, int how);

关闭套接字的部分或全部通信方向。与 close() 不同，shutdown() 可以只关闭读或写方向。

**参数** ：

  * sockfd 套接字文件描述符。
  * how 关闭方式：
  * SHUT_RD 关闭读方向。
  * SHUT_WR 关闭写方向（发送 FIN）。
  * SHUT_RDWR 关闭读写双向。


**返回值** ：

成功时返回 0，失败时返回 -1 并设置 errno：

  * EBADF 无效的文件描述符。
  * ENOTCONN 套接字未连接。
  * EINVAL how 参数无效。


**POSIX 兼容性** ：兼容 POSIX/BSD 同名接口。

# 连接管理

## bind
    
    
    int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);

将套接字绑定到指定的本地地址和端口。服务器端在 listen() 前必须调用 bind()。

**参数** ：

  * sockfd 套接字文件描述符。
  * addr 本地地址结构体（struct sockaddr_in 或 struct sockaddr_in6）。
  * addrlen 地址结构体的大小。


**返回值** ：

成功时返回 0，失败时返回 -1 并设置 errno：

  * EBADF 无效的文件描述符。
  * EINVAL 套接字已绑定，或地址无效。
  * EADDRINUSE 地址已被使用。
  * EADDRNOTAVAIL 请求的地址不可用。


**POSIX 兼容性** ：兼容 POSIX/BSD 同名接口。

## connect
    
    
    int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);

发起到远程地址的连接。对于 TCP 套接字，执行三次握手；对于 UDP 套接字，设置默认目标地址。

**参数** ：

  * sockfd 套接字文件描述符。
  * addr 远程地址结构体。
  * addrlen 地址结构体的大小。


**返回值** ：

成功时返回 0，失败时返回 -1 并设置 errno：

  * EBADF 无效的文件描述符。
  * ECONNREFUSED 远程主机拒绝连接。
  * ETIMEDOUT 连接超时。
  * ENETUNREACH 网络不可达。
  * EINPROGRESS 非阻塞模式下连接正在进行。
  * EISCONN 套接字已连接。


**POSIX 兼容性** ：兼容 POSIX/BSD 同名接口。

## listen
    
    
    int listen(int sockfd, int backlog);

将套接字标记为被动监听状态，准备接受连接请求。

**参数** ：

  * sockfd 已绑定的套接字文件描述符。
  * backlog 等待连接队列的最大长度。


**返回值** ：

成功时返回 0，失败时返回 -1 并设置 errno：

  * EBADF 无效的文件描述符。
  * EOPNOTSUPP 套接字类型不支持 listen()。


**POSIX 兼容性** ：兼容 POSIX/BSD 同名接口。

## accept
    
    
    int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);

从监听套接字的等待队列中取出第一个连接请求，创建并返回一个新的已连接套接字。如果队列为空，阻塞等待。

**参数** ：

  * sockfd 监听套接字文件描述符。
  * addr 如果非 NULL，存储客户端地址。
  * addrlen 输入时为 addr 缓冲区大小，输出时为实际地址大小。


**返回值** ：

成功时返回新的已连接套接字描述符，失败时返回 -1 并设置 errno：

  * EBADF 无效的文件描述符。
  * EMFILE 文件描述符数量已达上限。
  * ECONNABORTED 连接被中止。
  * EINTR 被信号中断。


**POSIX 兼容性** ：兼容 POSIX/BSD 同名接口。

## accept4
    
    
    int accept4(int sockfd, struct sockaddr *addr, socklen_t *addrlen, int flags);

与 accept() 相同，但可通过 flags 设置新套接字的属性。

**参数** ：

  * sockfd 监听套接字文件描述符。
  * addr 客户端地址（可为 NULL）。
  * addrlen 地址长度。
  * flags 标志位：
  * SOCK_NONBLOCK 新套接字设为非阻塞。
  * SOCK_CLOEXEC 新套接字设为 exec 时关闭。


**返回值** ：

同 accept()。

**POSIX 兼容性** ：兼容 Linux 扩展接口（非 POSIX 标准）。

# 数据发送

## send
    
    
    ssize_t send(int sockfd, const void *buf, size_t len, int flags);

在已连接的套接字上发送数据。等价于 sendto() 不指定目标地址。

**参数** ：

  * sockfd 已连接的套接字文件描述符。
  * buf 要发送的数据缓冲区。
  * len 数据长度（字节）。
  * flags 发送标志：
  * MSG_DONTWAIT 非阻塞发送。
  * MSG_NOSIGNAL 对端关闭时不产生 SIGPIPE。
  * 0 默认行为。


**返回值** ：

成功时返回发送的字节数，失败时返回 -1 并设置 errno：

  * EBADF 无效的文件描述符。
  * ENOTCONN 套接字未连接。
  * EAGAIN / EWOULDBLOCK 非阻塞模式下发送缓冲区满。
  * EPIPE 对端已关闭连接。
  * EINTR 被信号中断。


**POSIX 兼容性** ：兼容 POSIX/BSD 同名接口。

## sendto
    
    
    ssize_t sendto(int sockfd, const void *buf, size_t len, int flags,
                   const struct sockaddr *to, socklen_t tolen);

发送数据到指定地址。主要用于 UDP 套接字，也可用于已连接的 TCP 套接字（此时忽略目标地址）。

**参数** ：

  * sockfd 套接字文件描述符。
  * buf 数据缓冲区。
  * len 数据长度。
  * flags 发送标志（同 send()）。
  * to 目标地址。对于已连接套接字可为 NULL。
  * tolen 目标地址长度。


**返回值** ：

成功时返回发送的字节数，失败时返回 -1 并设置 errno（同 send()，另加）：

  * EDESTADDRREQ 未连接的套接字且未指定目标地址。


**POSIX 兼容性** ：兼容 POSIX/BSD 同名接口。

## sendmsg
    
    
    ssize_t sendmsg(int sockfd, const struct msghdr *msg, int flags);

通过 msghdr 结构发送数据，支持分散/聚集 I/O 和辅助数据（如文件描述符传递）。

**参数** ：

  * sockfd 套接字文件描述符。
  * msg 消息头结构体，包含目标地址、I/O 向量、辅助数据等。
  * flags 发送标志。


**返回值** ：

成功时返回发送的字节数，失败时返回 -1 并设置 errno。

**POSIX 兼容性** ：兼容 POSIX/BSD 同名接口。

# 数据接收

## recv
    
    
    ssize_t recv(int sockfd, void *buf, size_t len, int flags);

从已连接的套接字接收数据。

**参数** ：

  * sockfd 已连接的套接字文件描述符。
  * buf 接收缓冲区。
  * len 缓冲区大小（字节）。
  * flags 接收标志：
  * MSG_DONTWAIT 非阻塞接收。
  * MSG_PEEK 查看数据但不移除。
  * MSG_WAITALL 等待接收完整的 len 字节。
  * 0 默认行为。


**返回值** ：

成功时返回接收的字节数（0 表示对端关闭连接），失败时返回 -1 并设置 errno：

  * EBADF 无效的文件描述符。
  * ENOTCONN 套接字未连接。
  * EAGAIN / EWOULDBLOCK 非阻塞模式下无数据可读。
  * EINTR 被信号中断。


**POSIX 兼容性** ：兼容 POSIX/BSD 同名接口。

## recvfrom
    
    
    ssize_t recvfrom(int sockfd, void *buf, size_t len, int flags,
                     struct sockaddr *from, socklen_t *fromlen);

接收数据并获取发送方地址。主要用于 UDP 套接字。

**参数** ：

  * sockfd 套接字文件描述符。
  * buf 接收缓冲区。
  * len 缓冲区大小。
  * flags 接收标志（同 recv()）。
  * from 如果非 NULL，存储发送方地址。
  * fromlen 输入时为 from 缓冲区大小，输出时为实际地址大小。


**返回值** ：

成功时返回接收的字节数，失败时返回 -1 并设置 errno（同 recv()）。

**POSIX 兼容性** ：兼容 POSIX/BSD 同名接口。

## recvmsg
    
    
    ssize_t recvmsg(int sockfd, struct msghdr *msg, int flags);

通过 msghdr 结构接收数据，支持分散/聚集 I/O 和辅助数据。

**参数** ：

  * sockfd 套接字文件描述符。
  * msg 消息头结构体。
  * flags 接收标志。


**返回值** ：

成功时返回接收的字节数，失败时返回 -1 并设置 errno。

**POSIX 兼容性** ：兼容 POSIX/BSD 同名接口。

# 套接字选项

## setsockopt
    
    
    int setsockopt(int sockfd, int level, int option, const void *value, socklen_t value_len);

设置套接字选项。

**参数** ：

  * sockfd 套接字文件描述符。
  * level 选项所在的协议层：
  * SOL_SOCKET 套接字层选项。
  * IPPROTO_TCP TCP 层选项。
  * IPPROTO_IP IP 层选项。
  * IPPROTO_IPV6 IPv6 层选项。
  * option 选项名称（如 SO_REUSEADDR、SO_KEEPALIVE、TCP_NODELAY 等）。
  * value 选项值。
  * value_len 选项值的大小。


**返回值** ：

成功时返回 0，失败时返回 -1 并设置 errno：

  * EBADF 无效的文件描述符。
  * ENOPROTOOPT 不支持的选项。
  * EINVAL 选项值无效。


**POSIX 兼容性** ：兼容 POSIX/BSD 同名接口。

## getsockopt
    
    
    int getsockopt(int sockfd, int level, int option, void *value, socklen_t *value_len);

获取套接字选项。

**参数** ：

  * sockfd 套接字文件描述符。
  * level 协议层（同 setsockopt()）。
  * option 选项名称。
  * value 存储选项值的缓冲区。
  * value_len 输入时为缓冲区大小，输出时为实际值大小。


**返回值** ：

成功时返回 0，失败时返回 -1 并设置 errno（同 setsockopt()）。

**POSIX 兼容性** ：兼容 POSIX/BSD 同名接口。

# 地址查询

## getsockname
    
    
    int getsockname(int sockfd, struct sockaddr *addr, socklen_t *addrlen);

获取套接字绑定的本地地址。

**参数** ：

  * sockfd 套接字文件描述符。
  * addr 存储本地地址的缓冲区。
  * addrlen 输入时为缓冲区大小，输出时为实际地址大小。


**返回值** ：

成功时返回 0，失败时返回 -1 并设置 errno：

  * EBADF 无效的文件描述符。
  * EINVAL addrlen 无效。


**POSIX 兼容性** ：兼容 POSIX/BSD 同名接口。

## getpeername
    
    
    int getpeername(int sockfd, struct sockaddr *addr, socklen_t *addrlen);

获取已连接套接字的远程地址。

**参数** ：

  * sockfd 已连接的套接字文件描述符。
  * addr 存储远程地址的缓冲区。
  * addrlen 输入时为缓冲区大小，输出时为实际地址大小。


**返回值** ：

成功时返回 0，失败时返回 -1 并设置 errno：

  * EBADF 无效的文件描述符。
  * ENOTCONN 套接字未连接。


**POSIX 兼容性** ：兼容 POSIX/BSD 同名接口。

# DNS 接口

头文件：#include <nuttx/net/dns.h>

## dns_add_nameserver
    
    
    int dns_add_nameserver(const struct sockaddr *addr, socklen_t addrlen);

添加一个 DNS 名称服务器。

**参数** ：

  * addr DNS 服务器地址（struct sockaddr_in 或 struct sockaddr_in6）。
  * addrlen 地址结构体大小。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

**POSIX 兼容性** ：openvela/NuttX 扩展接口。

## dns_default_nameserver
    
    
    int dns_default_nameserver(void);

重置 DNS 解析器，仅使用默认 DNS 服务器。

**返回值** ：

成功时返回 0，失败时返回负的错误码。

**POSIX 兼容性** ：openvela/NuttX 扩展接口。

## dns_foreach_nameserver
    
    
    int dns_foreach_nameserver(dns_callback_t callback, void *arg);

遍历所有已配置的 DNS 服务器，对每个服务器调用回调函数。

**参数** ：

  * callback 回调函数，对每个 DNS 服务器调用。
  * arg 传递给回调函数的用户参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

**POSIX 兼容性** ：openvela/NuttX 扩展接口。

## dns_register_notify
    
    
    int dns_register_notify(dns_callback_t callback, void *arg);

注册 DNS 服务器变更通知。当 DNS 服务器列表发生变化时，调用回调函数。

**参数** ：

  * callback 变更通知回调函数。
  * arg 传递给回调函数的用户参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

**POSIX 兼容性** ：openvela/NuttX 扩展接口。

## dns_unregister_notify
    
    
    int dns_unregister_notify(dns_callback_t callback, void *arg);

取消 DNS 服务器变更通知注册。

**参数** ：

  * callback 之前注册的回调函数。
  * arg 注册时提供的用户参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

**POSIX 兼容性** ：openvela/NuttX 扩展接口。

## dns_set_queryfamily
    
    
    int dns_set_queryfamily(sa_family_t family);

设置 DNS 查询使用的地址族。

**参数** ：

  * family 地址族（AF_INET、AF_INET6 或 AF_UNSPEC）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

**POSIX 兼容性** ：openvela/NuttX 扩展接口。

---

## DHCP API

> 路径: 网络接口 > DHCP API
> 来源: [https://doc.openvela.com/document?id=1115&language=cn&version=dev](https://doc.openvela.com/document?id=1115&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/network/net_dhcp.md>) | 简体中文 ]

# DHCP API

DHCP（Dynamic Host Configuration Protocol）客户端与服务器接口，覆盖 IPv4（dhcpc_* / dhcpd_*）和 IPv6（dhcp6c_*）两套地址分配协议。

头文件：#include <netutils/dhcpc.h>、#include <netutils/dhcp6c.h>、#include <netutils/dhcpd.h>

# openvela 实现说明

  * **IPv4 客户端** ：dhcpc_* 系列封装完整的 DHCP 客户端状态机（DISCOVER/OFFER/REQUEST/ACK）
  * **IPv6 客户端** ：dhcp6c_* 系列实现 DHCPv6 客户端协议流程
  * **服务器** ：dhcpd_* 系列提供简单的 DHCP 服务器能力，可在热点/AP 模式下分配 IP
  * **异步调用** ：*_request_async 接口提供回调式调用，避免阻塞当前线程
  * **配置依赖** ：需启用 CONFIG_NETUTILS_DHCPC / CONFIG_NETUTILS_DHCP6C / CONFIG_NETUTILS_DHCPD


# DHCP 客户端

头文件：#include <netutils/dhcpc.h>

## dhcpc_open
    
    
    void *dhcpc_open(const char *interface, const void *mac_addr, int mac_len);

创建 DHCP 客户端会话。

**参数** ：

  * interface 网络接口名称（如 "eth0"）。
  * mac_addr MAC 地址。
  * mac_len MAC 地址长度。


**返回值** ：

成功时返回会话句柄，失败时返回 NULL。

## dhcpc_request
    
    
    int dhcpc_request(void *handle, struct dhcpc_state *presult);

执行 DHCP 协商获取 IP 地址（阻塞调用）。

**参数** ：

  * handle 由 dhcpc_open() 返回的会话句柄。
  * presult 存储获取的网络配置（IP、子网掩码、网关、DNS、租约时间）。


**返回值** ：

成功时返回 0，失败时返回 -1。

## dhcpc_request_async
    
    
    int dhcpc_request_async(void *handle, dhcpc_callback_t callback);

异步执行 DHCP 协商，在后台线程中运行，通过回调返回结果。

**参数** ：

  * handle 会话句柄。
  * callback 结果回调函数。


**返回值** ：

成功启动时返回 0，失败时返回 -1。

## dhcpc_cancel
    
    
    void dhcpc_cancel(void *handle);

取消正在进行的 DHCP 协商。

## dhcpc_close
    
    
    void dhcpc_close(void *handle);

关闭 DHCP 客户端会话，释放所有资源。内部会先调用 dhcpc_cancel()。

# DHCPv6 客户端

头文件：#include <netutils/dhcp6c.h>

## dhcp6c_open
    
    
    void *dhcp6c_open(const char *interface);

创建 DHCPv6 客户端会话。

**参数** ：

  * interface 网络接口名称。


**返回值** ：

成功时返回会话句柄，失败时返回 NULL。

## dhcp6c_request
    
    
    int dhcp6c_request(void *handle, struct dhcp6c_state *presult);

执行 DHCPv6 协商获取地址（阻塞调用）。

## dhcp6c_request_async
    
    
    int dhcp6c_request_async(void *handle, dhcp6c_callback_t callback);

异步执行 DHCPv6 协商。

## dhcp6c_cancel
    
    
    void dhcp6c_cancel(void *handle);

取消正在进行的 DHCPv6 协商。

## dhcp6c_close
    
    
    void dhcp6c_close(void *handle);

关闭 DHCPv6 客户端会话。

# DHCP 服务器

头文件：#include <netutils/dhcpd.h>

## dhcpd_run
    
    
    int dhcpd_run(const char *interface);

在当前线程运行 DHCP 服务器（阻塞，直到出错才返回）。

## dhcpd_start
    
    
    int dhcpd_start(const char *interface);

以后台任务启动 DHCP 服务器守护进程。

**返回值** ：

成功时返回 0，失败时返回负的错误码。

## dhcpd_stop
    
    
    int dhcpd_stop(void);

停止运行中的 DHCP 服务器守护进程。

## dhcpd_set_startip
    
    
    int dhcpd_set_startip(in_addr_t startip);

配置 DHCP 服务器分配地址池的起始 IP 地址。

**参数** ：

  * startip 起始 IP 地址（网络字节序）。


**返回值** ：

始终返回 0。

## dhcpd_set_routerip
    
    
    int dhcpd_set_routerip(in_addr_t routerip);

配置 DHCP 服务器下发给客户端的默认网关地址。

**参数** ：

  * routerip 默认网关 IP（网络字节序）。


**返回值** ：

始终返回 0。

## dhcpd_set_netmask
    
    
    int dhcpd_set_netmask(in_addr_t netmask);

配置 DHCP 服务器下发给客户端的子网掩码。

**参数** ：

  * netmask 子网掩码（网络字节序）。


**返回值** ：

始终返回 0。

## dhcpd_set_dnsip
    
    
    int dhcpd_set_dnsip(in_addr_t dnsip);

配置 DHCP 服务器下发给客户端的 DNS 服务器地址。

**参数** ：

  * dnsip DNS 服务器 IP（网络字节序）。


**返回值** ：

始终返回 0。

---

## 网络工具库（netlib）API

> 路径: 网络接口 > 网络工具库（netlib）API
> 来源: [https://doc.openvela.com/document?id=1116&language=cn&version=dev](https://doc.openvela.com/document?id=1116&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/network/netlib.md>) | 简体中文 ]

# 网络工具库（netlib）API

openvela 网络工具库（netlib_*）提供了一系列简化 BSD 套接字操作的辅助函数，涵盖 IPv4/IPv6 地址管理、路由、ARP、MAC 地址、MTU、防火墙（iptables/ip6tables）、网络连通性检查等。

头文件：#include <netutils/netlib.h>

# openvela 实现说明

  * **定位** ：在 BSD socket API 基础上的便利封装，隐藏 ioctl \+ SIOCGIF* 等底层细节
  * **覆盖范围** ：
    * IPv4/IPv6 地址、网关、子网掩码、DNS、路由
    * MAC 地址读写、接口上/下、MTU 设置
    * VLAN 管理、ARP 表操作
    * iptables/ip6tables 操作
    * 网络连通性检查（ping / HTTP / 接口可达性）
    * URL 解析工具
  * **配置依赖** ：需启用 CONFIG_NETUTILS_NETLIB，部分子接口另需对应模块配置（如 CONFIG_NET_ARP、CONFIG_NET_IPv6 等）
  * **错误处理** ：多数接口成功时返回 0 或 OK，失败时返回 ERROR（-1）并设置 errno


# 网络工具库

头文件：#include <netutils/netlib.h>

netlib 提供网络配置工具函数，包括接口地址设置、路由管理、ARP 操作等。

**IPv4 地址管理**

## netlib_get_ipv4addr
    
    
    int netlib_get_ipv4addr(const char *ifname, struct in_addr *addr);

**参数** ：

  * ifname 网络接口名称
  * ipaddr 用于存储 IP 地址


## netlib_set_ipv4addr
    
    
    int netlib_set_ipv4addr(const char *ifname, const struct in_addr *addr);

**参数** ：

  * ifname 网络接口名称
  * ipaddr 要设置的地址


## netlib_set_dripv4addr
    
    
    int netlib_set_dripv4addr(const char *ifname, const struct in_addr *addr);

**参数** ：

  * ifname 网络接口名称
  * ipaddr 要设置的地址


## netlib_get_dripv4addr
    
    
    int netlib_get_dripv4addr(const char *ifname, struct in_addr *addr);

**参数** ：

  * ifname 网络接口名称
  * ipaddr 用于存储默认路由地址


## netlib_set_ipv4netmask
    
    
    int netlib_set_ipv4netmask(const char *ifname, const struct in_addr *addr);

**参数** ：

  * ifname 网络接口名称
  * ipaddr 要设置的地址


## netlib_get_ipv4netmask
    
    
    int netlib_get_ipv4netmask(const char *ifname, struct in_addr *addr);

**参数** ：

  * ifname 网络接口名称
  * ipaddr 用于存储子网掩码


## netlib_ipv4adaptor
    
    
    int netlib_ipv4adaptor(in_addr_t destipaddr, in_addr_t *srcipaddr);

**参数** ：

  * destipaddr 目标 IPv4 地址
  * srcipaddr 用于存储适配器地址


## netlib_read_ipv4route
    
    
    ssize_t netlib_read_ipv4route(FILE *stream, struct netlib_ipv4_route_s *route);

**参数** ：

  * fd procfs IPv4 路由表的文件描述符
  * route 用于存储下一条路由表项


## netlib_ipv4router
    
    
    int netlib_ipv4router(const struct in_addr *destipaddr, struct in_addr *router);

**参数** ：

  * destipaddr 目标 IP 地址。
  * router \- 用于存储网关的 IP 地址，即


## netlib_obtain_ipv4addr
    
    
    int netlib_obtain_ipv4addr(const char *ifname);

**参数** ：

  * ifname 网络接口名称


## netlib_set_ipv4dnsaddr
    
    
    int netlib_set_ipv4dnsaddr(const struct in_addr *inaddr);

**参数** ：

  * inaddr 要设置的地址


**IPv6 地址管理**

## netlib_add_ipv6addr
    
    
    int netlib_add_ipv6addr(const char *ifname, const struct in6_addr *addr, uint8_t preflen);

**参数** ：

  * ifname 网络接口名称
  * ipaddr 地址 to add
  * preflen 前缀长度（位）。


## netlib_del_ipv6addr
    
    
    int netlib_del_ipv6addr(const char *ifname, const struct in6_addr *addr, uint8_t preflen);

**参数** ：

  * ifname 网络接口名称
  * ipaddr 地址 to delete
  * preflen 前缀长度（位）。


## netlib_get_ipv6addr
    
    
    int netlib_get_ipv6addr(const char *ifname, struct in6_addr *addr);

**参数** ：

  * ifname 网络接口名称
  * ipaddr 用于存储 IP 地址


## netlib_set_ipv6addr
    
    
    int netlib_set_ipv6addr(const char *ifname, const struct in6_addr *addr);

**参数** ：

  * ifname 网络接口名称
  * ipaddr 要设置的地址


## netlib_set_dripv6addr
    
    
    int netlib_set_dripv6addr(const char *ifname, const struct in6_addr *addr);

**参数** ：

  * ifname 网络接口名称
  * ipaddr 要设置的地址


## netlib_set_ipv6netmask
    
    
    int netlib_set_ipv6netmask(const char *ifname, const struct in6_addr *addr);

**参数** ：

  * ifname 网络接口名称
  * ipaddr 要设置的地址


## netlib_ipv6adaptor
    
    
    int netlib_ipv6adaptor(const struct in6_addr *destipaddr, struct in6_addr *srcipaddr);

**参数** ：

  * destipaddr 目标 IP 地址。
  * srcipaddr \- 用于存储适配器地址


## netlib_ipv6netmask2prefix
    
    
    uint8_t netlib_ipv6netmask2prefix(const uint16_t *mask);

**参数** ：

  * mask 子网掩码。


## netlib_prefix2ipv6netmask
    
    
    void netlib_prefix2ipv6netmask(uint8_t preflen, struct in6_addr *netmask);

**参数** ：

  * preflen 前缀长度（位）。
  * netmask 用于存储子网掩码.


## netlib_read_ipv6route
    
    
    ssize_t netlib_read_ipv6route(FILE *stream, struct netlib_ipv6_route_s *route);

**参数** ：

  * fd 路由表项。
  * route 用于存储下一条路由表项


## netlib_ipv6router
    
    
    int netlib_ipv6router(const struct in6_addr *destipaddr, struct in6_addr *router);

**参数** ：

  * destipaddr 目标 IP 地址。
  * router \- 用于存储网关的 IP 地址，即


## netlib_obtain_ipv6addr
    
    
    int netlib_obtain_ipv6addr(const char *ifname);

**参数** ：

  * ifname 网络接口名称。


## netlib_set_ipv6dnsaddr
    
    
    int netlib_set_ipv6dnsaddr(const struct in6_addr *inaddr);

**参数** ：

  * inaddr 要设置的地址


**接口管理**

## netlib_setmacaddr
    
    
    int netlib_setmacaddr(const char *ifname, const uint8_t *macaddr);

**参数** ：

  * ifname 网络接口名称
  * macaddr MAC 地址。


## netlib_getmacaddr
    
    
    int netlib_getmacaddr(const char *ifname, uint8_t *macaddr);

**参数** ：

  * ifname 网络接口名称
  * macaddr 用于存储 MAC 地址


## netlib_getessid
    
    
    int netlib_getessid(const char *ifname, char *essid, size_t idlen);

**参数** ：

  * ifname 网络接口名称
  * essid 用于存储结果。
  * idlen ESSID 缓冲区大小。


## netlib_setessid
    
    
    int netlib_setessid(const char *ifname, const char *essid);

**参数** ：

  * ifname 网络接口名称
  * essid ESSID（网络名称）。


## netlib_getifstatus
    
    
    int netlib_getifstatus(const char *ifname, uint8_t *flags);

**参数** ：

  * ifname 网络接口名称
  * flags 接口标志。


## netlib_ifup
    
    
    int netlib_ifup(const char *ifname);

**参数** ：

  * ifname 网络接口名称


## netlib_ifdown
    
    
    int netlib_ifdown(const char *ifname);

**参数** ：

  * ifname 网络接口名称


## netlib_set_mtu
    
    
    int netlib_set_mtu(const char *ifname, int mtu);

**参数** ：

  * ifname 网络接口名称
  * mtu 最大传输单元（MTU）。


**返回值** ：

:

## netlib_getifstatistics
    
    
    int netlib_getifstatistics(const char *ifname, struct netdev_statistics_s *stat);

**参数** ：

  * ifname 网络接口名称。
  * stat 用于存储设备统计信息。


## netlib_check_ifconflict
    
    
    int netlib_check_ifconflict(const char *ifname);

**参数** ：

  * ifname 网络接口名称


**路由管理**

## netlib_get_route
    
    
    ssize_t netlib_get_route(struct rtentry *rtelist, unsigned int nentries, sa_family_t family);

**参数** ：

  * rtelist 用于存储设备列表。
  * nentries 数组容量（条目数）。
  * family \- 地址族。 See AF_* definitions in


**ARP 管理**

## netlib_del_arpmapping
    
    
    int netlib_del_arpmapping(const struct sockaddr_in *inaddr, const char *ifname);

**参数** ：

  * inaddr IPv4 地址。
  * ifname 网络接口名称。


## netlib_get_arpmapping
    
    
    int netlib_get_arpmapping(const struct sockaddr_in *inaddr, uint8_t *macaddr, const char *ifname);

**参数** ：

  * inaddr IPv4 地址。
  * macaddr 用于存储对应的以太网 MAC 地址
  * ifname 网络接口名称。


## netlib_set_arpmapping
    
    
    int netlib_set_arpmapping(const struct sockaddr_in *inaddr, const uint8_t *macaddr, const char *ifname);

**参数** ：

  * inaddr IPv4 地址。
  * macaddr MAC 地址。
  * ifname 网络接口名称。


## netlib_get_arptable
    
    
    ssize_t netlib_get_arptable(struct arpreq *arptab, unsigned int nentries);

**参数** ：

  * arptab 用于存储 ARP 表副本
  * nentries 数组容量（条目数）。


## netlib_ifarp
    
    
    int netlib_ifarp(const char *ifname);

**参数** ：

  * ifname 网络接口名称


## netlib_ifnoarp
    
    
    int netlib_ifnoarp(const char *ifname);

**参数** ：

  * ifname 网络接口名称


**DNS 管理**

## netlib_clear_dnsaddr
    
    
    void netlib_clear_dnsaddr(void);

**VLAN 管理**

## netlib_add_vlan
    
    
    int netlib_add_vlan(const char *ifname, int vlanid, int prio);

**参数** ：

  * ifname 网络接口名称。
  * vlanid VLAN 标识符。
  * prio 默认 VLAN 优先级（PCP）。


## netlib_del_vlan
    
    
    int netlib_del_vlan(const char *vlanif);

**iptables**

## netlib_ipt_commit
    
    
    int netlib_ipt_commit(const struct ipt_replace *repl);

**参数** ：

  * repl 要提交的配置。


## netlib_ipt_flush
    
    
    int netlib_ipt_flush(const char *table, enum nf_inet_hooks hook);

**参数** ：

  * table 表名。
  * hook 钩子点。


## netlib_ipt_policy
    
    
    int netlib_ipt_policy(const char *table, enum nf_inet_hooks hook, int verdict);

**参数** ：

  * table 策略。
  * hook 钩子点。
  * verdict 判定值。


## netlib_ipt_append
    
    
    int netlib_ipt_append(struct ipt_replace **repl, const struct ipt_entry *entry, enum nf_inet_hooks hook);

**参数** ：

  * repl 要提交的配置。
  * entry 要追加的规则条目。
  * hook 钩子点。


## netlib_ipt_insert
    
    
    int netlib_ipt_insert(struct ipt_replace **repl, const struct ipt_entry *entry, enum nf_inet_hooks hook, int rulenum);

**参数** ：

  * repl 要提交的配置。
  * entry 要插入的规则条目。
  * hook 钩子点。
  * rulenum 规则编号。


## netlib_ipt_delete
    
    
    int netlib_ipt_delete(struct ipt_replace *repl, const struct ipt_entry *entry, enum nf_inet_hooks hook, int rulenum);

**参数** ：

  * repl 要提交的配置。
  * entry 要删除的规则条目。
  * hook 钩子点。
  * rulenum 规则编号。


## netlib_ipt_fillifname
    
    
    int netlib_ipt_fillifname(struct ipt_entry *entry, const char *inifname, const char *outifname);

**参数** ：

  * entry 要填充的规则条目。
  * inifname 输入设备名称，NULL 表示不变。
  * outifname 输出设备名称，NULL 表示不变。


## netlib_ip6t_commit
    
    
    int netlib_ip6t_commit(const struct ip6t_replace *repl);

**参数** ：

  * repl 要提交的配置。


## netlib_ip6t_flush
    
    
    int netlib_ip6t_flush(const char *table, enum nf_inet_hooks hook);

**参数** ：

  * table 表名。
  * hook 钩子点。


## netlib_ip6t_policy
    
    
    int netlib_ip6t_policy(const char *table, enum nf_inet_hooks hook, int verdict);

**参数** ：

  * table 策略。
  * hook 钩子点。
  * verdict 判定值。


## netlib_ip6t_append
    
    
    int netlib_ip6t_append(struct ip6t_replace **repl, const struct ip6t_entry *entry, enum nf_inet_hooks hook);

**参数** ：

  * repl 要提交的配置。
  * entry 要追加的规则条目。
  * hook 钩子点。


## netlib_ip6t_insert
    
    
    int netlib_ip6t_insert(struct ip6t_replace **repl, const struct ip6t_entry *entry, enum nf_inet_hooks hook, int rulenum);

**参数** ：

  * repl 要提交的配置。
  * entry 要插入的规则条目。
  * hook 钩子点。
  * rulenum 规则编号。


## netlib_ip6t_delete
    
    
    int netlib_ip6t_delete(struct ip6t_replace *repl, const struct ip6t_entry *entry, enum nf_inet_hooks hook, int rulenum);

**参数** ：

  * repl 要提交的配置。
  * entry 要删除的规则条目。
  * hook 钩子点。
  * rulenum 规则编号。


## netlib_ip6t_fillifname
    
    
    int netlib_ip6t_fillifname(struct ip6t_entry *entry, const char *inifname, const char *outifname);

**参数** ：

  * entry 要填充的规则条目。
  * inifname 输入设备名称，NULL 表示不变。
  * outifname 输出设备名称，NULL 表示不变。


**连接检测**

## netlib_check_ipconnectivity
    
    
    int netlib_check_ipconnectivity(const char *ip, int timeout, int retry);

**参数** ：

  * ip 要检查的 IPv4 地址。
  * timeout 超时时间。
  * retry 重试次数。


## netlib_check_ifconnectivity
    
    
    int netlib_check_ifconnectivity(const char *ifname, int timeout, int retry);

**参数** ：

  * ifname 网络接口名称
  * timeout 超时时间。
  * retry 重试次数。


**URL 解析**

## netlib_parsehttpurl
    
    
    int netlib_parsehttpurl(const char *url, uint16_t *port, char *hostname, int hostlen, char *filename, int namelen);

**参数** ：

  * url HTTP 相关参数。
  * port 指向 uint16_t，用于存储解析出的端口号。
  * hostname 用于存储结果的缓冲区。
  * hostlen 缓冲区大小。
  * filename 用于存储结果的缓冲区。
  * namelen 缓冲区大小。


## netlib_parseurl
    
    
    int netlib_parseurl(const char *str, struct url_s *url);

## netlib_check_httpconnectivity
    
    
    int netlib_check_httpconnectivity(const char *host, const char *getmsg, int port, int expect_code);

**参数** ：

  * host 远程主机地址。
  * getmsg HTTP 相关参数。
  * port 端口号。
  * expect_code HTTP 相关参数。


**其他**

## netlib_get_devices
    
    
    ssize_t netlib_get_devices(struct netlib_device_s *devlist, unsigned int nentries, sa_family_t family);

**参数** ：

  * devlist 用于存储设备列表。
  * nentries 数组容量（条目数）。
  * family 地址族。 See AF_* definitions in


## netlib_seteaddr
    
    
    int netlib_seteaddr(const char *ifname, const uint8_t *eaddr);

**参数** ：

  * ifname 网络接口名称
  * eaddr 新地址。


## netlib_getpanid
    
    
    int netlib_getpanid(const char *ifname, uint8_t *panid);

**参数** ：

  * ifname 网络接口名称
  * panid 用于存储当前 PAN ID


## netlib_getproperties
    
    
    int netlib_getproperties(const char *ifname, struct pktradio_properties_s *properties);

**参数** ：

  * ifname 网络接口名称
  * nodeadd 用于存储节点地址。


## netlib_setnodeaddr
    
    
    int netlib_setnodeaddr(const char *ifname, const struct pktradio_addr_s *nodeaddr);

**参数** ：

  * ifname 网络接口名称
  * nodeadd 新地址。


## netlib_getnodnodeaddr
    
    
    int netlib_getnodnodeaddr(const char *ifname, struct pktradio_addr_s *nodeaddr);

**参数** ：

  * ifname 网络接口名称
  * nodeadd 用于存储节点地址。


## netlib_get_nbtable
    
    
    ssize_t netlib_get_nbtable(struct neighbor_entry_s *nbtab, unsigned int nentries);

**参数** ：

  * nbtab 用于存储邻居表副本
  * nentries 数组容量（条目数）。


## netlib_icmpv6_autoconfiguration
    
    
    int netlib_icmpv6_autoconfiguration(const char *ifname);

**参数** ：

  * ifname 网络接口名称


## netlib_parse_conntrack
    
    
    int netlib_parse_conntrack(const struct nlmsghdr *nlh, size_t len, struct netlib_conntrack_s *ct);

**参数** ：

  * nlh 要解析的 netlink 消息。
  * ct 连接跟踪条目。


## netlib_get_conntrack
    
    
    int netlib_get_conntrack(sa_family_t family, netlib_conntrack_cb_t cb);

**参数** ：

  * family 地址族，用于过滤 conntrack 表项。
  * cb 连接跟踪条目。


## netlib_listenon
    
    
    int netlib_listenon(uint16_t portno);

**参数** ：

  * portno 端口号。


## netlib_server
    
    
    void netlib_server(uint16_t portno, pthread_startroutine_t handler, int stacksize);

**参数** ：

  * portno 端口号。
  * handler 任务入口函数。
  * stacksize 栈大小。


## netlib_get_iobinfo
    
    
    int netlib_get_iobinfo(struct iob_stats_s *iob);

**参数** ：

  * iob IOB 信息结构体。


## netlib_ipv4addrconv
    
    
    bool netlib_ipv4addrconv(const char *addrstr, uint8_t *addr);

将 IPv4 地址字符串（如 "192.168.1.1"）转换为 4 字节二进制数组。

**参数** ：

  * addrstr IPv4 地址字符串。
  * addr 输出缓冲区（4 字节）。


**返回值** ：

转换成功返回 true，格式非法时返回 false。

## netlib_ethaddrconv
    
    
    bool netlib_ethaddrconv(const char *hwstr, uint8_t *hw);

将以太网 MAC 地址字符串（如 "aa:bb:cc:dd:ee:ff"）转换为 6 字节二进制数组。

**参数** ：

  * hwstr MAC 地址字符串。
  * hw 输出缓冲区（6 字节）。


**返回值** ：

转换成功返回 true，格式非法时返回 false。

## netlib_saddrconv
    
    
    bool netlib_saddrconv(const char *hwstr, uint8_t *hw);

将 IEEE 802.15.4 短地址（2 字节）字符串转换为二进制形式。

**参数** ：

  * hwstr 地址字符串。
  * hw 输出缓冲区（2 字节）。


**返回值** ：

转换成功返回 true，格式非法时返回 false。

## netlib_eaddrconv
    
    
    bool netlib_eaddrconv(const char *hwstr, uint8_t *hw);

将 IEEE 802.15.4 扩展地址（8 字节）字符串转换为二进制形式。

**参数** ：

  * hwstr 地址字符串。
  * hw 输出缓冲区（8 字节）。


**返回值** ：

转换成功返回 true，格式非法时返回 false。

## netlib_nodeaddrconv
    
    
    bool netlib_nodeaddrconv(const char *addrstr,
                             struct pktradio_addr_s *nodeaddr);

将 pktradio 节点地址字符串转换为 pktradio_addr_s 结构体。

**参数** ：

  * addrstr 节点地址字符串。
  * nodeaddr 输出结构体指针。


**返回值** ：

转换成功返回 true，格式非法时返回 false。

---

## 无线网络接口（WAPI）API

> 路径: 网络接口 > 无线网络接口（WAPI）API
> 来源: [https://doc.openvela.com/document?id=1117&language=cn&version=dev](https://doc.openvela.com/document?id=1117&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/network/wapi.md>) | 简体中文 ]

# 无线网络接口（WAPI）API

wapi_* 系列接口基于 Linux Wireless Extensions（WEXT）封装，提供无线网络配置、扫描、关联、功率管理、区域代码和 PMKSA 缓存等能力。

头文件：#include <wireless/wapi.h>

# openvela 实现说明

  * **底层机制** ：基于 Linux Wireless Extensions（WEXT）的 ioctl 协议与 Wi-Fi 驱动通信
  * **支持场景** ：Station（客户端）模式、AP 模式、混杂模式（由驱动支持程度决定）
  * **配置依赖** ：需启用 CONFIG_WIRELESS_WAPI 及对应的 Wi-Fi 芯片驱动
  * **典型用法** ：
    * wapi_set_ifup/wapi_set_ifdown 控制接口启停
    * wapi_set_essid \+ wapi_set_mode 配置连接目标
    * wapi_scan_* / wapi_escan_* 扫描周围 AP
    * wapi_load_config / wapi_save_config 持久化配置
  * **扩展能力** ：通过 wapi_extend_params / wapi_set_pmksa 等接口与驱动私有特性交互


# 无线网络接口

头文件：#include <wireless/wapi.h>

wapi 提供无线网络配置接口，包括 SSID 扫描、连接、频率设置等。

**连接管理**

## wapi_get_ifup
    
    
    int wapi_get_ifup(int sock, const char *ifname, int *is_up);

**参数** ：

  * sock 套接字描述符（用于 ioctl 操作）。
  * ifname 网络接口名称.
  * is_up 接口状态，0 表示启用，1 表示禁用。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_set_ifup
    
    
    int wapi_set_ifup(int sock, const char *ifname);

**参数** ：

  * sock 套接字描述符（用于 ioctl 操作）。
  * ifname 网络接口名称.


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_set_ifdown
    
    
    int wapi_set_ifdown(int sock, const char *ifname);

**参数** ：

  * sock 套接字描述符（用于 ioctl 操作）。
  * ifname 网络接口名称，将被关闭。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_get_ip
    
    
    int wapi_get_ip(int sock, const char *ifname, struct in_addr *addr);

**参数** ：

  * sock 套接字描述符（用于 ioctl 操作）。
  * ifname 网络接口名称.
  * addr 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_set_ip
    
    
    int wapi_set_ip(int sock, const char *ifname, const struct in_addr *addr);

**参数** ：

  * sock 套接字描述符（用于 ioctl 操作）。
  * ifname 网络接口名称，其 IP 地址
  * addr 指向包含新 IP 地址的结构体。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_get_netmask
    
    
    int wapi_get_netmask(int sock, const char *ifname, struct in_addr *addr);

**参数** ：

  * sock 套接字描述符（用于 ioctl 操作）。
  * ifname 网络接口名称.
  * addr 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_set_netmask
    
    
    int wapi_set_netmask(int sock, const char *ifname, const struct in_addr *addr);

**参数** ：

  * sock 套接字描述符（用于 ioctl 操作）。
  * ifname 网络接口名称.
  * addr 指向包含新子网掩码的结构体。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_add_route_gw
    
    
    int wapi_add_route_gw(int sock, enum wapi_route_target_e targettype, const struct in_addr *target, const struct in_addr *netmask, const struct in_addr *gw);

**参数** ：

  * sock 套接字描述符（用于 ioctl 操作）。
  * targettype 目标类型。
  * target 指向目标 IP 地址。
  * netmask 指向目标地址对应的子网掩码。
  * gw 指向对应的网关（路由器）IP 地址，用于


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_del_route_gw
    
    
    int wapi_del_route_gw(int sock, enum wapi_route_target_e targettype, const struct in_addr *target, const struct in_addr *netmask, const struct in_addr *gw);

**参数** ：

  * sock 套接字描述符（用于 ioctl 操作）。
  * targettype 目标类型。
  * target 指向路由的目标 IP 地址
  * netmask 指向目标地址对应的子网掩码。
  * gw 指向对应的网关（路由器）IP 地址，用于


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_get_freq
    
    
    int wapi_get_freq(int sock, const char *ifname, double *freq, enum wapi_freq_flag_e *flag);

**参数** ：

  * sock 套接字描述符（用于 ioctl 操作）。
  * ifname 网络接口名称。
  * freq 输出参数。
  * flag 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_set_freq
    
    
    int wapi_set_freq(int sock, const char *ifname, double freq, enum wapi_freq_flag_e flag);

**参数** ：

  * sock 套接字描述符（用于 ioctl 操作）。
  * ifname 网络接口名称。
  * freq 频率值。
  * flag 频率值。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_freq2chan
    
    
    int wapi_freq2chan(int sock, const char *ifname, double freq, int *chan);

**参数** ：

  * sock 套接字描述符（用于 ioctl 操作）。
  * ifname 网络接口名称。
  * freq 频率（Hz），将被转换为信道编号。
  * chan 输出参数。


## wapi_chan2freq
    
    
    int wapi_chan2freq(int sock, const char *ifname, int chan, double *freq);

**参数** ：

  * sock 套接字描述符（用于 ioctl 操作）。
  * ifname 信道。
  * chan 信道编号，将被转换为频率。
  * freq 输出参数。


## wapi_get_essid
    
    
    int wapi_get_essid(int sock, const char *ifname, char *essid, enum wapi_essid_flag_e *flag);

**参数** ：

  * sock 套接字描述符（用于 ioctl 操作）。
  * ifname 网络接口名称。
  * essid 用于存储结果。
  * flag 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_set_essid
    
    
    int wapi_set_essid(int sock, const char *ifname, const char *essid, enum wapi_essid_flag_e flag);

**参数** ：

  * sock 套接字描述符（用于 ioctl 操作）。
  * ifname 网络接口名称。
  * essid 指向一个以 \0 结尾的 ESSID 字符串
  * flag 控制标志。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_get_mode
    
    
    int wapi_get_mode(int sock, const char *ifname, enum wapi_mode_e *mode);

**参数** ：

  * sock 套接字描述符（用于 ioctl 操作）。
  * ifname 网络接口名称。
  * mode 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_set_mode
    
    
    int wapi_set_mode(int sock, const char *ifname, enum wapi_mode_e mode);

**参数** ：

  * sock 套接字描述符（用于 ioctl 操作）。
  * ifname 网络接口名称。
  * mode 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_make_broad_ether
    
    
    int wapi_make_broad_ether(struct ether_addr *sa);

**参数** ：

  * sa 输出参数。


**返回值** ：

返回底层 wapi_make_ether() 调用的结果。

## wapi_make_null_ether
    
    
    int wapi_make_null_ether(struct ether_addr *sa);

**参数** ：

  * sa 输出参数。


**返回值** ：

返回底层 wapi_make_ether() 调用的结果。

## wapi_get_ap
    
    
    int wapi_get_ap(int sock, const char *ifname, struct ether_addr *ap);

**参数** ：

  * sock 套接字描述符（用于 ioctl 操作）。
  * ifname 网络接口名称。
  * ap 要设置的地址。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_set_ap
    
    
    int wapi_set_ap(int sock, const char *ifname, const struct ether_addr *ap);

**参数** ：

  * sock 套接字描述符（用于 ioctl 操作）。
  * ifname 网络接口名称。
  * ap 接入点的 MAC 地址。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_get_bitrate
    
    
    int wapi_get_bitrate(int sock, const char *ifname, int *bitrate, enum wapi_bitrate_flag_e *flag);

**参数** ：

  * sock 套接字描述符（用于 ioctl 操作）。
  * ifname 网络接口名称。
  * bitrate 输出参数，用于存储查询到的比特率。
  * flag 输出参数，用于存储比特率标志位。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_set_bitrate
    
    
    int wapi_set_bitrate(int sock, const char *ifname, int bitrate, enum wapi_bitrate_flag_e flag);

**参数** ：

  * sock 套接字描述符（用于 ioctl 操作）。
  * ifname 网络接口名称。
  * bitrate 比特率 .
  * flag 比特率 flag.


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_dbm2mwatt
    
    
    int wapi_dbm2mwatt(int dbm);

**参数** ：

  * dbm 要转换的 dBm 值。


**返回值** ：

转换后的毫瓦值。

## wapi_mwatt2dbm
    
    
    int wapi_mwatt2dbm(int mwatt);

**参数** ：

  * mwatt 毫瓦值。


**返回值** ：

转换后的 dBm 值。

## wapi_get_txpower
    
    
    int wapi_get_txpower(int sock, const char *ifname, int *power, enum wapi_txpower_flag_e *flag);

**参数** ：

  * sock 套接字描述符.
  * ifname 网络接口名称。
  * power 输出参数，用于存储发射功率值。
  * flag 输出参数，用于存储发射功率的单位。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_set_txpower
    
    
    int wapi_set_txpower(int sock, const char *ifname, int power, enum wapi_txpower_flag_e flag);

**参数** ：

  * sock 套接字描述符.
  * ifname 网络接口名称。
  * power 发射功率。
  * flag 发射功率。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_make_socket
    
    
    int wapi_make_socket(void);

## wapi_scan_init
    
    
    int wapi_scan_init(int sock, const char *ifname, const char *essid);

**参数** ：

  * sock 套接字描述符.
  * ifname 网络接口名称。
  * essid 要扫描的 ESSID。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_scan_channel_init
    
    
    int wapi_scan_channel_init(int sock, const char *ifname, const char *essid, uint8_t *channels, int num_channels);

**参数** ：

  * sock 套接字描述符.
  * ifname 网络接口名称。
  * essid 要扫描的 ESSID。
  * channels 要扫描的信道编号数组。
  * num_channels 信道。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_escan_init
    
    
    int wapi_escan_init(int sock, const char *ifname, uint8_t scan_type, const char *essid);

**参数** ：

  * sock 套接字描述符.
  * ifname 网络接口名称。
  * scan_type 扫描类型。
  * essid 要扫描的 ESSID。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_escan_channel_init
    
    
    int wapi_escan_channel_init(int sock, const char *ifname, uint8_t scan_type, const char *essid, uint8_t *channels, int num_channels);

**参数** ：

  * sock 套接字描述符.
  * ifname 网络接口名称。
  * scan_type 扫描类型。
  * essid 要扫描的 ESSID。
  * channels 要扫描的信道编号数组。
  * num_channels 信道。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_scan_stat
    
    
    int wapi_scan_stat(int sock, const char *ifname);

**参数** ：

  * sock 套接字描述符.
  * ifname 网络接口名称。


## wapi_scan_coll
    
    
    int wapi_scan_coll(int sock, const char *ifname, struct wapi_list_s *aps);

**参数** ：

  * sock 套接字描述符.
  * ifname 网络接口名称。
  * aps 收集的扫描结果列表。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_scan_coll_free
    
    
    void wapi_scan_coll_free(struct wapi_list_s *aps);

**参数** ：

  * aps 要释放的扫描结果列表。


## wapi_set_country
    
    
    int wapi_set_country(int sock, const char *ifname, const char *country);

**参数** ：

  * sock 套接字描述符.
  * ifname 网络接口名称。
  * country 指向双字符字符串，表示要设置的


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_get_country
    
    
    int wapi_get_country(int sock, const char *ifname, char *country);

**参数** ：

  * sock 套接字描述符.
  * ifname 网络接口名称。
  * country 指向调用方提供的缓冲区，用于接收


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_get_sensitivity
    
    
    int wapi_get_sensitivity(int sock, const char *ifname, int *sense);

**参数** ：

  * sock 套接字描述符.
  * ifname 网络接口名称。
  * sense 指向调用方提供的整型变量，用于接收


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_load_config
    
    
    void *wapi_load_config(const char *ifname, const char *confname, struct wpa_wconfig_s *conf);

**参数** ：

  * ifname 网络接口名称。
  * confname 路径。
  * conf 指向调用方提供的结构体，用于填入


## wapi_unload_config
    
    
    void wapi_unload_config(void *load);

**参数** ：

  * load 配置资源句柄。


## wapi_save_config
    
    
    int wapi_save_config(const char *ifname, const char *confname, const struct wpa_wconfig_s *conf);

**参数** ：

  * ifname 网络接口名称。
  * confname 路径。
  * conf 指向包含配置信息的结构体


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_set_pta_prio
    
    
    int wapi_set_pta_prio(int sock, const char *ifname, enum wapi_pta_prio_e pta_prio);

**参数** ：

  * sock 文件描述符。
  * ifname 网络接口名称。
  * pta_prio PTA 优先级。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_get_pta_prio
    
    
    int wapi_get_pta_prio(int sock, const char *ifname, enum wapi_pta_prio_e *pta_prio);

**参数** ：

  * sock 文件描述符。
  * ifname 网络接口名称。
  * pta_prio 指向用于接收当前 PTA 优先级的变量


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_set_pmksa
    
    
    int wapi_set_pmksa(int sock, const char *ifname, const uint8_t *pmk, int len);

**参数** ：

  * sock 文件描述符。
  * ifname 网络接口名称。
  * pmk 指向包含 PMKSA 数据的缓冲区
  * len 长度。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_get_pmksa
    
    
    int wapi_get_pmksa(int sock, const char *ifname, uint8_t *pmk, int len);

**参数** ：

  * sock 文件描述符。
  * ifname 网络接口名称。
  * pmk 指向用于接收查询到的 PMKSA 数据的缓冲区
  * len 缓冲区大小。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_extend_params
    
    
    int wapi_extend_params(int sock, int cmd, struct iwreq *wrq);

**参数** ：

  * sock 文件描述符。
  * cmd 私有 ioctl 命令码。
  * wrq 指向 iwreq 结构体，调用方需预先


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_set_power_save
    
    
    int wapi_set_power_save(int sock, const char *ifname, bool on);

**参数** ：

  * sock 文件描述符。
  * ifname 网络接口名称。
  * on 控制标志。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## wapi_get_power_save
    
    
    int wapi_get_power_save(int sock, const char *ifname, bool *on);

**参数** ：

  * sock 文件描述符。
  * ifname 网络接口名称。
  * on 指向用于接收当前状态的布尔变量


**返回值** ：

成功时返回 0，失败时返回负的错误码。

---

## FTP 服务器 API

> 路径: 网络接口 > FTP 服务器 API
> 来源: [https://doc.openvela.com/document?id=1118&language=cn&version=dev](https://doc.openvela.com/document?id=1118&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/network/net_ftp.md>) | 简体中文 ]

# FTP 服务器 API

简单的 FTP 服务器接口，提供用户管理和会话处理能力。

头文件：#include <netutils/ftpd.h>

# openvela 实现说明

  * **适用场景** ：IoT 设备调试、固件上传、文件下载等轻量 FTP 应用
  * **配置依赖** ：需启用 CONFIG_NETUTILS_FTPD
  * **用户管理** ：通过 ftpd_adduser 添加用户与权限
  * **会话模型** ：ftpd_session 为一个客户端连接提供会话处理，通常在独立线程中调用


# FTP 服务器

头文件：#include <netutils/ftpd.h>

## ftpd_open
    
    
    FTPD_SESSION ftpd_open(int port, sa_family_t family);

创建 FTP 服务器会话。

**参数** ：

  * port 监听端口（通常为 21）。
  * family 地址族（AF_INET 或 AF_INET6）。


**返回值** ：

成功时返回会话句柄。

## ftpd_adduser
    
    
    int ftpd_adduser(FTPD_SESSION handle, uint8_t accountflags,
                     const char *user, const char *passwd, const char *home);

添加 FTP 用户。

**参数** ：

  * handle 由 ftpd_open() 返回的句柄。
  * accountflags 用户属性标志（参见 FTPD_ACCOUNTFLAGS_*）。
  * user 用户名（NULL 表示无需登录）。
  * passwd 密码（NULL 表示无需密码）。
  * home 用户主目录。


## ftpd_session
    
    
    int ftpd_session(FTPD_SESSION handle, int timeout);

运行 FTP 服务器会话，等待并处理一个客户端连接。

**参数** ：

  * handle 会话句柄。
  * timeout 等待连接的超时时间（毫秒），0 表示无限等待。


## ftpd_close
    
    
    void ftpd_close(FTPD_SESSION handle);

关闭 FTP 服务器会话。

---

## 应用框架总览

> 路径: 应用框架 > 应用框架总览
> 来源: [https://doc.openvela.com/document?id=1120&language=cn&version=dev](https://doc.openvela.com/document?id=1120&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/index.md>) | 简体中文 ]

# 应用框架 (Application Framework)

openvela 应用框架为上层应用提供了统一的系统能力接口，涵盖进程间通信、蓝牙与连接管理、多媒体、电话服务、图形界面、安全可信执行等核心子系统。开发者可通过这些 API 快速构建 IoT 及智能设备应用，而无需关注底层硬件差异。

框架按功能领域划分为以下模块：

  * **Binder** — 进程间通信（IPC）框架开发指南（API 与 Android NDK Binder 一致，参见 [Android Binder NDK 文档](<https://developer.android.com/ndk/reference/group/ndk-binder>)）
  * **[蓝牙 (Bluetooth)](</document?id=1124&version=dev&language=cn>)** — 蓝牙协议栈接口，支持 BLE、经典蓝牙及多种 Profile（A2DP、HFP、HID 等）
  * **[电话服务 (Telephony)](</document?id=1137&version=dev&language=cn>)** — 蜂窝网络通信接口，涵盖通话、短信、数据连接、SIM 卡管理等
  * **[多媒体 (Media)](</document?id=1152&version=dev&language=cn>)** — 音视频播放与录制框架
  * **[系统服务 (Services)](</document?id=1162&version=dev&language=cn>)** — 应用管理（AMS）与权限管理（PMS）等核心系统服务
  * **[Feature](</document?id=1166&version=dev&language=cn>)** — 系统能力（SystemCapability）查询接口
  * **[快应用 (QuickApp)](</document?id=1175&version=dev&language=cn>)** — 轻量级应用运行时框架
  * **[工具库 (Utils)](</document?id=1178&version=dev&language=cn>)** — 日志（Log）与性能追踪（Trace）等通用工具
  * **[KVDB](</document?id=1182&version=dev&language=cn>)** — 轻量级键值对持久化存储
  * **[安全 (Security)](</document?id=1184&version=dev&language=cn>)** — 基于 OP-TEE 的可信执行环境（TEE）接口
  * **[uORB](</document?id=1186&version=dev&language=cn>)** — 发布/订阅消息总线，用于模块间的异步数据通信

---

## Binder 进程间通信 (IPC) 开发指南

> 路径: 应用框架 > Binder > Binder 进程间通信 (IPC) 开发指南
> 来源: [https://doc.openvela.com/document?id=1122&language=cn&version=dev](https://doc.openvela.com/document?id=1122&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/binder/binder.md>) | 简体中文 ]

# Binder 进程间通信 (IPC) 开发指南

Binder 是一种高效的进程间通信 (IPC) 传输机制，允许不同进程之间进行数据交换和远程方法调用。

# 1\. 核心架构

Binder 机制由以下四个核心组件构成：

  * **Binder 驱动程序** ：位于内核空间，负责处理进程间通信的底层细节，包括数据包传输和线程管理。
  * **ServiceManager** ：一个特殊的守护进程，充当上下文管理器，负责注册服务和查找 Binder 服务。
  * **Binder 服务端 (Server)** ：实现具体的服务功能，并通过 Binder 机制响应来自其他进程的请求。
  * **Binder 客户端 (Client)** ：使用服务的进程，通过 Binder 机制向服务端发送请求并接收响应。


# 2\. 系统配置与启动

## 2.1 Kconfig 配置

在使用 Binder 之前，请确保开启以下基本配置：  

    
    
    CONFIG_DRIVERS_BINDER          # 内核驱动开关
    CONFIG_ANDROID_BINDER          # Binder Lib 库开关
    CONFIG_ANDROID_SERVICEMANAGER  # Binder 守护进程
    CONFIG_BINDER_EXAMPLES         # Binder 示例开关

若使用 libuv 进行事件循环监听，需在开启 CONFIG_BINDER_EXAMPLES 后，额外使能：  

    
    
    CONFIG_LIBUV                   # 使能 libuv 支持

## 2.2 运行时启动

进行 Binder 通信前，必须先启动 ServiceManager 守护进程：  

    
    
    nsh> servicemanager &

# 3\. 工作原理

Binder 的通信流程如下：

  1. 开发者通过 **AIDL** 文件定义通信接口。
  2. **服务端** 实现该接口，并将服务注册到 ServiceManager。
  3. **客户端** 向 ServiceManager 查询特定服务名，获取服务端的 Binder 对象引用。
  4. **客户端** 调用预定义的接口方法。AIDL 生成的代理代码与 Binder 库将参数序列化，并将请求写入内核驱动。
  5. **Binder 驱动** 将客户端请求转发至服务端。
  6. **服务端** 接收请求，执行具体操作，并将结果原路返回给客户端。


# 4\. 接口定义 (AIDL)

AIDL (Android Interface Definition Language) 用于定义进程间通信接口，简化了跨进程的方法调用。

## 4.1 接口定义示例

创建一个简单的 AIDL 接口文件：  

    
    
    interface ITestStuff {
        void write(int sample);
        void read(int idx);
    }

## 4.2 代码生成

AIDL 工具将根据上述定义生成以下 C++ 文件，包含客户端代理类 (Bp) 和服务端桩类 (Bn)：

  * BnTestStuff.h
  * BpTestStuff.h
  * ITestStuff.h
  * ITestStuff.cpp


# 5\. 实现模式

根据应用场景的不同，Binder 服务端主要有三种实现模式。

## 模式一：基于 Binder 线程池 (标准模式)

此模式适用于标准的阻塞式服务调用。

### 1\. 服务端实现

  * **创建服务实例** ：继承 AIDL 生成的 Bn 类并实现接口。  

        
        sp<ITestServer> testServer = new ITestServer;

  * **定义接口方法** ：  

        
        Status read(int32_t sample) { /* 实现逻辑 */ }
        Status write(int32_t index) { /* 实现逻辑 */ }

  * **注册服务** ：  

        
        sp<IServiceManager> sm(defaultServiceManager());
        sm->addService(String16("aidldemo.service"), testServer);

  * **启动线程池** ：将当前线程加入 Binder 线程池处理请求。  

        
        ProcessState::self()->startThreadPool();
        IPCThreadState::self()->joinThreadPool();


### 2\. 客户端实现

  * **获取服务** ：  

        
        sp<IServiceManager> sm(defaultServiceManager());
        sp<IBinder> binder = sm->getService(String16("aidldemo.service"));

  * **转换代理接口** ：  

        
        sp<ITestStuff> service = interface_cast<ITestStuff>(binder);

  * **调用接口** ：  

        
        service->write(123);
        service->read(456);


* * *

## 模式二：基于 Libuv 主循环 (异步事件驱动)

此模式适用于需要集成到 libuv 事件循环的应用。

### 1\. 服务端实现

  * **创建并注册服务** ：  

        
        sp<ILibuvServer> testServer = new ILibuvServer;
        // ... 实现接口并注册到 ServiceManager (同模式一) ...

  * **配置 Binder 轮询** ：获取 Binder 驱动的文件描述符 (FD)。  

        
        IPCThreadState::self()->setupPolling(&fd);

  * **初始化 Libuv 句柄** ：  

        
        uv_poll_init(uv_default_loop(), &binder_handle, fd);

  * **启动监听** ：当 FD 可读时触发回调 uv_binder_cb，处理消息队列。  

        
        uv_poll_start(&binder_handle, UV_READABLE, uv_binder_cb);

  * **运行事件循环** ：  

        
        uv_run(uv_default_loop(), UV_RUN_DEFAULT);

  * **资源释放** ：  

        
        uv_close((uv_handle_t*)&binder_handle, NULL);
        IPCThreadState::self()->stopProcess();


### 2\. 客户端实现

请参考模式一。

* * *

## 模式三：基于 Epoll 主循环 (原生 Linux 事件驱动)

此模式适用于使用原生 epoll 机制管理事件的应用。

### 1\. 服务端实现

  * **创建并注册服务** ：  

        
        // 参考模式一创建 Bn 类实例并注册

  * **创建 Epoll 实例** ：  

        
        int epoll_fd = epoll_create1(EPOLL_CLOEXEC);

  * **配置 Binder 轮询** ：  

        
        int fd;
        IPCThreadState::self()->setupPolling(&fd);

  * **注册 Epoll 事件** ：  

        
        struct epoll_event ev;
        ev.events = EPOLLIN;
        epoll_ctl(epoll_fd, EPOLL_CTL_ADD, fd, &ev);

  * **事件循环处理** ：  

        
        while (1) {
            struct epoll_event events[1];
            int numEvents = epoll_wait(epoll_fd, events, 1, -1);
            if (numEvents < 0) {
                if (errno == EINTR) {
                    continue;
                }
        
                break;
            }
        
            if (numEvents > 0 && (events[0].events & EPOLLIN)) {
                ALOGI("process binder transaction");
                // 处理命令并刷新缓冲区
                IPCThreadState::self()->handlePolledCommands();
                IPCThreadState::self()->flushCommands(); // flush BC_FREE_BUFFER
            }
        }


### 2\. 客户端实现

请参考模式一。

---

## 蓝牙 API 总览

> 路径: 应用框架 > 蓝牙（Bluetooth） > 蓝牙 API 总览
> 来源: [https://doc.openvela.com/document?id=1124&language=cn&version=dev](https://doc.openvela.com/document?id=1124&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/bluetooth/index.md>) | 简体中文 ]

# 蓝牙 API

openvela 蓝牙框架提供完整的蓝牙协议栈接口，支持经典蓝牙（BR/EDR）和低功耗蓝牙（BLE），涵盖从底层连接管理到上层应用规范。

# 核心协议

  * **[GAP](</document?id=1125&version=dev&language=cn>)** （通用访问规范）— 设备发现、连接管理、配对与安全
  * **[GATT](</document?id=1126&version=dev&language=cn>)** （通用属性规范）— BLE 数据属性读写与通知
  * **[设备管理](</document?id=1127&version=dev&language=cn>)** — 远程设备配对、连接、属性查询


# 经典蓝牙规范

  * **[A2DP](</document?id=1130&version=dev&language=cn>)** （高级音频分发）— 高质量立体声音乐传输
  * **[HFP](</document?id=1132&version=dev&language=cn>)** （免提规范）— 蓝牙通话功能
  * **[HID](</document?id=1133&version=dev&language=cn>)** （人机接口设备）— 键盘、鼠标、游戏手柄
  * **[SPP](</document?id=1134&version=dev&language=cn>)** （串口仿真）— 数据透传
  * **[PAN](</document?id=1135&version=dev&language=cn>)** （个人局域网）— 网络共享与蓝牙组网


# 低功耗蓝牙规范

  * **[CS](<https://github.com/open-vela/docs/tree/dev//zh-cn/api/framework/bluetooth/bt_cs.md>)** （Channel Sounding）— 蓝牙信道探测测距与定位

---

## 蓝牙 GAP API

> 路径: 应用框架 > 蓝牙（Bluetooth） > 蓝牙 GAP API
> 来源: [https://doc.openvela.com/document?id=1125&language=cn&version=dev](https://doc.openvela.com/document?id=1125&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/bluetooth/bt_gap.md>) | 简体中文 ]

# 蓝牙 GAP API

openvela 蓝牙 GAP（通用访问规范）接口提供蓝牙适配器的管理功能，包括启用/禁用、设备发现、属性配置、配对管理等。

头文件：#include "bt_adapter.h"

# openvela 实现说明

  * **双模支持** ：支持经典蓝牙（BR/EDR）和低功耗蓝牙（BLE）独立控制
  * **异步模式** ：大部分 API 提供同步和异步两个版本，异步版本以 _async 后缀命名，通过回调返回结果
  * **实例管理** ：所有 API 的第一个参数为 bt_instance_t* ins（蓝牙客户端实例），通过 bt_open() 获取
  * **状态机** ：适配器状态遵循 OFF → BLE_TURNING_ON → BLE_ON → TURNING_ON → ON 的转换流程


# 适配器控制

### bt_adapter_get_state
    
    
    bt_adapter_state_t bt_adapter_get_state(bt_instance_t* ins);

获取适配器状态。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.


**返回值** ：

返回当前适配器状态枚举值，参见 bt_adapter_state_t。

### bt_adapter_is_support_le
    
    
    bool bt_adapter_is_support_le(bt_instance_t* ins);

查询是否支持 BLE。

**参数** ：

  * ins 蓝牙客户端实例。


**返回值** ：

支持时返回 true，不支持时返回 false。

### bt_adapter_is_support_leaudio
    
    
    bool bt_adapter_is_support_leaudio(bt_instance_t* ins);

查询是否支持 LE Audio。

**参数** ：

  * ins 蓝牙客户端实例。


**返回值** ：

支持时返回 true，不支持时返回 false。

# 设备发现

### bt_adapter_set_discovery_filter
    
    
    bt_status_t bt_adapter_set_discovery_filter(bt_instance_t* ins);

设置设备发现过滤条件。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.


### bt_adapter_start_discovery
    
    
    bt_status_t bt_adapter_start_discovery(bt_instance_t* ins, uint32_t timeout);

开始设备发现。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * timeout 超时时间。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

### bt_adapter_cancel_discovery
    
    
    bt_status_t bt_adapter_cancel_discovery(bt_instance_t* ins);

取消设备发现。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

### bt_adapter_is_discovering
    
    
    bool bt_adapter_is_discovering(bt_instance_t* ins);

查询是否正在发现设备。

**参数** ：

  * ins 蓝牙客户端实例。


**返回值** ：

正在发现时返回 true，否则返回 false。

# 属性管理

### bt_adapter_get_type
    
    
    bt_device_type_t bt_adapter_get_type(bt_instance_t* ins);

获取设备类型。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.


### bt_adapter_set_name
    
    
    bt_status_t bt_adapter_set_name(bt_instance_t* ins, const char* name);

设置设备名称。

**参数** ：

  * ins 蓝牙客户端实例。
  * name 名称。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

### bt_adapter_get_name
    
    
    void bt_adapter_get_name(bt_instance_t* ins, char* name, int length);

获取设备名称。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * name 输出参数，存储适配器名称。
  * length 缓冲区长度。


### bt_adapter_set_scan_mode
    
    
    bt_status_t bt_adapter_set_scan_mode(bt_instance_t* ins, bt_scan_mode_t mode, bool bondable);

设置扫描模式。

**参数** ：

  * ins 蓝牙客户端实例。
  * mode 扫描模式。
  * bondable 是否可配对。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

### bt_adapter_get_scan_mode
    
    
    bt_scan_mode_t bt_adapter_get_scan_mode(bt_instance_t* ins);

获取扫描模式。

**参数** ：

  * ins 蓝牙客户端实例。


**返回值** ：

返回扫描模式枚举值，参见 bt_scan_mode_t。  

    
    
    bt_status_t bt_adapter_set_device_class(bt_instance_t* ins, uint32_t cod);

设置设备类型（CoD）。

**参数** ：

  * ins 蓝牙客户端实例。
  * cod 设备类型（CoD）。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回负的错误码。。

### bt_adapter_get_device_class
    
    
    uint32_t bt_adapter_get_device_class(bt_instance_t* ins);

获取设备类型（CoD）。

**参数** ：

  * ins 蓝牙客户端实例。


**返回值** ：

返回 24 位 Class of Device 值。  

    
    
    bt_status_t bt_adapter_set_debug_mode(bt_instance_t* ins, bt_debug_mode_t mode, uint8_t operation);

设置蓝牙适配器的调试模式，用于工厂测试和射频认证。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * mode 调试模式。
  * operation 调试操作。


### bt_adapter_set_le_address
    
    
    bt_status_t bt_adapter_set_le_address(bt_instance_t* ins, bt_address_t* addr);

设置本地 BLE 地址。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * addr BLE 身份地址。


### bt_adapter_set_le_appearance
    
    
    bt_status_t bt_adapter_set_le_appearance(bt_instance_t* ins, uint16_t appearance);

设置 BLE 外观值。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * appearance BLE 外观值。


### bt_adapter_le_add_whitelist_with_type
    
    
    bt_status_t bt_adapter_le_add_whitelist_with_type(bt_instance_t* ins, bt_address_t* addr, ble_addr_type_t type);

BLE 连接添加BLE 白名单（指定类型）特征值（签名写入）type。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * addr 设备地址。
  * type 地址类型。


# 配对与安全

### bt_adapter_set_io_capability
    
    
    bt_status_t bt_adapter_set_io_capability(bt_instance_t* ins, bt_io_capability_t cap);

设置 IO 能力。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * cap IO 能力值。


### bt_adapter_get_bonded_devices
    
    
    bt_status_t bt_adapter_get_bonded_devices(bt_instance_t* ins, bt_transport_t transport, bt_address_t** addr, int* num, bt_allocator_t allocator);

获取已配对设备列表。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * transport Transport type, 参见 bt_transport_t.
  * allocator 内存分配函数。
  * addr 输出参数，存储已配对设备地址数组。
  * num 输出参数，存储设备数量。


### bt_adapter_disconnect_all_devices
    
    
    void bt_adapter_disconnect_all_devices(bt_instance_t* ins);

断开所有已连接设备。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.


### bt_adapter_get_le_io_capability
    
    
    uint32_t bt_adapter_get_le_io_capability(bt_instance_t* ins);

获取 BLE IO 能力。

**参数** ：

  * ins 蓝牙客户端实例。


**返回值** ：

返回 BLE IO 能力值。

# BLE 管理

### bt_adapter_enable
    
    
    bt_status_t bt_adapter_enable(bt_instance_t* ins);

启用蓝牙适配器。

**参数** ：

  * ins 蓝牙客户端实例。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

### bt_adapter_disable
    
    
    bt_status_t bt_adapter_disable(bt_instance_t* ins);

禁用蓝牙适配器。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

### bt_adapter_disable_safe
    
    
    bt_status_t bt_adapter_disable_safe(bt_instance_t* ins);

安全禁用蓝牙适配器，等待所有连接断开后再关闭。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.


### bt_adapter_disable_le
    
    
    bt_status_t bt_adapter_disable_le(bt_instance_t* ins);

禁用低功耗蓝牙（BLE）。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.


### bt_adapter_is_le_enabled
    
    
    bool bt_adapter_is_le_enabled(bt_instance_t* ins);

查询 BLE 是否已启用。

**参数** ：

  * ins 蓝牙客户端实例。


**返回值** ：

已启用时返回 true，未启用时返回 false。

### bt_adapter_le_enable_key_derivation
    
    
    bt_status_t bt_adapter_le_enable_key_derivation(bt_instance_t* ins, bool brkey_to_lekey, bool lekey_to_brkey);

启用 BLE 密钥派生。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * brkey_to_lekey 是否启用 BR→LE 密钥派生。
  * lekey_to_brkey 是否启用 LE→BR 密钥派生。


### bt_adapter_le_remove_whitelist
    
    
    bt_status_t bt_adapter_le_remove_whitelist(bt_instance_t* ins, bt_address_t* addr);

从 BLE 白名单移除设备。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * addr 要移除的设备地址。


### bt_adapter_set_page_scan_parameters
    
    
    bt_status_t bt_adapter_set_page_scan_parameters(bt_instance_t* ins, bt_scan_type_t type, uint16_t interval, uint16_t window);

设置页面扫描参数。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * type 扫描类型。
  * interval 扫描间隔。
  * window 扫描窗口。


# 异步接口

### bt_adapter_register_callback_async
    
    
    bt_status_t bt_adapter_register_callback_async(bt_instance_t* ins, const adapter_callbacks_t* adapter_cbs, bt_register_callback_cb_t cb, void* userdata);

异步版本。

**参数** ：

  * ins 蓝牙客户端实例。
  * adapter_cbs 适配器回调函数集合。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_unregister_callback_async
    
    
    bt_status_t bt_adapter_unregister_callback_async(bt_instance_t* ins, void* cookie, bt_bool_cb_t cb, void* userdata);

取消注册回调函数（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * cookie 用户上下文。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_enable_async
    
    
    bt_status_t bt_adapter_enable_async(bt_instance_t* ins, bt_status_cb_t cb, void* userdata);

适配器状态变更回调（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_disable_async
    
    
    bt_status_t bt_adapter_disable_async(bt_instance_t* ins, bt_status_cb_t cb, void* userdata);

禁用蓝牙适配器.（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_enable_le_async
    
    
    bt_status_t bt_adapter_enable_le_async(bt_instance_t* ins, bt_status_cb_t cb, void* userdata);

启用低功耗蓝牙（BLE）.（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_disable_le_async
    
    
    bt_status_t bt_adapter_disable_le_async(bt_instance_t* ins, bt_status_cb_t cb, void* userdata);

禁用低功耗蓝牙（BLE）.（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_get_state_async
    
    
    bt_status_t bt_adapter_get_state_async(bt_instance_t* ins, bt_adapter_get_state_cb_t get_state_cb, void* userdata);

获取当前适配器状态（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * get_state_cb 获取状态的回调函数。
  * userdata 用户数据。


### bt_adapter_is_le_enabled_async
    
    
    bt_status_t bt_adapter_is_le_enabled_async(bt_instance_t* ins, bt_bool_cb_t cb, void* userdata);

Check if BLE is enabled（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_get_type_async
    
    
    bt_status_t bt_adapter_get_type_async(bt_instance_t* ins, bt_device_type_cb_t get_dtype_cb, void* userdata);

获取适配器设备类型（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * get_dtype_cb 获取设备类型的回调函数。
  * userdata 用户数据。


### bt_adapter_set_discovery_filter_async
    
    
    bt_status_t bt_adapter_set_discovery_filter_async(bt_instance_t* ins, bt_status_cb_t cb, void* userdata);

设置发现过滤器（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_start_discovery_async
    
    
    bt_status_t bt_adapter_start_discovery_async(bt_instance_t* ins, uint32_t timeout, bt_status_cb_t cb, void* userdata);

开始设备发现.（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * timeout 超时时间。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_cancel_discovery_async
    
    
    bt_status_t bt_adapter_cancel_discovery_async(bt_instance_t* ins, bt_status_cb_t cb, void* userdata);

取消设备发现.（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_is_discovering_async
    
    
    bt_status_t bt_adapter_is_discovering_async(bt_instance_t* ins, bt_bool_cb_t cb, void* userdata);

查询适配器是否正在发现设备（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_get_address_async
    
    
    bt_status_t bt_adapter_get_address_async(bt_instance_t* ins, bt_address_cb_t cb, void* userdata);

读取蓝牙控制器地址（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_set_name_async
    
    
    bt_status_t bt_adapter_set_name_async(bt_instance_t* ins, const char* name, bt_status_cb_t cb, void* userdata);

设置适配器本地名称（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * name 名称。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_get_name_async
    
    
    bt_status_t bt_adapter_get_name_async(bt_instance_t* ins, bt_string_cb_t get_name_cb, void* userdata);

获取适配器本地名称（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * get_name_cb 获取名称的回调函数。
  * userdata 用户数据。


### bt_adapter_get_uuids_async
    
    
    bt_status_t bt_adapter_get_uuids_async(bt_instance_t* ins, bt_uuids_cb_t get_uuids_cb, void* userdata);

获取适配器支持的 UUID 列表（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * get_uuids_cb 获取 UUID 列表的回调函数。
  * userdata 用户数据。


### bt_adapter_set_scan_mode_async
    
    
    bt_status_t bt_adapter_set_scan_mode_async(bt_instance_t* ins, bt_scan_mode_t mode, bool bondable, bt_status_cb_t cb, void* userdata);

设置适配器扫描模式（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * mode 模式。
  * bondable 是否可配对。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_get_scan_mode_async
    
    
    bt_status_t bt_adapter_get_scan_mode_async(bt_instance_t* ins, bt_adapter_get_scan_mode_cb_t get_scan_mode_cb, void* userdata);

获取适配器扫描模式（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * get_scan_mode_cb 获取扫描模式的回调函数。
  * userdata 用户数据。


### bt_adapter_set_device_class_async
    
    
    bt_status_t bt_adapter_set_device_class_async(bt_instance_t* ins, uint32_t cod, bt_status_cb_t cb, void* userdata);

设置适配器设备类型（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * cod 设备类型（CoD）。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_get_device_class_async
    
    
    bt_status_t bt_adapter_get_device_class_async(bt_instance_t* ins, bt_u32_cb_t get_cod_cb, void* userdata);

获取适配器设备类型（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * get_cod_cb 获取设备类型的回调函数。
  * userdata 用户数据。


### bt_adapter_set_io_capability_async
    
    
    bt_status_t bt_adapter_set_io_capability_async(bt_instance_t* ins, bt_io_capability_t cap, bt_status_cb_t cb, void* userdata);

设置 BR/EDR 适配器 IO 能力（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * cap IO 能力值。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_get_io_capability_async
    
    
    bt_status_t bt_adapter_get_io_capability_async(bt_instance_t* ins, bt_adapter_get_io_capability_cb_t get_ioc_cb, void* userdata);

获取 BR/EDR 适配器 IO 能力（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * get_ioc_cb 获取 IO 能力的回调函数。
  * userdata 用户数据。


### bt_adapter_set_inquiry_scan_parameters_async
    
    
    bt_status_t bt_adapter_set_inquiry_scan_parameters_async(bt_instance_t* ins, bt_scan_type_t type, uint16_t interval, uint16_t window, bt_status_cb_t cb, void* userdata);

设置查询扫描参数（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * type 类型。
  * interval 间隔。
  * window 扫描窗口（时间槽数）。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_set_page_scan_parameters_async
    
    
    bt_status_t bt_adapter_set_page_scan_parameters_async(bt_instance_t* ins, bt_scan_type_t type, uint16_t interval, uint16_t window, bt_status_cb_t cb, void* userdata);

设置页面扫描参数（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * type 类型。
  * interval 间隔。
  * window 扫描窗口（时间槽数）。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_set_le_io_capability_async
    
    
    bt_status_t bt_adapter_set_le_io_capability_async(bt_instance_t* ins, uint32_t le_io_cap, bt_status_cb_t cb, void* userdata);

设置 BLE 适配器 IO 能力（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * le_io_cap BLE IO 能力值。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_get_le_io_capability_async
    
    
    bt_status_t bt_adapter_get_le_io_capability_async(bt_instance_t* ins, bt_u32_cb_t get_le_ioc_cb, void* userdata);

获取 BLE 适配器 IO 能力（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * get_le_ioc_cb 获取 BLE IO 能力的回调函数。
  * userdata 用户数据。


### bt_adapter_get_le_address_async
    
    
    bt_status_t bt_adapter_get_le_address_async(bt_instance_t* ins, bt_adapter_get_le_address_cb_t cb, void* userdata);

获取 BLE 适配器地址（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_set_le_address_async
    
    
    bt_status_t bt_adapter_set_le_address_async(bt_instance_t* ins, bt_address_t* addr, bt_status_cb_t cb, void* userdata);

设置 BLE 私有地址（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_set_le_identity_address_async
    
    
    bt_status_t bt_adapter_set_le_identity_address_async(bt_instance_t* ins, bt_address_t* addr, bool is_public, bt_status_cb_t cb, void* userdata);

设置 BLE 身份地址（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * is_public 是否使用公共地址。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_set_le_appearance_async
    
    
    bt_status_t bt_adapter_set_le_appearance_async(bt_instance_t* ins, uint16_t appearance, bt_status_cb_t cb, void* userdata);

设置 BLE 适配器外观值（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * appearance 外观值。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_get_le_appearance_async
    
    
    bt_status_t bt_adapter_get_le_appearance_async(bt_instance_t* ins, bt_u16_cb_t cb, void* userdata);

获取 BLE 适配器外观值（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_le_enable_key_derivation_async
    
    
    bt_status_t bt_adapter_le_enable_key_derivation_async(bt_instance_t* ins, bool brkey_to_lekey, bool lekey_to_brkey, bt_status_cb_t cb, void* userdata);

启用或禁用跨传输密钥派生（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * brkey_to_lekey 是否启用 BR 密钥派生 LE 密钥。
  * lekey_to_brkey 是否启用 LE 密钥派生 BR 密钥。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_le_add_whitelist_async
    
    
    bt_status_t bt_adapter_le_add_whitelist_async(bt_instance_t* ins, bt_address_t* addr, bt_status_cb_t cb, void* userdata);

添加设备到 BLE 白名单（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_le_remove_whitelist_async
    
    
    bt_status_t bt_adapter_le_remove_whitelist_async(bt_instance_t* ins, bt_address_t* addr, bt_status_cb_t cb, void* userdata);

从 BLE 白名单移除设备（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_get_bonded_devices_async
    
    
    bt_status_t bt_adapter_get_bonded_devices_async(bt_instance_t* ins, bt_transport_t transport, bt_adapter_get_devices_cb_t get_bonded_cb, void* userdata);

获取已配对设备列表（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * transport 传输类型（BR/EDR 或 BLE）。
  * get_bonded_cb 获取已配对设备列表的回调函数。
  * userdata 用户数据。


### bt_adapter_get_connected_devices_async
    
    
    bt_status_t bt_adapter_get_connected_devices_async(bt_instance_t* ins, bt_transport_t transport, bt_adapter_get_devices_cb_t get_connected_cb, void* userdata);

获取已连接设备列表（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * transport 传输类型（BR/EDR 或 BLE）。
  * get_connected_cb 获取已连接设备列表的回调函数。
  * userdata 用户数据。


### bt_adapter_set_afh_channel_classification_async
    
    
    bt_status_t bt_adapter_set_afh_channel_classification_async(bt_instance_t* ins, uint16_t central_frequency, uint16_t band_width, uint16_t number, bt_status_cb_t cb, void* userdata);

设置 AFH 自适应跳频信道分类（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * central_frequency 中心频率（MHz）。
  * band_width 带宽（MHz）。
  * number 号码。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_set_auto_sniff_async
    
    
    bt_status_t bt_adapter_set_auto_sniff_async(bt_instance_t* ins, bt_auto_sniff_params_t* params, bt_status_cb_t cb, void* userdata);

设置自动 Sniff 模式参数（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * params 参数结构体。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_disconnect_all_devices_async
    
    
    bt_status_t bt_adapter_disconnect_all_devices_async(bt_instance_t* ins, bt_status_cb_t cb, void* userdata);

断开所有已连接设备（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_is_support_bredr_async
    
    
    bt_status_t bt_adapter_is_support_bredr_async(bt_instance_t* ins, bt_bool_cb_t cb, void* userdata);

Check if BR/EDR is supported（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_is_support_le_async
    
    
    bt_status_t bt_adapter_is_support_le_async(bt_instance_t* ins, bt_bool_cb_t cb, void* userdata);

Check if BLE is supported（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * cb 回调函数。
  * userdata 用户数据。


### bt_adapter_is_support_leaudio_async
    
    
    bt_status_t bt_adapter_is_support_leaudio_async(bt_instance_t* ins, bt_bool_cb_t cb, void* userdata);

查询是否支持 LE Audio（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * cb 回调函数。
  * userdata 用户数据。

---

## 蓝牙 GATT API

> 路径: 应用框架 > 蓝牙（Bluetooth） > 蓝牙 GATT API
> 来源: [https://doc.openvela.com/document?id=1126&language=cn&version=dev](https://doc.openvela.com/document?id=1126&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/bluetooth/bt_gatt.md>) | 简体中文 ]

# 蓝牙 GATT API

openvela 蓝牙 GATT（通用属性规范）接口，支持 BLE 数据属性的读写与通知。

头文件：#include "bt_gattc.h"、#include "bt_gatts.h"

# openvela 实现说明

  * **双角色支持** ：Client（GATTC，发起读写请求）和 Server（GATTS，提供服务和特征值）
  * **BLE 核心** ：GATT 是 BLE 数据交换的基础协议


# 同步接口

## bt_gattc_create_connect
    
    
    bt_status_t bt_gattc_create_connect(bt_instance_t* ins, gattc_handle_t* phandle, gattc_callbacks_t* callbacks);

发起与远程设备的连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * phandle 输出参数，存储 GATT 客户端句柄。
  * callbacks 回调函数集合。


**返回值** ：

无返回值。

## bt_gattc_delete_connect
    
    
    bt_status_t bt_gattc_delete_connect(gattc_handle_t conn_handle);

发起与远程设备的连接。

**参数** ：

  * conn_handle 连接句柄。


**返回值** ：

建立连接。

## bt_gattc_connect
    
    
    bt_status_t bt_gattc_connect(gattc_handle_t conn_handle, bt_address_t* addr, ble_addr_type_t addr_type);

发起与远程设备的连接。

**参数** ：

  * conn_handle 连接句柄。
  * addr 远程设备蓝牙地址。
  * addr_type BLE 地址类型。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_gattc_disconnect
    
    
    bt_status_t bt_gattc_disconnect(gattc_handle_t conn_handle);

断开与远程设备的连接。

**参数** ：

  * conn_handle 连接句柄。


**返回值** ：

断开连接。

## bt_gattc_discover_service
    
    
    bt_status_t bt_gattc_discover_service(gattc_handle_t conn_handle, bt_uuid_t* filter_uuid);

发现远程设备上的 GATT 服务，结果通过回调异步返回。

**参数** ：

  * conn_handle 连接句柄。
  * filter_uuid 服务 UUID 过滤条件（NULL 表示不过滤）。


**返回值** ：

bt_gattc_discover_service 操作。

## bt_gattc_get_attribute_by_handle
    
    
    bt_status_t bt_gattc_get_attribute_by_handle(gattc_handle_t conn_handle, uint16_t attr_handle, gatt_attr_desc_t* attr_desc);

通过属性句柄获取 GATT 属性信息。

**参数** ：

  * conn_handle 连接句柄。
  * attr_handle 属性句柄。
  * attr_desc 输出参数，存储属性描述信息。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_gattc_get_attribute_by_uuid
    
    
    bt_status_t bt_gattc_get_attribute_by_uuid(gattc_handle_t conn_handle, uint16_t start_handle, uint16_t end_handle, bt_uuid_t* attr_uuid, gatt_attr_desc_t* attr_desc);

通过 UUID 获取 GATT 属性信息。

**参数** ：

  * conn_handle 连接句柄。
  * start_handle 起始句柄。
  * end_handle 结束句柄。
  * attr_uuid 属性 UUID。
  * attr_desc 输出参数，存储属性描述信息。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_gattc_read
    
    
    bt_status_t bt_gattc_read(gattc_handle_t conn_handle, uint16_t attr_handle);

读取远程设备的 GATT 特征值或描述符，结果通过回调异步返回。

**参数** ：

  * conn_handle 连接句柄。
  * attr_handle 属性句柄。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_gattc_write
    
    
    bt_status_t bt_gattc_write(gattc_handle_t conn_handle, uint16_t attr_handle, uint8_t* value, uint16_t length);

向远程设备写入 GATT 特征值或描述符，等待确认后通过回调返回结果。

**参数** ：

  * conn_handle 连接句柄。
  * attr_handle 属性句柄。
  * value 值。
  * length 长度。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_gattc_write_without_response
    
    
    bt_status_t bt_gattc_write_without_response(gattc_handle_t conn_handle, uint16_t attr_handle, uint8_t* value, uint16_t length);

向远程设备写入 GATT 特征值（Write Without Response），不等待确认。

**参数** ：

  * conn_handle 连接句柄。
  * attr_handle 属性句柄。
  * value 值。
  * length 长度。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_gattc_write_with_signed
    
    
    bt_status_t bt_gattc_write_with_signed(gattc_handle_t conn_handle, uint16_t attr_handle, uint8_t* value, uint16_t length);

向远程设备写入 GATT 特征值（Signed Write），使用签名认证。

**参数** ：

  * conn_handle 连接句柄。
  * attr_handle 属性句柄。
  * value 值。
  * length 长度。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_gattc_subscribe
    
    
    bt_status_t bt_gattc_subscribe(gattc_handle_t conn_handle, uint16_t attr_handle, uint16_t ccc_value);

订阅远程设备的 GATT 特征值通知或指示（Notification/Indication）。

**参数** ：

  * conn_handle 连接句柄。
  * attr_handle 属性句柄。
  * ccc_value CCCD 值（0 禁用，1 通知，2 指示）。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_gattc_unsubscribe
    
    
    bt_status_t bt_gattc_unsubscribe(gattc_handle_t conn_handle, uint16_t attr_handle);

取消订阅远程设备的 GATT 特征值通知或指示。

**参数** ：

  * conn_handle 连接句柄。
  * attr_handle 属性句柄。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_gattc_exchange_mtu
    
    
    bt_status_t bt_gattc_exchange_mtu(gattc_handle_t conn_handle, uint32_t mtu);

与远程设备协商 ATT MTU 大小，影响单次数据传输的最大长度。

**参数** ：

  * conn_handle 连接句柄。
  * mtu MTU 值。


**返回值** ：

bt_gattc_exchange_mtu 操作。

## bt_gattc_update_connection_parameter
    
    
    bt_status_t bt_gattc_update_connection_parameter(gattc_handle_t conn_handle, uint32_t min_interval, uint32_t max_interval, uint32_t latency, uint32_t timeout, uint32_t min_connection_event_length, uint32_t max_connection_event_length);

发起与远程设备的连接。

**参数** ：

  * conn_handle 连接句柄。
  * min_interval 最小间隔。
  * max_interval 最大间隔。
  * latency 从设备延迟。
  * timeout 超时时间。
  * min_connection_event_length 最小连接事件长度。
  * max_connection_event_length 最大连接事件长度。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_gattc_read_phy
    
    
    bt_status_t bt_gattc_read_phy(gattc_handle_t conn_handle);

读取远程设备的 GATT 特征值或描述符，结果通过回调异步返回。

**参数** ：

  * conn_handle 连接句柄。


**返回值** ：

bt_gattc_read_phy 操作。

## bt_gattc_update_phy
    
    
    bt_status_t bt_gattc_update_phy(gattc_handle_t conn_handle, ble_phy_type_t tx_phy, ble_phy_type_t rx_phy);

PHY 配置操作。

**参数** ：

  * conn_handle 连接句柄。
  * tx_phy 发送 PHY。
  * rx_phy 接收 PHY。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_gattc_read_rssi
    
    
    bt_status_t bt_gattc_read_rssi(gattc_handle_t conn_handle);

读取远程设备的 GATT 特征值或描述符，结果通过回调异步返回。

**参数** ：

  * conn_handle 连接句柄。


**返回值** ：

bt_gattc_read_rssi 操作。

## bt_gatts_register_service
    
    
    bt_status_t bt_gatts_register_service(bt_instance_t* ins, gatts_handle_t* phandle, gatts_callbacks_t* callbacks);

注册GATT 服务。

**参数** ：

  * ins 蓝牙客户端实例。
  * phandle 输出参数，存储 GATT 客户端句柄。
  * callbacks 回调函数集合。


**返回值** ：

## bt_gatts_unregister_service
    
    
    bt_status_t bt_gatts_unregister_service(gatts_handle_t srv_handle);

取消注册GATT 服务。

**参数** ：

  * srv_handle GATT 服务句柄。


**返回值** ：

bt_gatts_unregister_service 操作。

## bt_gatts_connect
    
    
    bt_status_t bt_gatts_connect(gatts_handle_t srv_handle, bt_address_t* addr, ble_addr_type_t addr_type);

发起与远程设备的连接。

**参数** ：

  * srv_handle GATT 服务句柄。
  * addr 远程设备蓝牙地址。
  * addr_type BLE 地址类型。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_gatts_connect_bear
    
    
    bt_status_t bt_gatts_connect_bear(gatts_handle_t srv_handle, bt_address_t* addr, ble_addr_type_t addr_type, uint8_t bear_type);

发起与远程设备的连接。

**参数** ：

  * srv_handle GATT 服务句柄。
  * addr 远程设备蓝牙地址。
  * addr_type BLE 地址类型。
  * bear_type 承载类型。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_gatts_disconnect
    
    
    bt_status_t bt_gatts_disconnect(gatts_handle_t srv_handle, bt_address_t* addr);

断开与远程设备的连接。

**参数** ：

  * srv_handle GATT 服务句柄。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_gatts_add_attr_table
    
    
    bt_status_t bt_gatts_add_attr_table(gatts_handle_t srv_handle, gatt_srv_db_t* srv_db);

向本地 GATT 服务器添加属性表（服务、特征值、描述符）。

**参数** ：

  * srv_handle GATT 服务句柄。
  * srv_db GATT 服务属性表。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_gatts_remove_attr_table
    
    
    bt_status_t bt_gatts_remove_attr_table(gatts_handle_t srv_handle, uint16_t attr_handle);

从本地 GATT 服务器移除属性表。

**参数** ：

  * srv_handle GATT 服务句柄。
  * attr_handle 属性句柄。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_gatts_set_attr_value
    
    
    bt_status_t bt_gatts_set_attr_value(gatts_handle_t srv_handle, uint16_t attr_handle, uint8_t* value, uint16_t length);

设置本地 GATT 属性的值。

**参数** ：

  * srv_handle GATT 服务句柄。
  * attr_handle 属性句柄。
  * value 值。
  * length 长度。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_gatts_get_attr_value
    
    
    bt_status_t bt_gatts_get_attr_value(gatts_handle_t srv_handle, uint16_t attr_handle, uint8_t* value, uint16_t* length);

获取本地 GATT 属性的值。

**参数** ：

  * srv_handle GATT 服务句柄。
  * attr_handle 属性句柄。
  * value 值。
  * length 长度。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_gatts_response
    
    
    bt_status_t bt_gatts_response(gatts_handle_t srv_handle, bt_address_t* addr, uint32_t req_handle, uint8_t* value, uint16_t length);

回复远程设备的 GATT 读写请求。

**参数** ：

  * srv_handle GATT 服务句柄。
  * addr 远程设备蓝牙地址。
  * req_handle 请求句柄。
  * value 值。
  * length 长度。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_gatts_notify
    
    
    bt_status_t bt_gatts_notify(gatts_handle_t srv_handle, bt_address_t* addr, uint16_t attr_handle, uint8_t* value, uint16_t length);

向已订阅的远程设备发送 GATT 通知（Notification），不需要确认。

**参数** ：

  * srv_handle GATT 服务句柄。
  * addr 远程设备蓝牙地址。
  * attr_handle 属性句柄。
  * value 值。
  * length 长度。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_gatts_indicate
    
    
    bt_status_t bt_gatts_indicate(gatts_handle_t srv_handle, bt_address_t* addr, uint16_t attr_handle, uint8_t* value, uint16_t length);

向已订阅的远程设备发送 GATT 指示（Indication），需要确认。

**参数** ：

  * srv_handle GATT 服务句柄。
  * addr 远程设备蓝牙地址。
  * attr_handle 属性句柄。
  * value 值。
  * length 长度。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_gatts_read_phy
    
    
    bt_status_t bt_gatts_read_phy(gatts_handle_t srv_handle, bt_address_t* addr);

读取 PHY 配置。

**参数** ：

  * srv_handle GATT 服务句柄。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_gatts_update_phy
    
    
    bt_status_t bt_gatts_update_phy(gatts_handle_t srv_handle, bt_address_t* addr, ble_phy_type_t tx_phy, ble_phy_type_t rx_phy);

PHY 配置操作。

**参数** ：

  * srv_handle GATT 服务句柄。
  * addr 远程设备蓝牙地址。
  * tx_phy 发送 PHY。
  * rx_phy 接收 PHY。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

# 异步接口

## bt_gattc_create_connect_async
    
    
    bt_status_t bt_gattc_create_connect_async(bt_instance_t* ins, gattc_handle_t* phandle, gattc_callbacks_t* callbacks, bt_gattc_create_connect_cb_t cb, void* userdata);

建立连接（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * phandle 输出参数，存储 GATT 客户端句柄。
  * callbacks 回调函数集合。
  * cb 回调函数。
  * userdata 用户数据。


## bt_gattc_delete_connect_async
    
    
    bt_status_t bt_gattc_delete_connect_async(gattc_handle_t conn_handle, bt_status_cb_t bt_gattc_delete_connect_cb_t, void* userdata);

删除 GATT 客户端（异步版本）。

**参数** ：

  * conn_handle 连接句柄。
  * bt_gattc_delete_connect_cb_t 删除连接的回调函数。
  * userdata 用户数据。


## bt_gattc_connect_async
    
    
    bt_status_t bt_gattc_connect_async(gattc_handle_t conn_handle, bt_address_t* addr, ble_addr_type_t addr_type, bt_status_cb_t cb, void* userdata);

建立连接（异步版本）。

**参数** ：

  * conn_handle 连接句柄。
  * addr 远程设备蓝牙地址。
  * addr_type BLE 地址类型。
  * cb 回调函数。
  * userdata 用户数据。


## bt_gattc_disconnect_async
    
    
    bt_status_t bt_gattc_disconnect_async(gattc_handle_t conn_handle, bt_status_cb_t cb, void* userdata);

断开 ATT 承载连接（异步版本）。

**参数** ：

  * conn_handle 连接句柄。
  * cb 回调函数。
  * userdata 用户数据。


## bt_gattc_discover_service_async
    
    
    bt_status_t bt_gattc_discover_service_async(gattc_handle_t conn_handle, bt_uuid_t* filter_uuid, bt_status_cb_t cb, void* userdata);

发现GATT 服务（异步版本）。

**参数** ：

  * conn_handle 连接句柄。
  * filter_uuid 服务 UUID 过滤条件（NULL 表示不过滤）。
  * cb 回调函数。
  * userdata 用户数据。


## bt_gattc_get_attribute_by_handle_async
    
    
    bt_status_t bt_gattc_get_attribute_by_handle_async(gattc_handle_t conn_handle, uint16_t attr_handle, bt_gattc_get_attribute_cb_t cb, void* userdata);

通过属性句柄获取属性（异步版本）。

**参数** ：

  * conn_handle 连接句柄。
  * attr_handle 属性句柄。
  * cb 回调函数。
  * userdata 用户数据。


## bt_gattc_get_attribute_by_uuid_async
    
    
    bt_status_t bt_gattc_get_attribute_by_uuid_async(gattc_handle_t conn_handle, uint16_t start_handle, uint16_t end_handle, bt_uuid_t* attr_uuid, bt_gattc_get_attribute_cb_t cb, void* userdata);

获取属性（按 UUID）（异步版本）。

**参数** ：

  * conn_handle 连接句柄。
  * start_handle 起始句柄。
  * end_handle 结束句柄。
  * attr_uuid 属性 UUID。
  * cb 回调函数。
  * userdata 用户数据。


## bt_gattc_read_async
    
    
    bt_status_t bt_gattc_read_async(gattc_handle_t conn_handle, uint16_t attr_handle, bt_status_cb_t cb, void* userdata);

通过句柄读取属性值（异步版本）。

**参数** ：

  * conn_handle 连接句柄。
  * attr_handle 属性句柄。
  * cb 回调函数。
  * userdata 用户数据。


## bt_gattc_write_async
    
    
    bt_status_t bt_gattc_write_async(gattc_handle_t conn_handle, uint16_t attr_handle, uint8_t* value, uint16_t length, bt_status_cb_t cb, void* userdata);

写入操作（异步版本）。

**参数** ：

  * conn_handle 连接句柄。
  * attr_handle 属性句柄。
  * value 值。
  * length 长度。
  * cb 回调函数。
  * userdata 用户数据。


## bt_gattc_write_without_response_async
    
    
    bt_status_t bt_gattc_write_without_response_async(gattc_handle_t conn_handle, uint16_t attr_handle, uint8_t* value, uint16_t length, bt_gattc_write_cb_t cb, void* userdata);

向指定属性写入数据（异步版本）。

**参数** ：

  * conn_handle 连接句柄。
  * attr_handle 属性句柄。
  * value 值。
  * length 长度。
  * cb 回调函数。
  * userdata 用户数据。


## bt_gattc_subscribe_async
    
    
    bt_status_t bt_gattc_subscribe_async(gattc_handle_t conn_handle, uint16_t attr_handle, uint16_t ccc_value, bt_status_cb_t cb, void* userdata);

订阅操作（异步版本）。

**参数** ：

  * conn_handle 连接句柄。
  * attr_handle 属性句柄。
  * ccc_value CCCD 值（0 禁用，1 通知，2 指示）。
  * cb 回调函数。
  * userdata 用户数据。


## bt_gattc_unsubscribe_async
    
    
    bt_status_t bt_gattc_unsubscribe_async(gattc_handle_t conn_handle, uint16_t attr_handle, bt_status_cb_t cb, void* userdata);

禁用指定的 CCCD（客户端特征配置描述符）（异步版本）。

**参数** ：

  * conn_handle 连接句柄。
  * attr_handle 属性句柄。
  * cb 回调函数。
  * userdata 用户数据。


## bt_gattc_exchange_mtu_async
    
    
    bt_status_t bt_gattc_exchange_mtu_async(gattc_handle_t conn_handle, uint32_t mtu, bt_status_cb_t cb, void* userdata);

交换 MTU 大小（异步版本）。

**参数** ：

  * conn_handle 连接句柄。
  * mtu MTU 值。
  * cb 回调函数。
  * userdata 用户数据。


## bt_gattc_update_connection_parameter_async
    
    
    bt_status_t bt_gattc_update_connection_parameter_async(gattc_handle_t conn_handle, uint32_t min_interval, uint32_t max_interval, uint32_t latency, uint32_t timeout, uint32_t min_connection_event_length, uint32_t max_connection_event_length, bt_status_cb_t cb, void* userdata);

修改 BLE 连接参数（异步版本）。

**参数** ：

  * conn_handle 连接句柄。
  * min_interval 最小间隔。
  * max_interval 最大间隔。
  * latency 从设备延迟。
  * timeout 超时时间。
  * min_connection_event_length 最小连接事件长度。
  * max_connection_event_length 最大连接事件长度。
  * cb 回调函数。
  * userdata 用户数据。


## bt_gattc_read_phy_async
    
    
    bt_status_t bt_gattc_read_phy_async(gattc_handle_t conn_handle, bt_status_cb_t cb, void* userdata);

读取PHY 配置（异步版本）。

**参数** ：

  * conn_handle 连接句柄。
  * cb 回调函数。
  * userdata 用户数据。


## bt_gattc_update_phy_async
    
    
    bt_status_t bt_gattc_update_phy_async(gattc_handle_t conn_handle, ble_phy_type_t tx_phy, ble_phy_type_t rx_phy, bt_status_cb_t cb, void* userdata);

更新 PHY 配置（异步版本）。

**参数** ：

  * conn_handle 连接句柄。
  * tx_phy 发送 PHY。
  * rx_phy 接收 PHY。
  * cb 回调函数。
  * userdata 用户数据。


## bt_gattc_read_rssi_async
    
    
    bt_status_t bt_gattc_read_rssi_async(gattc_handle_t conn_handle, bt_status_cb_t cb, void* userdata);

读取 RSSI 值（异步版本）。

**参数** ：

  * conn_handle 连接句柄。
  * cb 回调函数。
  * userdata 用户数据。

---

## 蓝牙设备管理 API

> 路径: 应用框架 > 蓝牙（Bluetooth） > 蓝牙设备管理 API
> 来源: [https://doc.openvela.com/document?id=1127&language=cn&version=dev](https://doc.openvela.com/document?id=1127&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/bluetooth/bt_device.md>) | 简体中文 ]

# 蓝牙设备管理 API

openvela 蓝牙远程设备管理接口，提供设备配对、连接、属性查询和管理功能。

头文件：#include "bt_device.h"

# openvela 实现说明

  * **设备属性** ：支持查询远程设备名称、地址、类型、配对状态、连接状态等
  * **配对管理** ：支持发起配对、取消配对、确认配对请求
  * **连接管理** ：支持建立和断开与远程设备的连接
  * **异步模式** ：大部分 API 提供同步和异步两个版本


# 同步接口

## bt_device_get_identity_address
    
    
    bt_status_t bt_device_get_identity_address(bt_instance_t* ins, bt_address_t* bd_addr, bt_address_t* id_addr);

获取远程设备的身份地址（Identity Address），用于标识使用随机地址的 BLE 设备。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * bd_addr 远程设备 BLE 地址。- id_addr 输出参数，存储身份地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_device_get_address_type
    
    
    ble_addr_type_t bt_device_get_address_type(bt_instance_t* ins, bt_address_t* addr);

获取远程设备的 BLE 地址类型（Public/Static Random/RPA 等）。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * addr 远程设备地址.


**返回值** ：

返回设备的 BLE 地址类型，未找到时返回 BLE_ADDR_TYPE_UNKNOWN。

## bt_device_get_device_type
    
    
    bt_device_type_t bt_device_get_device_type(bt_instance_t* ins, bt_address_t* addr);

获取远程设备的类型（经典蓝牙/BLE/双模）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

## bt_device_get_name
    
    
    bool bt_device_get_name(bt_instance_t* ins, bt_address_t* addr, char* name, uint32_t length);

获取远程设备的蓝牙名称。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * name 名称。
  * length 长度。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_device_get_device_class
    
    
    uint32_t bt_device_get_device_class(bt_instance_t* ins, bt_address_t* addr);

获取远程设备的设备类型（Class of Device），包含主设备类、子设备类和服务类信息。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * addr 远程设备地址.


**返回值** ：

## bt_device_get_uuids
    
    
    bt_status_t bt_device_get_uuids(bt_instance_t* ins, bt_address_t* addr, bt_uuid_t** uuids, uint16_t* size, bt_allocator_t allocator);

获取远程设备支持的服务 UUID 列表。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * addr 远程设备地址.
  * allocator 内存分配函数。- uuids UUID 数组（由 allocator 分配）。
  * size 返回 UUID 数量。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_device_get_appearance
    
    
    uint16_t bt_device_get_appearance(bt_instance_t* ins, bt_address_t* addr);

获取远程设备的 BLE 外观特征值（Appearance），用于标识设备的物理外观。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * addr 远程设备地址.


## bt_device_get_rssi
    
    
    int8_t bt_device_get_rssi(bt_instance_t* ins, bt_address_t* addr);

获取远程设备的接收信号强度指示（RSSI）。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * addr 远程设备地址.


## bt_device_get_alias
    
    
    bool bt_device_get_alias(bt_instance_t* ins, bt_address_t* addr, char* alias, uint32_t length);

获取远程设备的用户自定义别名，未设置时返回设备名称。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * addr 远程设备地址.
  * length 长度。- alias 输出参数，存储别名字符串。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_device_set_alias
    
    
    bt_status_t bt_device_set_alias(bt_instance_t* ins, bt_address_t* addr, const char* alias);

设置远程设备的用户自定义别名，长度不超过 BT_LOC_NAME_MAX_LEN。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * addr 远程设备地址.
  * alias 设备别名。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回负的错误码。

## bt_device_is_connected
    
    
    bool bt_device_is_connected(bt_instance_t* ins, bt_address_t* addr, bt_transport_t transport);

发起与远程设备的连接。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * addr 远程设备地址.
  * transport Transport type, 参见 bt_transport_t.


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_device_is_encrypted
    
    
    bool bt_device_is_encrypted(bt_instance_t* ins, bt_address_t* addr, bt_transport_t transport);

查询与远程设备的连接是否已加密。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * addr 远程设备地址.
  * transport Transport type, 参见 bt_transport_t.


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_device_is_bond_initiate_local
    
    
    bool bt_device_is_bond_initiate_local(bt_instance_t* ins, bt_address_t* addr, bt_transport_t transport);

查询与远程设备的配对是否由本地发起。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * addr 远程设备地址.
  * transport Transport type, 参见 bt_transport_t.


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_device_get_bond_state
    
    
    bond_state_t bt_device_get_bond_state(bt_instance_t* ins, bt_address_t* addr, bt_transport_t transport);

获取与远程设备的配对状态。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * transport 传输类型（BR/EDR 或 BLE）。


**返回值** ：

返回当前配对状态，参见 bond_state_t。

## bt_device_is_bonded
    
    
    bool bt_device_is_bonded(bt_instance_t* ins, bt_address_t* addr, bt_transport_t transport);

查询远程设备是否已配对。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * transport 传输类型（BR/EDR 或 BLE）。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_device_create_bond
    
    
    bt_status_t bt_device_create_bond(bt_instance_t* ins, bt_address_t* addr, bt_transport_t transport);

发起与远程设备的配对（Bonding），建立长期安全关系。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * transport 传输类型（BR/EDR 或 BLE）。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回负的错误码。

## bt_device_set_security_level
    
    
    bt_status_t bt_device_set_security_level(bt_instance_t* ins, uint8_t level, bt_transport_t transport);

设置与远程设备的安全级别（0~4），级别越高安全性越强。

**参数** ：

  * ins 蓝牙客户端实例。
  * level 安全级别。
  * transport 传输类型（BR/EDR 或 BLE）。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_device_set_bondable_le
    
    
    bt_status_t bt_device_set_bondable_le(bt_instance_t* ins, bool bondable);

设置远程设备是否允许 BLE 配对。

**参数** ：

  * ins 蓝牙客户端实例。
  * bondable 是否可配对。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_device_remove_bond
    
    
    bt_status_t bt_device_remove_bond(bt_instance_t* ins, bt_address_t* addr, uint8_t transport);

移除与远程设备的配对关系，删除存储的配对密钥。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * transport 传输类型（BR/EDR 或 BLE）。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回负的错误码。

## bt_device_cancel_bond
    
    
    bt_status_t bt_device_cancel_bond(bt_instance_t* ins, bt_address_t* addr);

取消正在进行的配对过程。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回负的错误码。

## bt_device_pair_request_reply
    
    
    bt_status_t bt_device_pair_request_reply(bt_instance_t* ins, bt_address_t* addr, bool accept);

回复远程设备的配对请求，接受或拒绝配对。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * accept 是否接受。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回负的错误码。

## bt_device_set_pairing_confirmation
    
    
    bt_status_t bt_device_set_pairing_confirmation(bt_instance_t* ins, bt_address_t* addr, uint8_t transport, bool accept);

确认或拒绝 SSP 配对的数字比较请求。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * transport 传输类型（BR/EDR 或 BLE）。
  * accept 是否接受。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回负的错误码。

## bt_device_set_pin_code
    
    
    bt_status_t bt_device_set_pin_code(bt_instance_t* ins, bt_address_t* addr, bool accept, char* pincode, int len);

设置 PIN 码用于传统配对认证。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * accept 是否接受。
  * pincode PIN 码字符串。
  * len 长度。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回负的错误码。

## bt_device_set_pass_key
    
    
    bt_status_t bt_device_set_pass_key(bt_instance_t* ins, bt_address_t* addr, uint8_t transport, bool accept, uint32_t passkey);

设置数字密钥用于 SSP 配对认证。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * transport 传输类型（BR/EDR 或 BLE）。
  * accept 是否接受。
  * passkey 配对密钥。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回负的错误码。

## bt_device_set_le_legacy_tk
    
    
    bt_status_t bt_device_set_le_legacy_tk(bt_instance_t* ins, bt_address_t* addr, bt_128key_t tk_val);

设置 BLE Legacy 配对 TK 值。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * tk_val OOB TK 值。


## bt_device_set_le_sc_remote_oob_data
    
    
    bt_status_t bt_device_set_le_sc_remote_oob_data(bt_instance_t* ins, bt_address_t* addr, bt_128key_t c_val, bt_128key_t r_val);

设置远程设备的 BLE Secure Connections OOB 数据，用于带外配对。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * c_val SC 确认值（128 位）。
  * r_val SC 随机值（128 位）。

  * ins 蓝牙客户端实例, 参见 bt_instance_t.

  * addr 远程设备地址.
  * c_val LE 安全连接确认值（128 位密钥）。
  * r_val LE 安全连接随机值（128 位密钥）。


## bt_device_get_le_sc_local_oob_data
    
    
    bt_status_t bt_device_get_le_sc_local_oob_data(bt_instance_t* ins, bt_address_t* addr);

获取 BLE SC 本地 OOB 数据。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回负的错误码。

## bt_device_connect
    
    
    bt_status_t bt_device_connect(bt_instance_t* ins, bt_address_t* addr);

发起与远程设备的连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回负的错误码。

## bt_device_background_connect
    
    
    bt_status_t bt_device_background_connect(bt_instance_t* ins, bt_address_t* addr, bt_transport_t transport);

发起与远程设备的连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * transport 传输类型（BR/EDR 或 BLE）。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_device_disconnect
    
    
    bt_status_t bt_device_disconnect(bt_instance_t* ins, bt_address_t* addr);

断开与远程设备的连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回负的错误码。

## bt_device_background_disconnect
    
    
    bt_status_t bt_device_background_disconnect(bt_instance_t* ins, bt_address_t* addr, bt_transport_t transport);

断开与远程设备的连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * transport 传输类型（BR/EDR 或 BLE）。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_device_connect_le
    
    
    bt_status_t bt_device_connect_le(bt_instance_t* ins, bt_address_t* addr, ble_addr_type_t type, ble_connect_params_t* param);

发起与远程设备的 BLE 连接。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * addr 蓝牙地址。
  * type LE address type, 参见 ble_addr_type_t.
  * param 指向 connection parameters, 参见 ble_connect_params_t.


## bt_device_disconnect_le
    
    
    bt_status_t bt_device_disconnect_le(bt_instance_t* ins, bt_address_t* addr);

断开与远程设备的 BLE 连接。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * addr 蓝牙地址。


## bt_device_connect_request_reply
    
    
    bt_status_t bt_device_connect_request_reply(bt_instance_t* ins, bt_address_t* addr, bool accept);

回复远程设备的连接请求，接受或拒绝连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * accept 是否接受。


## bt_device_set_le_phy
    
    
    bt_status_t bt_device_set_le_phy(bt_instance_t* ins, bt_address_t* addr, ble_phy_type_t tx_phy, ble_phy_type_t rx_phy);

设置与远程设备的 BLE PHY 配置（1M/2M/Coded）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * tx_phy 发送 PHY。
  * rx_phy 接收 PHY。

  * ins 蓝牙客户端实例, 参见 bt_instance_t.

  * addr 蓝牙地址。
  * tx_phy Preferred TX PHY, 参见 ble_phy_type_t.
  * rx_phy Preferred RX PHY, 参见 ble_phy_type_t.


## bt_device_connect_all_profile
    
    
    void bt_device_connect_all_profile(bt_instance_t* ins, bt_address_t* addr);

连接所有 Profile 连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


## bt_device_disconnect_all_profile
    
    
    void bt_device_disconnect_all_profile(bt_instance_t* ins, bt_address_t* addr);

断开与远程设备的所有 Profile 连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


## bt_device_enable_enhanced_mode
    
    
    bt_status_t bt_device_enable_enhanced_mode(bt_instance_t* ins, bt_address_t* addr, bt_enhanced_mode_t mode);

启用与远程设备的增强模式。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * mode 模式。


## bt_device_disable_enhanced_mode
    
    
    bt_status_t bt_device_disable_enhanced_mode(bt_instance_t* ins, bt_address_t* addr, bt_enhanced_mode_t mode);

禁用与远程设备的增强模式。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * addr 远程设备地址.
  * mode Enhanced mode to disable, 参见 bt_enhanced_mode_t.


# 异步接口

## bt_device_get_identity_address_async
    
    
    bt_status_t bt_device_get_identity_address_async(bt_instance_t* ins, bt_address_t* bd_addr, bt_address_cb_t cb, void* userdata);

获取身份地址（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * bd_addr BLE 地址。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_get_address_type_async
    
    
    bt_status_t bt_device_get_address_type_async(bt_instance_t* ins, bt_address_t* addr, bt_device_get_address_type_cb_t cb, void* userdata);

获取远程设备的 BLE 地址类型。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_get_device_type_async
    
    
    bt_status_t bt_device_get_device_type_async(bt_instance_t* ins, bt_address_t* addr, bt_device_type_cb_t cb, void* userdata);

获取设备类型（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_get_name_async
    
    
    bt_status_t bt_device_get_name_async(bt_instance_t* ins, bt_address_t* addr, bt_string_cb_t cb, void* userdata);

获取远程设备名称（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_get_device_class_async
    
    
    bt_status_t bt_device_get_device_class_async(bt_instance_t* ins, bt_address_t* addr, bt_u32_cb_t cb, void* userdata);

获取设备类型（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_get_uuids_async
    
    
    bt_status_t bt_device_get_uuids_async(bt_instance_t* ins, bt_address_t* addr, bt_uuids_cb_t cb, void* userdata);

获取远程设备支持的 UUID 列表。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_get_appearance_async
    
    
    bt_status_t bt_device_get_appearance_async(bt_instance_t* ins, bt_address_t* addr, bt_u16_cb_t cb, void* userdata);

获取外观特征值（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_get_rssi_async
    
    
    bt_status_t bt_device_get_rssi_async(bt_instance_t* ins, bt_address_t* addr, bt_s8_cb_t cb, void* userdata);

获取远程设备的 RSSI（接收信号强度）。（异步版本）

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_get_alias_async
    
    
    bt_status_t bt_device_get_alias_async(bt_instance_t* ins, bt_address_t* addr, bt_string_cb_t cb, void* userdata);

获取别名（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_set_alias_async
    
    
    bt_status_t bt_device_set_alias_async(bt_instance_t* ins, bt_address_t* addr, const char* alias, bt_status_cb_t cb, void* userdata);

设置远程设备的别名。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * alias 别名。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_is_connected_async
    
    
    bt_status_t bt_device_is_connected_async(bt_instance_t* ins, bt_address_t* addr, bt_transport_t transport, bt_bool_cb_t cb, void* userdata);

检查是否已连接（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * transport 传输类型（BR/EDR 或 BLE）。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_is_encrypted_async
    
    
    bt_status_t bt_device_is_encrypted_async(bt_instance_t* ins, bt_address_t* addr, bt_transport_t transport, bt_bool_cb_t cb, void* userdata);

检查与远程设备的连接是否已加密。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * transport 传输类型（BR/EDR 或 BLE）。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_is_bond_initiate_local_async
    
    
    bt_status_t bt_device_is_bond_initiate_local_async(bt_instance_t* ins, bt_address_t* addr, bt_transport_t transport, bt_bool_cb_t cb, void* userdata);

查询配对是否由本地发起（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * transport 传输类型（BR/EDR 或 BLE）。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_get_bond_state_async
    
    
    bt_status_t bt_device_get_bond_state_async(bt_instance_t* ins, bt_address_t* addr, bt_transport_t transport, bt_device_get_bond_state_cb_t cb, void* userdata);

获取与远程设备的配对状态（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * transport 传输类型（BR/EDR 或 BLE）。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_is_bonded_async
    
    
    bt_status_t bt_device_is_bonded_async(bt_instance_t* ins, bt_address_t* addr, bt_transport_t transport, bt_bool_cb_t cb, void* userdata);

查询是否已配对（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * transport 传输类型（BR/EDR 或 BLE）。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_connect_async
    
    
    bt_status_t bt_device_connect_async(bt_instance_t* ins, bt_address_t* addr, bt_status_cb_t cb, void* userdata);

连接远程设备（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_disconnect_async
    
    
    bt_status_t bt_device_disconnect_async(bt_instance_t* ins, bt_address_t* addr, bt_status_cb_t cb, void* userdata);

断开连接（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_connect_le_async
    
    
    bt_status_t bt_device_connect_le_async(bt_instance_t* ins, bt_address_t* addr, ble_addr_type_t type, ble_connect_params_t* param, bt_status_cb_t cb, void* userdata);

连接远程 BLE 设备（异步版本，支持指定连接参数）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * type 类型。
  * param 连接参数结构体。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_disconnect_le_async
    
    
    bt_status_t bt_device_disconnect_le_async(bt_instance_t* ins, bt_address_t* addr, bt_status_cb_t cb, void* userdata);

断开BLE 连接（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_connect_request_reply_async
    
    
    bt_status_t bt_device_connect_request_reply_async(bt_instance_t* ins, bt_address_t* addr, bool accept, bt_status_cb_t cb, void* userdata);

回复连接请求（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * accept 是否接受。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_connect_all_profile_async
    
    
    bt_status_t bt_device_connect_all_profile_async(bt_instance_t* ins, bt_address_t* addr, bt_status_cb_t cb, void* userdata);

连接所有 Profile 连接（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_disconnect_all_profile_async
    
    
    bt_status_t bt_device_disconnect_all_profile_async(bt_instance_t* ins, bt_address_t* addr, bt_status_cb_t cb, void* userdata);

断开所有 Profile 连接（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_set_le_phy_async
    
    
    bt_status_t bt_device_set_le_phy_async(bt_instance_t* ins, bt_address_t* addr, ble_phy_type_t tx_phy, ble_phy_type_t rx_phy, bt_status_cb_t cb, void* userdata);

设置BLE PHY 配置（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * tx_phy 发送 PHY。
  * rx_phy 接收 PHY。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_create_bond_async
    
    
    bt_status_t bt_device_create_bond_async(bt_instance_t* ins, bt_address_t* addr, bt_transport_t transport, bt_status_cb_t cb, void* userdata);

发起与远程设备的配对（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * transport 传输类型（BR/EDR 或 BLE）。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_remove_bond_async
    
    
    bt_status_t bt_device_remove_bond_async(bt_instance_t* ins, bt_address_t* addr, uint8_t transport, bt_status_cb_t cb, void* userdata);

取消配对（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * transport 传输类型（BR/EDR 或 BLE）。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_cancel_bond_async
    
    
    bt_status_t bt_device_cancel_bond_async(bt_instance_t* ins, bt_address_t* addr, bt_status_cb_t cb, void* userdata);

取消正在进行的配对（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_pair_request_reply_async
    
    
    bt_status_t bt_device_pair_request_reply_async(bt_instance_t* ins, bt_address_t* addr, bool accept, bt_status_cb_t cb, void* userdata);

配对配对请求回复（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * accept 是否接受。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_set_pairing_confirmation_async
    
    
    bt_status_t bt_device_set_pairing_confirmation_async(bt_instance_t* ins, bt_address_t* addr, uint8_t transport, bool accept, bt_status_cb_t cb, void* userdata);

设置安全配对确认（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * transport 传输类型（BR/EDR 或 BLE）。
  * accept 是否接受。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_set_pin_code_async
    
    
    bt_status_t bt_device_set_pin_code_async(bt_instance_t* ins, bt_address_t* addr, bool accept, char* pincode, int len, bt_status_cb_t cb, void* userdata);

设置 PIN 码（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * accept 是否接受。
  * pincode PIN 码字符串。
  * len 长度。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_set_pass_key_async
    
    
    bt_status_t bt_device_set_pass_key_async(bt_instance_t* ins, bt_address_t* addr, uint8_t transport, bool accept, uint32_t passkey, bt_status_cb_t cb, void* userdata);

设置配对密钥（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * transport 传输类型（BR/EDR 或 BLE）。
  * accept 是否接受。
  * passkey 配对密钥。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_set_le_legacy_tk_async
    
    
    bt_status_t bt_device_set_le_legacy_tk_async(bt_instance_t* ins, bt_address_t* addr, bt_128key_t tk_val, bt_status_cb_t cb, void* userdata);

设置 BLE Legacy 配对 TK 值（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * tk_val OOB TK 值。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_set_le_sc_remote_oob_data_async
    
    
    bt_status_t bt_device_set_le_sc_remote_oob_data_async(bt_instance_t* ins, bt_address_t* addr, bt_128key_t c_val, bt_128key_t r_val, bt_status_cb_t cb, void* userdata);

设置 LE SC 配对的远程 OOB 数据（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * c_val SC 确认值。
  * r_val SC 随机值。
  * cb 回调函数。
  * userdata 用户数据。


## bt_device_get_le_sc_local_oob_data_async
    
    
    bt_status_t bt_device_get_le_sc_local_oob_data_async(bt_instance_t* ins, bt_address_t* addr, bt_status_cb_t cb, void* userdata);

获取 LE SC 配对的本地 OOB 数据（异步版本）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * cb 回调函数。
  * userdata 用户数据。

---

## 蓝牙 A2DP API

> 路径: 应用框架 > 蓝牙（Bluetooth） > 蓝牙 A2DP API
> 来源: [https://doc.openvela.com/document?id=1130&language=cn&version=dev](https://doc.openvela.com/document?id=1130&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/bluetooth/bt_a2dp.md>) | 简体中文 ]

# 蓝牙 A2DP API

openvela 蓝牙 A2DP（高级音频分发）接口，支持音频流的发送（Source）和接收（Sink）。

头文件：#include "bt_a2dp.h"、#include "bt_a2dp_sink.h"、#include "bt_a2dp_source.h"

# openvela 实现说明

  * **双角色支持** ：Source（音频发送端）和 Sink（音频接收端）
  * **编解码器** ：支持 SBC 和 AAC
  * **传输模式** ：支持硬件卸载（Offloading）和非卸载模式


# 连接状态机

A2DP 连接建立、流传输以及断开过程中的状态转换如下图所示：

![A2DP 状态机](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455195169_a2dp.png)

各状态含义：

  * **Idle** ：空闲，未建立 A2DP 连接。
  * **Opening** ：正在建立 A2DP 连接（本端发起 A2DP connect 之后）。
  * **Opened** ：A2DP 信令连接已建立，可准备音频流。
  * **Started** ：音频流已启动，正在传输音频数据。
  * **Closing** ：正在断开 A2DP 连接，直至对端确认 A2DP disconnected。


# 同步接口

## bt_a2dp_sink_unregister_callbacks
    
    
    bool bt_a2dp_sink_unregister_callbacks(bt_instance_t* ins, void* cookie);

取消注册回调函数，停止接收状态变更通知。

**参数** ：

  * ins 蓝牙客户端实例。
  * cookie 用户上下文。


**返回值** ：

成功时返回 true，失败时返回 false。

## bt_a2dp_sink_is_connected
    
    
    bool bt_a2dp_sink_is_connected(bt_instance_t* ins, bt_address_t* addr);

查询指定设备的 A2DP Sink 是否已连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 对端设备蓝牙地址。


**返回值** ：

已连接时返回 true，未连接时返回 false。

## bt_a2dp_sink_is_playing
    
    
    bool bt_a2dp_sink_is_playing(bt_instance_t* ins, bt_address_t* addr);

查询指定设备的 A2DP Sink 是否正在播放音频流。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 对端设备蓝牙地址。


**返回值** ：

正在播放时返回 true，未播放时返回 false。

## bt_a2dp_sink_get_connection_state
    
    
    profile_connection_state_t bt_a2dp_sink_get_connection_state(bt_instance_t* ins, bt_address_t* addr);

获取指定设备的 A2DP Sink 连接状态。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

返回当前连接状态枚举值，参见 profile_connection_state_t。

## bt_a2dp_sink_connect
    
    
    bt_status_t bt_a2dp_sink_connect(bt_instance_t* ins, bt_address_t* addr);

发起与远程设备的 A2DP Sink 连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 对端设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_a2dp_sink_disconnect
    
    
    bt_status_t bt_a2dp_sink_disconnect(bt_instance_t* ins, bt_address_t* addr);

断开与远程设备的 A2DP Sink 连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 对端设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_a2dp_source_unregister_callbacks
    
    
    bool bt_a2dp_source_unregister_callbacks(bt_instance_t* ins, void* cookie);

取消注册回调函数，停止接收状态变更通知。

**参数** ：

  * ins 蓝牙客户端实例。
  * cookie 用户上下文。


**返回值** ：

成功时返回 true，失败时返回 false。

## bt_a2dp_source_is_connected
    
    
    bool bt_a2dp_source_is_connected(bt_instance_t* ins, bt_address_t* addr);

查询指定设备的 A2DP Source 是否已连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 对端设备蓝牙地址。


**返回值** ：

已连接时返回 true，未连接时返回 false。

## bt_a2dp_source_is_playing
    
    
    bool bt_a2dp_source_is_playing(bt_instance_t* ins, bt_address_t* addr);

查询指定设备的 A2DP Source 是否正在播放音频流。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 对端设备蓝牙地址。


**返回值** ：

正在播放时返回 true，未播放时返回 false。

## bt_a2dp_source_get_connection_state
    
    
    profile_connection_state_t bt_a2dp_source_get_connection_state(bt_instance_t* ins, bt_address_t* addr);

获取指定设备的 A2DP Source 连接状态。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

返回当前连接状态枚举值，参见 profile_connection_state_t。

## bt_a2dp_source_connect
    
    
    bt_status_t bt_a2dp_source_connect(bt_instance_t* ins, bt_address_t* addr);

发起与远程设备的 A2DP Source 连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 对端设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_a2dp_source_disconnect
    
    
    bt_status_t bt_a2dp_source_disconnect(bt_instance_t* ins, bt_address_t* addr);

断开与远程设备的连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_a2dp_source_set_silence_device
    
    
    bt_status_t bt_a2dp_source_set_silence_device(bt_instance_t* ins, bt_address_t* addr, bool silence);

设置静音设备。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * silence 是否设为静音模式（true 为静音）。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_a2dp_source_set_active_device
    
    
    bt_status_t bt_a2dp_source_set_active_device(bt_instance_t* ins, bt_address_t* addr);

设置活跃设备。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

---

## 蓝牙 HFP API

> 路径: 应用框架 > 蓝牙（Bluetooth） > 蓝牙 HFP API
> 来源: [https://doc.openvela.com/document?id=1132&language=cn&version=dev](https://doc.openvela.com/document?id=1132&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/bluetooth/bt_hfp.md>) | 简体中文 ]

# 蓝牙 HFP API

openvela 蓝牙 HFP（免提规范）接口，支持蓝牙通话功能。

头文件：#include "bt_hfp.h"、#include "bt_hfp_hf.h"、#include "bt_hfp_ag.h"

# openvela 实现说明

  * **双角色支持** ：HF（Hands-Free，免提端）和 AG（Audio Gateway，音频网关端）
  * **功能** ：接听/挂断电话、音量控制、语音识别、电话簿访问


# 同步接口

## bt_hfp_hf_unregister_callbacks
    
    
    bool bt_hfp_hf_unregister_callbacks(bt_instance_t* ins, void* cookie);

取消注册回调函数，停止接收状态变更通知。

**参数** ：

  * ins 蓝牙客户端实例。
  * cookie 用户上下文。


**返回值** ：

成功时返回 true，失败时返回 false。

## bt_hfp_hf_is_connected
    
    
    bool bt_hfp_hf_is_connected(bt_instance_t* ins, bt_address_t* addr);

查询与远程设备的 HFP HF 是否已连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

已连接时返回 true，未连接时返回 false。

## bt_hfp_hf_is_audio_connected
    
    
    bool bt_hfp_hf_is_audio_connected(bt_instance_t* ins, bt_address_t* addr);

查询与远程设备的 HFP 音频通道是否已连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

音频已连接时返回 true，未连接时返回 false。

## bt_hfp_hf_get_connection_state
    
    
    profile_connection_state_t bt_hfp_hf_get_connection_state(bt_instance_t* ins, bt_address_t* addr);

获取与远程设备的 HFP HF 连接状态。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

返回当前连接状态枚举值，参见 profile_connection_state_t。

## bt_hfp_hf_connect
    
    
    bt_status_t bt_hfp_hf_connect(bt_instance_t* ins, bt_address_t* addr);

发起与远程设备的 HFP HF 连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 对端设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_hf_disconnect
    
    
    bt_status_t bt_hfp_hf_disconnect(bt_instance_t* ins, bt_address_t* addr);

断开与远程设备的连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_hf_set_connection_policy
    
    
    bt_status_t bt_hfp_hf_set_connection_policy(bt_instance_t* ins, bt_address_t* addr, connection_policy_t policy);

发起与远程设备的连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * policy 策略值。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_hf_connect_audio
    
    
    bt_status_t bt_hfp_hf_connect_audio(bt_instance_t* ins, bt_address_t* addr);

发起与远程设备的连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_hf_disconnect_audio
    
    
    bt_status_t bt_hfp_hf_disconnect_audio(bt_instance_t* ins, bt_address_t* addr);

断开与远程设备的连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_hf_start_voice_recognition
    
    
    bt_status_t bt_hfp_hf_start_voice_recognition(bt_instance_t* ins, bt_address_t* addr);

启动远程设备的语音识别功能。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_hf_stop_voice_recognition
    
    
    bt_status_t bt_hfp_hf_stop_voice_recognition(bt_instance_t* ins, bt_address_t* addr);

停止远程设备的语音识别功能。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_hf_dial
    
    
    bt_status_t bt_hfp_hf_dial(bt_instance_t* ins, bt_address_t* addr, const char* number);

发起通话。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * number 号码。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_hf_dial_memory
    
    
    bt_status_t bt_hfp_hf_dial_memory(bt_instance_t* ins, bt_address_t* addr, uint32_t memory);

通过 HFP 拨打内存中存储的号码。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * memory 内存位置编号。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_hf_redial
    
    
    bt_status_t bt_hfp_hf_redial(bt_instance_t* ins, bt_address_t* addr);

发起通话。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_hf_accept_call
    
    
    bt_status_t bt_hfp_hf_accept_call(bt_instance_t* ins, bt_address_t* addr, hfp_call_accept_t flag);

通过 HFP 接听来电。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * flag 标志位。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_hf_reject_call
    
    
    bt_status_t bt_hfp_hf_reject_call(bt_instance_t* ins, bt_address_t* addr);

通过 HFP 拒绝来电。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_hf_hold_call
    
    
    bt_status_t bt_hfp_hf_hold_call(bt_instance_t* ins, bt_address_t* addr);

通过 HFP 保持当前通话。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_hf_terminate_call
    
    
    bt_status_t bt_hfp_hf_terminate_call(bt_instance_t* ins, bt_address_t* addr);

通过 HFP 挂断当前通话。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_hf_control_call
    
    
    bt_status_t bt_hfp_hf_control_call(bt_instance_t* ins, bt_address_t* addr, hfp_call_control_t chld, uint8_t index);

control通话状态。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * chld CHLD 命令类型。
  * index 索引。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_hf_query_current_calls
    
    
    bt_status_t bt_hfp_hf_query_current_calls(bt_instance_t* ins, bt_address_t* addr, hfp_current_call_t** calls, int* num, bt_allocator_t allocator);

查询当前所有通话的状态信息（CLCC）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 对端设备蓝牙地址。
  * allocator 内存分配函数。- calls 输出参数，存储通话信息数组。
  * num 输出参数，存储通话数量。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_hf_send_at_cmd
    
    
    bt_status_t bt_hfp_hf_send_at_cmd(bt_instance_t* ins, bt_address_t* addr, const char* cmd);

发送自定义 AT 命令到远程设备。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * cmd 命令。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_hf_update_battery_level
    
    
    bt_status_t bt_hfp_hf_update_battery_level(bt_instance_t* ins, bt_address_t* addr, uint8_t level);

向远程设备更新本地电池电量信息。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * level 安全级别。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_hf_volume_control
    
    
    bt_status_t bt_hfp_hf_volume_control(bt_instance_t* ins, bt_address_t* addr, hfp_volume_type_t type, uint8_t volume);

通过 HFP 控制远程设备的音量。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * type 类型。
  * volume 音量值。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_hf_send_dtmf
    
    
    bt_status_t bt_hfp_hf_send_dtmf(bt_instance_t* ins, bt_address_t* addr, char dtmf);

通过 HFP 发送 DTMF 按键音。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * dtmf DTMF 按键字符。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_hf_get_subscriber_number
    
    
    bt_status_t bt_hfp_hf_get_subscriber_number(bt_instance_t* ins, bt_address_t* addr);

获取用户号码。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


## bt_hfp_hf_query_current_calls_with_callback
    
    
    bt_status_t bt_hfp_hf_query_current_calls_with_callback(bt_instance_t* ins, bt_address_t* addr);

查询当前所有通话的状态信息（CLCC），结果通过回调异步返回。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_ag_unregister_callbacks
    
    
    bool bt_hfp_ag_unregister_callbacks(bt_instance_t* ins, void* cookie);

取消注册回调函数，停止接收状态变更通知。

**参数** ：

  * ins 蓝牙客户端实例。
  * cookie 用户上下文。


**返回值** ：

成功时返回 true，失败时返回 false。

## bt_hfp_ag_is_connected
    
    
    bool bt_hfp_ag_is_connected(bt_instance_t* ins, bt_address_t* addr);

查询与远程设备的 HFP AG 是否已连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

已连接时返回 true，未连接时返回 false。

## bt_hfp_ag_is_audio_connected
    
    
    bool bt_hfp_ag_is_audio_connected(bt_instance_t* ins, bt_address_t* addr);

查询与远程设备的 HFP AG 音频通道是否已连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

音频已连接时返回 true，未连接时返回 false。

## bt_hfp_ag_get_connection_state
    
    
    profile_connection_state_t bt_hfp_ag_get_connection_state(bt_instance_t* ins, bt_address_t* addr);

获取与远程设备的 HFP AG 连接状态。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

返回当前连接状态枚举值，参见 profile_connection_state_t。

## bt_hfp_ag_connect
    
    
    bt_status_t bt_hfp_ag_connect(bt_instance_t* ins, bt_address_t* addr);

发起与远程设备的 HFP AG 连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 对端设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_ag_disconnect
    
    
    bt_status_t bt_hfp_ag_disconnect(bt_instance_t* ins, bt_address_t* addr);

断开与远程设备的连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_ag_connect_audio
    
    
    bt_status_t bt_hfp_ag_connect_audio(bt_instance_t* ins, bt_address_t* addr);

发起与远程设备的连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_ag_disconnect_audio
    
    
    bt_status_t bt_hfp_ag_disconnect_audio(bt_instance_t* ins, bt_address_t* addr);

断开与远程设备的连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_ag_start_virtual_call
    
    
    bt_status_t bt_hfp_ag_start_virtual_call(bt_instance_t* ins, bt_address_t* addr);

开始操作。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_ag_stop_virtual_call
    
    
    bt_status_t bt_hfp_ag_stop_virtual_call(bt_instance_t* ins, bt_address_t* addr);

停止操作。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_ag_start_voice_recognition
    
    
    bt_status_t bt_hfp_ag_start_voice_recognition(bt_instance_t* ins, bt_address_t* addr);

启动远程设备的语音识别功能。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_ag_stop_voice_recognition
    
    
    bt_status_t bt_hfp_ag_stop_voice_recognition(bt_instance_t* ins, bt_address_t* addr);

停止远程设备的语音识别功能。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_ag_phone_state_change
    
    
    bt_status_t bt_hfp_ag_phone_state_change(bt_instance_t* ins, bt_address_t* addr, uint8_t num_active, uint8_t num_held, hfp_ag_call_state_t call_state, hfp_call_addrtype_t type, const char* number, const char* name);

通知远程设备电话状态变更（来电/通话/挂断等）。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * num_active 活跃通话数量。
  * num_held 保持中通话数量。
  * call_state 通话状态。
  * type 类型。
  * number 号码。
  * name 名称。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_ag_notify_device_status
    
    
    bt_status_t bt_hfp_ag_notify_device_status(bt_instance_t* ins, bt_address_t* addr, hfp_network_state_t network, hfp_roaming_state_t roam, uint8_t signal, uint8_t battery);

notify设备类型status。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * network 网络信息。
  * roam 漫游状态。
  * signal 信号强度。
  * battery 电池电量。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_ag_volume_control
    
    
    bt_status_t bt_hfp_ag_volume_control(bt_instance_t* ins, bt_address_t* addr, hfp_volume_type_t type, uint8_t volume);

通过 HFP 控制远程设备的音量。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * type 类型。
  * volume 音量值。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_ag_send_at_command
    
    
    bt_status_t bt_hfp_ag_send_at_command(bt_instance_t* ins, bt_address_t* addr, const char* at_command);

发送操作。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * at_command AT 命令字符串。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_ag_send_vendor_specific_at_command
    
    
    bt_status_t bt_hfp_ag_send_vendor_specific_at_command(bt_instance_t* ins, bt_address_t* addr, const char* command, const char* value);

发送操作。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * command 命令。
  * value 值。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_ag_send_clcc_response
    
    
    bt_status_t bt_hfp_ag_send_clcc_response(bt_instance_t* ins, bt_address_t* addr, uint32_t index, hfp_call_direction_t dir, hfp_ag_call_state_t state, hfp_call_mode_t mode, hfp_call_mpty_type_t mpty, hfp_call_addrtype_t type, const char* number);

发送操作。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 蓝牙地址。
  * index 索引。
  * dir 方向（呼入/呼出）。
  * state 状态。
  * mode 模式。
  * mpty 是否为多方通话。
  * type 类型。
  * number 通话号码。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hfp_ag_send_cind_response
    
    
    bt_status_t bt_hfp_ag_send_cind_response(bt_instance_t* ins, bt_address_t* addr, hfp_network_state_t network, hfp_call_t call, hfp_callheld_t call_held, hfp_callsetup_t call_setup, uint8_t signal, hfp_roaming_state_t roam, uint8_t battery);

发送操作。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * network 网络信息。
  * call 通话信息。
  * call_held 保持中通话数量。
  * call_setup 通话建立状态。
  * signal 信号强度。
  * roam 漫游状态。
  * battery 电池电量。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

---

## 蓝牙 HID API

> 路径: 应用框架 > 蓝牙（Bluetooth） > 蓝牙 HID API
> 来源: [https://doc.openvela.com/document?id=1133&language=cn&version=dev](https://doc.openvela.com/document?id=1133&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/bluetooth/bt_hid.md>) | 简体中文 ]

# 蓝牙 HID API

openvela 蓝牙 HID（人机接口设备）接口，支持键盘、鼠标、游戏手柄等输入设备。

头文件：#include "bt_hid_device.h"

# openvela 实现说明

  * **设备角色** ：HID Device（输入设备端）


# 同步接口

## bt_hid_device_unregister_callbacks
    
    
    bool bt_hid_device_unregister_callbacks(bt_instance_t* ins, void* cookie);

取消注册回调函数，停止接收状态变更通知。

**参数** ：

  * ins 蓝牙客户端实例, 参见 bt_instance_t.
  * cookie 用户上下文。


**返回值** ：

成功时返回 true，失败时返回 false。

## bt_hid_device_register_app
    
    
    bt_status_t bt_hid_device_register_app(bt_instance_t* ins, hid_device_sdp_settings_t* sdp_setting, bool le_hid);

注册操作。

**参数** ：

  * ins 蓝牙客户端实例。
  * sdp_setting SDP 设置。
  * le_hid LE HID 实例。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回负的错误码。

## bt_hid_device_unregister_app
    
    
    bt_status_t bt_hid_device_unregister_app(bt_instance_t* ins);

取消注册 HID 设备应用。

**参数** ：

  * ins 蓝牙客户端实例。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hid_device_connect
    
    
    bt_status_t bt_hid_device_connect(bt_instance_t* ins, bt_address_t* addr);

发起与远程设备的连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回负的错误码。

## bt_hid_device_disconnect
    
    
    bt_status_t bt_hid_device_disconnect(bt_instance_t* ins, bt_address_t* addr);

断开与远程设备的连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回负的错误码。

## bt_hid_device_send_report
    
    
    bt_status_t bt_hid_device_send_report(bt_instance_t* ins, bt_address_t* addr, uint8_t rpt_id, uint8_t* rpt_data, int rpt_size);

向已连接的主机发送 HID 输入报告。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * rpt_id HID 报告 ID。
  * rpt_data HID 报告数据。
  * rpt_size 报告数据大小（字节）。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回负的错误码。

## bt_hid_device_response_report
    
    
    bt_status_t bt_hid_device_response_report(bt_instance_t* ins, bt_address_t* addr, uint8_t rpt_type, uint8_t* rpt_data, int rpt_size);

回复主机的 HID 报告请求。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * rpt_type HID 报告类型（输入/输出/特性）。
  * rpt_data HID 报告数据。
  * rpt_size 报告数据大小（字节）。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hid_device_report_error
    
    
    bt_status_t bt_hid_device_report_error(bt_instance_t* ins, bt_address_t* addr, hid_status_error_t error);

向主机报告 HID 错误。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * error 错误码，参见 hid_status_error_t。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_hid_device_virtual_unplug
    
    
    bt_status_t bt_hid_device_virtual_unplug(bt_instance_t* ins, bt_address_t* addr);

发送虚拟拔出请求，断开 HID 连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

---

## 蓝牙 SPP API

> 路径: 应用框架 > 蓝牙（Bluetooth） > 蓝牙 SPP API
> 来源: [https://doc.openvela.com/document?id=1134&language=cn&version=dev](https://doc.openvela.com/document?id=1134&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/bluetooth/bt_spp.md>) | 简体中文 ]

# 蓝牙 SPP API

openvela 蓝牙 SPP（串口仿真）接口，用于替代物理串口进行数据透传。

头文件：#include "bt_spp.h"

# openvela 实现说明

  * **功能** ：虚拟串口通信，适用于传统串口设备的蓝牙化


# 同步接口

## bt_spp_unregister_app
    
    
    bt_status_t bt_spp_unregister_app(bt_instance_t* ins, void* handle);

取消注册 SPP 应用。

**参数** ：

  * ins 蓝牙客户端实例。
  * handle 句柄。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_spp_server_start
    
    
    bt_status_t bt_spp_server_start(bt_instance_t* ins, void* handle, uint16_t scn, bt_uuid_t* uuid, uint8_t max_connection);

启动 SPP 服务器，监听远程设备的连接请求。

**参数** ：

  * ins 蓝牙客户端实例。
  * handle 句柄。
  * scn 服务器通道号。
  * uuid 服务 UUID。
  * max_connection 最大连接数。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_spp_server_stop
    
    
    bt_status_t bt_spp_server_stop(bt_instance_t* ins, void* handle, uint16_t scn);

停止 SPP 服务器，不再接受新连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * handle 句柄。
  * scn 服务器通道号。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_spp_connect
    
    
    bt_status_t bt_spp_connect(bt_instance_t* ins, void* handle, bt_address_t* addr, int16_t scn, bt_uuid_t* uuid, uint16_t* port);

发起与远程设备的连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * handle 句柄。
  * addr 远程设备蓝牙地址。
  * scn 服务器通道号。
  * uuid 服务 UUID。
  * port 端口号。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_spp_insecure_connect
    
    
    bt_status_t bt_spp_insecure_connect(bt_instance_t* ins, void* handle, bt_address_t* addr, int16_t scn, bt_uuid_t* uuid, uint16_t* port);

发起与远程设备的非安全连接（不要求加密）。

**参数** ：

  * ins 蓝牙客户端实例。
  * handle 句柄。
  * addr 远程设备蓝牙地址。
  * scn 服务器通道号。
  * uuid 服务 UUID。
  * port 端口号。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_spp_disconnect
    
    
    bt_status_t bt_spp_disconnect(bt_instance_t* ins, void* handle, bt_address_t* addr, uint16_t port);

断开连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * handle 句柄。
  * addr 对端设备蓝牙地址。
  * port 端口号。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

---

## 蓝牙 PAN API

> 路径: 应用框架 > 蓝牙（Bluetooth） > 蓝牙 PAN API
> 来源: [https://doc.openvela.com/document?id=1135&language=cn&version=dev](https://doc.openvela.com/document?id=1135&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/bluetooth/bt_pan.md>) | 简体中文 ]

# 蓝牙 PAN API

openvela 蓝牙 PAN（个人局域网）接口，支持通过蓝牙实现网络共享。

头文件：#include "bt_pan.h"

# openvela 实现说明

  * **功能** ：网络共享（Tethering）、蓝牙组网


# 同步接口

## bt_pan_unregister_callbacks
    
    
    bool bt_pan_unregister_callbacks(bt_instance_t* ins, void* cookie);

取消注册回调函数，停止接收状态变更通知。

**参数** ：

  * cookie 用户上下文。
  * ins 蓝牙客户端实例。


**返回值** ：

取消注册回调函数。

## bt_pan_connect
    
    
    bt_status_t bt_pan_connect(bt_instance_t* ins, bt_address_t* addr, uint8_t dst_role, uint8_t src_role);

发起与远程设备的连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。
  * dst_role 目标设备角色。
  * src_role 本地设备角色。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

## bt_pan_disconnect
    
    
    bt_status_t bt_pan_disconnect(bt_instance_t* ins, bt_address_t* addr);

断开与远程设备的连接。

**参数** ：

  * ins 蓝牙客户端实例。
  * addr 远程设备蓝牙地址。


**返回值** ：

成功时返回 BT_STATUS_SUCCESS，失败时返回错误码。

---

## Telephony API 总览

> 路径: 应用框架 > 电话服务（Telephony） > Telephony API 总览
> 来源: [https://doc.openvela.com/document?id=1137&language=cn&version=dev](https://doc.openvela.com/document?id=1137&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/telephony/index.md>) | 简体中文 ]

# Telephony API

Telephony 提供蜂窝通信能力，framework/telephony 是 openvela 蜂窝通信对应用层提供的接口层，又称为 TAPI（Telephony API）。封装的接口涵盖了蜂窝通信业务：网络服务、通话、短信、数据、SIM 双卡和 modem 配置管理等。

TAPI 独立于 openvela telephony core stack，内部逻辑基于 DBUS LIB 对 Core Stack 进行业务逻辑封装，屏蔽掉 D-Bus 的复杂操作，对外以标准 C 的方式提供标准化统一的 Telephony API 接口定义，方便 openvela 应用层 APP 的使用，让 openvela APP 实现 openvela 系统版本间复用。

# openvela 实现说明

  * **架构** ：TAPI 基于 D-Bus 对 Telephony Core Stack（oFono）进行封装，以标准 C 接口对外提供
  * **SIM 卡标识** ：通过 slot_id 参数区分不同 SIM 卡槽
  * **异步模型** ：大部分操作通过回调函数异步返回结果


# 模块代码介绍

模块 | 源码 | API 文档 | 说明  
---|---|---|---  
对外统一头文件 | tapi.h | [公共工具](</document?id=683&version=dev&language=cn>) | 公共类型定义、字符串/枚举转换 utils  
Radio 接口 | tapi_manager.c/h | [管理](</document?id=1139&version=dev&language=cn>) | Telephony 初始化、状态查询、事件注册  
Call 接口 | tapi_call.c/h | [通话](</document?id=1140&version=dev&language=cn>) | 语音通话控制  
补充业务 | tapi_ss.c/h | [补充业务 SS](</document?id=1141&version=dev&language=cn>) | 呼叫转移/呼叫限制/呼叫等待/CLIR/USSD  
简化电话服务 | tapi_phone.c/h | [简化电话服务](</document?id=1142&version=dev&language=cn>) | 轻量客户端封装  
Network 接口 | tapi_network.c/h | [网络](</document?id=1143&version=dev&language=cn>) | 网络注册、信号、运营商  
Data 接口 | tapi_data.c/h | [数据](</document?id=1144&version=dev&language=cn>) | 蜂窝数据连接  
SIM 接口 | tapi_sim.c/h | [SIM 卡](</document?id=1145&version=dev&language=cn>) | SIM 卡管理  
SIM Toolkit | tapi_stk.c/h | [SIM Toolkit](</document?id=1146&version=dev&language=cn>) | STK Agent 与 SIM 卡主动命令  
电话簿 | tapi_phonebook.c/h | [电话簿](</document?id=1147&version=dev&language=cn>) | ADN/FDN 电话簿管理  
SMS 接口 | tapi_sms.c/h | [短信](</document?id=1148&version=dev&language=cn>) | 短信收发  
Cell Broadcast | tapi_cbs.c/h | [小区广播 CBS](</document?id=1149&version=dev&language=cn>) | 小区广播消息  
IMS 接口 | tapi_ims.c/h | [IMS](</document?id=1150&version=dev&language=cn>) | VoLTE/VoWiFi  
  
# TAPI 配置

完整的 Telephony 业务涉及模块众多，需要所有模块开启完整使用 Telephony 业务。

**DBUS 配置**  

    
    
    CONFIG_DBUS_DAEMON=y
    CONFIG_DBUS_MONITOR=y
    CONFIG_DBUS_SEND=y
    CONFIG_LIB_DBUS=y

**GLIB 配置**  

    
    
    CONFIG_LIB_GLIB=y

**OFONO 配置**  

    
    
    CONFIG_LIB_ELL=y
    CONFIG_OFONO=y
    CONFIG_OFONO_RILMODEM=y  # modem 类型选择，支持 rild 的选择 rilmodem
    CONFIG_OFONO_ATMODEM=y   # 支持串口、USB 的选择 atmodem

**GDBUS 配置**  

    
    
    CONFIG_LIB_DBUS=y

**Telephony API 配置**  

    
    
    CONFIG_TELEPHONY=y
    CONFIG_TELEPHONY_TOOL=y  # debug 工具，可选

# TAPI 工作使用模型

![TAPIWork](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455195863_TapiWork.png)

# TAPI 函数使用举例

## 获取 TAPI 工作上下文

先声明一个 callback 函数：  

    
    
    static void on_tapi_client_ready(const char* client_name, void* user_data)
    {
        if (client_name != NULL)
            syslog(LOG_DEBUG, "tapi is ready for %s\n", client_name);
        ...
    }

再调用 tapi_open 函数获取上下文。获取成功需要 oFono、D-Bus 等服务启动成功，当 ready 后会调用 callback 函数。  

    
    
    tapi_context context;
    char* dbus_name = "vela.telephony.tool";
    context = tapi_open(dbus_name, on_tapi_client_ready, NULL);

## 释放 TAPI 工作上下文
    
    
    tapi_close(context);

## 查询当前的 radio power 状态
    
    
    int slot_id = 0;
    bool value = false;
    tapi_get_radio_power(context, slot_id, &value);

---

## Telephony 公共工具 API

> 路径: 应用框架 > 电话服务（Telephony） > Telephony 公共工具 API
> 来源: [https://doc.openvela.com/document?id=1138&language=cn&version=dev](https://doc.openvela.com/document?id=1138&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/telephony/telephony.md>) | 简体中文 ]

# Telephony 公共工具 API

TAPI 提供的通用工具函数，涵盖状态字符串转换、modem 路径解析、运营商状态解析等辅助能力。

头文件：#include <tapi.h>

# openvela 实现说明

  * **字符串↔枚举转换** ：*_from_string / *_to_string 系列把 oFono D-Bus 字符串与 TAPI 枚举互转，便于状态解析
  * **Modem 路径** ：tapi_utils_get_modem_path 将 slot_id 转成 oFono 的 modem 对象路径
  * **工具性质** ：本组接口不依赖 tapi_context，可在任意位置直接调用
  * **适用场景** ：实现自定义事件处理、打印调试日志、或扩展 TAPI 能力时使用


# SIM 状态

## tapi_sim_state_to_string
    
    
    const char* tapi_sim_state_to_string(tapi_sim_state state);

将 SIM 状态枚举转为可读字符串。

**参数** ：

  * state SIM 状态枚举值。


**返回值** ：

返回状态的字符串表示，失败时返回 NULL 或占位字符串。

# APN 工具

## tapi_utils_apn_auth_from_string
    
    
    int tapi_utils_apn_auth_from_string(const char* str);

将认证类型字符串转为 APN 认证枚举值。

**参数** ：

  * str 认证类型字符串（如 "pap"、"chap"）。


**返回值** ：

返回认证枚举值；无效字符串时返回错误值。

## tapi_utils_apn_auth_to_string
    
    
    const char* tapi_utils_apn_auth_to_string(int auth);

将 APN 认证枚举值转为字符串。

**参数** ：

  * auth 认证枚举值。


**返回值** ：

返回对应字符串。

## tapi_utils_apn_proto_from_string
    
    
    int tapi_utils_apn_proto_from_string(const char* str);

将协议字符串转为 APN 协议枚举值。

**参数** ：

  * str 协议字符串（如 "ip"、"ipv6"、"dual"）。


**返回值** ：

返回协议枚举值。

## tapi_utils_apn_proto_to_string
    
    
    const char* tapi_utils_apn_proto_to_string(int proto);

将 APN 协议枚举值转为字符串。

**参数** ：

  * proto 协议枚举值。


**返回值** ：

返回对应字符串。

## tapi_utils_apn_type_from_string
    
    
    int tapi_utils_apn_type_from_string(const char* str);

将 APN 类型字符串转为类型枚举值。

**参数** ：

  * str APN 类型字符串（如 "default"、"mms"、"ims"）。


**返回值** ：

返回类型枚举值。

## tapi_utils_apn_type_to_string
    
    
    const char* tapi_utils_apn_type_to_string(int type);

将 APN 类型枚举值转为字符串。

**参数** ：

  * type APN 类型枚举值。


**返回值** ：

返回对应字符串。

# 通话工具

## tapi_utils_call_disconnected_reason
    
    
    int tapi_utils_call_disconnected_reason(const char* reason);

将通话断开原因字符串转为 TAPI 断开原因枚举值。

**参数** ：

  * reason 断开原因字符串。


**返回值** ：

返回断开原因枚举值。

## tapi_utils_call_status_from_string
    
    
    int tapi_utils_call_status_from_string(const char* status);

将通话状态字符串转为状态枚举值。

**参数** ：

  * status 状态字符串（如 "active"、"held"、"dialing"）。


**返回值** ：

返回状态枚举值。

# 小区与网络工具

## tapi_utils_cell_type_from_string
    
    
    int tapi_utils_cell_type_from_string(const char* str);

将小区类型字符串转为枚举值。

**参数** ：

  * str 小区类型字符串。


**返回值** ：

返回小区类型枚举值。

## tapi_utils_cell_type_to_string
    
    
    const char* tapi_utils_cell_type_to_string(int type);

将小区类型枚举值转为字符串。

**参数** ：

  * type 小区类型枚举值。


**返回值** ：

返回对应字符串。

## tapi_utils_network_mode_from_string
    
    
    int tapi_utils_network_mode_from_string(const char* str);

将网络模式字符串转为枚举值。

**参数** ：

  * str 网络模式字符串（如 "gsm"、"lte"）。


**返回值** ：

返回网络模式枚举值。

## tapi_utils_network_mode_to_string
    
    
    const char* tapi_utils_network_mode_to_string(int mode);

将网络模式枚举值转为字符串。

**参数** ：

  * mode 网络模式枚举值。


**返回值** ：

返回对应字符串。

## tapi_utils_network_type_from_ril_tech
    
    
    int tapi_utils_network_type_from_ril_tech(int tech);

将 RIL 层传来的网络技术值转为 TAPI 网络类型枚举。

**参数** ：

  * tech RIL 网络技术值。


**返回值** ：

返回 TAPI 网络类型枚举值。

## tapi_utils_network_operator_status_from_string
    
    
    int tapi_utils_network_operator_status_from_string(const char* str);

将运营商状态字符串转为枚举值。

**参数** ：

  * str 运营商状态字符串。


**返回值** ：

返回运营商状态枚举值。

## tapi_utils_operator_status_from_string
    
    
    int tapi_utils_operator_status_from_string(const char* str);

tapi_utils_network_operator_status_from_string 的简写版本，等价功能。

**参数** ：

  * str 运营商状态字符串。


**返回值** ：

返回运营商状态枚举值。

# 注册状态工具

## tapi_utils_registration_mode_from_string
    
    
    int tapi_utils_registration_mode_from_string(const char* str);

将注册模式字符串转为枚举值。

**参数** ：

  * str 注册模式字符串（如 "auto"、"manual"）。


**返回值** ：

返回注册模式枚举值。

## tapi_utils_registration_status_from_string
    
    
    int tapi_utils_registration_status_from_string(const char* str);

将注册状态字符串转为枚举值。

**参数** ：

  * str 注册状态字符串。


**返回值** ：

返回注册状态枚举值。

## tapi_utils_get_registration_status_string
    
    
    const char* tapi_utils_get_registration_status_string(int status);

将注册状态枚举值转为可读字符串。

**参数** ：

  * status 注册状态枚举值。


**返回值** ：

返回对应字符串。

# Modem 路径与 Slot

## tapi_utils_get_modem_path
    
    
    const char* tapi_utils_get_modem_path(int slot_id);

根据 SIM 卡槽 ID 获取 oFono 的 modem 对象路径。

**参数** ：

  * slot_id SIM 卡槽 ID（0 或 1）。


**返回值** ：

返回 modem 对象路径字符串（如 /ril_0、/ril_1）。

## tapi_utils_get_slot_id
    
    
    int tapi_utils_get_slot_id(const char* path);

从 oFono modem 对象路径解析 SIM 卡槽 ID。

**参数** ：

  * path modem 对象路径。


**返回值** ：

返回对应的卡槽 ID（0 或 1），无效路径时返回负值。

---

## Telephony 管理 API

> 路径: 应用框架 > 电话服务（Telephony） > Telephony 管理 API
> 来源: [https://doc.openvela.com/document?id=1139&language=cn&version=dev](https://doc.openvela.com/document?id=1139&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/telephony/telephony_manager.md>) | 简体中文 ]

# Telephony 管理 API

蜂窝通信管理接口，包括初始化、状态查询和事件注册。

头文件：#include <tapi_manager.h>

# openvela 实现说明

  * **基于 D-Bus** ：TAPI Manager 通过 D-Bus 与 Telephony Core Stack（oFono）通信，对外以标准 C 接口封装
  * **SIM 卡标识** ：管理器层面不直接涉及 SIM 卡槽选择，涉及特定卡槽的操作在 tapi_sim 等子模块中使用 slot_id 参数
  * **客户端句柄** ：通过 tapi_open 获取 tapi_context，所有后续调用均以该 context 作为第一个参数
  * **事件订阅** ：通过 tapi_register 注册事件回调，tapi_unregister 取消订阅
  * **同步 vs 异步** ：多数接口是异步的（带回调），部分提供 *_sync 变体用于简单场景


# 客户端连接管理

## tapi_open
    
    
    tapi_context tapi_open(const char* client_name, tapi_client_ready_function callback, void* user_data);

打开 Telephony 连接，获取上下文句柄。

**参数** ：

  * client_name 客户端名称。
  * callback 回调函数。
  * user_data 用户数据，传递给回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_open_service
    
    
    tapi_context tapi_open_service(const char* client_name, tapi_client_ready_function callback, void* user_data, unsigned int tapi_service);

打开 Telephony 连接。

**参数** ：

  * client_name 客户端名称。
  * callback 回调函数。
  * user_data 用户数据，传递给回调函数。
  * tapi_service Telephony 服务类型。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_close
    
    
    int tapi_close(tapi_context context);

关闭 Telephony 连接。

**参数** ：

  * context Telephony 上下文句柄。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 能力查询

## tapi_is_feature_supported
    
    
    bool tapi_is_feature_supported(tapi_feature_type feature);

查询是否支持指定功能。

**参数** ：

  * feature 功能名称。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 无线电控制

## tapi_set_radio_power
    
    
    int tapi_set_radio_power(tapi_context context, int slot_id, int event_id, bool state, tapi_async_function p_handle);

设置射频功率。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * state 状态。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_set_radio_power_async
    
    
    int tapi_set_radio_power_async(tapi_context context, int slot_id, int event_id, bool state, void* user_data, tapi_async_function p_handle);

设置射频功率（异步版本）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * state 状态。
  * user_data 用户数据，传递给回调函数。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_get_radio_power
    
    
    int tapi_get_radio_power(tapi_context context, int slot_id, bool* out);

获取射频功率状态。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 网络模式

## tapi_set_pref_net_mode
    
    
    int tapi_set_pref_net_mode(tapi_context context, int slot_id, int event_id, tapi_pref_net_mode mode, tapi_async_function p_handle);

打开 Telephony 连接，获取上下文句柄。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * mode 模式。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_get_pref_net_mode
    
    
    int tapi_get_pref_net_mode(tapi_context context, int slot_id, tapi_pref_net_mode* out);

打开 Telephony 连接，获取上下文句柄。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_get_radio_state
    
    
    int tapi_get_radio_state(tapi_context context, int slot_id, tapi_radio_state* out);

获取射频状态。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# Modem 信息

## tapi_get_imei
    
    
    int tapi_get_imei(tapi_context context, int slot_id, char** out);

获取设备 IMEI。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_get_imeisv
    
    
    int tapi_get_imeisv(tapi_context context, int slot_id, char** out);

获取设备 IMEI。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_get_modem_revision
    
    
    int tapi_get_modem_revision(tapi_context context, int slot_id, char** out);

打开 Telephony 连接，获取上下文句柄。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_get_phone_state
    
    
    int tapi_get_phone_state(tapi_context context, int slot_id, tapi_phone_state* state);

打开 Telephony 连接，获取上下文句柄。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * state 状态。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 手机号码

## tapi_get_msisdn_number
    
    
    int tapi_get_msisdn_number(tapi_context context, int slot_id, char** out);

获取 SIM 卡电话号码（MSISDN）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# Modem 状态与控制

## tapi_get_modem_activity_info
    
    
    int tapi_get_modem_activity_info(tapi_context context, int slot_id, int event_id, tapi_async_function p_handle);

获取 Modem 活动信息。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_invoke_oem_ril_request_raw
    
    
    int tapi_invoke_oem_ril_request_raw(tapi_context context, int slot_id, int event_id, unsigned char oem_req[], int length, tapi_async_function p_handle);

发送 OEM RIL 请求。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * oem_req OEM 请求数据。
  * length 数据长度。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_invoke_oem_ril_request_strings
    
    
    int tapi_invoke_oem_ril_request_strings(tapi_context context, int slot_id, int event_id, char* oem_req[], int length, tapi_async_function p_handle);

发送 OEM RIL 请求。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * oem_req OEM 请求数据。
  * length 数据长度。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_enable_modem
    
    
    int tapi_enable_modem(tapi_context context, int slot_id, int event_id, bool enable, tapi_async_function p_handle);

启用 Modem。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * enable 是否启用。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_enable_modem_abnormal_event
    
    
    int tapi_enable_modem_abnormal_event(tapi_context context, int slot_id, bool enable, int event_id, int module_mask, int from_event_id, int to_event_id, tapi_async_function p_handle);

启用 Modem。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * enable 是否启用。
  * event_id 事件 ID，用于回调匹配。
  * module_mask 模块掩码。
  * from_event_id 源事件 ID。
  * to_event_id 目标事件 ID。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_set_signal_report_threshold
    
    
    int tapi_set_signal_report_threshold(tapi_context context, int slot_id, int event_id, int type, tapi_async_function p_handle);

打开 Telephony 连接，获取上下文句柄。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * type 类型。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_suppress_message_report
    
    
    int tapi_suppress_message_report(tapi_context context, int slot_id, int event_id, bool enable, tapi_async_function p_handle);

打开 Telephony 连接，获取上下文句柄。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * enable 是否启用。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_enable_modem_stationary
    
    
    int tapi_enable_modem_stationary(tapi_context context, int slot_id, int event_id, bool enable, tapi_async_function p_handle);

启用 Modem。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * enable 是否启用。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_set_modem_stationary_threshold
    
    
    int tapi_set_modem_stationary_threshold(tapi_context context, int slot_id, int event_id, int value, tapi_async_function p_handle);

打开 Telephony 连接，获取上下文句柄。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * value 值。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_get_modem_status
    
    
    int tapi_get_modem_status(tapi_context context, int slot_id, int event_id, tapi_async_function p_handle);

打开 Telephony 连接，获取上下文句柄。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_get_modem_status_sync
    
    
    int tapi_get_modem_status_sync(tapi_context context, int slot_id, tapi_modem_state* out);

打开 Telephony 连接，获取上下文句柄。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_set_fast_dormancy
    
    
    int tapi_set_fast_dormancy(tapi_context context, int slot_id, int event_id, bool state, tapi_async_function p_handle);

打开 Telephony 连接，获取上下文句柄。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * state 状态。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_get_phone_number
    
    
    int tapi_get_phone_number(tapi_context context, int slot_id, char** out);

获取本机号码。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 事件订阅

## tapi_register
    
    
    int tapi_register(tapi_context context, int slot_id, tapi_indication_msg msg, void* user_obj, tapi_async_function p_handle);

打开 Telephony 连接，获取上下文句柄。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * msg 消息内容。
  * user_obj 用户对象指针。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_unregister
    
    
    int tapi_unregister(tapi_context context, int watch_id);

打开 Telephony 连接，获取上下文句柄。

**参数** ：

  * context Telephony 上下文句柄。
  * watch_id 监听 ID（用于取消监听）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 运营商配置

## tapi_get_carrier_config_bool
    
    
    int tapi_get_carrier_config_bool(tapi_context context, int slot_id, char* key, bool* out);

打开 Telephony 连接，获取上下文句柄。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * key 键名。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_get_carrier_config_int
    
    
    int tapi_get_carrier_config_int(tapi_context context, int slot_id, char* key, int* out);

打开 Telephony 连接，获取上下文句柄。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * key 键名。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_get_carrier_config_string
    
    
    int tapi_get_carrier_config_string(tapi_context context, int slot_id, char* key, char** out);

打开 Telephony 连接，获取上下文句柄。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * key 键名。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

---

## 通话管理 API

> 路径: 应用框架 > 电话服务（Telephony） > 通话管理 API
> 来源: [https://doc.openvela.com/document?id=1140&language=cn&version=dev](https://doc.openvela.com/document?id=1140&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/telephony/telephony_call.md>) | 简体中文 ]

# 通话管理 API

语音通话控制，包括拨号、接听、挂断、保持等。

头文件：#include <tapi_call.h>

# openvela 实现说明

  * **SIM 卡标识** ：部分接口不带 slot_id，使用默认卡；需要指定卡时通过 tapi_call_set_default_slot 切换
  * **同步/异步** ：拨号、应答等耗时操作同时提供同步版本和 _async 版本（回调风格）
  * **按 ID 操作** ：长生命周期通话通过返回的 call ID（字符串）唯一标识，*_by_id 接口据此执行操作
  * **DTMF** ：拨号盘按键通过 tapi_call_send_tones（批量）或 tapi_call_start_dtmf / tapi_call_stop_dtmf（持续按键）触发
  * **会议通话** ：通过 tapi_call_dial_conferece 和 tapi_call_merge_call 组织，tapi_call_separate_call 拆分


# 拨打与应答

## tapi_call_dial
    
    
    int tapi_call_dial(tapi_context context, int slot_id, char* number, int hide_callerid, int event_id, tapi_async_function p_handle);

发起语音通话。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * number 电话号码。
  * hide_callerid 是否隐藏主叫号码。
  * event_id 事件 ID，用于回调匹配。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_call_dial_async
    
    
    int tapi_call_dial_async(tapi_context context, int slot_id, char* number, int hide_callerid, int event_id, void* user_data, tapi_async_function p_handle);

发起语音通话（异步版本）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * number 电话号码。
  * hide_callerid 是否隐藏主叫号码。
  * event_id 事件 ID，用于回调匹配。
  * user_data 用户数据，传递给回调函数。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 挂断控制

## tapi_call_hangup_all_calls
    
    
    int tapi_call_hangup_all_calls(tapi_context context, int slot_id);

挂断所有通话。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 保持与切换

## tapi_call_release_and_answer
    
    
    int tapi_call_release_and_answer(tapi_context context, int slot_id);

挂断当前通话并接听等待中的来电。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_call_hold_and_answer
    
    
    int tapi_call_hold_and_answer(tapi_context context, int slot_id);

保持当前通话并接听等待中的来电。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_call_release_and_swap
    
    
    int tapi_call_release_and_swap(tapi_context context, int slot_id);

挂断当前通话并切换到保持中的通话。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_call_hold_call
    
    
    int tapi_call_hold_call(tapi_context context, int slot_id);

保持当前通话。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_call_unhold_call
    
    
    int tapi_call_unhold_call(tapi_context context, int slot_id);

恢复保持中的通话。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 转移与会议

## tapi_call_transfer
    
    
    int tapi_call_transfer(tapi_context context, int slot_id);

转接通话。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_call_merge_call
    
    
    int tapi_call_merge_call(tapi_context context, int slot_id, int event_id, tapi_async_function p_handle);

合并通话（多方通话）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_call_merge_call_async
    
    
    int tapi_call_merge_call_async(tapi_context context, int slot_id, int event_id, void* user_data, tapi_async_function p_handle);

合并通话（多方通话）（异步版本）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * user_data 用户数据，传递给回调函数。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_call_separate_call
    
    
    int tapi_call_separate_call(tapi_context context, int slot_id, int event_id, char* call_id, tapi_async_function p_handle);

从多方通话中分离指定通话。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * call_id 通话 ID。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_call_hangup_multiparty
    
    
    int tapi_call_hangup_multiparty(tapi_context context, int slot_id);

挂断多方通话会议。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# DTMF 与拨号音

## tapi_call_send_tones
    
    
    int tapi_call_send_tones(void* context, int slot_id, char* tones);

发送 DTMF 按键音播放请求。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * tones DTMF 按键序列。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 通话查询

## tapi_call_get_all_calls
    
    
    int tapi_call_get_all_calls(tapi_context context, int slot_id, int event_id, tapi_async_function p_handle);

获取当前所有通话。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_call_get_call_by_state
    
    
    int tapi_call_get_call_by_state(tapi_context context, int slot_id, int state, tapi_call_info* call_list, int size, tapi_call_info* out_list);

按通话状态筛选通话。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * state 状态。
  * call_list 通话列表。
  * size 大小。
  * out_list 输出列表。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 紧急号码

## tapi_call_get_ecc_list
    
    
    int tapi_call_get_ecc_list(tapi_context context, int slot_id, ecc_info* out);

获取紧急呼叫号码列表。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_call_is_emergency_number
    
    
    int tapi_call_is_emergency_number(tapi_context context, char* number);

检查指定号码是否是紧急号码。

**参数** ：

  * context Telephony 上下文句柄。
  * number 电话号码。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 事件订阅

## tapi_call_register_emergency_list_change
    
    
    int tapi_call_register_emergency_list_change(tapi_context context, int slot_id, void* user_obj, tapi_async_function p_handle);

注册紧急号码列表变更回调。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * user_obj 用户对象指针。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_call_register_ringback_tone_change
    
    
    int tapi_call_register_ringback_tone_change(tapi_context context, int slot_id, void* user_obj, tapi_async_function p_handle);

注册回铃音变更回调。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * user_obj 用户对象指针。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_call_register_default_voicecall_slot_change
    
    
    int tapi_call_register_default_voicecall_slot_change(tapi_context context, void* user_obj, tapi_async_function p_handle);

注册默认语音通话卡槽变更回调。

**参数** ：

  * context Telephony 上下文句柄。
  * user_obj 用户对象指针。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 会议通话

## tapi_call_dial_conferece
    
    
    int tapi_call_dial_conferece(tapi_context context, int slot_id, char* participants[], int size);

发起 IMS 会议通话。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * participants 参与者列表。
  * size 大小。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_call_invite_participants
    
    
    int tapi_call_invite_participants(tapi_context context, int slot_id, char* participants[], int size);

请求会议服务器邀请额外参与者加入会议。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * participants 参与者列表。
  * size 大小。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_call_register_call_state_change
    
    
    int tapi_call_register_call_state_change(tapi_context context, int slot_id, void* user_obj, tapi_async_function p_handle);

注册通话状态变更回调。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * user_obj 用户对象指针。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 按 ID 操作

## tapi_call_answer_by_id
    
    
    int tapi_call_answer_by_id(tapi_context context, int slot_id, char* call_id);

按 ID 接听通话。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * call_id 通话 ID。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_call_answer_by_id_async
    
    
    int tapi_call_answer_by_id_async(tapi_context context, int slot_id, char* call_id, void* user_obj, tapi_async_function p_handle);

按 ID 接听通话（异步版本，结果通过回调返回）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * call_id 通话 ID。
  * user_obj 用户对象指针。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_call_hangup_by_id
    
    
    int tapi_call_hangup_by_id(tapi_context context, int slot_id, char* call_id);

按 ID 挂断通话。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * call_id 通话 ID。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_call_deflect_by_id
    
    
    int tapi_call_deflect_by_id(tapi_context context, int slot_id, char* call_id, char* number);

转移来电到指定号码。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * call_id 通话 ID。
  * number 电话号码。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 连续 DTMF

## tapi_call_start_dtmf
    
    
    int tapi_call_start_dtmf(tapi_context context, int slot_id, unsigned char digit, int event_id, tapi_async_function p_handle);

开始发送 DTMF 按键音。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * digit DTMF 按键字符。
  * event_id 事件 ID，用于回调匹配。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_call_stop_dtmf
    
    
    int tapi_call_stop_dtmf(tapi_context context, int slot_id, int event_id, tapi_async_function p_handle);

停止发送 DTMF 按键音。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 默认卡槽

## tapi_call_set_default_slot
    
    
    int tapi_call_set_default_slot(tapi_context context, int slot_id);

设置默认语音通话卡槽。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_call_get_default_slot
    
    
    int tapi_call_get_default_slot(tapi_context context, int* out);

获取默认语音通话卡槽。

**参数** ：

  * context Telephony 上下文句柄。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

---

## Telephony 补充业务（SS）API

> 路径: 应用框架 > 电话服务（Telephony） > Telephony 补充业务（SS）API
> 来源: [https://doc.openvela.com/document?id=1141&language=cn&version=dev](https://doc.openvela.com/document?id=1141&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/telephony/telephony_ss.md>) | 简体中文 ]

# Telephony 补充业务（SS）API

Supplementary Services（补充业务）是 3GPP 蜂窝标准定义的增值通话能力，包括呼叫限制（Call Barring）、呼叫转移（Call Forwarding）、主叫识别（CLIR/CLIP）、呼叫等待、USSD 等。

头文件：#include <tapi_ss.h>

# openvela 实现说明

  * **呼叫限制 Call Barring** ：tapi_ss_*_call_barring* 系列控制拨出/拨入的号码范围
  * **呼叫转移 Call Forwarding** ：tapi_ss_*_call_forwarding* 系列配置无条件/忙/无应答/不可达四种转移
  * **CLIR/CLIP** ：主叫号码显示与限制，通过 calling_line_restriction 和 calling_line_presentation_info 接口
  * **USSD** ：tapi_ss_send_ussd 发送 *#xxxx# 命令，tapi_ss_cancel_ussd 取消会话
  * **FDN** ：固定拨号开关通过 tapi_ss_enable_fdn / tapi_ss_query_fdn
  * **SIM 卡标识** ：所有接口带 slot_id
  * **异步回调** ：所有操作使用 tapi_async_function


# 呼叫限制

## tapi_ss_request_call_barring
    
    
    int tapi_ss_request_call_barring(tapi_context context, int slot_id, int event_id,
                                     char* fac, char* pin2,
                                     tapi_async_function p_handle);

请求某类呼叫限制（按 FAC 编码）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * event_id 事件 ID。
  * fac 呼叫限制 FAC 码（如 "OI"、"IR" 等）。
  * pin2 SIM 卡 PIN2 码。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_ss_set_call_barring_option
    
    
    int tapi_ss_set_call_barring_option(tapi_context context, int slot_id, int event_id,
                                        char* facility, char* pin2,
                                        tapi_async_function p_handle);

设置呼叫限制选项。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * event_id 事件 ID。
  * facility 限制类型字符串。
  * pin2 SIM 卡 PIN2 码。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_ss_get_call_barring_option
    
    
    int tapi_ss_get_call_barring_option(tapi_context context, int slot_id,
                                        const char* service_type, char** out);

查询当前呼叫限制配置。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * service_type 服务类型字符串。
  * out 输出参数，返回配置字符串。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_ss_change_call_barring_password
    
    
    int tapi_ss_change_call_barring_password(tapi_context context, int slot_id, int event_id,
                                             char* old_pin, char* new_pin,
                                             tapi_async_function p_handle);

修改呼叫限制服务的密码。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * event_id 事件 ID。
  * old_pin 旧密码。
  * new_pin 新密码。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_ss_disable_all_call_barrings
    
    
    int tapi_ss_disable_all_call_barrings(tapi_context context, int slot_id, int event_id,
                                          char* passwd, tapi_async_function p_handle);

关闭所有呼叫限制。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * event_id 事件 ID。
  * passwd 服务密码。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_ss_disable_all_incoming
    
    
    int tapi_ss_disable_all_incoming(tapi_context context, int slot_id,
                                     int event_id, char* passwd,
                                     tapi_async_function p_handle);

关闭所有入呼限制。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * event_id 事件 ID。
  * passwd 服务密码。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_ss_disable_all_outgoing
    
    
    int tapi_ss_disable_all_outgoing(tapi_context context, int slot_id,
                                     int event_id, char* passwd,
                                     tapi_async_function p_handle);

关闭所有出呼限制。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * event_id 事件 ID。
  * passwd 服务密码。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 呼叫转移

## tapi_ss_query_call_forwarding_option
    
    
    int tapi_ss_query_call_forwarding_option(tapi_context context, int slot_id, int event_id,
                                             int cf_reason, tapi_async_function p_handle);

查询呼叫转移配置。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * event_id 事件 ID。
  * cf_reason 转移类型（无条件/忙/无应答/不可达，详见 tapi_call_forward_option）。
  * p_handle 异步回调函数，回调时返回 tapi_call_forwarding_info。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_ss_set_call_forwarding_option
    
    
    int tapi_ss_set_call_forwarding_option(tapi_context context, int slot_id, int event_id,
                                           tapi_call_forwarding_info* info,
                                           tapi_async_function p_handle);

设置呼叫转移配置。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * event_id 事件 ID。
  * info 呼叫转移配置结构体。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# USSD 会话

## tapi_ss_initiate_service
    
    
    int tapi_ss_initiate_service(tapi_context context, int slot_id, int event_id,
                                 char* command, tapi_async_function p_handle);

发起 SS 服务命令（USSD/SS 字符串形式，如 *#06#）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * event_id 事件 ID。
  * command 命令字符串。
  * p_handle 异步回调函数，回调返回 tapi_ss_initiate_info。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_get_ussd_state
    
    
    int tapi_get_ussd_state(tapi_context context, int slot_id, char** out);

查询当前 USSD 会话状态。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * out 输出参数，返回状态字符串（如 "idle"、"user-response"）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_ss_send_ussd
    
    
    int tapi_ss_send_ussd(tapi_context context, int slot_id, int event_id, char* reply,
                         tapi_async_function p_handle);

发送 USSD 回复消息。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * event_id 事件 ID。
  * reply 回复字符串。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_ss_cancel_ussd
    
    
    int tapi_ss_cancel_ussd(tapi_context context, int slot_id, int event_id,
                           tapi_async_function p_handle);

取消当前 USSD 会话。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * event_id 事件 ID。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 呼叫等待

## tapi_ss_set_call_waiting
    
    
    int tapi_ss_set_call_waiting(tapi_context context, int slot_id, int event_id, bool enable,
                                 tapi_async_function p_handle);

启用或禁用呼叫等待功能。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * event_id 事件 ID。
  * enable true 启用，false 禁用。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_ss_get_call_waiting
    
    
    int tapi_ss_get_call_waiting(tapi_context context, int slot_id, int event_id,
                                 tapi_async_function p_handle);

查询呼叫等待开关状态。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * event_id 事件 ID。
  * p_handle 异步回调函数，回调返回当前状态。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# CLIR / CLIP（主叫号码显示与限制）

## tapi_ss_get_calling_line_presentation_info
    
    
    int tapi_ss_get_calling_line_presentation_info(tapi_context context, int slot_id,
                                                   int event_id, tapi_async_function p_handle);

查询主叫号码显示（CLIP）状态。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * event_id 事件 ID。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_ss_set_calling_line_restriction
    
    
    int tapi_ss_set_calling_line_restriction(tapi_context context, int slot_id, int event_id,
                                             tapi_clir_status status,
                                             tapi_async_function p_handle);

设置主叫号码限制（CLIR）状态。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * event_id 事件 ID。
  * status CLIR 状态枚举值（CLIR_DEFAULT / CLIR_INVOCATION / CLIR_SUPPRESSION）。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_ss_get_calling_line_restriction_info
    
    
    int tapi_ss_get_calling_line_restriction_info(tapi_context context, int slot_id,
                                                  int event_id, tapi_async_function p_handle);

查询主叫号码限制（CLIR）状态。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * event_id 事件 ID。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# FDN（固定拨号）开关

## tapi_ss_enable_fdn
    
    
    int tapi_ss_enable_fdn(tapi_context context, int slot_id, int event_id,
                          bool enable, char* pin2, tapi_async_function p_handle);

启用或禁用 FDN 模式（需要 PIN2）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * event_id 事件 ID。
  * enable true 启用 FDN，false 禁用。
  * pin2 SIM 卡 PIN2 码。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_ss_query_fdn
    
    
    int tapi_ss_query_fdn(tapi_context context, int slot_id, int event_id,
                         tapi_async_function p_handle);

查询 FDN 开关状态。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * event_id 事件 ID。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 事件订阅

## tapi_ss_register
    
    
    int tapi_ss_register(tapi_context context, int slot_id, tapi_indication_msg msg,
                        void* user_obj, tapi_async_function p_handle);

注册 SS 相关事件回调。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * msg 要监听的事件类型。
  * user_obj 用户数据。
  * p_handle 事件回调函数。


**返回值** ：

成功时返回 watch ID，失败时返回负的错误码。

## tapi_ss_unregister
    
    
    int tapi_ss_unregister(tapi_context context, int watch_id);

取消 SS 事件订阅。

**参数** ：

  * context Telephony 上下文句柄。
  * watch_id 订阅时返回的 watch ID。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

---

## Telephony Phone Service API

> 路径: 应用框架 > 电话服务（Telephony） > Telephony Phone Service API
> 来源: [https://doc.openvela.com/document?id=1142&language=cn&version=dev](https://doc.openvela.com/document?id=1142&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/telephony/telephony_phone.md>) | 简体中文 ]

# Telephony Phone Service API

简化版电话服务接口，面向轻量客户端使用。相较于 tapi_call，该模块封装更紧凑的通话控制能力，并整合音频类型控制、无线电开关和 WTP（Wireless Telephony Profile）配套接口。

头文件：#include <tapi_phone.h>

# openvela 实现说明

  * **客户端会话** ：通过 tapi_start_phone_service_client 启动，tapi_stop_phone_service_client 停止
  * **回调注册** ：通过 tapi_client_register_callbacks 注册统一回调，监听通话事件
  * **无需 tapi_context** ：本接口在底层自管理与服务端的连接，调用方不需要持有 tapi_context
  * **WTP 支持** ：封装蓝牙配对手表/设备的 WTP（Wireless Telephony Profile）适配能力
  * **适用场景** ：嵌入式可穿戴设备、简单通话客户端


# 服务生命周期

## tapi_start_phone_service_client
    
    
    int tapi_start_phone_service_client(const char* client_name);

启动电话服务客户端。

**参数** ：

  * client_name 客户端名称。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stop_phone_service_client
    
    
    int tapi_stop_phone_service_client(void);

停止电话服务客户端。

**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_client_register_callbacks
    
    
    int tapi_client_register_callbacks(void* callbacks);

注册客户端回调集合。

**参数** ：

  * callbacks 回调函数集合指针。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_client_unregister_callbacks
    
    
    int tapi_client_unregister_callbacks(void);

取消客户端回调注册。

**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 通话控制

## tapi_dial_call
    
    
    int tapi_dial_call(const char* number);

拨打电话。

**参数** ：

  * number 要拨打的号码字符串。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_answer_call
    
    
    int tapi_answer_call(void);

接听来电。

**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_reject_call
    
    
    int tapi_reject_call(void);

拒绝来电。

**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_hangup_call
    
    
    int tapi_hangup_call(void);

挂断当前通话。

**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_hold_call
    
    
    int tapi_hold_call(void);

保持当前通话。

**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_hold_and_answer_call
    
    
    int tapi_hold_and_answer_call(void);

保持当前通话并接听新来电。

**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_release_and_answer_call
    
    
    int tapi_release_and_answer_call(void);

释放当前通话并接听新来电。

**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_merge_call
    
    
    int tapi_merge_call(void);

合并多个通话形成会议通话。

**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_send_tones
    
    
    int tapi_send_tones(const char* tones);

发送 DTMF 音序列。

**参数** ：

  * tones DTMF 字符串（0-9 * # A-D）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 音频与射频控制

## tapi_client_set_audio_type
    
    
    int tapi_client_set_audio_type(int type);

设置通话期间使用的音频类型。

**参数** ：

  * type 音频类型枚举值。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_client_set_radio_power
    
    
    int tapi_client_set_radio_power(bool enabled);

简化版射频功率开关。

**参数** ：

  * enabled true 开启射频，false 关闭。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# WTP（无线电话配置文件）

## tapi_client_wtp_register_cb
    
    
    int tapi_client_wtp_register_cb(void* callbacks);

注册 WTP 事件回调。

**参数** ：

  * callbacks WTP 回调集合指针。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_client_wtp_unregister_cb
    
    
    int tapi_client_wtp_unregister_cb(void);

取消 WTP 事件回调注册。

**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_wtp_set_local_info
    
    
    int tapi_wtp_set_local_info(const char* info);

设置 WTP 本地信息（设备标识、能力等）。

**参数** ：

  * info 本地信息字符串。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_wtp_modify_discovery
    
    
    int tapi_wtp_modify_discovery(int mode);

修改 WTP 发现模式。

**参数** ：

  * mode 发现模式枚举值。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_wtp_modify_visibility
    
    
    int tapi_wtp_modify_visibility(int visibility);

修改 WTP 可见性配置。

**参数** ：

  * visibility 可见性枚举值。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

---

## 网络服务 API

> 路径: 应用框架 > 电话服务（Telephony） > 网络服务 API
> 来源: [https://doc.openvela.com/document?id=1143&language=cn&version=dev](https://doc.openvela.com/document?id=1143&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/telephony/telephony_network.md>) | 简体中文 ]

# 网络服务 API

蜂窝网络注册、信号强度、运营商信息等。

头文件：#include <tapi_network.h>

# openvela 实现说明

  * **选网模式** ：支持自动选网（select_auto）和手动选网（select_manual）
  * **扫描** ：tapi_network_scan 扫描可用的网络运营商
  * **小区信息** ：get_serving_cellinfos 获取当前服务小区，get_neighbouring_cellinfos 获取相邻小区
  * **SIM 卡标识** ：大部分接口带 slot_id，区分不同 SIM 卡槽的网络状态
  * **事件订阅** ：tapi_network_register / tapi_network_unregister 监听注册状态/信号强度变化


# 选网与扫描

## tapi_network_select_auto
    
    
    int tapi_network_select_auto(tapi_context context, int slot_id, int event_id, tapi_async_function p_handle);

自动选择网络。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_network_select_manual
    
    
    int tapi_network_select_manual(tapi_context context, int slot_id, int event_id, tapi_operator_info* network, tapi_async_function p_handle);

手动选择网络。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * network 网络信息。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_network_scan
    
    
    int tapi_network_scan(tapi_context context, int slot_id, int event_id, tapi_async_function p_handle);

手动选择指定网络。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 小区信息

## tapi_network_get_serving_cellinfos
    
    
    int tapi_network_get_serving_cellinfos(tapi_context context, int slot_id, int event_id, tapi_async_function p_handle);

手动选择指定网络。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_network_get_neighbouring_cellinfos
    
    
    int tapi_network_get_neighbouring_cellinfos(tapi_context context, int slot_id, int event_id, tapi_async_function p_handle);

手动选择指定网络。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 语音网络状态

## tapi_network_is_voice_registered
    
    
    int tapi_network_is_voice_registered(tapi_context context, int slot_id, bool* out);

查询是否已注册语音服务。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_network_is_voice_emergency_only
    
    
    int tapi_network_is_voice_emergency_only(tapi_context context, int slot_id, bool* out);

手动选择指定网络。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_network_get_voice_network_type
    
    
    int tapi_network_get_voice_network_type(tapi_context context, int slot_id, tapi_network_type* out);

获取语音网络类型。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_network_is_voice_roaming
    
    
    int tapi_network_is_voice_roaming(tapi_context context, int slot_id, bool* out);

手动选择指定网络。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 运营商信息

## tapi_network_get_display_name
    
    
    int tapi_network_get_display_name(tapi_context context, int slot_id, char** out);

手动选择指定网络。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 信号强度

## tapi_network_get_signalstrength
    
    
    int tapi_network_get_signalstrength(tapi_context context, int slot_id, tapi_signal_strength* out);

手动选择指定网络。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 注册信息

## tapi_network_get_registration_info
    
    
    int tapi_network_get_registration_info(tapi_context context, int slot_id, int event_id, tapi_async_function p_handle);

获取网络注册信息。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 上报频率与事件

## tapi_network_set_cell_info_list_rate
    
    
    int tapi_network_set_cell_info_list_rate(tapi_context context, int slot_id, int event_id, u_int32_t period, tapi_async_function p_handle);

手动选择指定网络。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * period 周期（毫秒）。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_network_register
    
    
    int tapi_network_register(tapi_context context, int slot_id, tapi_indication_msg msg, void* user_obj, tapi_async_function p_handle);

手动选择指定网络。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * msg 消息内容。
  * user_obj 用户对象指针。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_network_unregister
    
    
    int tapi_network_unregister(tapi_context context, int watch_id);

手动选择指定网络。

**参数** ：

  * context Telephony 上下文句柄。
  * watch_id 监听 ID（用于取消监听）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# MCC / MNC

## tapi_network_get_mcc
    
    
    int tapi_network_get_mcc(tapi_context context, int slot_id, char** mcc);

手动选择指定网络。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * mcc 移动国家码。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_network_get_mnc
    
    
    int tapi_network_get_mnc(tapi_context context, int slot_id, char** mnc);

手动选择指定网络。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * mnc 移动网络码。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_network_get_operator_status
    
    
    int tapi_network_get_operator_status(tapi_context context, int slot_id, int* out);

手动选择指定网络。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_network_get_operator_name
    
    
    int tapi_network_get_operator_name(tapi_context context, int slot_id, char** out);

获取运营商名称。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_network_get_reg_state
    
    
    int tapi_network_get_reg_state(tapi_context context, int slot_id, tapi_registration_state* out);

手动选择指定网络。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

---

## 数据连接 API

> 路径: 应用框架 > 电话服务（Telephony） > 数据连接 API
> 来源: [https://doc.openvela.com/document?id=1144&language=cn&version=dev](https://doc.openvela.com/document?id=1144&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/telephony/telephony_data.md>) | 简体中文 ]

# 数据连接 API

蜂窝数据连接管理。

头文件：#include <tapi_data.h>

# openvela 实现说明

  * **APN 上下文** ：通过 tapi_data_*_apn_context 系列接口管理 APN 配置（增删改查）
  * **按需连接** ：tapi_data_request_network / tapi_data_release_network 控制数据网络的建立与释放
  * **漫游控制** ：通过 tapi_data_enable_roaming 显式开关数据漫游
  * **SIM 卡标识** ：涉及特定卡的操作使用 slot_id 参数；数据默认卡通过 tapi_data_set_default_slot 设置
  * **状态订阅** ：tapi_data_register / tapi_data_unregister 用于注册/取消状态变化事件


# APN 配置管理

## tapi_data_load_apn_contexts
    
    
    int tapi_data_load_apn_contexts(tapi_context context, int slot_id, int event_id, tapi_async_function p_handle);

加载 APN 配置。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_data_add_apn_context
    
    
    int tapi_data_add_apn_context(tapi_context context, int slot_id, int event_id, tapi_data_context* apn, tapi_async_function p_handle);

加载 APN 配置列表。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * apn 接入点名称（APN）。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_data_remove_apn_context
    
    
    int tapi_data_remove_apn_context(tapi_context context, int slot_id, int event_id, tapi_data_context* apn, tapi_async_function p_handle);

删除 APN 配置。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * apn 接入点名称（APN）。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_data_edit_apn_context
    
    
    int tapi_data_edit_apn_context(tapi_context context, int slot_id, int event_id, tapi_data_context* apn, tapi_async_function p_handle);

加载 APN 配置列表。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * apn 接入点名称（APN）。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_data_reset_apn_contexts
    
    
    int tapi_data_reset_apn_contexts(tapi_context context, int slot_id, int event_id, tapi_async_function p_handle);

重置 APN 配置为默认值。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 数据网络状态

## tapi_data_is_registered
    
    
    int tapi_data_is_registered(tapi_context context, int slot_id, bool* out);

加载 APN 配置列表。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_data_is_data_emergency_only
    
    
    int tapi_data_is_data_emergency_only(tapi_context context, int slot_id, bool* out);

加载 APN 配置列表。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_data_get_network_type
    
    
    int tapi_data_get_network_type(tapi_context context, int slot_id, tapi_network_type* out);

获取当前网络类型。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_data_is_data_roaming
    
    
    int tapi_data_is_data_roaming(tapi_context context, int slot_id, bool* out);

加载 APN 配置列表。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 数据连接控制

## tapi_data_request_network
    
    
    int tapi_data_request_network(tapi_context context, int slot_id, const char* type);

请求建立数据连接。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * type 类型。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_data_release_network
    
    
    int tapi_data_release_network(tapi_context context, int slot_id, const char* type);

释放数据连接。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * type 类型。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_data_get_data_connection_list
    
    
    int tapi_data_get_data_connection_list(tapi_context context, int slot_id, int event_id, tapi_async_function p_handle);

加载 APN 配置列表。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 首选 APN

## tapi_data_set_preferred_apn
    
    
    int tapi_data_set_preferred_apn(tapi_context context, int slot_id, tapi_data_context* apn);

加载 APN 配置列表。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * apn 接入点名称（APN）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_data_get_preferred_apn
    
    
    int tapi_data_get_preferred_apn(tapi_context context, int slot_id, char** out);

加载 APN 配置列表。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 数据开关

## tapi_data_enable_data
    
    
    int tapi_data_enable_data(tapi_context context, bool enabled);

加载 APN 配置列表。

**参数** ：

  * context Telephony 上下文句柄。
  * enabled 是否启用。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_data_get_enabled
    
    
    int tapi_data_get_enabled(tapi_context context, bool* out);

查询 IMS 是否启用。

**参数** ：

  * context Telephony 上下文句柄。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 漫游控制

## tapi_data_enable_roaming
    
    
    int tapi_data_enable_roaming(tapi_context context, bool enabled);

加载 APN 配置列表。

**参数** ：

  * context Telephony 上下文句柄。
  * enabled 是否启用。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_data_get_roaming_enabled
    
    
    int tapi_data_get_roaming_enabled(tapi_context context, bool* out);

加载 APN 配置列表。

**参数** ：

  * context Telephony 上下文句柄。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 默认卡槽与授权

## tapi_data_set_default_slot
    
    
    int tapi_data_set_default_slot(tapi_context context, int slot_id);

加载 APN 配置列表。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_data_get_default_slot
    
    
    int tapi_data_get_default_slot(tapi_context context, int* out);

加载 APN 配置列表。

**参数** ：

  * context Telephony 上下文句柄。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_data_set_data_allow
    
    
    int tapi_data_set_data_allow(tapi_context context, int slot_id, int event_id, bool allowed, tapi_async_function p_handle);

加载 APN 配置列表。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * allowed 是否允许。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 事件订阅

## tapi_data_register
    
    
    int tapi_data_register(tapi_context context, int slot_id, tapi_indication_msg msg, void* user_obj, tapi_async_function p_handle);

加载 APN 配置列表。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * msg 消息内容。
  * user_obj 用户对象指针。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_data_unregister
    
    
    int tapi_data_unregister(tapi_context context, int watch_id);

加载 APN 配置列表。

**参数** ：

  * context Telephony 上下文句柄。
  * watch_id 监听 ID（用于取消监听）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

---

## SIM 卡管理 API

> 路径: 应用框架 > 电话服务（Telephony） > SIM 卡管理 API
> 来源: [https://doc.openvela.com/document?id=1145&language=cn&version=dev](https://doc.openvela.com/document?id=1145&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/telephony/telephony_sim.md>) | 简体中文 ]

# SIM 卡管理 API

SIM 卡状态查询和管理。

头文件：#include <tapi_sim.h>

# openvela 实现说明

  * **SIM 卡管理** ：所有接口均带 slot_id 参数，用于标识 SIM 卡
  * **PIN 管理** ：提供 enter_pin / change_pin / reset_pin / lock_pin / unlock_pin 完整 PIN/PUK 流程
  * **APDU 通道** ：通过 open_logical_channel / close_logical_channel / transmit_apdu_* 直接向 SIM 卡发送 APDU 命令
  * **UICC 开关** ：通过 get_uicc_enablement / set_uicc_enablement 控制 SIM 卡的启用状态
  * **事件订阅** ：tapi_sim_register / tapi_sim_unregister 监听 SIM 卡状态变化


# SIM 状态查询

## tapi_sim_has_icc_card
    
    
    int tapi_sim_has_icc_card(tapi_context context, int slot_id, bool* out);

查询是否插入 SIM 卡。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sim_get_sim_state
    
    
    int tapi_sim_get_sim_state(tapi_context context, int slot_id, int* out);

获取 SIM 卡状态。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sim_get_sim_operator
    
    
    int tapi_sim_get_sim_operator(tapi_context context, int slot_id, int length, char* out);

获取 SIM 卡运营商信息。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * length 数据长度。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sim_get_sim_operator_name
    
    
    int tapi_sim_get_sim_operator_name(tapi_context context, int slot_id, char** out);

获取 SIM 卡运营商信息。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sim_get_sim_iccid
    
    
    int tapi_sim_get_sim_iccid(tapi_context context, int slot_id, char** out);

获取 SIM 卡 ICCID。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sim_get_subscriber_id
    
    
    int tapi_sim_get_subscriber_id(tapi_context context, int slot_id, char** out);

获取用户标识（IMSI）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 事件订阅

## tapi_sim_register
    
    
    int tapi_sim_register(tapi_context context, int slot_id, tapi_indication_msg msg, void* user_obj, tapi_async_function p_handle);

获取用户标识（IMSI）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * msg 消息内容。
  * user_obj 用户对象指针。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sim_unregister
    
    
    int tapi_sim_unregister(tapi_context context, int watch_id);

获取用户标识（IMSI）。

**参数** ：

  * context Telephony 上下文句柄。
  * watch_id 监听 ID（用于取消监听）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# PIN 管理

## tapi_sim_change_pin
    
    
    int tapi_sim_change_pin(tapi_context context, int slot_id, int event_id, char* pin_type, char* old_pin, char* new_pin, tapi_async_function p_handle);

获取用户标识（IMSI）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * pin_type PIN 码类型。
  * old_pin 旧 PIN 码。
  * new_pin 新 PIN 码。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sim_enter_pin
    
    
    int tapi_sim_enter_pin(tapi_context context, int slot_id, int event_id, char* pin_type, char* pin, tapi_async_function p_handle);

获取用户标识（IMSI）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * pin_type PIN 码类型。
  * pin PIN 码。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sim_reset_pin
    
    
    int tapi_sim_reset_pin(tapi_context context, int slot_id, int event_id, char* puk_type, char* puk, char* new_pin, tapi_async_function p_handle);

获取用户标识（IMSI）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * puk_type PUK 码类型。
  * puk PUK 码。
  * new_pin 新 PIN 码。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sim_lock_pin
    
    
    int tapi_sim_lock_pin(tapi_context context, int slot_id, int event_id, char* pin_type, char* pin, tapi_async_function p_handle);

获取用户标识（IMSI）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * pin_type PIN 码类型。
  * pin PIN 码。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sim_unlock_pin
    
    
    int tapi_sim_unlock_pin(tapi_context context, int slot_id, int event_id, char* pin_type, char* pin, tapi_async_function p_handle);

获取用户标识（IMSI）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * pin_type PIN 码类型。
  * pin PIN 码。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# APDU 逻辑通道

## tapi_sim_open_logical_channel
    
    
    int tapi_sim_open_logical_channel(tapi_context context, int slot_id, int event_id, unsigned char aid[], int len, tapi_async_function p_handle);

打开 SIM 卡逻辑通道。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * aid 应用 ID。
  * len 长度。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sim_close_logical_channel
    
    
    int tapi_sim_close_logical_channel(tapi_context context, int slot_id, int event_id, int session_id, tapi_async_function p_handle);

关闭 SIM 卡逻辑通道。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * session_id 会话 ID。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sim_transmit_apdu_logical_channel
    
    
    int tapi_sim_transmit_apdu_logical_channel(tapi_context context, int slot_id, int event_id, int session_id, unsigned char pdu[], int len, tapi_async_function p_handle);

通过逻辑通道发送 APDU 命令。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * session_id 会话 ID。
  * pdu PDU 数据。
  * len 长度。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sim_transmit_apdu_basic_channel
    
    
    int tapi_sim_transmit_apdu_basic_channel(tapi_context context, int slot_id, int event_id, unsigned char pdu[], int len, tapi_async_function p_handle);

通过逻辑通道发送 APDU 命令。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * pdu PDU 数据。
  * len 长度。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# UICC 开关

## tapi_sim_get_uicc_enablement
    
    
    int tapi_sim_get_uicc_enablement(tapi_context context, int slot_id, tapi_sim_uicc_app_state* out);

获取用户标识（IMSI）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sim_set_uicc_enablement
    
    
    int tapi_sim_set_uicc_enablement(tapi_context context, int slot_id, int event_id, int state, tapi_async_function p_handle);

获取用户标识（IMSI）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * event_id 事件 ID，用于回调匹配。
  * state 状态。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sim_get_sim_invalid
    
    
    int tapi_sim_get_sim_invalid(tapi_context context, int slot_id, int* out);

获取用户标识（IMSI）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

---

## Telephony SIM Toolkit (STK) API

> 路径: 应用框架 > 电话服务（Telephony） > Telephony SIM Toolkit (STK) API
> 来源: [https://doc.openvela.com/document?id=1146&language=cn&version=dev](https://doc.openvela.com/document?id=1146&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/telephony/telephony_stk.md>) | 简体中文 ]

# Telephony SIM Toolkit (STK) API

SIM Application Toolkit（STK / CAT）是运营商在 SIM 卡上预置的交互菜单与事件处理能力，常见用途包括运营商增值菜单、服务密码管理、URL 浏览器启动等。

头文件：#include <tapi_stk.h>

# openvela 实现说明

  * **Agent 模式** ：应用侧作为"STK Agent"注册到 TAPI，SIM 卡主动发起的显示/输入/确认请求通过 Agent 回调触达应用
  * **注册层级** ：支持 per-slot Agent（通过 tapi_stk_agent_register）与 default Agent（系统默认 UI）
  * **主菜单** ：tapi_stk_get_main_menu* 查询 SIM 卡提供的主菜单结构
  * **Proactive Command 响应** ：tapi_stk_handle_agent_* 系列接口用于将 Agent 对 SIM 卡主动命令的响应回传给 SIM
  * **SIM 卡标识** ：所有接口带 slot_id


# Agent 注册

## tapi_stk_agent_register
    
    
    int tapi_stk_agent_register(tapi_context context, int slot_id,
                                char* agent_id, tapi_async_function p_handle);

为指定 SIM 卡槽注册 STK Agent。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * agent_id Agent 标识字符串。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_agent_unregister
    
    
    int tapi_stk_agent_unregister(tapi_context context, int slot_id,
                                  char* agent_id, tapi_async_function p_handle);

取消 STK Agent 注册。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * agent_id Agent 标识字符串。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_default_agent_register
    
    
    int tapi_stk_default_agent_register(tapi_context context, int slot_id,
                                        char* agent_id, tapi_async_function p_handle);

注册为默认 STK Agent（全局 fallback）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * agent_id Agent 标识字符串。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_default_agent_unregister
    
    
    int tapi_stk_default_agent_unregister(tapi_context context, int slot_id,
                                          tapi_async_function p_handle);

取消默认 STK Agent 注册。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_agent_interface_register
    
    
    int tapi_stk_agent_interface_register(tapi_context context, int slot_id, char* agent_id,
                                          tapi_stk_agent_interface* iface);

在 Agent 层注册具体的接口实现（回调函数集合）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * agent_id Agent 标识字符串。
  * iface Agent 接口回调结构体指针。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_agent_interface_unregister
    
    
    int tapi_stk_agent_interface_unregister(tapi_context context, char* agent_id);

注销 Agent 接口实现。

**参数** ：

  * context Telephony 上下文句柄。
  * agent_id Agent 标识字符串。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_default_agent_interface_register
    
    
    int tapi_stk_default_agent_interface_register(tapi_context context, int slot_id,
                                                  tapi_stk_agent_interface* iface);

为默认 Agent 注册接口实现。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * iface Agent 接口回调结构体指针。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_default_agent_interface_unregister
    
    
    int tapi_stk_default_agent_interface_unregister(tapi_context context, int slot_id);

注销默认 Agent 的接口实现。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 主菜单与空闲模式

## tapi_stk_select_item
    
    
    int tapi_stk_select_item(tapi_context context, int slot_id,
                             int item_idx, tapi_async_function p_handle);

选择主菜单中的某个条目，触发 SIM 卡的业务响应。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * item_idx 条目索引。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_get_idle_mode_text
    
    
    int tapi_stk_get_idle_mode_text(tapi_context context, int slot_id, char** text);

查询 SIM 卡设定的空闲模式显示文本。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * text 输出参数，返回文本字符串。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_get_idle_mode_icon
    
    
    int tapi_stk_get_idle_mode_icon(tapi_context context, int slot_id, char** icon);

查询 SIM 卡设定的空闲模式图标标识。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * icon 输出参数，返回图标标识字符串。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_get_main_menu
    
    
    int tapi_stk_get_main_menu(tapi_context context, int slot_id, int* length,
                               tapi_stk_menu_item out[]);

获取 SIM 卡提供的主菜单条目列表。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * length 输入输出参数：入参表示缓冲区容量，出参返回实际条目数。
  * out 输出缓冲区，接收菜单条目数组。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_get_main_menu_title
    
    
    int tapi_stk_get_main_menu_title(tapi_context context, int slot_id, char** title);

查询主菜单标题。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * title 输出参数，返回标题字符串。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_get_main_menu_icon
    
    
    int tapi_stk_get_main_menu_icon(tapi_context context, int slot_id, int* icon);

查询主菜单图标编号。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * icon 输出参数，返回图标编号。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# Agent 响应处理

以下接口由 Agent 实现使用，用于向 SIM 卡回传 proactive command 的响应。所有接口成功时返回 0，失败时返回负的错误码。

## tapi_stk_handle_agent_request_selection
    
    
    int tapi_stk_handle_agent_request_selection(tapi_context context, int slot_id,
                                                char* agent_id, int selection,
                                                tapi_async_function p_handle);

处理 SIM 卡的菜单项选择请求，回传用户选中的条目索引。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * agent_id Agent 标识字符串。
  * selection 用户选中的条目索引。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_handle_agent_display_text
    
    
    int tapi_stk_handle_agent_display_text(tapi_context context, int slot_id,
                                           char* agent_id, int result,
                                           tapi_async_function p_handle);

响应 SIM 卡的文本显示请求。

**参数** ：

  * context / slot_id / agent_id 同上。
  * result 显示操作结果（用户是否确认等）。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_handle_agent_request_input
    
    
    int tapi_stk_handle_agent_request_input(tapi_context context, int slot_id,
                                            char* agent_id, char* input,
                                            tapi_async_function p_handle);

响应 SIM 卡的字符串输入请求。

**参数** ：

  * context / slot_id / agent_id 同上。
  * input 用户输入的字符串。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_handle_agent_request_digits
    
    
    int tapi_stk_handle_agent_request_digits(tapi_context context, int slot_id,
                                             char* agent_id, char* digits,
                                             tapi_async_function p_handle);

响应 SIM 卡的数字序列输入请求。

**参数** ：

  * context / slot_id / agent_id 同上。
  * digits 用户输入的数字序列。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_handle_agent_request_key
    
    
    int tapi_stk_handle_agent_request_key(tapi_context context, int slot_id,
                                          char* agent_id, char key,
                                          tapi_async_function p_handle);

响应 SIM 卡的单键输入请求。

**参数** ：

  * context / slot_id / agent_id 同上。
  * key 用户输入的按键字符。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_handle_agent_request_digit
    
    
    int tapi_stk_handle_agent_request_digit(tapi_context context, int slot_id,
                                            char* agent_id, char digit,
                                            tapi_async_function p_handle);

响应 SIM 卡的单数字输入请求。

**参数** ：

  * context / slot_id / agent_id 同上。
  * digit 用户输入的单个数字字符。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_handle_agent_request_quick_digit
    
    
    int tapi_stk_handle_agent_request_quick_digit(tapi_context context, int slot_id,
                                                  char* agent_id, char digit,
                                                  tapi_async_function p_handle);

响应 SIM 卡的快速数字输入请求（无需回显）。

**参数** ：

  * context / slot_id / agent_id 同上。
  * digit 用户输入的单个数字字符。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_handle_agent_request_confirmation
    
    
    int tapi_stk_handle_agent_request_confirmation(tapi_context context, int slot_id,
                                                   char* agent_id, bool confirmed,
                                                   tapi_async_function p_handle);

响应 SIM 卡的确认/取消类请求。

**参数** ：

  * context / slot_id / agent_id 同上。
  * confirmed 用户是否确认。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_handle_agent_confirm_call_setup
    
    
    int tapi_stk_handle_agent_confirm_call_setup(tapi_context context, int slot_id,
                                                 char* agent_id, bool confirmed,
                                                 tapi_async_function p_handle);

响应 SIM 卡发起的 call-setup 确认请求。

**参数** ：

  * context / slot_id / agent_id 同上。
  * confirmed 用户是否确认拨出。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_handle_agent_play_tone
    
    
    int tapi_stk_handle_agent_play_tone(tapi_context context, int slot_id,
                                        char* agent_id, int result,
                                        tapi_async_function p_handle);

响应 SIM 卡的播放提示音请求。

**参数** ：

  * context / slot_id / agent_id 同上。
  * result 播放结果。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_handle_agent_loop_tone
    
    
    int tapi_stk_handle_agent_loop_tone(tapi_context context, int slot_id,
                                        char* agent_id, int result,
                                        tapi_async_function p_handle);

响应 SIM 卡的循环提示音请求。

**参数** ：

  * context / slot_id / agent_id 同上。
  * result 播放结果。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_handle_agent_display_action_information
    
    
    int tapi_stk_handle_agent_display_action_information(tapi_context context, int slot_id,
                                                         char* agent_id, int result,
                                                         tapi_async_function p_handle);

响应 SIM 卡的动作进度信息显示请求。

**参数** ：

  * context / slot_id / agent_id 同上。
  * result 显示操作结果。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_handle_agent_confirm_launch_browser
    
    
    int tapi_stk_handle_agent_confirm_launch_browser(tapi_context context, int slot_id,
                                                     char* agent_id, bool confirmed,
                                                     tapi_async_function p_handle);

响应 SIM 卡的浏览器启动确认请求。

**参数** ：

  * context / slot_id / agent_id 同上。
  * confirmed 用户是否确认启动浏览器。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_handle_agent_display_action
    
    
    int tapi_stk_handle_agent_display_action(tapi_context context, int slot_id,
                                             char* agent_id, int result,
                                             tapi_async_function p_handle);

响应 SIM 卡的动作状态更新请求。

**参数** ：

  * context / slot_id / agent_id 同上。
  * result 操作结果。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_stk_handle_agent_confirm_open_channel
    
    
    int tapi_stk_handle_agent_confirm_open_channel(tapi_context context, int slot_id,
                                                   char* agent_id, bool confirmed,
                                                   tapi_async_function p_handle);

响应 SIM 卡发起的打开数据通道确认请求。

**参数** ：

  * context / slot_id / agent_id 同上。
  * confirmed 用户是否确认打开通道。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

---

## Telephony 电话簿 API

> 路径: 应用框架 > 电话服务（Telephony） > Telephony 电话簿 API
> 来源: [https://doc.openvela.com/document?id=1147&language=cn&version=dev](https://doc.openvela.com/document?id=1147&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/telephony/telephony_phonebook.md>) | 简体中文 ]

# Telephony 电话簿 API

SIM 卡电话簿管理接口，支持 ADN（普通电话簿）和 FDN（固定拨号号码）两类条目。

头文件：#include <tapi_phonebook.h>

# openvela 实现说明

  * **ADN** ：普通电话簿（Abbreviated Dialling Numbers），存储在 SIM 卡上的常规号码
  * **FDN** ：固定拨号号码（Fixed Dialling Numbers），启用后手机只能拨打 FDN 中的号码，受 PIN2 保护
  * **FDN 操作需要 PIN2** ：insert_fdn_entry / delete_fdn_entry / update_fdn_entry 调用时需要传入 PIN2
  * **SIM 卡标识** ：所有接口带 slot_id
  * **异步回调** ：所有操作使用 tapi_async_function 异步返回结果


# ADN 电话簿

## tapi_phonebook_load_adn_entries
    
    
    int tapi_phonebook_load_adn_entries(tapi_context context, int slot_id, int event_id,
                                        tapi_async_function p_handle);

加载 SIM 卡上的 ADN 电话簿条目。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * event_id 事件 ID，用于回调匹配。
  * p_handle 异步回调函数，回调时返回 ADN 条目列表。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# FDN 固定拨号

## tapi_phonebook_load_fdn_entries
    
    
    int tapi_phonebook_load_fdn_entries(tapi_context context, int slot_id, int event_id,
                                        tapi_async_function p_handle);

加载 SIM 卡上的 FDN 条目。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * event_id 事件 ID。
  * p_handle 异步回调函数，回调时返回 FDN 条目列表。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_phonebook_insert_fdn_entry
    
    
    int tapi_phonebook_insert_fdn_entry(tapi_context context, int slot_id, int event_id,
                                        char* name, char* number, char* pin2,
                                        tapi_async_function p_handle);

向 FDN 列表插入一条新条目（需要 PIN2 校验）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * event_id 事件 ID。
  * name 联系人姓名。
  * number 电话号码。
  * pin2 SIM 卡 PIN2 码。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_phonebook_update_fdn_entry
    
    
    int tapi_phonebook_update_fdn_entry(tapi_context context, int slot_id, int event_id,
                                        int fdn_idx, char* new_name, char* new_number,
                                        char* pin2, tapi_async_function p_handle);

更新已有 FDN 条目（需要 PIN2 校验）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * event_id 事件 ID。
  * fdn_idx 要更新的条目索引。
  * new_name 新的联系人姓名。
  * new_number 新的电话号码。
  * pin2 SIM 卡 PIN2 码。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_phonebook_delete_fdn_entry
    
    
    int tapi_phonebook_delete_fdn_entry(tapi_context context, int slot_id, int event_id,
                                        int fdn_idx, char* pin2,
                                        tapi_async_function p_handle);

删除指定 FDN 条目（需要 PIN2 校验）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * event_id 事件 ID。
  * fdn_idx 要删除的条目索引。
  * pin2 SIM 卡 PIN2 码。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

---

## 短信管理 API

> 路径: 应用框架 > 电话服务（Telephony） > 短信管理 API
> 来源: [https://doc.openvela.com/document?id=1148&language=cn&version=dev](https://doc.openvela.com/document?id=1148&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/telephony/telephony_sms.md>) | 简体中文 ]

# 短信管理 API

短信发送和接收。

头文件：#include <tapi_sms.h>

# openvela 实现说明

  * **文本与数据短信** ：send_message 发送文本短信，send_data_message 发送二进制 PDU
  * **服务中心地址** ：通过 set_service_center_address / get_service_center_address 配置运营商短信网关
  * **送达报告** ：可通过 enable_delivery_report 开关送达报告
  * **SIM 卡存储** ：提供 get_all_messages_from_sim / copy_message_to_sim / delete_message_from_sim 操作 SIM 卡上的短信
  * **事件订阅** ：tapi_sms_register 监听收件/发件事件


# 发送短信

## tapi_sms_send_message
    
    
    int tapi_sms_send_message(tapi_context context, int slot_id, int sms_id, char* number, char* text, int event_id, tapi_async_function p_handle);

发送短信。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * sms_id 短信 ID。
  * number 电话号码。
  * text 文本内容。
  * event_id 事件 ID，用于回调匹配。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sms_send_data_message
    
    
    int tapi_sms_send_data_message(tapi_context context, int slot_id, int sms_id, char* dest_addr, unsigned int port, char* text, int event_id, tapi_async_function p_handle);

发送数据短信。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * sms_id 短信 ID。
  * dest_addr 目标号码。
  * port 端口号。
  * text 文本内容。
  * event_id 事件 ID，用于回调匹配。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 服务中心与送达报告

## tapi_sms_set_service_center_address
    
    
    bool tapi_sms_set_service_center_address(tapi_context context, int slot_id, char* number);

发送数据短信。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * number 电话号码。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sms_get_service_center_address
    
    
    int tapi_sms_get_service_center_address(tapi_context context, int slot_id, char** number);

发送数据短信。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * number 电话号码。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sms_enable_delivery_report
    
    
    int tapi_sms_enable_delivery_report(tapi_context context, int slot_id, bool enable);

发送数据短信。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * enable 是否启用。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sms_get_delivery_report_status
    
    
    int tapi_sms_get_delivery_report_status(tapi_context context, int slot_id, bool* out);

发送数据短信。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# SIM 卡短信存储

## tapi_sms_get_all_messages_from_sim
    
    
    int tapi_sms_get_all_messages_from_sim(tapi_context context, int slot_id, tapi_message_list* list, tapi_async_function p_handle);

发送数据短信。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * list 列表。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sms_copy_message_to_sim
    
    
    int tapi_sms_copy_message_to_sim(tapi_context context, int slot_id, char* number, char* text, char* send_time, int type);

发送数据短信。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * number 电话号码。
  * text 文本内容。
  * send_time 发送时间。
  * type 类型。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sms_delete_message_from_sim
    
    
    int tapi_sms_delete_message_from_sim(tapi_context context, int slot_id, int index);

发送数据短信。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * index 索引。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 事件订阅与默认卡

## tapi_sms_register
    
    
    int tapi_sms_register(tapi_context context, int slot_id, tapi_indication_msg msg, void* user_obj, tapi_async_function p_handle);

发送数据短信。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * msg 消息内容。
  * user_obj 用户对象指针。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sms_unregister
    
    
    int tapi_sms_unregister(tapi_context context, int watch_id);

发送数据短信。

**参数** ：

  * context Telephony 上下文句柄。
  * watch_id 监听 ID（用于取消监听）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sms_set_default_slot
    
    
    int tapi_sms_set_default_slot(tapi_context context, int slot_id);

发送数据短信。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sms_get_default_slot
    
    
    int tapi_sms_get_default_slot(tapi_context context, int* out);

发送数据短信。

**参数** ：

  * context Telephony 上下文句柄。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

---

## Telephony 小区广播 API

> 路径: 应用框架 > 电话服务（Telephony） > Telephony 小区广播 API
> 来源: [https://doc.openvela.com/document?id=1149&language=cn&version=dev](https://doc.openvela.com/document?id=1149&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/telephony/telephony_cbs.md>) | 简体中文 ]

# Telephony 小区广播 API

Cell Broadcast Service（CBS）是蜂窝网络的小区广播能力，常用于接收政府紧急警报（地震、海啸）和运营商公告。

头文件：#include <tapi_cbs.h>

# openvela 实现说明

  * **开关控制** ：通过 set_cell_broadcast_power_on 启用/禁用小区广播接收
  * **主题订阅** ：通过 set_cell_broadcast_topics 配置要接收的广播主题范围（按频道 ID）
  * **事件回调** ：通过 tapi_cbs_register 注册事件回调，接收到的广播消息
  * **SIM 卡标识** ：所有接口带 slot_id，支持多 SIM 卡设备
  * **相关协议** ：底层对应 3GPP TS 23.041 定义的 Cell Broadcast 流程


# 开关控制

## tapi_sms_set_cell_broadcast_power_on
    
    
    int tapi_sms_set_cell_broadcast_power_on(tapi_context context, int slot_id, bool enabled);

启用或禁用小区广播接收。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * enabled true 表示启用，false 表示禁用。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sms_get_cell_broadcast_power_on
    
    
    int tapi_sms_get_cell_broadcast_power_on(tapi_context context, int slot_id, bool* enabled);

查询小区广播接收开关状态。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * enabled 输出参数，返回当前开关状态。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 主题订阅

## tapi_sms_set_cell_broadcast_topics
    
    
    int tapi_sms_set_cell_broadcast_topics(tapi_context context, int slot_id, char* topics);

配置小区广播的主题范围（频道 ID 列表）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * topics 主题字符串，典型格式为逗号分隔的频道 ID 或范围（如 "4352-4356,919"）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_sms_get_cell_broadcast_topics
    
    
    int tapi_sms_get_cell_broadcast_topics(tapi_context context, int slot_id, char** topics);

查询当前配置的小区广播主题。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * topics 输出参数，返回主题字符串（调用方负责释放）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 事件订阅

## tapi_cbs_register
    
    
    int tapi_cbs_register(tapi_context context, int slot_id, tapi_indication_msg msg,
                          void* user_obj, tapi_async_function p_handle);

注册小区广播事件回调。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID。
  * msg 要监听的事件类型。
  * user_obj 用户数据，将回传给回调函数。
  * p_handle 事件回调函数。


**返回值** ：

成功时返回事件订阅 watch ID，失败时返回负的错误码。

---

## IMS 服务 API

> 路径: 应用框架 > 电话服务（Telephony） > IMS 服务 API
> 来源: [https://doc.openvela.com/document?id=1150&language=cn&version=dev](https://doc.openvela.com/document?id=1150&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/telephony/telephony_ims.md>) | 简体中文 ]

# IMS 服务 API

IP 多媒体子系统（VoLTE/VoWiFi）管理。

头文件：#include <tapi_ims.h>

# openvela 实现说明

  * **IMS 开关** ：通过 turn_on / turn_off 控制 IMS 服务的启用状态
  * **注册状态** ：查询 IMS 是否已注册到网络，订阅注册状态变化事件
  * **业务开关** ：set_service_status 控制具体业务（如语音、视频）的启用
  * **VoLTE 支持** ：通过 is_volte_available 查询当前网络是否支持 VoLTE
  * **SIM 卡标识** ：所有接口带 slot_id 参数


# IMS 开关

## tapi_ims_turn_on
    
    
    int tapi_ims_turn_on(tapi_context context, int slot_id);

开启 IMS 服务（VoLTE/VoWiFi）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_ims_turn_off
    
    
    int tapi_ims_turn_off(tapi_context context, int slot_id);

关闭 IMS 服务。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 服务状态配置

## tapi_ims_set_service_status
    
    
    int tapi_ims_set_service_status(tapi_context context, int slot_id, int capability);

开启 IMS 服务（VoLTE/VoWiFi）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * capability 能力值。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 注册状态与事件

## tapi_ims_get_registration
    
    
    int tapi_ims_get_registration(tapi_context context, int slot_id, tapi_ims_registration_info* ims_reg);

开启 IMS 服务（VoLTE/VoWiFi）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * ims_reg IMS 注册状态。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_ims_register_registration_change
    
    
    int tapi_ims_register_registration_change(tapi_context context, int slot_id, void* user_obj, tapi_async_function p_handle);

开启 IMS 服务（VoLTE/VoWiFi）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * user_obj 用户对象指针。
  * p_handle 异步回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_ims_is_registered
    
    
    int tapi_ims_is_registered(tapi_context context, int slot_id, bool* out);

开启 IMS 服务（VoLTE/VoWiFi）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# VoLTE 与业务查询

## tapi_ims_is_volte_available
    
    
    int tapi_ims_is_volte_available(tapi_context context, int slot_id, bool* out);

开启 IMS 服务（VoLTE/VoWiFi）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_ims_get_subscriber_uri_number
    
    
    int tapi_ims_get_subscriber_uri_number(tapi_context context, int slot_id, char** out);

开启 IMS 服务（VoLTE/VoWiFi）。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## tapi_ims_get_enabled
    
    
    int tapi_ims_get_enabled(tapi_context context, int slot_id, bool* out);

查询 IMS 是否启用。

**参数** ：

  * context Telephony 上下文句柄。
  * slot_id SIM 卡槽 ID（0 或 1）。
  * out 输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

---

## 多媒体 API 总览

> 路径: 应用框架 > 多媒体（Media） > 多媒体 API 总览
> 来源: [https://doc.openvela.com/document?id=1152&language=cn&version=dev](https://doc.openvela.com/document?id=1152&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/media/index.md>) | 简体中文 ]

# 多媒体 API

openvela 多媒体框架提供统一的音视频播放、录制、音频焦点管理、策略控制和媒体会话能力，同时包含语音唤醒与工具类接口。

# openvela 实现说明

  * **编解码后端** ：底层由 **FFmpeg** 提供音视频编解码、封装/解封装和滤镜能力，源码位于 external/ffmpeg/（LGPL v2.1+）
  * **调用建议** ：
    * 首选使用 openvela framework/media 封装（media_player_* / media_recorder_* 等），已集成音频焦点、策略控制、会话同步
    * 需要自定义 filter graph、直接编解码或探测非常规流媒体时，可直接使用 FFmpeg 原生 API，请参考 [FFmpeg 官方文档](<https://ffmpeg.org/documentation.html>)
  * **FFmpeg 集成配置** （external/ffmpeg/Kconfig）：  

        
        CONFIG_LIB_FFMPEG=y                # 主开关：启用 FFmpeg 库
        CONFIG_LIB_FFMPEG_CONFIGURATION="" # 传递给 FFmpeg ./configure 的参数，用于裁剪组件
        CONFIG_LIB_FFMPEG_TEST=n           # 是否编译 FFmpeg 测试目标
        CONFIG_UTILS_FFMPEG_PRIORITY=100   # ffmpeg 命令行工具的任务优先级
        CONFIG_UTILS_FFMPEG_STACKSIZE=51200 # ffmpeg 命令行工具的任务栈大小

组件裁剪通过 CONFIG_LIB_FFMPEG_CONFIGURATION 字符串传给 FFmpeg 自带的 ./configure 脚本。例如：  

        
        CONFIG_LIB_FFMPEG_CONFIGURATION="--disable-everything --enable-decoder=mp3,aac --enable-demuxer=mov,mp4"

具体可用的 \--enable-* / \--disable-* 参数请参考 FFmpeg 官方 ./configure --help。


# 核心能力

  * **[播放器](</document?id=1153&version=dev&language=cn>)** — 音视频播放（本地/网络流/字节流）
  * **[录制器](</document?id=1154&version=dev&language=cn>)** — 音视频录制与图片捕获
  * **[媒体会话](</document?id=1155&version=dev&language=cn>)** — 控制器-被控端模式的播放控制与状态同步


# 音频策略

  * **[音频焦点](</document?id=1156&version=dev&language=cn>)** — 多应用音频播放优先级协调
  * **[音频策略](</document?id=1157&version=dev&language=cn>)** — 音频路由、设备管理、音量和模式切换


# 语音唤醒

  * **[媒体触发器](</document?id=1158&version=dev&language=cn>)** — 语音唤醒高层接口（声学模型加载 + 识别控制）
  * **[声学模型](</document?id=1159&version=dev&language=cn>)** — 底层声学模型操作（加载/属性/热词检测）


# 工具与调试

  * **[媒体工具](</document?id=1160&version=dev&language=cn>)** — DTMF 信号生成、事件名查询、dump、自定义命令

---

## 多媒体播放器 API

> 路径: 应用框架 > 多媒体（Media） > 多媒体播放器 API
> 来源: [https://doc.openvela.com/document?id=1153&language=cn&version=dev](https://doc.openvela.com/document?id=1153&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/media/media_player.md>) | 简体中文 ]

# 多媒体播放器 API

音视频播放功能，支持本地文件和网络流媒体。

头文件：#include <media_player.h>

# openvela 实现说明

  * **同步/异步双模型** ：提供两套对等接口
    * 同步：media_player_* 系列，调用在当前线程返回
    * 异步：media_uv_player_* 系列，基于 libuv 事件循环，需启用 CONFIG_LIBUV
  * **生命周期** ：open 创建播放器 → prepare 设置源 → start 开始播放 → stop/close 释放
  * **数据源** ：支持两种输入方式
    * 本地/网络 URL：通过 prepare(url) 直接指定
    * 字节流缓冲：通过 write_data 推送，或 get_socket 获取底层套接字
  * **事件回调** ：通过 set_event_callback 注册事件监听器，接收播放状态变化、错误等通知
  * **参数配置** ：通用参数通过 set_property / get_property 读写（如采样率、通道数等）


# 同步接口 - 生命周期

## media_player_open
    
    
    void* media_player_open(const char* stream);

打开指定流类型的播放器。

**参数** ：

  * stream 流类型常量，不同流类型有不同的路由逻辑。


**返回值** ：

成功时返回播放器句柄，失败时返回 NULL。

## media_player_close
    
    
    int media_player_close(void* handle, int pending_stop);

关闭播放器。

**参数** ：

  * handle 播放器句柄。
  * pending_stop 关闭前是否等待停止完成：0 表示立即停止并关闭，1 表示等待当前曲目播放完成再关闭。此参数仅对音频播放器有效；视频播放器设置为 1 时不产生等待效果。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_player_set_event_callback
    
    
    int media_player_set_event_callback(void* handle, void* event_cookie, media_event_callback on_event);

设置事件回调，监听流状态变更。

**参数** ：

  * handle 播放器句柄。
  * event_cookie 回调上下文参数。
  * on_event 事件回调函数，用于接收流状态变化通知。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_player_prepare
    
    
    int media_player_prepare(void* handle, const char* url, const char* options);

准备播放资源。

**参数** ：

  * handle 播放器句柄。
  * url 资源路径，支持两种模式：1. URL 模式：url 为本地文件路径或网络地址，框架会读取并播放；2. BUFFER 模式：url 为 NULL，调用方需通过 media_player_write_data() 或 media_player_get_socket() \+ write() 持续推送数据。
  * options 资源的额外配置参数，通常为描述资源格式的键值对（例如 "format=s16le,sample_rate=44100,channels=2"）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_player_reset
    
    
    int media_player_reset(void* handle);

重置播放器到初始状态。

**参数** ：

  * handle 播放器句柄，由 media_player_open 返回。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 同步接口 - 数据流

## media_player_write_data
    
    
    ssize_t media_player_write_data(void* handle, const void* data, size_t len);

写入数据到播放器进行播放。

**参数** ：

  * handle 播放器句柄。
  * data 数据缓冲区地址。
  * len 要写入的数据长度（字节）。


**返回值** ：

成功时返回实际写入的字节数，失败时返回负的错误码。

## media_player_get_sockaddr
    
    
    int media_player_get_sockaddr(void* handle, struct sockaddr_storage* addr);

获取缓冲模式的 Socket 地址信息。

**参数** ：

  * handle 播放器句柄。
  * addr 用于存储 Socket 地址信息的输出参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_player_get_socket
    
    
    int media_player_get_socket(void* handle);

获取用于写入的 Socket 文件描述符。

**参数** ：

  * handle 播放器句柄。


**返回值** ：

成功时返回 Socket 文件描述符，失败时返回负的错误码。

## media_player_close_socket
    
    
    void media_player_close_socket(void* handle);

关闭 Socket 文件描述符。

**参数** ：

  * handle 播放器句柄。


# 同步接口 - 播放控制

## media_player_start
    
    
    int media_player_start(void* handle);

开始或恢复播放音频源。

**参数** ：

  * handle 播放器句柄。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_player_stop
    
    
    int media_player_stop(void* handle);

停止播放并清除已准备的音频源。

**参数** ：

  * handle 播放器句柄。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_player_pause
    
    
    int media_player_pause(void* handle);

暂停播放。

**参数** ：

  * handle 播放器句柄。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_player_seek
    
    
    int media_player_seek(void* handle, unsigned int position);

跳转到指定的播放位置。

**参数** ：

  * handle 播放器句柄。
  * position 目标位置，单位为毫秒，从起始位置计算。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_player_set_looping
    
    
    int media_player_set_looping(void* handle, int loop);

设置循环播放次数。

**参数** ：

  * handle 播放器句柄。
  * loop 循环次数，-1 表示无限循环。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

# 同步接口 - 状态查询

## media_player_is_playing
    
    
    int media_player_is_playing(void* handle);

查询当前是否正在播放。

**参数** ：

  * handle 播放器句柄。


**返回值** ：

正在播放时返回正值，未播放时返回 0，出错时返回负的错误码。

## media_player_get_position
    
    
    int media_player_get_position(void* handle, unsigned int* position);

获取当前播放位置。

**参数** ：

  * handle 播放器句柄。
  * position 输出参数，当前播放位置，单位为毫秒。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_player_get_duration
    
    
    int media_player_get_duration(void* handle, unsigned int* duration);

获取当前音频源的总时长。

**参数** ：

  * handle 播放器句柄。
  * duration 输出参数，音频源总时长，单位为毫秒。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_player_get_latency
    
    
    int media_player_get_latency(void* handle, unsigned int* latency);

获取当前音频源的播放延迟。

**参数** ：

  * handle 播放器句柄。
  * latency 输出参数，延迟帧数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

# 同步接口 - 音量与属性

## media_player_set_volume
    
    
    int media_player_set_volume(void* handle, float volume);

设置播放音量。

**参数** ：

  * handle 播放器句柄。
  * volume 音量值，取值范围 [0.0, 1.0]。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_player_get_volume
    
    
    int media_player_get_volume(void* handle, float* volume);

获取当前播放音量。

**参数** ：

  * handle 播放器句柄。
  * volume 输出参数，当前音量值，取值范围 [0.0, 1.0]。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_player_set_property
    
    
    int media_player_set_property(void* handle, const char* target, const char* key, const char* value);

设置播放器属性。

**参数** ：

  * handle 播放器句柄。
  * target 目标 filter 名称。
  * key 属性键名。
  * value 属性值。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_player_get_property
    
    
    int media_player_get_property(void* handle, const char* target, const char* key, char* value, int value_len);

获取播放器属性。

**参数** ：

  * handle 播放器句柄。
  * target 目标 filter 名称。
  * key 属性键名。
  * value 输出缓冲区，用于存储属性值。
  * value_len 输出缓冲区长度。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

# 异步接口（基于 libuv）

以下接口仅在启用 CONFIG_LIBUV 时可用，回调在 uv_loop 上执行，避免阻塞调用线程。

## media_uv_player_open
    
    
    void* media_uv_player_open(void* loop, const char* stream, media_uv_callback on_open, void* cookie);

打开异步播放器。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * stream 流类型常量，不同流类型有不同的路由逻辑。
  * on_open 打开完成后触发的回调函数。
  * cookie 回调上下文，供 on_open、on_event、on_connection、on_close 共用。


**返回值** ：

成功时返回播放器句柄，失败时返回 NULL。

## media_uv_player_listen
    
    
    int media_uv_player_listen(void* handle, media_event_callback on_event);

注册事件监听回调，接收播放状态变化通知。

**参数** ：

  * handle 异步播放器句柄。
  * on_event 事件回调函数，在收到通知后调用。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_player_close
    
    
    int media_uv_player_close(void* handle, int pending, media_uv_callback on_close);

关闭异步播放器。

**参数** ：

  * handle 异步播放器句柄。
  * pending 是否以 pending 方式关闭（等待当前播放完成）。
  * on_close 资源释放完成后触发的回调函数。


**返回值** ：

成功时返回 0，无效句柄时返回负的错误码。

## media_uv_player_prepare
    
    
    int media_uv_player_prepare(void* handle, const char* url, const char* options, media_uv_object_callback on_connection, media_uv_callback on_prepare, void* cookie);

准备音频源以供播放。

**参数** ：

  * handle 异步播放器句柄。
  * url 资源路径，支持两种模式：1. URL 模式：url 为本地文件路径或网络地址，框架会读取并播放；2. BUFFER 模式：url 为 NULL，调用方需通过 media_player_write_data() 或 media_player_get_socket() \+ write() 持续推送数据。
  * options 资源的额外配置参数，通常为描述资源格式的键值对（例如 "format=s16le,sample_rate=44100,channels=2"）。
  * on_connection BUFFER 模式下接收 uv_pipe_t 的回调函数。
  * on_prepare 准备完成后的结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_uv_player_reset
    
    
    int media_uv_player_reset(void* handle, media_uv_callback on_reset, void* cookie);

重置播放器到初始状态。

**参数** ：

  * handle 异步播放器句柄。
  * on_reset 重置完成后的结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_player_start_auto
    
    
    int media_uv_player_start_auto(void* handle, const char* scenario, media_uv_callback on_start, void* cookie);

播放或恢复已准备的音频源，并自动请求音频焦点。

**参数** ：

  * handle 异步播放器句柄。
  * scenario 场景常量，不同场景对应不同的焦点优先级。
  * on_start 播放开始后的结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_player_start
    
    
    int media_uv_player_start(void* handle, media_uv_callback on_start, void* cookie);

播放或恢复已准备的资源。

**参数** ：

  * handle 异步播放器句柄。
  * on_start 播放开始后的结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_player_pause
    
    
    int media_uv_player_pause(void* handle, media_uv_callback on_pause, void* cookie);

暂停播放。

**参数** ：

  * handle 异步播放器句柄。
  * on_pause 暂停完成后的结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_player_stop
    
    
    int media_uv_player_stop(void* handle, media_uv_callback on_stop, void* cookie);

停止播放并清除已准备的音频源。

**参数** ：

  * handle 异步播放器句柄。
  * on_stop 停止完成后的结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_player_set_volume
    
    
    int media_uv_player_set_volume(void* handle, float volume, media_uv_callback on_volume, void* cookie);

设置播放音量。

**参数** ：

  * handle 异步播放器句柄。
  * volume 音量值，取值范围 [0.0, 1.0]。
  * on_volume 设置完成后的结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_uv_player_get_volume
    
    
    int media_uv_player_get_volume(void* handle, media_uv_float_callback on_volume, void* cookie);

获取当前播放音量。

**参数** ：

  * handle 异步播放器句柄。
  * on_volume 结果回调函数，回调参数为当前音量值（范围 0.0 - 1.0）。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_player_get_playing
    
    
    int media_uv_player_get_playing(void* handle, media_uv_int_callback on_playing, void* cookie);

获取当前播放状态。

**参数** ：

  * handle 异步播放器句柄。
  * on_playing 结果回调函数，回调参数为播放状态。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_player_get_position
    
    
    int media_uv_player_get_position(void* handle, media_uv_unsigned_callback on_position, void* cookie);

获取当前播放位置。

**参数** ：

  * handle 异步播放器句柄。
  * on_position 结果回调函数，回调参数为当前位置（毫秒）。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_player_get_duration
    
    
    int media_uv_player_get_duration(void* handle, media_uv_unsigned_callback on_duration, void* cookie);

获取当前音频源的总时长。

**参数** ：

  * handle 异步播放器句柄。
  * on_duration 结果回调函数，回调参数为总时长（毫秒）。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_player_get_latency
    
    
    int media_uv_player_get_latency(void* handle, media_uv_unsigned_callback cb, void* cookie);

获取当前音频源的播放延迟。

**参数** ：

  * handle 异步播放器句柄。
  * cb 结果回调函数，回调参数为延迟帧数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_player_set_looping
    
    
    int media_uv_player_set_looping(void* handle, int loop, media_uv_callback on_looping, void* cookie);

设置循环播放次数。

**参数** ：

  * handle 异步播放器句柄。
  * loop 循环次数，-1 表示无限循环。
  * on_looping 设置完成后的结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_player_seek
    
    
    int media_uv_player_seek(void* handle, unsigned int position, media_uv_callback on_seek, void* cookie);

跳转到指定的播放位置。

**参数** ：

  * handle 异步播放器句柄。
  * position 目标位置，单位为毫秒，从起始位置计算。
  * on_seek 跳转完成后的结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_player_set_property
    
    
    int media_uv_player_set_property(void* handle, const char* target, const char* key, const char* value, media_uv_callback on_setprop, void* cookie);

设置播放器属性。

**参数** ：

  * handle 异步播放器句柄。
  * target 目标 filter 名称。
  * key 属性键名。
  * value 属性值。
  * on_setprop 设置完成后的结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_player_get_property
    
    
    int media_uv_player_get_property(void* handle, const char* target, const char* key, media_uv_string_callback on_getprop, void* cookie);

获取播放器属性。

**参数** ：

  * handle 异步播放器句柄。
  * target 目标 filter 名称。
  * key 属性键名。
  * on_getprop 结果回调函数，回调参数为属性值字符串。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_player_query
    
    
    int media_uv_player_query(void* handle, media_uv_object_callback on_query, void* cookie);

查询播放器元数据。

**参数** ：

  * handle 异步播放器句柄。
  * on_query 结果回调函数，回调参数为元数据指针。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_uv_player_close_socket
    
    
    int media_uv_player_close_socket(void* handle);

关闭 Socket 文件描述符。

**参数** ：

  * handle 播放器句柄。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

---

## 多媒体录制器 API

> 路径: 应用框架 > 多媒体（Media） > 多媒体录制器 API
> 来源: [https://doc.openvela.com/document?id=1154&language=cn&version=dev](https://doc.openvela.com/document?id=1154&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/media/media_recorder.md>) | 简体中文 ]

# 多媒体录制器 API

音视频录制功能，支持文件录制和缓冲模式。

头文件：#include <media_recorder.h>

# openvela 实现说明

  * **同步/异步双模型** ：media_recorder_*（同步）和 media_uv_recorder_*（异步，基于 libuv）
  * **输出方式** ：支持两种目标
    * 本地文件：通过 prepare(url) 指定路径
    * 字节流缓冲：通过 read_data 读取，或 get_socket 获取底层套接字
  * **拍照** ：除音视频录制外，提供 take_picture / start_picture / finish_picture 图片捕获接口
  * **事件回调** ：通过 set_event_callback 注册事件监听器


# 同步接口 - 生命周期

## media_recorder_open
    
    
    void* media_recorder_open(const char* params);

打开指定源类型的录制器。

**参数** ：

  * params 源类型常量，通常为 MEDIA_SOURCE_MIC。


**返回值** ：

成功时返回录制器句柄，失败时返回 NULL。

## media_recorder_close
    
    
    int media_recorder_close(void* handle);

关闭录制器。

**参数** ：

  * handle 录制器句柄。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_recorder_set_event_callback
    
    
    int media_recorder_set_event_callback(void* handle, void* cookie, media_event_callback event_cb);

设置录制器事件回调，当状态变化或发生用户关注的事件时触发回调。

**参数** ：

  * handle 录制器句柄。
  * cookie 用户数据，在 event_cb 触发时回传给用户。
  * event_cb 事件回调函数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_recorder_prepare
    
    
    int media_recorder_prepare(void* handle, const char* url, const char* options);

准备录制器。

**参数** ：

  * handle 录制器句柄。
  * url 资源路径，支持两种模式：1. URL 模式：url 为本地文件路径，框架会打开并录制到该路径；2. BUFFER 模式：url 为 NULL，调用方需通过 media_recorder_read_data() 或 media_recorder_get_socket() \+ read() 持续接收数据。
  * options 额外配置参数，字段包括：format（封装格式，如 opus/wav）、sample_rate（采样率）、ch_layout（声道布局）、b（比特率，如 "23900"）、vbr（0=固定码率，1=可变码率）、level（编码复杂度，0-10，默认 10）。示例："format=opusraw:sample_rate=16000:ch_layout=mono:b=32000:vbr=0:level=1"。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_recorder_reset
    
    
    int media_recorder_reset(void* handle);

重置录制器到初始状态。

**参数** ：

  * handle 录制器句柄。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 同步接口 - 数据流

## media_recorder_read_data
    
    
    ssize_t media_recorder_read_data(void* handle, void* data, size_t len);

从录制器读取录制数据。

**参数** ：

  * handle 录制器句柄。
  * data 数据缓冲区地址。
  * len 要读取的数据长度（字节）。


**返回值** ：

成功时返回读取的字节数，失败时返回负的错误码。

## media_recorder_get_sockaddr
    
    
    int media_recorder_get_sockaddr(void* handle, struct sockaddr_storage* addr);

获取缓冲模式的 Socket 地址信息。

**参数** ：

  * handle 录制器句柄。
  * addr 用于存储 Socket 地址信息的输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_recorder_get_socket
    
    
    int media_recorder_get_socket(void* handle);

获取用于读取的 Socket 文件描述符。

**参数** ：

  * handle 录制器句柄。


**返回值** ：

成功时返回 Socket 文件描述符，失败时返回负的错误码。

## media_recorder_close_socket
    
    
    void media_recorder_close_socket(void* handle);

关闭录制器数据接收完成后的 Socket 文件描述符。

**参数** ：

  * handle 录制器句柄。


# 同步接口 - 录制控制

## media_recorder_start
    
    
    int media_recorder_start(void* handle);

开始或恢复录制。

**参数** ：

  * handle 录制器句柄。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_recorder_pause
    
    
    int media_recorder_pause(void* handle);

暂停录制。

**参数** ：

  * handle 录制器句柄。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_recorder_stop
    
    
    int media_recorder_stop(void* handle);

停止录制。

**参数** ：

  * handle 录制器句柄。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 同步接口 - 属性

## media_recorder_set_property
    
    
    int media_recorder_set_property(void* handle, const char* target, const char* key, const char* value);

设置录制器属性。

**参数** ：

  * handle 录制器句柄。
  * target 目标 filter 名称。
  * key 属性键名。
  * value 属性值。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_recorder_get_property
    
    
    int media_recorder_get_property(void* handle, const char* target, const char* key, char* value, int value_len);

获取录制器属性。

**参数** ：

  * handle 录制器句柄。
  * target 目标 filter 名称。
  * key 属性键名。
  * value 输出缓冲区，用于存储属性值。
  * value_len 输出缓冲区长度。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

# 同步接口 - 图片捕获

## media_recorder_take_picture
    
    
    int media_recorder_take_picture(char* params, char* filename, size_t number);

从摄像头拍照。

**参数** ：

  * params 相机打开路径参数。
  * filename 新图片的存储路径。
  * number 拍摄图片的数量。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_recorder_start_picture
    
    
    void* media_recorder_start_picture(char* params, char* filename, size_t number, media_event_callback event_cb, void* cookie);

开始拍照，内部依次执行打开、设置事件回调、准备和启动操作。

**参数** ：

  * params 打开参数。
  * filename 新图片的存储路径。
  * number 拍摄图片的数量。
  * event_cb 处理状态反馈的回调函数。
  * cookie 用户私有数据。


**返回值** ：

成功时返回有效句柄，失败时返回 NULL。

## media_recorder_finish_picture
    
    
    int media_recorder_finish_picture(void* handle);

拍照完成后关闭录制器。

**参数** ：

  * handle 由 media_recorder_start_picture() 返回的录制器句柄。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 异步接口（基于 libuv）

以下接口仅在启用 CONFIG_LIBUV 时可用。

## media_uv_recorder_open
    
    
    void* media_uv_recorder_open(void* loop, const char* source, media_uv_callback on_open, void* cookie);

打开异步录制器。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * source 源类型。
  * on_open 打开完成后触发的回调函数。
  * cookie 回调上下文，供 on_open、on_event、on_close 共用。


**返回值** ：

成功时返回录制器句柄，失败时返回 NULL。

## media_uv_recorder_listen
    
    
    int media_uv_recorder_listen(void* handle, media_event_callback on_event);

注册事件监听回调，接收录制状态变化通知。

**参数** ：

  * handle 异步录制器句柄。
  * on_event 事件回调函数，在收到通知后调用。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_recorder_close
    
    
    int media_uv_recorder_close(void* handle, media_uv_callback on_close);

关闭异步录制器。

**参数** ：

  * handle 异步录制器句柄。
  * on_close 资源释放完成后触发的回调函数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_recorder_prepare
    
    
    int media_uv_recorder_prepare(void* handle, const char* url, const char* options, media_uv_object_callback on_connection, media_uv_callback on_prepare, void* cookie);

准备录制目标文件。

**参数** ：

  * handle 异步录制器句柄。
  * url 目标路径。
  * options 目标配置参数，详见 media_recorder_prepare。
  * on_connection BUFFER 模式下接收可写入数据的 uv_pipe_t 的回调函数。
  * on_prepare 准备完成后的结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_recorder_start_auto
    
    
    int media_uv_recorder_start_auto(void* handle, const char* stream, media_uv_callback on_start, void* cookie);

开始或恢复录制，并自动请求音频焦点。

**参数** ：

  * handle 异步录制器句柄。
  * scenario 场景常量（定义在 media_defs.h 中）。
  * on_start 录制开始后的结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_recorder_start
    
    
    int media_uv_recorder_start(void* handle, media_uv_callback on_start, void* cookie);

开始或恢复录制。

**参数** ：

  * handle 异步录制器句柄。
  * on_start 录制开始后的结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_recorder_pause
    
    
    int media_uv_recorder_pause(void* handle, media_uv_callback on_pause, void* cookie);

暂停录制。

**参数** ：

  * handle 异步录制器句柄。
  * on_pause 暂停完成后的结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_recorder_stop
    
    
    int media_uv_recorder_stop(void* handle, media_uv_callback on_stop, void* cookie);

停止录制并完成目标文件写入。

**参数** ：

  * handle 异步录制器句柄。
  * on_stop 停止完成后的结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_recorder_set_property
    
    
    int media_uv_recorder_set_property(void* handle, const char* target, const char* key, const char* value, media_uv_callback cb, void* cookie);

设置录制器属性。

**参数** ：

  * handle 异步录制器句柄。
  * target 目标 filter 名称。
  * key 属性键名。
  * value 属性值。
  * cb 设置完成后的结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_recorder_get_property
    
    
    int media_uv_recorder_get_property(void* handle, const char* target, const char* key, media_uv_string_callback cb, void* cookie);

获取录制器属性。

**参数** ：

  * handle 异步录制器句柄。
  * target 目标 filter 名称。
  * key 属性键名。
  * cb 结果回调函数，回调参数为属性值字符串。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_recorder_reset
    
    
    int media_uv_recorder_reset(void* handle, media_uv_callback on_reset, void* cookie);

重置录制器，清除当前录制内容以准备新的录制。

**参数** ：

  * handle 异步录制器句柄。
  * on_reset 重置完成后的结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_recorder_take_picture
    
    
    int media_uv_recorder_take_picture(void* loop, char* params, char* filename, size_t number, media_uv_callback on_complete, void* cookie);

从摄像头异步拍照。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * params 相机打开路径参数。
  * filename 新图片的存储路径。
  * number 拍摄图片的数量。
  * on_complete 拍照完成后的结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

---

## 媒体会话 API

> 路径: 应用框架 > 多媒体（Media） > 媒体会话 API
> 来源: [https://doc.openvela.com/document?id=1155&language=cn&version=dev](https://doc.openvela.com/document?id=1155&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/media/media_session.md>) | 简体中文 ]

# 媒体会话 API

媒体播放控制和状态同步，支持控制器-被控端模式。

头文件：#include <media_session.h>

# openvela 实现说明

  * **控制器-被控端模式** ：支持两种角色
    * 控制器（Controller）：通过 media_session_open 打开，向当前活跃媒体发送播放控制命令
    * 被控端（Controllee）：通过 media_session_register 注册，接收控制命令并上报状态
  * **同步/异步双模型** ：media_session_*（同步）和 media_uv_session_*（异步，基于 libuv）
  * **控制命令** ：start / stop / pause / seek / prev_song / next_song / volume 等
  * **状态查询** ：控制器可查询当前播放状态、位置、时长、音量等
  * **状态通知** ：被控端通过 notify / update 向控制器推送播放状态变化


# 控制器接口 - 生命周期

## media_session_open
    
    
    void* media_session_open(const char* params);

打开媒体会话控制器。

**参数** ：

  * params 暂未使用，传 NULL。


**返回值** ：

成功时返回控制器句柄，失败时返回 NULL。

## media_session_close
    
    
    int media_session_close(void* handle);

关闭媒体会话控制器。

**参数** ：

  * handle 控制器句柄。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_session_set_event_callback
    
    
    int media_session_set_event_callback(void* handle, void* cookie, media_event_callback on_event);

设置事件回调，接收被控端消息。

**参数** ：

  * handle 控制器句柄。
  * cookie 回调上下文参数。
  * on_event 事件回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 控制器接口 - 播放控制

## media_session_start
    
    
    int media_session_start(void* handle);

请求开始播放。

**参数** ：

  * handle 控制器句柄。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_session_stop
    
    
    int media_session_stop(void* handle);

请求停止播放。

**参数** ：

  * handle 控制器句柄。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_session_pause
    
    
    int media_session_pause(void* handle);

请求暂停播放。

**参数** ：

  * handle 控制器句柄。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_session_seek
    
    
    int media_session_seek(void* handle, unsigned position);

请求跳转到指定位置。

**参数** ：

  * handle 控制器句柄。
  * position 目标位置，单位为毫秒。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_session_prev_song
    
    
    int media_session_prev_song(void* handle);

请求播放上一首。

**参数** ：

  * handle 控制器句柄。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_session_next_song
    
    
    int media_session_next_song(void* handle);

请求播放下一首。

**参数** ：

  * handle 控制器句柄。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

# 控制器接口 - 音量控制

## media_session_increase_volume
    
    
    int media_session_increase_volume(void* handle);

请求增大音量。

**参数** ：

  * handle 控制器句柄。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_session_decrease_volume
    
    
    int media_session_decrease_volume(void* handle);

请求减小音量。

**参数** ：

  * handle 控制器句柄。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_session_set_volume
    
    
    int media_session_set_volume(void* handle, int volume);

请求设置音量。

**参数** ：

  * handle 控制器句柄。
  * volume 音量档位。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

**注意** ：

  * 此接口尚未实现。


# 控制器接口 - 状态查询

## media_session_query
    
    
    int media_session_query(void* handle, const media_metadata_t** data);

查询当前最活跃被控端的元数据。

**参数** ：

  * handle 控制器句柄。
  * data 用于接收元数据指针的输出参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_session_get_state
    
    
    int media_session_get_state(void* handle, int* state);

获取当前播放状态。

**参数** ：

  * handle 控制器句柄。
  * state 输出参数，当前播放状态。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_session_get_position
    
    
    int media_session_get_position(void* handle, unsigned* position);

获取当前播放位置。

**参数** ：

  * handle 控制器句柄。
  * position 输出参数，当前位置，单位为毫秒。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_session_get_duration
    
    
    int media_session_get_duration(void* handle, unsigned* duration);

获取当前音频源的总时长。

**参数** ：

  * handle 控制器句柄。
  * duration 输出参数，总时长，单位为毫秒。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_session_get_volume
    
    
    int media_session_get_volume(void* handle, int* volume);

获取当前音量。

**参数** ：

  * handle 控制器句柄。
  * volume 输出参数，当前音量档位。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 被控端接口

## media_session_register
    
    
    void* media_session_register(void* cookie, media_event_callback on_event);

注册为媒体会话被控端。

**参数** ：

  * cookie 回调上下文参数。
  * on_event 事件回调函数，用于接收控制命令。


**返回值** ：

成功时返回被控端句柄，失败时返回 NULL。

## media_session_unregister
    
    
    int media_session_unregister(void* handle);

取消注册被控端。

**参数** ：

  * handle 被控端句柄。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_session_notify
    
    
    int media_session_notify(void* handle, int event, int result, const char* extra);

通知控制器控制命令的处理结果。被控端收到 MEDIA_EVENT_* 事件后，完成相应处理，再调用此接口向控制器发送响应。

**参数** ：

  * handle 被控端句柄。
  * event 要响应的事件类型（MEDIA_EVENT_*）。
  * result 操作结果，成功时为 0，失败时为负的 errno。
  * extra 附加消息字符串，不需要时传 NULL。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_session_update
    
    
    int media_session_update(void* handle, const media_metadata_t* data);

向会话更新元数据。

**参数** ：

  * handle 被控端句柄。
  * data 要更新的元数据。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

# 异步接口（基于 libuv）

以下接口仅在启用 CONFIG_LIBUV 时可用，控制器与被控端均有对应异步版本。

## media_uv_session_open
    
    
    void* media_uv_session_open(void* loop, char* params, media_uv_callback on_open, void* cookie);

打开异步会话控制器。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * params 暂未使用，传 NULL。
  * on_open 打开完成后触发的回调函数。
  * cookie 回调上下文，供 on_open、on_event、on_close 共用。


**返回值** ：

成功时返回异步控制器句柄，失败时返回 NULL。

## media_uv_session_close
    
    
    int media_uv_session_close(void* handle, media_uv_callback on_close);

关闭异步控制器。

**参数** ：

  * handle 异步控制器句柄。
  * on_close 关闭完成后触发的回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_uv_session_listen
    
    
    int media_uv_session_listen(void* handle, media_event_callback on_event);

注册事件监听回调，接收被控端状态变化通知。

**参数** ：

  * handle 异步控制器句柄。
  * on_event 事件回调函数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_uv_session_start
    
    
    int media_uv_session_start(void* handle, media_uv_callback on_start, void* cookie);

请求开始播放。

**参数** ：

  * handle 异步控制器句柄。
  * on_start 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_session_stop
    
    
    int media_uv_session_stop(void* handle, media_uv_callback on_stop, void* cookie);

请求停止播放。

**参数** ：

  * handle 异步控制器句柄。
  * on_stop 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_session_pause
    
    
    int media_uv_session_pause(void* handle, media_uv_callback on_pause, void* cookie);

请求暂停播放。

**参数** ：

  * handle 异步控制器句柄。
  * on_pause 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_session_seek
    
    
    int media_uv_session_seek(void* handle, unsigned position, media_uv_callback on_seek, void* cookie);

请求跳转到指定位置。

**参数** ：

  * handle 异步控制器句柄。
  * position 目标位置，单位为毫秒。
  * on_seek 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_session_prev_song
    
    
    int media_uv_session_prev_song(void* handle, media_uv_callback on_pre_song, void* cookie);

请求播放上一首。

**参数** ：

  * handle 异步控制器句柄。
  * on_pre_song 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_session_next_song
    
    
    int media_uv_session_next_song(void* handle, media_uv_callback on_next, void* cookie);

请求播放下一首。

**参数** ：

  * handle 异步控制器句柄。
  * on_next 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_session_increase_volume
    
    
    int media_uv_session_increase_volume(void* handle, media_uv_callback on_increase, void* cookie);

请求增大音量。

**参数** ：

  * handle 异步控制器句柄。
  * on_increase 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_session_decrease_volume
    
    
    int media_uv_session_decrease_volume(void* handle, media_uv_callback on_decrease, void* cookie);

请求减小音量。

**参数** ：

  * handle 异步控制器句柄。
  * on_decrease 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_session_set_volume
    
    
    int media_uv_session_set_volume(void* handle, int volume, media_uv_callback on_set_volume, void* cookie);

请求设置音量。

**参数** ：

  * handle 异步控制器句柄。
  * volume 音量档位。
  * on_set_volume 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

**注意** ：

  * 此接口尚未实现。


## media_uv_session_query
    
    
    int media_uv_session_query(void* handle, media_uv_object_callback on_query, void* cookie);

查询完整状态信息。

**参数** ：

  * handle 异步控制器句柄。
  * on_query 结果回调函数，回调参数为元数据指针。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_uv_session_get_state
    
    
    int media_uv_session_get_state(void* handle, media_uv_int_callback on_state, void* cookie);

获取当前播放状态。

**参数** ：

  * handle 异步控制器句柄。
  * on_state 结果回调函数，回调参数为当前状态。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

**注意** ：

  * 此接口尚未实现，请使用 media_uv_session_query 替代。


## media_uv_session_get_position
    
    
    int media_uv_session_get_position(void* handle, media_uv_unsigned_callback on_position, void* cookie);

获取当前播放位置。

**参数** ：

  * handle 异步控制器句柄。
  * on_position 结果回调函数，回调参数为当前位置（毫秒）。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

**注意** ：

  * 此接口尚未实现，请使用 media_uv_session_query 替代。


## media_uv_session_get_duration
    
    
    int media_uv_session_get_duration(void* handle, media_uv_unsigned_callback on_duration, void* cookie);

获取当前音频源的总时长。

**参数** ：

  * handle 异步控制器句柄。
  * on_duration 结果回调函数，回调参数为总时长（毫秒）。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

**注意** ：

  * 此接口尚未实现，请使用 media_uv_session_query 替代。


## media_uv_session_get_volume
    
    
    int media_uv_session_get_volume(void* handle, media_uv_int_callback on_get_volume, void* cookie);

获取当前音量。

**参数** ：

  * handle 异步控制器句柄。
  * on_get_volume 结果回调函数，回调参数为当前音量档位。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

**注意** ：

  * 此接口尚未实现，请使用 media_uv_session_query 替代。


## media_uv_session_register
    
    
    void* media_uv_session_register(void* loop, const char* params, media_event_callback on_event, void* cookie);

注册为异步会话被控端，接收控制命令。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * params 暂未使用，传 NULL。
  * on_event 接收控制消息的回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回异步被控端句柄，失败时返回 NULL。

## media_uv_session_unregister
    
    
    int media_uv_session_unregister(void* handle, media_uv_callback on_release);

取消注册被控端。

**参数** ：

  * handle 异步被控端句柄。
  * on_release 资源释放完成后的回调函数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_session_notify
    
    
    int media_uv_session_notify(void* handle, int event, int result, const char* extra, media_uv_callback on_notify, void* cookie);

通知控制器控制命令的处理结果。被控端收到 MEDIA_EVENT_* 事件后，完成相应处理，再调用此接口向控制器发送响应。

**参数** ：

  * handle 异步被控端句柄。
  * event 要响应的事件类型。
  * result 操作结果，成功时为 0，失败时为负的 errno。
  * extra 附加消息字符串，不需要时传 NULL。
  * on_notify 通知确认回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_session_update
    
    
    int media_uv_session_update(void* handle, const media_metadata_t* data, media_uv_callback on_update, void* cookie);

向会话更新元数据。

**参数** ：

  * handle 异步被控端句柄。
  * data 要更新的元数据。
  * on_update 更新确认回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

---

## 音频焦点管理 API

> 路径: 应用框架 > 多媒体（Media） > 音频焦点管理 API
> 来源: [https://doc.openvela.com/document?id=1156&language=cn&version=dev](https://doc.openvela.com/document?id=1156&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/media/media_focus.md>) | 简体中文 ]

# 音频焦点管理 API

音频焦点（Audio Focus）用于协调多个音频应用之间的播放优先级。当多个应用同时请求音频焦点时，系统根据场景（scenario）判断谁应当播放、谁应当停止或降低音量，并通过回调通知各应用。

头文件：#include <media_focus.h>

# openvela 实现说明

  * **场景优先级** ：通过 scenario 字符串标识请求类型（如 MEDIA_SCENARIO_MUSIC、MEDIA_SCENARIO_NOTIFICATION 等），框架根据场景优先级返回焦点建议
  * **同步/异步双模型** ：提供两组接口
    * 同步：media_focus_* 系列，适合简单场景
    * 异步（基于 libuv）：media_uv_focus_* 系列，需启用 CONFIG_LIBUV，适合基于 uv_loop 的应用
  * **自动回复** ：request2 接口新增 auto_reply 参数，为 1 时框架自动回复收到的建议，无需应用手动调用 reply
  * **回调失联保护** ：即使 initial_suggestion 返回 MEDIA_FOCUS_STOP（意味着立即被其他焦点抢占），框架仍会返回有效句柄，必须调用 abandon 释放，否则会有资源泄漏
  * **新旧接口** ：media_focus_request / media_uv_focus_request 已标记 deprecated，请使用带 2 后缀的新版本


# 焦点请求（同步）

## media_focus_request
    
    
    void* media_focus_request(int* initial_suggestion, const char* scenario,
                              media_focus_callback on_suggestion, void* cookie)
        __attribute__((deprecated));

请求音频焦点（**已废弃** ，请使用 media_focus_request2）。

**参数** ：

  * initial_suggestion 输出参数，返回初始焦点建议，取值为 MEDIA_FOCUS_* 常量。
  * scenario 场景标识字符串，取值为 MEDIA_SCENARIO_* 常量。
  * on_suggestion 焦点建议变化时的回调函数。
  * cookie 传递给回调的用户数据。


**返回值** ：

成功时返回焦点句柄，失败时返回 NULL。

**注意** ：

  * 若 initial_suggestion 为 MEDIA_FOCUS_STOP，on_suggestion 不会被调用，但仍会返回有效句柄，调用方必须调用 media_focus_abandon 释放，否则会泄漏。


## media_focus_request2
    
    
    void* media_focus_request2(int* initial_suggestion, const char* scenario,
                               media_focus_callback2 on_suggestion,
                               int auto_reply, void* cookie);

请求音频焦点（推荐使用，替代 media_focus_request）。

**参数** ：

  * initial_suggestion 输出参数，返回初始焦点建议，取值为 MEDIA_FOCUS_* 常量。
  * scenario 场景标识字符串，取值为 MEDIA_SCENARIO_* 常量。
  * on_suggestion 焦点建议变化时的回调函数（新版签名包含 req_id）。
  * auto_reply 是否启用自动回复：1 表示框架自动回复焦点建议，0 表示由应用手动调用 media_focus_reply。
  * cookie 传递给回调的用户数据。


**返回值** ：

成功时返回焦点句柄，失败时返回 NULL。

**注意** ：

  * 若 initial_suggestion 为 MEDIA_FOCUS_STOP，on_suggestion 不会被调用，但仍会返回有效句柄，调用方必须调用 media_focus_abandon 释放。


**示例** ：  

    
    
    int initial_suggestion;
    
    context->handle = media_focus_request2(&initial_suggestion,
        MEDIA_SCENARIO_MUSIC, demo_focus_callback, 1, context);
    if (!context->handle) {
        // 处理错误
    }
    
    if (initial_suggestion == MEDIA_FOCUS_STOP)
        media_focus_abandon(context->handle);

## media_focus_abandon
    
    
    int media_focus_abandon(void* handle);

释放音频焦点。

**参数** ：

  * handle 待释放的焦点句柄。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_focus_reply
    
    
    int media_focus_reply(void* handle, int req_id);

回复焦点请求。当 request2 的 auto_reply 为 0 时使用，手动确认焦点建议。

**参数** ：

  * handle 焦点句柄。
  * req_id 请求 ID，由焦点建议回调传入。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

# 焦点请求（异步，基于 libuv）

以下接口仅在启用 CONFIG_LIBUV 时可用。

## media_uv_focus_request
    
    
    void* media_uv_focus_request(void* loop, const char* scenario,
                                 media_focus_callback on_suggestion, void* cookie)
        __attribute__((deprecated));

异步请求音频焦点（**已废弃** ，请使用 media_uv_focus_request2）。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环。
  * scenario 场景标识字符串，取值为 MEDIA_SCENARIO_* 常量。
  * on_suggestion 焦点建议变化时的回调函数。
  * cookie 传递给回调的用户数据。


**返回值** ：

成功时返回异步焦点句柄，失败时返回 NULL。

**注意** ：

  * 当 on_suggestion 回调收到 MEDIA_FOCUS_STOP 时，应用应调用 media_uv_focus_abandon 释放句柄。


## media_uv_focus_request2
    
    
    void* media_uv_focus_request2(void* loop, const char* scenario,
                                  media_focus_callback2 on_suggestion,
                                  int auto_reply, void* cookie);

异步请求音频焦点（推荐使用，替代 media_uv_focus_request）。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环。
  * scenario 场景标识字符串，取值为 MEDIA_SCENARIO_* 常量。
  * on_suggestion 焦点建议变化时的回调函数（新版签名包含 req_id）。
  * auto_reply 是否启用自动回复：1 表示框架自动回复焦点建议。
  * cookie 传递给回调的用户数据。


**返回值** ：

成功时返回异步焦点句柄，失败时返回 NULL。

**示例** ：  

    
    
    void user_on_suggestion(int suggestion, int req_id, void* cookie) {
        UserContext* ctx = cookie;
        switch (suggestion) {
        case MEDIA_FOCUS_STOP:
            media_uv_focus_abandon(ctx->handle, NULL);
            break;
        }
    }
    
    ctx->handle = media_uv_focus_request2(loop, MEDIA_SCENARIO_MUSIC,
        user_on_suggestion, 1, ctx);

## media_uv_focus_abandon
    
    
    int media_uv_focus_abandon(void* handle, media_uv_callback on_abandon);

异步释放音频焦点。

**参数** ：

  * handle 异步焦点句柄。
  * on_abandon 释放完成后的回调，通常用于释放 cookie。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_focus_reply
    
    
    int media_uv_focus_reply(void* handle, int req_id);

异步回复焦点请求。当 request2 的 auto_reply 为 0 时使用。

**参数** ：

  * handle 异步焦点句柄。
  * req_id 请求 ID。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

# 调试接口

## media_focus_dump
    
    
    void media_focus_dump(const char* options);

转储焦点栈信息用于调试。

**参数** ：

  * options 转储选项（目前未使用）。


**注意** ：

  * 该接口将来会并入统一的 media_dump()。

---

## 音频策略 API

> 路径: 应用框架 > 多媒体（Media） > 音频策略 API
> 来源: [https://doc.openvela.com/document?id=1157&language=cn&version=dev](https://doc.openvela.com/document?id=1157&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/media/media_policy.md>) | 简体中文 ]

# 音频策略 API

音频路由、设备管理和模式切换策略。

头文件：#include <media_policy.h>

# openvela 实现说明

  * **Parameter Framework（PFW）后端** ：策略数据通过 openvela PFW 规则引擎管理，运行时可动态切换
  * **同步/异步双模型** ：media_policy_*（同步）和 media_uv_policy_*（异步，基于 libuv）
  * **策略类别** ：涵盖 5 类运行时控制
    * 音频模式（Audio Mode）：通话、媒体播放、免提等场景切换
    * 设备路由（Device Routing）：启用/禁用、可用性、使用状态
    * 音量控制（Stream Volume）：按音频流类型调整音量
    * 静音（Mute）：全局静音与麦克风静音
    * 通用参数（int/string/include/exclude/contain）：扩展配置读写
  * **订阅机制** ：通过 media_policy_subscribe 监听策略变化事件（同步接口独有）
  * **HFP 采样率** ：通过 set_hfp_samplerate 调整蓝牙免提音频采样率


# 同步接口 - 音频模式

## media_policy_set_audio_mode
    
    
    int media_policy_set_audio_mode(const char* mode);

设置音频模式（如通话模式、正常模式）。

**参数** ：

  * mode 模式常量


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_policy_get_audio_mode
    
    
    int media_policy_get_audio_mode(char* mode, int len);

获取当前音频模式。

**参数** ：

  * mode 输出缓冲区。
  * len 缓冲区长度。


# 同步接口 - 设备使用

## media_policy_set_devices_use
    
    
    int media_policy_set_devices_use(const char* devices);

强制使用指定音频设备或协议。

**参数** ：

  * devices 设备常量，支持多设备，用 "|" 分隔。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_policy_set_devices_unuse
    
    
    int media_policy_set_devices_unuse(const char* devices);

取消强制使用音频设备。

**参数** ：

  * devices 设备常量，支持多设备，用 "|" 分隔。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_policy_get_devices_use
    
    
    int media_policy_get_devices_use(char* devices, int len);

获取当前强制使用的音频设备。

**参数** ：

  * devices 设备名称字符串，多个设备用 | 分隔（例如 "sco"、"sco|mic"、"<none>"）。
  * len 缓冲区长度。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_policy_is_devices_use
    
    
    int media_policy_is_devices_use(const char* devices, int* use);

检查指定设备是否处于强制使用状态。

**参数** ：

  * devices 设备常量，支持多设备，用 "|" 分隔。
  * use 设备使用状态：0 表示所有设备均未使用，1 表示至少有一个设备正在使用。


# 同步接口 - HFP 采样率与设备可用性

## media_policy_set_hfp_samplerate
    
    
    int media_policy_set_hfp_samplerate(int rate);

设置 HFP 蓝牙通话采样率。HFP（Hands-Free Profile）基于 BT-SCO 传输，采样率在协商完成前不确定。

**参数** ：

  * rate 采样率，CVSD 编码取 8000，mSBC 编码取 16000。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_policy_set_devices_available
    
    
    int media_policy_set_devices_available(const char* devices);

报告音频设备（或协议）可用。

**参数** ：

  * devices 设备常量，支持多设备，用 "|" 分隔。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_policy_set_devices_unavailable
    
    
    int media_policy_set_devices_unavailable(const char* devices);

报告音频设备（或协议）不可用。

**参数** ：

  * devices 设备常量，支持多设备，用 "|" 分隔。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_policy_get_devices_available
    
    
    int media_policy_get_devices_available(char* devices, int len);

获取当前可用设备。

**参数** ：

  * devices 设备名称字符串，多个设备用 | 分隔（例如 "sco"、"sco|mic"、"<none>"）。
  * len 缓冲区长度。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_policy_is_devices_available
    
    
    int media_policy_is_devices_available(const char* devices, int* available);

检查指定设备是否可用。

**参数** ：

  * devices 待检查的设备，取值为 MEDIA_DEVICE_* 常量，多个设备用 | 分隔。
  * available 设备可用性状态：0 表示所有设备均不可用，1 表示至少有一个设备可用。


# 同步接口 - 静音控制

## media_policy_set_mute_mode
    
    
    int media_policy_set_mute_mode(int mute);

设置静音模式。

**参数** ：

  * mute 新的静音模式：0 表示关闭静音，1 表示开启静音。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_policy_get_mute_mode
    
    
    int media_policy_get_mute_mode(int* mute);

获取当前静音模式。

**参数** ：

  * mute 当前静音模式：0 表示关闭静音，1 表示开启静音。


# 同步接口 - 音量控制

## media_policy_set_stream_volume
    
    
    int media_policy_set_stream_volume(const char* stream, int volume);

设置指定流类型的音量档位。

**参数** ：

  * stream 流类型常量（MEDIA_STREAM_*）。
  * volume 新的音量档位。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_policy_get_stream_volume
    
    
    int media_policy_get_stream_volume(const char* stream, int* volume);

获取指定流类型的音量档位。

**参数** ：

  * stream 流类型常量（MEDIA_STREAM_*）。
  * volume 当前音量档位。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_policy_increase_stream_volume
    
    
    int media_policy_increase_stream_volume(const char* stream);

将指定流类型的音量档位加 1。

**参数** ：

  * stream 流类型常量（MEDIA_STREAM_*）。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_policy_decrease_stream_volume
    
    
    int media_policy_decrease_stream_volume(const char* stream);

将指定流类型的音量档位减 1。

**参数** ：

  * stream 流类型常量（MEDIA_STREAM_*）。


# 同步接口 - 麦克风静音

## media_policy_set_mic_mute
    
    
    int media_policy_set_mic_mute(int mute);

静音麦克风。

**参数** ：

  * mute 麦克风静音模式：1 表示关闭静音，0 表示开启静音。


# 同步接口 - 通用参数读写

## media_policy_set_int
    
    
    int media_policy_set_int(const char* name, int value, int apply);

设置策略条件的数值。

**参数** ：

  * name 准则名称。
  * value 数值。
  * apply 是否将变更应用到策略。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_policy_get_int
    
    
    int media_policy_get_int(const char* name, int* value);

获取策略条件的数值。

**参数** ：

  * name 准则名称。
  * value 数值。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_policy_get_range
    
    
    int media_policy_get_range(const char* name, int* min_value, int* max_value);

获取策略条件的数值范围。

**参数** ：

  * name 准则名称。
  * min_value 数值最小值。
  * min_value 数值最大值。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_policy_set_string
    
    
    int media_policy_set_string(const char* name, const char* value, int apply);

设置策略条件的字符串值。

**参数** ：

  * name 准则名称。
  * value 字符串值。
  * apply 是否将变更应用到策略。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_policy_get_string
    
    
    int media_policy_get_string(const char* name, char* value, int len);

获取策略条件的字符串值。

**参数** ：

  * name 准则名称。
  * value 输出缓冲区。
  * len 缓冲区长度。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_policy_include
    
    
    int media_policy_include(const char* name, const char* values, int apply);

向包含型条件添加字面值。

**参数** ：

  * name 准则名称。
  * values 字符串值。
  * apply 是否将变更应用到策略。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_policy_exclude
    
    
    int media_policy_exclude(const char* name, const char* values, int apply);

从包含型条件移除字面值。

**参数** ：

  * name 准则名称。
  * values 字符串值。
  * apply 是否将变更应用到策略。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_policy_contain
    
    
    int media_policy_contain(const char* name, const char* values, int* result);

检查字面值是否包含在包含型条件中。

**参数** ：

  * name 准则名称。
  * values 字符串值数组。
  * result 值是否被包含。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_policy_increase
    
    
    int media_policy_increase(const char* name, int apply);

将数值型条件值加 1。

**参数** ：

  * name 准则名称。
  * apply 是否将变更应用到策略。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_policy_decrease
    
    
    int media_policy_decrease(const char* name, int apply);

将数值型条件值减 1。

**参数** ：

  * name 准则名称。
  * apply 是否将变更应用到策略。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 同步接口 - 订阅事件

## media_policy_subscribe
    
    
    void* media_policy_subscribe(const char* name, media_policy_change_callback on_change, void* cookie);

订阅策略条件变化事件。

**参数** ：

  * name 准则名称。
  * on_change 准则值变化时触发的回调。


**返回值** ：

成功时返回有效句柄，失败时返回 NULL。

## media_policy_unsubscribe
    
    
    int media_policy_unsubscribe(void* handle);

取消订阅策略条件变化事件。

**参数** ：

  * name 准则名称。
  * handle 用于取消订阅的句柄。


# 异步接口（基于 libuv）

以下接口仅在启用 CONFIG_LIBUV 时可用。

## media_uv_policy_set_int
    
    
    int media_uv_policy_set_int(void* loop, const char* name, int value, int apply, media_uv_callback cb, void* cookie);

设置策略条件的数值。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * name 准则名称。
  * value 要设置的数值。
  * apply 是否将新值应用到策略配置。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_uv_policy_get_int
    
    
    int media_uv_policy_get_int(void* loop, const char* name, media_uv_int_callback cb, void* cookie);

获取策略条件的数值。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * name 准则名称。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_uv_policy_increase
    
    
    int media_uv_policy_increase(void* loop, const char* name, int apply, media_uv_callback cb, void* cookie);

将策略条件的数值加 1。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * name 准则名称。
  * apply 是否将新值应用到策略配置。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_uv_policy_set_string
    
    
    int media_uv_policy_set_string(void* loop, const char* name, const char* value, int apply, media_uv_callback cb, void* cookie);

设置策略条件的字符串值。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * name 准则名称。
  * value 要设置的字符串值。
  * apply 是否将新值应用到策略配置。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_uv_policy_get_string
    
    
    int media_uv_policy_get_string(void* loop, const char* name, media_uv_string_callback cb, void* cookie);

获取策略条件的字符串值。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * name 准则名称。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_uv_policy_decrease
    
    
    int media_uv_policy_decrease(void* loop, const char* name, int apply, media_uv_callback cb, void* cookie);

将策略条件的数值减 1。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * name 准则名称。
  * apply 是否将新值应用到策略配置。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_uv_policy_include
    
    
    int media_uv_policy_include(void* loop, const char* name, const char* value, int apply, media_uv_callback cb, void* cookie);

向包含型条件添加字面值。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * name 准则名称。
  * value 字符串值数组。
  * apply 是否将新值应用到策略配置。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_uv_policy_exclude
    
    
    int media_uv_policy_exclude(void* loop, const char* name, const char* value, int apply, media_uv_callback cb, void* cookie);

从包含型条件移除字面值。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * name 准则名称。
  * value 字符串值数组。
  * apply 是否将新值应用到策略配置。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_uv_policy_contain
    
    
    int media_uv_policy_contain(void* loop, const char* name, const char* value, media_uv_int_callback cb, void* cookie);

检查字面值是否包含在包含型条件中。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * name 准则名称。
  * value 字符串值数组。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_uv_policy_set_stream_volume
    
    
    int media_uv_policy_set_stream_volume(void* loop, const char* stream, int volume, media_uv_callback cb, void* cookie);

设置指定流类型的音量。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * stream 流类型，取值为流类型常量。
  * volume 要设置的音量档位。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_policy_get_stream_volume
    
    
    int media_uv_policy_get_stream_volume(void* loop, const char* stream, media_uv_int_callback cb, void* cookie);

获取指定流类型的音量。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * stream 流类型，取值为流类型常量。
  * volume 要设置的音量档位。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_policy_increase_stream_volume
    
    
    int media_uv_policy_increase_stream_volume(void* loop, const char* stream, media_uv_callback cb, void* cookie);

将指定流类型的音量加 1。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * stream 流类型，取值为流类型常量。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_policy_decrease_stream_volume
    
    
    int media_uv_policy_decrease_stream_volume(void* loop, const char* stream, media_uv_callback cb, void* cookie);

将指定流类型的音量减 1。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * stream 流类型，取值为流类型常量。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_policy_set_audio_mode
    
    
    int media_uv_policy_set_audio_mode(void* loop, const char* mode, media_uv_callback cb, void* cookie);

设置音频模式（如通话模式、正常模式）。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * mode 新的音频模式。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_policy_get_audio_mode
    
    
    int media_uv_policy_get_audio_mode(void* loop, media_uv_string_callback cb, void* cookie);

获取当前音频模式。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_policy_set_devices_use
    
    
    int media_uv_policy_set_devices_use(void* loop, const char* devices, bool use, media_uv_callback cb, void* cookie);

强制使用或取消使用指定设备（或协议）。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * devices 目标设备。
  * use 将设备设置为使用或未使用状态。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_policy_get_devices_use
    
    
    int media_uv_policy_get_devices_use(void* loop, media_uv_string_callback cb, void* cookie);

获取当前强制使用的设备。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_policy_is_devices_use
    
    
    int media_uv_policy_is_devices_use(void* loop, const char* devices, media_uv_int_callback cb, void* cookie);

检查指定设备是否正在被使用。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * devices 待检查的设备。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_policy_set_hfp_samplerate
    
    
    int media_uv_policy_set_hfp_samplerate(void* loop, int rate, media_uv_callback cb, void* cookie);

设置 HFP（Hands-Free Profile）采样率。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * rate 采样率，CVSD 编码取 8000，mSBC 编码取 16000。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

**注意** ：

  * 此接口已废弃，rate 参数将来会改为 int 类型。


## media_uv_policy_set_devices_available
    
    
    int media_uv_policy_set_devices_available(void* loop, const char* devices, bool available, media_uv_callback cb, void* cookie);

设置设备可用或不可用状态。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * devices 目标设备。
  * available 将设备设置为可用或不可用状态。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## media_uv_policy_get_devices_available
    
    
    int media_uv_policy_get_devices_available(void* loop, media_uv_string_callback cb, void* cookie);

获取当前可用设备。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_policy_is_devices_available
    
    
    int media_uv_policy_is_devices_available(void* loop, const char* devices, media_uv_int_callback cb, void* cookie);

检查指定设备是否可用。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * devices 待检查的设备。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_policy_set_mute_mode
    
    
    int media_uv_policy_set_mute_mode(void* loop, int mute, media_uv_callback cb, void* cookie);

设置静音模式。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * mute 新的静音模式。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_policy_get_mute_mode
    
    
    int media_uv_policy_get_mute_mode(void* loop, media_uv_int_callback cb, void* cookie);

获取当前静音模式。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_uv_policy_set_mic_mute
    
    
    int media_uv_policy_set_mic_mute(void* loop, int mute, media_uv_callback cb, void* cookie);

静音内置麦克风或蓝牙麦克风。

**参数** ：

  * loop 当前线程的 uv_loop_t* 事件循环句柄。
  * mute 静音模式。
  * cb 结果回调函数。
  * cookie 回调上下文参数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

---

## 媒体触发器 API

> 路径: 应用框架 > 多媒体（Media） > 媒体触发器 API
> 来源: [https://doc.openvela.com/document?id=1158&language=cn&version=dev](https://doc.openvela.com/document?id=1158&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/media/media_trigger.md>) | 简体中文 ]

# 媒体触发器 API

媒体触发器（Media Trigger）用于语音唤醒（Voice Trigger）场景，通过加载声学模型实现关键词检测、启动识别等功能。

头文件：#include <media_trigger.h>

# openvela 实现说明

  * **典型场景** ：智能音箱、智能手表的"嘿小爱"等语音唤醒
  * **工作流程** ：
    1. open 打开触发器句柄
    2. set_event_callback 注册事件回调
    3. load_sound_model 加载声学模型
    4. start_recognition 开始识别
    5. 监听回调，检测到关键词后处理
    6. stop_recognition → unload_sound_model → close 清理
  * **参数配置** ：通过 open 传入的 params 选择麦克风配置（如 "default" / "Dual Mic"）
  * **底层实现** ：对接 DSP 侧的声学模型处理器


# 触发器生命周期

## media_trigger_open
    
    
    void* media_trigger_open(const char* params);

打开媒体触发器句柄。

**参数** ：

  * params 触发器参数字符串，例如 "default" 或 "Dual Mic"，用于选择麦克风配置。


**返回值** ：

成功时返回触发器句柄，失败时返回 NULL。

**示例** ：  

    
    
    // 1. 创建实例
    void* handle = media_trigger_open("default");
    
    // 2. 设置事件回调
    ret = media_trigger_set_event_callback(handle, cookie, callback);
    
    // 3. 加载声学模型
    ret = media_trigger_load_sound_model(handle, model, model_size);
    
    // 4. 开始识别
    ret = media_trigger_start_recognition(handle);
    
    // 5. 停止识别
    ret = media_trigger_stop_recognition(handle);
    
    // 6. 卸载模型
    ret = media_trigger_unload_sound_model(handle);
    
    // 7. 关闭句柄
    ret = media_trigger_close(handle);

## media_trigger_close
    
    
    int media_trigger_close(void* handle);

关闭触发器句柄，释放相关资源。

**参数** ：

  * handle 待关闭的触发器句柄。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

# 事件与回调

## media_trigger_set_event_callback
    
    
    int media_trigger_set_event_callback(void* handle, void* event_cookie,
                                         media_event_callback on_event);

为触发器设置事件回调，用于接收识别状态变化等事件。

**参数** ：

  * handle 触发器句柄。
  * event_cookie 传递给回调的用户数据。
  * on_event 事件回调函数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

# 声学模型管理

## media_trigger_load_sound_model
    
    
    int media_trigger_load_sound_model(void* handle, void* model, size_t model_size);

为触发器加载声学模型数据。

**参数** ：

  * handle 触发器句柄。
  * model 声学模型数据指针。
  * model_size 模型数据字节数。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_trigger_unload_sound_model
    
    
    int media_trigger_unload_sound_model(void* handle);

卸载已加载的声学模型。

**参数** ：

  * handle 触发器句柄。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

# 识别控制

## media_trigger_start_recognition
    
    
    int media_trigger_start_recognition(void* handle);

开始语音识别。触发器会持续检测输入音频，匹配已加载模型中的关键词。

**参数** ：

  * handle 触发器句柄。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

## media_trigger_stop_recognition
    
    
    int media_trigger_stop_recognition(void* handle);

停止语音识别。

**参数** ：

  * handle 触发器句柄。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

# DSP 属性查询

## media_trigger_get_property
    
    
    int media_trigger_get_property(char* properties, int len);

查询触发器底层 DSP 的属性信息。

**参数** ：

  * properties 输出缓冲区，用于接收属性字符串。
  * len 缓冲区长度。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

---

## 声学模型 API

> 路径: 应用框架 > 多媒体（Media） > 声学模型 API
> 来源: [https://doc.openvela.com/document?id=1159&language=cn&version=dev](https://doc.openvela.com/document?id=1159&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/media/media_trigger_model.md>) | 简体中文 ]

# 声学模型 API

声学模型（Sound Model）接口用于处理媒体触发器所需的低层声学模型数据，提供模型加载、卸载、属性/选项查询和热词检测能力。

头文件：#include <media_trigger_model.h>

# openvela 实现说明

  * **与 Media Trigger 的关系** ：media_trigger_* 是高层语音唤醒接口（含 DSP 通路），media_trigger_model_* 是底层模型操作接口（不涉及音频采集）
  * **典型用途** ：自定义识别流程、在特定 PCM 缓冲上跑一次性的关键词检测
  * **模型属性/选项** ：通过 get_properties 查询厂商属性，get_options 读取推荐的音频采样参数
  * **一次性检测** ：detect_hotword 在给定 PCM 缓冲上做一次同步检测


# 模型生命周期

## media_trigger_model_load
    
    
    void* media_trigger_model_load(const void* model, size_t size);

加载声学模型数据，返回模型上下文。

**参数** ：

  * model 模型数据起始指针。
  * size 模型数据字节数。


**返回值** ：

成功时返回模型上下文指针，失败时返回 NULL。

## media_trigger_model_unload
    
    
    void media_trigger_model_unload(void* context);

卸载已加载的模型上下文。

**参数** ：

  * context 待卸载的模型上下文。


# 模型属性查询

## media_trigger_model_get_properties
    
    
    void media_trigger_model_get_properties(void* properties, size_t* size);

查询厂商提供的模型属性信息。

**参数** ：

  * properties 输出缓冲区，用于存放属性数据。
  * size 输入输出参数：调用时表示缓冲区大小，返回时被更新为实际写入的字节数。


## media_trigger_model_get_options
    
    
    void media_trigger_model_get_options(void* context, char* options, size_t size);

查询模型推荐的音频采集选项字符串，例如 "format=s16le:sample_rate=16000:ch_layout=mono"。

**参数** ：

  * context 模型上下文（由 media_trigger_model_load 返回）。
  * options 输出缓冲区，用于接收选项字符串。
  * size 输出缓冲区字节数。


## media_trigger_model_get_buffer_size
    
    
    void media_trigger_model_get_buffer_size(void* context, size_t* size);

查询模型推荐的录音缓冲区大小。

**参数** ：

  * context 模型上下文。
  * size 输出参数，返回推荐的缓冲区字节数。


# 热词检测

## media_trigger_model_detect_hotword
    
    
    bool media_trigger_model_detect_hotword(void* context, const char* buffer, size_t size);

在给定 PCM 缓冲上运行一次模型检测，判断是否匹配到热词。

**参数** ：

  * context 模型上下文。
  * buffer 待检测的 PCM 音频缓冲区。
  * size 缓冲区字节数。


**返回值** ：

检测到热词时返回 true，未检测到返回 false。

---

## 媒体工具 API

> 路径: 应用框架 > 多媒体（Media） > 媒体工具 API
> 来源: [https://doc.openvela.com/document?id=1160&language=cn&version=dev](https://doc.openvela.com/document?id=1160&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/media/media_utils.md>) | 简体中文 ]

# 媒体工具 API

媒体框架通用工具接口，包括 DTMF 双音多频信号生成、事件名查询、图/策略 dump 与通用命令发送。

头文件：#include <media_utils.h>

# openvela 实现说明

  * **DTMF** ：生成 0-9 / *#ABCD 对应的 DTMF 双音多频信号，音频格式固定为 format=s16le:sample_rate=8000:ch_layout=mono（由 MEDIA_TONE_DTMF_FORMAT 宏定义）
  * **调试接口** ：media_graph_dump、media_player_dump、media_recorder_dump 和 media_policy_dump 用于打印内部状态，便于问题定位
  * **通用命令** ：media_process_command 向 media server 发送自定义命令，用于扩展能力（如触发 graph 内某个 filter 的操作）
  * **事件名查询** ：media_event_get_name 把 MEDIA_EVENT_* 数值转成可读字符串，便于日志输出


# DTMF 信号生成

## media_dtmf_get_buffer_size
    
    
    int media_dtmf_get_buffer_size(const char* numbers);

查询 DTMF 信号所需的缓冲区大小。

**参数** ：

  * numbers 拨号按键字符序列，字符范围为 0-9 与 *#ABCD。


**返回值** ：

成功时返回缓冲区字节数，失败时返回负的 errno。

## media_dtmf_generate
    
    
    int media_dtmf_generate(const char* numbers, void* buffer);

生成一个或连续多个 DTMF 信号并写入调用方提供的缓冲区。

**参数** ：

  * numbers 拨号按键字符序列，字符范围为 0-9 与 *#ABCD。
  * buffer 输出缓冲区，大小需通过 media_dtmf_get_buffer_size 提前查询。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

**注意** ：

  * 播放 DTMF 音时，音频参数必须固定为 MEDIA_TONE_DTMF_FORMAT（s16le / 8000Hz / mono）。


# 事件名查询

## media_event_get_name
    
    
    const char* media_event_get_name(int event);

将 MEDIA_EVENT_* 枚举值转换为可读的字符串。

**参数** ：

  * event 事件值，取值为 MEDIA_EVENT_* 常量。


**返回值** ：

始终返回可打印的字符串，对未知事件返回占位字符串（不会返回 NULL）。

**示例** ：  

    
    
    printf("event: %s\n", media_event_get_name(MEDIA_EVENT_STARTED));
    // 输出: event: STARTED

# Dump 调试

## media_graph_dump
    
    
    void media_graph_dump(const char* options);

打印 media graph 内部状态，用于调试。

**参数** ：

  * options dump 选项字符串。


## media_policy_dump
    
    
    void media_policy_dump(const char* options);

打印 media policy 当前状态，用于调试。

**参数** ：

  * options dump 选项字符串。


## media_player_dump
    
    
    void media_player_dump(const char* options);

打印 media player 内部状态，用于调试。

**参数** ：

  * options dump 选项字符串。


## media_recorder_dump
    
    
    void media_recorder_dump(const char* options);

打印 media recorder 内部状态，用于调试。

**参数** ：

  * options dump 选项字符串。


# 通用命令

## media_process_command
    
    
    int media_process_command(const char* target, const char* cmd,
                              const char* arg, char* res, int res_len);

向 media server 内的指定 graph filter 发送自定义命令。

**参数** ：

  * target 目标 graph filter 实例名。
  * cmd 命令类型。
  * arg 命令参数。
  * res 响应消息输出缓冲区。
  * res_len 响应缓冲区长度。


**返回值** ：

成功时返回 0，失败时返回负的 errno。

---

## Services API 总览

> 路径: 应用框架 > 系统服务（Services） > Services API 总览
> 来源: [https://doc.openvela.com/document?id=1162&language=cn&version=dev](https://doc.openvela.com/document?id=1162&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/services/index.md>) | 简体中文 ]

# Services API

Services 模块提供 openvela 系统的核心应用管理服务，包括 Activity Manager Service（AMS）和 Package Manager Service（PMS），负责应用生命周期管理、任务调度及包管理等功能。

  * **[AMS](</document?id=1163&version=dev&language=cn>)** — Activity Manager Service，应用/Activity 生命周期管理
  * **[PMS](</document?id=1164&version=dev&language=cn>)** — Package Manager Service，应用包管理

---

## AMS API

> 路径: 应用框架 > 系统服务（Services） > AMS API
> 来源: [https://doc.openvela.com/document?id=1163&language=cn&version=dev](https://doc.openvela.com/document?id=1163&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/services/ams.md>) | 简体中文 ]

# AMS API

Activity Manager Service（AMS）是 openvela XMS 系统中的活动管理服务模块，负责管理应用的生命周期，以及任务和活动的调度。

# 功能特性

  * **Activity 生命周期管理** ：AMS 负责管理应用内 Activity 的生命周期，包括创建、启动、暂停、恢复和销毁。
  * **任务管理** ：AMS 管理应用任务和任务栈，包括任务切换和调度，确保流畅的用户体验。
  * **进程管理** ：AMS 负责启动、停止和监控应用进程，确保系统资源的有效利用。
  * **Intent 处理** ：AMS 处理应用间的 Intent 通信，允许不同应用启动 Activity 和 Service。
  * **权限管理** ：AMS 参与权限检查，确保应用在启动 Activity 时满足系统安全要求。
  * **应用状态跟踪** ：AMS 跟踪应用状态（如前台、后台、已停止），并据此分配资源。
  * **多窗口支持** ：AMS 提供多窗口模式下的 Activity 管理，允许多个应用同时显示。
  * **后台任务限制** ：AMS 对后台任务和服务施加限制，以优化系统性能和电池使用。
  * **Service 和 Broadcast 管理** ：AMS 还负责管理 Service 和 BroadcastReceiver 的生命周期，确保系统的响应性和稳定性。


# 示例

以下是使用 openvela AMS 模块的示例代码，通常通过 ActivityManager 类来管理 Activity 和控制任务。

**启动新 Activity**  

    
    
    Intent intent;
    makeIntent(intent);
    intent.setFlag(intent.mFlag | Intent::FLAG_ACTIVITY_NEW_TASK);
    android::sp<android::IBinder> token = new android::BBinder();
    ActivityManager am;
    am.startActivity(token, intent, -1);

**停止 Activity**  

    
    
    Intent intent;
    makeIntent(intent);
    ActivityManager am;
    am.stopActivity(intent, intent.mFlag);

# 核心类

## ActivityManager

头文件：#include <app/ActivityManager.h>

客户端侧访问 AMS 能力的门面类。提供的主要方法：

  * startActivity() / stopActivity() / finishActivity() — Activity 启停
  * startService() / stopService() / stopServiceByToken() / bindService() / unbindService() — Service 操作
  * publishService() / getService() — 服务发布与获取
  * sendBroadcast() / registerReceiver() / unregisterReceiver() — 广播与接收器
  * attachApplication() / stopApplication() — Application 绑定与终止
  * moveActivityTaskToBackground() — Activity 任务切换到后台
  * reportActivityStatus() / reportServiceStatus() — 状态上报（由应用向 AMS 回报生命周期状态）
  * postIntent() — 向指定组件投递 Intent


## ActivityManagerService

头文件：#include <am/ActivityManagerService.h>

AMS 的服务端实现类，注册为系统服务，接收各应用通过 Binder 发来的调用并执行调度。开发者一般不直接使用该类。

## Activity

头文件：#include <app/Activity.h>

应用开发的 UI 单元基类。应用通过继承该类并重写 onCreate / onStart / onResume / onPause / onStop / onDestroy / onRestart 等生命周期回调来实现一个界面。还提供 finish / setResult / getWindow / moveToBackground / onBackPressed / onActivityResult / onNewIntent 等操作与扩展点。

## Application

头文件：#include <app/Application.h>

应用进程的全局单例基类。应用通常继承 Application 来放置进程级资源。主要方法包括：

  * 生命周期：onCreate / onDestroy / onForeground / onBackground / onReceiveIntent
  * 组件管理：createActivity / createService / addActivity / addService / findActivity / findService / deleteActivity / deleteService
  * 元信息：getPackageName / getUid / isSystemUI / getMainLoop / getWindowManager


## ApplicationThread

头文件：#include <app/ApplicationThread.h>

Application 侧的调度线程抽象，承接来自 AMS 的调度请求并在应用进程内派发执行。属于框架内部协作类，应用开发者一般不直接调用。

## AppMain

头文件：#include <app/AppMain.h>

应用进程入口辅助类。定义应用进程从启动到接入 AMS 的基础流程，封装主事件循环与初始化步骤。

## Context

头文件：#include <app/Context.h>

最核心的上下文基类，提供系统能力访问入口。典型方法包括：

  * getPackageName() / getApplication() / getComponentName() — 应用与组件信息
  * startActivity() / startActivityForResult() / stopActivity() — Activity 启停
  * startService() / stopService() / bindService() / unbindService() — Service 操作
  * sendBroadcast() / registerReceiver() / unregisterReceiver() — 广播与接收器
  * getActivityManager() / getWindowManager() — 系统服务访问
  * getMainLoop() / getCurrentLoop() — 事件循环获取


## ContextImpl

头文件：#include <app/ContextImpl.h>

Context 基类的默认实现，由框架在 Application / Activity / Service 创建时装配。应用开发者通常不直接构造 ContextImpl，而是通过 Activity::getContext() 等方式获取实例。

## Intent

头文件：#include <app/Intent.h>

承载组件间通信意图的数据结构。包含 action、data、target、bundle、flag 等字段，以及 FLAG_ACTIVITY_* 等启动标志。提供 setAction / setData / setTarget / setBundle / setFlag / readFromParcel / writeToParcel 等读写方法。

## Service

头文件：#include <app/Service.h>

无界面的长生命周期组件基类。开发者通过继承 Service 并重写 onCreate / onStartCommand / onBind / onUnbind / onDestroy / onReceiveIntent 来实现后台服务。

## ServiceConnection

头文件：#include <app/ServiceConnection.h>

bindService 的连接回调接口。包含 onServiceConnected / onServiceDisconnected 两个回调方法，用于在绑定成功或断开时通知客户端。

## BroadcastReceiver

头文件：#include <app/BroadcastReceiver.h>

广播接收器基类。应用通过继承该类并重写 onReceive(Intent) 来处理匹配到的系统或应用广播。

## MessageService

头文件：#include <app/MessageService.h>

面向消息通信的服务辅助类，封装基于 Intent 的请求—响应模式，便于应用构建基于消息分发的后台服务。主要方法：sendMessage / receiveMessage / receiveMessageAndReply / reply / onBind / onBindExt / onReply。

## Dialog

头文件：#include <app/Dialog.h>

对话框组件基类。提供 show / hide / setLayout / setRect / getLayout / getRoot / createDialog 等操作，应用可继承实现自定义对话框。

## UvLoop

头文件：#include <app/UvLoop.h>

基于 libuv 的事件循环封装，供应用主线程以及其他框架组件复用。提供定时器、IO 事件、工作队列等能力。

## Logger

头文件：#include <app/Logger.h>

AMS/应用侧通用日志宏定义，封装分级日志输出（APP_LOGI / APP_LOGW / APP_LOGE 等）。

## ActivityTrace

头文件：#include <ActivityTrace.h>

Activity 生命周期的 trace 打点宏集合，配合 openvela trace 分析工具可视化应用启动与切换路径。

---

## PMS API

> 路径: 应用框架 > 系统服务（Services） > PMS API
> 来源: [https://doc.openvela.com/document?id=1164&language=cn&version=dev](https://doc.openvela.com/document?id=1164&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/services/pms.md>) | 简体中文 ]

# PMS API

Package Manager Service（PMS）是 openvela XMS 系统中的包管理模块。

# 功能特性

  * 提供包安装功能
  * 提供包信息查询能力
  * 提供包卸载能力


# 示例

**通过命令行进行包管理**

安装包：  

    
    
    pm install [packagename]

查询已安装的包：  

    
    
    pm list

**通过源码使用包管理工具**

安装包：  

    
    
    #include <pm/PackageManager.h>
    
    PackageManager pm;
    InstallParam parms;
    pm.installPackage(parms);

获取所有包信息：  

    
    
    #include <pm/PackageManager.h>
    
    PackageManager pm;
    std::vector<PackageInfo> pgInfos;
    pm.getAllPackageInfo(&pgInfos);

卸载包：  

    
    
    #include <pm/PackageManager.h>
    
    PackageManager pm;
    UninstallParam parms;
    pm.uninstallPackage(parms);

# 核心类

## PackageManager

头文件：#include <pm/PackageManager.h>

客户端侧访问 PMS 能力的门面类。提供的主要操作：

  * installPackage(InstallParam) — 安装应用包
  * uninstallPackage(UninstallParam) — 卸载应用包
  * getAllPackageInfo(std::vector<PackageInfo>*) — 查询所有已安装包信息
  * getPackageInfo(packageName, PackageInfo*) — 查询指定包信息
  * getAllPackageName(std::vector<std::string>*) — 查询所有已安装包名
  * getPackageSizeInfo(packageName, ...) — 查询包占用空间
  * clearAppCache(packageName) — 清理应用缓存
  * isFirstBoot() — 查询是否首次启动


应用通常构造 PackageManager 实例后直接调用上述方法，内部通过 Binder 与 PackageManagerService 通信。

## PackageManagerService

头文件：#include <pm/PackageManagerService.h>

PMS 的服务端实现类，注册为系统服务。负责维护已安装包的元数据、执行实际的安装/卸载动作、处理权限与签名校验。开发者一般不直接使用该类。

## PackageInfo

头文件：#include <pm/PackageInfo.h>

描述单个安装包元数据的结构。主要字段包括：

  * packageName / name — 包名与应用名
  * version / priority / appType — 版本、优先级与应用类型
  * installedPath / installTime / size — 安装路径、安装时间与占用大小
  * execfile / entry / manifest — 可执行文件、入口与清单
  * activitiesInfo / servicesInfo — 内部 Activity 与 Service 列表
  * shasum — 签名摘要
  * userId / isSystemUI — 用户 ID 与是否系统 UI
  * windowEnterAnim / windowExitAnim — 窗口进入/退出动画配置


PackageManager 的查询接口返回该类型的结果。

## PackageTrace

头文件：#include <PackageTrace.h>

PMS 的 trace 打点宏集合，用于跟踪包管理操作路径，配合 openvela trace 工具分析性能。

---

## Feature 框架 API 总览

> 路径: 应用框架 > Feature 框架 > Feature 框架 API 总览
> 来源: [https://doc.openvela.com/document?id=1166&language=cn&version=dev](https://doc.openvela.com/document?id=1166&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/feature/index.md>) | 简体中文 ]

# Feature 框架 API

Feature 框架是 openvela 快应用（Quick App）的 Native 扩展开发框架，提供 JS 与 C/C++ 之间的互调能力。开发者可以通过 Feature 框架为快应用扩展新的系统能力，框架负责参数转换、生命周期管理、异步编程模型以及接口自动生成（JIDL）等核心功能。

# 框架概览

  * **[Feature 框架概述](</document?id=1167&version=dev&language=cn>)** — 架构、概念模型（Module / Prototype / Instance）、JIDL 接口描述语言


# 核心数据类型

  * **[类型定义](</document?id=1168&version=dev&language=cn>)** — 基本类型别名、句柄类型、枚举、结构体


# 运行时接口

  * **[上下文与数据转换](</document?id=1169&version=dev&language=cn>)** — ft_value_t 创建/销毁、类型转换、数组/对象操作
  * **[Feature 导出接口](</document?id=1170&version=dev&language=cn>)** — Feature 开发者使用的全量运行时 API（内存、回调、Promise、事件、Worker、JSON）
  * **[框架管理接口](</document?id=1171&version=dev&language=cn>)** — 快应用框架实现者用于创建和配置 Feature 管理器


# 前端互操作

  * **[QuickJS 互操作](</document?id=1172&version=dev&language=cn>)** — ft_value_t 与 JSValue 互转（仅 QuickJS 前端）


# 调试与性能

  * **[Trace 打点](</document?id=1173&version=dev&language=cn>)** — Feature 框架内嵌的 sched_note 性能追踪宏

---

## Feature 框架概述

> 路径: 应用框架 > Feature 框架 > Feature 框架概述
> 来源: [https://doc.openvela.com/document?id=1167&language=cn&version=dev](https://doc.openvela.com/document?id=1167&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/feature/feature_framework.md>) | 简体中文 ]

# Feature 框架概述

# 一、Feature 框架简介

在快应用（Quick App）开发中，需要为快应用增加一些新的能力，这些能力通过 C/C++ 语言编写。Feature 框架是一个帮助系统开发者为快应用扩展功能的框架、SDK 以及工具集。

整体架构从上到下分为以下几层：

  * **JS 层** —— 快应用（用户编写的 JS 代码）
  * **框架层** —— 快应用框架（及快应用引擎）、Feature 框架
  * **Native 层** —— Feature 的 C/C++ 实现
  * **操作系统层** —— openvela


# 二、Feature 框架能力

Feature 框架由运行时框架、API 以及 JIDL 语言及工具组成：

  * 提供 JS 层调用 Native 代码的执行框架
  * Feature 框架 API 提供一组 Native 代码与 JS 交互的接口
  * JIDL 是一个接口描述语言，用于自动生成 JS 和 Native 相互调用的接口


![JIDL 接口描述语言工作流程](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455198381_JIDL.png)

## 1、Feature 的概念模型

### 静态概念模型

由于 Feature 是由 Native 向 JS 提供的接口，所以 Feature 的概念也遵循 JS 的概念。

Feature 有 3 层概念：

  * Module：一个 Feature 就是一个模块，它等同于 C 语言里面的程序模块。它没有实例，是全局存在的；
  * Prototype：原型，等同于 JS 中的原型对象，类似 C++ 里面的类，但是又有所不同。一个快应用实例会产生一个 Prototype。所有的 Feature 上的函数、属性都在 Prototype 上管理；
  * Instance：实例，一个 APP 内有多个实例（每 Require 一次就会产生一个实例），实例上保存了所有的处理数据。


具体到快应用中：

  * 一个快应用实例只有一个 Prototype。
  * 一个快应用页面一般只包含一个 Feature 的 Instance。


从系统角度上看 Feature 的概念：

![Feature 静态概念模型](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455198491_feature_static.png)

### 运行时概念模型

每个 Feature 都可以关联 Native 数据，所关联的内容有所区别：

  * **Module** 完全位于 Native 侧，不暴露给 JS 环境。
  * **Prototype** 在 JS 中以 JSObject 形式呈现，但不能直接在 JS 中使用。在 Native 侧持有 prototype Native 数据，生命周期与 APP 一致。
  * **Instance** 在 JS 中也以 JSObject 形式呈现，在 Native 侧持有 instance Native 数据，生命周期与 Instance 本身一致。


### Feature 的生命周期

Feature 的生命周期包含 6 个事件，按发生顺序依次如下：

事件 | 触发时机 | 注意事项  
---|---|---  
**onRegister** （Module 注册） | 系统启动时调用，或者调用 FeatureManagerRegister 函数时触发 | 注册时不可执行长复杂任务，否则会导致系统启动变慢  
**onCreate** （Prototype 创建） | APP 第一次使用 Feature 时调用 | 不可期望该函数在 APP 启动时调用  
**onRequire** （Instance 创建） | APP Require 该 Feature 时调用 | 可在此做 Feature 实例初始化  
**onDettach** （Instance 销毁） | Feature 实例被销毁时（Page 退出、APP 退出等） | Feature 退出有一定不确定性，临时数据不能拖延到此刻回收  
**onDestroy** （Prototype 销毁） | APP 退出时调用 | 此处 APP 全局数据回收  
**onUnregister** （Module 被注销） | Feature 注销时调用 | 不可依赖此回调，该回调可能不会被调用  
  
## 2、Feature 框架提供的接口能力

### 自动生成 Feature Prototype 和 Instance

Feature 框架帮助开发者创建 Feature 的 Prototype 和 Instance。

  1. Feature 开发者需要提供一个 FeatureDescription，描述 Feature 的信息，包括：

     * Feature 的名字
     * Feature 的成员组成
       * Feature 支持的方法，包括方法名、参数列表、返回值以及实现回调函数
       * 属性的名字、类型以及实现函数
       * 其他
  2. 根据 FeatureDescription 生成 FeaturePrototype 和 FeatureInstance，并以 FeatureProtoHandle 和 FeatureInstanceHandle 的方式反馈给开发者。

![Feature Instance 创建流程](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455198594_feature_instance.png)


### 提供参数转换

从 JS 到 Native，Feature 框架提供参数转换能力，将 JS 参数转换为普通参数。下表提供了基本的转换能力：

JS 类型 | C 类型 | 说明  
---|---|---  
number/boolean 类型 | int, float, double, bool | JS 的 number 类型以浮点数形式存在。根据 JIDL 的描述，可以转换成 int、float 等可兼容类型。转成 int/bool 类型会导致小数部分丢失  
string | FtString | const char* 的 typedef  
object | struct 指针 / FtAny 指针 | 如果在 JIDL 中定义了 struct 结构，则转成对应的 C 语言 struct 指针；如果在 JIDL 中定义为 object/any 类型，则定义为 FtAny 指针  
array | FtArray 指针 | 转成一个 C 结构的 FtArray  
function | FtCallbackId | 转成一个整数，表示 CallbackId  
promise | FtPromiseId | 转成一个整数，表示 PromiseId  
  
* * *

  * 指针对象自带引用计数，可以通过 FeatureDupValue 和 FeatureFreeValue 来释放。
  * 通过参数传递的指针，不需要额外释放。


Feature 框架内部对 Callback 和 Promise 做了统一管理，隐藏实现细节：

  * Feature 开发者拿到的是不透明的整数 ID（FtCallbackId / FtPromiseId），而不是 JS Function 或 Promise 对象本身。
  * 真正的 JS Function 和 Promise 对象由 Feature 框架内部（开发者不可见）持有，并带有引用计数。
  * ID 作为索引指向内部表，资源的回收由框架负责。


Feature 框架通过隐藏细节，达到两个目的：

  * Feature 开发者无需关心细节，也无需管理 Callback 和 Promise 的生命周期。
  * FeatureInstance 提供托底的内存管理方法。


### 异步编程模型

Feature 的代码和 JS 代码运行在同一个 uvloop 内，Feature 开发者需要注意调用时长。在普通函数中不能阻塞。

![异步编程模型示意图](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455198703_Asynchronous_model.png)

  * 可添加一个任务到 worker 队列。
  * 任意线程可以调用 FeaturePost 添加任务到主循环队列。


## 3、JIDL 提供的接口描述

JIDL 用于描述 Feature 的接口，下面是一个简单的 Feature 文件：  

    
    
    // 模块名称
    module test@1.0
    
    callback cb(int a, int b);
    
    void foo(int a, float b, string c);
    
    void goo(int a, cb cb1);
    
    property string name;
    property int age;

  * 类似 C++ 语言的注释风格。
  * 总是以 module 开头，包括模块名和版本。
  * 可以定义属性、函数、接口等。


文件定义上：

  * 文件名以 .jidl 结尾。
  * 文件名字一般是 <feature 名字>_<版本号>.jidl，但不强制。


模块命名上，可以使用 . 号，如 system.fetch。

---

## Feature Types API

> 路径: 应用框架 > Feature 框架 > Feature Types API
> 来源: [https://doc.openvela.com/document?id=1168&language=cn&version=dev](https://doc.openvela.com/document?id=1168&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/feature/feature_framework_types.md>) | 简体中文 ]

# Feature Types API

Feature 框架的基础数据类型定义，供 Feature 开发者使用。

头文件：#include <feature_types.h>

# openvela 实现说明

  * **前端无关** ：将各类前端（QuickJS、WAMR 等）的对象封装为统一的 ft_value_t 类型，Feature 开发者无需感知具体前端差异
  * **类型系统** ：通过 FeaturePrimitiveType 枚举为参数传递提供统一的类型标识，内部通过 FT_SET_PRIMITIVE_TYPE(base, flags) 宏编码类型信息与内存管理标志
  * **引用计数** ：TypeFlags 标记类型是否需要托管内存（TYPE_FLAGS_POINTER 需要 malloc/free，TYPE_FLAGS_VALUE 则不需要）
  * **错误码范围** ：通用错误码从 200 开始，自定义错误码从 400 起，开发者可自行扩展


# 基本类型别名

为基本 C 类型提供带 Ft 前缀的别名，便于在 Feature 接口中标识类型语义。  

    
    
    typedef int       FtInt;       // 等价于 int32_t
    typedef int8_t    FtInt8;
    typedef uint8_t   FtUint8;
    typedef int16_t   FtInt16;
    typedef uint16_t  FtUint16;
    typedef int32_t   FtInt32;
    typedef uint32_t  FtUint32;
    typedef int64_t   FtInt64;
    typedef uint64_t  FtUint64;
    typedef float     FtFloat;
    typedef double    FtDouble;
    typedef bool      FtBool;
    typedef const char*   FtString;  // 常量字符串
    typedef ft_value_t*   FtAny;     // 通用 ft_value_t 引用
    
    typedef int32_t   FtCallbackId;  // 回调 ID
    typedef int32_t   FtEventId;     // 事件 ID
    typedef int32_t   FtPromiseId;   // Promise ID

# 句柄类型

Feature 框架核心对象的不透明句柄，开发者只能通过框架 API 操作，不应直接访问底层结构。  

    
    
    typedef void* FeatureRegistryHandle;    // Feature 注册表句柄
    typedef void* FeatureManagerHandle;     // Feature 管理器句柄
    typedef void* FeatureProtoHandle;       // Feature 原型句柄（一个快应用对应一个）
    typedef void* FeatureInstanceHandle;    // Feature 实例句柄（每次 require 产生一个）
    typedef void* FeatureInterfaceHandle;   // Feature 接口句柄
    typedef void* FeatureRuntimeContext;    // 前端运行时上下文（如 QuickJS RuntimeContext）
    typedef void* FeatureRawContextHandle;  // 原始运行时上下文
    
    typedef struct _FeatureWorker* FeatureWorkerHandle;  // Worker 句柄
    typedef uintptr_t FeatureType;          // Feature 类型标志

# 回调函数类型
    
    
    // 通用 Native 函数指针
    typedef void (*NativeFunc)(void);
    
    // Feature 异步任务回调
    typedef void (*FeatureTaskCallback)(int status, void* data);
    
    // Feature 异步任务回调扩展版（带 instance 句柄）
    typedef void (*FeatureTaskCallbackExt)(int status, uint64_t data,
                                           FeatureInstanceHandle feature);
    
    // 事件变更监听回调
    typedef void (*FeatureEventChangeListener)(FeatureInstanceHandle data,
                                               FtEventId eid,
                                               FeatureEventStatus status);
    
    // Manager userdata 释放回调
    typedef void (*ManagerUserdataFreeCallback)(void* data);
    
    // Feature 注册函数
    typedef bool (*FeatureRegistryFunc)(FeatureRegistryHandle);

# 枚举类型

## FeatureTaskMode

Feature 异步任务的运行模式。  

    
    
    enum FeatureTaskMode {
        FEATURE_TASK_MODE_FREE   = 0,  // 异步任务已结束
        FEATURE_TASK_MODE_NORMAL = 1,  // 异步任务正常运行
    };

## FeaturePromiseType

Promise 类型标识。Feature 框架兼容传统 callback 和 Promise 两种异步模型。  

    
    
    typedef enum FeaturePromiseType {
        FEATURE_PROMISE_TYPE_INVALID   = -1,  // 无效类型
        FEATURE_PROMISE_TYPE_PROMISE   = 0,   // Promise 模型
        FEATURE_PROMISE_TYPE_CALLBACKS = 1,   // Callback 模型
    } FeaturePromiseType;

## TypeFlags

类型的内存管理标志，用于决定是否需要释放。  

    
    
    enum TypeFlags {
        TYPE_FLAGS_VALUE             = 1,    // 值类型，无需释放
        TYPE_FLAGS_POINTER,                  // 指针类型，需要 malloc/free
        TYPE_FLAGS_RAWPOINTER         = TYPE_FLAGS_POINTER | 1,  // 原始指针，无需释放
        TYPE_FLAGS_UNMANAGED_POINTER  = TYPE_FLAGS_RAWPOINTER,   // 非托管指针
    };

## FeaturePrimitiveType

参数传递时使用的原始类型编码。通过宏 FT_SET_PRIMITIVE_TYPE(base, flags) 将类型基数与内存管理标志组合编码。  

    
    
    #define FT_SET_PRIMITIVE_TYPE(base, flags) ((base << 2) | (flags))
    
    enum FeaturePrimitiveType {
        FT_VOID      = FT_SET_PRIMITIVE_TYPE(FT_VOID_BASE,    TYPE_FLAGS_VALUE),    // 1
        FT_INT       = FT_SET_PRIMITIVE_TYPE(FT_INT_BASE,     TYPE_FLAGS_VALUE),    // 5
        FT_INT8      = FT_SET_PRIMITIVE_TYPE(FT_INT8_BASE,    TYPE_FLAGS_VALUE),    // 9
        FT_UINT8     = FT_SET_PRIMITIVE_TYPE(FT_UINT8_BASE,   TYPE_FLAGS_VALUE),    // 13
        FT_INT16     = FT_SET_PRIMITIVE_TYPE(FT_INT16_BASE,   TYPE_FLAGS_VALUE),    // 17
        FT_UINT16    = FT_SET_PRIMITIVE_TYPE(FT_UINT16_BASE,  TYPE_FLAGS_VALUE),    // 21
        FT_INT32     = FT_SET_PRIMITIVE_TYPE(FT_INT32_BASE,   TYPE_FLAGS_VALUE),    // 25
        FT_UINT32    = FT_SET_PRIMITIVE_TYPE(FT_UINT32_BASE,  TYPE_FLAGS_VALUE),    // 29
        FT_INT64     = FT_SET_PRIMITIVE_TYPE(FT_INT64_BASE,   TYPE_FLAGS_VALUE),    // 33
        FT_UINT64    = FT_SET_PRIMITIVE_TYPE(FT_UINT64_BASE,  TYPE_FLAGS_VALUE),    // 37
        FT_FLOAT     = FT_SET_PRIMITIVE_TYPE(FT_FLOAT_BASE,   TYPE_FLAGS_VALUE),    // 41
        FT_DOUBLE    = FT_SET_PRIMITIVE_TYPE(FT_DOUBLE_BASE,  TYPE_FLAGS_VALUE),    // 45
        FT_BOOLEAN   = FT_SET_PRIMITIVE_TYPE(FT_BOOLEAN_BASE, TYPE_FLAGS_VALUE),    // 49
        FT_STRING    = FT_SET_PRIMITIVE_TYPE(FT_STRING_BASE,  TYPE_FLAGS_POINTER),  // 54
        FT_CHAR      = FT_STRING,                                                   // 54，与 FT_STRING 等价
        FT_ANY_REF   = FT_SET_PRIMITIVE_TYPE(FT_ANY_REF_BASE,  TYPE_FLAGS_POINTER), // 58
        FT_JSON_OBJ  = FT_SET_PRIMITIVE_TYPE(FT_JSON_OBJ_BASE, TYPE_FLAGS_POINTER), // 62
    };

## FeatureErrorCode

Feature 框架的错误码定义。  

    
    
    typedef enum FeatureErrorCode {
        FT_ERR_GENERAL           = 200,   // 通用错误
        FT_ERR_ARGS              = 202,   // 参数错误
        FT_ERR_TIMEOUT           = 204,   // 超时
        FT_ERR_IOERROR           = 300,   // IO 错误
        FT_ERR_PATH_NOT_EXISTS   = 301,   // 路径不存在
        FT_ERR_CUSTOM_BEGIN      = 400,   // 自定义错误码起点
        FT_ERR_TASK_FAILED       = 1000,  // 任务失败
        FT_ERR_TASK_NOT_EXISTS   = 1001,  // 任务不存在
        FT_ERR_CANCEL_ERROR_CODE = 1002,  // 取消错误
    } FeatureErrorCode;

## FeatureEventStatus

事件变更状态，用于通知监听器事件被添加或移除。  

    
    
    typedef enum FeatureEventStatus {
        FEATURE_EVENT_ADDED,    // 事件被添加
        FEATURE_EVENT_REMOVED,  // 事件被移除
    } FeatureEventStatus;

## FeaturePermsRejectReason

权限拒绝原因。  

    
    
    typedef enum FeaturePermsRejectReason {
        FEATURE_PERMS_DENIED = 400,  // 权限被拒绝
        FEATURE_PERMS_ERROR,         // 权限错误
        FEATURE_PERMS_NO_BG,         // 权限不允许后台
    } FeaturePermsRejectReason;

## FeatureWorkerCancelResult

Worker 取消结果。  

    
    
    enum FeatureWorkerCancelResult {
        FeatureWorkerCancelSuccess,       // 成功取消
        FeatureWorkerCancelPending,       // 任务处于 pending，未能取消
        FeatureWorkerCancelInvalid,       // Worker 无效
        FeatureWorkerCancelUnknownError,  // 未知错误
    };

## FeatureWorkerState

Worker 运行状态。  

    
    
    enum FeatureWorkerState {
        FEATURE_WORKER_PENDING,    // 等待中
        FEATURE_WORKER_RUNNING,    // 运行中
        FEATURE_WORKER_INVALID,    // 无效状态
        FEATURE_WORKER_RESOLVED,   // 已 resolve
        FEATURE_WORKER_REJECTED,   // 已 reject
        FEATURE_WORKER_FINISHED,   // 已完成
    };

## FeatureManagerType

Feature 管理器类型。  

    
    
    typedef enum FeatureManagerType {
        FEATURE_MANAGER_JS,    // JS 类型 Feature 管理器
        FEATURE_MANAGER_WAMR,  // WAMR 类型 Feature 管理器
    } FeatureManagerType;

# 结构体

## FtArray

Feature 框架通用动态数组结构。  

    
    
    typedef struct FtArray {
        int32_t _size;       // 当前数组实际元素数
        int32_t _capacity;   // 当前容量
        void*   _element;    // 元素指针
    } FtArray;

## FtJsonObject

JSON 对象句柄，内部为柔性字符串。  

    
    
    typedef struct _FtJsonObject {
        char str[0];  // 内部字符串数据
    } *FtJsonObject;

## AppendData

用于向数组追加元素的通用联合体，支持多种基本类型。  

    
    
    typedef union AppendData {
        int32_t     i32;  // 32 位有符号整数
        int64_t     i64;  // 64 位有符号整数
        uint32_t    u32;  // 32 位无符号整数
        uint64_t    u64;  // 64 位无符号整数
        float       f32;  // 单精度浮点
        double      f64;  // 双精度浮点
        void*       ptr;  // 任意指针
        const char* str;  // 字符串
    } AppendData;

## FtVariParams

可变长参数包。  

    
    
    typedef struct FtVariParams {
        int32_t     vari_count;  // 参数数量
        ft_value_t* vari_args;   // 参数数组指针
    } FtVariParams;

## FeatureWorkerResult

Worker 的执行结果联合体。  

    
    
    typedef union _FeatureWorkerResult {
        int64_t  ival;   // 有符号整数结果
        uint64_t uval;   // 无符号整数结果
        double   dval;   // 浮点结果
        char*    str;    // 字符串结果
        void*    ptr;    // 指针结果
    } FeatureWorkerResult;

## VTable

Feature 接口创建时使用的虚函数表。  

    
    
    typedef struct VTable {
        int               size;       // 成员数量
        NativeFunc        finalizer;  // 析构函数
        const NativeFunc* members;    // 成员函数数组
    } VTable;

## FeatureManagerCreateInfo

创建 Feature 管理器时所需的配置信息。  

    
    
    typedef struct FeatureManagerCreateInfo {
        FeatureRawContextHandle raw_ctx;       // 原始上下文句柄
        ReleaseRawContextCb     release_cb;    // 原始上下文释放回调
        FeatureManagerType      manager_type;  // 管理器类型（JS / WAMR）
        const char*             package_name;  // 快应用包名
    } FeatureManagerCreateInfo;

## FeatureMemoryDump

内存诊断回调结构，用于在调试时统计内存使用情况。  

    
    
    typedef struct {
        MemoryDumpCountCB     count;       // 单项内存计数回调
        MemoryDumpCountMetaCB count_meta;  // 带名称的元数据计数回调
        MemoryDumpSubCB       sub;         // 递归子项回调
    } FeatureMemoryDump;

## ArgsErrorInfo

参数错误信息。当 Feature 调用参数类型不匹配时，通过 ArgsErrorCb 回调传递此信息。  

    
    
    typedef struct {
        int         argc;        // 参数个数
        void*       argv;        // 参数列表指针
        int         error_code;  // 错误码
        const char* error_msg;   // 错误消息
    } ArgsErrorInfo;

## FeaturePermissionsInfo

权限检查信息。  

    
    
    typedef struct FeaturePermissionsInfo {
        const FeaturePermissions* permissions;   // 权限描述
        const char*               api_name;      // API 名称
        bool                      has_async_cbs; // 是否带异步回调
    } FeaturePermissionsInfo;

## FeatureRegistryTable

Feature 注册表，用于批量注册多个 Feature。  

    
    
    typedef struct _FeatureRegistryTable {
        size_t              count;    // 条目数
        FeatureRegistryFunc data[];   // 注册函数数组（柔性成员）
    } FeatureRegistryTable, *FeatureRegistryTableHandle;

---

## Feature Context API

> 路径: 应用框架 > Feature 框架 > Feature Context API
> 来源: [https://doc.openvela.com/document?id=1169&language=cn&version=dev](https://doc.openvela.com/document?id=1169&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/feature/feature_framework_context.md>) | 简体中文 ]

# Feature Context API

Feature 框架提供的统一数据类型与上下文操作接口。通过 ft_value_t 封装前端（QuickJS、WAMR 等）的原生对象，开发者无需感知具体前端差异即可完成类型转换、数组对象操作与内存管理。

头文件：#include <feature_context.h>

# openvela 实现说明

  * **核心数据类型 ft_value_t**：统一封装前端的 JSValue/Wasm 对象，根据目标平台是否 64 位使用 16 字节或 8 字节存储
  * **ft_context_ref** ：伴随 ft_value_t 的上下文对象，所有 API 都需要传入，用于定位具体的前端 Runtime
  * **值类型 vs 引用类型** ：
    * ft_from_int / ft_from_bool 等返回值类型，无需显式释放
    * ft_from_string / ft_from_buffer / ft_new_object 等返回引用类型，必须通过 ft_free_value 释放
  * **释放规则** ：
    * **无需释放** ：Feature 实现函数入参、作为返回值传回前端的 ft_value_t
    * **必须释放** ：ft_from_xxx 创建的对象、ft_new_object 新建对象、ft_array_at 取出的元素、ft_obj_get_property 返回的属性、ft_parse_json 解析结果
    * 字符串：ft_to_string 返回的 const char* 必须用 ft_free_string 释放


# Feature Context 与前端运行时的关系

下图展示了 Feature 框架如何通过 ft_value_t 与 ft_context_ref 统一封装前端运行时（以 QuickJS 为例）的原生对象：

![Feature Context 与前端运行时的关系](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455199399_ft_context.svg)

  * **Feature Framework Interface** ：Feature 框架对外提供的统一 C 接口，由 ft_value_t（数据）与 ft_context_ref（上下文）两部分组成。
  * **JS Implementation** ：具体前端运行时的实现。ft_value_t 背后对应 JSValue，ft_context_ref 背后对应 JSContext，两者之间是 N:1 的关系（多个值归属于同一上下文）。
  * 切换其他前端（如 WAMR）时，Feature 实现侧的代码不需要修改，只需替换底层映射关系。


# 类型与上下文访问

## ft_context_get_data
    
    
    void* ft_context_get_data(ft_context_ref ft_ctx);

获取当前 Feature 上下文关联的用户数据指针。该用户数据由 Feature 管理器在初始化阶段绑定。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。


**返回值** ：

返回关联的用户数据指针，若未绑定则返回 NULL。

## ft_get_type
    
    
    ft_type ft_get_type(ft_context_ref ft_ctx, ft_value_t ft_val);

获取给定 ft_value_t 的类型。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * ft_val 待查询类型的 ft_value_t。


**返回值** ：

返回值类型枚举 ft_type：

  * FT_TYPE_NULL：null
  * FT_TYPE_UNDEF：undefined
  * FT_TYPE_NONE：未定义值
  * FT_TYPE_NUMBER：数值
  * FT_TYPE_BOOL：布尔
  * FT_TYPE_STRING：字符串
  * FT_TYPE_ARRAY：数组
  * FT_TYPE_BUFFER：二进制缓冲区
  * FT_TYPE_TYPED_BUFFER：类型化缓冲区
  * FT_TYPE_OBJECT：对象


## ft_undefined
    
    
    ft_value_t ft_undefined(ft_context_ref ft_ctx);

构造 undefined 类型的 ft_value_t。用于向前端返回"无值"结果。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。


**返回值** ：

返回一个类型为 FT_TYPE_UNDEF 的 ft_value_t。该值为值类型，无需显式释放。

# 基本类型转换（Native → ft_value_t）

以下接口将 C 原生类型转换为 ft_value_t，便于传递给前端。

## ft_from_int
    
    
    ft_value_t ft_from_int(ft_context_ref ft_ctx, int32_t val);

将 32 位有符号整数转换为 ft_value_t。返回值为值类型，无需释放。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * val 32 位有符号整数值。


**返回值** ：

返回对应的 ft_value_t（类型为 FT_TYPE_NUMBER）。

## ft_from_uint
    
    
    ft_value_t ft_from_uint(ft_context_ref ft_ctx, uint32_t val);

将 32 位无符号整数转换为 ft_value_t。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * val 32 位无符号整数值。


**返回值** ：

返回对应的 ft_value_t。

## ft_from_int64
    
    
    ft_value_t ft_from_int64(ft_context_ref ft_ctx, int64_t val);

将 64 位有符号整数转换为 ft_value_t。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * val 64 位有符号整数值。


**返回值** ：

返回对应的 ft_value_t。

## ft_from_uint64
    
    
    ft_value_t ft_from_uint64(ft_context_ref ft_ctx, uint64_t val);

将 64 位无符号整数转换为 ft_value_t。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * val 64 位无符号整数值。


**返回值** ：

返回对应的 ft_value_t。

## ft_from_double
    
    
    ft_value_t ft_from_double(ft_context_ref ft_ctx, double val);

将双精度浮点数转换为 ft_value_t。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * val 双精度浮点值。


**返回值** ：

返回对应的 ft_value_t。

## ft_from_bool
    
    
    ft_value_t ft_from_bool(ft_context_ref ft_ctx, bool val);

将布尔值转换为 ft_value_t。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * val 布尔值。


**返回值** ：

返回对应的 ft_value_t（类型为 FT_TYPE_BOOL）。

## ft_from_string
    
    
    ft_value_t ft_from_string(ft_context_ref ft_ctx, const char* val);

将 C 字符串转换为 ft_value_t。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * val 以 \0 结尾的 C 字符串。


**返回值** ：

返回对应的 ft_value_t（类型为 FT_TYPE_STRING）。

**注意** ：

  * 返回的 ft_value_t 为引用类型，**必须** 通过 ft_free_value 释放。
  * 实现会拷贝 val 的内容，调用后原指针可以立即释放。


# 二进制缓冲区转换

## ft_from_buffer
    
    
    ft_value_t ft_from_buffer(ft_context_ref ft_ctx, uint8_t* buff, uint32_t size);

将 Native 字节缓冲区封装为 ft_value_t。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * buff 字节缓冲区起始指针。
  * size 缓冲区字节数。


**返回值** ：

返回对应的 ft_value_t（类型为 FT_TYPE_BUFFER）。

**注意** ：

  * 返回的 ft_value_t 为引用类型，必须通过 ft_free_value 释放。


## ft_from_typed_buffer
    
    
    ft_value_t ft_from_typed_buffer(ft_context_ref ft_ctx, uint8_t* buff,
                                    uint32_t size, FtTypedArrayType type);

将 Native 缓冲区封装为前端的类型化数组（Typed Array）。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * buff 字节缓冲区起始指针。
  * size 缓冲区字节数。
  * type 类型化数组的元素类型，详见 FtTypedArrayType：
    * FT_Int8Array / FT_Uint8Array
    * FT_Int16Array / FT_Uint16Array
    * FT_Int32Array / FT_Uint32Array
    * FT_Float32Array / FT_Float64Array


**返回值** ：

返回对应的 ft_value_t（类型为 FT_TYPE_TYPED_BUFFER）。必须通过 ft_free_value 释放。

**示例** ：  

    
    
    uint8_t* buff = ft_to_buffer(ft_ctx, &size, data);
    // 对 buff 做处理
    ft_value_t ret = ft_from_typed_buffer(ft_ctx, buff, size, FT_Uint8Array);

## ft_parse_json
    
    
    ft_value_t ft_parse_json(ft_context_ref ft_ctx, const char* buf,
                             size_t buf_len, const char* filename);

解析 JSON 字符串为 ft_value_t 对象。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * buf JSON 字符串指针。
  * buf_len JSON 字符串长度（字节）。
  * filename 用于错误信息定位的文件名，可传 NULL。


**返回值** ：

成功时返回解析得到的 ft_value_t；失败时返回类型为 FT_TYPE_UNDEF 的值。

**注意** ：

  * 返回的 ft_value_t 为引用类型，必须通过 ft_free_value 释放。


# 数组类型转换（Native 数组 → ft_value_t）

将 Native 数组转换为 ft_value_t 数组。所有返回值均为引用类型，必须通过 ft_free_value 释放。

## ft_from_int_array
    
    
    ft_value_t ft_from_int_array(ft_context_ref ft_ctx, int32_t* val, uint32_t size);

将 int32 数组转换为 ft_value_t。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * val 源数组指针。
  * size 数组元素个数。


**返回值** ：

返回对应的 ft_value_t（类型为 FT_TYPE_ARRAY）。

## ft_from_uint_array
    
    
    ft_value_t ft_from_uint_array(ft_context_ref ft_ctx, uint32_t* val, uint32_t size);

将 uint32 数组转换为 ft_value_t。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * val 源数组指针。
  * size 数组元素个数。


**返回值** ：

返回对应的 ft_value_t。

## ft_from_int64_array
    
    
    ft_value_t ft_from_int64_array(ft_context_ref ft_ctx, int64_t* val, uint32_t size);

将 int64 数组转换为 ft_value_t。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * val 源数组指针。
  * size 数组元素个数。


**返回值** ：

返回对应的 ft_value_t。

## ft_from_uint64_array
    
    
    ft_value_t ft_from_uint64_array(ft_context_ref ft_ctx, uint64_t* val, uint32_t size);

将 uint64 数组转换为 ft_value_t。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * val 源数组指针。
  * size 数组元素个数。


**返回值** ：

返回对应的 ft_value_t。

## ft_from_bool_array
    
    
    ft_value_t ft_from_bool_array(ft_context_ref ft_ctx, bool* val, uint32_t size);

将布尔数组转换为 ft_value_t。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * val 源数组指针。
  * size 数组元素个数。


**返回值** ：

返回对应的 ft_value_t。

## ft_from_double_array
    
    
    ft_value_t ft_from_double_array(ft_context_ref ft_ctx, double* val, uint32_t size);

将 double 数组转换为 ft_value_t。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * val 源数组指针。
  * size 数组元素个数。


**返回值** ：

返回对应的 ft_value_t。

## ft_from_string_array
    
    
    ft_value_t ft_from_string_array(ft_context_ref ft_ctx, const char** val, uint32_t size);

将 C 字符串数组转换为 ft_value_t。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * val 字符串指针数组。
  * size 数组元素个数。


**返回值** ：

返回对应的 ft_value_t。

# 基本类型转换（ft_value_t → Native）

以下接口将前端传入的 ft_value_t 转换为 C 原生类型，便于 Feature 实现使用。

## ft_to_int
    
    
    bool ft_to_int(ft_context_ref ft_ctx, ft_value_t f_val, int32_t* val);

将 ft_value_t 转换为 32 位有符号整数。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * f_val 源 ft_value_t，应为数值类型。
  * val 用于接收结果的 int32_t*。


**返回值** ：

转换成功时返回 true，否则返回 false（通常因为 f_val 不是数值类型）。

## ft_to_uint
    
    
    bool ft_to_uint(ft_context_ref ft_ctx, ft_value_t f_val, uint32_t* val);

将 ft_value_t 转换为 32 位无符号整数。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * f_val 源 ft_value_t。
  * val 用于接收结果的 uint32_t*。


**返回值** ：

成功返回 true，失败返回 false。

## ft_to_int64
    
    
    bool ft_to_int64(ft_context_ref ft_ctx, ft_value_t f_val, int64_t* val);

将 ft_value_t 转换为 64 位有符号整数。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * f_val 源 ft_value_t。
  * val 用于接收结果的 int64_t*。


**返回值** ：

成功返回 true，失败返回 false。

## ft_to_uint64
    
    
    bool ft_to_uint64(ft_context_ref ft_ctx, ft_value_t f_val, uint64_t* val);

将 ft_value_t 转换为 64 位无符号整数。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * f_val 源 ft_value_t。
  * val 用于接收结果的 uint64_t*。


**返回值** ：

成功返回 true，失败返回 false。

## ft_to_double
    
    
    bool ft_to_double(ft_context_ref ft_ctx, ft_value_t f_val, double* val);

将 ft_value_t 转换为双精度浮点数。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * f_val 源 ft_value_t。
  * val 用于接收结果的 double*。


**返回值** ：

成功返回 true，失败返回 false。

## ft_to_bool
    
    
    bool ft_to_bool(ft_context_ref ft_ctx, ft_value_t ft_val, bool* val);

将 ft_value_t 转换为布尔值。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * ft_val 源 ft_value_t。
  * val 用于接收结果的 bool*。


**返回值** ：

成功返回 true，失败返回 false。

## ft_to_string
    
    
    const char* ft_to_string(ft_context_ref ft_ctx, ft_value_t f_val);

将 ft_value_t 转换为 C 字符串。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * f_val 源 ft_value_t，应为字符串类型。


**返回值** ：

成功时返回字符串指针；失败时返回 NULL。

**注意** ：

  * 返回的字符串由框架管理，**必须** 通过 ft_free_string 释放。
  * Feature 框架不保证该字符串长期有效，如需保留应及时拷贝。


## ft_to_buffer
    
    
    uint8_t* ft_to_buffer(ft_context_ref ft_ctx, size_t* p_size, ft_value_t f_val);

将 ft_value_t 转换为二进制缓冲区。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * p_size 输出参数，返回缓冲区字节数。
  * f_val 源 ft_value_t，应为 FT_TYPE_BUFFER 或 FT_TYPE_TYPED_BUFFER。


**返回值** ：

成功时返回缓冲区起始指针；失败时返回 NULL。

**注意** ：

  * 返回的指针由前端管理，不要手动 free。


# 数组操作

## ft_array_size
    
    
    uint32_t ft_array_size(ft_context_ref ft_ctx, const ft_value_t array);

获取 ft_value_t 数组的元素数量。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * array 数组类型的 ft_value_t。


**返回值** ：

返回数组元素个数。若 array 不是数组类型，返回 0。

## ft_array_at
    
    
    ft_value_t ft_array_at(ft_context_ref ft_ctx, const ft_value_t array, uint32_t idx);

按索引访问 ft_value_t 数组中的元素。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * array 数组类型的 ft_value_t。
  * idx 元素索引，从 0 开始。


**返回值** ：

成功时返回索引位置的元素 ft_value_t；越界或 array 非数组时返回 undefined。

**注意** ：

  * 返回的 ft_value_t 为引用类型，**必须** 通过 ft_free_value 释放。


# 对象操作

## ft_new_object
    
    
    ft_value_t ft_new_object(ft_context_ref ft_ctx);

创建一个空的 ft_value_t 对象。Feature 可以向该对象挂载自定义属性。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。


**返回值** ：

返回新建的对象 ft_value_t（类型为 FT_TYPE_OBJECT）。

**注意** ：

  * 返回值为引用类型，必须通过 ft_free_value 释放。
  * 对象支持挂载子属性，释放根对象时子属性会被自动释放。


## ft_obj_get_property
    
    
    ft_value_t ft_obj_get_property(ft_context_ref ft_ctx, ft_value_t ft_val, const char* prop);

按属性名读取 ft_value_t 对象的属性值。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * ft_val 对象类型的 ft_value_t。
  * prop 属性名。


**返回值** ：

成功时返回属性值的 ft_value_t；属性不存在时返回 undefined。

**注意** ：

  * 返回的 ft_value_t 为引用类型，必须通过 ft_free_value 释放。


## ft_obj_set_property
    
    
    bool ft_obj_set_property(ft_context_ref ft_ctx, ft_value_t obj,
                             const char* prop, ft_value_t val);

为 ft_value_t 对象设置属性值。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * obj 目标对象 ft_value_t。
  * prop 属性名。
  * val 要设置的属性值。


**返回值** ：

设置成功返回 true，失败返回 false。

# 内存管理

## ft_free_value
    
    
    void ft_free_value(ft_context_ref ft_ctx, ft_value_t ft_val);

释放 ft_value_t 引用计数。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * ft_val 待释放的 ft_value_t。


**注意** ：

**需要释放** 的 ft_value_t 来源：

  * ft_from_xxx 创建的对象
  * ft_new_object 新建的对象
  * ft_array_at 取出的元素
  * ft_obj_get_property 返回的属性
  * ft_parse_json 解析得到的对象


**不需要释放** 的 ft_value_t：

  * Feature 实现函数收到的入参
  * 作为返回值传回前端的 ft_value_t


未正确释放引用类型的 ft_value_t 会导致内存泄漏。

## ft_free_string
    
    
    void ft_free_string(ft_context_ref ft_ctx, const char* str);

释放由 ft_to_string 返回的字符串。

**参数** ：

  * ft_ctx 当前 Feature 上下文引用。
  * str 待释放的字符串指针。


**注意** ：

  * Feature 框架不保证 ft_to_string 返回的字符串长期有效，使用完毕后必须及时调用本接口释放。
  * 不要使用 free() 或 delete 释放，必须使用本接口。

---

## Feature Export API

> 路径: 应用框架 > Feature 框架 > Feature Export API
> 来源: [https://doc.openvela.com/document?id=1170&language=cn&version=dev](https://doc.openvela.com/document?id=1170&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/feature/feature_framework_export.md>) | 简体中文 ]

# Feature Export API

Feature 框架为 Feature 开发者提供的核心运行时接口，涵盖内存与数组管理、引用访问、回调、Promise、事件、异步 Worker、JSON 对象与注册表等能力。

头文件：#include <feature_exports.h>

# openvela 实现说明

  * **内存所有权** ：FeatureMalloc / FeatureInstanceAlloc* 分配的内存由框架托管，使用 FeatureDupValue 增加引用，FeatureFreeValue 减少引用，引用计数为 0 时释放
  * **数组类型** ：FtArray 由框架管理，通过 FeatureCreateArray / FeatureArrayCopy 创建，支持 FeatureArrayAppend / FeatureArrayInsertAfter 等原位操作
  * **回调与 Promise** ：Feature 接口支持 Callback 与 Promise 两种异步模型，通过 FeatureGetPromiseType 查询当前调用使用的类型
  * **Worker 机制** ：FeatureCreateWorker 创建的 Worker 在独立线程或 uv work queue 中执行，完成后回主线程通知结果
  * **线程安全** ：调用 FeaturePost / FeaturePostExt 将任务抛回 Feature 管理器绑定的事件循环，避免跨线程操作 FeatureInstanceHandle
  * **引用管理** ：使用 FeatureDupInstanceHandle 延长 FeatureInstanceHandle 生命周期，避免在异步回调中访问已销毁的实例
  * **实例 Detach** ：在异步回调里必须通过 FeatureInstanceIsDetached 判断实例是否已分离，分离后不得再调用该句柄


# 内存分配

## FeatureInstanceAlloc
    
    
    void* FeatureInstanceAlloc(FeatureInstanceHandle handle, size_t size);

为 Feature 实例分配内存。分配的内存由框架托管，可通过 FeatureFreeValue 释放。

**参数** ：

  * handle Feature 实例句柄。
  * size 申请字节数。


**返回值** ：

成功时返回内存起始指针；失败时返回 NULL。

## FeatureInstanceAllocType
    
    
    void* FeatureInstanceAllocType(FeatureInstanceHandle hInst, size_t size, FeatureType type);

按类型为 Feature 实例分配内存，分配的内存携带类型标记。

**参数** ：

  * hInst Feature 实例句柄。
  * size 申请字节数。
  * type 类型标识，详见 FeatureType。


**返回值** ：

成功时返回内存起始指针；失败时返回 NULL。

## FeatureInstanceAllocProtobuf
    
    
    void* FeatureInstanceAllocProtobuf(FeatureInstanceHandle handle,
                                        const ProtobufCMessageDescriptor* desc);

根据 Protobuf 消息描述符为 Feature 实例分配内存，并自动完成字段初始化。

**参数** ：

  * handle Feature 实例句柄。
  * desc Protobuf 消息描述符指针。


**返回值** ：

成功时返回已初始化的消息对象指针；失败时返回 NULL。

## FeatureInstanceDupValue
    
    
    void* FeatureInstanceDupValue(void* ptr);

为通过 FeatureInstanceAlloc* 分配的指针增加引用计数。

**参数** ：

  * ptr 待增加引用的指针，必须是 FeatureInstanceAlloc* 返回值。


**返回值** ：

返回原指针（方便链式使用）。

## FeatureInstanceFreeValue
    
    
    void FeatureInstanceFreeValue(void* ptr);

减少 FeatureInstanceAlloc* 分配指针的引用计数，为 0 时真正释放。

**参数** ：

  * ptr 待释放的指针。


## FeatureMalloc
    
    
    void* FeatureMalloc(size_t size, FeatureType featureType);

按类型分配一块 Feature 托管内存。

**参数** ：

  * size 申请字节数。
  * featureType 类型标识。


**返回值** ：

成功时返回内存指针；失败时返回 NULL。

## FeatureDupValue
    
    
    void* FeatureDupValue(void* ptr);

增加 Feature 值的引用计数。仅适用于 FeatureMalloc 分配的指针。

**参数** ：

  * ptr 待增加引用的指针。


**返回值** ：

返回原指针。

## FeatureFreeValue
    
    
    void FeatureFreeValue(void* ptr);

减少 Feature 值的引用计数，为 0 时真正释放。仅适用于 FeatureMalloc 分配的指针。

**参数** ：

  * ptr 待释放的指针。


## FeatureGetValueRefCount
    
    
    int32_t FeatureGetValueRefCount(void* ptr);

获取 Feature 值的当前引用计数。仅对 FeatureMalloc 分配的指针有效。

**参数** ：

  * ptr 查询目标指针。


**返回值** ：

返回引用计数值。

## FeatureStrCopy
    
    
    char* FeatureStrCopy(FeatureInstanceHandle handle, const char* str);

基于原始 C 字符串创建一个由 Feature 框架托管的字符串副本。

**参数** ：

  * handle Feature 实例句柄。
  * str 源字符串。


**返回值** ：

成功时返回新字符串指针；失败时返回 NULL。返回值可通过 FeatureStrAddRef 增加引用，或通过 FeatureInstanceFreeValue 释放。

## FeatureStrAddRef
    
    
    #define FeatureStrAddRef(ptr) FeatureInstanceDupValue(ptr)

为 Feature 字符串增加一次引用计数，等价于 FeatureInstanceDupValue。

**参数** ：

  * ptr Feature 字符串指针。


**返回值** ：

返回原指针（便于链式调用）。

# 数组管理

## FeatureCreateArray
    
    
    FtArray* FeatureCreateArray(FeatureInstanceHandle handle, size_t capacity,
                                 FeatureType element_type);

创建一个空的 FtArray，预留给定容量。

**参数** ：

  * handle Feature 实例句柄。
  * capacity 初始容量。
  * element_type 元素类型，详见 FeatureType。


**返回值** ：

成功时返回新数组指针；失败时返回 NULL。

## FeatureArrayCopy
    
    
    FtArray* FeatureArrayCopy(FeatureInstanceHandle handle, FeatureType element_type,
                              const void* data, size_t count);

从现有数据拷贝创建一个 FtArray。拷贝时对每个元素执行类型相关的深拷贝。

**参数** ：

  * handle Feature 实例句柄。
  * element_type 元素类型。
  * data 源数据起始指针。
  * count 元素个数。


**返回值** ：

成功时返回新数组指针；失败时返回 NULL。

## FeatureArrayCopyRaw
    
    
    FtArray* FeatureArrayCopyRaw(FeatureInstanceHandle handle, FeatureType element_type,
                                  const void* data, size_t count);

从现有数据按原始字节拷贝创建 FtArray，不对元素做深拷贝。

**参数** ：

  * handle Feature 实例句柄。
  * element_type 元素类型。
  * data 源数据起始指针。
  * count 元素个数。


**返回值** ：

成功时返回新数组指针；失败时返回 NULL。

## FeatureArrayResize
    
    
    FtArray* FeatureArrayResize(FtArray* arr, size_t new_size);

调整数组大小。若 new_size 大于当前容量则扩容，小于则截断。

**参数** ：

  * arr 待调整的数组。
  * new_size 新的元素数量。


**返回值** ：

成功时返回调整后的数组指针（可能被 realloc 指向新地址）；失败时返回 NULL。

## FeatureArrayGetLength
    
    
    size_t FeatureArrayGetLength(FtArray* arr);

获取数组当前元素数量。

**参数** ：

  * arr 目标数组。


**返回值** ：

返回当前元素数量。

## FeatureArrayGetData
    
    
    void* FeatureArrayGetData(FtArray* arr, int start);

获取数组从指定索引开始的元素指针。

**参数** ：

  * arr 目标数组。
  * start 起始索引。


**返回值** ：

返回元素起始指针。索引越界时返回 NULL。

## FeatureArrayAppend
    
    
    FtArray* FeatureArrayAppend(FtArray* arr, const void* data);

向数组末尾追加一个元素（深拷贝）。

**参数** ：

  * arr 目标数组。
  * data 待追加元素的数据指针。


**返回值** ：

成功时返回数组指针；失败时返回 NULL。

## FeatureArrayAppendRaw
    
    
    FtArray* FeatureArrayAppendRaw(FtArray* arr, const void* data);

向数组末尾追加一个元素（原始字节拷贝，不做深拷贝）。

**参数** ：

  * arr 目标数组。
  * data 待追加元素的数据指针。


**返回值** ：

成功时返回数组指针；失败时返回 NULL。

## FeatureArrayClear
    
    
    int FeatureArrayClear(FtArray* arr);

清空数组中所有元素，保留已分配的容量。

**参数** ：

  * arr 目标数组。


**返回值** ：

成功时返回 0；失败时返回负数。

## FeatureArrayRemove
    
    
    int FeatureArrayRemove(FtArray* arr, int start, size_t count);

从指定位置开始删除 count 个元素。

**参数** ：

  * arr 目标数组。
  * start 起始索引。
  * count 删除元素个数。


**返回值** ：

成功时返回 0；失败时返回负数。

## FeatureArrayInsertAfter
    
    
    int FeatureArrayInsertAfter(FtArray* arr, int start, const void* data, size_t count);

在指定位置**之后** 插入 count 个元素（深拷贝）。

**参数** ：

  * arr 目标数组。
  * start 参考位置索引。
  * data 元素数据起始指针。
  * count 插入元素个数。


**返回值** ：

成功时返回 0；失败时返回负数。

## FeatureArrayInsertRawAfter
    
    
    int FeatureArrayInsertRawAfter(FtArray* arr, int start, const void* data, size_t count);

同 FeatureArrayInsertAfter，但使用原始字节拷贝。

**参数** ：

  * arr 目标数组。
  * start 参考位置索引。
  * data 元素数据起始指针。
  * count 插入元素个数。


**返回值** ：

成功时返回 0；失败时返回负数。

## FeatureArrayInsertBefore
    
    
    int FeatureArrayInsertBefore(FtArray* arr, int start, const void* data, size_t count);

在指定位置**之前** 插入 count 个元素（深拷贝）。

**参数** ：

  * arr 目标数组。
  * start 参考位置索引。
  * data 元素数据起始指针。
  * count 插入元素个数。


**返回值** ：

成功时返回 0；失败时返回负数。

## FeatureArrayInsertRawBefore
    
    
    int FeatureArrayInsertRawBefore(FtArray* arr, int start, const void* data, size_t count);

同 FeatureArrayInsertBefore，但使用原始字节拷贝。

**参数** ：

  * arr 目标数组。
  * start 参考位置索引。
  * data 元素数据起始指针。
  * count 插入元素个数。


**返回值** ：

成功时返回 0；失败时返回负数。

# Feature 句柄与上下文访问

## FeatureGetProtoHandle
    
    
    FeatureProtoHandle FeatureGetProtoHandle(FeatureInstanceHandle handle);

从 Feature 实例句柄获取对应的原型句柄。

**参数** ：

  * handle Feature 实例句柄。


**返回值** ：

返回对应的 FeatureProtoHandle；失败时返回 NULL。

## FeatureGetProtoData
    
    
    void* FeatureGetProtoData(FeatureProtoHandle handle);

获取绑定到 Feature 原型的用户数据。该数据对所有该原型的实例可见。

**参数** ：

  * handle Feature 原型句柄。


**返回值** ：

返回用户数据指针；未绑定则返回 NULL。

## FeatureSetProtoData
    
    
    void FeatureSetProtoData(FeatureProtoHandle handle, void* data);

在 Feature 原型上挂载用户数据。

**参数** ：

  * handle Feature 原型句柄。
  * data 用户数据指针。


## FeatureGetObjectData
    
    
    void* FeatureGetObjectData(FeatureInstanceHandle handle);

获取绑定到 Feature 实例的用户数据。

**参数** ：

  * handle Feature 实例句柄。


**返回值** ：

返回用户数据指针；未绑定则返回 NULL。

## FeatureSetObjectData
    
    
    void FeatureSetObjectData(FeatureInstanceHandle handle, void* data);

在 Feature 实例上挂载用户数据。

**参数** ：

  * handle Feature 实例句柄。
  * data 用户数据指针。


## FeatureGetContext
    
    
    ft_context_ref FeatureGetContext(FeatureInstanceHandle handle);

从 Feature 实例获取其运行时上下文（前端相关）。

**参数** ：

  * handle Feature 实例句柄。


**返回值** ：

返回 ft_context_ref；失败时返回 NULL。

## FeatureGetPackageName
    
    
    const char* FeatureGetPackageName(FeatureProtoHandle handle);

获取 Feature 原型对应的快应用包名。

**参数** ：

  * handle Feature 原型句柄。


**返回值** ：

成功时返回包名字符串；失败时返回 NULL。返回值由框架管理，不要手动释放。

## FeatureGetPackageVersion
    
    
    const char* FeatureGetPackageVersion(FeatureProtoHandle handle);

获取 Feature 原型对应的快应用版本号。

**参数** ：

  * handle Feature 原型句柄。


**返回值** ：

成功时返回版本号字符串；失败时返回 NULL。

## FeatureGetEnvironmentName
    
    
    const char* FeatureGetEnvironmentName(FeatureProtoHandle handle);

获取 Feature 原型所在的运行环境名称。

**参数** ：

  * handle Feature 原型句柄。


**返回值** ：

成功时返回环境名字符串；失败时返回 NULL。

## FeatureInstanceGetManagerUserData
    
    
    void* FeatureInstanceGetManagerUserData(FeatureInstanceHandle handle, const char* name);

从 Feature 实例所属的管理器中按名称获取用户数据。

**参数** ：

  * handle Feature 实例句柄。
  * name 用户数据名称。


**返回值** ：

成功时返回用户数据指针；未找到返回 NULL。

## FeatureGetManagerHandleFromInstance
    
    
    FeatureManagerHandle FeatureGetManagerHandleFromInstance(FeatureInstanceHandle handle);

从 Feature 实例句柄获取其所属的 Feature 管理器句柄。

**参数** ：

  * handle Feature 实例句柄。


**返回值** ：

成功时返回 FeatureManagerHandle；失败时返回 NULL。

## FeatureGetManagerHandleFromProto
    
    
    FeatureManagerHandle FeatureGetManagerHandleFromProto(FeatureProtoHandle handle);

从 Feature 原型句柄获取其所属的 Feature 管理器句柄。

**参数** ：

  * handle Feature 原型句柄。


**返回值** ：

成功时返回 FeatureManagerHandle；失败时返回 NULL。

## FeatureGetUVLoop
    
    
    uv_loop_t* FeatureGetUVLoop(FeatureManagerHandle handle);

获取 Feature 管理器绑定的 libuv 事件循环。

**参数** ：

  * handle Feature 管理器句柄。


**返回值** ：

成功时返回 uv_loop_t*；未绑定时返回 NULL。

## FeatureDupInstanceHandle
    
    
    FeatureInstanceHandle FeatureDupInstanceHandle(FeatureInstanceHandle handle);

增加 Feature 实例句柄的引用计数，返回同一句柄（可链式使用）。

**参数** ：

  * handle Feature 实例句柄。


**返回值** ：

返回原句柄。

## FeatureFreeInstanceHandle
    
    
    void FeatureFreeInstanceHandle(FeatureInstanceHandle handle);

减少 Feature 实例句柄的引用计数，为 0 时释放。

**参数** ：

  * handle Feature 实例句柄。


## FeatureInstanceIsDetached
    
    
    bool FeatureInstanceIsDetached(FeatureInstanceHandle handle);

判断 Feature 实例是否已与其原型分离（一般发生在实例销毁过程中）。异步回调在使用句柄前应先调用此接口判断。

**参数** ：

  * handle Feature 实例句柄。


**返回值** ：

已分离返回 true；未分离返回 false。分离后不得再调用该句柄上的任何接口。

## FeatureCreateInterface
    
    
    FeatureInterfaceHandle FeatureCreateInterface(FeatureInstanceHandle handle, VTable* vtable);

基于虚函数表创建一个 Feature 接口句柄。用于以对象接口形式向前端暴露方法。

**参数** ：

  * handle Feature 实例句柄。
  * vtable 虚函数表，详见 VTable。


**返回值** ：

成功时返回新建的 FeatureInterfaceHandle；失败时返回 NULL。

# Manager 用户数据操作

## FeatureSetManagerUserData
    
    
    void FeatureSetManagerUserData(FeatureManagerHandle handle, const char* name, void* data);

按名称向 Feature 管理器挂载用户数据。同一个 Manager 可通过不同名称挂载多个数据。

**参数** ：

  * handle Feature 管理器句柄。
  * name 用户数据名称。
  * data 用户数据指针。


## FeatureSetManagerUserDataWithFreeCallback
    
    
    void* FeatureSetManagerUserDataWithFreeCallback(FeatureManagerHandle handle,
        const char* name, void* data, ManagerUserdataFreeCallback free_cb);

按名称挂载用户数据，并注册释放回调。Manager 销毁时会调用 free_cb 清理用户数据。

**参数** ：

  * handle Feature 管理器句柄。
  * name 用户数据名称。
  * data 用户数据指针。
  * free_cb 释放回调，签名为 void (*)(void* data)。


**返回值** ：

返回旧值（若之前已绑定过同名数据），否则返回 NULL。

## FeatureManagerHasUserData
    
    
    bool FeatureManagerHasUserData(FeatureManagerHandle handle, const char* name);

判断管理器是否已绑定指定名称的用户数据。

**参数** ：

  * handle Feature 管理器句柄。
  * name 用户数据名称。


**返回值** ：

已绑定返回 true；否则返回 false。

## FeatureGetManagerUserData
    
    
    void* FeatureGetManagerUserData(FeatureManagerHandle handle, const char* name);

按名称获取管理器上绑定的用户数据。

**参数** ：

  * handle Feature 管理器句柄。
  * name 用户数据名称。


**返回值** ：

成功返回用户数据指针；未找到返回 NULL。

# 回调管理

## FeatureInvokeCallback
    
    
    bool FeatureInvokeCallback(FeatureInstanceHandle handle, FtCallbackId cid, ...);

通过回调 ID 触发一次 JS 层的回调函数。可变参数按 Feature 接口声明的类型依次传入。

**参数** ：

  * handle Feature 实例句柄。
  * cid 回调 ID。
  * ... 传给回调的可变参数。


**返回值** ：

成功返回 true；失败返回 false（例如回调 ID 已失效或实例已分离）。

## FeatureInvokeCallbackCount
    
    
    bool FeatureInvokeCallbackCount(FeatureInstanceHandle handle, FtCallbackId cid,
                                     int count, ...);

同 FeatureInvokeCallback，但显式指定参数个数。适合在参数数量动态变化的场景下使用。

**参数** ：

  * handle Feature 实例句柄。
  * cid 回调 ID。
  * count 参数个数。
  * ... 可变参数列表。


**返回值** ：

成功返回 true；失败返回 false。

## FeatureRemoveCallback
    
    
    bool FeatureRemoveCallback(FeatureInstanceHandle handle, FtCallbackId cid);

从 Feature 实例中移除指定 ID 的回调。移除后再调用 FeatureInvokeCallback 会失败。

**参数** ：

  * handle Feature 实例句柄。
  * cid 回调 ID。


**返回值** ：

成功返回 true；回调 ID 不存在返回 false。

## FeatureCheckCallbackId
    
    
    bool FeatureCheckCallbackId(FeatureInstanceHandle handle, FtCallbackId cid);

检查指定回调 ID 对应的 JS 函数是否仍然有效。

**参数** ：

  * handle Feature 实例句柄。
  * cid 回调 ID。


**返回值** ：

函数仍存在且有效返回 true；否则返回 false。

# 异步任务投递

## FeaturePost
    
    
    bool FeaturePost(FeatureInstanceHandle handle, FeatureTaskCallback task_cb, void* data);

将任务投递到 Feature 管理器绑定的事件循环执行。常用于跨线程回到主线程上操作 Feature 实例。

**参数** ：

  * handle Feature 实例句柄。
  * task_cb 任务回调，签名为 void (*)(int status, void* data)。
  * data 传递给回调的用户数据。


**返回值** ：

成功投递返回 true；失败返回 false。

**注意** ：

  * 在 task_cb 内使用 FeatureInstanceIsDetached 判断句柄是否已分离。分离后禁止继续使用该句柄。


## FeaturePostExt
    
    
    bool FeaturePostExt(FeatureInstanceHandle handle, FeatureTaskCallbackExt task_cb_ext,
                        uint64_t data);

扩展版 FeaturePost。回调签名带实例句柄，便于在回调内直接访问实例。

**参数** ：

  * handle Feature 实例句柄。
  * task_cb_ext 扩展任务回调，签名为 void (*)(int status, uint64_t data, FeatureInstanceHandle feature)。
  * data 传递给回调的 64 位用户数据。


**返回值** ：

成功返回 true；失败返回 false。

**注意** ：

  * 在回调内同样需要 FeatureInstanceIsDetached 检查实例状态。


# Promise 管理

Feature 框架同时支持 Callback 和 Promise 两种异步模型，二者在 Feature 实现内部使用相同的 FtPromiseId 引用。以下接口用于完成异步调用的 resolve 或 reject。

## FeaturePromiseResolve
    
    
    bool FeaturePromiseResolve(FeatureInstanceHandle handle, FtPromiseId pid, ...);

以可变参数的形式 resolve Promise。仅支持传递一个参数。

**参数** ：

  * handle Feature 实例句柄。
  * pid Promise ID。
  * ... 传递的参数。


**返回值** ：

成功返回 true；失败返回 false。

## FeaturePromiseReject
    
    
    bool FeaturePromiseReject(FeatureInstanceHandle handle, FtPromiseId pid,
                              int code, const char* msg);

以错误码与错误消息 reject Promise。

**参数** ：

  * handle Feature 实例句柄。
  * pid Promise ID。
  * code 错误码。
  * msg 错误消息。


**返回值** ：

成功返回 true；失败返回 false。

## FeatureGetPromiseType
    
    
    enum FeaturePromiseType FeatureGetPromiseType(FeatureInstanceHandle handle, FtPromiseId pid);

获取当前异步调用使用的模型类型。Feature 实现可据此选择调用 Callback 或 Promise 对应接口。

**参数** ：

  * handle Feature 实例句柄。
  * pid Promise ID。


**返回值** ：

返回枚举 FeaturePromiseType：

  * FEATURE_PROMISE_TYPE_INVALID：无效（通常表示 Promise 已失效）
  * FEATURE_PROMISE_TYPE_PROMISE：Promise 模型
  * FEATURE_PROMISE_TYPE_CALLBACKS：Callback 模型


# Promise 类型化 Resolve

以下一组接口按类型特化 resolve Promise，避免使用可变参数带来的类型不确定性。所有接口成功时返回 FT_TRUE，失败时返回 FT_FALSE。

## FeatureFtStringPromiseResolve
    
    
    FtBool FeatureFtStringPromiseResolve(FeatureInstanceHandle handle, FtPromiseId pid, FtString val);

以字符串 resolve Promise。

**参数** ：

  * handle Feature 实例句柄。
  * pid Promise ID。
  * val 字符串结果。


**返回值** ：

成功时返回 FT_TRUE，失败时返回 FT_FALSE。

## FeatureFtIntPromiseResolve
    
    
    FtBool FeatureFtIntPromiseResolve(FeatureInstanceHandle handle, FtPromiseId pid, FtInt val);

以 FtInt（int32）resolve Promise。

**参数** ：

  * handle Feature 实例句柄。
  * pid Promise ID。
  * val int32 结果。


**返回值** ：

成功时返回 FT_TRUE，失败时返回 FT_FALSE。

## FeatureFtUint32PromiseResolve
    
    
    FtBool FeatureFtUint32PromiseResolve(FeatureInstanceHandle handle, FtPromiseId pid, FtUint32 val);

以 FtUint32 resolve Promise。

**参数** ：

  * handle Feature 实例句柄。
  * pid Promise ID。
  * val uint32 结果。


**返回值** ：

成功时返回 FT_TRUE，失败时返回 FT_FALSE。

## FeatureFtInt8PromiseResolve
    
    
    FtBool FeatureFtInt8PromiseResolve(FeatureInstanceHandle handle, FtPromiseId pid, FtInt8 val);

以 FtInt8 resolve Promise。

**参数** ：

  * handle Feature 实例句柄。
  * pid Promise ID。
  * val int8 结果。


**返回值** ：

成功时返回 FT_TRUE，失败时返回 FT_FALSE。

## FeatureFtUint8PromiseResolve
    
    
    FtBool FeatureFtUint8PromiseResolve(FeatureInstanceHandle handle, FtPromiseId pid, FtUint8 val);

以 FtUint8 resolve Promise。

**参数** ：

  * handle Feature 实例句柄。
  * pid Promise ID。
  * val uint8 结果。


**返回值** ：

成功时返回 FT_TRUE，失败时返回 FT_FALSE。

## FeatureFtInt16PromiseResolve
    
    
    FtBool FeatureFtInt16PromiseResolve(FeatureInstanceHandle handle, FtPromiseId pid, FtInt16 val);

以 FtInt16 resolve Promise。

**参数** ：

  * handle Feature 实例句柄。
  * pid Promise ID。
  * val int16 结果。


**返回值** ：

成功时返回 FT_TRUE，失败时返回 FT_FALSE。

## FeatureFtUint16PromiseResolve
    
    
    FtBool FeatureFtUint16PromiseResolve(FeatureInstanceHandle handle, FtPromiseId pid, FtUint16 val);

以 FtUint16 resolve Promise。

**参数** ：

  * handle Feature 实例句柄。
  * pid Promise ID。
  * val uint16 结果。


**返回值** ：

成功时返回 FT_TRUE，失败时返回 FT_FALSE。

## FeatureFtInt64PromiseResolve
    
    
    FtBool FeatureFtInt64PromiseResolve(FeatureInstanceHandle handle, FtPromiseId pid, FtInt64 val);

以 FtInt64 resolve Promise。

**参数** ：

  * handle Feature 实例句柄。
  * pid Promise ID。
  * val int64 结果。


**返回值** ：

成功时返回 FT_TRUE，失败时返回 FT_FALSE。

## FeatureFtUint64PromiseResolve
    
    
    FtBool FeatureFtUint64PromiseResolve(FeatureInstanceHandle handle, FtPromiseId pid, FtUint64 val);

以 FtUint64 resolve Promise。

**参数** ：

  * handle Feature 实例句柄。
  * pid Promise ID。
  * val uint64 结果。


**返回值** ：

成功时返回 FT_TRUE，失败时返回 FT_FALSE。

## FeatureFtFloatPromiseResolve
    
    
    FtBool FeatureFtFloatPromiseResolve(FeatureInstanceHandle handle, FtPromiseId pid, FtFloat val);

以 FtFloat（float）resolve Promise。

**参数** ：

  * handle Feature 实例句柄。
  * pid Promise ID。
  * val float 结果。


**返回值** ：

成功时返回 FT_TRUE，失败时返回 FT_FALSE。

## FeatureFtDoublePromiseResolve
    
    
    FtBool FeatureFtDoublePromiseResolve(FeatureInstanceHandle handle, FtPromiseId pid, FtDouble val);

以 FtDouble（double）resolve Promise。

**参数** ：

  * handle Feature 实例句柄。
  * pid Promise ID。
  * val double 结果。


**返回值** ：

成功时返回 FT_TRUE，失败时返回 FT_FALSE。

## FeatureFtBoolPromiseResolve
    
    
    FtBool FeatureFtBoolPromiseResolve(FeatureInstanceHandle handle, FtPromiseId pid, FtBool val);

以 FtBool resolve Promise。

**参数** ：

  * handle Feature 实例句柄。
  * pid Promise ID。
  * val bool 结果。


**返回值** ：

成功时返回 FT_TRUE，失败时返回 FT_FALSE。

## FeatureFtAnyPromiseResolve
    
    
    FtBool FeatureFtAnyPromiseResolve(FeatureInstanceHandle handle, FtPromiseId pid, FtAny val);

以 FtAny（ft_value_t*）resolve Promise。可用于返回任意类型结果。

**参数** ：

  * handle Feature 实例句柄。
  * pid Promise ID。
  * val ft_value_t* 结果。


**返回值** ：

成功时返回 FT_TRUE，失败时返回 FT_FALSE。

## FeatureFtArrayPromiseResolve
    
    
    FtBool FeatureFtArrayPromiseResolve(FeatureInstanceHandle handle, FtPromiseId pid, FtArray* val);

以 FtArray* resolve Promise。

**参数** ：

  * handle Feature 实例句柄。
  * pid Promise ID。
  * val 数组结果。


**返回值** ：

成功时返回 FT_TRUE，失败时返回 FT_FALSE。

# 事件管理

## FeatureGetEventId
    
    
    FtEventId FeatureGetEventId(FeatureInstanceHandle handle, const char* name);

根据事件名称查询对应的事件 ID。

**参数** ：

  * handle Feature 实例句柄。
  * name 事件名称。


**返回值** ：

成功时返回有效的事件 ID（正整数）；事件不存在时返回 ≤ 0。

## FeatureGetEventName
    
    
    const char* FeatureGetEventName(FeatureInstanceHandle handle, FtEventId eid);

根据事件 ID 获取事件名称。

**参数** ：

  * handle Feature 实例句柄。
  * eid 事件 ID。


**返回值** ：

成功时返回事件名字符串；不存在时返回 NULL。

## FeatureEmitEvent
    
    
    bool FeatureEmitEvent(FeatureInstanceHandle handle, FtEventId eid, ...);

按事件 ID 触发事件，支持向事件订阅者传递可变参数。

**参数** ：

  * handle Feature 实例句柄。
  * eid 事件 ID。
  * ... 事件携带的数据，类型需与 Feature 接口声明一致。


**返回值** ：

成功触发返回 true；失败返回 false（例如事件不存在、实例已分离）。

## FeatureEmitEventByName
    
    
    bool FeatureEmitEventByName(FeatureInstanceHandle handle, const char* name, ...);

按事件名称触发事件。内部会先通过 FeatureGetEventId 查询 ID 再触发。

**参数** ：

  * handle Feature 实例句柄。
  * name 事件名称。
  * ... 事件携带的数据。


**返回值** ：

成功返回 true；失败返回 false。

## FeatureSetEventChangeListener
    
    
    void FeatureSetEventChangeListener(FeatureInstanceHandle handle,
                                        FeatureEventChangeListener listener);

为 Feature 实例设置事件变更监听器。当事件订阅者的数量发生变化时（有订阅者加入或离开），会触发回调。

**参数** ：

  * handle Feature 实例句柄。
  * listener 事件变更监听器，签名为 void (*)(FeatureInstanceHandle, FtEventId, FeatureEventStatus)。
    * 状态为 FEATURE_EVENT_ADDED 表示添加订阅
    * 状态为 FEATURE_EVENT_REMOVED 表示移除订阅


## FeatureGetEventCallbackCount
    
    
    int FeatureGetEventCallbackCount(FeatureInstanceHandle handle, FtEventId eid);

按事件 ID 查询当前注册的订阅者数量。可用于在无订阅者时跳过事件触发以节省开销。

**参数** ：

  * handle Feature 实例句柄。
  * eid 事件 ID。


**返回值** ：

返回订阅者数量；不存在或失败时返回 0。

## FeatureGetEventCallbackCountByName
    
    
    static inline int FeatureGetEventCallbackCountByName(FeatureInstanceHandle handle, const char* name);

按事件名称查询当前注册的订阅者数量。内部通过 FeatureGetEventId \+ FeatureGetEventCallbackCount 实现。

**参数** ：

  * handle Feature 实例句柄。
  * name 事件名称。


**返回值** ：

返回订阅者数量；不存在时返回 0。

# 异步任务 Worker

Worker 机制用于将耗时任务放入后台执行，执行完毕后回到主线程通知结果。适用于文件 IO、计算密集等场景。

## FeatureCreateWorker
    
    
    FeatureWorkerHandle FeatureCreateWorker(FeatureInstanceHandle handle, FtPromiseId pid,
        size_t buf_size,
        void (*do_work)(FeatureWorkerHandle),
        void (*do_after_worker)(FeatureWorkerHandle),
        void (*free)(void*));

创建一个 Worker 对象，准备投递到后台执行。

**参数** ：

  * handle Feature 实例句柄。
  * pid 关联的 Promise ID，用于 Worker 完成后触发 resolve/reject。
  * buf_size Worker 私有缓冲区大小，可用来在两个回调间传递数据。
  * do_work 后台执行函数，在 worker 线程中运行。
  * do_after_worker 完成回调，在主线程运行，通常在此调用 FeatureWorkerResolve 或 FeatureWorkerReject。
  * free 资源释放函数，Worker 销毁时调用。


**返回值** ：

成功时返回 FeatureWorkerHandle；失败返回 NULL。

## FeatureWorkerCommit
    
    
    bool FeatureWorkerCommit(FeatureInstanceHandle handle, FeatureWorkerHandle hworker);

提交 Worker 到后台开始执行。

**参数** ：

  * handle Feature 实例句柄。
  * hworker Worker 句柄。


**返回值** ：

提交成功返回 true；失败返回 false。

## FeatureWorkerResolve
    
    
    void FeatureWorkerResolve(FeatureInstanceHandle handle, FeatureWorkerHandle hworker,
                              FeatureWorkerResult result);

通知 Worker 以成功结果完成，触发关联 Promise 的 resolve。通常在 do_after_worker 回调内调用。

**参数** ：

  * handle Feature 实例句柄。
  * hworker Worker 句柄。
  * result 执行结果，详见 FeatureWorkerResult。


## FeatureWorkerReject
    
    
    void FeatureWorkerReject(FeatureInstanceHandle handle, FeatureWorkerHandle hworker,
                             int errcode, const char* err_msg);

通知 Worker 以失败结果完成，触发关联 Promise 的 reject。

**参数** ：

  * handle Feature 实例句柄。
  * hworker Worker 句柄。
  * errcode 错误码。
  * err_msg 错误消息。


## FeatureWorkerIsValid
    
    
    bool FeatureWorkerIsValid(FeatureInstanceHandle handle, FeatureWorkerHandle hworker);

判断 Worker 是否仍然有效。

**参数** ：

  * handle Feature 实例句柄。
  * hworker Worker 句柄。


**返回值** ：

有效返回 true；失效或已完成返回 false。

## FeatureWorkerGetState
    
    
    int FeatureWorkerGetState(FeatureWorkerHandle hworker);

获取 Worker 当前状态。

**参数** ：

  * hworker Worker 句柄。


**返回值** ：

返回 FeatureWorkerState 枚举值：

  * FEATURE_WORKER_PENDING：等待中
  * FEATURE_WORKER_RUNNING：运行中
  * FEATURE_WORKER_INVALID：无效
  * FEATURE_WORKER_RESOLVED：已 resolve
  * FEATURE_WORKER_REJECTED：已 reject
  * FEATURE_WORKER_FINISHED：已完成


## FeatureWorkerCancel
    
    
    int FeatureWorkerCancel(FeatureInstanceHandle handle, FeatureWorkerHandle hworker);

尝试取消 Worker 的执行。处于 pending 状态的任务无法立即取消。

**参数** ：

  * handle Feature 实例句柄。
  * hworker Worker 句柄。


**返回值** ：

返回 FeatureWorkerCancelResult 枚举值：

  * FeatureWorkerCancelSuccess：成功取消
  * FeatureWorkerCancelPending：Worker 处于 pending，未能取消
  * FeatureWorkerCancelInvalid：Worker 无效
  * FeatureWorkerCancelUnknownError：未知错误


# JSON 对象

## FeatureNewJsonObject
    
    
    FtJsonObject FeatureNewJsonObject(const char* str);

基于给定字符串创建 JSON 对象。

**参数** ：

  * str JSON 字符串。


**返回值** ：

成功返回 FtJsonObject；失败返回 NULL。

## FeatureAllocJsonObject
    
    
    FtJsonObject FeatureAllocJsonObject(size_t str_len);

按指定字符串长度分配 JSON 对象空间（不初始化内容）。

**参数** ：

  * str_len 字符串长度。


**返回值** ：

成功返回 FtJsonObject；失败返回 NULL。

## FeatureGetJsonString
    
    
    const char* FeatureGetJsonString(const FtJsonObject json_obj);

获取 JSON 对象对应的字符串视图。

**参数** ：

  * json_obj JSON 对象。


**返回值** ：

成功返回字符串指针；失败返回 NULL。返回指针由框架管理，不要手动释放。

# Feature 注册

## FeatureRegisterFeatures
    
    
    bool FeatureRegisterFeatures(FeatureRegistryHandle handle,
                                  const FeatureRegistryTableHandle regTable);

将一组 Feature 批量注册到 Feature 注册表中。通常在模块初始化时调用。

**参数** ：

  * handle Feature 注册表句柄。
  * regTable 注册条目表，详见 FeatureRegistryTable。


**返回值** ：

全部注册成功返回 true；任一注册失败返回 false。

---

## Feature Main Export API

> 路径: 应用框架 > Feature 框架 > Feature Main Export API
> 来源: [https://doc.openvela.com/document?id=1171&language=cn&version=dev](https://doc.openvela.com/document?id=1171&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/feature/feature_framework_main_export.md>) | 简体中文 ]

# Feature Main Export API

Feature 管理器（Feature Manager）的生命周期管理与全局配置接口。主要用于快应用框架初始化、绑定运行时事件循环、注册 Feature 以及管理权限。

头文件：#include <feature_main_exports.h>

# openvela 实现说明

  * **使用场景** ：这组 API 主要由快应用框架实现者（Runtime 整合层）使用，Feature 插件开发者一般不直接调用
  * **与 Feature 管理器的关系** ：一个 Feature 管理器对应一个独立的快应用实例，通过 FeatureCreateManager 创建，使用结束后必须调用 FeatureFreeManager 释放
  * **事件循环集成** ：通过 FeatureSetUVLoop 绑定 libuv 事件循环，实现异步任务的调度。必须在 FeatureCreateInstance 之前完成绑定
  * **权限回调机制** ：通过 FeatureSetPermissionsCallback 注册统一的权限检查入口，所有需要权限的 Feature 调用都会触发回调，调用方需显式 Grant 或 Reject


# 快应用框架示例代码
    
    
    #ifdef CONFIG_FEATURE_FRAMEWORK
        FeatureManagerCreateInfo ft_info;
        ft_info.raw_ctx = (FeatureRawContextHandle)(qrt->env.ctx);
        ft_info.release_cb = nullptr;
        ft_info.manager_type = FEATURE_MANAGER_JS;
        ft_info.package_name = app->packageName();
        qrt->pFeatureMgr = FeatureCreateManager(&ft_info);
        FeatureSetArgsErrorCb(qrt->pFeatureMgr, on_feature_args_error, qrt);
        FeatureSetManagerUserData(qrt->pFeatureMgr, "app", app);
        FeatureSetUVLoop(qrt->pFeatureMgr, qrt->loop);
    #endif

# 管理器生命周期

## FeatureCreateManager
    
    
    FeatureManagerHandle FeatureCreateManager(FeatureManagerCreateInfo* pinfo);

根据给定的配置信息创建一个 Feature 管理器实例。

**参数** ：

  * pinfo Feature 管理器的创建配置，包含原始运行时上下文、释放回调、管理器类型和快应用包名。详见 FeatureManagerCreateInfo。


**返回值** ：

成功时返回有效的 FeatureManagerHandle 句柄；失败时返回 NULL。

## FeatureFreeManager
    
    
    void FeatureFreeManager(FeatureManagerHandle handle);

释放 Feature 管理器。释放前应先调用 FeatureUnsetUVLoop 解绑事件循环。

**参数** ：

  * handle 待释放的 Feature 管理器句柄。


## FeatureUninit
    
    
    void FeatureUninit(FeatureManagerHandle handle);

对 Feature 管理器执行反初始化操作。清理内部状态但不释放句柄本身。

**参数** ：

  * handle Feature 管理器句柄。


# 全局配置

## FeatureSetArgsErrorCb
    
    
    void FeatureSetArgsErrorCb(FeatureManagerHandle handle, ArgsErrorCb cb, void* data);

为 Feature 管理器注册参数错误回调。当任一 Feature 调用的参数类型不匹配时，会触发该回调。

**参数** ：

  * handle Feature 管理器句柄。
  * cb 参数错误回调，签名为 bool (*)(void* data, ArgsErrorInfo* args_info)。
  * data 传递给回调的用户数据。


## FeatureSetPackageVersion
    
    
    void FeatureSetPackageVersion(FeatureManagerHandle handle, const char* package_version);

设置当前管理器对应快应用的包版本号。版本号可通过 FeatureGetPackageVersion 查询。

**参数** ：

  * handle Feature 管理器句柄。
  * package_version 快应用版本号字符串。


## FeatureSetUVLoop
    
    
    void FeatureSetUVLoop(FeatureManagerHandle handle, uv_loop_t* loop);

为 Feature 管理器绑定 libuv 事件循环。所有 FeaturePost、FeatureWorker* 等异步任务都会在该 loop 上调度。

**参数** ：

  * handle Feature 管理器句柄。
  * loop libuv 事件循环指针。


**注意** ：

  * 必须在 FeatureCreateInstance 之前调用。
  * 同一个 uv_loop_t 可以被多个 Feature 管理器共享，但通常建议每个快应用实例独占一个 loop。


## FeatureUnsetUVLoop
    
    
    void FeatureUnsetUVLoop(FeatureManagerHandle handle);

解绑 Feature 管理器的 libuv 事件循环。解绑后所有未完成的异步任务将失效。

**参数** ：

  * handle Feature 管理器句柄。


**注意** ：

  * 必须在 FeatureFreeManager 之前调用。


# 运行时访问

## FeatureManagerGetContext
    
    
    ft_context_ref FeatureManagerGetContext(FeatureManagerHandle handle);

从 Feature 管理器获取对应的 Feature 上下文引用，可用于 ft_value_t 相关操作。

**参数** ：

  * handle Feature 管理器句柄。


**返回值** ：

返回 ft_context_ref，失败时返回 NULL。

## FeatureSetManagerUserData
    
    
    void FeatureSetManagerUserData(FeatureManagerHandle handle, const char* name, void* data);

按名称在 Feature 管理器上挂载用户数据。可用于在各个 Feature 实例之间共享信息。

**参数** ：

  * handle Feature 管理器句柄。
  * name 用户数据名称（键）。
  * data 用户数据指针。


## FeatureHasFeature
    
    
    bool FeatureHasFeature(FeatureManagerHandle handle, FtString feature_method);

判断给定名称的 Feature 是否已注册到当前管理器。

**参数** ：

  * handle Feature 管理器句柄。
  * feature_method 要查询的 Feature 名称。


**返回值** ：

Feature 已注册时返回 true，否则返回 false。

# Feature 操作

## FeatureRequire
    
    
    ft_value_t FeatureRequire(FeatureManagerHandle handle,
                              ft_value_t binding_obj, const char* name);

按名称向 Feature 管理器请求一个 Feature 实例。等价于 JS 层的 require('@system.xxx')。

**参数** ：

  * handle Feature 管理器句柄。
  * binding_obj 绑定对象（通常是 Feature 所在的 JS 全局对象）。
  * name Feature 名称。


**返回值** ：

返回封装了 Feature 实例的 ft_value_t。失败时返回 undefined 类型的 ft_value_t。

**注意** ：

  * 每次 FeatureRequire 都会产生一个独立的 Feature 实例。


## FeatureFindFeature
    
    
    ft_value_t FeatureFindFeature(FeatureManagerHandle handle, const char* name);

查找已创建的 Feature 实例而不会新建实例。

**参数** ：

  * handle Feature 管理器句柄。
  * name Feature 名称。


**返回值** ：

返回 Feature 实例对应的 ft_value_t；若未找到，返回 undefined。

## FeatureCreateFeature
    
    
    ft_value_t FeatureCreateFeature(FeatureManagerHandle handle,
                                    ft_value_t prototype, ft_value_t binding_obj);

根据原型创建一个 Feature 实例。用于需要直接操作原型对象的高级场景。

**参数** ：

  * handle Feature 管理器句柄。
  * prototype Feature 原型对象。
  * binding_obj 绑定对象。


**返回值** ：

成功时返回新建 Feature 实例的 ft_value_t；失败时返回 undefined。

# 内存诊断

## FeatureDumpMemory
    
    
    void FeatureDumpMemory(FeatureManagerHandle feature_manager,
                           FeatureMemoryDump* dump, void* userdata);

回调式的 Feature 框架内存占用诊断接口，便于上层整合自定义的内存统计能力。

**参数** ：

  * feature_manager Feature 管理器句柄。
  * dump 内存诊断回调结构体，包含 count、count_meta、sub 三类回调，详见 FeatureMemoryDump。
  * userdata 透传给各回调的用户数据。


# 权限管理

## FeatureSetPermissionsCallback
    
    
    void FeatureSetPermissionsCallback(FeatureManagerHandle hmanager,
                                       FeaturePermissionsCb cb, void* data);

注册权限检查回调。当某个 Feature API 需要权限时，框架会触发此回调，由业务层决定授予或拒绝。

**参数** ：

  * hmanager Feature 管理器句柄。
  * cb 权限检查回调，签名为 void (*)(FeaturePermissionsHandle, const FeaturePermissionsInfo*, void*)。
  * data 透传给回调的用户数据。


**注意** ：

  * 回调内必须调用 FeatureGrantPermissions 或 FeatureRejectPermissions 之一，否则对应的 Feature 调用会一直挂起。


## FeatureGrantPermissions
    
    
    void FeatureGrantPermissions(FeatureManagerHandle hmanager,
                                 FeaturePermissionsHandle handle);

授予一次权限请求。调用后，对应的 Feature API 调用会继续执行。

**参数** ：

  * hmanager Feature 管理器句柄。
  * handle 权限请求句柄（由权限回调传入）。


## FeatureRejectPermissions
    
    
    void FeatureRejectPermissions(FeatureManagerHandle hmanager,
                                  FeaturePermissionsHandle handle,
                                  FeaturePermsRejectReason reason);

拒绝一次权限请求。调用后，对应的 Feature API 调用会返回权限错误。

**参数** ：

  * hmanager Feature 管理器句柄。
  * handle 权限请求句柄。
  * reason 拒绝原因，详见 FeaturePermsRejectReason：
    * FEATURE_PERMS_DENIED：权限被拒绝
    * FEATURE_PERMS_ERROR：权限检查错误
    * FEATURE_PERMS_NO_BG：不允许后台调用

---

## Feature QJS Export API

> 路径: 应用框架 > Feature 框架 > Feature QJS Export API
> 来源: [https://doc.openvela.com/document?id=1172&language=cn&version=dev](https://doc.openvela.com/document?id=1172&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/feature/feature_framework_qjs_export.md>) | 简体中文 ]

# Feature QJS Export API

Feature 框架与 QuickJS 运行时之间的互操作接口。提供 ft_value_t 与 JSValue 相互转换的能力，仅在 QuickJS 前端场景下可用。

头文件：#include <feature_qjs_exports.h>

# openvela 实现说明

  * **仅适用于 QuickJS** ：本组接口只能在 QuickJS 运行时下调用，WAMR 等其他前端请勿使用
  * **依赖 QuickJS 头文件** ：feature_qjs_exports.h 内部包含 quickjs/quickjs.h，需要 QuickJS 对外开放的头文件可见
  * **典型用途** ：当 Feature 实现需要访问 QuickJS 原生 API（例如使用 QuickJS 专有 API 创建对象）时，通过本组接口与 Feature 框架的统一 ft_value_t 类型互转
  * **不建议业务代码广泛使用** ：绑定到 QuickJS 后将失去跨运行时的兼容性，应优先使用 feature_context.h 中的通用 API


# JSValue 与 ft_value_t 互转

## ft_from_jsvalue
    
    
    ft_value_t ft_from_jsvalue(ft_context_ref rt_ctx, JSValue val);

将 QuickJS 的 JSValue 转换为 Feature 框架的 ft_value_t。

**参数** ：

  * rt_ctx 当前 Feature 上下文引用。
  * val 要转换的 QuickJS JSValue 对象。


**返回值** ：

返回对应的 ft_value_t 对象。返回值的生命周期由 Feature 框架管理。

**注意** ：

  * 调用方应确保传入的 JSValue 在 rt_ctx 对应的 QuickJS Runtime 中有效
  * 若返回的 ft_value_t 被保留到后续异步上下文，需使用 feature_context.h 中的相关接口控制其生命周期


## ft_to_jsvalue
    
    
    JSValue ft_to_jsvalue(ft_context_ref rt_ctx, ft_value_t val);

将 Feature 框架的 ft_value_t 转换为 QuickJS 的 JSValue。

**参数** ：

  * rt_ctx 当前 Feature 上下文引用。
  * val 要转换的 ft_value_t 对象。


**返回值** ：

返回对应的 JSValue 对象。该 JSValue 遵循 QuickJS 自身的引用计数规则，调用方负责通过 JS_FreeValue 在合适时机释放。

**注意** ：

  * 本接口会在 QuickJS Runtime 内分配对应的 JS 对象，返回前引用计数已加 1。
  * 使用完成后必须调用 JS_FreeValue 释放，否则会导致 QuickJS 端的内存泄漏。


## ft_ctx_to_js_ctx
    
    
    JSContext* ft_ctx_to_js_ctx(ft_context_ref rt_ctx);

从 Feature 上下文引用中获取底层的 QuickJS JSContext*。

**参数** ：

  * rt_ctx 当前 Feature 上下文引用。


**返回值** ：

成功时返回对应的 JSContext*，可直接作为 QuickJS 原生 API 的参数使用。

**注意** ：

  * 返回的 JSContext* 生命周期由 Feature 框架管理，**不要** 手动调用 JS_FreeContext 释放。
  * 仅在 QuickJS 前端下返回有效指针；其他前端下的行为未定义。

---

## Feature Trace API

> 路径: 应用框架 > Feature 框架 > Feature Trace API
> 来源: [https://doc.openvela.com/document?id=1173&language=cn&version=dev](https://doc.openvela.com/document?id=1173&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/feature/feature_framework_trace.md>) | 简体中文 ]

# Feature Trace API

Feature 框架中用于性能追踪（trace）打点的宏定义。这些宏在启用时调用 NuttX 的 sched_note 接口记录事件，未启用时展开为空操作。

头文件：#include <feature_trace.h>

# openvela 实现说明

  * **条件编译** ：所有 trace 宏由 CONFIG_FEATURE_USE_SCHED_NOTE 配置项控制
    * 启用时，展开为 sched_note_* 系列调用，使用 NOTE_TAG_ALWAYS 标签
    * 未启用时，展开为空操作（不产生任何 CPU / 内存开销），适合生产环境编译
  * **依赖** ：依赖 NuttX 内核的 sched_note 机制，需同时启用 CONFIG_SCHED_INSTRUMENTATION 相关配置
  * **使用场景** ：在 Feature 接口实现或 JS-Native 边界处打点，配合 openvela 的 trace 分析工具（如 SystemView、Perfetto）可视化性能瓶颈
  * **成对使用** ：FEATURE_NOTE_BEGIN* / FEATURE_NOTE_END* 必须成对调用，否则 trace 事件配对会失败


# 基础打点宏

## FEATURE_NOTE_PRINTF
    
    
    FEATURE_NOTE_PRINTF(format, ...)

以格式化字符串打点，类似 printf。用于记录自定义调试信息。

**参数** ：

  * format 格式化字符串。
  * ... 可变参数列表，与 format 占位符对应。


## FEATURE_NOTE_BEGIN
    
    
    FEATURE_NOTE_BEGIN()

标记一段代码执行的开始（无附加信息）。必须与 FEATURE_NOTE_END 成对使用。

## FEATURE_NOTE_END
    
    
    FEATURE_NOTE_END()

标记一段代码执行的结束。与最近一次 FEATURE_NOTE_BEGIN 配对。

# 带标签的打点宏

## FEATURE_NOTE_BEGIN_STR
    
    
    FEATURE_NOTE_BEGIN_STR(str)

带字符串标签的起始打点，用于标识代码段的语义。

**参数** ：

  * str 事件标签字符串，该字符串需在整个 trace 事件期间保持有效。


## FEATURE_NOTE_END_STR
    
    
    FEATURE_NOTE_END_STR(str)

带字符串标签的结束打点，与对应 FEATURE_NOTE_BEGIN_STR 的标签一致。

**参数** ：

  * str 事件标签字符串（必须与起始打点的标签一致）。


## FEATURE_NOTE_MARK
    
    
    FEATURE_NOTE_MARK(str)

打一个即时标记点，不需要配对。用于在时间线上标记单一事件。

**参数** ：

  * str 标记标签字符串。


# 作用域打点宏

## FEATURE_NOTE_BEGIN_LOCAL / FEATURE_NOTE_END_LOCAL
    
    
    FEATURE_NOTE_BEGIN_LOCAL(str)
        // 被追踪的代码
    FEATURE_NOTE_END_LOCAL()

带局部变量作用域的起止打点。内部通过局部变量保存标签，避免上层代码传参复杂。

**参数** ：

  * str 事件标签字符串。


**使用示例** ：  

    
    
    void my_feature_func(void)
    {
        FEATURE_NOTE_BEGIN_LOCAL("my_feature_func");
        // ... 业务逻辑 ...
        FEATURE_NOTE_END_LOCAL();
    }

**注意** ：

  * FEATURE_NOTE_BEGIN_LOCAL 与 FEATURE_NOTE_END_LOCAL 必须在同一作用域内成对使用，宏内部使用 do { ... } while(0) 模式封装，依赖编译器能够识别作用域。
  * 宏内部会引入名为 note_temp_str 的局部变量，同一作用域内不要使用该变量名。

---

## 快应用框架 API 总览

> 路径: 应用框架 > 快应用（QuickApp） > 快应用框架 API 总览
> 来源: [https://doc.openvela.com/document?id=1175&language=cn&version=dev](https://doc.openvela.com/document?id=1175&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/quickapp/index.md>) | 简体中文 ]

# 快应用框架

openvela 快应用（QuickApp）框架为开发者提供轻量级的应用运行时环境，基于快应用联盟标准实现，适配实时操作系统（RTOS）场景，支持低内存消耗下的高效执行。

  * **[基础接口](</document?id=1176&version=dev&language=cn>)** — 快应用运行时的基础 API

---

## 快应用框架简介

> 路径: 应用框架 > 快应用（QuickApp） > 快应用框架简介
> 来源: [https://doc.openvela.com/document?id=1176&language=cn&version=dev](https://doc.openvela.com/document?id=1176&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/quickapp/basic.md>) | 简体中文 ]

# 快应用框架简介

openvela 快应用（QuickApp）框架（以下简称"应用框架"），是 openvela 上的[快应用](<https://doc.quickapp.cn/>)运行时实现。相较于手机运行时，openvela 快应用框架具有如下特点：

  * 遵循快应用联盟标准，针对 openvela 系统重新实现，部分特性和功能有所裁剪。
  * 适配实时操作系统（RTOS），注重运行时性能，在低内存消耗下具有较高的执行性能。
  * 易于开发和部署，有效缩短应用开发周期。


本文档介绍应用框架的整体设计、实现思路和技术要点，不聚焦应用开发本身。

# 相关文档

  * [小米 openvela 快应用开发手册](<https://iot.mi.com/vela/quickapp/zh/content/intro.html>) — 面向应用开发者的完整开发指南
  * [Feature 框架 API](</document?id=1166&version=dev&language=cn>) — 快应用的 Native 扩展 API（JS 与 C/C++ 互调）


# 编译配置

应用框架本身的配置项不多，但依赖项较多。依赖项中渲染器的依赖较多，具体配置请参考图形组提供的文档。

## 主要配置
    
    
    CONFIG_QUICKAPP_VAPP=y                      # 快应用主配置
    CONFIG_QUICKAPP_VAPP_XMS=y                  # 快应用 xms 集成版，依赖 xms 服务框架
    CONFIG_QUICKAPP_LOG_LEVEL=1                 # log 等级，默认 INFO
    CONFIG_QUICKAPP_MICRO_FRAMEWORK_MODE=y      # 微框架
    CONFIG_QUICKAPP_PRIORITY=100                # 优先级
    CONFIG_HAP_APP_PATH="/data"                 # rpk 安装路径
    CONFIG_QUICKAPP_THREADSTACKSIZE=1048576     # JS 线程栈大小
    CONFIG_QUICKAPP_JSSTACKSIZE=524288          # JS 引擎栈大小
    CONFIG_QUICKAPP_JSHEAPSIZE=4194304          # JS 引擎堆内存限制，手表设备默认 4MB，依据应用复杂度调整
    CONFIG_CURL=y                               # 启用 curl 支持，框架网络 feature 需要开启 curl
    CONFIG_QUICKAPP_RPK_DIR="/resource/package" # ams 应用安装路径
    CONFIG_QUICKAPP_BYTECODE_OPTIMIZATION=y     # QuickJS 字节码优化（字符串合并）
    CONFIG_QUICKAPP_FOLME_ANIMENGINE_ADAPTER=n  # folme 动效引擎
    CONFIG_WIDGET_IMAGE_USE_CACHE_MANAGER=y     # 启用 widget image cache manager
    
    # 字体相关配置
    CONFIG_FONT_DEFAULT_NORMAL_NAME="MiSansW_Regular"
    CONFIG_FONT_DEFAULT_BOLD_NAME="MiSansW_Demibold"
    CONFIG_FONT_DEFAULT_SIZE=30
    CONFIG_PROMPT_TOAST_FONT_SIZE=24
    CONFIG_PROMPT_DIALOG_TITLE_FONT_SIZE=36
    CONFIG_PROMPT_DIALOG_MSG_FONT_SIZE=34

## 调试配置
    
    
    CONFIG_DOM_TRACE_ENABLE=n                   # vdom 树打印
    CONFIG_JS_USE_SCHED_NOTE=n                  # 框架启动 trace
    CONFIG_QUICKAPP_MEMORY_STATUS=n             # 框架 JS 引擎内存信息打印
    CONFIG_WIDGET_LOG_ENABLE=y                  # LVGL widget log
    CONFIG_WIDGET_LOG_LEVEL=1                   # widget log level，默认 warning
    CONFIG_WIDGET_ASSERT_ENABLE=n               # widget assert
    CONFIG_WIDGET_TRACE_ENABLE=n                # widget trace check
    CONFIG_WIDGET_PERF_ENABLE=n                 # widget performance monitor
    CONFIG_WIDGET_DUMP_TREE_ENABLE=n            # dump LVGL widget tree
    CONFIG_WIDGET_DUMP_TREE_IN_LAYOUT=n         # dump widget tree in layout task
    CONFIG_WIDGET_SHOW_YOGA_NODE_ENABLE=n       # widget show yoga node
    CONFIG_WIDGET_DEBUG_DRAW_OUTLINE=n          # widget draw outline for debug
    CONFIG_CSS_ATTR_LIST_ENABLE=n               # 启用 widget get css/attr function

## 依赖项
    
    
    CONFIG_LIBUV=y
    CONFIG_LVGL_EXTENSION=y
    CONFIG_LIBUV_EXTENSION=y
    CONFIG_LVX_USE_FONT_MANAGER=y
    CONFIG_LIB_YOGA=y
    CONFIG_PROTOBUF_C=y
    CONFIG_LIB_PNG=y
    CONFIG_LV_USE_LIBPNG=y
    CONFIG_LV_USE_NUTTX_LIBUV=y
    CONFIG_USE_QUICKJS=y

---

## 工具库 API 总览

> 路径: 应用框架 > 工具库（Utils） > 工具库 API 总览
> 来源: [https://doc.openvela.com/document?id=1178&language=cn&version=dev](https://doc.openvela.com/document?id=1178&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/utils/index.md>) | 简体中文 ]

# Utils

openvela 工具库提供应用开发中常用的基础工具，包括日志系统（ALOG）和性能追踪（ATrace）。

  * **[Log](</document?id=617&version=dev&language=cn>)** — ALOG 日志系统
  * **[Trace](</document?id=745&version=dev&language=cn>)** — ATrace 性能追踪

---

## ALOG 简介

> 路径: 应用框架 > 工具库（Utils） > ALOG 简介
> 来源: [https://doc.openvela.com/document?id=1179&language=cn&version=dev](https://doc.openvela.com/document?id=1179&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/utils/log.md>) | 简体中文 ]

# ALOG 简介

ALOG（Android Log）是一个常用的日志宏集，提供了一个简化的方式来记录日志信息。它是对 __android_log_print 函数的一个宏封装，使得在 C 或 C++ 代码中记录日志更加方便和直观。

# 数据结构定义

## LOG 优先级

LOG 优先级用于控制不同等级的 LOG 过滤，可以通过 CONFIG_ALOG 控制默认输出的 LOG 级别：  

    
    
    typedef enum android_LogPriority {
        ANDROID_LOG_UNKNOWN = 0, // 未知
        ANDROID_LOG_DEFAULT, //默认
        ANDROID_LOG_VERBOSE, //冗长
        ANDROID_LOG_DEBUG, //调试
        ANDROID_LOG_INFO, //信息
        ANDROID_LOG_WARN, //警告
        ANDROID_LOG_ERROR, //错误
        ANDROID_LOG_FATAL, //致命
        ANDROID_LOG_SILENT, //静默
    } android_LogPriority;

## LOG ID

LOG ID 用于标识特定的日志缓冲区，用于 __android_log_buf_write() 和 __android_log_buf_print()。  

    
    
    typedef enum log_id {
        LOG_ID_MIN = 0,
        LOG_ID_MAIN = 0,
        LOG_ID_RADIO = 1,
        LOG_ID_EVENTS = 2,
        LOG_ID_SYSTEM = 3,
        LOG_ID_CRASH = 4,
        LOG_ID_STATS = 5,
        LOG_ID_SECURITY = 6,
        LOG_ID_KERNEL = 7,
        LOG_ID_MAX,
    
        LOG_ID_DEFAULT = 0x7FFFFFFF
    } log_id_t;

# API 列表

下面是原始的 LOG API 的定义及参数说明：  

    
    
    /**
     * @brief 将一个字符串写入日志系统。
     *
     * @param prio 日志消息的优先级，使用 `android_LogPriority` 枚举值。
     * @param tag 与日志消息关联的标签。
     * @param text 要记录的常量字符串。
     * @return int 成功时返回0，失败时返回非0值。
     */
    int __android_log_write(int prio, const char* tag, const char* text);
    
    /**
     * @brief 以格式化的方式写入日志消息。
     *
     * @param prio 日志消息的优先级，使用 `android_LogPriority` 枚举值。
     * @param tag 与日志消息关联的标签。
     * @param fmt 格式化字符串，后跟一系列参数。
     * @return int 成功时返回0，失败时返回非0值。
     */
    int __android_log_print(int prio, const char* tag, const char* fmt, ...);
    
    /**
     * @brief 使用可变参数列表以格式化的方式写入日志消息。
     *
     * @param prio 日志消息的优先级，使用 `android_LogPriority` 枚举值。
     * @param tag 与日志消息关联的标签。
     * @param fmt 格式化字符串。
     * @param ap 包含所有参数的可变参数列表。
     * @return int 成功时返回0，失败时返回非0值。
     */
    int __android_log_vprint(int prio, const char* tag, const char* fmt, va_list ap);
    
    /**
     * @brief 在条件失败时写入一条断言消息到日志系统。
     *
     * @param cond 断言条件的字符串表示。
     * @param tag 与日志消息关联的标签。
     * @param fmt 格式化字符串，后跟一系列参数（可选）。
     */
    void __android_log_assert(const char* cond, const char* tag, const char* fmt, ...);

除原始 API 以外，ALOG 还提供了一系列的宏用于简化使用：  

    
    
    /**
     * @brief 发送一个指定级别的日志。
     *
     * @param ... 可变参数列表，格式和参数类似于 printf 函数。
     */
    #define ALOGV(...) ((void)ALOG(LOG_VERBOSE, LOG_TAG, __VA_ARGS__))
    #define ALOGD(...) ((void)ALOG(LOG_DEBUG, LOG_TAG, __VA_ARGS__))
    #define ALOGI(...) ((void)ALOG(LOG_INFO, LOG_TAG, __VA_ARGS__))
    #define ALOGW(...) ((void)ALOG(LOG_WARN, LOG_TAG, __VA_ARGS__))
    #define ALOGE(...) ((void)ALOG(LOG_ERROR, LOG_TAG, __VA_ARGS__))
    
    /**
     * @brief 当条件为真时，写入日志。
     *
     * @param cond 评估的条件。
     * @param ... 可变参数列表，格式和参数类似于 printf 函数。
     */
    #define ALOGV_IF(cond, ...)
    #define ALOGD_IF(cond, ...)
    #define ALOGI_IF(cond, ...)
    #define ALOGW_IF(cond, ...)
    #define ALOGE_IF(cond, ...)

# 使用示例
    
    
    #include <log/log.h>
    
    #define LOG_TAG "MyAppTag"
    
    void log_info_alogi() {
    }
    
    int main() {
        // 自定义优先级打印 log
        __android_log_print(ANDROID_LOG_INFO, LOG_TAG, "Formatted number: %d", 42);
    
        // 使用宏打印 INFO 级别 log
        ALOGI("ALOGI: A log message from my app.");
        return 0;
    }

---

## ATrace 简介

> 路径: 应用框架 > 工具库（Utils） > ATrace 简介
> 来源: [https://doc.openvela.com/document?id=1180&language=cn&version=dev](https://doc.openvela.com/document?id=1180&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/utils/trace.md>) | 简体中文 ]

# ATrace 简介

ATrace（Android Trace）提供了一套应用层 Trace API，可以通过这些 API 在应用中插桩，进行性能分析，优化应用的执行效率。

# 接口 API 介绍
    
    
    // 头文件
    #include <cutils/trace.h>
    
    // 判断Trace是否被启用。可以用于条件性地执行跟踪代码，以减少非跟踪模式下的性能开销。
    ATRACE_ENABLED()
    
    // 开始跟踪一个上下文（通常用于函数执行时间跟踪）。name 参数用于标识该上下文。
    ATRACE_BEGIN(name)
    
    // 结束一个上下文的跟踪。此调用应与相应的 ATRACE_BEGIN 成对出现，并在其之后执行。
    ATRACE_END()
    
    // 开始跟踪一个异步事件。与 ATRACE_BEGIN/ATRACE_END 不同，异步事件不需要嵌套。
    // name 描述事件，而 cookie 提供用于区分同时发生事件的唯一标识符。
    // 开始和结束事件时使用的 name 和 cookie 必须一致。
    ATRACE_ASYNC_BEGIN(name, cookie)
    
    // 结束一个异步事件的跟踪。此调用应有对应的 ATRACE_ASYNC_BEGIN。
    ATRACE_ASYNC_END(name, cookie)
    
    // 开始跟踪一个异步事件。除了 name 和 cookie 外，还提供了一个 track_name 参数，
    // 指定该异步事件应记录的行的名称。
    // 开始事件时使用的 track_name、name 和 cookie 必须与结束时使用的一致。
    ATRACE_ASYNC_FOR_TRACK_BEGIN(track_name, name, cookie)
    
    // 结束一个异步事件的跟踪。此调用应与之前的 ATRACE_ASYNC_FOR_TRACK_BEGIN 对应。
    ATRACE_ASYNC_FOR_TRACK_END(track_name, cookie)
    
    // 跟踪一个瞬时上下文。name 用于标识上下文。
    // 瞬时事件是没有定义持续时间的事件，在时间线上可视化显示为单个标记。
    ATRACE_INSTANT(name)
    
    // 跟踪一个瞬时上下文，并指定记录事件的行名称 track_name。
    // 该功能与 ATRACE_INSTANT 类似，但允许将不同的瞬时事件放入同一时间线轨道/行中。
    ATRACE_INSTANT_FOR_TRACK(name, track_name)
    
    // 跟踪一个整数计数器值。name 用于标识计数器。这可以用于跟踪随时间变化的值。
    ATRACE_INT(name, value)
    
    // 跟踪一个64位整数计数器值。使用方式与 ATRACE_INT 相同，但用于更大范围的值。
    ATRACE_INT64(name, value)

# 使用示例
    
    
    #define ATRACE_TAG ATRACE_TAG_ALWAYS
    #include <cutils/trace.h>
    
    int main(int argc, char *argv[])
    {
        // 对当前函数进行插桩
        ATRACE_BEGIN("hello_main");
        sleep(1);
        ATRACE_INSTANT("printf");
        printf("hello world!");
        // 结束插桩
        ATRACE_END();
        return 0;
    }

使用 trace dump 命令输出结果为：  

    
    
    hello-7   [0]   3.187400000: sched_wakeup_new: comm=hello pid=7 target_cpu=0
    hello-7   [0]   3.187400000: tracing_mark_write: B|7|hello_main
    hello-7   [0]   4.197700000: tracing_mark_write: I|7|printf
    hello-7   [0]   4.187700000: tracing_mark_write: E|7|hello_main

---

## KVDB API

> 路径: 应用框架 > KVDB > KVDB API
> 来源: [https://doc.openvela.com/document?id=1182&language=cn&version=dev](https://doc.openvela.com/document?id=1182&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/kvdb.md>) | 简体中文 ]

# KVDB API

KVDB 提供轻量级键值对持久化存储，底层基于 UnQLite 数据库，API 设计参考 Android properties 规范。

头文件：#include <kvdb.h>、#include <cutils/properties.h>

# openvela 实现说明

  * **存储后端** ：基于 UnQLite 嵌入式数据库
  * **键值类型** ：支持字符串、布尔、int32、int64 和二进制数据
  * **同步/异步写入** ：property_set() 为同步写入，property_set_oneway() 为异步写入（不等待持久化完成）
  * **监控机制** ：支持通过 property_wait() 或 property_monitor_* 接口监听键值变更
  * **命令行工具** ：提供 setprop/getprop 命令行工具用于调试


# 读取接口

## property_get
    
    
    int property_get(const char *key, char *value, const char *default_value);

获取字符串类型的属性值。如果键不存在，返回默认值。

**参数** ：

  * key 属性键名。
  * value 用于存储属性值的缓冲区。
  * default_value 键不存在时的默认值，可为 NULL。


**返回值** ：

返回属性值的长度。

## property_get_bool
    
    
    int8_t property_get_bool(const char *key, int8_t default_value);

获取布尔类型的属性值。

**参数** ：

  * key 属性键名。
  * default_value 键不存在时的默认值。


**返回值** ：

返回属性的布尔值。

## property_get_int32
    
    
    int32_t property_get_int32(const char *key, int32_t default_value);

获取 32 位整数类型的属性值。

**参数** ：

  * key 属性键名。
  * default_value 键不存在时的默认值。


**返回值** ：

返回属性的 int32 值。

## property_get_int64
    
    
    int64_t property_get_int64(const char *key, int64_t default_value);

获取 64 位整数类型的属性值。

**参数** ：

  * key 属性键名。
  * default_value 键不存在时的默认值。


**返回值** ：

返回属性的 int64 值。

## property_get_buffer
    
    
    ssize_t property_get_buffer(const char *key, void *value, size_t size);

获取二进制缓冲区类型的属性值。

**参数** ：

  * key 属性键名。
  * value 用于存储数据的缓冲区。
  * size 缓冲区大小。


**返回值** ：

成功时返回读取的字节数，失败时返回负的错误码。

## property_get_binary
    
    
    ssize_t property_get_binary(const char *key, void *value, size_t val_len);

获取二进制类型的属性值。

**参数** ：

  * key 属性键名。
  * value 用于存储数据的缓冲区。
  * val_len 缓冲区大小。


**返回值** ：

成功时返回读取的字节数，失败时返回负的错误码。

## property_get_with_err
    
    
    int property_get_with_err(const char *key, char *value);

获取字符串属性值，通过返回值区分"键不存在"和"值为空"。

**参数** ：

  * key 属性键名。
  * value 用于存储属性值的缓冲区。


**返回值** ：

成功时返回属性值长度，键不存在时返回负的错误码。

## property_get_bool_with_err
    
    
    int property_get_bool_with_err(const char *key, int8_t *value);

带错误检测的布尔值读取。

**参数** ：

  * key 属性键名。
  * value 用于存储布尔结果的指针。


**返回值** ：

成功时返回 0，键不存在或类型不匹配时返回负的错误码。

## property_get_int32_with_err
    
    
    int property_get_int32_with_err(const char *key, int32_t *value);

带错误检测的 32 位有符号整数读取。

**参数** ：

  * key 属性键名。
  * value 用于存储 int32 结果的指针。


**返回值** ：

成功时返回 0，键不存在或类型不匹配时返回负的错误码。

## property_get_int64_with_err
    
    
    int property_get_int64_with_err(const char *key, int64_t *value);

带错误检测的 64 位有符号整数读取。

**参数** ：

  * key 属性键名。
  * value 用于存储 int64 结果的指针。


**返回值** ：

成功时返回 0，键不存在或类型不匹配时返回负的错误码。

# 写入接口

## property_set
    
    
    int property_set(const char *key, const char *value);

设置字符串类型的属性值（同步写入，等待持久化完成）。

**参数** ：

  * key 属性键名。
  * value 属性值。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## property_set_oneway
    
    
    int property_set_oneway(const char *key, const char *value);

设置字符串类型的属性值（异步写入，不等待持久化完成）。性能更高但不保证立即持久化。

**参数** ：

  * key 属性键名。
  * value 属性值。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## property_set_bool
    
    
    int property_set_bool(const char *key, int8_t value);

设置布尔类型属性值（同步写入）。

**参数** ：

  * key 属性键名。
  * value 布尔值（0 或非 0）。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## property_set_int32
    
    
    int property_set_int32(const char *key, int32_t value);

设置 32 位有符号整数属性值（同步写入）。

**参数** ：

  * key 属性键名。
  * value int32 值。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## property_set_int64
    
    
    int property_set_int64(const char *key, int64_t value);

设置 64 位有符号整数属性值（同步写入）。

**参数** ：

  * key 属性键名。
  * value int64 值。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## property_set_bool_oneway
    
    
    int property_set_bool_oneway(const char *key, int8_t value);

异步设置布尔类型属性值（不等待持久化完成）。

**参数** ：

  * key 属性键名。
  * value 布尔值。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## property_set_int32_oneway
    
    
    int property_set_int32_oneway(const char *key, int32_t value);

异步设置 int32 类型属性值（不等待持久化完成）。

**参数** ：

  * key 属性键名。
  * value int32 值。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## property_set_int64_oneway
    
    
    int property_set_int64_oneway(const char *key, int64_t value);

异步设置 int64 类型属性值（不等待持久化完成）。

**参数** ：

  * key 属性键名。
  * value int64 值。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## property_set_buffer
    
    
    int property_set_buffer(const char *key, const void *value, size_t size);

设置二进制缓冲区类型的属性值（同步写入）。

**参数** ：

  * key 属性键名。
  * value 数据缓冲区指针。
  * size 缓冲区字节数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## property_set_buffer_oneway
    
    
    int property_set_buffer_oneway(const char *key, const void *value, size_t size);

异步设置二进制缓冲区类型的属性值（不等待持久化完成）。

**参数** ：

  * key 属性键名。
  * value 数据缓冲区指针。
  * size 缓冲区字节数。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## property_set_binary
    
    
    int property_set_binary(const char *key, const void *value, size_t val_len, bool oneway);

设置二进制类型的属性值。

**参数** ：

  * key 属性键名。
  * value 二进制数据。
  * val_len 数据长度。
  * oneway 是否异步写入。


## property_delete
    
    
    int property_delete(const char *key);

删除指定键的属性。

**参数** ：

  * key 要删除的属性键名。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 管理接口

## property_commit
    
    
    int property_commit(void);

强制将所有待写入的属性持久化到存储。

**返回值** ：

成功时返回 0，失败时返回负的错误码。

## property_load
    
    
    int property_load(const char *path);

从文件加载属性到数据库。

**参数** ：

  * path 属性文件路径。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

## property_exit
    
    
    int property_exit(void);

关闭 KVDB 并释放资源。

**返回值** ：

成功时返回 0，失败时返回负的错误码。

## property_list
    
    
    int property_list(void (*propfn)(const char *key, const char *value, void *cookie), void *cookie);

遍历所有属性，对每个属性调用回调函数。

**参数** ：

  * propfn 回调函数，接收键、值和用户数据。
  * cookie 传递给回调函数的用户数据。


## property_list_binary
    
    
    int property_list_binary(void (*propfn)(const char *key, const void *value, size_t val_len, void *cookie), void *cookie);

遍历所有二进制类型属性，对每个属性调用回调函数。相比 property_list，回调参数带有 val_len 字段，适合处理非字符串值。

**参数** ：

  * propfn 回调函数，签名为 void (*)(const char *key, const void *value, size_t val_len, void *cookie)，接收键、二进制值、值长度和用户数据。
  * cookie 传递给回调函数的用户数据。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

# 监控接口

## property_wait
    
    
    ssize_t property_wait(const char *key, char *newkey, void *newvalue, size_t val_len, int timeout);

等待属性变更通知。阻塞直到指定键（或任意键）发生变更或超时。

**参数** ：

  * key 要监控的键名，NULL 表示监控所有键。
  * newkey 用于存储变更的键名。
  * newvalue 用于存储变更后的值。
  * val_len 值缓冲区大小。
  * timeout 超时时间（毫秒），-1 表示无限等待。


**返回值** ：

成功时返回值的长度，超时返回 0，失败时返回负的错误码。

## property_monitor_open
    
    
    int property_monitor_open(const char *key);

打开属性监控文件描述符，可配合 poll() 使用。

**参数** ：

  * key 要监控的键名，NULL 表示监控所有键。


**返回值** ：

成功时返回文件描述符，失败时返回负的错误码。

## property_monitor_read
    
    
    ssize_t property_monitor_read(int fd, char *newkey, void *newvalue, size_t val_len);

从监控文件描述符读取变更事件。

**参数** ：

  * fd 由 property_monitor_open() 返回的文件描述符。
  * newkey 用于存储变更的键名。
  * newvalue 用于存储变更后的值。
  * val_len 值缓冲区大小。


**返回值** ：

成功时返回值的长度，失败时返回负的错误码。

## property_monitor_close
    
    
    int property_monitor_close(int fd);

关闭属性监控文件描述符。

**参数** ：

  * fd 要关闭的文件描述符。


**返回值** ：

成功时返回 0，失败时返回负的错误码。

---

## 安全框架 API

> 路径: 应用框架 > 安全（Security） > 安全框架 API
> 来源: [https://doc.openvela.com/document?id=1184&language=cn&version=dev](https://doc.openvela.com/document?id=1184&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/security.md>) | 简体中文 ]

# 安全框架 API（Security Framework API）

openvela 安全框架基于 MiTEE（可信执行环境）提供安全存储、密钥管理和安全支付等能力，遵循 GlobalPlatform（GP）TEE 标准。

本文档涵盖以下内容：

  * MiTEE CA 应用级 API 接口（SST 安全存储、三元组、微信/支付宝支付、PIN 码）
  * MiTEE Rootkey API 接口
  * GP TEE Client API（REE 侧，供 CA 调用）
  * GP TEE Internal API（TEE 侧，供 TA 实现使用）


头文件：frameworks/security/include/ 下的各 CA 头文件（comsst_ca_api.h / triad_ca_api.h 等），以及 <sys/boardctl.h>（Rootkey）、OP-TEE <tee_client_api.h>（TEE Client）、<tee_internal_api.h>（TEE Internal）。

# openvela 实现说明

  * **安全方案双轨并存** ：openvela 提供两套可选的安全能力——
    * **基于 MiTEE 的 TEE 方案** （本文主要内容）：面向需要硬件级可信执行环境的场景
    * **Android Keystore 方案** （见"Android Keystore Client API"小节）：移植自 AOSP，面向只需密钥管理与安全存储的轻量场景
  * **基于 MiTEE** ：openvela 的 TEE 实现，与 OP-TEE 兼容，遵循 GlobalPlatform（GP）规范
  * **两侧运行时** ：
    * **REE 侧** （Rich Execution Environment）：运行 CA（Client Application），通过 libteec 发起 TEE 请求
    * **TEE 侧** （Trusted Execution Environment）：运行 TA（Trusted Application），由 miteed 服务器调度
  * **通信通道** ：CA 与 TA 之间通过 rpmsg socket 进行数据交换
  * **API 层次** ：
    * 应用级 CA API（位于 frameworks/security/ca/）封装常见的安全业务（SST、三元组、支付、PIN）
    * GP TEE Client API（REE 侧）提供 GP 标准的 Context/Session 管理与命令调用
    * GP TEE Internal API（TEE 侧）提供 TA 实现者可调用的内存/对象/加解密能力
  * **密钥根** ：Rootkey 在工厂阶段一次性写入，运行时不可变，所有派生密钥都从 Rootkey 推导


# 通用安全存储 SST CA API

对安全存储（Secure Storage，SST）分区执行读写操作。实现位于 frameworks/security/ca/comsst。

## comsst_data_read
    
    
    uint32_t comsst_data_read(uint8_t *scope, uint8_t *name, bool is_deletable,
                              uint8_t *buff, uint32_t *out_len);

从 SST 分区读取一条数据记录。

**参数** ：

  * scope 命名空间（范围标识），用于区分不同业务。
  * name 记录名称。
  * is_deletable 该记录是否允许被用户侧删除。
  * buff 输出缓冲区，接收读取到的数据。
  * out_len 输入输出参数，输入为缓冲区大小，输出为实际读取长度。


**返回值** ：

成功时返回 TEE_SUCCESS（0），失败时返回 TEE 错误码。

## comsst_data_write
    
    
    uint32_t comsst_data_write(uint8_t *scope, uint8_t *name, bool is_deletable,
                               uint8_t *buff, uint32_t len);

向 SST 分区写入一条数据记录。

**参数** ：

  * scope 命名空间。
  * name 记录名称。
  * is_deletable 该记录是否允许被用户侧删除。
  * buff 要写入的数据缓冲区。
  * len 数据长度。


**返回值** ：

成功时返回 TEE_SUCCESS，失败时返回 TEE 错误码。

## comsst_data_delete
    
    
    uint32_t comsst_data_delete(uint8_t *scope, uint8_t *name, bool is_deletable);

删除 SST 分区中的一条记录。

**参数** ：

  * scope 命名空间。
  * name 记录名称。
  * is_deletable 该记录的可删除属性，需与写入时一致。


**返回值** ：

成功时返回 TEE_SUCCESS，失败时返回 TEE 错误码。

## is_comsst_data_exited
    
    
    uint32_t is_comsst_data_exited(uint8_t *scope, uint8_t *name, bool is_deletable);

查询 SST 分区中是否存在指定记录。

**参数** ：

  * scope 命名空间。
  * name 记录名称。
  * is_deletable 可删除属性。


**返回值** ：

存在时返回 TEE_SUCCESS，不存在时返回对应错误码。

## comsst_data_verify
    
    
    uint32_t comsst_data_verify(uint8_t *scope, uint8_t *name, bool is_deletable,
                                uint8_t *buff, uint32_t len);

比较传入数据与 SST 中已存储数据是否一致。常用于校验应用端持有的副本是否为最新。

**参数** ：

  * scope 命名空间。
  * name 记录名称。
  * is_deletable 可删除属性。
  * buff 待比较的数据。
  * len 数据长度。


**返回值** ：

一致时返回 TEE_SUCCESS，不一致或失败时返回错误码。

# 三元组 CA API

对设备三元组中的设备标识（DID）和密钥（Key）执行读写操作。实现位于 frameworks/security/ca/triad。

## triad_store_did
    
    
    int triad_store_did(uint8_t *did, uint16_t len);

将设备 DID 写入安全存储。

**参数** ：

  * did DID 缓冲区。
  * len DID 长度（字节）。


**返回值** ：

成功时返回 0，失败时返回负值错误码。

## triad_load_did
    
    
    int triad_load_did(uint8_t *did, uint16_t len);

从安全存储读取 DID。

**参数** ：

  * did 输出缓冲区，接收 DID。
  * len 缓冲区长度。


**返回值** ：

成功时返回 0，失败时返回负值错误码。

## triad_store_key
    
    
    int triad_store_key(uint8_t *key, uint16_t len);

将设备密钥写入安全存储。

**参数** ：

  * key 密钥缓冲区。
  * len 密钥长度。


**返回值** ：

成功时返回 0，失败时返回负值错误码。

## triad_load_key
    
    
    int triad_load_key(uint8_t *key, uint16_t len);

从安全存储读取设备密钥。

**参数** ：

  * key 输出缓冲区。
  * len 缓冲区长度。


**返回值** ：

成功时返回 0，失败时返回负值错误码。

## triad_get_hmac
    
    
    int triad_get_hmac(uint8_t *input, uint16_t inlen,
                       uint8_t *output, uint16_t outlen);

使用设备密钥对输入数据做 HMAC 计算，结果写入输出缓冲区。

**参数** ：

  * input 输入数据。
  * inlen 输入数据长度。
  * output 输出缓冲区，接收 HMAC 结果。
  * outlen 输出缓冲区长度。


**返回值** ：

成功时返回 0，失败时返回负值错误码。

# 微信支付 CA API

对微信安全支付相关数据执行读写操作。实现位于 frameworks/security/ca/wxcodepay。

## wxcodepay_tee_data_read
    
    
    uint32_t wxcodepay_tee_data_read(int item, uint8_t *buff, uint32_t *out_len);

读取一条微信支付相关数据项。

**参数** ：

  * item 数据项 ID。
  * buff 输出缓冲区。
  * out_len 输入输出参数，返回实际读取长度。


**返回值** ：

成功时返回 TEE_SUCCESS，失败时返回 TEE 错误码。

## wxcodepay_tee_data_write
    
    
    uint32_t wxcodepay_tee_data_write(int item, const uint8_t *buf, uint32_t len);

写入一条微信支付相关数据项。

**参数** ：

  * item 数据项 ID。
  * buf 数据缓冲区。
  * len 数据长度。


**返回值** ：

成功时返回 TEE_SUCCESS，失败时返回 TEE 错误码。

## wxcodepay_tee_data_delete
    
    
    uint32_t wxcodepay_tee_data_delete(int item);

删除指定微信支付数据项。

**参数** ：

  * item 数据项 ID。


**返回值** ：

成功时返回 TEE_SUCCESS，失败时返回 TEE 错误码。

## is_wxcodepay_tee_data_exited
    
    
    bool is_wxcodepay_tee_data_exited(int item);

查询指定微信支付数据项是否已存储。

**参数** ：

  * item 数据项 ID。


**返回值** ：

存在时返回 true，不存在时返回 false。

# 支付宝支付 CA API

对支付宝安全支付相关数据执行读写操作。实现位于 frameworks/security/ca/alipay。

## alipay_tee_data_read
    
    
    uint32_t alipay_tee_data_read(const char *item_name, uint8_t *buff,
                                  uint32_t *out_len);

读取一条支付宝数据项。

**参数** ：

  * item_name 数据项名称字符串。
  * buff 输出缓冲区。
  * out_len 输入输出参数，返回实际读取长度。


**返回值** ：

成功时返回 TEE_SUCCESS，失败时返回 TEE 错误码。

## alipay_tee_data_write
    
    
    uint32_t alipay_tee_data_write(const char *item_name, const uint8_t *buf,
                                   uint32_t len);

写入一条支付宝数据项。

**参数** ：

  * item_name 数据项名称字符串。
  * buf 数据缓冲区。
  * len 数据长度。


**返回值** ：

成功时返回 TEE_SUCCESS，失败时返回 TEE 错误码。

## alipay_tee_data_delete
    
    
    uint32_t alipay_tee_data_delete(const char *item_name);

删除指定支付宝数据项。

**参数** ：

  * item_name 数据项名称。


**返回值** ：

成功时返回 TEE_SUCCESS，失败时返回 TEE 错误码。

## is_alipay_tee_data_exited
    
    
    bool is_alipay_tee_data_exited(const char *item_name);

查询指定支付宝数据项是否已存储。

**参数** ：

  * item_name 数据项名称。


**返回值** ：

存在时返回 true，不存在时返回 false。

# PIN 码 CA API

对个人识别码（Personal Identification Number，PIN）执行存储、验证、修改等操作。实现位于 frameworks/security/ca/pin。

## pin_store
    
    
    uint32_t pin_store(bool is_deletable, uint8_t *buff, uint32_t len);

在安全存储中保存一个 PIN。

**参数** ：

  * is_deletable 是否允许被用户侧删除。
  * buff PIN 数据缓冲区。
  * len PIN 数据长度。


**返回值** ：

成功时返回 TEE_SUCCESS，失败时返回 TEE 错误码。

## pin_is_exist
    
    
    bool pin_is_exist(bool is_deletable);

查询指定类型的 PIN 是否已存储。

**参数** ：

  * is_deletable 可删除属性，用于区分不同类型的 PIN。


**返回值** ：

存在时返回 true，不存在时返回 false。

## pin_delete
    
    
    uint32_t pin_delete(bool is_deletable);

删除安全存储中的 PIN。

**参数** ：

  * is_deletable 可删除属性。


**返回值** ：

成功时返回 TEE_SUCCESS，失败时返回 TEE 错误码。

## pin_verify
    
    
    uint32_t pin_verify(bool is_deletable, uint8_t *buff, uint32_t len);

验证 PIN 是否与安全存储中的记录一致。

**参数** ：

  * is_deletable 可删除属性。
  * buff 待验证的 PIN 数据。
  * len PIN 数据长度。


**返回值** ：

验证通过返回 TEE_SUCCESS，不通过或失败时返回错误码。

## pin_change
    
    
    uint32_t pin_change(bool is_deletable, uint8_t *old, uint32_t oldlen,
                        uint8_t *new, uint32_t newlen);

修改已存储的 PIN，需同时提供旧 PIN 和新 PIN。

**参数** ：

  * is_deletable 可删除属性。
  * old 旧 PIN 缓冲区。
  * oldlen 旧 PIN 长度。
  * new 新 PIN 缓冲区。
  * newlen 新 PIN 长度。


**返回值** ：

成功时返回 TEE_SUCCESS（旧 PIN 校验通过且新 PIN 写入成功），失败时返回错误码。

## pin_getsha256
    
    
    uint32_t pin_getsha256(bool is_deletable, uint8_t *buff, uint32_t len);

获取 PIN 对应的 SHA-256 摘要。

**参数** ：

  * is_deletable 可删除属性。
  * buff 输出缓冲区，接收 32 字节摘要。
  * len 缓冲区长度（应不小于 32）。


**返回值** ：

成功时返回 TEE_SUCCESS，失败时返回 TEE 错误码。

# MiTEE Rootkey 管理

Rootkey 是 TEE 安全体系的**信任根密钥** ，用于派生其他密钥。该密钥在工厂阶段一次性写入，运行时由 TEE OS 读取使用。

## boardctl_BOARDIOC_UNIQUEKEY
    
    
    #include <sys/boardctl.h>
    
    boardctl(BOARDIOC_UNIQUEKEY, tmp_key);

TEE OS 中的 TEE Server（miteed）通过 boardctl 系统调用读取 Rootkey。

**参数** ：

  * BOARDIOC_UNIQUEKEY 固定命令字。
  * tmp_key 输出缓冲区指针，接收 Rootkey 内容。


**返回值** ：

成功时返回 0，失败时返回负值并设置 errno。

**注意** ：

  * 只有 TEE OS 侧允许调用本接口；REE 侧应用无法访问 Rootkey。


## rootkey_provision
    
    
    norflash_api_security_register_erase(HAL_FLASH_ID_0, 2048, 32);
    norflash_api_security_register_write(HAL_FLASH_ID_0, 2048, rn, 32);
    norflash_api_security_register_lock(HAL_FLASH_ID_0, 2048, 32);

Rootkey 仅在工厂版本中、TEE OS 首次启动时执行写入。典型流程为"擦除 → 写入 → 锁定"三步：

**参数** （以 norflash_api_security_register_* 为例）：

  * HAL_FLASH_ID_0 Flash 设备标识。
  * 2048 安全寄存器起始偏移。
  * 32 字节长度（256 位）。
  * rn 写入时提供的 Rootkey 数据缓冲区。


**注意** ：

  * 一旦执行 _lock，该区域永久锁定无法再次写入，必须保证写入数据的正确性。
  * 生产设备永远不应包含调用上述接口的代码。


# Android Keystore Client API

**本节介绍的 Keystore 是一套独立于 MiTEE 的安全方案** ，源码移植自 Android Keystore 服务框架，遵循 Keystore/Keymaster 标准接口。其中 Keymaster 层支持多种实现方式，包括对接 MiTee、纯软件实现以及为安全芯片（SE）定制的实现。

openvela Keystore 向上层以 Keystore C API 的方式，为账号 SDK 等应用场景提供密钥管理与安全存储能力，使用方无需关注底层的硬件差异和具体存储细节。

头文件：#include <keystore/client.h>

源码路径：external/android/system/security/keystore/

## Keystore 使用约定

  * **存储单元** ：每条数据通过 name 字符串作为唯一标识
  * **命名规则** ：name 长度上限为 CONFIG_NAME_MAX - 12；若包含特殊字符（ASCII 0 至 ~ 范围），每个字符按 2 字节计算
  * **返回值约定** ：所有接口成功时返回 KEYSTORE_NO_ERROR（值为 1），失败时返回大于 1 的错误码
  * **内存管理** ：keyStoreGet 返回的数据由内部分配，调用方需用 free() 释放


## keyStoreInsert
    
    
    int keyStoreInsert(const char *name, size_t nameLength,
                       const uint8_t *item, size_t itemLength);

将一条数据项写入 Keystore，数据在 Keystore 内部加密存储。

**参数** ：

  * name 数据项名称。需唯一，受 CONFIG_NAME_MAX - 12 长度限制。
  * nameLength 名称长度（字节）。
  * item 要写入的数据缓冲区。
  * itemLength 数据长度（字节）。


**返回值** ：

成功时返回 KEYSTORE_NO_ERROR，失败时返回其他 KEYSTORE_* 错误码。

## keyStoreGet
    
    
    int keyStoreGet(const char *name, size_t nameLength,
                    uint8_t **item, size_t *itemLength);

按名称从 Keystore 读取一条数据项。数据由内部分配，调用方必须通过 free() 释放。

**参数** ：

  * name 数据项名称。
  * nameLength 名称长度。
  * item 输出参数，返回内部分配的数据缓冲区指针。
  * itemLength 输出参数，返回数据长度。


**返回值** ：

成功时返回 KEYSTORE_NO_ERROR，失败时返回其他 KEYSTORE_* 错误码。

## keyStoreDel
    
    
    int keyStoreDel(const char *name, size_t nameLength);

按名称删除 Keystore 中的一条数据项。

**参数** ：

  * name 数据项名称。
  * nameLength 名称长度。


**返回值** ：

成功时返回 KEYSTORE_NO_ERROR，失败时返回其他 KEYSTORE_* 错误码。

## keyStoreExist
    
    
    int keyStoreExist(const char *name, size_t nameLength);

检测 Keystore 中是否存在指定名称的数据项。

**参数** ：

  * name 数据项名称。
  * nameLength 名称长度。


**返回值** ：

存在时返回 KEYSTORE_NO_ERROR，不存在或失败时返回其他 KEYSTORE_* 错误码。

## keyStoreReset
    
    
    int keyStoreReset(void);

删除当前应用在 Keystore 中的**所有** 数据项。

**返回值** ：

成功时返回 KEYSTORE_NO_ERROR，失败时返回其他 KEYSTORE_* 错误码。

**注意** ：

  * 该操作不可撤销，仅作用于当前应用的命名空间。


## Keystore 错误码

所有 Keystore 接口返回的错误码定义（头文件 keystore/client.h）：

错误码 | 值 | 含义  
---|---|---  
KEYSTORE_NO_ERROR | 1 | 操作成功  
KEYSTORE_LOCKED | 2 | Keystore 已锁定  
KEYSTORE_UNINITIALIZED | 3 | 未初始化  
KEYSTORE_SYSTEM_ERROR | 4 | 系统错误  
KEYSTORE_PROTOCOL_ERROR | 5 | 协议错误  
KEYSTORE_PERMISSION_DENIED | 6 | 权限不足  
KEYSTORE_KEY_NOT_FOUND | 7 | 指定的数据项不存在  
KEYSTORE_VALUE_CORRUPTED | 8 | 数据损坏  
KEYSTORE_UNDEFINED_ACTION | 9 | 未定义的操作  
KEYSTORE_WRONG_PASSWORD_0 ~ KEYSTORE_WRONG_PASSWORD_3 | 10-13 | 密码错误（最多 4 次重试）  
KEYSTORE_SIGNATURE_INVALID | 14 | 签名无效  
KEYSTORE_OP_AUTH_NEEDED | 15 | 本次操作需要先通过身份认证  
KEYSTORE_KEY_ALREADY_EXISTS | 16 | 数据项已存在  
KEYSTORE_KEY_PERMANENTLY_INVALIDATED | 17 | 数据项永久失效  
KEYSTORE_ABORT_CALLED | 18 | 操作被中止  
KEYSTORE_PRUNED | 19 | 数据被 pruned  
KEYSTORE_BINDER_DIED | 20 | Binder 连接已断开  
  
# GP TEE Client API（REE 侧）

以下接口遵循 GlobalPlatform TEE Client API 规范，由 CA 在 REE 侧调用，用于与 TEE 建立上下文、打开会话、执行命令。

## TEEC_InitializeContext
    
    
    TEEC_Result TEEC_InitializeContext(const char *name, TEEC_Context *context);

初始化一个 TEE 上下文，建立 CA 与指定 TEE 之间的连接。

**参数** ：

  * name 零结尾字符串，标识要连接的 TEE。当前实现仅支持 NULL，表示连接默认 TEE。
  * context 待初始化的上下文结构体指针。


**返回值** ：

成功时返回 TEEC_SUCCESS，失败时返回其他 TEEC_Result 错误码。

## TEEC_FinalizeContext
    
    
    void TEEC_FinalizeContext(TEEC_Context *context);

销毁已初始化的 TEE 上下文，关闭 CA 与 TEE 之间的连接。

**参数** ：

  * context 要销毁的上下文。


**注意** ：

  * 调用前必须确保所有关联的会话已关闭、所有共享内存已释放。


## TEEC_OpenSession
    
    
    TEEC_Result TEEC_OpenSession(TEEC_Context *context,
                                 TEEC_Session *session,
                                 const TEEC_UUID *destination,
                                 uint32_t connectionMethod,
                                 const void *connectionData,
                                 TEEC_Operation *operation,
                                 uint32_t *returnOrigin);

在 CA 与指定 TA 之间打开一个新会话。

**参数** ：

  * context 已初始化的 TEE 上下文。
  * session 待初始化的会话结构体指针。
  * destination 目标 TA 的 UUID。
  * connectionMethod 连接方式。
  * connectionData 连接相关数据（当前未使用，应传 NULL）。
  * operation 操作参数结构体；若不需要传参，可传 NULL。
  * returnOrigin 输出参数，错误发生时返回错误来源。


**返回值** ：

成功时返回 TEEC_SUCCESS，失败时返回其他 TEEC_Result 错误码。

## TEEC_CloseSession
    
    
    void TEEC_CloseSession(TEEC_Session *session);

关闭已打开的 TA 会话。

**参数** ：

  * session 要关闭的会话。


## TEEC_InvokeCommand
    
    
    TEEC_Result TEEC_InvokeCommand(TEEC_Session *session,
                                   uint32_t commandID,
                                   TEEC_Operation *operation,
                                   uint32_t *returnOrigin);

在指定会话中调用 TA 命令。

**参数** ：

  * session 已打开的会话句柄。
  * commandID TA 内部的命令 ID。
  * operation 操作参数结构体；若不需要传参，可传 NULL。
  * returnOrigin 输出参数，错误发生时返回错误来源。


**返回值** ：

成功时返回 TEEC_SUCCESS，失败时返回其他 TEEC_Result 错误码。

## TEEC_AllocateSharedMemory
    
    
    TEEC_Result TEEC_AllocateSharedMemory(TEEC_Context *context,
                                          TEEC_SharedMemory *sharedMem);

在指定 TEE 上下文范围内分配一块共享内存。

**参数** ：

  * context 已初始化的 TEE 上下文。
  * sharedMem 待分配的共享内存结构体指针。


**返回值** ：

成功时返回 TEEC_SUCCESS；内存不足时返回 TEEC_ERROR_OUT_OF_MEMORY；其他失败返回对应 TEEC_Result 错误码。

## TEEC_RegisterSharedMemory
    
    
    TEEC_Result TEEC_RegisterSharedMemory(TEEC_Context *context,
                                          TEEC_SharedMemory *sharedMem);

将一块**调用方已分配** 的内存注册为共享内存。与 TEEC_AllocateSharedMemory（由框架分配）不同，本接口允许 CA 复用已有内存缓冲区作为 TEE 通信数据区。

**参数** ：

  * context 已初始化的 TEE 上下文。
  * sharedMem 共享内存结构体指针，调用方应预先填写 buffer、size 和 flags 字段。


**返回值** ：

成功时返回 TEEC_SUCCESS，失败时返回对应 TEEC_Result 错误码。

## TEEC_ReleaseSharedMemory
    
    
    void TEEC_ReleaseSharedMemory(TEEC_SharedMemory *sharedMemory);

释放或注销先前分配的共享内存块。对 TEEC_AllocateSharedMemory 分配的内存会释放，对 TEEC_RegisterSharedMemory 注册的内存只做注销（不释放调用方的缓冲区）。

**参数** ：

  * sharedMemory 待释放的共享内存结构体指针。


## TEEC_RequestCancellation
    
    
    void TEEC_RequestCancellation(TEEC_Operation *operation);

请求取消一个正在执行的 TEEC_OpenSession 或 TEEC_InvokeCommand 操作。调用本接口后，对应操作可能被 TEE 异步中止。

**参数** ：

  * operation 目标操作的 TEEC_Operation 结构体指针。该结构必须是某个正在执行中的 OpenSession / InvokeCommand 使用的同一份对象。


**注意** ：

  * 本接口是"请求"而非"强制"，能否真正中止由 TEE 和目标 TA 决定。
  * TA 需要在 GP Internal API 中调用 TEE_GetCancellationFlag 配合才能响应取消请求。


# GP TEE Internal API（TEE 侧）

GP TEE Internal Core API 是 GlobalPlatform 定义的标准 TA 开发接口，**函数签名、参数语义和返回值语义以 GP 官方规范为准** 。openvela 的 MiTEE 在兼容这些接口的同时，由于当前实现进度原因，部分接口仅处于"实现不完整"状态。

> **权威参考** ：  
>  \- [GlobalPlatform TEE Internal Core API Specification v1.3.1](<https://globalplatform.org/specs-library/tee-internal-core-api-specification/>)  
>  \- optee_os 源码中的 <tee_internal_api.h>

本节以**状态速查表** 的形式列出 openvela 对每个 GP Internal API 的支持情况，便于 TA 开发者判断哪些 API 可以直接使用。完整签名、参数、返回值请以上述 GP 官方规范为准。

**状态列说明** ：

  * **支持** — openvela 已完整实现，行为与 GP 规范一致
  * **实现不完整** — 函数符号存在，但部分行为尚未实现或未经充分验证，不建议生产环境使用


## TA 生命周期入口

函数 | 状态 | 描述  
---|---|---  
TA_CreateEntryPoint | 支持 | TA 创建入口  
TA_DestroyEntryPoint | 支持 | TA 销毁入口  
TA_OpenSessionEntryPoint | 支持 | 会话打开入口  
TA_CloseSessionEntryPoint | 支持 | 会话关闭入口  
TA_InvokeCommandEntryPoint | 支持 | 命令调用入口  
  
## TA 间通信

函数 | 状态 | 描述  
---|---|---  
TEE_OpenTASession | 实现不完整 | 打开 TA 间会话  
TEE_CloseTASession | 实现不完整 | 关闭 TA 间会话  
TEE_InvokeTACommand | 实现不完整 | 调用其他 TA 命令  
  
## 内存访问检查

函数 | 状态 | 描述  
---|---|---  
TEE_CheckMemoryAccessRights | 实现不完整 | 检查内存访问权限  
  
## 内存管理

函数 | 状态 | 描述  
---|---|---  
TEE_Malloc | 支持 | 分配内存  
TEE_Realloc | 支持 | 重新分配内存  
TEE_Free | 支持 | 释放内存  
TEE_MemMove | 支持 | 内存移动  
TEE_MemCompare | 支持 | 内存比较  
TEE_MemFill | 支持 | 内存填充  
  
## 通用对象操作

函数 | 状态 | 描述  
---|---|---  
TEE_GetObjectInfo1 | 支持 | 获取对象信息  
TEE_CloseObject | 支持 | 关闭对象  
  
## 瞬态对象操作

函数 | 状态 | 描述  
---|---|---  
TEE_AllocateTransientObject | 支持 | 分配瞬态对象  
TEE_FreeTransientObject | 支持 | 释放瞬态对象  
TEE_ResetTransientObject | 支持 | 重置瞬态对象  
TEE_PopulateTransientObject | 支持 | 填充瞬态对象属性  
TEE_InitRefAttribute | 支持 | 初始化引用属性  
TEE_InitValueAttribute | 支持 | 初始化值属性  
TEE_CopyObjectAttributes1 | 支持 | 复制对象属性  
TEE_GenerateKey | 实现不完整 | 生成密钥  
  
## 持久化对象操作

函数 | 状态 | 描述  
---|---|---  
TEE_OpenPersistentObject | 实现不完整 | 打开持久化对象  
TEE_CreatePersistentObject | 实现不完整 | 创建持久化对象  
TEE_CloseAndDeletePersistentObject | 实现不完整 | 关闭并删除持久化对象  
TEE_RenamePersistentObject | 实现不完整 | 重命名持久化对象  
  
## 持久化对象数据流操作

函数 | 状态 | 描述  
---|---|---  
TEE_ReadObjectData | 实现不完整 | 读取对象数据  
TEE_WriteObjectData | 实现不完整 | 写入对象数据  
TEE_TruncateObjectData | 实现不完整 | 截断对象数据  
TEE_SeekObjectData | 实现不完整 | 定位对象数据偏移  
  
## 密码学操作管理

函数 | 状态 | 描述  
---|---|---  
TEE_AllocateOperation | 支持 | 分配密码学操作  
TEE_FreeOperation | 支持 | 释放密码学操作  
TEE_GetOperationInfo | 支持 | 获取操作信息  
TEE_GetOperationInfoMultiple | 支持 | 获取多密钥操作信息  
TEE_ResetOperation | 支持 | 重置操作  
TEE_SetOperationKey | 支持 | 设置操作密钥  
TEE_SetOperationKey2 | 支持 | 设置双密钥操作  
TEE_CopyOperation | 支持 | 复制操作  
  
## 消息摘要（Message Digest）

函数 | 状态 | 描述  
---|---|---  
TEE_DigestUpdate | 支持 | 更新摘要数据  
TEE_DigestDoFinal | 支持 | 完成摘要计算  
  
## 对称加密（Symmetric Cipher）

函数 | 状态 | 描述  
---|---|---  
TEE_CipherInit | 支持 | 初始化对称加密操作  
TEE_CipherUpdate | 支持 | 更新加密数据  
TEE_CipherDoFinal | 支持 | 完成加密操作  
  
## 消息认证码（MAC）

函数 | 状态 | 描述  
---|---|---  
TEE_MACInit | 支持 | 初始化 MAC 操作  
TEE_MACUpdate | 支持 | 更新 MAC 数据  
TEE_MACComputeFinal | 支持 | 计算最终 MAC 值  
TEE_MACCompareFinal | 支持 | 比较最终 MAC 值  
  
## 认证加密（Authenticated Encryption，AE）

函数 | 状态 | 描述  
---|---|---  
TEE_AEInit | 实现不完整 | 初始化 AE 操作  
TEE_AEUpdateAAD | 实现不完整 | 更新附加认证数据  
TEE_AEUpdate | 实现不完整 | 更新 AE 数据  
TEE_AEEncryptFinal | 实现不完整 | 完成 AE 加密  
TEE_AEDecryptFinal | 实现不完整 | 完成 AE 解密  
  
## 非对称加密（Asymmetric Cryptography）

函数 | 状态 | 描述  
---|---|---  
TEE_AsymmetricEncrypt | 实现不完整 | 非对称加密  
TEE_AsymmetricDecrypt | 实现不完整 | 非对称解密  
TEE_AsymmetricSignDigest | 实现不完整 | 非对称签名  
TEE_AsymmetricVerifyDigest | 实现不完整 | 非对称验签  
  
## 密钥派生（Key Derivation）

函数 | 状态 | 描述  
---|---|---  
TEE_DeriveKey | 实现不完整 | 派生密钥  
  
## 随机数生成

函数 | 状态 | 描述  
---|---|---  
TEE_GenerateRandom | 实现不完整 | 生成随机数  
  
## 时间 API

函数 | 状态 | 描述  
---|---|---  
TEE_GetSystemTime | 实现不完整 | 获取系统时间  
TEE_GetTAPersistentTime | 实现不完整 | 获取 TA 持久化时间  
TEE_SetTAPersistentTime | 实现不完整 | 设置 TA 持久化时间  
TEE_GetREETime | 实现不完整 | 获取 REE 时间

---

## uORB API

> 路径: 应用框架 > uORB > uORB API
> 来源: [https://doc.openvela.com/document?id=1186&language=cn&version=dev](https://doc.openvela.com/document?id=1186&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/api/framework/uorb.md>) | 简体中文 ]

# uORB API

uORB 是 openvela 的发布/订阅消息总线，用于进程或线程间的异步数据通信。

头文件：#include <uORB/uORB.h>

# openvela 实现说明

  * **配置依赖** ：需要启用 CONFIG_USENSOR 和 CONFIG_UORB
  * **跨核通信** ：启用 CONFIG_SENSORS_RPMSG 后支持 topic 跨核传输
  * **内置传感器** ：提供 34 种预定义传感器 topic（加速度计、陀螺仪、GPS 等）
  * **自定义 topic** ：通过 ORB_DECLARE、ORB_DEFINE、ORB_ID 宏定义
  * **调试工具** ：uorb listener 工具可监听 topic 数据（需 CONFIG_DEBUG_UORB）


# 设备管理

## orb_open
    
    
    int orb_open(const char *name, int instance, int flags);

打开指定名称和实例的 topic 设备节点.

## orb_close
    
    
    int orb_close(int fd);

关闭文件描述符。

## orb_unlink_multi
    
    
    int orb_unlink_multi(const struct orb_metadata *meta, int instance);

移除 topic 节点。

# 发布接口

## orb_advertise_multi_queue_info
    
    
    int orb_advertise_multi_queue_info(const struct orb_metadata *meta, const void *data, int *instance, unsigned int queue_size, orb_info_t *info);

执行 topic 的初始广播（发布者注册），在 /dev/uorb 下创建对应的 topic 节点并发布初始数据。

## orb_advertise_multi_queue_persist
    
    
    int orb_advertise_multi_queue_persist_info(const struct orb_metadata *meta, const void *data, int *instance, unsigned int queue_size, orb_info_t *info);

orb_advertise_multi_queue_persist 类似于 orb_advertise_multi_queue，但会保证所有订阅者（包括未来新增的）都能访问到当前及后续发布的数据。

## orb_unadvertise
    
    
    static inline int orb_unadvertise(int fd) { return orb_close(fd);

取消 topic 广播。

## orb_publish_multi
    
    
    ssize_t orb_publish_multi(int fd, const void *data, size_t len);

向 topic 发布指定长度的新数据。数据发布后，所有正在等待的订阅者会被唤醒；未等待的订阅者可通过 orb_check 检查 topic 是否有更新。

## orb_advertise
    
    
    static inline int orb_advertise(const struct orb_metadata *meta, const void *data);

发布一个 topic 的 advertiser。等价于 orb_advertise_multi(meta, data, NULL)，创建默认实例 0。

**参数** ：

  * meta topic 元数据指针。
  * data 初始发布的数据（可为 NULL）。


**返回值** ：

成功时返回 advertiser 的文件描述符，失败时返回负值并设置 errno。

## orb_advertise_multi
    
    
    static inline int orb_advertise_multi(const struct orb_metadata *meta,
                                          const void *data, int *instance);

发布带实例 ID 的 topic advertiser，用于多实例 topic 的场景。

**参数** ：

  * meta topic 元数据指针。
  * data 初始发布数据。
  * instance 输入输出参数，返回新创建的实例 ID。


**返回值** ：

成功时返回文件描述符，失败时返回负值。

## orb_advertise_queue
    
    
    static inline int orb_advertise_queue(const struct orb_metadata *meta,
                                          const void *data, unsigned int queue_size);

发布带队列的 topic advertiser。队列长度大于 1 时支持缓存多条历史数据。

**参数** ：

  * meta topic 元数据指针。
  * data 初始数据。
  * queue_size 队列深度。


**返回值** ：

成功时返回文件描述符，失败时返回负值。

## orb_advertise_multi_queue
    
    
    static inline int orb_advertise_multi_queue(const struct orb_metadata *meta,
                                                const void *data, int *instance,
                                                unsigned int queue_size);

同时指定实例 ID 和队列深度的 advertiser。

**参数** ：

  * meta topic 元数据指针。
  * data 初始数据。
  * instance 输入输出参数，返回实例 ID。
  * queue_size 队列深度。


**返回值** ：

成功时返回文件描述符，失败时返回负值。

## orb_advertise_multi_queue_persist_info
    
    
    int orb_advertise_multi_queue_persist_info(const struct orb_metadata *meta,
                                               const void *data, int *instance,
                                               unsigned int queue_size,
                                               orb_info_t *info);

带持久化信息字段的 advertiser。info 参数用于传递额外的 topic 元信息。

**参数** ：

  * meta topic 元数据指针。
  * data 初始数据。
  * instance 输入输出参数，返回实例 ID。
  * queue_size 队列深度。
  * info topic 附加信息指针。


**返回值** ：

成功时返回文件描述符，失败时返回负值。

## orb_publish
    
    
    static inline int orb_publish(const struct orb_metadata *meta, int fd, const void *data);

发布一个 topic 数据（默认长度，从 meta 获取）。

**参数** ：

  * meta topic 元数据指针。
  * fd advertiser 文件描述符。
  * data 要发布的数据。


**返回值** ：

成功时返回发布的字节数，失败时返回负值。

## orb_publish_auto
    
    
    static inline int orb_publish_auto(const struct orb_metadata *meta, int *fd,
                                       const void *data, int *instance);

自动 advertise + publish。若 *fd 小于 0，会自动创建 advertiser。便于简单场景的快速发布。

**参数** ：

  * meta topic 元数据指针。
  * fd 输入输出参数，advertiser 文件描述符。
  * data 要发布的数据。
  * instance 输入输出参数，返回实例 ID。


**返回值** ：

成功时返回 0，失败时返回负值。

# 订阅接口

## orb_subscribe_multi
    
    
    int orb_subscribe_multi(const struct orb_metadata *meta, unsigned instance);

以非唤醒方式订阅 topic。数据发布后，等待中的订阅者会被唤醒；未等待的订阅者可通过 orb_check 检查更新。

如果订阅发生在 publish 之后，订阅成功后立刻调用 orb_check 将返回 true。即使 topic 尚未 advertise，订阅也会成功——此时 topic 的时间戳为 0、不会触发 poll 事件、orb_check 始终返回 false、也无法被 copy，直到后续 topic 被 advertise 为止。

## orb_unsubscribe
    
    
    static inline int orb_unsubscribe(int fd) { return orb_close(fd);

取消订阅 topic。

## orb_copy_multi
    
    
    ssize_t orb_copy_multi(int fd, void *buffer, size_t len);

从 topic 获取指定长度的数据。这是**唯一** 会重置"订阅者收到新数据"标记位的接口——一旦 poll 或 orb_check 表明有更新，必须调用本接口完成消费。

## orb_check
    
    
    int orb_check(int fd, bool *updated);

检查 topic 自上次 orb_copy 后是否有新数据发布。用于不使用 poll() 的场景下判断是否需要调用 orb_copy；也可避免在 topic 很可能已更新时仍要调用 poll() 的开销。更新状态按 fd 维度跟踪：返回 true 后，在同一 fd 上必须调用 orb_copy 才会重置更新标记，否则本接口会持续返回 true。

## orb_subscribe
    
    
    static inline int orb_subscribe(const struct orb_metadata *meta);

订阅 topic 的默认实例。等价于 orb_subscribe_multi(meta, 0)。

**参数** ：

  * meta topic 元数据指针。


**返回值** ：

成功时返回订阅者文件描述符，失败时返回负值。

## orb_subscribe_wakeup
    
    
    static inline int orb_subscribe_wakeup(const struct orb_metadata *meta);

订阅默认实例并启用 wakeup 模式（有新数据时异步唤醒调用者）。等价于 orb_subscribe_multi_wakeup(meta, 0)。

**参数** ：

  * meta topic 元数据指针。


**返回值** ：

成功时返回文件描述符，失败时返回负值。

## orb_subscribe_multi_wakeup
    
    
    int orb_subscribe_multi_wakeup(const struct orb_metadata *meta, unsigned instance);

订阅指定实例 ID 的 topic 并启用 wakeup 模式。

**参数** ：

  * meta topic 元数据指针。
  * instance 实例 ID。


**返回值** ：

成功时返回文件描述符，失败时返回负值。

## orb_copy
    
    
    static inline int orb_copy(const struct orb_metadata *meta, int fd, void *buffer);

从订阅者 fd 拷贝最新 topic 数据到 buffer，使用默认长度（从 meta 获取）。

**参数** ：

  * meta topic 元数据指针。
  * fd 订阅者文件描述符。
  * buffer 接收数据的缓冲区。


**返回值** ：

成功时返回拷贝的字节数，失败时返回负值。

## orb_unlink
    
    
    static inline int orb_unlink(const struct orb_metadata *meta);

删除 topic 的默认实例。等价于 orb_unlink_multi(meta, 0)。

**参数** ：

  * meta topic 元数据指针。


**返回值** ：

成功时返回 0，失败时返回负值。

# 控制接口

## orb_get_state
    
    
    int orb_get_state(int fd, struct orb_state *state);

获取 topic 所有订阅者的状态信息。该状态包含所有订阅者中的最大频率和最小批处理间隔，以及 enable 字段（指示当前节点是否已订阅或激活）。若当前无任何订阅者，状态字段将被置为：max_frequency=0、min_batch_interval=0、enable=false。

## orb_get_events
    
    
    int orb_get_events(int fd, unsigned int *events);

获取指定订阅者的事件信息.

## orb_ioctl
    
    
    int orb_ioctl(int fd, int cmd, unsigned long arg);

订阅者的 ioctl 控制, 与 ioctl 相同().

## orb_flush
    
    
    int orb_flush(int fd);

刷新硬件缓冲区中累积的 topic 数据。当硬件 FIFO 未达 watermark 但希望立即读取时，调用本接口可强制把 FIFO 中的数据吐出；调用时机无限制。调用后可通过监听 fd 的 POLLPRI 事件，并用 orb_get_events 获取事件以判断 flush 是否完成。

## orb_set_batch_interval
    
    
    int orb_set_batch_interval(int fd, unsigned batch_interval);

设置用户期望的批处理间隔，最终生效值取决于硬件 FIFO 能力。本接口会触发 POLLPRI 事件通知发布者，由发布者决定最终的批处理间隔。仅适用于具备硬件 FIFO 的 topic（如带硬件 FIFO 的传感器），否则调用无意义。

## orb_get_batch_interval
    
    
    int orb_get_batch_interval(int fd, unsigned *batch_interval);

获取批处理模式下当前生效的批处理间隔。仅适用于具备硬件 FIFO 的 topic（如带硬件 FIFO 的传感器），否则调用无意义。参见 orb_set_batch_interval。

## orb_set_interval
    
    
    int orb_set_interval(int fd, unsigned interval);

设置订阅者的最小上报间隔（单位：微秒）。

**参数** ：

  * fd 订阅者文件描述符。
  * interval 上报间隔，单位微秒，0 表示无限制。


**返回值** ：

成功时返回 0，失败时返回负值。

## orb_get_interval
    
    
    int orb_get_interval(int fd, unsigned *interval);

获取订阅者当前的上报间隔（微秒）。

**参数** ：

  * fd 订阅者文件描述符。
  * interval 输出参数，返回当前间隔值。


**返回值** ：

成功时返回 0，失败时返回负值。

## orb_set_frequency
    
    
    static inline int orb_set_frequency(int fd, unsigned frequency);

按频率（Hz）设置订阅者的上报间隔。等价于 orb_set_interval(fd, frequency ? 1000000/frequency : 0)。

**参数** ：

  * fd 订阅者文件描述符。
  * frequency 目标频率（Hz），0 表示无限制。


**返回值** ：

成功时返回 0，失败时返回负值。

## orb_get_frequency
    
    
    static inline int orb_get_frequency(int fd, unsigned *frequency);

按频率（Hz）获取订阅者的当前上报速率。

**参数** ：

  * fd 订阅者文件描述符。
  * frequency 输出参数，返回当前频率。


**返回值** ：

成功时返回 0，失败时返回负值。

## orb_get_info
    
    
    int orb_get_info(int fd, orb_info_t *info);

获取 topic 信息。

## orb_info
    
    
    void orb_info(const char *format, const char *name, const void *data);

打印传感器数据。

# 查询接口

## orb_elapsed_time
    
    
    orb_abstime orb_absolute_time(void);

获取当前系统时间（微秒）。

## orb_exists
    
    
    int orb_exists(const struct orb_metadata *meta, int instance);

检查 topic 实例是否已被广播.

## orb_group_count
    
    
    int orb_group_count(const struct orb_metadata *meta);

获取已广播的 topic 实例数量。

## orb_absolute_time
    
    
    orb_abstime orb_absolute_time(void);

获取单调递增的绝对时间戳（单位：微秒），用于 topic 数据的时间戳标记。

**返回值** ：

返回当前时间戳。

## orb_get_meta
    
    
    const struct orb_metadata *orb_get_meta(const char *name);

通过名称字符串获取 topic 元数据。

# 格式化 I/O

## orb_sscanf
    
    
    int orb_sscanf(const char *buf, const char *format, void *data);

将字符串值转换为结构体缓冲区。

## orb_fprintf
    
    
    int orb_fprintf(FILE *stream, const char *format, const void *data);

将传感器数据打印到文件。

# 事件循环

## orb_loop_init
    
    
    int orb_loop_init(struct orb_loop_s *loop, enum orb_loop_type_e type);

初始化 orb 事件循环, 使用 orb_loop_deinit 释放 function.

## orb_loop_run
    
    
    int orb_loop_run(struct orb_loop_s *loop);

启动事件循环。循环启动后，用户可以通过 orb_handle_start 动态添加新的文件描述符，也可通过 orb_handle_stop 关闭已添加的 fd。循环启动后会进入阻塞状态。

## orb_loop_deinit
    
    
    int orb_loop_deinit(struct orb_loop_s *loop);

注销当前事件循环。注销后如需再次使用必须重新初始化。通过 orb_handle_init 添加到循环中的 handle 由用户负责关闭。

## orb_loop_exit_async
    
    
    int orb_loop_exit_async(struct orb_loop_s *loop);

向当前事件循环发送退出事件(不等待).

## orb_handle_init
    
    
    int orb_handle_init(struct orb_handle_s *handle, int fd, int events, void *arg, orb_datain_cb_t datain_cb, orb_dataout_cb_t dataout_cb, orb_eventpri_cb_t pri_cb, orb_eventerr_cb_t err_cb);

初始化 orb 句柄。

## orb_handle_start
    
    
    int orb_handle_start(struct orb_loop_s *loop, struct orb_handle_s *handle);

从事件循环中启动句柄。

## orb_handle_stop
    
    
    int orb_handle_stop(struct orb_loop_s *loop, struct orb_handle_s *handle);

从事件循环中停止句柄。

---

