# 调试

> 来源: openvela官方
> 共 21 篇文档

---

## GDB 调试指南

> 路径: GDB > GDB 调试指南
> 来源: [https://doc.openvela.com/document?id=742&language=cn&version=dev](https://doc.openvela.com/document?id=742&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/debugging_tools/GDB/GDB_debugging.md>) | 简体中文 ]

# 一、概述

本指南旨在为开发者提供一份全面而实用的 GNU Debugger (GDB) 操作手册。无论您是初学者还是希望深化嵌入式调试技能的开发者，都能从中获益。

## 1、GDB 是什么

GDB (GNU Debugger) 是 GNU 项目提供的标准化调试工具。它功能强大，能与 GCC 编译器紧密协作，帮助开发者深入理解和修复程序中的问题。

## 2、GDB 的核心能力

GDB 主要提供以下四项核心能力，赋予您完全控制程序执行的能力：

  1. **控制执行** ：按照您的设定启动并运行程序，包括传递命令行参数和设置环境变量。
  2. **设置断点** ：在代码的任意位置（如特定行号、函数入口）设置断点，或创建在满足特定条件时才触发的条件断点。
  3. **检查状态** ：当程序暂停时，您可以检查变量的当前值、查看内存内容、回溯函数调用栈以及检查寄存器状态。
  4. **动态修改** ：在运行时动态改变变量的值，或修改内存内容，以测试不同的代码路径和修复假设。


# 二、准备工作

在开始调试前，必须确保您的程序包含了 GDB 所需的调试信息。

## 1、编译时加入调试信息

使用 GCC 编译代码时，必须添加 -g 选项。为了获得最详尽的调试信息（包括宏定义），推荐使用 -g3：  

    
    
    # 示例编译命令
    gcc -g3 -o my_program my_program.c

在 **openvela** 的构建系统中，您可以通过 Kconfig 开启调试选项，系统会自动为编译器添加合适的标志。

## 2、安装 GDB

对于跨平台嵌入式开发（例如，在 x86 主机上调试 ARM 目标板），您需要一个支持多架构的 GDB 版本。  

    
    
    # 在 Ubuntu/Debian 系统上安装 gdb-multiarch
    sudo apt install gdb-multiarch

对于特定的 ARM 目标，您也可以使用对应的工具链中的 GDB，例如 arm-none-eabi-gdb。

# 三、GDB 核心命令参考

本章节将命令按功能分组，帮助您快速掌握 GDB 的核心操作。

## 1、启动与退出

**命令** | **描述**  
---|---  
gdb ./nuttx | 加载 nuttx 可执行文件并进入 GDB 交互界面。  
attach <PID> | 附加到已在后台运行的进程。   
您需要先用 ps -ef | grep nuttx 找到进程 ID (PID)。  
target remote <IP>:<Port> | 在 GDB 内执行，用于连接到远程目标机上运行的 GDB Server。  
例如，target remote :1234 连接到本地的 1234 端口。  
gdb -q ./nuttx | 启动 GDB 但不显示冗长的版本和版权信息。  
quit | q，**退出** GDB 会话。  
kill | **终止** 被调试的程序。  
  
## 2、控制程序执行

**命令** | **描述**  
---|---  
run | r，**启动或重新启动** 程序。  
程序将一直运行，直到遇到断点、观察点、异常或手动中断。  
continue | c，从当前暂停位置**继续执行** ，直到下一个断点或程序结束。  
next | n，**单步执行 (Step Over)** 。  
执行当前行代码。如果当前行是函数调用，它会执行整个函数，然后停在下一行。  
step | s，**单步进入 (Step In)** 。  
如果当前行是函数调用，它会进入该函数内部并停在函数的第一行。  
stepi | si，**单条****指令****执行** 。  
用于汇编级别的单步调试。  
finish | fin，**完成当前函数** 。  
执行当前函数剩余部分，然后停在函数返回后的下一条语句。  
(回车) | 重复执行上一条命令（对于 n、s 等命令非常有用）。  
  
## 3、管理断点与观察点

断点使程序在特定位置暂停，观察点则在变量或内存地址被访问时暂停。

**命令** | **描述**  
---|---  
break <location> | b，在指定位置设置断点。   
location 可以是**行号** (b main.c:25)、**函数名** (b my_function) 或**地址** (b *0xdeadbeef)。  
break ... if <condition> | 设置**条件断点** 。  
仅当 condition 为真时，断点才会被触发。  
例如：b 15 if i == 10。  
info breakpoints | info b，显示所有断点及其状态（编号、是否启用、命中次数等）。  
delete <num> | del，删除指定编号的断点。若不带编号，则删除所有断点。  
disable <num> | dis，禁用指定编号的断点，但不会删除它。  
enable <num> | en，重新启用一个被禁用的断点。  
watch <expr> | 设置**观察点 (Write Watchpoint)** 。  
当表达式 expr（通常是一个变量名或内存地址）的值被**写入** 时，程序暂停。  
rwatch <expr> | 设置**读观察点 (Read Watchpoint)** 。  
当 expr 被**读取** 时，程序暂停。  
awatch <expr> | 设置**访问观察点 (Access Watchpoint)** 。  
当 expr 被**读取或写入** 时，程序暂停。  
  
## 4、检查程序状态

当程序暂停时，这些命令帮助您探查问题所在。

**命令** | **描述**  
---|---  
print <expr> | p，打印变量或表达式的值。 例如 p my_var 或 p *my_ptr。  
x/<nfu> <addr> | **检查内存 (Examine)** 。   
n 是数量   
f 是格式 (x=十六进制, d=十进制, c=字符, s=字符串),  
u 是单位 (b=字节, h=半字, w=字, g=双字)  
例如，x/16xw 0x1000 表示从地址 0x1000 开始显示 16 个字的十六进制内容。  
backtrace | bt，显示当前的**函数调用栈** ，帮助您追溯代码是如何执行到当前位置的。  
frame <num> | f，切换到指定编号的栈帧。 结合 bt 使用，可以查看调用栈中任意层级的局部变量和参数。  
info locals | 显示当前栈帧中的所有**局部变量** 。  
info args | 显示当前栈帧中的所有**函数参数** 。  
info registers | 显示所有 CPU **寄存器** 的当前值。  
info threads | 在多线程程序（如 openvela）中，显示所有线程及其 ID。  
thread <id> | 切换到指定 ID 的线程上下文。  
ptype <expr> | 显示变量或类型的**数据结构定义** 。 例如   
ptype struct my_struct。  
ptype /o  命令可以打印出指定类型的完整内存布局，清晰地展示每个成员的偏移量（offset）和大小（size）。  
set var <name>=<value> | 在运行时**修改变量的值** 。 例如 set var i = 10。不引起歧义时，可使用 set i = 10。  
  
## 5、与源码和汇编交互

**命令** | **描述**  
---|---  
list | l，显示当前位置附近的源代码。  
layout src | 进入文本用户界面 (TUI) 模式，**分屏显示源代码** 。  
layout asm | 分屏显示**汇编代码** 。  
layout split | 分屏**同时显示源代码和汇编代码** 。   
在此模式下，可使用 focus 命令或快捷键 Ctrl + X \+ O 在不同窗口间切换焦点。  
Ctrl + X, A | 退出 TUI 模式，返回标准 GDB 命令行界面。  
disassemble <func> | disas，反汇编指定的函数。  
/m 参数表示混合显示源代码与反汇编代码。  
  
## 6、GDB 环境与 Shell 交互

**命令** | **描述**  
---|---  
help <command> | 显示指定 GDB 命令的帮助信息。  
pipe <cmd> | <shell_cmd> | 将 GDB 命令 cmd 的输出通过管道传递给 Shell 命令。  
例如 pipe bt | less。  
shell <shell_cmd> | 在 GDB 内部执行一个 Shell 命令。  
例如 shell ls -l。  
  
# 四、openvela 典型调试场景

本节将理论应用于实践，展示如何使用 GDB 解决在 openvela（尤其是 sim 和硬件）开发中遇到的具体问题。

## 场景一：分析程序崩溃（Hard Fault, Crash）

### 问题描述

程序在 sim 或开发板上运行时突然崩溃，例如出现 ASan 错误、段错误或硬件异常（Data Abort, Prefetch Abort）。

### 调试策略

  1. **复现问题** ：使用 gdb ./nuttx 启动调试会话，然后输入 r 运行程序直至其崩溃。
  2. **定位崩溃点** ：程序崩溃后 GDB 会自动暂停。使用 bt 命令查看调用栈，最顶层的栈帧通常就是导致崩溃的直接原因。
  3. **分析上下文** ：使用 frame <num> 切换到可疑的栈帧，然后用 p <var> 和 info locals 检查当时的变量值，分析崩溃原因。
  4. **硬件异常分析** ：对于硬件异常，info registers 查看 PC (Program Counter), LR (Link Register) 等寄存器的值至关重要。使用 disassemble /m <PC_value> 可以查看崩溃时正在执行的汇编指令及其对应的源代码行。


## 场景二：程序卡死或死锁

### 问题描述

程序运行后终端无响应，CPU 占用率高，疑似进入死循环或死锁。

### 调试策略

  1. **中断程序** ：

     * 若程序在前台运行，直接在 GDB 中按 Ctrl + C。
     * 若程序在后台运行，先用 ps 找到 PID，然后执行 sudo gdb attach <PID>。附加成功后，程序会自动暂停。
     * 对于 sim 环境，也可在新终端执行 pkill -SIGSTOP nuttx 来暂停进程。
  2. **检查所有线程** ：输入 info threads 查看所有线程的状态，是否有线程处于异常状态或都在等待某个资源。

  3. **分析每个线程** ：使用 thread <id> 逐一切换到每个线程，然后用 bt 查看其调用栈，判断它们正在执行什么任务。这通常能快速定位到死循环或死锁的位置。


## 场景三：追踪变量的意外修改

### 问题描述

一个全局变量的值在某个时刻被错误地修改，但代码中有多处可能修改它的地方。

### 调试策略

  1. **设置观察点** ：启动 GDB 后，使用 watch my_global_variable 或 watch *<address_of_variable> 为该变量设置一个写观察点。
  2. **运行并等待** ：输入 run 或者 continue 启动或继续运行程序。当该变量的值被修改时，程序会立即暂停。
  3. **定位修改者** ：GDB 会报告变量的新旧值，并停在修改该变量的代码行。使用 bt 查看调用栈，即可找到修改变量的代码。


## 场景四：分析被编译器优化的变量

### 问题描述

在开启优化（如 -O2, -O3）后，尝试用 print 查看某个局部变量时，GDB 提示 <optimized out>。

### 原因分析

编译器为了效率，可能已将该变量优化掉，或将其值存放在了 CPU 寄存器中，而不是内存（栈）中。

### 调试策略

  1. **查看变量地址信息** ：使用 info address your_var。
  2. **解读输出** ：GDB 会告诉您该变量当前位于何处。

     * 如果它显示 "in register r5"，意味着变量的值就在 r5 寄存器中，您可以用 p $r5 来查看。
     * 如果它显示在某个栈地址，您仍然可以尝试用 x/w <address> 来查看内存。
  3. **终极手段** ：如果必须精确调试，请临时使用 -O0 关闭优化重新编译。


## 场景五：远程调试 Coredump 文件

### 问题描述

服务器上编译的程序在目标设备上崩溃并生成 coredump，您需要在本地分析，但源码路径不匹配。

### 调试策略

  1. **加载** **Coredump** ：gdb ./nuttx /path/to/coredump
  2. **查看原始路径** ：使用 info source 查看编译时记录的源码路径。
  3. **映射路径** ：使用 set substitute-path <original_path> <local_path> 命令进行路径替换。  

         
         # 示例：将服务器路径映射到本地路径
         set substitute-path /home/build-server/project/ /home/user/my_project/

  4. **开始分析** ：路径映射后，即可正常使用 bt、list 等命令查看源码。


# 五、GDB 工作原理

## 1、本地调试

在本地调试中，GDB 和被调试的程序运行在同一台计算机上。GDB 通过操作系统提供的 ptrace (在 Linux 上) 等系统调用来控制和检查目标进程。

## 2、远程调试

远程调试是嵌入式开发中最常见的模式。它采用客户端/服务器 (Client/Server) 架构：

  * **GDB Client** ：运行在您的开发主机上（例如，您的 PC）。
  * **GDB Server** ：一个轻量级程序，运行在目标设备上（例如，ARM 开发板）。
  * **通信协议** ：两者之间通过 GDB Remote Serial Protocol (RSP) 进行通信，通信介质可以是串口或网络 (TCP/IP)。


当您在 GDB Client 中输入 continue 时，Client 会将对应的 RSP 命令发送给 Server，Server 接收后控制目标程序继续执行。当程序遇到断点时，Server 会暂停程序，并将状态信息通过 RSP 回传给 Client 显示。

# 六、高级主题与相关实践

## 1、使用 GDB 脚本 (Command File)

当您需要重复执行一系列 GDB 命令时，可以将其写入一个文本文件（例如 my_setup.gdb），然后使用 source 命令加载：  

    
    
    source [-s] [-v] filename

  * -s 表示在系统的 PATH 环境变量中搜索指定文件。
  * -v 表示开启详细模式，显示每条指令的执行过程。


更多信息请参考：[Debugging with GDB - Command Files (gnu.org)](<https://ftp.gnu.org/old-gnu/Manuals/gdb/html_node/gdb_190.html>)

## 2、相关调试实践

  * **IDE 集成** ：关于如何在 VSCode 中配置 GDB 以调试 sim 环境，请参考[使用 VSCode 调试 SIM 环境](</document?id=743&version=dev&language=cn>)。
  * **线程感知调试** ：为了在 GDB 中更好地查看 openvela 的线程信息，可以利用 J-Link 的 GDB 插件，详情请参见[使用 J-Link GDB 插件增强 openvela 线程调试](</document?id=752&version=dev&language=cn>)。


# 七、故障排查 (Troubleshooting)

## GDB 启动时报错 ModuleNotFoundError: No module named 'encodings'

### 问题原因

这通常是由于 GDB 依赖的 Python 版本与您系统中默认或环境变量中配置的 Python 版本不兼容导致的。GDB 内部使用 Python 脚本来增强功能（如 pretty-printing），如果找不到正确的 Python 环境，就会启动失败。

### 解决方案

  1. 确认 GDB 需要的 Python 版本：错误信息通常会暗示所需的版本（例如 python3.8）。

  2. 安装对应版本：确保您的系统中安装了该版本的 Python，可参考[安装多个 Python 版本](<https://www.rosehosting.com/blog/how-to-install-and-switch-python-versions-on-ubuntu-20-04/>)。

  3. 配置 PYTHONHOME：如果安装后问题依旧，尝试设置 PYTHONHOME 环境变量，强制 GDB 使用正确的 Python 解释器。


# 八、参考资料

  * [GDB Official Documentation](<https://www.gnu.org/software/gdb/documentation/>) (官方文档)
  * [GDB Command Cheat Sheet](<https://darkdust.net/files/GDB%20Cheat%20Sheet.pdf>) (常用命令速查表)
  * [Interrupt Blog: Debugging Firmware with GDB](<https://interrupt.memfault.com/blog/gdb-for-firmware-1>) (面向嵌入式开发者的 GDB 优秀博文系列)

---

## 使用 VSCode 调试 SIM 环境

> 路径: GDB > 使用 VSCode 调试 SIM 环境
> 来源: [https://doc.openvela.com/document?id=743&language=cn&version=dev](https://doc.openvela.com/document?id=743&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/debugging_tools/GDB/VSCODE_debugging.md>) | 简体中文 ]

# 一、概述

本指南详细阐述了如何在 Visual Studio Code (VSCode) 中配置和使用 GDB，以实现对 **openvela** sim 仿真环境的图形化调试。通过 VSCode，您可以获得现代化的调试体验，包括设置断点、查看调用栈、监视变量和内存，从而显著提升开发与排错效率。

**核心流程包括：**

  1. **环境准备** ：安装必要的 VSCode 扩展。
  2. **项目配置** ：创建并配置 launch.json 文件，以告知 VSCode 如何启动调试会话。
  3. **实战调试** ：通过一个实际案例，演示如何启动调试、设置断点并分析程序状态。
  4. **高级主题** ：解决在特定场景（如 SMP、网络功能）下可能遇到的问题。


# 二、准备工作

在开始调试前，请确保您的开发环境满足以下要求。

## 1、环境要求

  * **Visual Studio Code** ：已安装。
  * **C/C++ 扩展** ：这是 VSCode 提供 C/C++ 语言支持和调试能力的核心插件。
  * **已编译的 sim 目标**：已成功编译 openvela 的 sim 版本，并确保生成了包含调试信息的可执行文件 (nuttx)。编译时必须包含 -g 或 -g3 标志。


## 2、VSCode 环境设置

### 步骤 1：安装 C/C++ 扩展

在 VSCode 的扩展市场中搜索 C/C++（由 Microsoft 发布），并单击安装。

### 步骤 2：打开项目工作区

启动 VSCode，通过菜单 File > Add Folder to Workspace...，将您的 openvela 项目根目录添加进来。这能确保 VSCode 正确解析 launch.json 中的 ${workspaceFolder} 变量。

# 三、调试配置 (launch.json)

launch.json 文件是 VSCode 调试功能的核心，它定义了如何启动和附加到您的程序。

## 1、创建 launch.json

  1. 切换到 VSCode 的 "Run and Debug" 视图（快捷键 Ctrl+Shift+D）。
  2. 单击 "create a launch.json file" 链接。
  3. 在弹出的选择框中，选择 **C++** **(GDB/LLDB)** 。
  4. VSCode 将会自动生成一个 launch.json 模板文件，并保存在项目根目录的 .vscode 文件夹下。


## 2、配置 launch.json

将 launch.json 的内容替换为以下配置。此配置专门为调试 openvela sim 环境定制。  

    
    
    {
        "version": "0.2.0",
        "configurations": [
            {
                "name": "Debug openvela (sim)",
                "type": "cppdbg",
                "request": "launch",
                "program": "${workspaceFolder}/nuttx/nuttx",
                "stopAtEntry": false,
                "cwd": "${workspaceFolder}/nuttx",
                "environment": [],
                "console": "externalTerminal",
                "MIMode": "gdb",
                "setupCommands": [
                    {
                        "description": "Enable pretty-printing for gdb",
                        "text": "-enable-pretty-printing",
                        "ignoreFailures": true
                    }
                ]
            }
        ]
    }

### 配置项解析

**属性** | **值** | **说明**  
---|---|---  
name | Debug openvela (sim) | 调试配置的名称，将显示在 VSCode 的调试下拉菜单中。  
type | cppdbg | 指定使用 C/C++ 扩展进行调试。  
request | launch | 表示这是一个 "启动" 型的调试会话，VSCode 将负责启动程序。  
program | ${workspaceFolder}/nuttx/nuttx | **关键配置项** 。  
指定要调试的可执行文件的路径。${workspaceFolder} 代表您在 VSCode 中打开的项目根目录。  
stopAtEntry | false | 如果设为 true，程序会在入口点（如 _start）处自动暂停。  
通常设为 false，让程序直接运行到我们设置的断点。  
cwd | ${workspaceFolder}/nuttx | 设置被调试程序的工作目录。  
对于 sim 环境，这通常是包含 nuttx 可执行文件的目录。  
console | externalTerminal | 指定在一个**外部终端** 中运行程序。  
这对于需要与 NuttShell (NSH) 交互的 sim 环境至关重要，您可以在该终端中输入命令。  
MIMode | gdb | 指定使用的调试器后端为 GDB。  
setupCommands | [...] | GDB 启动后、程序运行前执行的命令。  
这里默认启用了 "pretty-printing"，以更友好的格式显示 STL 等复杂数据结构。  
  
# 四、调试实战

下面，我们以调试 ping 命令为例，走完整个流程。

## 步骤 1：打开源码并设置断点

在 VSCode 中，打开文件 apps/system/ping/ping.c。在 ping_main 函数的入口处（或任意您感兴趣的行），点击行号左侧的空白区域，设置一个红点断点。

## 步骤 2：启动调试会话

按下 F5 键或点击 "Run and Debug" 视图中的绿色启动按钮。VSCode 将：

  * 启动 GDB。
  * 打开一个新的外部终端窗口。
  * 在该终端中运行 nuttx 程序，您会看到 NSH 的启动提示符 nsh>。


## 步骤 3：触发断点

在 nsh> 提示符所在的**外部终端** 中，输入触发断点的命令：  

    
    
    nsh> ping 127.0.0.1

## 步骤 4：分析程序状态

当程序执行到 ping_main 时，您会看到：

  * VSCode 窗口自动获得焦点。
  * 代码视图中的断点行高亮显示。
  * 左侧的调试面板中填充了实时信息：
    * **VARIABLES** ：显示当前作用域内的局部变量和全局变量的值。
    * **WATCH** ：您可以添加表达式来持续监视其值的变化。
    * **CALL STACK** ：清晰地展示了函数调用栈，帮助您理解程序的执行路径。
    * **BREAKPOINTS** ：管理您设置的所有断点。


# 五、高级主题与常见问题

## 1、处理 SMP 调试中的 SIGUSR1 信号

### 问题现象

如果您的 openvela 配置启用了对称多处理（SMP），在调试时程序可能会在启动后不久就因 SIGUSR1 信号而意外暂停。

### 原因分析

openvela 在 SMP 模式下使用 SIGUSR1 信号进行核间任务调度和通信。默认情况下，GDB 会捕获所有信号并暂停程序，这干扰了系统的正常运行。

### 解决方案

您可以通过创建 GDB 的全局初始化脚本，让它忽略此信号。

  1. 创建一个文件：~/.gdbinit（位于您的用户主目录下）。
  2. 在该文件中添加以下命令：  

         
         # Instruct GDB to not stop or print a message for SIGUSR1
         handle SIGUSR1 nostop noprint

  3. 保存文件。GDB 在每次启动时都会自动加载并执行此文件中的命令，从而解决了该问题。


## 2、为 sim 获取 Root 权限

### 问题场景

sim 环境的某些高级功能，特别是网络相关的（如使用 TAP 设备与主机系统通信），需要 root 权限才能正常工作。直接使用 sudo F5 是不可行的。

### 解决方案

推荐的方案是配置 sudo，允许您的用户账户在不输入密码的情况下以 root 身份运行 gdb。

  1. 配置免密 sudo。

为了安全和规范，我们通过在 /etc/sudoers.d/ 目录下创建特定配置文件来实现。这种方法比直接修改主 sudoers 文件更安全。

在您的 Linux 终端中执行以下命令，将 your_username 替换为您的实际用户名：  

         
         # 使用您的用户名替换 your_username
         echo "your_username ALL=(ALL) NOPASSWD: /usr/bin/gdb" | sudo tee /etc/sudoers.d/gdb-nopasswd

  2. 创建 GDB 脚本。

在您的项目根目录下（例如 openvela/），创建一个名为 sudo-gdb.sh 的文件，并填入以下内容：  

         
         #!/bin/bash
         # This script acts as a wrapper to launch gdb with sudo.
         sudo /usr/bin/gdb "$@"

然后，赋予此脚本可执行权限：  

         
         chmod +x sudo-gdb.sh

  3. 修改 launch.json。

修改 .vscode/launch.json 文件，在您的调试配置中添加 "miDebuggerPath" 属性，使其指向我们刚刚创建的脚本。  

         
         {
             "name": "Debug openvela (sim) with Root",
             "type": "cppdbg",
             "request": "launch",
             "program": "${workspaceFolder}/nuttx/nuttx",
             "miDebuggerPath": "${workspaceFolder}/sudo-gdb.sh", // <-- 添加此行
             "stopAtEntry": false,
             "cwd": "${workspaceFolder}/nuttx",
             "environment": [],
             "console": "externalTerminal",
             "MIMode": "gdb",
             "setupCommands": [
                 {
                     "description": "Enable pretty-printing for gdb",
                     "text": "-enable-pretty-printing",
                     "ignoreFailures": true
                 }
             ]
         }


完成以上步骤后，选择新的调试配置并按 F5 启动，您的 sim 程序就会以 root 权限运行。

# 六、参考资料

  * [Visual Studio Code Docs: Debugging](<https://code.visualstudio.com/docs/editor/debugging>)
  * [MCU on Eclipse: VS Code for C/C++ with ARM Cortex-M](<https://mcuoneclipse.com/2021/05/01/visual-studio-code-for-c-c-with-arm-cortex-m-part-1/>)
  * [MCU on Eclipse: VS Code Data Breakpoints and Watchpoints](<https://mcuoneclipse.com/2023/11/14/vs-code-data-breakpoints-and-watchpoints/>)
  * [Gunnar Peipman's Blog: Browse WSL files with Windows Explorer](<https://gunnarpeipman.com/browse-wsl-with-explorer/>)

---

## Backtrace 使用指南

> 路径: 离线调试 > Backtrace 使用指南
> 来源: [https://doc.openvela.com/document?id=745&language=cn&version=dev](https://doc.openvela.com/document?id=745&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/debugging_tools/offline_debugging/backtrace.md>) | 简体中文 ]

# 一、概述

在日常开发中，我们常常需要查看指定线程的栈信息，常见的场景包括：

  * 死锁（deadlock）
  * 高 CPU 使用率（high CPU usage）
  * 忙循环（busy loop）
  * 系统崩溃（crash）
  * 内存调试（memory debug）


通常情况下，借助调试工具（如 JLink），可以通过 gdb 和断点（breakpoint，简称 bp）的方式实现这些功能。但在设备封包发布和外围调试功能关闭之后，这些功能在真实设备上往往无法使用。

为了解决这一问题，openvela 支持在运行环境中查看特定线程的栈信息。

# 二、配置说明

## 1、通用配置说明

openvela 支持 ARM、RISC-V 和 Xtensa 三种架构的通用配置，具体如下：  

    
    
    # 开启 backtrace 功能，默认不显示函数名称
    CONFIG_SCHED_BACKTRACE=y
    CONFIG_SYSTEM_DUMPSTACK=y
    
    # 如果需要符号名支持，启用以下选项；  
    # 若 Flash 空间不足，可以通过 addr2line 手动解析地址到符号  
    CONFIG_ALLSYMS=y
    
    # 启用架构支持  
    CONFIG_ARCH_HAVE_BACKTRACE=y

对于 ARM 平台，由于代码资源限制及 Thumb-2 特性的要求，提供以下三种 backtrace 实现方式供选择：  

    
    
    # 基于帧指针（frame pointer）的回溯实现
    CONFIG_UNWINDER_FRAME_POINTER
    
    # 基于栈指针（stack pointer）的回溯实现 
    CONFIG_UNWINDER_STACK_POINTER
    
    # 基于 ARM 架构的 .exidx 段的回溯实现
    CONFIG_UNWINDER_ARM

目前，openvela 支持 ARM、RISC-V 和 Xtensa 三种体系结构的 backtrace 功能，各架构的配置和实现如下。

## 2、ARM

### ARM Cortex-A/R

在 ARM Cortex-A 和 Cortex-R 系列中，backtrace 实现支持以下两种方式，选择其中一种即可：  

    
    
    # 方式 1：基于 fp 寄存器的回溯实现  
    CONFIG_UNWINDER_FRAME_POINTER
    
    # 方式 2：基于 .exidx 段的回溯实现 
    CONFIG_UNWINDER_ARM

### ARM Cortex-M

在 ARM Cortex-M 系列中，backtrace 有以下三种实现方式，根据项目需求选择其一：  

    
    
    # 方式 1：基于 fp 的回溯实现（需注意编译器限制）  
    CONFIG_UNWINDER_FRAME_POINTER=y  
    
    # 方式 2：基于 sp 的回溯实现，适用于小资源设备  
    CONFIG_UNWINDER_STACK_POINTER=y  
    
    # 方式 3：基于 .exidx 段的回溯实现  
    CONFIG_UNWINDER_ARM=y

  * CONFIG_UNWINDER_FRAME_POINTER：GCC 编译器上存在相关限制（详情参考 [GCC 问题](<https://gcc.gnu.org/bugzilla/show_bug.cgi?id=92172>)）。
  * CONFIG_UNWINDER_STACK_POINTER：通过 bl/blx 指令获取 pc 地址，适用于资源有限的设备，但存在一定的误判概率。如果项目代码被分散到多个区域，需要通过以下 API 配置多个代码区域：  

        
        void up_backtrace_init_code_regions(FAR void **regions)

  * CONFIG_UNWINDER_ARM：在编译阶段生成 .exidx 段，代码体积增加 5%-8%。


## 3、RISC-V

在 RISC-V 架构中，backtrace 基于帧指针（frame pointer）实现，只需启用以下配置：  

    
    
    CONFIG_FRAME_POINTER=y
    CONFIG_SCHED_BACKTRACE=y

更多信息参考：[RISC-V Backtrace 实现](<https://github.com/open-vela//nuttx/blob/dev/arch/risc-v/src/common/riscv_backtrace.c>)

## 4、Xtensa

在 Xtensa 架构中，backtrace 默认支持栈回溯，不需要额外启用 -fno-omit-frame-pointer 选项。

# 三、操作使用

在代码中使用 backtrace 系列函数需要包含头文件 #include <execinfo.h>。本章介绍如何使用 backtrace 获取函数调用堆栈信息、打印日志及定位错误行。

## 1、在代码中使用 backtrace

使用 backtrace 系列函数可以捕获当前程序状态，打印堆栈信息。以下是常见函数说明，

更多细节请参考 Linux Man Page: [backtrace](<https://man7.org/linux/man-pages/man3/backtrace.3.html>)。  

    
    
    #include<execinfo.h>
    
    /* 存储当前程序状态至__array数组，array最大数量为__size
        返回值为实际存储的元素个数 
    */
    extern int backtrace (void **__array, int __size) __nonnull ((1));
    
    /*  
      功能：返回一个字符串数组，存放从 backtrace 获取的信息。  
      参数：  
        - __array: backtrace 返回的指针数组  
        - __size:  backtrace 的返回值  
      注意：该方法会调用 `backtrace_malloc(FAR void *const *buffer, int size)` 申请空间，定义在   
      nuttx/libs/libc/misc/lib_execinfo.c 文件中。  
    */  
    extern char **backtrace_symbols (void *const *__array, int __size)
         __THROW __nonnull ((1));
    
    /*  
      功能：和 backtrace_symbols 类似，但无需申请额外空间，直接写入文件描述符 __fd。  
    */  
    extern void backtrace_symbols_fd (void *const *__array, int __size, int __fd)
         __THROW __nonnull ((1));

## 2、dump_stack()

  1. 在 openvela 系统中，可以直接调用 dump_stack() 函数打印堆栈信息。例如：  

         
         // 在 examples/hello/hello_main.c 文件中添加测试代码
         37 int main(int argc, FAR char *argv[])
         38 {
         39   printf("Hello, World!!\n");
         +40   dump_stack();  // 打印堆栈信息  
         41   return 0;
         42 }

打印输出示例：  

         
         ap> hello
         Hello, World!!
         [07:06:21] [28] [  INFO] [BackTrace|28|0]:   0xc070a96  0xc063d7c  0xc0809bc  0xc063d38  0xc0587de

  2. 使用 addr2line 工具解析打印出的回溯地址到具体的代码行：  

         
         addr2line -fe nuttx 0xc070a96  0xc063d7c  0xc0809bc  0xc063d38  0xc0587de

解析结果示例：  

         
         nuttx/arch/arm/src/armv8-m/arm_backtrace.c:446
         nuttx/libs/libc/sched/sched_dumpstack.c:60
         apps/examples/hello/hello_main.c:40
         nuttx/libs/libc/sched/task_startup.c:151
         nuttx/sched/task/task_start.c:130

  3. 利用 dump_stack() 的地址定位错误位置，或者通过[打开符号表](</document?id=746&version=dev&language=cn>)功能直接打印函数名称，方便分析。


## 3、dumpstack 命令

在命令行中，可以使用 dumpstack 命令获取指定任务的 backtrace。以下是使用方法：

### 使用 dumpstack [pid] 获取任务堆栈

  1. 获取进程的堆栈。  

         
         # 查看进程状态
         ap> ps
         ...
         26       100 RR       Task    --- Waiting  Semaphore 00000010 004056 000648  15.9%    0.0% Telnet daemon 0x3c4293e0
         
         # 查看 PID 为 26 的 backtrace
         ap> dumpstack 26
         [15:18:53] [29] [  INFO] [BackTrace|26|0]:   0xc06b1c2   0x2154aa   0x20f312  0xc2ca118  0xc2c9bc4  0xc2c9c34  0xc08d894  0xc063d38
         [15:18:53] [29] [  INFO] [BackTrace|26|1]:   0xc0587de

  2. 使用 addr2line 解析回溯地址。  

         
         addr2line -e nuttx 0xc06b1c2   0x2154aa   0x20f312  0xc2ca118  0xc2c9bc4  0xc2c9c34  0xc08d894  0xc063d38

  3. 查看解析结果。

解析结果示例如下：  

         
         nuttx/arch/arm/src/armv8-m/arm_switchcontext.S:79
         nuttx/net/utils/net_lock.c:128
         nuttx/net/tcp/tcp_accept.c:281
         nuttx/net/inet/inet_sockif.c:889
         nuttx/net/socket/accept.c:141 (discriminator 4)
         nuttx/net/socket/accept.c:270
         apps/netutils/telnetd/telnetd_daemon.c:240 (discriminator 3)
         nuttx/libs/libc/sched/task_startup.c:151


### 使用 dumpstack [pid_start] [pid_end] 查看多个进程堆栈

查看 PID 从 0 到 26 的 backtrace 信息：  

    
    
    ap> dumpstack 0 26  
    [15:21:07] [30] [  INFO] [BackTrace|0|0]:  0xc054ba0  0xc3129f0  0xc000056  
    [15:21:07] [30] [  INFO] [BackTrace|1|0]:  0xc06b1c2  0xc0572e2  0xc0595e6  0xc0587d4  
    [15:21:07] [30] [  INFO] [BackTrace|26|0]:  0xc06b1c2  0xc2154aa  0xc0587d4  
    ...

## 4、crash 日志中的调用栈解析
    
    
    [15:21:21] [25] [  INFO] [BackTrace|25|0]:   0xc070aa6  0xc063d7c  0xc070f58  0xc060948  0xc06b2a2  0xc054d1e  0xc070dc8  0xc06b21e
    [15:21:21] [25] [  INFO] [BackTrace|25|1]:   0xc087556  0xc0847fa  0xc087864  0xc0889b4  0xc0837a8  0xc063d38  0xc0587de
    
    crash thread 25:
    
    $ addr2line -e nuttx 0xc070aa6  0xc063d7c  0xc070efc  0xc0569c8  0xc070fba  0xc060948  0xc06b2a2  0xc054d1e 0xc070dc8  0xc06b21e  0xc087556  0xc0847fa  0xc087864  0xc0889b4  0xc0837a8  0xc063d38
    nuttx/arch/arm/src/armv8-m/arm_backtrace.c:446
    nuttx/libs/libc/sched/sched_dumpstack.c:60
    nuttx/arch/arm/src/armv8-m/arm_assert.c:167

---

## Allsyms 符号表功能使用指南

> 路径: 离线调试 > Allsyms 符号表功能使用指南
> 来源: [https://doc.openvela.com/document?id=746&language=cn&version=dev](https://doc.openvela.com/document?id=746&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/debugging_tools/offline_debugging/allsyms_guide.md>) | 简体中文 ]

本文档指导您如何在 openvela 系统中启用并使用 **Allsyms** 功能。通过启用此功能，您可以将完整的符号表编译到固件镜像中，从而在设备运行时将函数地址直接解析为可读的函数名，提升在线调试（例如分析崩溃栈）的效率。

# 一、前置条件

在编译包含 **Allsyms** 功能的固件前，您必须确保开发环境中已安装以下 Python 依赖包。构建系统使用这些工具来解析 ELF 文件并生成符号表。

请在您的终端中运行以下命令进行安装：  

    
    
    pip3 install pyelftools cxxfilt

# 二、如何启用 Allsyms

> **警告**
> 
> 启用 **Allsyms** 功能会显著增加最终固件镜像的体积。请在评估存储空间后，仅在调试版本中开启此功能。

要启用此功能，您只需在项目的配置文件中添加以下配置项：  

    
    
    CONFIG_ALLSYMS=y

此功能的底层实现代码位于 openvela 的以下路径： nuttx/libs/libc/symtab

# 三、使用方法

启用 **Allsyms** 后，您可以通过以下几种方式利用符号表进行调试。

## 1、在回溯跟踪中自动显示函数名

这是 **Allsyms** 最核心的应用场景。当系统发生崩溃或您手动调用 dumpstack、sched_dumpstack 等函数时，系统打印的回溯跟踪（Backtrace）将不再是裸地址，而是自动解析后的函数名，方便您快速定位问题。

## 2、在 printf 中格式化输出符号

您可以在 printf 系列函数中使用 %pS 格式说明符，直接打印指定地址对应的符号信息。如果找不到匹配的符号，系统将打印原始地址。

**代码示例：**  

    
    
    #include <stdio.h>
    extern void hello_world(void);
    void my_debug_function(void)
    {
      // 打印 hello_world 函数的符号名和地址
      printf("Symbol info for hello_world: %pS\n", hello_world);
    }

## 3、使用 API 手动查询符号

openvela 提供了两个核心 API，允许您在代码中实现函数名与地址的相互转换。

  * allsyms_findbyname()：根据函数名查找其地址。
  * allsyms_findbyvalue()：根据地址查找最接近的函数名。


# 四、API 参考

以下是 **Allsyms** 功能相关的核心数据结构与函数原型。

## 1、struct symtab_s

此结构体定义了符号表中的单个条目。  

    
    
    /* struct symbtab_s describes one entry in the symbol table.  A symbol table
     * is a fixed size array of struct symtab_s. The information is intentionally
     * minimal and supports only:
     *
     * 1. Function pointers as sym_values.  Of other kinds of values need to be
     *    supported, then typing information would also need to be included in
     *    the structure.
     *
     * 2. Fixed size arrays.  There is no explicit provisional for dynamically
     *    adding or removing entries from the symbol table (realloc might be
     *    used for that purpose if needed).  The intention is to support only
     *    fixed size arrays completely defined at compilation or link time.
     */
    
    struct symtab_s
    {
      FAR const char *sym_name;  /* A pointer to the symbol name string */
      FAR const void *sym_value; /* The value associated with the string */
    };

## 2、allsyms_findbyname()

根据符号名称查找符号表条目。  

    
    
    /****************************************************************************
     * Name: allsyms_findbyname
     *
     * Description:
     *   Find the symbol in the symbol table with the matching name.
     *
     * Returned Value:
     *   A reference to the symbol table entry if an entry with the matching
     *   name is found; NULL is returned if the entry is not found.
     *
     ****************************************************************************/
    
    FAR const struct symtab_s *allsyms_findbyname(FAR const char *name,
                                                  FAR size_t *size);

## 3、allsyms_findbyvalue()

根据值（地址）查找符号表条目。  

    
    
    /****************************************************************************
     * Name: symtab_findbyvalue
     *
     * Description:
     *   Find the symbol in the symbol table whose value closest (but not greater
     *   than), the provided value. This version assumes that table is not
     *   ordered with respect to symbol value and, hence, access time will be
     *   linear with respect to nsyms.
     *
     * Returned Value:
     *   A reference to the symbol table entry if an entry with the matching
     *   name is found; NULL is returned if the entry is not found.
     *
     ****************************************************************************/
    
    FAR const struct symtab_s *allsyms_findbyvalue(FAR void *value,
                                                   FAR size_t *size);

# 四、FAQ

## 1、编译时提示缺少 elftools 或 cxxfilt 模块

### 问题描述

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455186999_001.jpg)

### 原因分析

这是因为 **Allsyms** 功能的构建过程依赖这两个 **Python** 工具来处理 **ELF** 文件并提取符号信息。

### 解决方案

请参照本文档的[前置条件](<#前置条件>)章节，使用 pip3 命令安装它们。

# 五、相关文档

  * [Backtrace 使用指南](</document?id=745&version=dev&language=cn>)

---

## 使用 AddressSanitizer 调试内存错误

> 路径: 内存检测 > 使用 AddressSanitizer 调试内存错误
> 来源: [https://doc.openvela.com/document?id=748&language=cn&version=dev](https://doc.openvela.com/document?id=748&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/debugging_tools/crash/memory/heap/ASan.md>) | 简体中文 ]

AddressSanitizer (ASan) 是一款基于编译器的、高效的内存错误检测工具，能够帮助开发者在运行时精确地发现和诊断各类内存问题。本指南详细介绍如何在 openvela 的 simulator 平台中启用和使用 ASan。

**注意** ：当前 AddressSanitizer 功能仅在 simulator 平台上受支持。

# 一、概述

AddressSanitizer (ASan) 是 [Google Sanitizer Tools](<https://github.com/google/sanitizers>) 的一部分，它通过在编译时对代码进行插桩 (Instrumentation) 并在运行时链接一个专用的库来工作。这种机制使其能够以中等的性能开销高效地捕获多种内存错误。

ASan 可以检测以下常见问题：

  * **越界访问 (Out-of-Bounds Access)** ：对堆、栈及全局变量的访问超出了其合法边界。
  * **释放后使用 (Use-after-Free)** ：访问了已经被 free() 或 delete 回收的内存。
  * **返回后使用 (Use-after-Return)** ：访问了函数返回后其栈帧上的局部变量。
  * **作用域后使用 (Use-after-Scope)** ：访问了生命周期已在作用域 {} 内结束的局部变量。
  * **重复释放 (Double-Free)** ：对同一块内存执行了两次 free()。
  * **无效释放 (Invalid-Free)** ：释放了无效的或未分配的内存地址。
  * **内存泄漏** **(Memory Leaks)** ：由集成的 LeakSanitizer (LSan) 检测，找出已分配但无法再访问的内存。
  * **初始化顺序错误 (Initialization-Order-Fiasco)** ：检测 C++ 中跨编译单元的全局变量初始化顺序问题。


# 二、ASan 工作原理

ASan 主要由**编译器插桩** 模块和**运行时库** 两部分协同工作。

## 1、编译器插桩 (Compiler Instrumentation)

启用 ASan 后，编译器会在程序的每一次内存访问（读/写）操作前后，自动插入用于验证访问合法性的检查代码。效果如下所示：

![alt text](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455187308_001.png)

## 2、运行时库 (Runtime Library)

ASan 的运行时库 (libasan) 接管了标准的内存管理函数（如 malloc 和 free），并引入了**影子内存 (Shadow Memory)** 和**内存中毒 (Memory Poisoning)** 机制。

  * **影子内存 (Shadow Memory)** ：ASan 将一部分虚拟地址空间保留为影子内存。影子内存中的一个字节用于描述主应用程序内存中对应的 8 个字节的状态（例如：不可访问、完全可访问、部分可访问）。

  * **内存中毒 (Poisoning)** ：

    * **分配时** ：当调用 malloc 分配内存时，ASan 运行时库会在请求的内存区域周围分配额外的“红区 (Redzone)”。这些红区和对齐产生的填充字节会被标记为“中毒”，任何对它们的访问都会被立即报告为错误。
    * **释放时** ：当调用 free 释放内存时，整块内存区域（包括原先的有效区域和红区）都会被标记为“中毒”，并被放入一个隔离队列中。这块内存暂时不会被重新分配，从而能有效地检测出“释放后使用”的错误。


![alt text](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455187425_002.png)

## 3、检测算法

每次内存访问时，编译器插入的检查代码会执行以下伪代码逻辑：

  1. 根据访问地址 Addr 计算出其在影子内存中的对应地址 ShadowAddr。
  2. 读取影子字节 k 的值。k 描述了 Addr 所在 8 字节对齐块的状态。
  3. 检查访问是否合法：

     * 如果 k 为 0，表示 8 字节全部可访问。
     * 如果 k 为负数，表示整个 8 字节块不可访问（例如，红区或已释放内存）。
     * 如果 k 为正数（1 到 7），表示前 k 个字节可访问。
     * 如果访问越过了 k 定义的边界，则判定为内存错误。  

           
           // 伪代码表示检测逻辑
           ShadowAddr = (Addr >> 3) + Offset;   // 计算影子地址
           k = *ShadowAddr;                     // 读取影子字节 
           if (k != 0 && ((Addr & 7) + AccessSize > k)) {
               ReportAndCrash(Addr);            // 如果访问非法，则报告错误并终止程序
           }


![alt text](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455187522_003.png)

# 三、如何在 openvela 中使用 ASan

在 simulator 平台启用 ASan 非常简单，只需三个步骤。

## 步骤 1：启用 ASan 配置

通过 menuconfig 或直接修改 .config 文件，启用以下 Kconfig 选项：  

    
    
    # 在 sim 平台启用 Address Sanitizer
    CONFIG_SIM_ASAN=y

**说明** ：启用此选项后，构建系统会自动为编译器和链接器添加 -fsanitize=address 选项，并为了获得更清晰的堆栈跟踪信息，通常会附带 -fno-omit-frame-pointer 选项。

## 步骤 2：编译并运行

执行标准编译流程，然后启动 simulator 运行您的应用程序。  

    
    
    # 运行模拟器（示例）
    ./emulator.sh vela

## 步骤 3：分析错误报告

若 ASan 检测到内存错误，程序将立即终止并打印详细报告。一份典型的 ASan 报告包含以下关键信息：  

    
    
    # 1. 错误摘要：指明错误类型 (heap-use-after-free) 和非法访问的地址。
    ==9901==ERROR: AddressSanitizer: heap-use-after-free on address 0x60700000dfb5
    
    # 2. 访问详情和堆栈跟踪：显示非法的内存操作 (READ of size 1) 及其发生位置。
    READ of size 1 at 0x60700000dfb5 thread T0
        #0 0x45917a in main use-after-free.c:5
        #1 0x7fce9f25e76c in __libc_start_main ...
    
    # 3. 内存位置描述：说明非法地址位于哪个内存区域。
    0x60700000dfb5 is located 5 bytes inside of 80-byte region [0x60700000dfb0,0x60700000e000)
    
    # 4. 释放点堆栈跟踪：(若适用) 显示该内存块在何处被释放。
    freed by thread T0 here:
        #0 0x4441ee in __interceptor_free ...
        #1 0x45914a in main use-after-free.c:4
    
    # 5. 分配点堆栈跟踪：显示该内存块最初在何处被分配。
    previously allocated by thread T0 here:
        #0 0x44436e in __interceptor_malloc ...
        #1 0x45913f in main use-after-free.c:3
    
    # 6. 最终概要：对整个错误的简洁总结。
    SUMMARY: AddressSanitizer: heap-use-after-free use-after-free.c:5 main

# 四、常见错误类型及示例

以下是 ASan 可以检测到的几种典型内存错误。

## 1、堆内存释放后使用 (Heap-use-after-free)

**场景** ：访问已通过 free 或 delete 释放的堆内存。

**示例代码** ：  

    
    
    5 int main (int argc, char** argv)
    6 {
    7     int* array = new int[100];
    8     delete []array;
    9     return array[1];  // <-- 错误：访问已释放的内存
     10 }

**错误报告摘要** ：  

    
    
    ==3189==ERROR: AddressSanitizer: heap-use-after-free on address 0x61400000fe44
    ...
    freed by thread T0 here:
        #1 0x4008b5 in main /home/ron/dev/as/use_after_free.cpp:8
    previously allocated by thread T0 here:
        #1 0x40089e in main /home/ron/dev/as/use_after_free.cpp:7

## 2、堆缓冲区溢出 (Heap-buffer-overflow)

**场景** ：访问堆上分配的内存区域时超出了其边界。

**示例代码** ：   

    
    
    2 int main (int argc, char** argv)
    3 {
    4     int* array = new int[100];
    5     int res = array[100];  // <-- 错误：访问第 101 个元素，越界
    6     delete [] array;
    7     return res;
    8 }

**错误报告摘要** ：  

    
    
    ==3322==ERROR: AddressSanitizer: heap-buffer-overflow on address 0x61400000ffd0
    ...
    0x61400000ffd0 is located 0 bytes to the right of 400-byte region [0x61400000fe40,0x61400000ffd0)
    allocated by thread T0 here:
        #1 0x40089e in main /home/ron/dev/as/heap_buf_overflow.cpp:4

## 3、栈缓冲区溢出 (Stack-buffer-overflow)

**场景** ：访问栈上分配的局部变量时超出了其边界。

**示例代码** ：  

    
    
    2 int main (int argc, char** argv)
    3 {
    4     int array[100];
    5     return array[100];  // <-- 错误：访问第 101 个元素，越界
    6 }

**错误报告摘要** ：  

    
    
    ==3389==ERROR: AddressSanitizer: stack-buffer-overflow on address 0x7ffd061fa4a0
    ...
    Address 0x7ffd061fa4a0 is located in stack of thread T0 at offset 432 in frame
        #0 0x400935 in main /home/ron/dev/as/stack_buf_overflow.cpp:3
      This frame has 1 object(s):
        [32, 432) 'array' <== Memory access at offset 432 overflows this variable

## 4、全局变量缓冲区溢出 (Global-buffer-overflow)

**场景** ：访问全局或静态变量时超出了其边界。

**示例代码** ：  

    
    
    2 int array[100];
    3 
    4 int main (int argc, char** argv)
    5 {
    6     return array[100]; // <-- 错误：访问第 101 个元素，越界
    7 }

**错误报告摘要** ：  

    
    
    ==3499==ERROR: AddressSanitizer: global-buffer-overflow on address 0x000000601270
    ...
    0x000000601270 is located 0 bytes to the right of global variable 'array' defined in '...'

## 5、返回后使用 (Use-after-return)

**场景** ：函数返回后，其栈帧被销毁，但程序仍然通过指针访问该栈上的局部变量。

**示例代码** ：  

    
    
    int *ptr;
    __attribute__((noinline))
    void FunctionThatEscapesLocalObject() {
      int local[100];
      ptr = &local[0];  // ptr 指向一个即将被销毁的局部变量
    }
    
    int main(int argc, char **argv) {
      FunctionThatEscapesLocalObject();
      return ptr[argc];  // <-- 错误：访问已失效的栈内存
    }

**错误报告摘要** ：  

    
    
    ==6268== ERROR: AddressSanitizer: stack-use-after-return on address 0x7fa19a8fc024

## 6、作用域后使用 (Use-after-scope)

**场景** ：变量的生命周期在一个作用域 ({...}) 内结束，但在该作用域外仍被访问。

**示例代码** ：  

    
    
    volatile int *p = 0;
    
    int main() {
      {
        int x = 0;
        p = &x
      }  // x 的作用域在此结束
      *p = 5;  // <-- 错误：访问已失效的栈内存
      return 0;
    }

**错误报告摘要** ：  

    
    
    ==58237==ERROR: AddressSanitizer: stack-use-after-scope on address 0x7ffc4d830880

## 7\. 初始化顺序错误 (Initialization-Order-Fiasco)

**场景** ：此问题主要发生在 C++ 中。当一个单元（.cpp 文件）中的全局变量的初始化依赖于另一个单元中尚未初始化的全局变量时，就会发生此错误。

**示例** ：  

    
    
    // a.cc
    extern int extern_global;
    int x = extern_global + 1; // <-- 错误：在 extern_global 初始化前读取它
    // b.cc
    int extern_global = 42;

**错误报告摘要** ：  

    
    
    ==ERROR: AddressSanitizer: initialization-order-fiasco on address 0x...
    READ of size 4 at 0x...
    ... is located 0 bytes inside of global variable 'extern_global' from 'b.cc'

## 8、内存泄漏 (Memory Leak)

**场景** ：分配的堆内存（通过 malloc 或 new）在不再需要时没有被正确释放，导致内存占用持续增长。此功能由 LeakSanitizer (LSan) 提供，它默认集成在 ASan 中。

**示例代码** ：  

    
    
    4 void* p;
    5 
    6 int main ()
    7 {
    8     p = malloc (7);
    9     p = 0;           // <-- 错误：原始指针丢失，7字节内存泄漏
     10     return 0;
     11 }

**错误报告摘要** ：  

    
    
    ==4088==ERROR: LeakSanitizer: detected memory leaks
    
    Direct leak of 7 byte(s) in 1 object(s) allocated from:
        #0 0x7ff9ae510602 in malloc (...)
        #1 0x4008d3 in main /home/ron/dev/as/mem_leak.cpp:8

**RTOS 环境下的内存泄漏说明**

  * 在 openvela 等 RTOS 中，任务（Task）退出时，其动态分配的内存通常不会被系统自动回收，这与桌面操作系统的进程（Process）行为不同。
  * LeakSanitizer 通过追踪指针是否丢失来判断泄漏。如果一个指针直到任务结束仍然可达，即使内存未释放，LSan 也可能不会报告为泄漏。
  * 因此，开发者需要自行确保所有动态分配的内存在不再使用时被显式释放。


# 五、结合 GDB 进行高级调试

当 ASan 检测到错误并终止程序时，您可能希望在错误发生的确切位置进行交互式调试。为此，您可以在 GDB 中对 ASan 的报告函数设置一个断点。在 GDB 中，使用以下命令：  

    
    
    # 在 ASan 报告错误的函数处设置断点
    b __asan::ReportGenericError

当程序触发内存错误时，执行会停在断点处，此时你可以使用标准的 GDB 命令（如 bt, p, info locals）来检查调用堆栈、变量值和程序状态，从而更深入地分析问题根源。

# 六、参考资料

  * **Google Sanitizers Project Wiki** : https://github.com/google/sanitizers/wiki/AddressSanitizer
  * **Clang Documentation on AddressSanitizer** : https://clang.llvm.org/docs/AddressSanitizer.html

---

## 使用 _FORTIFY_SOURCE 增强 C 语言内存安全性

> 路径: 内存检测 > 使用 _FORTIFY_SOURCE 增强 C 语言内存安全性
> 来源: [https://doc.openvela.com/document?id=749&language=cn&version=dev](https://doc.openvela.com/document?id=749&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/debugging_tools/crash/memory/heap/fortify_source.md>) | 简体中文 ]

本文档全面介绍了 _FORTIFY_SOURCE 的功能、配置和原理，并对其与 KASan 的差异进行了分析。通过阅读本文，开发者可以理解如何利用 **_FORTIFY_SOURCE** 检测并避免库函数引发的越界问题，从而提升应用程序的安全性。

# 一、概述

在 C 语言程序开发中，不安全的函数调用（例如 **memcpy** 、**memset** ）是导致缓冲区溢出的常见原因，这可能引发程序崩溃或安全漏洞。

**_FORTIFY_SOURCE** 是一项编译器特性，它通过在编译时替换标准库中不安全的函数，为您的应用程序增加一层额外的边界检查。此功能帮助您在开发和运行阶段快速定位并修复由库函数调用引起的内存越界问题。其主要优势在于开销极低，适合在生产环境中持续开启。

# 二、如何启用

要启用 **_FORTIFY_SOURCE** 功能，您需要满足特定前提条件并进行相应配置。

## 前提条件

  * **编译优化等级** : 您必须将编译优化等级设置为 **-O2** 或更高。
  * **编译器版本:**

    * 要使用最高的检查等级（Level 3），您需要使用 GCC 12+ 或 Clang 16+。
    * 对于 GCC 12 以下的版本，请将检查等级设置为 2（Level 2）。


## 配置等级

您可以通过 **CONFIG_FORTIFY_SOURCE** 宏定义来设置安全检查的等级。  

    
    
    # 在项目的 Kconfig 或 Makefile 中设置
    CONFIG_FORTIFY_SOURCE=3

**_FORTIFY_SOURCE** 提供三个不同的检查等级：

  * Level **1** : 在编译时执行检查。编译器可以检测并警告一部分在编译期就能确定存在溢出的代码。
  * Level **2** : 在 Level **1** 的基础上，增加对栈（Stack）变量和全局变量的运行时大小检查。这是最常用的等级。
  * Level **3** : 在 Level **2** 的基础上，增加对堆（Heap）上动态分配内存（例如通过 malloc 分配）的运行时大小检查。


# 三、工作原理

**_FORTIFY_SOURCE** 的核心依赖于 GNU 编译器套件（GNU Compiler Collection, GCC）提供的一组内建函数（Intrinsics）。

## 编译器内建函数

  * **__builtin_object_size**(ptr, type): 编译器在编译时使用此函数来推断指针 **ptr** 所指向对象的大小。
  * **__builtin_dynamic_object_size**(ptr, type): GCC 12 中引入，用于在运行时获取动态分配对象的大小。


当您启用 **_FORTIFY_SOURCE** 后，C 标准库的头文件会使用宏定义，将 **memcpy** 等函数调用重定向到其对应的 **_fortify** 版本。这些 **_fortify** 版本内部会调用上述内建函数来获取目标缓冲区的大小，并在执行实际操作前进行边界检查。

## 函数包装示例

以下示例展示了在 openvela 中如何包装 **memcpy** 函数以集成 **_FORTIFY_SOURCE** 检查。  

    
    
    /**
     * @brief 使用 _FORTIFY_SOURCE 包装 memcpy 函数。
     *
     * @param dest 目标内存区域的指针。
     * @param src  源内存区域的指针。
     * @param n    要复制的字节数。
     * @return     返回指向目标内存区域的指针 dest。
     */
    fortify_function(memcpy) FAR void *memcpy(FAR void *dest,
                                              FAR const void *src,
                                              size_t n)
    {
      /*
       * 使用 fortify_size 获取目标和源缓冲区的大小，
       * 如果要复制的长度 n 超出任一缓冲区边界，则触发断言。
       * fortify_size 内部会调用 __builtin_object_size。
       */
      fortify_assert(n <= fortify_size(dest, 0) && n <= fortify_size(src, 0));
      /*
       * 调用原始的、未被包装的 memcpy 函数。
       * __real_memcpy 是通过链接器脚本或宏技巧指向的原始函数实现。
       */
      return __real_memcpy(dest, src, n);
    }

目前，**_FORTIFY_SOURCE** 已广泛覆盖 **string.h** 、**stdio.h** 、**unistd.h** 等头文件中大多数存在溢出风险的函数。

# 四、和 KASan 的对比

内核地址空间清理器（Kernel Address Sanitizer, KASan）是另一种强大的内存错误检测工具。下表对比了 _FORTIFY_SOURCE 和 KASan 的关键特性。

特性对比 | _FORTIFY_SOURCE | KASan (内核地址空间清理器)  
---|---|---  
检测范围 | 仅检查被包装的标准库函数调用 | 检查所有内存读写操作  
栈与全局变量检查 | 支持 | 不支持  
堆变量检查 | 支持 (Level 3) | 支持  
内存开销 (ROM/RAM) | 极小 | 大  
运行时性能开销 | 可忽略不计 | 显著 (可能导致性能大幅降低)  
  
## 结论

_FORTIFY_SOURCE 和 KASan 是互补的内存安全工具：

  * **_FORTIFY_SOURCE** : 轻量级、低开销，适合作为**默认开启** 的安全基线，用于防范由标准库函数调用引起的常见溢出。
  * **KASan** : 重量级、高开销，适合在**调试阶段** 使用，用于检测更复杂的内存错误，例如越界读写（Use-after-free）、双重释放（Double-free）等。


# 五、进一步阅读

您可以查阅以下资源，获取关于 **_FORTIFY_SOURCE** 的更多技术细节：

  * [GCC's new fortification level](<https://developers.redhat.com/articles/2022/09/17/gccs-new-fortification-level>)
  * [Enhance application security with _FORTIFY_SOURCE](<https://www.redhat.com/en/blog/enhance-application-security-fortifysource>)
  * [_FORTIFY_SOURCE](<https://maskray.me/blog/2022-11-06-fortify-source>)
  * [Use source-level annotations to help GCC detect buffer overflows](<https://developers.redhat.com/articles/2021/06/25/use-source-level-annotations-help-gcc-detect-buffer-overflows>)

---

## LeakSanitizer (LSan) 使用指南

> 路径: 内存检测 > LeakSanitizer (LSan) 使用指南
> 来源: [https://doc.openvela.com/document?id=750&language=cn&version=dev](https://doc.openvela.com/document?id=750&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/debugging_tools/crash/memory/heap/LSan.md>) | 简体中文 ]

# 一、概述

LeakSanitizer (LSan) 是一款高效的堆内存泄漏检测工具。它作为运行时工具，能够在程序退出时自动检测并报告未释放的内存，帮助开发者定位和修复内存泄漏问题。LSan 可以与 [AddressSanitizer](<https://github.com/google/sanitizers/wiki/AddressSanitizer>) (ASan) 或 [MemorySanitizer](<https://github.com/google/sanitizers/wiki/MemorySanitizer>) (MSan) 协同工作，也可以独立运行。

> 注意
> 
> 在 openvela 环境中，LSan 目前仅支持在 **sim 仿真平台** 上使用。

# 二、如何使用

## 步骤 1：启用 LSan

您可以通过以下配置启用 LSan。在 openvela 中，启用 ASan 会默认一同启用 LSan。

在配置文件中添加：  

    
    
    CONFIG_SIM_ASAN=y

## 步骤 2：执行泄漏检测

LSan 会在程序正常退出时（例如，在 openvela 中执行 poweroff 命令）自动运行，检查是否存在内存泄漏。

## 步骤 3：解读报告

当 LSan 检测到内存泄漏时，它会打印一份包含详细调用栈的报告。

### 问题代码示例 (hello_main.c)
    
    
    // 在 hello_main.c 中添加以下代码
    #include <stdlib.h>
    int main(int argc, FAR char *argv[])
    {
      // 分配了 100 字节内存但未释放
      malloc(100);
      printf("Hello, World!!\n");
      return 0;
    }

### 运行与输出
    
    
    nsh> hello
    Hello, World!!
    nsh> poweroff
    =================================================================
    ==2283059==ERROR: LeakSanitizer: detected memory leaks
    Direct leak of 100 byte(s) in 1 object(s) allocated from:
        #0 0x7fcadf13d93c in __interceptor_posix_memalign ...
        #1 0x5601710b789d in host_memalign sim/posix/sim_hostmemory.c:180
        ...
        #5 0x560170fd2974 in malloc umm_heap/umm_malloc.c:62
        #6 0x56017106a5d9 in hello_main ~/vela/apps/examples/hello/hello_main.c:38
        #7 0x560170fc82da in nxtask_startup sched/task_startup.c:70
        #8 0x560170fa6c15 in nxtask_start task/task_start.c:134
    SUMMARY: AddressSanitizer: 100 byte(s) leaked in 1 allocation(s).

### 报告解读

  * Direct leak of 100 byte(s) in 1 object(s): 指出存在一个 100 字节的直接内存泄漏。**直接泄漏** 表示该内存块已不可从任何地方访问。
  * 调用栈 (Call Stack): 报告中的堆栈跟踪信息是定位问题的关键。在本例中，#6 行清晰地显示泄漏发生在 hello_main.c 文件的第 38 行，即 malloc(100) 的调用处。


# 三、工作原理

LSan 无需编译器插桩，它通过在运行时拦截内存分配/释放函数（如 malloc, free, new, delete）来跟踪所有堆对象。其检测过程类似于垃圾回收 (Garbage Collection, GC) 中的标记-清除 (Mark-and-Sweep) 算法。

## 检测流程

  1. **跟踪分配** : 程序运行时，LSan 记录所有在堆上分配的内存块。
  2. **暂停程序** : 在程序退出或手动触发检测时，LSan 会暂停所有线程，以获得一个稳定的内存快照。
  3. **确定根集合 (Root Set)** : LSan 扫描所有可能合法持有指向堆内存指针的根区域，包括：

     * 全局变量
     * 所有线程的栈 (Stack)
     * CPU 寄存器
     * 线程局部存储 (Thread-Local Storage, TLS)
  4. **标记可达对象** : 从根集合出发，LSan 递归遍历所有指针，标记所有可被访问到的堆内存块。

  5. **识别泄漏** : 遍历结束后，所有**未被标记** 的堆内存块均被视为内存泄漏。
  6. **生成报告** : LSan 报告所有泄漏的内存块，并附上其分配时记录的调用栈。


## 根集合的查找方式

对于需要深入了解其实现细节的用户，LSan 通过以下方式在底层获取根集合的具体内存区域：

  * **全局变量区** ：通过 dl_iterate_phdr() 遍历所有已加载的动态链接库（包括主程序），获取它们的全局数据段范围。
  * **线程栈范围** ：通过 pthread_getattr_np() 获取每个线程的栈地址和大小。
  * **线程局部存储 (TLS)** ：

    * 静态 TLS 区域通过内部 glibc 函数 _dl_get_tls_static_info() 定位。
    * 动态分配的 TLS 块则通过拦截链接器分配动态 TLS 空间时调用的 __libc_memalign，将这些分配的内存块直接视为根集合的一部分。


# 四、泄漏抑制 (Suppression)

在某些情况下，您可能需要忽略已知的、可接受的泄漏（例如，来自第三方库的已知问题，或设计上作为单例存在的对象）。LSan 允许您通过多种方式抑制这些泄漏报告。

最常用的方法是**使用抑制文件 (Suppression File)** 。

## 操作步骤

  1. 创建抑制文件。 创建一个文本文件，例如 lsan.supp。

  2. 添加抑制规则。 在文件中按行添加规则。每条规则用于指定一个要忽略的泄漏来源。最常用的规则格式是 leak:function_name，其中 function_name 是分配泄漏内存的函数名。

**示例** (lsan.supp)  

         
         # 忽略由 my_singleton_alloc 函数分配的所有内存
         leak:my_singleton_alloc
         # 也可以忽略整个文件中发生的泄漏
         leak:third_party_library.c

**说明** : 您可以直接从 LSan 报告的调用栈中复制函数名或文件名。

  3. 指定抑制文件路径 通过 LSAN_OPTIONS 环境变量来告诉 LSan 抑制文件的位置。您需要在启动 sim 仿真环境之前设置此环境变量。  

         
         # 在 openvela 根目录下执行
         export LSAN_OPTIONS=suppressions=./lsan.supp
         ./build/bin/sim # 之后再启动仿真程序

LSan 在运行时会读取这个文件，并忽略其中列出的所有泄漏源。


## 其他抑制方法

除了抑制文件，LSan 还支持在代码中直接忽略某个内存对象：  

    
    
    #include <sanitizer/lsan_interface.h>
    void *p = malloc(100);
    __lsan_ignore_object(p); // 告诉 LSan 不要跟踪这个对象

这种方法适用于您能直接控制并获取到内存指针的场景。

# 五、FAQ

## 1、fast-unwind 兼容性问题

### 问题描述

LSan 的 fast-unwind 堆栈回溯机制依赖于帧指针 (Frame Pointer) 且对当前任务的栈范围有严格要求。然而，openvela sim 模式的调度基于协程（使用 setjmp/longjmp），这导致线程切换后栈指针变化，使得 fast-unwind 的栈范围检查失败，从而无法捕获到内存泄漏。

### 解决方案

在 sim 模式下，默认禁用 fast-unwind，强制 LSan 使用标准的 slow-unwind 模式。该配置通过 __lsan_default_options 函数实现，确保 LSan 能正确回溯调用栈。

参考实现 (nuttx/arch/sim/src/sim/sim_asan.c):  

    
    
    #ifdef CONFIG_SIM_ASAN
    const char *__lsan_default_options(void)
    {
      /* 
       * Disable fast-unwind to avoid unwind failure in NuttX's
       * coroutine-based scheduling model.
       */
      return "fast_unwind_on_malloc=0";
    }
    #endif

## 2、UBSan 误报问题

### 问题描述

当启用 UndefinedBehaviorSanitizer (UBSan) 时，其内部操作（如 C++ 的 dynamic_cast 类型信息处理）在某些情况下会分配内存。这部分内存在程序退出时可能未被 UBSan 自身清理，导致 LSan 将其误报为内存泄漏。

### 解决方案

为避免此类误报，可以配置一个 dummy 的 UBSan 模块。此方法保留了库的二进制兼容性，但在运行时屏蔽了 UBSan 的所有功能，从而消除了误报源。

**配置选项：**  

    
    
    CONFIG_MM_UBSAN=y
    CONFIG_MM_UBSAN_DUMMY=y

# 六、调试技巧

## 为什么我的程序内存占用持续增长，但 LSan 却没有报告泄漏

这种情况通常是**逻辑内存泄漏（Logical Leak）** ，而非 LSan 设计用来检测的**可达性泄漏 (Reachability Leak)** 。

  * **可达性泄漏** : 内存被分配后，所有指向它的指针都已丢失，程序无法再访问或释放它。这是 LSan 检测的目标。
  * **逻辑内存泄漏** : 内存虽然在技术上仍然可达（例如，被一个全局列表或缓存持有），但从程序逻辑上看已不再需要。


### 示例

一个全局的数据缓存不断添加新条目，但从未或很少移除旧的、无用的条目。

由于这些无用条目仍然被全局数据结构引用，LSan 认为它们是**可达的** ，因此不会报告泄漏。然而，它们却实实在在地消耗着内存。

### 应对策略

对于逻辑内存泄漏，您需要使用其他工具进行手动分析。例如，切换回系统内置的内存分配器，并使用 [Leak 检测](<>)介绍的方法手工检查内存占用变化，从而定位造成内存持续增长的模块。

# 七、参考文献

  * [LeakSanitizer 官方文档](<https://maskray.me/blog/2023-02-12-all-about-leak-sanitizer>)
  * [Apache NuttX PR #9186](<https://github.com/apache/nuttx/pull/9186>)
  * [Apache NuttX PR #12659](<https://github.com/apache/nuttx/pull/12659>)

---

## 使用 J-Link GDB 插件增强 openvela 线程调试

> 路径: J-Link > 使用 J-Link GDB 插件增强 openvela 线程调试
> 来源: [https://doc.openvela.com/document?id=752&language=cn&version=dev](https://doc.openvela.com/document?id=752&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/debugging_tools/crash/JLINK/J_Link.md>) | 简体中文 ]

# 一、概述

在标准的嵌入式开发流程中，使用 **SEGGER J-Link** 和 **GDB** (the GNU Project Debugger) 进行调试时，**GDB** 默认无法识别 **openvela** （基于 NuttX RTOS）的线程模型。这导致开发者无法列出当前系统的所有线程或在它们之间自由切换，极大地限制了多线程应用的调试效率。

本指南详细介绍如何通过 **J-Link** 的 **RTOS** 插件，扩展 **GDB** 的调试能力，从而实现对 **openvela** 系统的线程级调试。您将学习如何编译、配置并使用该插件来查看线程信息、切换线程上下文、以及分析特定线程的调用栈。

# 二、先决条件

在开始之前，请确保您的开发环境满足以下条件：

  * 已正确安装 **SEGGER J-Link** 驱动和相关工具。
  * 已准备好多架构 GDB 工具链（例如 gdb-multiarch）。
  * 拥有 openvela 项目的完整源代码。


# 三、操作步骤

请遵循以下步骤来编译和启用线程调试插件。

## 步骤 1：编译 RTOS 插件

  1. 插件的源代码位于 NuttX 的 tools 目录下。您需要手动编译生成动态库文件 (.so)。  

         
         cd nuttx/tools

  2. 执行 make 命令编译插件。  

         
         make -f Makefile.host jlink-nuttx.so

编译成功后，将在当前目录下生成 jlink-nuttx.so 文件。


## 步骤 2：启动 J-Link GDB 服务器并加载插件

启动 J-Link GDB 服务器时，必须通过 -rtos 参数指定插件的绝对路径，以使其生效。  

    
    
    JLinkGDBServer -if SWD -device Cortex-M55 -rtos <your-nuttx-project-path>/nuttx/tools/jlink-nuttx.so

  * -if SWD: 指定调试接口为 SWD。
  * -device Cortex-M55: 指定目标设备的核心类型。请根据您的硬件平台进行修改。
  * -rtos: 指定 RTOS 插件的绝对路径。


## 步骤 3：连接 GDB 客户端并验证插件加载

  1. 启动 GDB 客户端，并连接到 J-Link GDB 服务器。默认端口为 2331。  

         
         gdb-multiarch nuttx -ex "target remote localhost:2331"

  2. 观察 GDB 的启动信息。如果看到以下输出，则表示插件已成功加载。  

         
         Loading RTOS plugin: /<your-nuttx-project-path>/nuttx/tools/jlink-nuttx.so...
         RTOS plugin (API v1.0) loaded successfully
         RTOS plugin: Loaded
         Received symbol: g_pidhash (0x3C036ADC)
         Received symbol: g_npidhash (0x3C036ACC)
         Received symbol: g_tcbinfo (0x2C531ACC)
         Received symbol: g_cpuload_total (0x3C036DE0)
         Received symbol: g_assignedtasks (0x00000000)
         All mandatory symbols successfully loaded.


# 四、核心调试命令与结果分析

插件加载成功后，您可以使用 GDB 的标准线程命令来调试 openvela 系统。

## 1、查看所有线程 (info threads)

此命令列出系统中所有正在运行的线程及其状态。  

    
    
    (gdb) info thread
    Id   Target Id                                           Frame
    * 2    Thread 1 ([PID:000]Idle Task:0003[PRI:000])         nx_start () at init/nx_start.c:797
    3    Thread 2 ([PID:001]hpwork:0005[PRI:224])            arm_switchcontext (saveregs=0x3c00927c, restoreregs=0x3c00c5ac) at /home/zyl/code/m1ap/nuttx/include/arch/armv8-m/syscall.h:121
    4    Thread 19 ([PID:018]rpmsg-uorb-sens:0005[PRI:100])  arm_switchcontext (saveregs=0x3c015fbc, restoreregs=0x3c00efdc) at /home/zyl/code/m1ap/nuttx/include/arch/armv8-m/syscall.h:121
    5    Thread 4 ([PID:003]bes_main:0005[PRI:101])          arm_switchcontext (saveregs=0x3c00ae1c, restoreregs=0x3c00a2ec) at /home/zyl/code/m1ap/nuttx/include/arch/armv8-m/syscall.h:121
    6    Thread 5 ([PID:004]rptun:0005[PRI:224])             arm_switchcontext (saveregs=0x3c00c5ac, restoreregs=0x3c010fac) at /home/zyl/code/m1ap/nuttx/include/arch/armv8-m/syscall.h:121
    7    Thread 6 ([PID:005]rptun:0005[PRI:224])             arm_switchcontext (saveregs=0x3c00d43c, restoreregs=0x3c012acc) at /home/zyl/code/m1ap/nuttx/include/arch/armv8-m/syscall.h:121
    8    Thread 7 ([PID:006]rptun:0005[PRI:224])             arm_switchcontext (saveregs=0x3c00e29c, restoreregs=0x2000972c <g_idletcb+140>) at /home/zyl/code/m1ap/nuttx/include/arch/armv8-m/syscall.h:121
    9    Thread 8 ([PID:007]init:0005[PRI:100])              arm_switchcontext (saveregs=0x3c00efdc, restoreregs=0x2000972c <g_idletcb+140>) at /home/zyl/code/m1ap/nuttx/include/arch/armv8-m/syscall.h:121
    10   Thread 11 ([PID:010]thread-10:0005[PRI:101])        arm_switchcontext (saveregs=0x3c00a2ec, restoreregs=0x3c00efdc) at /home/zyl/code/m1ap/nuttx/include/arch/armv8-m/syscall.h:121
    11   Thread 13 ([PID:012]kvdbd:0005[PRI:100])            arm_switchcontext (saveregs=0x3c011cfc, restoreregs=0x3c013cdc) at /home/zyl/code/m1ap/nuttx/include/arch/armv8-m/syscall.h:121
    12   Thread 14 ([PID:013]rpmsg-gpio:0005[PRI:224])       arm_switchcontext (saveregs=0x3c012acc, restoreregs=0x3c00efdc) at /home/zyl/code/m1ap/nuttx/include/arch/armv8-m/syscall.h:121
    13   Thread 15 ([PID:014]rpmsg-uorb-audio:0005[PRI:100]) arm_switchcontext (saveregs=0x3c013cdc, restoreregs=0x3c014e2c) at /home/zyl/code/m1ap/nuttx/include/arch/armv8-m/syscall.h:121
    14   Thread 16 ([PID:015]rpmsg-uorb-cp:0005[PRI:100])    arm_switchcontext (saveregs=0x3c014e2c, restoreregs=0x3c015fbc) at /home/zyl/code/m1ap/nuttx/include/arch/armv8-m/syscall.h:121

如何解读输出信息：

  * * (星号)：标记当前 GDB 上下文所在的线程（即当前活动线程）。
  * Id：GDB 为每个线程分配的唯一标识符。后续的线程操作（如切换）将使用此 Id。
  * Target Id：由 J-Link 插件报告的线程 ID。在 openvela 中，Target Id 与 PID 的关系通常是 Target Id = PID + 1。例如，Thread 2 对应的系统 PID 是 1。
  * 括号内包含丰富的线程信息：
    * PID: 线程的进程 ID。
    * Name: 线程名称，如 Idle Task。
    * PRI: 线程的实时优先级。
  * Frame：显示该线程当前停止的函数及代码位置。


## 2、切换活动线程 (thread <Id>)

使用 thread 命令并指定 GDB Id，可以将调试上下文切换到目标线程。  

    
    
    (gdb) thread 4
    [Switching to thread 4 (Thread 19)]
    #0  arm_switchcontext (saveregs=0x3c015fbc, restoreregs=0x3c00efdc) at /home/zyl/code/m1ap/nuttx/include/arch/armv8-m/syscall.h:121
    121          return reg0;

执行此命令后，GDB 的焦点将切换到 Id 为 4 的线程（即 PID 为 18 的 rpmsg-uorb-sens 任务）。后续的调试命令（如查看调用栈、寄存器）都将针对此线程执行。

## 3、查看线程调用栈 (bt)
    
    
    (gdb) bt
    #0  arm_switchcontext (saveregs=0x3c015fbc, restoreregs=0x3c00efdc) at /home/zyl/code/m1ap/nuttx/include/arch/armv8-m/syscall.h:121
    #1  0x2c016ab6 in up_block_task (tcb=tcb@entry=0x3c015f30, task_state=task_state@entry=TSTATE_WAIT_SEM) at armv8-m/arm_blocktask.c:139
    #2  0x2c008338 in nxsem_wait (sem=sem@entry=0x3c016b44) at semaphore/sem_wait.c:153
    #3  0x2c03d054 in poll_semtake (sem=0x3c016b44) at vfs/fs_poll.c:59
    #4  nx_poll (fds=fds@entry=0x3c015ca8, nfds=32, timeout=1006721824) at vfs/fs_poll.c:439
    #5  0x2c03d0c0 in poll (fds=fds@entry=0x3c015ca8, nfds=<optimized out>, timeout=<optimized out>) at vfs/fs_poll.c:500
    #6  0x2c00927c in ppoll (fds=fds@entry=0x3c015ca8, nfds=738386121, nfds@entry=32, timeout_ts=timeout_ts@entry=0x0, sigmask=sigmask@entry=0x3c016c00) at signal/sig_ppoll.c:122
    #7  0x2c02e0c8 in uorb_rpmsg_task (argc=<optimized out>, argv=<optimized out>) at uORB/uORBRpmsg.cpp:404
    #8  0x2c00fa42 in nxtask_startup (entrypt=entrypt@entry=0x2c02dfd5 <uorb_rpmsg_task(int, char**)>, argc=<optimized out>, argv=<optimized out>) at sched/task_startup.c:151
    #9  0x2c00971a in nxtask_start () at task/task_start.c:130
    #10 0x00000000 in ?? ()
    Backtrace stopped: previous frame identical to this frame (corrupt stack?)

通过调用栈，您可以清晰地追踪函数的调用路径，例如从任务入口 nxtask_start 到当前阻塞点 arm_switchcontext。

## 4、查看栈帧信息 (info frame)

此命令提供当前栈帧的详细信息，包括程序计数器（PC）、寄存器保存位置等。  

    
    
    (gdb) info frame
    Stack level 0, frame at 0x3c016b20:
     pc = 0x2c016f52 in arm_switchcontext (/home/zyl/code/m1ap/nuttx/include/arch/armv8-m/syscall.h:121); saved pc = 0x2c016ab6
     called by frame at 0x3c016b20
     source language c.
     Arglist at 0x3c016b18, args: saveregs=0x3c015fbc, restoreregs=0x3c00efdc
     Locals at 0x3c016b18, Previous frame's sp is 0x3c016b20
     Saved registers:
      r7 at 0x3c016b18, lr at 0x3c016b1c

可以看到：

  * 当前 PC 指针地址为 0x2c016f52。
  * 上下文保存的地址为 saveregs=0x3c015fbc。
  * 恢复的地址为 restoreregs=0x3c00efdc。


## 5、查看寄存器 (info registers)

此命令显示当前活动线程上下文中的所有 CPU 寄存器值。  

    
    
    (gdb) info registers
    r0             0x2                 2
    r1             0x3c015fbc          1006723004
    r2             0x3c00efdc          1006694364
    r3             0x3c015fbc          1006723004
    r4             0x3c015f30          1006722864
    r5             0x80                128
    r6             0x3c015f28          1006722856
    r7             0x3c016b18          1006725912
    r8             0x3c015ca8          1006722216
    r9             0x3c016b44          1006725956
    r10            0x20                32
    r11            0x20                32
    r12            0x42                66
    sp             0x3c016b18          0x3c016b18
    lr             0x2c008339          738231097
    pc             0x2c016f52          0x2c016f52 <arm_switchcontext+14>
    xpsr           0x1100000           17825792
    msp            0x0                 0
    psp            0x0                 0
    primask        0x0                 0
    basepri        0x0                 0
    faultmask      0x0                 0
    control        0x0                 0
    fpscr          0x0                 0

您可以查看通用寄存器（r0-r12, sp, lr, pc）以及特殊寄存器（xpsr, primask 等）的值，以进行深度调试。

# 五、相关资料

  * [ELC-E Linux Awareness in Debugger (PDF)](<https://events.static.linuxfound.org/sites/events/files/slides/ELC-E%20Linux%20Awareness.pdf>)

---

## 评估硬件性能

> 路径: 性能分析 > 评估硬件性能
> 来源: [https://doc.openvela.com/document?id=754&language=cn&version=dev](https://doc.openvela.com/document?id=754&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/debugging_tools/performance/analysis/hardware-performance.md>) | 简体中文 ]

在着手分析和优化软件性能之前，您必须首先评估硬件的性能基准。硬件规格定义了系统性能的上限（即“性能天花板”），确认硬件能力能否满足项目需求，是所有性能工作的起点。

# 一、核心硬件性能指标

评估硬件时，请重点考察以下核心指标。这些指标直接影响系统的计算、存储和图形处理能力。

## 计算核心 (Processing Core)

  * **CPU 频率** ：决定处理器的基本运算速度。
  * **浮点运算单元 (FPU)** ：评估其是否支持以及支持的浮点精度（单精度/双精度）。
  * **DSP 指令集** ：确认是否支持数字信号处理指令，这对音视频和通信等计算密集型任务至关重要。


## 内存与缓存 (Memory and Cache)

  * **指令缓存 (I-Cache)、数据缓存 (D-Cache)、外部缓存** ：缓存的大小和速度是影响 CPU 实际性能的关键因素。
  * **RAM 频率** ：影响内存子系统的整体数据吞吐率。
  * **SRAM 带宽** ：片上 SRAM 提供高速数据访问，其带宽对实时任务至关重要。
  * **PSRAM 带宽** ：PSRAM 作为外部 RAM 扩展，其带宽直接影响大数据量的处理效率。


## 存储 (Storage)

  * **闪存 (Flash) 性能** ：包括代码执行速度（Execute-in-Place）和数据读写吞吐率。
  * **eMMC/SD 性能** ：影响文件系统操作和数据存储速度。


## 多媒体与图形加速 (Multimedia & Graphics Acceleration)

  * **2D 图形加速** ：确认硬件是否支持 Bit Blit 或其他 2D 加速功能，对 UI 流畅度有显著影响。
  * **图形处理单元 (GPU)** ：评估 GPU 的 3D 渲染能力和并行计算性能。
  * **硬件视频编解码** ：确认是否集成硬件编解码器，以高效处理视频流。


# 二、使用基准测试工具量化性能

您可以使用行业标准的基准测试工具，来量化评估芯片的关键性能。

  * **[Dhrystone]** ：评估处理器在整数运算方面的性能，详情请参见[使用 Dhrystone 评估 CPU 整数性能](</document?id=758&version=dev&language=cn>)。
  * **[CoreMark]** ：综合评估 CPU 核心的计算性能，是目前广泛使用的跨平台基准，详情请参见[执行 CoreMark 基准测试](</document?id=759&version=dev&language=cn>)。
  * **[CacheSpeed]** ：测试并量化缓存和内存子系统的读写速度，详情请参见 [CacheSpeed 测试工具指南](</document?id=760&version=dev&language=cn>)。
  * **[RAMSpeed]** ：专门用于评估 RAM 的数据吞吐量和访问延迟，详情请参见[ramspeed 内存性能测试指南](</document?id=761&version=dev&language=cn>)


# 三、关键分析与优化策略

基于硬件指标和测试数据，您可以采用以下策略进行深入分析和初步优化。

## 1、横向对比分析

将目标硬件的核心指标与同类产品或现有项目进行横向对比。这种方法可以帮助您快速识别当前硬件的性能长处与短板，为后续的性能优化指明方向。

## 2、优化浮点数运算

**注意** ：部分微控制器（如基于 Arm Cortex-M4 内核的型号）的 FPU 仅原生支持单精度浮点运算。如果在这些平台上执行双精度运算，编译器会调用软件库进行模拟，导致性能急剧下降。

  * **行动项** ：务必查阅芯片手册，确认其 FPU 支持的浮点精度。在代码中，应优先使用硬件原生支持的浮点类型。
  * **参考资料** ：[Be Aware: Floating Point Operations on Arm Cortex-M4(F)](<https://mcuoneclipse.com/2019/03/29/be-aware-floating-point-operations-on-arm-cortex-m4f/>)


## 3、优化代码与数据布局

将执行频率高的“热点代码”和需要频繁访问的关键数据放置在访问速度更快的内存区域（如 SRAM），是嵌入式系统中一项非常有效的优化手段。

  * **行动项** ：分析程序的性能瓶颈后，您可以使用链接器脚本（Linker Script），将特定的函数或变量从慢速存储器（如 Flash）重定向到高速存储器（如 SRAM）中运行。
  * **参考资料** ：[Putting Code of Files into Special Section with the GNU Linker](<https://mcuoneclipse.com/2014/10/06/putting-code-of-files-into-special-section-with-the-gnu-linker/>)

---

## 使用 irqinfo 和 critmon 进行中断与临界区监控

> 路径: 性能分析 > 使用 irqinfo 和 critmon 进行中断与临界区监控
> 来源: [https://doc.openvela.com/document?id=755&language=cn&version=dev](https://doc.openvela.com/document?id=755&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/debugging_tools/performance/analysis/irqinfo_critmon.md>) | 简体中文 ]

本文档为嵌入式开发人员提供在 openvela 系统上使用 irqinfo 和 critmon 两个核心工具的详细指南。您将学会如何监控中断性能、分析临界区（Critical Section）耗时以及调度器锁（Scheduler Lock）的最长持有时间，从而定位系统性能瓶颈并优化实时行为。

# 一、概述

irqinfo 和 critmon 是 openvela 系统提供的两个强大的命令行工具，用于实时性能分析。

  * irqinfo: 专注于中断（IRQ）监控。它统计每个中断的触发频率、发生次数以及中断服务程序（ISR）的最大执行时间。这对于识别“中断风暴”或耗时过长的中断处理至关重要。
  * critmon: 专注于临界区和调度器锁的耗时监控。它跟踪每个线程（Thread）在禁用中断（进入临界区）或禁用调度器时所花费的最长时间，帮助您发现导致系统响应延迟的关键代码路径。


# 二、系统配置

要使用这些监控工具，您必须在 defconfig 文件中启用相应的内核配置选项，并确保 procfs 文件系统已正确挂载。

## 1、通用配置：挂载 procfs

irqinfo 和 critmon 都依赖 procfs 文件系统来暴露其统计数据。请确保系统中已启用 CONFIG_FS_PROCFS=y，并在系统启动后执行以下命令挂载 procfs：  

    
    
    mount -t procfs /proc

## 2、irqinfo 专属配置

要启用中断频率和耗时统计功能，请设置以下 Kconfig 选项：  

    
    
    # 启用中断监控功能
    CONFIG_SCHED_IRQMONITOR=y
    
    # 启用 procfs 文件系统支持
    CONFIG_FS_PROCFS=y

## 3、critmon 专属配置

要启用临界区、调度锁和线程执行时间统计功能，请设置以下 Kconfig 选项：  

    
    
    # 启用临界区和调度锁监控
    CONFIG_SCHED_CRITMONITOR=y  
    
    # 启用 critmon 用户空间命令行工具
    CONFIG_SYSTEM_CRITMONITOR=y 
    
    # 启用 procfs 文件系统支持
    CONFIG_FS_PROCFS=y

**重要提示** ：启用 CONFIG_SCHED_CRITMONITOR 后，以下两个选项默认值为 -1（禁用）。您必须将它们修改为 0 ，才能开启统计功能。  

    
    
    # 设置为 0 以开启临界区耗时统计
    CONFIG_SCHED_CRITMONITOR_MAXTIME_CSECTION=0
    
    # 设置为 0 以开启调度锁耗时统计
    CONFIG_SCHED_CRITMONITOR_MAXTIME_PREEMPTION=0

# 三、使用 irqinfo 进行中断分析

irqinfo 工具帮助您深入了解系统的中断行为。

## 1、使用方法

直接在 shell 中执行 irqinfo 命令即可查看统计信息。  

    
    
    irqinfo

  * **首次执行** ：显示从系统启动到当前时间点的累计中断统计。
  * **后续执行** ：显示自上一次执行 irqinfo 命令以来的增量中断统计。


统计数据在每次读取后会自动清零，以便于进行分段观测。

## 2、解读输出结果
    
    
    ap> irqinfo
    IRQ  HANDLER   ARGUMENT     COUNT  RATE    TIME (us)
    ---  --------  --------     -----  ------  ---------
    11   2c604591  00000000       233   0.000         12
    39   0005753d  2c786451        18   2.395         83
    43   0005753d  00057455       759   0.000        143

**列名** | **描述**  
---|---  
IRQ | **中断号** 。唯一的数字标识符，用于区分不同的中断源。  
HANDLER | **中断处理函数地址** 。指向处理该中断的服务程序（ISR）的内存地址。  
ARGUMENT | **传递给处理函数的参数** 。通常为 0 或指向特定设备实例的指针。  
COUNT | **中断发生次数** 。在统计周期内，该中断被触发的总次数。  
RATE | **中断频率 (次/秒)** 。在统计周期内的平均每秒触发次数。  
TIME | **最大执行时间 (μs)** 。中断服务程序（ISR）单次执行所花费的最长时间，单位为微秒。  
  
## 3、分析技巧

### 解析中断处理函数 (HANDLER)

您可以使用 addr2line 工具将 HANDLER 地址转换为具体的文件名和行号，从而定位 ISR 源码。  

    
    
    addr2line -fe <your_elf_file> <address>
    addr2line -fe nuttx 0005753d

示例输出：  

    
    
    up_irq_handler
    /path/to/nuttx_os.c:55

**注意** : 在许多 ARM 架构的实现中，外设中断会共享一个顶层中断入口（如 up_irq_handler），此时需要结合 IRQ 号来进一步区分具体的中断源。

### 解析中断号 (IRQ)

IRQ 号的含义与硬件平台和架构紧密相关。

  * **ARM 平台**

    * **0-15** ：通常为系统级中断（如 SVC, PendSV。可通过中断处理函数 (HANDLER) 找到对应中断。
    * **> 15**：硬件中断。要将其映射到板级头文件中定义的 IRQn 枚举，请使用公式：枚举值 = IRQ 号 - 16。
  * **Xtensa 平台**

    * IRQ 定义通常位于特定于平台的板级头文件中，请直接查阅。


**示例分析与代码映射：**

以下 irqinfo 输出展示了如何将 IRQ 号与 BSP 头文件中的定义对应起来。  

    
    
    ap> irqinfo
    IRQ HANDLER  ARGUMENT    COUNT    RATE    TIME
     11 2c604591 00000000          8    0.205    7  # 系统中断，SVC
     39 0005753d 2c786451         37    0.948   62  # 硬件中断，39-16=23 UART0_IRQn
     43 0005753d 00057455       3862   99.015   73  # 硬件中断，43-16=27 Timer11 Interrupt

  

    
    
    /* 示例: framework/services/platform/cmsis/inc/best1600.h */
    typedef enum IRQn {
        // ...
        UART0_IRQn                =  23,      /*!< UART0 Interrupt                    */
        // ...
        SYS_TIMER11_IRQn          =  27,      /*!< Timer11 Interrupt                  */
        // ...
    } IRQn_Type;

# 四、使用 critmon 进行临界区与调度锁分析

critmon 工具帮助您监控线程在禁用中断或禁用调度期间的最长耗时。

## 1、使用方法

critmon 提供了一组命令来控制和显示统计信息。

  * **critmon** :

显示统计信息。与 irqinfo 类似，首次执行显示累计数据，后续执行显示增量数据。数据读取后自动清零。

  * **critmon_start** :

在后台启动一个任务，该任务会按照 CONFIG_SYSTEM_CRITMONITOR_INTERVAL（默认为 2 秒）的周期自动打印 critmon 统计信息。

  * **critmon_stop** :

停止后台的自动打印任务。


## 2、解读输出结果
    
    
    ap> critmon
    PRE-EMPTION  CALLER      CSECTION     CALLER      RUN          TIME         PID  DESCRIPTION
    -----------  ----------  -----------  ----------  -----------  -----------  ---  -----------
    1.392849000              0.004460000              -----------  -----------  ---- CPU 0
    0.000039000  0x81f88a7   0.000021000  0x81bf457   0.000631000  0.012379000    1  hpwork
    0.001204000  0x81ccc6d   0.000029000  0x81bcfa1   0.001750000  0.108839000    3  nsh_main

**列名** | **描述**  
---|---  
PRE-EMPTION & CALLER | **最长关调度时间 (秒)** 和 **调用者地址** 。  
记录了线程通过 sched_lock() 等函数禁用调度器的最长持续时间。  
CSECTION & CALLER | **最长关中断时间 (秒)** 和 **调用者地址** 。  
记录了线程通过 enter_critical_section() 进入临界区的最长持续时间。  
RUN | **单次最长运行时间 (秒)** 。  
线程在两次被抢占（preemption）之间连续运行的最长时间。  
TIME | **总计运行时间 (秒)** 。线程在统计周期内获得 CPU 的总时间。  
PID | **线程** **ID** 。  
DESCRIPTION | **线程名称** 。  
  
## 3、分析单个线程的执行时间

您还可以通过读取 /proc 文件系统中对应的节点来获取单个线程的监控数据。这对于编写自动化测试脚本或进行精细化分析非常有用。

  * **命令** ：cat /proc/<pid>/critmon
  * **功能** ：获取指定 PID 线程的单次最长运行时间和总运行时间。


![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455188148_001.png)

# 五、实现原理

  * 中断监控 (irqinfo)：系统在每次进入和退出中断服务程序时记录时间戳。通过计算差值，可以得到单次执行时间，并与已记录的最大值进行比较和更新。计数器则在每次中断触发时递增。
  * 临界区/调度锁监控 (critmon)：

    * 关中断/开中断：enter_critical_section() 和 leave_critical_section() 函数内置了计时逻辑，用于计算并更新当前线程禁用中断的最长时间。记录关中断时间 MAX 值，开机即开始计时，读完即清空，重新计时
    * 关调度/开调度：sched_lock() 和 sched_unlock() 函数同样包含计时逻辑，用于计算并更新当前线程禁用调度器的最长时间。同时该工具记录了开关调度的MAX 时间，原理相同


# 附录：关键概念解析

  * 中断 (IRQ) 与中断服务程序 (ISR)

    * 中断 (IRQ)：是由硬件或软件发出的信号，通知 CPU 发生了需要立即处理的紧急事件。
    * 中断服务程序 (ISR)：是专门用于处理特定中断事件的一段代码。当一个中断发生时，CPU 会暂停当前任务，转而执行对应的 ISR。
  * 临界区 (Critical Section)

    * 指一段必须以原子方式执行的代码，即在执行期间不能被中断或被其他任务抢占。在 openvela/NuttX 中，这通常通过**禁用所有中断** 来实现。critmon 中的 CSECTION 列监控的就是线程持有这种最高优先级锁定的时间。长时间占用临界区会严重影响系统的实时响应能力。
  * 调度锁 (Scheduler Lock)

    * 是一种比临界区更轻量的锁。它**仅禁用****任务调度****器** ，防止操作系统切换到其他任务，但**不会禁用硬件中断** 。这意味着在持有调度锁期间，中断仍然可以发生并得到处理。critmon 中的 PRE-EMPTION 列监控的就是线程持有调度锁的时间。
  * procfs (Process File System)

    * 一个虚拟文件系统，它并不存储在物理磁盘上，而是由内核在内存中动态生成。它提供了一个用户接口，允许用户通过读写文件的方式查看和修改内核的内部数据结构和状态。irqinfo 和 critmon 正是通过 procfs 将内核中的统计数据暴露给用户空间的命令行工具。

---

## 使用 cpuload 分析 CPU 负载

> 路径: 性能分析 > 使用 cpuload 分析 CPU 负载
> 来源: [https://doc.openvela.com/document?id=756&language=cn&version=dev](https://doc.openvela.com/document?id=756&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/debugging_tools/performance/analysis/cpuload.md>) | 简体中文 ]

在嵌入式系统开发中，分析 CPU 负载是定位性能瓶颈、优化任务调度和功耗管理的关键步骤。本文档详细介绍如何在 openvela 操作系统中配置和使用 cpuload 功能，以及如何结合高级工具进行深入的性能分

# 一、cpuload 配置方法

openvela 提供了三种不同的 CPU 负载统计模式，开发者可以根据精度要求和硬件资源选择最合适的方案。

## 模式一：基于系统时钟的采样 (默认)

此模式利用系统的核心节拍定时器 (System Tick Timer) 中断，在每个时钟滴答时对当前正在运行的任务进行采样，从而估算 CPU 占用率。

  * **工作原理** ：在系统时钟中断服务程序中，对当前活动任务的执行时间进行累加。

  * **优缺点** ：

    * **优点** ：配置最简单，不依赖任何额外的硬件定时器。
    * **缺点** ：统计精度受限于系统时钟频率，可能无法精确捕捉到短时运行的任务。
  * **配置选项** ：  

        
        CONFIG_SCHED_CPULOAD_SYSCLK=y


## 模式二：基于外部高精度定时器的采样 (推荐)

此模式使用一个独立的硬件定时器 (External Timer) 以更高的频率进行任务采样，从而提供比系统时钟更精确的 CPU 负载数据。

  * **工作原理** ：配置一个专用的硬件定时器，以高于系统时钟的频率触发中断，并在中断服务程序中对活动任务进行采样。

  * **优缺点** ：

    * **优点** ：统计精度更高，能更准确地反映任务的瞬时 CPU 占用。
    * **缺点** ：需要占用一个额外的硬件定时器，并且需要目标硬件平台 (BSP) 提供相应的驱动适配。
  * **配置选项** ：  

        
        CONFIG_SCHED_CPULOAD_EXTCLK=y


## 模式三：基于任务实际运行时间的高精度计算 (推荐)

此模式通过 SCHED_CRITMONITOR 模块精确记录每个任务的启动和停止时间戳，从而计算出其精确的累计运行时间。这是三种模式中精度最高的方法。

  * **工作原理** ：利用性能监控器 (Performance Monitor) 记录任务切换的精确时间点，通过累计每个任务的实际执行时长来计算其 CPU 占用率。
  * **优缺点** ：

    * **优点** ：统计精度最高，不受采样频率限制，能真实反映每个任务的 CPU 消耗。
    * **缺点** ：会引入轻微的性能开销，因为任务切换时需要记录额外的时间信息。
  * **配置选项** ：

**说明** ：使用此模式前，必须确保板级支持包 (BSP) 已经正确实现了性能计数器，并调用了 up_perf_init() 函数进行初始化。  

        
        CONFIG_SCHED_CRITMONITOR=y
        CONFIG_SCHED_CPULOAD_CRITMONITOR=y


# 二、查看与访问 CPU 负载数据

启用任一 cpuload 配置后，您可以通过多种方式获取 CPU 负载信息。

## 1、使用 ps 命令

在 shell 终端中执行 ps 命令，可以直接查看到每个线程 (thread) 的 CPU 占用率（CPU 列）。

![alt text](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455188412_002.png)

如果只想查看特定线程的信息，可以向 ps 命令传递一个或多个线程 ID (PID)。  

    
    
    # 示例：查看 PID 为 14 和 23 的线程信息
    ps 14 23

![alt text](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455188523_003.png)

## 2、通过编程接口访问

### 用户空间 (Userspace)

应用程序可以通过读取 /proc 文件系统中的虚拟文件来获取 CPU 负载数据。

  * **获取系统总负载** ：/proc/cpuload
  * **获取指定线程负载** ：/proc/${pid}/cpuload


### 内核空间 (Kernel Space)

在内核态代码中，可以直接调用以下 API 函数来获取指定线程的 CPU 负载信息。  

    
    
    #include <nuttx/clock.h>
    
    int clock_cpuload(int pid, FAR struct cpuload_s *cpuload)

# 三、使用高级工具进行分析

对于需要更精细、可视化的性能分析场景，ps 命令可能不够直观。此时，可以借助专业的系统分析工具。

## 1、使用 SEGGER SystemView

SystemView 是一款功能强大的可视化跟踪诊断工具。通过 J-Link 调试器，它可以实时捕获并展示 openvela 内核的详细调度事件，包括任务切换、中断、API 调用等。

与 ps 命令相比，SystemView 提供了更高的时间分辨率和更丰富的上下文信息，使您能够：

  * 精确测量每个线程的单次运行时间片。
  * 直观地观察任务间的交互与抢占关系。
  * 分析特定时间段内的系统整体负载情况。


![alt text](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455188650_004.png)

---

## 使用 Dhrystone 评估 CPU 整数性能

> 路径: 性能分析 > Benchmark > 使用 Dhrystone 评估 CPU 整数性能
> 来源: [https://doc.openvela.com/document?id=758&language=cn&version=dev](https://doc.openvela.com/document?id=758&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/debugging_tools/performance/Benchmark/Dhrystone.md>) | 简体中文 ]

# 一、概述

Dhrystone 是一个行业标准的基准测试程序，专门用于评估处理器的整数和逻辑运算性能。它通过执行一系列预定义的、不含浮点运算的计算密集型操作来模拟典型的程序行为。

测试结果通常以两个关键指标来衡量：

  * **每秒 Dhrystone 数 (Dhrystones per Second)** ：表示处理器在一秒内可以完整执行 Dhrystone 主循环的次数。这个值越高，表明性能越强。
  * **DMIPS** **(Dhrystone Million Instructions Per Second)** ：一个标准化的性能指标，通过将**每秒 Dhrystone 数** 与一个基准值（VAX 11/780 计算机的性能）进行比较得出。它提供了一个跨平台、跨架构的相对性能参考。


# 二、启用 Dhrystone

要使用 Dhrystone 基准测试工具，您必须在 openvela 的板级配置文件中设置以下 Kconfig 选项。  

    
    
    # 启用 Dhrystone 基准测试
    CONFIG_BENCHMARK_DHRYSTONE=y

# 三、执行测试

配置并编译固件后，您可以在 openvela 的 NSH (NuttShell) 终端中运行测试。

## 命令

在终端中，直接执行以下命令启动测试：  

    
    
    dhrystone

## 示例输出

程序会首先尝试一个较小的运行次数，如果执行时间过短，它会自动增加运行次数以获得更精确的测量结果。测试完成后，会打印最终的性能数据。   

    
    
    nsh> dhrystone
    
    Dhrystone Benchmark, Version C, Version 2.2
    Program compiled without 'register' attribute
    Using MSC clock(), HZ=100
    
    Trying 50000 runs through Dhrystone:
    Measured time too small to obtain meaningful results
    
    Trying 500000 runs through Dhrystone:
    Final values of the variables used in the benchmark:
    
    Int_Glob:            5
            should be:   5
    Bool_Glob:           1
            should be:   1
    ... (中间详细的变量验证输出已省略) ...
    Str_2_Loc:           DHRYSTONE PROGRAM, 2'ND STRING
            should be:   DHRYSTONE PROGRAM, 2'ND STRING
    
    Microseconds for one run through Dhrystone:        8.5 
    Dhrystones per Second:                          117647

# 四、解读测试结果

测试完成后，程序会输出详细的验证数据和两个关键的性能指标。

## 关键性能指标

**指标 (Metric)** | **说明**  
---|---  
Microseconds for one run through Dhrystone | 执行一次 Dhrystone 主循环所需的平均时间，单位为微秒 (µs)。  
Dhrystones per Second | 处理器每秒可以执行的 Dhrystone 主循环次数。  
  
## 计算 DMIPS

DMIPS 是一个更具参考价值的标准化指标。它将测试结果与 VAX 11/780 计算机的性能（定义为 1 MIPS）进行比较，该计算机的 Dhrystone 得分为 **1757** Dhrystones/sec。

您可以使用以下公式将测试结果转换为 DMIPS：

**DMIPS = Dhrystones per Second / 1757**

根据上文的示例输出：

  * **Dhrystones per Second** = 117647
  * **DMIPS** = 117647 / 1757 ≈ **66.96**


### 归一化性能 (DMIPS/MHz)

为了在不同主频的处理器之间进行公平比较，通常会使用 **DMIPS/MHz** 作为归一化指标。

**DMIPS/MHz = DMIPS / 处理器主频 (MHz)**

例如，如果处理器运行在 100 MHz，其归一化性能为：

  * **DMIPS/MHz** = 66.96 / 100 ≈ **0.67**

---

## 执行 CoreMark 基准测试

> 路径: 性能分析 > Benchmark > 执行 CoreMark 基准测试
> 来源: [https://doc.openvela.com/document?id=759&language=cn&version=dev](https://doc.openvela.com/document?id=759&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/debugging_tools/performance/Benchmark/coremark.md>) | 简体中文 ]

# 一、概述

CoreMark 是一款专为测量嵌入式系统中央处理器 (CPU) 性能而设计的行业标准基准测试。它由 EEMBC (Embedded Microprocessor Benchmark Consortium) 的 Shay Gal-on 于 2009 年开发，旨在提供一个比 Dhrystone 更真实、更全面的性能评估标准。

该基准测试完全由 C 语言编写，其工作负载主要模拟了 CPU 在实际应用中常见的操作，包含以下几种核心算法：

  * **列表处理 (List Processing):** 对链表进行查找、排序、插入和删除操作。
  * **矩阵操作 (Matrix Manipulation):** 执行常见的矩阵乘法等运算。
  * **状态机 (State Machine):** 通过状态转换来处理输入数据流。
  * **循环冗余校验 (CRC):** 计算数据的校验和，以验证前述算法结果的正确性。


# 二、启用功能

您可以通过以下 Kconfig 配置项来启用 CoreMark 功能：  

    
    
    CONFIG_BENCHMARK_COREMARK=y

# 三、执行测试

CoreMark 可用于评估单核及多核处理器的核心性能，启用该功能并编译固件后，可直接在 openvela 的 shell 中运行测试。  

    
    
    ap> coremark
    2K performance run parameters for coremark.
    CoreMark Size    : 666
    Total ticks      : 207740
    Total time (secs): 20.774000
    Iterations/Sec   : 529.508039
    Iterations       : 11000
    Compiler version : GCC11.3.1 20220712
    Compiler flags   : -Wstrict-prototypes -nostdlib -pipe -O3 -fno-strict-aliasing -fomit-frame-pointer -mthumb -Wa,-mthumb -Wa,-mimplicit-it=always -fno-common -Wall -Wshadow -x
    Memory location  : Please put data memory location here
                            (e.g. code in flash, data on heap, etc)
    seedcrc          : 0xe9f5
    [0]crclist       : 0xe714
    [0]crcmatrix     : 0x1fd7
    [0]crcstate      : 0x8e3a
    [0]crcfinal      : 0x33ff
    Correct operation validated. See README.md for run and reporting rules.
    CoreMark 1.0 : 529.508039 / GCC11.3.1 20220712 -Wstrict-prototypes -nostdlib -pipe -O3 -fno-strict-aliasing -fomit-frame-pointer -mthumb -Wa,-mthumb -Wa,-mimplicit-it=always p

# 四、解读测试结果

命令执行后会输出详细的性能数据和校验信息。下表对关键输出参数进行了解释：

**参数 (Parameter)** | **说明 (Description)** | **示例值 (Example Value)**  
---|---|---  
Run Type | 测试的运行类型和参数。 | 2K performance run...  
CoreMark Size | 测试使用的数据缓冲区大小。 | 666  
Total ticks | 完成所有迭代所消耗的系统时钟节拍（ticks）总数。 | 207740  
Total time (secs) | 完成测试的实际总耗时，单位为秒。 | 20.774000  
**Iterations/Sec** | **核心性能得分。该数值是衡量 CPU 性能的关键指标，越高表示性能越强。** | **529.508039**  
Iterations | 测试执行的总迭代次数。 | 11000  
Compiler version | 用于编译测试代码的编译器版本。 | GCC11.3.1 20220712  
Compiler flags | 编译和链接时使用的标志，这些标志会显著影响最终性能得分。 | -O3 -fno-strict-aliasing...  
seedcrc | 用于三组 CRC 计算的初始种子值。 | 0xe9f5  
[0]crclist | 列表处理算法的 CRC 校验和，用于验证结果正确性。 | 0xe714  
[0]crcmatrix | 矩阵操作算法的 CRC 校验和。 | 0x1fd7  
[0]crcstate | 状态机算法的 CRC 校验和。 | 0x8e3a  
[0]crcfinal | 综合三次迭代后的最终 CRC 校验和，用于确保测试的有效性。 | 0x33ff  
Final Score | 最终得分的紧凑格式总结，附加了编译器版本和标志等环境信息。 | CoreMark 1.0 : 529.508039 / ...  
  
# 五、参考资料

  * [CoreMark 官方网站 (EEMBC)](<https://www.eembc.org/coremark/>)
  * [CoreMark GitHub 仓库](<https://github.com/eembc/coremark>)

---

## CacheSpeed 测试工具指南

> 路径: 性能分析 > Benchmark > CacheSpeed 测试工具指南
> 来源: [https://doc.openvela.com/document?id=760&language=cn&version=dev](https://doc.openvela.com/document?id=760&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/debugging_tools/performance/Benchmark/cachespeed.md>) | 简体中文 ]

# 一、概述

cachespeed 是一款命令行基准测试工具，旨在精确测量 openvela 系统中缓存 (Cache) 操作的性能。它通过对指令缓存 (Instruction Cache, I-Cache) 和数据缓存 (Data Cache, D-Cache) 执行 invalidate (失效)、flush (刷回) 与 clean (写回) 操作，来量化其运行耗时。为提供全面的性能数据，该工具覆盖了内存地址对齐和非对齐两种测试场景。

## 技术术语解析

  * clean (写回)：将缓存中被修改过（“脏”）的数据写回主内存，但数据仍保留在缓存中。
  * invalidate (失效)：将缓存中的数据标记为无效，但不写回主内存。下次访问该数据时，CPU 会强制从主内存重新加载。
  * flush (刷回/冲刷)：通常是 clean 和 invalidate 操作的组合。它先将脏数据写回主内存，然后将对应的缓存行置为无效。


## 目标读者

本文档面向需要在 openvela 实时操作系统 (RTOS) 上进行性能分析和优化的开发者，包括：

  * **系统性能工程师** ：负责评估和调优系统整体性能。
  * **嵌入式内核开发者** ：负责开发或维护底层内存管理和处理器架构相关代码。
  * **板级支持包 (****BSP****) 工程师** ：负责将 openvela 移植到新硬件平台并验证其性能。


# 二、前置条件

该工具依赖 up_perf_gettime() 函数进行高精度计时。在运行测试前，您必须确保系统的性能计数器已正确配置。

对于基于 ARMv8-M 架构的平台，需要通过设置以下寄存器来使能周期计数器 (Cycle Counter)。通常，您可以在调试器或系统启动脚本中执行这些命令。  

    
    
    // 示例，请根据目标芯片确认
    mw 0xe000edfc=0x01100000
    mw 0xe0001000=0x48000001

# 三、编译配置

为确保基准测试结果的准确性，请在构建配置文件中应用以下配置。这些设置可以最大限度地减少可能干扰测试的系统开销。  

    
    
    # --- 性能与优化 ---
    DEBUG_CUSTOMOPT=y          # 启用自定义优化选项
    DEBUG_OPTLEVEL=-O3         # 设置编译器优化等级为 -O3，确保代码以最高效率运行
    
    # --- 关闭监控与安全检查 ---
    CONFIG_SCHED_INSTRUMENTATION=n # 关闭调度器测量
    CONFIG_SCHED_IRQMONITOR=n      # 关闭中断监控
    CONFIG_SCHED_CRITMONITOR=n     # 关闭临界区监控
    CONFIG_STACK_CANARIES=n        # 关闭栈保护。此项对性能影响极大，尤其在短函数调用场景，
                                   # 可能导致高达 3 倍的性能差距
    CONFIG_WATCHDOG=n              # 关闭看门狗，防止在长时间测试中触发系统复位
    
    # --- 使能测试工具 ---
    CONFIG_BENCHMARK_CACHESPEED=y  # 编译 cachespeed 工具

# 四、运行测试

该工具的源代码位于 apps/benchmarks/cachespeed 目录下。在系统 shell 中执行 cachespeed 命令即可运行测试。

## 示例输出
    
    
    cachespeed
    CACHE Speed: address src: 38506ec0
    ** dcache invalidate [rate, avg, cost] in nanoseconds(bytes/nesc) align **
    64 Bytes: 0.045714, 1400, 14000
    128 Bytes: 0.116364, 1100, 11000
    192 Bytes: 0.128000, 1500, 15000
    256 Bytes: 0.182857, 1400, 14000
    320 Bytes: 0.213333, 1500, 15000
    384 Bytes: 0.256000, 1500, 15000
    448 Bytes: 0.320000, 1400, 14000
    ...

# 五、结果解读

测试流程通常从单个缓存行大小开始，逐步增大数据块尺寸，直到接近或超过缓存容量。**分析时以** **avg** **为主** ；rate 与 cost 提供辅助视角，但容易受样本大小与测量方法影响。

输出结果各列含义如下：

**指标** | **单位** | **描述**  
---|---|---  
rate | 字节/纳秒 | 处理速率，计算公式为 (测试数据大小) / avg。  
avg | 纳秒 | **(关键指标)** 执行单次缓存操作的平均耗时。  
cost | 纳秒 | 完成指定数据大小所有迭代测试的总耗时。  
  
# 六、工作原理解析

理解缓存操作的底层机制，有助于您正确解读性能数据。

## 1、Invalidate (失效)

  * **现象** ：invalidate 操作的速率 (rate) 通常会随着测试数据量的增大而提高。
  * **原因解析** ：invalidate 操作的核心开销（例如，CPU 查找缓存标签并将其置为无效状态）相对固定，与要失效的数据块大小关系不大。当您用这部分相对固定的时间 (avg) 处理更大数据块 (size) 时，计算出的平均速率 (rate = size / avg) 自然会随之上升。


## 2、Clean (写回) 与 Flush (刷回)

  * **现象** ：当测试数据的大小超过物理 D-Cache 的总容量时，clean 和 flush 操作的平均耗时 (avg) 会趋于一个稳定值。
  * **原因解析** ：clean 和 flush 操作需要将脏数据（被修改过的数据）从缓存写回至主内存。一旦测试数据量大到无法完全装入缓存，性能瓶颈就从缓存内部的执行速度转移到了速度慢得多的**内存总线带宽** 上。由于总线带宽是固定的，系统向主内存写回数据的速度也趋于恒定，因此单次操作的平均耗时 (avg) 不再随数据量的增加而显著变化。


结论：分析 cachespeed 输出时，请把重点放在 avg 上，并结合目标平台的缓存大小、缓存行尺寸与内存带宽来做归因分析。

# 七、延伸阅读

  * [ARM 架构参考手册 (ARMv8-M)](<https://developer.arm.com/documentation/ddi0553/latest/>)

    * 查阅此手册可获取 DWT、缓存控制器等底层硬件模块的权威技术规范。

---

## ramspeed 内存性能测试指南

> 路径: 性能分析 > Benchmark > ramspeed 内存性能测试指南
> 来源: [https://doc.openvela.com/document?id=761&language=cn&version=dev](https://doc.openvela.com/document?id=761&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/debugging_tools/performance/Benchmark/ramspeed.md>) | 简体中文 ]

本文档为 openvela 系统的开发者和性能工程师提供 ramspeed 基准测试工具的详细使用指南。该工具通过执行一系列标准内存操作，旨在精确评估系统在不同负载下 memcpy 和 memset 函数的性能。

# 一、概述

ramspeed 是一个用于评估内存性能的命令行工具。它通过在指定内存区域上重复执行 memcpy (内存拷贝) 和 memset (内存填充) 操作，来测量不同数据块大小下的内存读写速率。

测试结果可以帮助开发者：

  * 评估系统 C 库中内存操作函数的实际性能。
  * 分析不同编译优化选项对性能的影响。
  * 识别潜在的系统级性能瓶颈。


为了确保测试结果的准确性和可复现性，请在执行测试前仔细阅读本文档的配置要求和最佳实践。

# 二、系统配置

为了获取可靠的性能基准数据，必须在测试前对系统进行专门配置，以排除不相关的系统活动和调试功能带来的性能开销。

## 1、Kconfig 配置

在 defconfig 文件中，请确认并应用以下配置。这些设置旨在最大化代码执行效率并关闭可能干扰性能测量的调试和监控功能。  

    
    
    # 启用自定义优化选项
    DEBUG_CUSTOMOPT=y
    # 设置编译器优化等级为 -O3，以获取最高性能
    DEBUG_OPTLEVEL=-O3
    
    # --- 关闭以下性能干扰项 ---
    # 关闭调度器指令插桩
    CONFIG_SCHED_INSTRUMENTATION=n
    # 关闭中断监控
    CONFIG_SCHED_IRQMONITOR=n
    # 关闭临界区监控
    CONFIG_SCHED_CRITMONITOR=n
    # 关闭stack检查。这个性能影响较大，特别是短函数调用，最大可达3倍性能差距！
    CONFIG_STACK_CANARIES=n
    #关闭wachdog，避免长时间测试触发assert
    CONFIG_WATCHDOG=n
    
    # --- 启用 ramspeed 测试套件 ---
    # 编译 ramspeed 工具
    CONFIG_BENCHMARK_RAMSPEED=y
    # 启用浮点支持，ramspeed 计算速率时需要
    CONFIG_LIBC_FLOATINGPOINT=y

# 三、使用方法

ramspeed 工具通过命令行接口启动，并支持多种参数来控制测试行为。

## 1、命令语法
    
    
    nsh> ramspeed -h
    RAM Speed: Missing required arguments
    
    Usage: ramspeed -a -r <hex-address> -w <hex-address> -s <decimal-size> -v <hex-value>[0x00] -n <decimal-repeat number>[100] -i
    
    Where:
      -a allocate RW buffers on heap. Overwrites -r and -w option.
      -r <hex-address> read address.
      -w <hex-address> write address.
      -s <decimal-size> number of memory locations (in bytes).
      -v <hex-value> value to fill in memory [default value: 0x00].
      -n <decimal-repeat num> number of repetitions [default value: 100].
      -i turn off interrupts while testing [default value: false].

## 2、参数说明

**参数** | **说明** | **是否必需**  
---|---|---  
-a | **自动分配内存** 。  
在堆 (Heap) 上自动申请读/写缓冲区。此选项会覆盖 -r 和 -w。 | 与 -r/-w 二选一  
-r <hex-address> | **指定读地址** 。  
设置 memcpy 的源内存地址。 | 否  
-w <hex-address> | **指定写地址** 。  
设置 memcpy 的目标地址或 memset 的操作地址。 | 否  
-s <decimal-size> | **设置最大测试大小** (单位：字节)。  
测试将从 32 字节开始，以 2 的倍数递增，直至达到此上限。 | 是  
-v <hex-value> | memset 测试时填充的 16 进制数值。默认为 0x00。 | 否  
-n <decimal-repeat> | 每个数据块大小的**重复测试次数** 。  
默认为 100 次。 | 否  
-i | **关闭中断** 。  
在测试执行期间进入临界区，以屏蔽中断对测试结果的干扰。 | 否  
  
**工作模式说明：**

  * **memcpy 测试**：必须同时提供读、写地址。您可以使用 -a 自动分配，或手动通过 -r 和 -w 指定。
  * **memset 测试**：仅需提供写地址。您可以使用 -a 自动分配（此时读缓冲区将被忽略），或手动通过 -w 指定。


## 3、执行示例

以下命令演示了自动分配 512 KB (524288 字节) 内存，并对每个块大小重复测试 10000 次。  

    
    
    ramspeed -a -s 524288 -n 10000

# 四、输出解读与分析

测试结果会分别展示 memcpy 和 memset 的性能数据。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455189326_001.png)

## 1、示例输出
    
    
    vela> ramspeed -a -s 524288 -n 10000
    RAM Speed: Allocate RW buffers on heap
    RAM Speed: Write address: 0xed95d800
    RAM Speed: Read address: 0xed57f800
    RAM Speed: Size: 524288 bytes
    RAM Speed: Value: 0x00
    RAM Speed: Repeat number: 10000
    RAM Speed: Interrupts disabled: false
    ______memcpy performance______
    ______Perform 32 Bytes access ______
    RAM Speed: system memcpy():      Rate = 781250.000 KB/s [cost: 0.400 ms]
    RAM Speed: internal memcpy():    Rate = 781250.000 KB/s [cost: 0.400 ms]
    ______Perform 64 Bytes access ______
    RAM Speed: system memcpy():      Rate = 892857.143 KB/s [cost: 0.700 ms]
    RAM Speed: internal memcpy():    Rate = 781250.000 KB/s [cost: 0.800 ms]
    ______Perform 128 Bytes access ______
    RAM Speed: system memcpy():      Rate = 1041666.667 KB/s        [cost: 1.200 ms]
    RAM Speed: internal memcpy():    Rate = 833333.333 KB/s [cost: 1.500 ms]
    ______Perform 256 Bytes access ______
    ...

## 2、结果分析

输出日志中包含两组核心性能指标：

  * **system memxxx()**

    * **含义** ：调用标准 C 库 (libc) 提供的 memcpy/memset 函数进行测试。其性能直接受编译器版本、优化选项和 C 库实现的影响。
    * **用途** ：反映系统在实际应用中的内存操作性能。
  * **internal memxxx()**

    * **含义** ：调用 ramspeed 工具内部实现的一个基础版 C 语言 memcpy/memset 函数。该实现作为一个性能基准，其核心思想是通过单次循环处理更多数据（如按 32-bit 或 64-bit 字宽操作）来减少循环开销。
    * **用途** ：提供一个稳定、可控的性能参考基线。


**性能诊断要点：** 通常情况下，system memxxx() 的性能应接近或优于 internal memxxx()。如果发现 system 性能远低于 internal，请排查以下原因：

  1. **编译优化未生效** ：请返回第二章，仔细检查 defconfig 中的优化相关配置是否已正确启用。
  2. **编译器特定优化** ：较新版本的 GCC 工具链可能会对 C 实现的 memcpy 进行向量化优化（例如，使用 Arm MVE 指令集）。这可能导致在某些测试中 internal 的性能反超 system，属于正常现象。您可以通过分析反汇编代码来确认具体实现。


# 五、最佳实践

为了获取准确且可复现的性能数据，请遵循以下建议：

  * **创建最小化测试环境** ：在执行测试前，关闭所有非必需的业务应用和后台任务，确保仅有核心系统进程运行，以减少对 CPU 和内存总线的竞争。
  * **规避缓存效应** ：使用较大的测试内存（-s 参数，建议 512 KB 或更大），以减少 Cache-hit 对小数据块测试结果的过度美化，更真实地反映 DDR/SRAM 的性能。
  * **增加测试样本量** ：使用较高的重复次数（-n 参数，建议 1000 或更大），以平滑单次运行的性能抖动，使统计结果更具说服力。
  * **屏蔽中断干扰** ：对于对实时性要求极高的场景分析，可使用 -i 参数在测试期间关闭中断，以测量纯粹的 CPU-to-Memory 性能。


# 六、参考资料

  * **[How Memory Usage Patterns Can Derail Real-time Performance](<https://interrupt.memfault.com/blog/memory-debugging>)** ：一篇深入探讨内存使用模式如何影响实时性能的专业文章。

---

## 使用 Tinymembench 分析内存性能

> 路径: 性能分析 > Benchmark > 使用 Tinymembench 分析内存性能
> 来源: [https://doc.openvela.com/document?id=762&language=cn&version=dev](https://doc.openvela.com/document?id=762&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/debugging_tools/performance/Benchmark/tinymembench.md>) | 简体中文 ]

# 一、概述

tinymembench 是一款轻量级的跨平台基准测试工具，您可以使用它来精确测量系统的内存带宽和随机存取延迟。此工具为分析和优化嵌入式系统的内存子系统性能提供了关键数据。

tinymembench 的主要特性包括：

  * **官方源码** ：https://github.com/ssvb/tinymembench

  * **支持的处理器架构** ：

    * AArch64
    * ARM
    * amd64
    * MIPS32
  * **支持的向量指令集** ：

    * SSE2 (Streaming SIMD Extensions 2)
    * NEON


# 二、使用说明

您可以通过简单的配置和命令，在 openvela 环境中启用并运行 tinymembench。

## 1、启用 tinymembench

在您的项目配置中，启用 tinymembench 应用程序。

  1. 进入 openvela 的配置菜单（例如，执行 make menuconfig）。

  2. 导航至 Application Configuration -> BenchMarks。

  3. 选中 tinymembench 选项。  

         
         CONFIG_BENCHMARKS_TINYMEMBENCH=y

  4. 保存配置并重新编译您的项目。


tinymembench 的源代码位于 apps/benchmarks/tinymembench 目录下。

## 2、运行基准测试

在命令行（NuttShell）中，直接执行 tinymembench 命令即可启动测试。该命令无需任何参数。  

    
    
    nsh> tinymembench

# 三、分析测试结果

tinymembench 的输出分为两个主要部分：内存带宽测试和内存延迟测试。

## 1、解读核心指标

性能评估的基本原则非常简单：

  * **内存带宽越高越好** ：表示单位时间内可以传输更多数据。
  * **内存延迟越低越好** ：表示单次内存访问所需时间更短。


## 2、示例输出

测试完成后，tinymembench 会打印详细的性能报告，如下所示：  

    
    
    nsh> tinymembench
    tinymembench v0.4.9 (simple benchmark for memory throughput and latency)
    
    ==========================================================================
    == Memory bandwidth tests                                               ==
    ... (此处省略了带宽测试的详细输出) ...
     C copy                                               :   7153.3 MB/s (3.7%)
     standard memcpy                                      :  13278.0 MB/s (7.2%)
     standard memset                                      :   5833.2 MB/s (1.0%)
     SSE2 copy                                            :  12823.8 MB/s (6.8%)
    
    ==========================================================================
    == Memory latency test                                                  ==
    ... (此处省略了延迟测试的详细输出) ...
    ==========================================================================
    
    block size : single random read / dual random read
          1024 :    0.1 ns          /     0.1 ns
    ...
      16777216 :   66.7 ns          /    84.9 ns
      33554432 :   73.6 ns          /    99.8 ns
      67108864 :   69.4 ns          /    94.7 ns

## 3、影响内存性能的关键因素

内存性能受到多种硬件和软件配置的共同影响。在分析结果时，请重点考虑以下因素：

  * **数据缓存 (Data Cache)** ：启用数据缓存可以显著降低平均访存延迟，从而提升整体性能。
  * **内存管理单元 (MMU)** ：启用 MMU 会引入虚拟地址到物理地址的转换开销，增加平均访存时间和最坏情况访存时间。在多级页表（如 4 级页表）的配置下，最坏情况下的访存延迟会显著增加。相比之下，使用内存保护单元 (MPU) 进行块式地址转换对性能的影响较小。
  * **转译后备缓冲器 (TLB)** ：TLB (Translation Lookaside Buffer) 是 MMU 的地址转换缓存。启用 TLB 可以有效加速地址转换过程，降低开启 MMU 时的平均访存延迟。
  * **页表项的缓存属性 (Cacheable Attribute)** ：如果将内存区域配置为非缓存 (Non-Cacheable)，CPU 将绕过缓存直接访问主存。这会增加平均访存时间，但可能略微降低最坏情况下的访存延迟抖动。
  * **虚拟化环境** ：在虚拟化环境中运行通常会引入额外的地址转换层（例如，中间物理地址到主机物理地址），这会轻微增加平均访存时间，并可能显著增加最坏情况下的访存时间。
  * **DDR 内存时序** ：DDR (Double Data Rate) SDRAM 的物理特性直接影响性能。

    * **刷新周期** ：内存刷新期间（由 t_REF, t_REFI 等参数定义），内存控制器会暂停响应访存请求，直接影响最坏情况下的访存时间。
    * **访问时序** ：其他关键时序参数，如 t_CL (CAS Latency) 和 t_RCD (RAS to CAS Delay)，同样会影响平均和最坏情况下的访存时间。


# 四、openvela 移植说明

在将 tinymembench 移植到 openvela 的过程中，进行了一项关键修改：

  * 为 fmin 函数增加了 attribute((weak)) 修饰，以解决其与标准库中同名函数可能发生的符号冲突问题。

---

## whetstone CPU 性能基准测试指南

> 路径: 性能分析 > Benchmark > whetstone CPU 性能基准测试指南
> 来源: [https://doc.openvela.com/document?id=763&language=cn&version=dev](https://doc.openvela.com/document?id=763&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/debugging_tools/performance/Benchmark/whetstone.md>) | 简体中文 ]

本文档为 openvela 系统的开发者和性能工程师提供 whetstone 基准测试工具的详细使用指南。whetstone 是一个经典的综合性基准测试程序，旨在通过执行一系列标准化的计算任务，精确评估系统的浮点与整数运算性能。

# 一、概述

whetstone 是一个用于评估处理器算术性能的命令行工具。它通过执行一组包含浮点运算、整数运算、函数调用和数组访问等在内的混合计算任务，得出一个标准化的性能评分。

测试结果可以帮助开发者：

  * 量化评估处理器的浮点运算单元 (Floating-Point Unit, FPU) 性能。
  * 分析不同编译器优化等级 (-O2, -O3 等) 对代码执行效率的影响。
  * 在不同硬件平台或系统配置之间进行算术性能对比。


# 二、系统配置

在运行测试前，您必须在 defconfig 文件中启用以下 Kconfig 选项，以确保 whetstone 测试套件及其依赖项被正确编译。  

    
    
    # 编译 Whetstone 基准测试工具
    CONFIG_BENCHMARK_WHETSTONE=y
    
    # Whetstone 测试的核心是浮点运算，必须启用 C 库的浮点支持
    CONFIG_LIBC_FLOATINGPOINT=y

# 三、使用方法

whetstone 工具通过简单的命令行接口启动，并支持参数来控制测试的负载。

## 1、命令语法
    
    
    whetstone [-c <iterations>] [<loops>]

## 2、参数说明

**参数** | **说明** | **是否必需** | **默认值**  
---|---|---|---  
[<loops>] | **模块循环次数** 。一个位置参数，用于设定每个内部测试模块的执行循环次数。增大此值会显著增加单个测试模块的计算量和执行时间。 | 否 | 1000  
-c <iterations> | **总测试轮数** 。一个可选参数，用于设定整个 whetstone 测试套件的重复执行次数。 | 否 | 1  
  
## 3、执行示例

  1. 执行一次标准测试：使用默认参数，每个模块循环 1,000 次，整个测试执行 1 轮。  

         
         whetstone

  2. 增加每个模块的计算负载：每个模块循环 100,000 次，整个测试执行 1 轮。这适用于需要更长运行时间以获取稳定平均值的场景。  

         
         whetstone 100000

  3. 重复执行多次测试：每个模块循环 100,000 次，并且整个测试套件重复执行 10 轮。  

         
         whetstone 100000 -c 10


# 四、结果解读

测试完成后，whetstone 会输出测试配置、总耗时以及最终的性能评分。

## 1、示例输出
    
    
    ap> whetstone 100000
    Loops: 100000, Iterations: 1, Duration: 5 sec.
    C Converted Double Precision Whetstones: 2.00 MWIPS

  * Loops: 100000: 每个模块执行了 100,000 次循环。
  * Iterations: 1: 整个测试套件执行了 1 轮。
  * Duration: 5 sec: 总耗时为 5 秒。
  * C Converted Double Precision Whetstones: 2.00 MWIPS: 最终性能评分为 2.00 MWIPS。


## 2、关键指标说明

  * MWIPS / KWIPS

    * **含义** : whetstone 的性能单位，分别是 **MWIPS** (Mega Whetstone Instructions Per Second) 和 **KWIPS** (Kilo Whetstone Instructions Per Second)。
    * **计算** : KIPS = (100.0 * loop * 1) / (执行时间(秒) * 1000)，该值根据固定的基准任务量、测试循环次数 (loops 和 -c 参数) 以及总执行时间计算得出。它是一个标准化的分数，分值越高，代表处理器的算术性能越强。
    * **单位换算** : 当评分低于 1 MWIPS (即 1000 KWIPS) 时，结果会以 KWIPS 显示。


# 五、测试模块详解

whetstone 基准测试由 11 个精心设计的计算模块组成，全面覆盖了不同的运算类型：

  * 模块 1-4：基础浮点运算/数组操作/条件判断
  * 模块 5：被省略的整数运算模块
  * 模块 6：复杂整数运算
  * 模块 7：三角函数计算（含反三角函数）
  * 模块 8：过程调用测试
  * 模块 9：数组索引测试
  * 模块 10：简单整数运算
  * 模块 11：数学函数链式调用


# 六、openvela 移植说明

此版本的 whetstone 针对嵌入式实时系统进行了关键优化。

  * **优化的计时器精度:** 原版 whetstone 只有测试时间达到秒级才能得到结果。移植到 openvela 的版本达到毫秒级别就有精度输出。这使得在高性能的嵌入式 CPU 上，即使运行较少的循环次数，也能快速获得稳定且准确的性能数据。

---

## blktest 块设备 I/O 测试指南

> 路径: 压力测试 > blktest 块设备 I/O 测试指南
> 来源: [https://doc.openvela.com/document?id=765&language=cn&version=dev](https://doc.openvela.com/document?id=765&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/debugging_tools/stress_testing/blktest.md>) | 简体中文 ]

本文档为 openvela 系统的开发者和测试工程师提供 blktest 测试套件的详细使用指南。该测试套件通过执行一系列 I/O 操作，旨在验证块设备和 Flash 存储设备驱动的稳定性、数据完整性和基本性能。

# 一、概述

blktest 是一个基于 CMocka 框架的驱动程序测试套件，用于对存储设备执行底层 I/O 功能验证。它通过直接与设备节点交互，模拟文件系统的读写行为，从而有效地评估目标驱动程序的健壮性。

该测试支持以下两种类型的设备：

  * **块设备 (Block Devices)** ：如 RAM 盘 (/dev/ram*)、SD 卡 (/dev/sd*) 等。
  * **MTD** **设备 (Flash Devices)** ：如 NAND/SPI-NOR Flash，通过 FTL (Flash Translation Layer) 和 BCH (Block-to-Character) 转换层进行访问。


blktest 主要执行三个核心测试用例，覆盖了从全盘压力扫描到特定 I/O 模式的多种场景。

**说明** ：块设备以固定大小的 block/page 为单位进行地址化读写，常见 block 大小范围为 512 字节-32 768 字节。

# 二、系统配置

在执行测试前，您必须在 defconfig 文件中启用以下 Kconfig 选项，以确保 blktest 套件及其依赖项被正确编译和集成到系统中。  

    
    
    # 启用 BCH 驱动，用于访问 MTD 设备
    CONFIG_BCH=y
    
    # 启用驱动测试集合，其中包含 blktest
    CONFIG_TESTING_DRIVER_TEST=y
    
    # 启用 CMocka 测试框架，为 blktest 提供运行环境
    CONFIG_TESTING_CMOCKA=y

**配置说明:**

  * CONFIG_BCH=y: 启用块到字符 (Block-to-Character) 转换驱动。当测试 MTD 设备时，该层是必需的。
  * CONFIG_TESTING_DRIVER_TEST=y: 启用基础驱动测试集。
  * CONFIG_TESTING_CMOCKA=y: 启用 CMocka 单元测试框架，blktest 测试用例基于此框架构建。


# 三、执行测试

## 1、命令语法

blktest 测试套件通过 cmocka_driver_block 命令启动。  

    
    
    cmocka_driver_block -m <device_path>

  * device_path：
    * 说明：指定要测试的目标设备节点路径。如 /dev/ram10（块设备）或 /dev/mtdblock0（MTD 设备）。


## 2、执行示例

以下命令演示了如何对位于 /dev/ram10 的 RAM 盘设备执行测试：  

    
    
    cmocka_driver_block -m /dev/ram10

**注意** ：测试过程会遍历设备的大部分区域进行读写，根据设备类型和大小，测试可能会持续较长时间，请耐心等待其执行完成。

# 四、测试用例详解

cmocka_driver_block 命令会依次执行以下三个独立的测试用例：

**测试用例名称** | **测试目的与行为**  
---|---  
blktest_stress | **全盘压力与数据完整性测试** 。 遍历设备的每一个块 (block)，向其中写入随机数据，然后立即回读并进行 CRC32 校验，以确保数据写入和读取的准确性。对于 Flash 设备，此操作会经过 FTL/BCH 堆栈。  
blktest_single_write | **单块写入功能测试** 。 模拟文件系统操作，向设备写入单个块/页 (block/page)，验证驱动程序处理基本写入请求的能力。  
blktest_cachesize_write | **缓存写入功能测试** 。 模拟文件系统操作，一次性写入与设备缓存大小相等的块/页数量，用于检验驱动对缓冲 I/O 或批量写入操作的处理能力。  
  
# 五、预期输出

测试成功后，您将在控制台看到类似以下的输出。每一行 [ OK ] 表示一个测试用例成功通过。   

    
    
    ap> cmocka_driver_block -m /dev/ram10
    [  INFO] [ap] [==========] tests: Running 1 test(s).
    [  INFO] [ap] [ RUN      ] blktest_stress
    [  INFO] [ap] [       OK ] blktest_stress
    [  INFO] [ap] [ RUN      ] blktest_single_write
    [  INFO] [ap] [       OK ] blktest_single_write
    [  INFO] [ap] [ RUN      ] blktest_cachesize_write
    [  INFO] [ap] [       OK ] blktest_cachesize_write
    [  INFO] [ap] [==========] tests: 1 test(s) run.
    [  INFO] [ap] [  PASSED  ] 1 test(s).
    ap>

# 六、参考资料

blktest 是开源项目 Apache NuttX 的一部分，您可以通过以下链接获取更多信息：

  * **[Apache NuttX 官方网站](<https://nuttx.apache.org/>)** ：了解 NuttX RTOS 的最新动态、功能和社区资源。
  * **[CMocka 官方网站](<https://cmocka.org/>)** ：了解 blktest 所使用的单元测试框架。

---

## 使用 memstress 进行内存压力测试

> 路径: 压力测试 > 使用 memstress 进行内存压力测试
> 来源: [https://doc.openvela.com/document?id=766&language=cn&version=dev](https://doc.openvela.com/document?id=766&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/debugging_tools/stress_testing/memstress.md>) | 简体中文 ]

# 一、概述

memstress 是一个专门用于检测系统内存管理器稳定性和正确性的测试工具，特别适合在开发和调试阶段使用。在调试模式下，工具会输出每次内存分配和释放的详细日志，便于追踪内存相关的问题。

# 二、工作原理

memstress 工具会随机进行以下三种内存操作的压力测试：

  1. 标准 malloc：使用 malloc() 分配内存。
  2. 对齐分配：使用 aligned_alloc() 进行对齐内存分配。
  3. 重新分配：使用 realloc() 调整内存大小。


工具会在分配的内存中填入随机数据或调试模式下的固定值，后续会验证数据的完整性，检测内存读写错误。 

如果检测到内存错误，工具会输出详细的错误信息并触发断言，帮助定位问题。

# 三、如何使用 memstress

## 步骤 1: 在编译时启用工具
    
    
    # 启用 memstress 工具
    CONFIG_TESTING_MEMORY_STRESS=y
    
    # 程序名称
    CONFIG_TESTING_MEMORY_STRESS_PROGNAME
    
    # 任务优先级
    CONFIG_TESTING_MEMORY_STRESS_PRIORITY
    
    # 栈大小
    CONFIG_TESTING_MEMORY_STRESS_STACKSIZE

## 步骤 2: 执行测试命令

通过系统 Shell 执行 memstress 命令。

### 命令格式
    
    
    Usage: memstress -m <max-allocsize> -n <node length> -t <sleep us> -x <nthreads> -d <debug mode>

### 参数说明

**参数** | **说明**  
---|---  
-m <max-allocsize> | 设置单次内存分配的最大大小，默认值为 8192 字节  
-n <node length> | 设置分配的内存块数量，默认值为 1024。  
-t <sleep us> | 设置每次测试之间的时间间隔（微秒），默认值为 100 微秒。  
-x <nthreads> | 启用多线程压力测试，设置线程数量，默认值为 1。  
-d <debug mode> | 启用调试模式，该模式有助于定位问题情况，会输出大量信息。  
  
### 使用示例
    
    
    # 基本使用，使用默认参数  
    memstress  
      
    # 设置最大分配 4KB，1000个内存块，4个线程  
    memstress -m 4096 -n 1000 -x 4  
      
    # 启用调试模式进行测试  
    memstress -d -m 2048 -n 500

# 四、重要提示：内存消耗评估

memstress 工具的最大内存消耗计算方式如下：

  1. 每个线程的节点数组：每个线程都会创建一个包含 **node length** 个节点的数组。
  2. 每个节点的最大分配：每个节点最多可以保存一个内存块，大小随机生成但不超过 **max-allocsize****。**
  3. 多线程并行执行：工具支持 **nthreads** 个线程同时运行。


memstress 是一个持续运行的测试，只有在检测到错误时才会停止。在运行前，请务必根据以下公式预估其最大潜在内存消耗，确保系统有足够的可用内存。

**最大内存消耗 ≈** **max-allocsize** **×** **node length** **×** **nthreads**

请注意，这是理论上的峰值，实际内存使用会因随机的分配和释放而动态变化。建议从较小的参数开始测试，逐步增加压力。

---

## fstest 文件系统压力测试工具指南

> 路径: 压力测试 > fstest 文件系统压力测试工具指南
> 来源: [https://doc.openvela.com/document?id=767&language=cn&version=dev](https://doc.openvela.com/document?id=767&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/debugging_tools/stress_testing/fstest.md>) | 简体中文 ]

# 一、概述

fstest 是一个命令行工具，专用于对文件系统的性能和稳定性进行压力测试。

它通过在指定的挂载点上模拟高负载的文件操作（如并发创建、写入、读取和删除文件），全面检验从上层文件系统到下层存储介质（如 eMMC、SD 卡、板载闪存）驱动的整个 I/O 栈。该工具对于评估特定硬件平台上的文件系统性能、定位 I/O 瓶颈以及验证存储驱动的稳定性至关重要。

# 二、命令详解

在 openvela 系统 Shell 中执行 fstest -h 可以获取完整的命令行选项帮助。

## 1、命令语法
    
    
    fstest [OPTIONS]

## 2、参数说明

**选项 (Option)** | **参数 (Argument)** | **说明** | **默认值**  
---|---|---|---  
-h | N/A | 显示此帮助信息并退出。 | N/A  
-n | [count] | 指定测试的循环次数。每次循环都会执行一遍完整的文件创建、写入、读取、校验和删除流程。 | 100  
-m | [path] | **（必填）** 指定测试的目标挂载点（路径）。工具将在此目录下创建和操作测试文件。 | N/A  
-o | [num] | 指定在单次测试循环中要创建和操作的文件总数。 | 512  
-s | [size] | 指定每个测试文件的大小，单位为字节 (Byte)。 | 8192  
  
## 3、原始帮助信息

以下为 fstest -h 命令在终端中的原始输出，可供参考。  

    
    
    ap>fstest -h 
    
    Usage:fstest [OPTION [ARG]] ...
    -h show this help statement 获取 show help message
    -n num of test loop e.g. [100] 测试循环次数，默认情况下是100次循环
    -m mount point to be tested e.g. [] 指定测试路径
    -o num of open file e.g 指定打开的文件数
    -s size of every file e.g 指定每个文件大小
    
    注意：-o 与 -s 大小的乘积需要小于整个分区的大小

# 三、使用前提

在运行测试前，您必须确保目标分区拥有足够的可用空间以容纳所有测试文件。测试所需的总空间由**文件数量** (-o) 和**单个文件大小** (-s) 决定，必须满足以下条件：  

    
    
    (文件数量 × 单个文件大小) < 目标分区的可用空间

如果可用空间不足，测试将因无法创建文件而失败。

# 四、执行与示例

## 1、测试命令示例

以下示例演示了如何在不同的挂载点上执行 fstest。  

    
    
    # 在 /tmp 目录下执行 100 次测试循环
    fstest -n 100 -m /tmp
    
    # 在 /data 目录下执行 100 次测试循环
    fstest -n 100 -m /data

## 2、示例输出

测试执行后，您将看到类似以下的输出日志。日志会显示测试配置，并分阶段打印文件操作的耗时。

  * 执行 fstest -n 100 -m /tmp 命令后的测试输出：

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455189774_001.png)

  * 执行 fstest -n 100 -m /data 命令后的测试输出：

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455189872_002.png)


## 3、结果解读

fstest 的输出日志主要包含两部分：**性能数据** 和**内存使用报告** 。

### 内存使用报告

日志末尾的 Final memory usage 表格是诊断内存泄漏的关键依据，它展示了测试运行前后 openvela 内核内存堆（Heap）的变化情况。

  * **BEFORE** **/** **AFTER** ：分别表示测试任务开始前和结束后某一内存指标的快照值。
  * **DELTA** ：AFTER 与 BEFORE 的差值。**对于一个健康的系统， DELTA 值应为 0**，表示测试过程中动态申请的内存在测试结束后已全部被正确释放。
  * **关键指标解读** ：

    * arena：总堆大小。
    * ordblks：空闲内存块（Free Chunks）的数量。
    * uordblks：已分配内存块（Allocated Chunks）的总大小。
    * fordblks：空闲内存块的总大小。


如果 DELTA 列出现非零值，通常意味着存在内存泄漏。例如，在第一个示例输出中，ordblks (空闲块) 增加了 3，而 uordblks (已用空间) 增加了 1080 字节，这表明测试在 /tmp 路径执行时可能触发了未能被正确释放的内存分配。

### 性能数据

日志中以 [TMR] 开头的行展示了各个文件操作阶段的性能数据。

  * **成功标志** ：当测试完成所有循环且未发生错误时，日志末尾会打印 fstest success!。
  * **性能指标** ：create file, write file, read file, remove file 等条目分别对应文件创建、写入、读取和删除阶段。其后的时间值表示完成该阶段所有操作的总耗时（单位通常为毫秒或系统时钟周期，具体单位取决于平台实现）。通过分析这些耗时数据，您可以评估文件系统在不同 I/O 模式下的具体性能表现。

---

## opus_ramtest 压力测试指南

> 路径: 压力测试 > opus_ramtest 压力测试指南
> 来源: [https://doc.openvela.com/document?id=768&language=cn&version=dev](https://doc.openvela.com/document?id=768&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/debugging_tools/stress_testing/opus_ramtest.md>) | 简体中文 ]

本文档提供在 openvela 系统上配置和执行 opus_ramtest 压力测试的详细指南。该测试通过并发解码 Opus 音频数据来评估系统的内存和调度器在重压下的稳定性。

# 一、概述

opus_ramtest 是一个用于评估系统稳定性的压力测试工具。它通过创建多个并发的子进程（线程），每个进程独立执行高强度的 Opus 音频解码任务，从而对系统的两个核心方面施加压力：

  * **内存系统** : 并发解码操作会引发大量的内存分配与释放，有效检验系统内存管理的鲁棒性，帮助发现内存泄漏、碎片化或非法访问等问题。
  * **任务调度器** : 大量活跃的进程会频繁抢占 CPU 资源，对操作系统的任务调度器提出严苛挑战，可用于评估调度算法的效率、实时性和公平性。


此测试对于验证嵌入式系统在持续高负载下的可靠性至关重要。

# 二、测试准备：系统配置

在执行测试前，您必须在系统构建配置中启用相关组件并进行优化。

## 1、启用核心功能

在您的 defconfig 文件中，确认以下 Kconfig 选项已被启用，以集成 Opus 库和测试程序：  

    
    
    CONFIG_LIB_OPUS=y
    CONFIG_LIB_OPUS_DEMO=y
    CONFIG_TESTING_OPUS_RAMTEST=y

  * CONFIG_LIB_OPUS=y：启用 Opus 音频编解码库。
  * CONFIG_LIB_OPUS_DEMO=y：启用 Opus 演示代码，opus_ramtest 依赖此项。
  * CONFIG_TESTING_OPUS_RAMTEST=y：编译并启用 opus_ramtest 测试命令。


## 2、优化测试环境

为确保测试能有效施加压力，请进行以下配置：

  * 配置任务调度器：

    * 设置 CONFIG_RR_INTERVAL，即轮询调度（Round-Robin）的时间片。**减小此值可提高任务切换频率，从而增大系统调度压力** 。例如，设置为 5 (毫秒) 可获得较好的测试效果。 CONFIG_RR_INTERVAL=5
  * 调整主进程栈大小：

    * 如果测试进程启动时发生栈溢出，您需要增加主进程的栈空间。
    * 修改 CONFIG_TESTING_OPUS_RAMTEST_STACKSIZE 的值。默认值为 40960 字节。


# 三、执行测试

## 1、关闭看门狗

长时间的压力测试可能导致系统响应变慢，从而触发看门狗复位。在测试前，请使用以下命令禁用看门狗：  

    
    
    echo V > /dev/watchdog0

## 2、运行测试命令

使用 opus_ramtest 命令启动测试。以下是推荐的测试指令：  

    
    
    # -s 参数为子进程设置 40960 字节的栈空间
    opus_ramtest -s 40960

# 四、命令参数详解

opus_ramtest 命令支持多个参数，用于定制测试行为。

**参数** | **说明** | **默认值**  
---|---|---  
-s | **（必填）** 为每个创建的子进程（线程）配置栈大小（单位：字节）。 在嵌入式设备上，pthread 创建线程时可能使用较小的默认栈，您必须通过此参数分配足够空间以防溢出。 | N/A  
-n | 指定并发执行解码任务的子进程数量。**注意** ：此值不宜设置过大，以免耗尽系统资源。 | 5  
-r | 设置子进程的调度优先级。 | N/A  
-f | 指定一个外部 Opus 音频文件路径进行解码。如果未提供此参数，测试将使用内部自带的音频数据数组。 | 内置数组  
  
# 五、重要注意事项

  * 内置数据源大小：

    * 该测试工具包含一个约 **250 KB** 的内置静态数组，用作默认的音频数据源。请确保您的目标硬件有足够的 RAM 来容纳此数组以及测试本身带来的开销。


# 六、参考文档

  * **[Opus 官方网站](<https://opus-codec.org/>)** ：获取关于 Opus 编解码器的最新信息、规范和资源。
  * **[Opus IETF RFC 6716](<https://www.rfc-editor.org/rfc/rfc6716>)** ：Opus 编解码器的权威技术标准文档，由互联网工程任务组（IETF）发布。

---

