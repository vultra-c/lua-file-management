# 应用开发

> 来源: openvela官方
> 共 7 篇文档

---

## Hello World

> 路径: 原生应用 > Hello World
> 来源: [https://doc.openvela.com/document?id=733&language=cn&version=dev](https://doc.openvela.com/document?id=733&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/app_dev/system_apps/hello_world/Hello_World.md>) | 简体中文 ]

# 概述

本文档面向开发者，旨在详细介绍如何在 openvela 操作系统中添加、配置和运行一个新的用户应用程序。openvela 基于 NuttX RTOS 构建，其模块化的设计允许开发者方便地集成自定义功能或第三方库。

一个典型的功能模块包含以下部分：

  * **系统应用 (System Application)** ：作为系统内置功能的一部分，通常存放于 apps/ 目录下。
  * **第三方库 (Third-Party Library)** ：作为外部依赖引入，通常存放于 external/ 目录下。


示例目录结构如下：  

    
    
    └── vela
        ├── apps
        │   └── examples
        │       ├── hello_main_1
        │       └── hello_main_2
        └── external
            ├── libs_1
            └── libs_2

本指南将以 Hello, World! 示例应用程序为引导，完整演示从代码编写到构建、运行和自启动的全过程。

# 步骤一：查看 Hello World 示例框架

本节介绍如何在 openvela 中添加一个示例应用程序，包括主体框架、文件内容以及相关构建配置。

## 1、主体框架

Hello World 示例应用程序需要包含以下核心文件：

  * hello_main.c：应用程序的源代码，包含 main 函数入口。
  * Kconfig：构建系统的配置文件，用于在 menuconfig 中提供可裁剪的编译选项。
  * CMakeLists.txt：CMake 构建脚本，用于定义源码、依赖和编译规则。


目录结构示例如下，当前 Hello World 已添加完毕：  

    
    
    apps
     └── examples
         └── hello
             ├── hello_main.c
             ├── CMakeLists.txt
             ├── Kconfig

## 2、编写源代码 (hello_main.c)

查看 hello_main.c 文件，这是应用程序的执行逻辑入口：  

    
    
    #include <stdio.h>
    
    int main(int argc, char *argv[])
    {
        printf("Hello, World!!\n");
        return 0;
    }

如果您需要使用 C++，请确保 main 函数使用 extern "C" 声明，以保证其 C 语言链接兼容性，从而能被系统正确调用：  

    
    
    #include <iostream>
    
    extern "C" int main(int argc, char *argv[])
    {
        std::cout << "Hello, World!!" << endl;
        return 0;
    }

## 3、创建 Kconfig 配置文件

查看 Kconfig 文件，用于定义应用程序的编译选项。这些选项将显示在 menuconfig 图形配置界面中，允许用户按需启用或配置您的应用：  

    
    
    config EXAMPLES_HELLO
            tristate "\"Hello, World!\" example"
            default n
            ---help---
                    Enable the \"Hello, World!\" example
    
    # 仅当 EXAMPLES_HELLO 启用时，以下选项才可见
    if EXAMPLES_HELLO
    
    # 定义应用程序在 openvela 中执行的命令名称
    config EXAMPLES_HELLO_PROGNAME
            string "Program name"
            default "hello"
            ---help---
                    This is the name of the program that will be used when the NSH ELF
                    program is installed.
    
    # 定义应用程序任务的优先级
    config EXAMPLES_HELLO_PRIORITY
            int "Hello task priority"
            default 100
    
    # 定义应用程序任务的堆栈大小
    config EXAMPLES_HELLO_STACKSIZE
            int "Hello stack size"
            default DEFAULT_TASK_STACKSIZE
            
    endif

## 4、创建 CMake 构建脚本

查看 CMakeLists.txt 文件。openvela 的构建系统会自动加载 .config 文件中的所有宏定义作为 CMake 变量，因此您可以直接使用 Kconfig 中定义的配置。  

    
    
    # 检查 'EXAMPLES_HELLO' 是否在 .config 中被启用
    if(CONFIG_EXAMPLES_HELLO) # 如果defconfig使能了该feature则加入编译
      
      # 调用 nuttx_add_application 函数将应用注册为内置 (built-in) 程序
      nuttx_add_application(
        # NAME: 指定应用的唯一名称，通常与 Kconfig 中的 PROGNAME 保持一致
        NAME                                
        ${CONFIG_EXAMPLES_HELLO_PROGNAME}   
        
        # SRCS: 指定源文件列表，main 函数所在文件应为第一个
        SRCS                                
        hello_main.c 
        
        # STACKSIZE: 指定任务堆栈大小                       
        STACKSIZE                           
        ${CONFIG_EXAMPLES_HELLO_STACKSIZE}  
        
        # PRIORITY: 指定任务优先级，不传则为SCHED_PRIORITY_DEFAULT
        PRIORITY                            
        ${CONFIG_EXAMPLES_HELLO_PRIORITY})  
    endif()

### nuttx_add_application() 的函数定义

该 CMake 函数位于 nuttx/cmake/nuttx_add_application.cmake 文件中，用于添加并配置应用程序。  

    
    
    nuttx/cmake/nuttx_add_application.cmake
    
     Usage:
       nuttx_add_application( NAME <string> [ PRIORITY <string> ]
         [ STACKSIZE <string> ] [ COMPILE_FLAGS <list> ]
         [ INCLUDE_DIRECTORIES <list> ] [ DEPENDS <string> ]
         [ DEFINITIONS <string> ] [ MODULE <string> ] [ SRCS <list> ] )
    
     Parameters:
       NAME                : unique name of application
       PRIORITY            : priority
       STACKSIZE           : stack size
       COMPILE_FLAGS       : compile flags
       INCLUDE_DIRECTORIES : include directories
       DEPENDS             : targets which this module depends on
       DEFINITIONS         : optional compile definitions
       MODULE              : if "m", build module (designed to received
                             CONFIG_<app> value)
       SRCS                : source files
       NO_MAIN_ALIAS       : do not add a main=<app>_main alias(*)

# 步骤二：验证应用程序

完成文件创建后，您需要通过以下步骤来配置、编译并运行您的应用程序。

## 1、清理构建环境 (可选)

如果您修改了 Kconfig 文件或希望进行全新编译，建议先执行清理操作：  

    
    
    # 使用 distclean 清理所有构建产物和配置
    ./build.sh vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap  --cmake distclean -j$(nproc)

或者直接删除cmake产物  

    
    
    # 或者直接删除cmake产物
    rm -rf cmake_out/vela_goldfish-armeabi-v7a-ap

## 2、图形化配置 (menuconfig)

启动 menuconfig 以在图形界面中启用您的新应用：  

    
    
    # 启动 menuconfig  
    ./build.sh vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap  --cmake menuconfig -j$(nproc)

在 menuconfig 界面中，通过以下路径找到并启用您的应用： Application Configuration \---> Examples \---> [*] "Hello, World!" example

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455167415_001.png)

## 3、编译和运行

保存 menuconfig 配置后，执行编译。  

    
    
    # 编译固件 (-j`nproc` 使用所有 CPU 核心并行编译)
    ./build.sh vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap  --cmake -j$(nproc)
    
    # 拷贝产物
    cp cmake_out/vela_goldfish-armeabi-v7a-ap/nuttx* nuttx/ && 
    cp cmake_out/vela_goldfish-armeabi-v7a-ap/vela_data.bin nuttx/ && 
    cp cmake_out/vela_goldfish-armeabi-v7a-ap/vela_system.bin nuttx/
    
    # 启动模拟器运行固件
    ./emulator.sh vela

系统启动后，在 NSH 命令行中输入您在 Kconfig 中设置的程序名称（默认为 hello）并回车，即可看到程序输出：

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455167524_002.png)

# 步骤三：配置应用自启动

openvela 支持在系统启动时自动运行指定脚本，您可以通过编辑启动脚本来实现应用的自启动。

## 1、自启动机制与配置

openvela 的启动脚本存放在 /etc 目录下，该目录以 romfs 的形式与 openvela 的二进制文件链接在一起。在系统启动后会自动被 nshlib 挂载，相关配置如下。

确保您的板级配置启用了以下 Kconfig 选项：  

    
    
    CONFIG_FS_ROMFS=y
    CONFIG_ETC_ROMFS=y
    CONFIG_ETC_ROMFSMOUNTPT="/etc"
    CONFIG_NSH_SYSINITSCRIPT="init.d/rc.sysinit"
    CONFIG_NSH_INITSCRIPT="init.d/rcS"

## 2、启动脚本位置

默认的用户启动脚本位于板级配置目录中：  

    
    
    vendor/openvela/boards/vela/src/etc/init.d/rc.sysinit   # 系统初始化脚本 
    vendor/openvela/boards/vela/src/etc/init.d/rcS          # 用户脚本

## 3、编辑启动脚本

打开 rcS 文件，在其中添加您应用的执行命令。  

    
    
    #ifdef CONFIG_FS_HOSTFS
    mount -t hostfs -o fs=vendor/openvela/boards/vela/resource /host
    #endif
    
    hello &

添加后效果如下图所示：

![alt text](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455167624_003.png)

## 4、重新编译和运行
    
    
    # 编译固件 (-j`nproc` 使用所有 CPU 核心并行编译)
    ./build.sh vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap  --cmake -j$(nproc)
    
    # 拷贝产物
    cp cmake_out/vela_goldfish-armeabi-v7a-ap/nuttx* nuttx/ && 
    cp cmake_out/vela_goldfish-armeabi-v7a-ap/vela_data.bin nuttx/ && 
    cp cmake_out/vela_goldfish-armeabi-v7a-ap/vela_system.bin nuttx/
    
    # 启动模拟器运行固件
    ./emulator.sh vela

启动后效果如下图所示：

![alt text](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455167728_004.png)

**注意：**

  * **使用 POSIX 线程** ：在应用程序内部，推荐使用 pthread_create() 创建和管理子线程，而不是直接调用底层的 task_create()。这能保证更好的可移植性和兼容性。
  * **守护主线程** ：如果您的主线程创建了子线程，请确保主线程在所有子线程安全退出后才结束。否则，主线程的退出可能导致整个进程被回收，子线程被强制终止。
  * **创建后台服务** ：对于需要长期运行的服务，可以在 rcS 脚本中使用 & 将其置于后台运行。应用内部通常会进入一个循环（如 while(1)）来处理事件或执行周期性任务。


# 参考资料

为帮助您更好地理解和添加 CMakeLists.txt，下面是参考资料和工具信息：

  * openvela CMake 编译系统请参考 [CMake 快速入门](</document?id=607&version=dev&language=cn>)。

---

## 打地鼠

> 路径: 原生应用 > 打地鼠
> 来源: [https://doc.openvela.com/document?id=734&language=cn&version=dev](https://doc.openvela.com/document?id=734&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//Whackmole/README.md>) | 简体中文 ]

本文档详细介绍如何在 openvela 系统上为 QEMU 模拟器和 ESP32-S3-BOX 开发板构建、部署和运行 Whack-a-Mole（打地鼠）演示应用程序。您将学习如何配置项目、编译固件、运行应用，并对游戏功能进行自定义修改。

# 一、运行效果

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455178187_whackmole.gif)

# 二、构建与运行

本节将指导您完成从项目配置到在目标平台上运行应用程序的完整流程。

## 准备工作

在开始之前，请确保您已位于 openvela 仓库的根目录下。本文中的所有命令均以此为起点。

## 步骤 1：配置项目

您需要通过 menuconfig 工具来启用 Whack-a-Mole 应用并进行相关设置。

  1. 启动 menuconfig。请根据您的目标平台选择对应的命令：

     * QEMU 模拟器:  

           
           ./build.sh vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap menuconfig

     * ESP32-S3-BOX:  

           
           ./build.sh nuttx/boards/xtensa/esp32s3/esp32s3-box/configs/lvgl-3 menuconfig

  2. 在 menuconfig 界面中，按 / 键打开搜索功能，查找并启用以下配置项：  

         
         LVX_USE_DEMO_WHACKMOLE=y
         LVX_WHACKMOLE_DATA_ROOT="/data"

  3. **（可选）** 如果您在运行时遇到界面卡顿或显示不流畅的问题，可以尝试增加 LVGL (Light and Versatile Graphics Library) 的缓存大小。搜索 lv_cache_def_size 并将其值设置为 20000000。

  4. 保存配置并退出 menuconfig。


## 步骤 2：编译项目

编译前，建议先清理旧的构建产物以避免潜在的构建错误。

  1. 清理构建产物 (distclean):

     * QEMU 模拟器:  

           
           ./build.sh vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap distclean -j8

     * ESP32-S3-BOX:  

           
           ./build.sh nuttx/boards/xtensa/esp32s3/esp32s3-box/configs/lvgl-3 distclean

  2. 执行构建:

     * QEMU 模拟器:  

           
           ./build.sh vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap -j8

     * ESP32-S3-BOX:  

           
           ./build.sh nuttx/boards/xtensa/esp32s3/esp32s3-box/configs/lvgl-3 -j8


## 步骤 3：部署与运行

编译成功后，您可以将固件部署到目标平台并启动应用。

### 选项 A：在 QEMU 模拟器中运行

  1. 在 openvela 根目录，执行以下命令启动模拟器：  

         
         ./emulator.sh vela

  2. 等待 openvela 终端（openvela-ap>）出现后，输入以下命令启动游戏：  

         
         Whackmole


### 选项 B：在 ESP32-S3-BOX 开发板上运行

  1. 烧录固件：

确保您的 ESP32-S3-BOX 已通过 USB 连接到计算机。执行以下命令开始烧录。请将 /dev/ttyACM0 替换为您的设备实际的串口端口号。  

         
         pushd nuttx && make -j8 flash ESPTOOL_PORT=/dev/ttyACM0 ESPTOOL_BINDIR=./ && popd

  2. 打开串口监视器：

使用 minicom 或其他串口工具来查看设备输出并与之交互。  

         
         sudo minicom -D /dev/ttyACM0 -b 115200

  3. 启动游戏：

在 minicom 的终端中，输入以下命令：  

         
         Whackmole


# 三、应用定制

您可以根据需求修改游戏的核心功能，例如替换资源或调整难度。

## 核心文件结构

  * Whackmole.c: 包含游戏的核心逻辑。所有功能开发和修改都应在此文件中进行。
  * Whackmole_main.c: 作为应用程序的入口，负责创建并启动运行游戏逻辑的任务。通常情况下，您无需修改此文件。


## 修改资源图片

游戏使用的图片和字体资源被转换为 C 数组，并直接编译到固件中。

  * **资源路径** : 资源文件位于 pic/ 目录下。
  * **转换工具** : 您可以使用 [LVGL 官方在线转换器](<https://lvgl.io/tools/imageconverter>) 将您自己的图片或字体文件转换为所需的 C 格式。
  * **替换** : 生成新的 C 文件后，替换 pic/ 目录下的旧文件并重新编译项目。


## 调整游戏难度

游戏难度由地鼠出现的频率决定，该频率由一个定时器控制。

在 pop_random_mole 函数中，游戏会根据剩余时间 game_time 动态调整定时器的周期。周期越短，地鼠出现越快，难度越高。  

    
    
    // Gophers appear randomly
    static void pop_random_mole(lv_timer_t *timer) {
        // ... (代码省略) ...
        
        // Adjust the frequency of gophers
        if (game_time < 40) {
            lv_timer_set_period(timer, 800);  // 周期设置为 800 毫秒
        }
        if (game_time < 20) {
            lv_timer_set_period(timer, 600);  // 周期设置为 600 毫秒
        }
    }

要调整游戏难度，您可以修改 lv_timer_set_period 函数的第二个参数值。

  * **降低难度** : 增大周期值（例如，1000 毫秒）。
  * **增加难度** : 减小周期值（例如，500 毫秒）。

---

## 亲戚计算器

> 路径: 原生应用 > 亲戚计算器
> 来源: [https://doc.openvela.com/document?id=735&language=cn&version=dev](https://doc.openvela.com/document?id=735&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//relation_calculator/Readme.md>) | 简体中文 ]

本文档为在 openvela 系统上构建、部署和运行**亲戚计算器** 演示应用提供了全面的指导。内容涵盖 QEMU 模拟器和 ESP32-S3-BOX 开发板的操作流程，以及如何通过增加新关系来自定义此应用。

# 一、运行效果

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455178867_show.gif)

# 二、构建与运行

本章节将引导您完成从项目配置到在目标平台上启动应用的完整过程。

## 准备工作

在开始之前，请确保您位于 openvela 仓库的根目录下。本指南中的所有命令均默认从该位置执行。

## 第一步：配置项目

使用 menuconfig 工具来启用**亲戚计算器** 演示应用。

  1. 根据您的目标平台，选择对应的命令启动 menuconfig：

     * **QEMU 模拟器:**  

           
           ./build.sh vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap menuconfig

     * **ESP32-S3-BOX 开发板:**  

           
           ./build.sh nuttx/boards/xtensa/esp32s3/esp32s3-box/configs/lvgl-3 menuconfig

  2. 在 menuconfig 界面中，按下 / 键打开搜索工具，查找并启用以下配置项：  

         
         LVX_USE_DEMO_RELATIVES_CALCULATOR=y

  3. 保存您的配置并退出 menuconfig。


## 第二步：构建项目

为避免潜在的冲突，建议在开始新的编译前清理旧的构建产物。

  1. 清理构建产物 (distclean):

     * **QEMU 模拟器:**  

           
           ./build.sh vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap distclean -j8

     * **ESP32-S3-BOX 开发板:**  

           
           ./build.sh nuttx/boards/xtensa/esp32s3/esp32s3-box/configs/lvgl-3 distclean -j8

  2. 执行构建:

     * **QEMU 模拟器:**  

           
           ./build.sh vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap -j8

     * **ESP32-S3-BOX 开发板:**  

           
           ./build.sh nuttx/boards/xtensa/esp32s3/esp32s3-box/configs/lvgl-3 -j8


## 第三步：部署并运行应用

成功构建后，请根据您的目标平台执行相应指令来部署固件并运行计算器。

### 选项 A：在 QEMU 模拟器上运行

  1. 在 openvela 根目录，执行以下命令启动模拟器：  

         
         ./emulator.sh vela

  2. 等待 openvela 终端（openvela-ap>）出现后，运行以下命令在后台启动应用：  

         
         rel_cal &


### 选项 B：在 ESP32-S3-BOX 开发板上运行

  1. 烧录固件： 通过 USB 将 ESP32-S3-BOX 开发板连接到您的计算机。运行以下命令烧录固件，需将 /dev/ttyACM0 替换为您设备的实际串口号。  

         
         pushd nuttx && make -j8 flash ESPTOOL_PORT=/dev/ttyACM0 ESPTOOL_BINDIR=./ && popd

  2. 打开串口终端： 使用 minicom 等串口终端工具来监控设备输出并与 Shell 交互。  

         
         sudo minicom -D /dev/ttyACM0 -b 115200

  3. 启动计算器： 在 minicom 的终端中，输入以下命令。  

         
         rel_cal &


# 三、自定义应用

您可以通过修改 demos/relation_calculator/relation_cal.c 文件来扩展计算器功能，增加新的关系。

此计算器采用状态转移模型来确定最终关系。要增加一个新关系，您需要定义其转换逻辑和对应的名称。

## 1、定义关系逻辑

在 transitions 数组中，添加一个新的条目来定义关系如何组合。每个条目遵循 relation_transformation_t 结构体格式。

例如，[我][爸爸] = [爸爸]，这一逻辑被定义为：{ME, FATHER, FATHER}。  

    
    
    // 定义关系转换的逻辑
    typedef struct relation_transformation_s
    {
        relation_type_t from;   // 当前的关系状态
        relation_type_t to;     // 新输入的关系（按下的按钮）
        relation_type_t result; // 最终得到的关系状态
    } relation_transformation_t;
    
    // 将新的状态转换逻辑添加到此数组中
    static const relation_transformation_t transitions[] = {
        // ... 已有的转换关系 ...
        { ME, FATHER, FATHER }, // 示例：我的爸爸是爸爸
        // 在此处添加您新的转换逻辑
    };

## 2、定义关系类型与名称

首先，在 relation_type_e 枚举中添加一个新的关系类型。然后，在 relation_names 数组中添加其对应的显示名称字符串。

**重要提示：** relation_names 数组中条目的顺序必须与 relation_type_e 枚举中的顺序严格对应，以确保计算器能显示正确的文本。  

    
    
    // 1. 在枚举中添加新的关系类型
    typedef enum relation_type_e
    {
        // ... 已有的类型 ...
        NEW_RELATIONSHIP, // 您定义的新关系类型
    } relation_type_t;
    
    // 2. 在名称数组中添加对应的名称
    static const char *relation_names[] = {
        // ... 已有的名称 ...
        "新关系", // NEW_RELATIONSHIP 对应的显示名称
    };

完成这些修改后，重新构建并部署项目，即可在计算器中看到您添加的新关系。

# 四、实现原理概述

亲戚计算器是基于一个状态转移系统实现的。用户的每一次按键操作都会触发一次状态变更，系统会根据预定义的转换表，将当前关系（如“我”）转换为一个新的关系（如“爸爸”）。该模型能够以清晰且可扩展的方式管理复杂的亲属关系计算。

# 五、贡献与未来改进

当前基于状态转移的实现方式需要预定义大量的静态数据来构建完整的关系图谱。我们正在积极寻求更高效、更具扩展性的模型来优化关系网的构建方式。

如果您对此有更好的实现思路或愿意参与贡献，我们非常欢迎您通过提交 Issue 或 Pull Request 来与社区共同探讨。

---

## 开发 UI 应用

> 路径: 原生应用 > 开发 UI 应用
> 来源: [https://doc.openvela.com/document?id=736&language=cn&version=dev](https://doc.openvela.com/document?id=736&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/app_dev/system_apps/Dev_UI_App.md>) | 简体中文 ]

# 一、前提条件

  1. 下载源码，请参见[快速入门](</document?id=847&version=dev&language=cn>)。
  2. 在开始本教程之前，请从 [music_player](<https://github.com/open-vela//packages_demos/tree/dev/music_player>) 获取示例代码。


# 二、前置概念

在开始教程之前，推荐先了解以下基础知识和工具，以便顺利完成相关开发工作：

  1. **Makefile** ：熟悉 Makefile 的基础概念与使用方式。Makefile 是构建自动化工具 make 使用的配置文件，常用于定义项目的编译规则和依赖管理。
  2. **Kconfig** ：了解 Kconfig 的基本原理和用法。Kconfig 是 Linux 内核及嵌入式开发中常用的配置系统，帮助开发者灵活地定义和选择软件配置选项。
  3. **LVGL** ：学习使用 LVGL 嵌入式图形库。LVGL 是一个开源的嵌入式图形库，广泛用于开发高性能的用户界面。相关文档可参考 [LVGL 官方文档](<https://docs.lvgl.io/>)。


对上述概念的基本理解将帮助您更高效地完成教程中的开发任务。

# 三、简介

本文介绍如何在 openvela 中编写一个简单的音乐播放器。

# 四、项目结构

项目的代码和资源被整齐地组织在各目录和模块中，便于高效管理和开发。以下是 music_player 项目的目录结构和文件组成说明。

## 1、目录结构

项目的核心目录和文件结构如下：  

    
    
    packages/demos/music_player
    ├── res
    │  ├── fonts
    │  │  ├── MiSans-Normal.ttf
    │  │  └── MiSans-Semibold.ttf
    │  ├── icons
    │  │  ├── album_picture.png
    │  │  ├── audio.png
    │  │  ├── music.png
    │  │  ├── mute.png
    │  │  ├── next.png
    │  │  ├── nocover.png
    │  │  ├── pause.png
    │  │  ├── play.png
    │  │  ├── playlist.png
    │  │  └── previous.png
    │  ├── musics
    │  │  ├── manifest.json
    │  │  ├── UnamedRhythm.png
    │  │  └── UnamedRhythm.wav
    │  └── config.json
    ├── audio_ctl.c
    ├── audio_ctl.h
    ├── Kconfig
    ├── Make.defs
    ├── Makefile
    ├── music_player.c
    ├── music_player.h
    ├── music_player_main.c
    ├── wifi.c
    └── wifi.h

## 2、文件组成

各目录与文件的作用如下：

  1. res：

资源目录，包含项目运行所需的静态资源文件：

     * fonts：字体文件目录，包含应用使用的字体。
     * icons：图标文件目录，包含用于界面显示的各种图标。
     * musics：音乐资源目录，包含音频文件和相应的配置信息。
     * config.json：全局配置文件，存储项目的配置参数。
  2. audio_ctl.c / audio_ctl.h

音频控制模块，负责实现音频相关的功能，包括音频输入、输出及音量调节等操作。

  3. wifi.c / wifi.h

Wi-Fi 控制模块，负责实现 Wi-Fi 的连接管理、初始化等功能。

  4. music_player.c / music_player.h

音乐播放器的核心逻辑，定义和实现音乐播放的主要功能。

  5. music_player_main.c

程序入口文件，负责初始化音乐播放器并启动主要运行逻辑。

  6. Kconfig、Make.defs、Makefile 构建系统文件：

     * Kconfig：定义项目的配置信息和构建选项。
     * Make.defs：编译相关的变量定义和依赖项规则。
     * Makefile：定义项目的构建过程和依赖管理。


# 五、UI 应用开发

## 1、UI 结构概览

目标是制作一个这样的音乐播放器界面。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455179147_028.png)

音乐播放器的用户界面 (UI) 采用分组的方式组织为多个模块。以下是完整的 UI 结构层次：  

    
    
    TIME GROUP:
         TIME: 00:00:00
         DATE: 2024/03/21
    
    PLAYER GROUP:
         ALBUM GROUP:
             ALBUM PICTURE
             ALBUM INFO:
                 ALBUM NAME
                 ALBUM ARTIST
         PROGRESS GROUP:
             CURRENT TIME: 00:00/00:00
             PLAYBACK PROGRESS BAR
         CONTROL GROUP:
             PLAYLIST
             PREVIOUS
             PLAY/PAUSE
             NEXT
             AUDIO
    
    TOP Layer:
         VOLUME BAR
         PLAYLIST GROUP:
             TITLE
             LIST:
                 ICON
                 ALBUM NAME
                 ALBUM ARTIST

  * TIME GROUP：时间显示区域。
  * PLAYER GROUP：播放器核心区域。
    * ALBUM GROUP：专辑信息区域。
    * PROGRESS GROUP：播放进度区域。
    * CONTROL GROUP：播放控制区域。
  * TOP Layer：顶层界面。
    * VOLUME BAR：音量控制条。
    * PLAYLIST GROUP：播放列表区域。


## 2、数据结构设计

### 应用内配置

应用内配置主要用于初始化所需的环境参数，例如 Wi-Fi 网络配置。需要注意的是，敏感信息如 Wi-Fi 的 ssid（服务集标识）和 psk（预共享密钥）不要明文保存，建议通过安全方法（例如环境变量或外部配置文件）方式加载。  

    
    
    struct conf_s {
    #if WIFI_ENABLED
        wifi_conf_t wifi;
    #endif
    };

  * 如果启用 Wi-Fi 功能（WIFI_ENABLED 宏定义），将允许配置 Wi-Fi 的 ssid 和 psk。
  * 避免在代码中硬编码 ssid 和 psk，确保配置敏感信息时引用外部加密存储或动态加载机制。


### 运行时状态

运行时状态数据是应用的动态内容，主要记录播放控制与专辑信息。以下是相关数据结构设计：

  * 唱片（album_info_t）信息。
  * 唱片状态切换（switch_album_mode_t）。
  * 播放状态（play_status_t）。  

        
        // 唱片信息
        typedef struct _album_info_t {   
            const char* name;               // 专辑名称  
            const char* artist;             // 艺术家  
            char path[LV_FS_MAX_PATH_LENGTH];  // 音频文件路径  
            char cover[LV_FS_MAX_PATH_LENGTH]; // 专辑封面路径  
            uint64_t total_time;            // 总时长（单位：毫秒）  
            lv_color_t color;               // 专辑主题颜色  
        } album_info_t;  
        
        // 唱片状态切换
        typedef enum _switch_album_mode_t {   
            SWITCH_ALBUM_MODE_PREV,  // 切换到上一张  
            SWITCH_ALBUM_MODE_NEXT,  // 切换到下一张  
        } switch_album_mode_t;  
        
        // 播放状态
        typedef enum _play_status_t {
            PLAY_STATUS_STOP,  // 播放停止  
            PLAY_STATUS_PLAY,  // 正在播放 
            PLAY_STATUS_PAUSE, // 暂停播放  
        } play_status_t;
        
        // 播放器运行时的状态信息
        struct ctx_s {  
            bool resource_healthy_check;     // 系统资源检查  
            album_info_t* current_album;     // 当前播放的专辑信息  
            lv_obj_t* current_album_related_obj; // 关联到专辑的 UI 对象  
        
            uint16_t volume;                 // 当前音量  
        
            play_status_t play_status_prev;  // 上一次播放状态  
            play_status_t play_status;       // 当前播放状态  
            uint64_t current_time;           // 当前播放时长  
        
            struct {  
                lv_timer_t* volume_bar_countdown;        // 音量条自动隐藏计时器  
                lv_timer_t* playback_progress_update;   // 播放进度更新计时器  
            } timers;  
        
            audioctl_s* audioctl;            // 音频控制句柄，用于音频操作  
        };


### 组件树结构

根据 UI 结构及其分组设计，resource_s 数据结构将包含所有 UI 控件、字体、样式以及图片资源。  

    
    
    struct resource_s {
        struct {
            lv_obj_t* time;         // 时间显示
            lv_obj_t* date;         // 日期显示
            lv_obj_t* player_group; // 播放器容器  
    
            lv_obj_t* volume_bar;   // 音量条  
            lv_obj_t* volume_bar_indic; // 音量指示器  
            lv_obj_t* audio;        // 音频对象  
            lv_obj_t* playlist_base; // 播放列表基础区域  
    
            lv_obj_t* album_cover;  // 专辑封面  
            lv_obj_t* album_name;   // 专辑名称  
            lv_obj_t* album_artist; // 艺术家名称  
    
            lv_obj_t* play_btn;       // 播放键  
            lv_obj_t* playback_group; // 播放进度容器  
            lv_obj_t* playback_progress; // 播放进度条  
            lv_span_t* playback_current_time; // 当前播放时间  
            lv_span_t* playback_total_time;   // 总时长  
    
            lv_obj_t* playlist; // 播放列表对象  
        } ui;  
    
        struct {   
            struct { lv_font_t* normal; } size_16;   
            struct { lv_font_t* bold; } size_22;   
            struct { lv_font_t* normal; } size_24;   
            struct { lv_font_t* normal; } size_28;   
            struct { lv_font_t* bold; } size_60;   
        } fonts;  
    
        struct {   
            lv_style_t button_default;                // 按钮默认样式  
            lv_style_t button_pressed;                // 按钮按下样式  
            lv_style_transition_dsc_t button_transition_dsc; // 按钮过渡效果  
            lv_style_transition_dsc_t transition_dsc;       // 通用过渡效果  
        } styles;  
    
        struct {   
            const char* playlist;   // 播放列表图标路径  
            const char* previous;   // 上一首图标路径  
            const char* play;       // 播放图标路径  
            const char* pause;      // 暂停图标路径  
            const char* next;       // 下一首图标路径  
            const char* audio;      // 音频图标路径  
            const char* mute;       // 静音图标路径  
            const char* music;      // 音乐图标路径  
            const char* nocover;    // 无封面占位图标路径  
        } images;  
    
        album_info_t* albums;     // 所有专辑信息  
        uint8_t album_count;      // 专辑数量  
    };

组件树结构说明：

  * ui 模块： 定义了所有界面控件的属性及其层次结构。
  * fonts 模块： 不同大小和粗细的字体设置。
  * styles 模块： 封装按钮效果及样式。
  * images 模块： 图片资源集中管理，便于动态加载.


## 3、业务逻辑设计

### 主启动流程

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455179261_027.png)

函数 app_create 是音乐播放器应用的初始化入口，用于完成以下任务：

  * 初始化资源和运行上下文结构体。
  * 加载配置文件。
  * 执行组件初始化（如资源健康检查、Wi-Fi 连接等）。
  * 创建主界面并设置默认状态。
  * 启动必要的后台任务（如日期和时间更新功能）。


以下是 app_create 的完整实现及解析：  

    
    
    void app_create(void)
     {
         // 初始化资源和上下文结构体
        lv_memzero(&R, sizeof(R));          // 清空资源结构体 Resource
        lv_memzero(&C, sizeof(C));          // 清空运行上下文结构体 Context
        lv_memzero(&CF, sizeof(CF));        // 清空配置结构体 Config
        read_configs();                     // 读取应用所需的配置文件  
    
        #if WIFI_ENABLED
            CF.wifi.conn_delay = 2000000;       // 设置 Wi-Fi 延迟（单位：微秒，2 秒）
            wifi_connect(&CF.wifi);             // 进行 Wi-Fi 连接
        #endif
    
        C.resource_healthy_check = init_resource(); // 检查和初始化资源  
    
        if (!C.resource_healthy_check) {    // 如果资源检查失败  
            app_create_error_page();        // 创建错误页面提醒用户  
            return;  
        }  
    
        app_create_main_page();             // 创建主页面  
        app_set_play_status(PLAY_STATUS_STOP); // 设置初始播放状态为 “停止”  
        app_switch_to_album(0);             // 切换到第一个专辑  
        app_set_volume(30);                 // 设置默认音量为 30  
    
        app_refresh_album_info();           // 更新专辑信息显示  
        app_refresh_playlist();             // 更新播放列表显示  
        app_refresh_volume_bar();           // 更新音量条显示  
    
        app_start_updating_date_time();     // 启动日期和时间的更新任务  
    }

### 运行时状态机

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455179376_028.jpeg)

app_refresh_play_status 是音乐播放器的运行时状态机核心函数。该函数的主要功能是根据播放状态（PLAY_STATUS_STOP、PLAY_STATUS_PLAY 和 PLAY_STATUS_PAUSE）更新 UI 和音频控制器的状态，从而完成播放、暂停和停止等功能的处理。以下是完整函数及其关键逻辑的逐步说明：  

    
    
    static void app_refresh_play_status(void)
     {
        if (C.timers.playback_progress_update == NULL) {
            C.timers.playback_progress_update = lv_timer_create(app_playback_progress_update_timer_cb, 1000, NULL);
        }
        switch (C.play_status) {  
        case PLAY_STATUS_STOP:  
            // 停止播放状态处理  
            lv_image_set_src(R.ui.play_btn, R.images.play); // 更新播放按钮图标为“播放”  
            lv_timer_pause(C.timers.playback_progress_update); // 暂停计时器  
            if (C.audioctl) {  
                audio_ctl_stop(C.audioctl);         // 停止音频播放  
                audio_ctl_uninit_nxaudio(C.audioctl); // 释放音频控制器资源  
                C.audioctl = NULL;                // 清空音频控制器句柄  
            }  
            break;  
        
        case PLAY_STATUS_PLAY:  
            // 播放状态处理  
            lv_image_set_src(R.ui.play_btn, R.images.pause); // 更新播放按钮图标为“暂停”  
            lv_timer_resume(C.timers.playback_progress_update); // 恢复计时器  
            if (C.play_status_prev == PLAY_STATUS_PAUSE) {  
                audio_ctl_resume(C.audioctl); // 恢复音频播放  
            } else if (C.play_status_prev == PLAY_STATUS_STOP) {  
                C.audioctl = audio_ctl_init_nxaudio(C.current_album->path); // 初始化音频控制器  
                audio_ctl_start(C.audioctl); // 开始播放音频  
            }  
            break;  
        
        case PLAY_STATUS_PAUSE:  
            // 暂停播放状态处理  
            lv_image_set_src(R.ui.play_btn, R.images.play); // 更新播放按钮图标为“播放”  
            lv_timer_pause(C.timers.playback_progress_update); // 暂停计时器  
            audio_ctl_pause(C.audioctl); // 暂停音频播放  
            break;  
        
        default:  
            break;  
        }  
    }

## 4、接口设计

  1. 初始化函数。

初始化函数负责在应用启动时执行资源配置、界面创建和配置文件加载等任务。以下是主要函数接口：  

         
         /* Init functions */
         static void read_configs(void);
         static bool init_resource(void);
         static void reload_music_config(void);
         static void app_create_error_page(void);
         static void app_create_main_page(void);
         static void app_create_top_layer(void);

  2. 定时器启动函数。

定时器控制任务用于启动后台进程，支持动态更新界面功能，例如时间显示、播放进度更新。  

         
         /* Timer starting functions */
         static void app_start_updating_date_time(void);

  3. 专辑操作接口。

专辑操作是音乐播放器的核心功能，支持专辑排序、切换和播放相关处理。  

         
         /* Album operations */
         static int32_t app_get_album_index(album_info_t* album);
         static void app_switch_to_album(int index);

  4. 播放器状态接口。

播放状态接口用于设置播放器的运行状态，如播放、暂停、改变音量或播放时间等。以下提供的接口实现了这些功能：  

         
         /* Album operations */
         static void app_set_play_status(play_status_t status);
         static void app_set_playback_time(uint32_t current_time);
         static void app_set_volume(uint16_t volume);

  5. UI 刷新功能接口。

UI 刷新接口负责动态更新界面组件，如专辑信息、播放状态、音量条和播放进度的实时显示。  

         
         /* UI refresh functions */
         static void app_refresh_album_info(void);
         static void app_refresh_date_time(void);
         static void app_refresh_play_status(void);
         static void app_refresh_playback_progress(void);
         static void app_refresh_playlist(void);
         static void app_refresh_volume_bar(void);
         static void app_refresh_volume_countdown_timer(void);

  6. 事件处理接口。

事件处理是用户交互的重要组成部分，负责对按钮、播放列表、音量条等的事件进行处理：  

         
         /* Event handler functions */
         static void app_audio_event_handler(lv_event_t* e);
         static void app_play_status_event_handler(lv_event_t* e);
         static void app_playlist_btn_event_handler(lv_event_t* e);
         static void app_playlist_event_handler(lv_event_t* e);
         static void app_switch_album_event_handler(lv_event_t* e);
         static void app_volume_bar_event_handler(lv_event_t* e);
         static void app_playback_progress_bar_event_handler(lv_event_t* e);

  7. 定时器回调函数接口。

定时器相关的回调函数用于在固定时间间隔内触发任务：  

         
         /* Timer callback functions */
         static void app_refresh_date_time_timer_cb(lv_timer_t* timer);
         static void app_playback_progress_update_timer_cb(lv_timer_t* timer);
         static void app_volume_bar_countdown_timer_cb(lv_timer_t* timer);


## 5、编写项目配置文件

  * 配置编译系统配置文件目的是针对目录下的所有源代码，将其编译成可执行产物。
  * 增加了新的应用程序，对应的应用程序需要有新的配置项来来决定是否启用应用程序、分配多少栈、进程执行额优先级以及应用的名字等信息。
  * 为了新增音乐播放器，需要更新编译系统的配置文件，包括 Kconfig、Makefile 和 Make.defs 文件。


### Kconfig 文件

以下为新增应用项目的 Kconfig 文件，用于启用功能及定义音乐播放器数据路径：  

    
    
    config LVX_USE_DEMO_MUSIC_PLAYER
            bool "Music Player"
            default n
            
    if LVX_USE_DEMO_MUSIC_PLAYER
            config LVX_MUSIC_PLAYER_DATA_ROOT
                    string "Music Player Data Root"
                    default "/sdcard"
    endif

### Makefile 文件

Makefile 控制应用的编译规则及资源。  

    
    
    include $(APPDIR)/Make.defs
    
    ifeq ($(CONFIG_LVX_USE_DEMO_MUSIC_PLAYER), y)
    PROGNAME = music_player
    PRIORITY = 100
    STACKSIZE = 32768
    MODULE = $(CONFIG_LVX_USE_DEMO_MUSIC_PLAYER)
    
    CSRCS = music_player.c audio_ctl.c wifi.c
    MAINSRC = music_player_main.c
    endif
    
    include $(APPDIR)/Application.mk

### Make.defs 文件

Make.defs 文件将新增的音乐播放器模块加入到系统构建。  

    
    
    ifneq ($(CONFIG_LVX_USE_DEMO_MUSIC_PLAYER),)
    CONFIGURED_APPS += $(APPDIR)/packages/demos/music_player
    endif

# 六、编译运行

## 1、配置项目

  1. 切换到 openvela 仓库的根目录，执行如下命令来配置音乐播放器。

模拟器配置文件（defconfig）在 vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap/ 目录下，使用 build.sh 配置和编译开发板的代码。  

         
         ./build.sh vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap menuconfig

     * build.sh：编译脚本，用来配置和编译 openvela 代码
     * vendor/openvela/boards/vela/configs/*：配置路径
     * menuconfig：打开 menuconfig 页面，修改项目代码的配置。

执行后出现如下界面：

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455179474_020.png)

  2. 按下 / 键逐个搜索修改如下配置：  

         
         LVX_USE_DEMO_MUSIC_PLAYER=y
         LVX_MUSIC_PLAYER_DATA_ROOT="/data"

以 LVX_USE_DEMO_MUSIC_PLAYER 为例进行操作，其余配置方式相同。

     1. 输入待搜索的配置 LVX_USE_DEMO_MUSIC_PLAYER，支持模糊搜索，例如 music_player，找到对应的配置，按回车键进入该配置。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455179639_021.png)

     2. 按下空格键，[ ] 中出现 * 表示打开该配置。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455179759_022.png)

     3. 将 LVX_MUSIC_PLAYER_DATA_ROOT 设置为 /data，修改后按下回车键保存当前配置项。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455179877_023.png)

     4. 按下 Q 键，弹出如下退出保存界面。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455179997_024.png)

     5. 按下字母Y 键保存配置，退出修改配置页面。


## 2、编译项目

  1. 切换到 openvela 仓库的根目录，在终端内依次执行如下命令：  

         
         # 清理构建产物
         ./build.sh vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap distclean -j8
         
         # 开始构建
         ./build.sh vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap -j8

  2. 成功执行后，将得到以下文件：  

         
         ./nuttx
         ├── vela_ap.elf
         ├── vela_ap.bin


## 3、启动模拟器并推送资源

音乐播放器运行中会使用到的字体和图片资源位于 apps/packages/demos/music_player/res 中。要将这些资源推送到模拟器挂载的相应文件路径，可以按照以下步骤操作。

  1. 切换到 openvela 仓库的根目录，启动模拟器：  

         
         ./emulator.sh vela

  2. 使用模拟器支持的 ADB 将资源推送到设备，在 openvela 仓库的根目录下打开一个新的终端，输入 adb push 后跟文件路径，即可将资源传输到相应位置。  

         
         # 安装adb
         sudo apt install android-tools-adb
         
         # 推送资源
         adb push apps/packages/demos/music_player/res /data/


## 4、启动音乐播放器

在模拟器的终端环境 openvela-ap> 中输入如下命令：  

    
    
    music_player &

## 5、退出 Demo

关闭模拟器退出 Demo，如下图所示：

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455180115_026.png)

# 七、常见问题

## 1、如何自定义音乐播放器

  1. 修改 apps/packages/demos/music_player/res 下面的相关配置，在 res/musics 目录下增加新的音乐媒体文件，格式目前只支持 *.wav，可以自行将 *.mp3/aac/m4a 等格式的媒体文件转换为 *.wav 格式。然后修改该目录下的 res/musics/manifest.json 文件：  

         
         {
           "musics": [
             {
               "path": "UnamedRhythm.wav",
               "name": "UnamedRhythm",
               "artist": "Benign X",
               "cover": "UnamedRhythm.png",
               "total_time": 12000,
               "color": "#114514"
             }
           ]
         }

  2. 将想要播放的媒体添加到该配置文件中，参考该格式：

参数 | 参数说明  
---|---  
path | 待播放媒体的文件路径  
name | 媒体名  
artist | 艺术家名  
cover | 封面路径，如果没有提供封面，会展示封面。  
total_time | 该媒体的总播放时长，单位为 毫秒。  
color | 主题色，目前还没有使用。  
  
例如：添加一个，Happiness.wav 播放时长为 186,507 ms 的音乐，可以按如下方式修改。  

         
         {
           "musics": [
             {
               "path": "UnamedRhythm.wav",
               "name": "UnamedRhythm",
               "artist": "Benign X",
               "cover": "UnamedRhythm.png",
               "total_time": 12000,
               "color": "#114514"
             },
             {
               "path": "Happiness.wav",
               "name": "Xin",
               "artist": "Tang",
               "cover": "Good.png",
               "total_time": 186507,
               "color": "#252525"
             },
           ]
         }

  3. 修改完配置后，需要重新推送资源，执行如下命令：  

         
         # 推送资源
         adb push apps/packages/demos/music_player/res /data/

  4. 退出模拟器。

  5. 重新执行[启动模拟器并推送资源](<#3启动模拟器并推送资源>)和[启动音乐播放器](<#4启动音乐播放器>)。

---

## 自行车码表

> 路径: 原生应用 > 自行车码表
> 来源: [https://doc.openvela.com/document?id=737&language=cn&version=dev](https://doc.openvela.com/document?id=737&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/demo/X_Track.md>) | 简体中文 ]

# 简介

X-TRACK Demo 移植自开源项目 [X-TRACK](<https://github.com/FASTSHIFT/X-TRACK>)，感谢 X-TRACK 原作者 FASTSHIFT 本人完成该移植工作。

它是一个自行车码表，拥有时速显示、路程统计和实时轨迹显示等功能，显示分辨率为 240x320，使用触摸屏交互。

代码目录位于：apps/packages/demos/x_track

本文介绍如何在模拟器上运行该示例。

# 前提条件

下载源码，请参见[快速入门](</document?id=847&version=dev&language=cn>)。

# 步骤一 配置项目

  1. 切换到 openvela 仓库的根目录，运行以下命令打开编译配置项目：  

         
         ./build.sh vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap menuconfig

  2. 依次修改如下配置。  

         
         LIB_PNG = y
         LV_USE_LIBPNG = y
         NETUTILS_CJSON = y
         UIKIT = y
         UIKIT_FONT_MANAGER = y
         LVX_USE_DEMO_X_TRACK = y

以启用 LIB_PNG 配置为例进行说明，其他配置操作相同。

     1. 按键盘上的 / 按键进入搜索模式，在搜索栏输入LIB_PNG，使用方向键移动光标至LIB_PNG，按回车确认。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455181377_008.png)

     2. 在Enable libpng选项上按空格键将此选项开启，[ ] 中出现 * 表示该配置被打开。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455181479_009.png)

     3. 其余配置项的开启方法同上。


# 步骤二 开始编译

  1. 运行以下命令开始编译：  

         
         # 清理构建产物
         ./build.sh vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap distclean -j8
         
         # 开始构建
         ./build.sh vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap -j8

  2. 编译成功后，在nuttx目录下会生成以下文件。  

         
         ./nuttx
         ├── vela_ap.elf
         ├── vela_ap.bin


# 步骤三 启动模拟器并推送资源

  1. 切换到 openvela 仓库的根目录，启动模拟器：  

         
         ./emulator.sh vela

  2. 使用模拟器支持的 ADB 将资源推送到设备，在 openvela 仓库的根目录下打开一个新的终端，输入 adb push 后跟文件路径，即可将资源传输到相应位置。  

         
         # 安装adb
         sudo apt install android-tools-adb
         
         # 推送资源
         adb push apps/packages/demos/x_track/resource/font /data
         adb push apps/packages/demos/x_track/resource/images /data
         adb push apps/packages/demos/x_track/resource/track /data


# 步骤四 启动

## 1 开机页面

  1. 启用 X-TRACK 程序，在模拟器的终端环境 openvela-ap> 中输入如下命令：  

         
         x_track &

  2. 执行后效果如下图所示：

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455181580_010.png)


## 2 主界面

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455181689_011.png)

下方三个功能按钮，分别对应跳转不同的功能页面：

  1. 运动轨迹页面。

此页面左下角显示了当前运动的基本信息，中间部分显示当前的运动方向和走过的轨迹，右划可返回上一页。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455181793_012.png)

  2. 关机页面。

此页面模仿了手机的关机页面，按住黄色滚动条往上拖到底再松手即可关机，点击其他位置或右划可返回上一页。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455181895_014.png)

  3. 系统信息页面。

此页面显示了更为详细的系统信息，上下划动或者点击对应的图标可切换不同的信息展示，右划可返回上一页。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455182008_013.png)


# 步骤五 退出 Demo

关闭模拟器退出 Demo，如下图所示：

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455182183_026.png)

# 常见问题

## 1\. adb 命令找不到

### 原因

未安装 adb 工具。

### 解决方案

安装 adb，执行如下命令：  

    
    
    sudo apt install android-tools-adb

## 2\. 字体显示为乱码

### 原因

未正确加载字体资源。

### 解决方案

请按[步骤三](<#步骤三-启动模拟器并推送资源>)进行资源推送。

## 3\. 为什么没有地图显示功能

### 原因

商用地图资源存在版权问题，所以无法提供地图功能，只保留轨迹显示功能。

## 4\. 为什么和原版的 UI 不一样

### 原因

此 Demo 基于原版的代码进行了大幅度调整，所以功能和显示上稍有区别。

## 5\. 为什么右上角状态栏电量一直在随机跳动

### 原因

在模拟器上使用的是简单的随机数模拟电量，所以是正常现象。

## 6\. 这个轨迹是模拟的吗

### 原因

是的，它通过读取 [GPX](<https://zh.wikipedia.org/wiki/GPX>) 文件进行轨迹重放，模拟GNSS产生数据。

## 7\. 怎么替换显示自己的轨迹文件

### 解决方案

将您的轨迹文件（GPX格式），重命名为 TRK_EXAMPLE.gpx，用 adb 工具推送到 /data/Track 目录即可。

---

## 音乐播放器

> 路径: 原生应用 > 音乐播放器
> 来源: [https://doc.openvela.com/document?id=738&language=cn&version=dev](https://doc.openvela.com/document?id=738&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/demo/Music_Player_Example.md>) | 简体中文 ]

# 简介

本文介绍如何在模拟器中运行音乐播放器 Demo。

# 前提条件

下载源码，请参见[快速入门](</document?id=847&version=dev&language=cn>)。

# 步骤一 配置项目

  1. 切换到 openvela 仓库的根目录，执行如下命令来配置音乐播放器。

**说明** ：模拟器配置文件（defconfig）在 vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap/ 目录下，使用 build.sh 配置和编译开发板的代码。  

         
         ./build.sh vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap menuconfig

     * build.sh：编译脚本，用来配置和编译 openvela 代码
     * vendor/openvela/boards/vela/configs/*：配置路径
     * menuconfig：打开 menuconfig 页面，修改项目代码的配置。

执行后出现如下界面：

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455183279_020.png)

  2. 按下 / 键逐个搜索修改如下配置：  

         
         LVX_USE_DEMO_MUSIC_PLAYER=y
         LVX_MUSIC_PLAYER_DATA_ROOT="/data"

**说明** ：以 LVX_USE_DEMO_MUSIC_PLAYER为例进行操作，其余配置方式相同。

     1. 输入待搜索的配置 LVX_USE_DEMO_MUSIC_PLAYER，支持模糊搜索，例如 music_player，找到对应的配置，按回车键进入该配置。

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455183387_021.png)

     2. 按下空格键，[ ] 中出现 * 表示打开该配置。

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455183490_022.png)

     3. 将 LVX_MUSIC_PLAYER_DATA_ROOT 设置为 /data，修改后按下回车键保存当前配置项。

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455183591_023.png)

     4. 按下 Q 键，弹出如下退出保存界面。

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455183696_024.png)

     5. 按下字母Y 键保存配置，退出修改配置页面。


# 步骤二 编译项目

  1. 切换到 openvela 仓库的根目录，在终端内依次执行如下命令：  

         
         # 清理构建产物
         ./build.sh vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap distclean -j8
         
         # 开始构建
         ./build.sh vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap -j8

  2. 成功执行后，将得到以下文件：  

         
         ./nuttx
         ├── vela_ap.elf
         ├── vela_ap.bin


# 步骤三 启动模拟器并推送资源

音乐播放器运行中会使用到的字体和图片资源位于 apps/packages/demos/music_player/res 中。要将这些资源推送到模拟器挂载的相应文件路径，可以按照以下步骤操作。

  1. 切换到 openvela 仓库的根目录，启动模拟器：  

         
         ./emulator.sh vela

  2. 使用模拟器支持的 ADB 将资源推送到设备，在 openvela 仓库的根目录下打开一个新的终端，输入 adb push 后跟文件路径，即可将资源传输到相应位置。  

         
         # 安装adb
         sudo apt install android-tools-adb
         
         # 推送资源
         adb push apps/packages/demos/music_player/res /data/


# 步骤四 启动音乐播放器

在模拟器的终端环境 openvela-ap> 中输入如下命令：  

    
    
    music_player &

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455183807_025.png)

# 步骤五 退出 Demo

关闭模拟器退出 Demo，如下图所示：

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455183971_026.png)

# 常见问题

## 如何自定义音乐播放器

  1. 修改 apps/packages/demos/music_player/res 下面的相关配置，在 res/musics 目录下增加新的音乐媒体文件，格式目前只支持 *.wav，可以自行将 *.mp3/aac/m4a 等格式的媒体文件转换为 *.wav 格式。然后修改该目录下的 res/musics/manifest.json 文件：  

         
         {
           "musics": [
             {
               "path": "UnamedRhythm.wav",
               "name": "UnamedRhythm",
               "artist": "Benign X",
               "cover": "UnamedRhythm.png",
               "total_time": 12000,
               "color": "#114514"
             }
           ]
         }

  2. 将想要播放的媒体添加到该配置文件中，参考该格式：

参数 | 参数说明  
---|---  
path | 待播放媒体的文件路径  
name | 媒体名  
artist | 艺术家名  
cover | 封面路径，如果没有提供封面，会展示封面。  
total_time | 该媒体的总播放时长，单位为 毫秒。  
color | 主题色，目前还没有使用。  
  
例如：添加一个，Happiness.wav 播放时长为 186,507 ms 的音乐，可以按如下方式修改。  

         
         {
           "musics": [
             {
               "path": "UnamedRhythm.wav",
               "name": "UnamedRhythm",
               "artist": "Benign X",
               "cover": "UnamedRhythm.png",
               "total_time": 12000,
               "color": "#114514"
             },
             {
               "path": "Happiness.wav",
               "name": "Xin",
               "artist": "Tang",
               "cover": "Good.png",
               "total_time": 186507,
               "color": "#252525"
             },
           ]
         }

  3. 修改完配置后，需要重新推送资源，执行如下命令：  

         
         # 推送资源
         adb push apps/packages/demos/music_player/res /data/

  4. 退出模拟器。

  5. 重新执行[步骤三](<#步骤三-启动模拟器并推送资源>)和[步骤四](<#步骤四-启动音乐播放器>)。

---

## 手环 Bandx

> 路径: 原生应用 > 手环 Bandx
> 来源: [https://doc.openvela.com/document?id=739&language=cn&version=dev](https://doc.openvela.com/document?id=739&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/demo/Smart_Band_Example.md>) | 简体中文 ]

# 简介

该应用是一款智能手环演示，包括手表表盘、启动器、音乐、心率、秒表、睡眠、运动、设置、手电筒，分辨率为 194*368。可以在 apps/packages/demos/bandx/ 目录中了解有关 bandx 的更多详细信息。

本文介绍如何在模拟器上运行该示例。

# 前提条件

下载源码，请参见[快速入门](</document?id=847&version=dev&language=cn>)。

# 步骤一 配置项目

  1. 切换到 openvela 仓库的根目录，执行如下命令来配置手环 Bandx。

**说明** ：模拟器配置文件（defconfig）在 vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap/ 目录下，使用 build.sh 配置和编译模拟器的代码。  

         
         ./build.sh vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap menuconfig

     * build.sh：编译脚本，用来配置和编译 openvela 代码
     * vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap：配置路径
     * menuconfig：打开 menuconfig 页面，修改项目代码的配置。

执行后出现如下界面：

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455184899_001.png)

  2. 按下 / 键逐个搜索修改如下配置项：  

         
         LV_USE_FRAGMENT = y
         LVX_USE_DEMO_BANDX = y
         BANDX_BASE_PATH = "/data"

以 LV_USE_FRAGMENT 为例进行操作，其余配置方式相同。

     1. 输入待搜索的配置。

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455185003_002.png)

     2. 按下Enter进入到配置页面。

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455185103_003.png)

     3. 按下Enter键打开该配置，[ ] 中出现 * 表示该配置被打开。

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455185216_004.png)

     4. 按下 / 键可以继续搜索剩下的配置，并按上述步骤修改其余配置。

     5. 按下字母Q键，弹出如下退出保存界面。

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455185320_005.png)

     6. 按下字母Y键保存配置，并退出修改配置页面。


# 步骤二 编译项目

  1. 切换到 openvela 仓库的根目录，在终端内依次执行如下命令：  

         
         # 清理构建产物
         ./build.sh vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap distclean -j8
         
         # 开始构建
         ./build.sh vendor/openvela/boards/vela/configs/goldfish-armeabi-v7a-ap -j8

  2. 成功执行后，将得到以下文件：  

         
         ./nuttx
         ├── vela_ap.elf
         ├── vela_ap.bin


# 步骤三 启动模拟器并推送资源

Bandx 中使用的字体和图像资源位于 apps/packages/demos/bandx/resources/ 中，要将这些资源推送到模拟器挂载的相应文件路径，可以按照以下步骤操作。

  1. 切换到 openvela 仓库的根目录，启动模拟器：  

         
         ./emulator.sh vela

  2. 使用模拟器支持的 ADB 将资源推送到设备，在 openvela 仓库的根目录下打开一个新的终端，输入 adb push 后跟文件路径，即可将资源传输到相应位置。  

         
         # 安装adb
         sudo apt install android-tools-adb
         
         # 推送资源
         adb push apps/packages/demos/bandx/resource/font/assets/* /data/font/
         adb push apps/packages/demos/bandx/resource/image/assets /data/image/

如果将 BANDX_BASE_PATH 更改为非默认值，如 /tmp，则资源文件也必须传输到 /tmp/font/ 和 /tmp/image/ 目录。否则将出现找不到资源的错误。


# 步骤四 启动 Bandx

  1. 在模拟器的终端环境 openvela-ap> 中输入如下命令：  

         
         bandx &

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455185433_006.png)

  2. 要访问 Launcher 界面，从右向左快速滑动。单击不同的图标导航到子页面，如下图所示的 Heart Rate 页面。要退出页面，从左向右快速滑动。

**说明** ：music页面只是UI展示，没有接入音频。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455185533_007.png)

  3. 打开 settings 中的 Auto-show，将会自动播放整个应用；关闭 Auto-show，自动播放就结束。


# 步骤五 退出 Demo

关闭模拟器退出 Demo，如下图所示：

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455185653_026.png)

# 常见问题

## 1\. adb 命令找不到

### 原因

未安装 adb 工具。

### 解决方案

安装 adb，执行以下命令：  

    
    
    sudo apt install android-tools-adb

## 2\. 字体显示为乱码

### 原因

未正确加载字体资源。

### 解决方案

请按[步骤三](<#步骤三-启动模拟器并推送资源>)进行资源推送。

---

