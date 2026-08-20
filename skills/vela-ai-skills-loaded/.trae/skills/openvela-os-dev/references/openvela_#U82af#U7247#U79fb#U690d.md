# 芯片移植

> 来源: openvela官方
> 共 3 篇文档

---

## 新平台适配指南

> 路径: 新平台适配指南
> 来源: [https://doc.openvela.com/document?id=602&language=cn&version=dev](https://doc.openvela.com/document?id=602&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/chip_porting/porting_guide.md>) | 简体中文 ]

本文旨在介绍 openvela 的启动（bringup）流程，以及如何为其适配新的芯片和板级设计。

# 一、概述

openvela 是一个支持多种硬件平台的嵌入式操作系统，具有模块化和高扩展性。通过分层架构设计，openvela 简化了从处理器架构、芯片层到板级平台的适配工作。本文档介绍 openvela 的系统架构、移植步骤及相关开发资源。

## 1、系统架构

openvela 的设计分为三层架构，分别是架构层（Architecture）、芯片层（Chip/SoC）和板级层（Board）。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455109969_001.svg)

### 架构层（Architecture）

架构层是系统的核心基础，定义了 CPU 架构，例如 ARMv7-M、ARMv7-A/R 和 RISC-V 等主流处理器架构。openvela 已支持多种 CPU 架构，通常无需进行修改或适配。

### 芯片层（Chip/SoC）

芯片层（System on Chip，简称 SoC）基于具体的处理器架构进行扩展，包含芯片的特定逻辑设计，例如中断控制、时钟管理、通用 I/O 逻辑和专用外设模块。例如，采用 ARMv7-M 处理器架构的 STM32 是典型的 SoC。

### 板级层（Board）

板级层在芯片的基础之上，连接外设以形成特定功能的开发板。例如，STM32F4 Discovery 开发板包含 STM32F407 SoC，同时集成了外部传感器和其他辅助电路板。板级层的适配通常包含 PIN 脚定义、板级驱动和硬件初始化逻辑。

在开发过程中，多个相似 SoC 或开发板可以共享公共部分代码，以提升开发效率和维护便捷性。

## 2、支持平台与移植说明

openvela 已支持多种主流开发板，可参考 [Supported Platforms](<https://nuttx.apache.org/docs/latest/platforms/index.html#>) 获取详细信息。

如果需要将 openvela 移植到一个新的开发板上，需完成以下适配工作：

  1. 确保目标架构（Architecture）已被 openvela 支持。
  2. 针对新开发板，完成以下层次的适配：

     * 芯片层（Chip/SoC）：增加目标芯片的支持，代码通常遵循 nuttx/arch 下的某种架构目录（如 armv8-m、risc-v、arm64 等）。
     * 板级层（Board）：完成与目标开发板相关的配置、链接脚本及驱动适配。 


完成适配流程后，可生成以下二进制产物，用于部署到目标硬件：

  * **libarch.a** ：架构层静态库。
  * **libboards.a** ：代码驱动静态库。
  * **vela_nuttx.bin** ：编译生成的最终运行二进制文件。


## 3、新平台移植流程

移植 openvela 时，需要完成以下操作：

  1. 熟悉代码结构。 开发者需熟悉 [Vendor 代码仓](</document?id=604&version=dev&language=cn>)的基本结构，vendor 目录支持通过 Git 仓库管理厂商定制化代码。目录命名通常以厂商名称命名，例如 [open-vela/vendor_template](<https://github.com/open-vela//vendor_template>) 为适配模板。
  2. 配置 Kconfig 文件。

     * Kconfig：用于定义编译选项和模块依赖项。开发者需根据硬件模块和外设配置文件，确保所需功能已在 Kconfig 中启用。Kconfig 使用可参考 [Kconfig 使用指南](</document?id=609&version=dev&language=cn>)。
  3. 编写 Makefile。

     * Makefile 使用工具链完成代码编译，需确保规则定义正确，并支持目标硬件平台。
  4. 完成芯片层（Chip/SoC）与板级层（Board）代码适配。 根据 [open-vela/vendor_template](<https://github.com/open-vela//vendor_template>) 中的模板，适配芯片层和板级层代码。需要更新驱动文件、板级配置文件，以及完成硬件初始化逻辑。

  5. 编译与测试。 编译并生成目标静态库和最终运行文件，测试所有功能是否工作正常。


## 4、编译方式与产物管理

开发者需关注以下内容：

  * 所有定制代码存放在 vendor 目录中，不得修改核心代码，以便与 openvela 的主仓库保持兼容。
  * 编译步骤生成的产物包括：
    * **libarch.a** ：架构层代码库。
    * **libboards.a** ：板级代码库。
    * **vela_nuttx.bin** ：最终的二进制镜像，用于固件烧录。


## 5、示例流程图

以下为 openvela 新平台移植的流程图，直观展示了开发步骤及逻辑顺序：

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455110068_002.png)

下面以 vendor 目录下适配为例，所有 **vendor** 仓库的初始源代码为 [open-vela/vendor_template](<https://github.com/open-vela//vendor_template>)，该模板包含了 操作系统的基本代码结构，因此适配过程只需打开相应文件进行修改。

# 二、芯片层适配

芯片层适配是 openvela 框架中支持硬件平台的重要环节，主要完成基于操作系统的入口函数，涉及以下方面的实现与配置：

  1. 启动入口函数：定义操作系统的初始加载逻辑。
  2. 架构（Arch） API 实现：实现系统调用所需的基础架构接口。
  3. 中断适配：配置中断处理函数及相关寄存器。
  4. 串口驱动：实现串口输入输出，并进行串口驱动注册。
  5. 定时器驱动：支持操作系统调度和时间相关功能。
  6. 内存（堆区）初始化：配置动态内存分配所需的堆区。
  7. Kconfig 和 Makefile 编写：管理配置选项和代码构建流程。


芯片层代码位于 vendor/<vendor_name>/chips 目录下，典型的目录结构如下所示：  

    
    
    vendor/vendor_name/
    ├── chips
    │   └── <chip_name>
    │       ├── chip.h
    │       ├── include
    │       │   ├── chip.h
    │       │   └── irq.h
    │       ├── Kconfig
    │       ├── Make.defs
    │       ├── <vendor_name>_irq.c
    │       ├── <vendor_name>_irq.h
    │       ├── <vendor_name>_lowputc.c
    │       ├── <vendor_name>_lowputc.h
    │       ├── <vendor_name>_start.c
    │       ├── <vendor_name>_start.h
    │       └── <vendor_name>_timeisr.c

## 1、启动入口

### 概述

在 nuttx/arch 目录下，系统为统一异常处理流程，为每个架构（arch）都定义了异常向量表（如 _vectors）。

以 [ARMv8-M](<https://github.com/open-vela/nuttx/blob/41545a4ca98165813908e5fe25d3ecdbfc5ab19a/arch/arm/src/armv8-m/arm_vectors.c#L94>) 为例，当发生复位异常时，系统会调用不同芯片实现的 __start 函数。

__start 函数的具体实现位于 **< vendor_name>**_start.c 文件中。开发者可以参考典型实现，如 [stm32_start.c](<https://github.com/open-vela/nuttx/blob/41545a4ca98165813908e5fe25d3ecdbfc5ab19a/arch/arm/src/stm32f7/stm32_start.c>)，以完成芯片平台的适配。

### __start 函数的职责

__start 函数是系统复位异常的入口函数，其主要职责包括以下方面：

  * 清除 BSS 段：
    * BSS（Block Started by Symbol）段用于存储未初始化的全局变量和静态变量。在系统复位后，需将其清零。
  * 拷贝 .data 和 RAM 函数到指定位置：
    * 将只读存储器（如 Flash）中的 .data 段和 RAM 函数拷贝到运行时 RAM 的指定区域。
  * 初始化必要模块：
    * 配置系统时钟（clock）。
    * 初始化串口（serial）。
    * 设置堆栈限制（stack limit）等环境变量。
  * 调用操作系统启动入口：
    * 通过 nx_start() 函数加载和启动 openvela 核心操作系统。


### 示例代码：__start 函数

以下是一个标准的 __start 函数实现模板，用于完成系统复位入口的初始化流程：  

    
    
    /****************************************************************************
     * Name: __start
     *
     * Description:
     *   This is the reset entry point.
     *
     ****************************************************************************/
    
    void __start(void)
    {
      /* do something initialize */
      
      ...
      
    #ifdef CONFIG_ARCH_PERF_EVENTS
      up_perf_init((void *)STM32_SYSCLK_FREQUENCY);
    #endif
    
      /* Perform early serial initialization */
    
    #ifdef USE_EARLYSERIALINIT
      arm_earlyserialinit();
    #endif
    
      /* Bring up NuttX */
        
      nx_start();
    
      /* Shouldn't get here */
    
      for (; ; );
    }

## 2、串口

### 概述

芯片通常包含多路串口，通常选用一路串口作为系统控制台（console），用于输出日志和 nsh 交互。在系统初始化（bringup）过程中，这一路串口的正常工作非常关键，详情请参见[串口驱动适配](</document?id=648&version=dev&language=cn>)。

### 代码位置

  * 参考实现：

    * [stm32_serial.c](<https://github.com/open-vela/nuttx/blob/41545a4ca98165813908e5fe25d3ecdbfc5ab19a/arch/arm/src/stm32f7/stm32_serial.c>)
    * [stm32_lowputc.c](<https://github.com/open-vela/nuttx/blob/41545a4ca98165813908e5fe25d3ecdbfc5ab19a/arch/arm/src/stm32f7/stm32_lowputc.c>)
  * 串口相关实现一般位于：

    * <vendor_name>_lowputc.c
    * <vendor_name>_serial.c


### 初始化流程

  * 串口的初始化通常发生在 nx_start 之前。

  * 每个架构（arch）都会提供 <arch>_earlyserialinit 接口，用于初始化控制台对应的串口寄存器，后续可通过 <arch>_lowputc 函数完成日志打印。下面是 ARM 平台的示例函数：
        
        ./arm/src/common/arm_internal.h
        
            /****************************************************************************
            - Name: arm_earlyserialinit
            -
            - Description:
            - Performs the low level USART initialization early in debug so that the
            - serial console will be available during bootup.  This must be called
            - before arm_serialinit.
            -
             ****************************************************************************/
        
            #ifdef USE_EARLYSERIALINIT
            void arm_earlyserialinit(void)
            {
            }
        
            /****************************************************************************
            - Name: arm_lowputc
            -
            - Description:
            - Output one byte on the serial console
            -
             ****************************************************************************/
        
            void arm_lowputc(char ch)
            {
            }


### 串口访问

操作系统代码会使用通用架构接口 up_putc 和 up_puts 来直接访问串口，其中 up_putc 需要厂商实现。  

    
    
    /****************************************************************************
     * Name: up_putc
     *
     * Description:
     *   Provide priority, low-level access to support OS debug writes
     *
     ****************************************************************************/
    
    void up_putc(int ch)
    {
    }

### 串口驱动注册

为了使应用可以通过标准输入/输出（stdin/out/err）访问物理串口，必须注册串口驱动。

  * 每个架构提供 <arm>_serialinit 接口，由厂商实现。

  * 内部调用 uart_register 注册控制台和其他串口设备节点。以下为 ARM 平台示例：  

        
        /****************************************************************************
            - Name: arm_serialinit
            -
            - Description:
            - Register serial console and serial ports.  This assumes
            - that arm_earlyserialinit was called previously.
            -
             ****************************************************************************/
        
            void arm_serialinit(void)
            {
                #ifdef CONSOLE_DEV
                uart_register("/dev/console", &CONSOLE_DEV);
                #endif
                ...
            }


## 3、定时器

### 概述

定时器（Timer）与系统的计时和定时相关。在 openvela 中，提供了两种主要的驱动模型：

  * arch_alarm：基于单次定时器（oneshot driver）。
  * arch_timer：基于常规计时器（timer driver）。


两种驱动的主要区别在于硬件计数器超时后的处理方式，这直接影响定时精度和误差。

### 驱动模型区别与适用

  * arch_alarm 适用于硬件计数器超时后无需清空计数器的情况。该模型避免了重新启动计数器带来的累计误差，**优先推荐使用** ，更多详情请参见 [Arch_Alarm 框架开发指南](</document?id=654&version=dev&language=cn>)。
  * arch_timer 通常适配于如系统滴答定时器（systick）等周期性定时器，硬件计数器在超时后需要清空并重新启动，更多详情请参见 [Arch Timer 驱动框架使用指南](</document?id=653&version=dev&language=cn>)。


### arch_alarm 驱动适配流程

厂商实现时，主要关注如下步骤：

  1. 实现单次定时器（oneshot）驱动。
  2. 在 up_timer_initialize 函数中，调用驱动初始化接口创建 oneshot_lowerhalf_s 实例。
  3. 调用 up_alarm_set_lowerhalf 将驱动与系统 arch_alarm 模型绑定。


以下是 up_timer_initialize 函数的参考实现，位于 [arm_arch_timer.c](<https://github.com/open-vela/nuttx/blob/41545a4ca98165813908e5fe25d3ecdbfc5ab19a/arch/arm/src/armv8-r/arm_arch_timer.c#L377>)：  

    
    
    /****************************************************************************
     * Function:  up_timer_initialize
     *
     * Description:
     *   This function is called during start-up to initialize the timer
     *   interrupt.
     *
     ****************************************************************************/
    
    void up_timer_initialize(void)
    {
       struct oneshot_lowerhalf_s *lower = xxx_oneshot_initialize();
       
       up_alarm_set_lowerhalf(lower);
    }

## 4、异常/中断

每个架构（arch）都提供好了对应的中断异常向量表，使得厂商能够调用 irq_attach 绑定相应的中断处理函数。

为实现中断的初始化、启用、禁用和优先级设置，厂商需要实现一系列与架构相关的以 up_ 开头的函数。

  * 详细内容请参见[中断系统适配指南](</document?id=603&version=dev&language=cn>)。
  * 相关代码请参考 [stm32_irq.c](<https://github.com/open-vela/nuttx/blob/41545a4ca98165813908e5fe25d3ecdbfc5ab19a/arch/arm/src/stm32f7/stm32_irq.c>)，中断的实现在<vendor_name>_irq.c中。


## 5、Stack/Heap

### 概述

在嵌入式系统中，栈（stack）和堆（heap）的划分至关重要。通常在平面构建（flat build）下的内存布局如下：  

    
    
    .data region              Size determined at link time.
    .bss region               Size determined at link time.
    IDLE thread stack         Size determined by CONFIG_IDLETHREAD_STACKSIZE.
    Heap                      Extends to the end of SRAM.

说明如下：

  * .data 区域：该区域大小在链接时确定。
  * .bss 区域：该区域大小在链接时确定。
  * IDLE 线程栈：大小由 CONFIG_IDLETHREAD_STACKSIZE 定义。
  * 堆（Heap）：从静态随机存取存储器（SRAM）的末尾向下延伸。


> 注意
> 
> IDLE 栈通常位于 .bss 段之后，其大小由 CONFIG_IDLETHREAD_STACKSIZE 指定，堆紧随其后。

### 中断栈配置

  * 厂商可通过配置项 CONFIG_ARCH_INTERRUPTSTACK 设置中断栈大小。
  * 中断栈空间由全局变量 g_intstackalloc 定义。
  * 各架构通过对应的初始化函数（例如 arm_initialize_stack）调用 up_get_intstackbase 获取中断栈底部地址，并根据 CONFIG_ARCH_INTERRUPTSTACK 计算栈顶。


### 堆管理

  * openvela 支持多个独立的堆管理。同一堆可包含多个不连续的物理内存区域。
  * 系统、驱动和应用通过 kmm_malloc 或标准 malloc API 申请堆内存。
  * 参考代码位置：[stm32_allocateheap.c](<https://github.com/open-vela/nuttx/blob/41545a4ca98165813908e5fe25d3ecdbfc5ab19a/arch/arm/src/stm32f7/stm32_allocateheap.c>)。


### 堆大小计算

通常情况下，系统的剩余 RAM（去除了 .data、.bss 和 IDLE 栈等部分）将注册为堆。因此，堆的总大小会随系统的变化而变化。可以使用以下方法计算堆的起始地址和大小：

  * 起始地址：ebss + CONFIG_IDLETHREAD_STACKSIZE
  * 堆大小：RAM 末地址 - 起始地址


## 6、Kconfig 和 Make.defs

### 概述

Kconfig 和 Make.defs 是构建和配置 openvela 系统的两个重要文件。它们分别用于定义芯片的配置项和管理编译源文件。

### Kconfig 作用

chip 目录下的 Kconfig 文件用于定义芯片相关的配置项，内容包括：

  * 芯片型号（Chip Model）
  * 芯片功能（Chip Features）
  * 内部模块配置项（Internal Module Settings）


例如，[nuttx/arch/arm/src/stm32f7/Kconfig](<https://github.com/open-vela/nuttx/blob/41545a4ca98165813908e5fe25d3ecdbfc5ab19a/arch/arm/src/stm32f7/Kconfig>) 文件定义了 STM32F7 系列芯片的相关配置，支持不同型号的 flash 配置和片内驱动配置。

以下是针对 STM32F7 系列芯片的 Kconfig 配置片段示例，其中 ARCH_CHIP_STM32F722RC 和 ARCH_CHIP_STM32F722RE 都属于定义该芯片系列的选项，但两者具有不同的 flash 配置。  

    
    
    if ARCH_CHIP_STM32F7
    
    comment "STM32 F7 Configuration Options"
    
    choice
            prompt "STM32 F7 Chip Selection"
            default ARCH_CHIP_STM32F746NG
            depends on ARCH_CHIP_STM32F7
    
    config ARCH_CHIP_STM32F722RC
            bool "STM32F722RC"
            select STM32F7_STM32F722XX
            select STM32F7_FLASH_CONFIG_C
            select STM32F7_IO_CONFIG_R
            ---help---
                    STM32 F7 Cortex M7, 256 FLASH, 256K (176+16+64) Kb SRAM
    
    config ARCH_CHIP_STM32F722RE
            bool "STM32F722RE"
            select STM32F7_STM32F722XX
            select STM32F7_FLASH_CONFIG_E
            select STM32F7_IO_CONFIG_R
            ---help---
                    STM32 F7 Cortex M7, 512 FLASH, 256K (176+16+64) Kb SRAM
    ...
    endif

  * choice 节点定义了芯片选择菜单，用户可通过该配置选择具体芯片型号。
  * 各 config 项对应具体芯片型号，指定对应的特性和资源分配（如 flash 大小和 IO 配置）。
  * select 关键字用于自动选择相应的配置子项。


芯片的片内驱动及各种硬件相关配置也可以在此 Kconfig 文件中进行定义和管理。

### Make.defs 作用

Make.defs 文件用于管理参与编译的源文件列表，确保构建系统正确编译所需代码。在对应的 Make.defs 文件中，需要添加所有要参与编译的源文件，确保构建系统能够正确处理各模块代码。可参考 [nuttx/arch/arm/src/stm32f7/Make.defs](<https://github.com/open-vela/nuttx/blob/41545a4ca98165813908e5fe25d3ecdbfc5ab19a/arch/arm/src/stm32f7/Make.defs>) 示例文件。

## 7、chip.h 和 irq.h 文件说明

  * chip.h 文件
    * vendor/vendor_name/chip/chip_name 目录下有两个 chip.h 文件：
      * 局部 chip.h：位于当前目录，定义与该芯片相关的宏和函数声明。
      * 公共 chip.h：位于 include/chip.h，通过 #include <arch/chip/chip.h> 引用，定义与架构相关的宏和函数，被架构层公共代码使用。
  * irq.h 文件
    * 结构类似：存在局部和公共两个层次。
    * 公共 include/irq.h 负责架构通用中断相关定义。
    * 局部 irq.h 针对具体芯片的中断定义。
  * 引用建议
    * 局部文件用于芯片特定代码，使用相对路径引用。
    * 公共文件用于架构共享代码，通过标准 include 路径引用。
  * 目的
    * 明确区分局部与公共文件，避免混淆和冲突。
    * 保证代码模块化，架构统一。


# 三、板级层适配

板级层适配主要完成以下内容：

  * 链接脚本（Linker Script）
  * 主 Make.defs
  * etcramfs 构建
  * Board 配置（Board Configs）
  * Board 初始化代码


整体代码结构如下：  

    
    
    vendor/vendor_name/
    ├── boards
    │   └── <chip_name>
    │       └── <board_name>
    │           ├── configs
    │           │   └── nsh
    │           │       └── defconfig
    │           ├── include
    │           │   ├── board.h
    │           │   └── nsh_romfsimg.h
    │           ├── Kconfig
    │           ├── scripts
    │           │   ├── ld.script
    │           │   └── Make.defs
    │           └── src
    │               ├── board_name.h
    │               ├── etc
    │               │   ├── group
    │               │   ├── init.d
    │               │   │   ├── rcS
    │               │   │   └── rc.sysinit
    │               │   └── passwd
    │               ├── Makefile
    │               ├── <vendor_name>_appinit.c
    │               ├── <vendor_name>_boot.c
    │               └── <vendor_name>_bringup.c

## 1、初始化代码

### 阶段划分

  * board_early_initialize：在 idle 任务前执行，早期硬件初始化。
  * board_late_initialize：在 Appbringup 线程上下文执行，常规驱动初始化。
  * board_app_initialize：在 nsh 任务上下文执行，文件系统与核心服务初始化。
  * board_app_finalinitialize：在 nsh 任务上下文执行，应用相关初始化。


详细流程请参见[启动流程](</document?id=614&version=dev&language=cn>)，厂商需要按照外设所初始化的时刻写到对应的函数中。

### 示例代码

相关的文件包括：

  * <vendor_name>_bringup.c
  * <vendor_name>_appinit.c
  * <vendor_name>_boot.c


示例代码可参考 [nuttx/boards/arm/stm32f7/stm32f746g-disco/src/stm32_boot.c](<https://github.com/open-vela/nuttx/blob/41545a4ca98165813908e5fe25d3ecdbfc5ab19a/boards/arm/stm32f7/stm32f746g-disco/src/stm32_boot.c#L99>)  

    
    
    #ifdef CONFIG_BOARD_EARLY_INITIALIZE
    void board_early_initialize(void)
    {
    
    }
    #endif
    
    #ifdef CONFIG_BOARD_LATE_INITIALIZE
    void board_late_initialize(void)
    {
    
    }
    
    int board_app_initialize(uintptr_t arg)
    {
    
    }
    
    #ifdef CONFIG_BOARDCTL_FINALINIT
    int board_app_finalinitialize(uintptr_t arg)
    {
    
    }
    #endif

## 2、ETCROMFS 构建

  * 功能说明： 根文件系统以只读文件系统（ROMFS）形式存放于 Flash。
  * 用途： 存储应用配置文件、密钥等敏感文件。
  * 添加文件步骤：
    * 在 Make.defs 中通过 RCRAWS 增加目标文件路径。
    * 删除 etctmp 目录后，触发增量编译。
    * 启动后，文件可通过 /etc/ 路径访问。


### 示例 Make.defs 配置
    
    
    ifeq ($(CONFIG_ETC_ROMFS),y)                                  
    RCSRCS += etc/init.d/rc.sysinit etc/init.d/rcS                
    RCRAWS += etc/group etc/passwd                                
    RCRAWS += etc/build.prop                                      
    RCRAWS += etc/txtable.txt                                     
                                                                  
    ifneq ($(CONFIG_UTILS_AVB_VERIFY)$(CONFIG_UTILS_ZIP_VERIFY),) 
      RCRAWS += etc/key.avb                                       
    endif                                                         
                                                                  
    ifeq ($(CONFIG_ATS3085X_BOOTLOADER),y)                        
    RCRAWS += etc/factory.sh                                      
    endif

## 3、链接脚本

每个 board 可配置自定义链接脚本，该链接脚本在 board/Make.defs 中通过 LDSCRIPT 关键字指定。一般链接脚本存放于如下路径： vendor/vendor_name/boards/chip_name/board_name/scripts

例如：[nuttx//boards/arm/stm32f7/stm32f746g-disco/scripts/flash.ld](<https://github.com/open-vela/nuttx/blob/41545a4ca98165813908e5fe25d3ecdbfc5ab19a/boards/arm/stm32f7/stm32f746g-disco/scripts/flash.ld>)

链接脚本的要求包括：

  * 设置 ENTRY 为 _vectors，以支持全局向量表。
  * 若支持 backtrace，需添加 .arm.exidx 段。更多详情请参见 [Backtrace](<https://github.com/open-vela/docs/tree/dev//zh-cn/device_dev_guide/debugging/memory/offline/backtrace.md>)。


链接脚本示例：  

    
    
    MEMORY
    {                                                                                       
      flash (rx) : ORIGIN = 0x10000000, LENGTH = 2560K                                      
      sram (rwx) : ORIGIN = 0x01000400, LENGTH = 111K                                       
      psram (rwx) : ORIGIN = 0x18000000, LENGTH = 4M                                        
      dsp_inner_ram (rwx) : ORIGIN = 0x01054000, LENGTH = 16K                           
      share_ram (rwx) : ORIGIN = 0x0106A600, LENGTH = 22K                                   
    }        
                                                                                   
    OUTPUT_ARCH(arm)                                                                        
    EXTERN(_vectors)                                                                        
    ENTRY(_stext)                                                                           
    SECTIONS                                                                                {                                                                                       
        .text : {                                                                           
            . = 0x200;                                                                      
            _stext = ABSOLUTE(.);                                                           
            *(.vectors)                                                                     
            *(.text .text.*)                                                                
            *(.fixup)                                                                       
            *(.gnu.warning)                                                                 
            *(.rodata .rodata.*)                                                            
            *(.gnu.linkonce.t.*)                                                            
            *(.glue_7)                                                                      
            *(.glue_7t)                                                                     
            *(.got)                                                                         
            *(.gcc_except_table)                                                            
            *(.gnu.linkonce.r.*)                                                            
            _etext = ABSOLUTE(.);                                                         
        } > flash    
    }

## 4、配置文件（Configs）

每个 board 可包含多个配置文件（config files），通常以 nsh 配置启动系统，仅具基本功能，配置位置在： vendor/vendor_name/boards/chip_name/board_name/configs/nsh。

例如：[nuttx/boards/arm/stm32f7/stm32f746g-disco/configs](<https://github.com/open-vela/nuttx/tree/41545a4ca98165813908e5fe25d3ecdbfc5ab19a/boards/arm/stm32f7/stm32f746g-disco/configs>)

> 注意
> 
> openvela 建议不要增加太多配置文件，以减少维护负担。

## 5、Kconfig、Makefile 和 Make.defs

  * Kconfig：定义板外设的配置项，包括外设驱动和板级配置。更多详情请参见 [Kconfig](<https://github.com/open-vela/nuttx/blob/41545a4ca98165813908e5fe25d3ecdbfc5ab19a/boards/arm/stm32f7/stm32f746g-disco/Kconfig>) 示例。

  * Makefile：将需要编译的源文件添加到构建中，最终生成 libboard.a。更多详情请参见 [Makefile](<https://github.com/open-vela/nuttx/blob/41545a4ca98165813908e5fe25d3ecdbfc5ab19a/boards/arm/stm32f7/stm32f746g-disco/src/Make.defs>) 示例。

  * scripts/Make.defs：顶层构建配置，包含系统配置 .config、Toolchain.defs、链接脚本及外部库引用等。详情请参见 [Make.defs](<https://github.com/open-vela/nuttx/blob/41545a4ca98165813908e5fe25d3ecdbfc5ab19a/boards/arm/stm32f7/stm32f746g-disco/scripts/Make.defs>) 示例。

示例 Make.defs 片段：
        
        include $(TOPDIR)/.config
            include $(TOPDIR)/tools/Config.mk
            include $(TOPDIR)/arch/arm/src/armv7-m/Toolchain.defs
        
            LDSCRIPT = ld.script
        
            ARCHSCRIPT += $(BOARD_DIR)$(DELIM)scripts$(DELIM)$(LDSCRIPT)
        
            CFLAGS := $(ARCHCFLAGS) $(ARCHOPTIMIZATION) $(ARCHCPUFLAGS) $(ARCHINCLUDES) $(ARCHDEFINES) $(EXTRAFLAGS) -pipe
            CPICFLAGS = $(ARCHPICFLAGS) $(CFLAGS)
            CXXFLAGS := $(ARCHCXXFLAGS) $(ARCHOPTIMIZATION) $(ARCHCPUFLAGS) $(ARCHXXINCLUDES) $(ARCHDEFINES) $(EXTRAFLAGS) -pipe
            CXXPICFLAGS = $(ARCHPICFLAGS) $(CXXFLAGS)
            CPPFLAGS := $(ARCHINCLUDES) $(ARCHDEFINES) $(EXTRAFLAGS)
            AFLAGS := $(CFLAGS) -D__ASSEMBLY__
        
            EXTRA_LIBS += $(wildcard $(shell readlink -f $(TOPDIR)/$(CONFIG_ARCH_BOARD_CUSTOM_DIR)/libs/$(CONFIG_ARCH_BOARD_CUSTOM_NAME))/*.a)
            EXTRA_LIBS += $(wildcard $(shell readlink -f $(TOPDIR)/$(CONFIG_ARCH_BOARD_CUSTOM_DIR)/libmedia/*.a))


## 6、board.h 与 nsh_romfsimg.h

  * board.h：主要用于定义外设驱动和板级配置相关的宏或函数声明，通过 <arch/board/board.h> 引入。 可参考 [nuttx/boards/arm/stm32f7/stm32f746g-disco/include/board.h](<https://github.com/open-vela/nuttx/blob/41545a4ca98165813908e5fe25d3ecdbfc5ab19a/boards/arm/stm32f7/stm32f746g-disco/include/board.h>) 示例。
  * nsh_romfsimg.h：自动生成的根文件系统内容，不建议手动修改。


## 7、工具链

厂商可导入自定义工具链，通常存放于 vendor/vendor_name/prebuilt。可通过 board/scripts/Make.defs 配置编译器、链接器工具路径等。

# 四、构建运行

openvela 支持两种编译方式：CMake 和 Make。

推荐使用以下 CMake 命令进行构建：  

    
    
    ./build.sh vendor/vendor_name/board/chip_name/configs/nsh --cmake -j8

执行上述命令后，将生成 vela_ap.bin 文件，厂商可采用相应的烧录方式进行运行验证。

# 五、测试验证

厂商完成适配后，需要通过准入测试进行检验，主要包括以下几个方面：

  * 功能测试
  * 稳定性测试
  * 性能测试

---

## 中断系统适配指南

> 路径: 中断系统适配指南
> 来源: [https://doc.openvela.com/document?id=603&language=cn&version=dev](https://doc.openvela.com/document?id=603&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/chip_porting/Interrupt_System_Adaptation_Guide.md>) | 简体中文 ]

# 一、实现芯片中断调试

在调试芯片中断子系统（bringup）时，厂商需要实现一系列与架构相关的函数（arch 函数），以完成以下任务：

  * 初始化中断
  * 启用和禁用中断
  * 设置中断优先级


以下内容提供了具体的要求和实现示例。

## 1、需要实现的中断相关函数

以下是厂商（ Vendor）需要实现的中断相关函数及其功能说明。

  1. 初始化中断系统，包括禁用所有中断、配置向量表位置、设置默认优先级以及启用中断。  

         
         void up_irqinitialize(void)
         {
             // Disable all interrupts
             // Set the NVIC vector location
             // Set all interrupts (and exceptions) to the default priority
             // Attach the SVCall and Hard Fault exception handlers
             // enable interrupts
         }

  2. 启用指定中断。  

         
         void up_enable_irq(int irq)
         {
             //enable interrupt with irq
         }

  3. 禁用指定的中断号。  

         
         void up_disable_irq(int irq)
         {
             //disable interrupt with irq
         }

  4. 设置中断优先级。 如果启用了 CONFIG_ARCH_IRQPRIO 配置，则需要实现以下函数：  

         
         #ifdef CONFIG_ARCH_IRQPRIO
         int up_prioritize_irq(int irq, int priority)
         {
             // set irq priority
         }
         #endif

  5. 管理中断状态。

     * 判断 flags 当前是否是关中断状态。  

           
           #define up_irq_is_disabled(flags)

     * 保存当前中断状态并关闭中断。  

           
           // 关中断
           irqstate_t up_irq_save(void)
           {
           }

     * 恢复指定中断状态。  

           
           // 恢复flags表示的中断状态
           void up_irq_restore(irqstate_t flags)
           {
           }

     * 开启所有中断。  

           
           // 开启所有中断
           irqstate_t up_irq_enable(void)
           {
           }

     * 获取当前中断状态。  

           
           // 获取当前中断状态
           irqstate_t irqstate(void)
           {
           }

  6. 处理核间中断：  

         
         // 发起核间中断
         void up_trigger_irq(int irq, cpu_set_t cpuset)

  7. 设置中断的安全属性。

     * 设置指定中断的安全属性。  

           
           // 设置中断安全属性
           void up_secure_irq(int irq, bool secure)

     * 改变所有中断的安全属性。  

           
           // 改变所有中断安全属性
           void up_secure_irq_all(bool secure)


## 2、需要定义的中断相关宏

除上面的函数实现，厂商还需定义一系列中断相关的宏，用于描述 NVIC（Nested vectored interrupt controller） 的配置，这些宏需定义在chips/chip_name/include/irq.h 文件中。可参考 [RTL8720C 示例](<https://github.com/open-vela//nuttx/blob/dev/arch/arm/src/rtl8720c/include/irq.h>)。

以下是必须实现的宏及其功能说明：

  1. 第一个中断向量号。  

         
         #define NVIC_IRQ_FIRST  (16)   /* Vector number of the first interrupt */

  2. 中断数量。  

         
         #define NR_IRQS (64)

  3. NVIC 优先级级别。

     * 最低优先级  

           
           #define NVIC_SYSH_PRIORITY_MIN  0xff /* All bits set in minimum priority */

     * 默认优先级  

           
           #define NVIC_SYSH_PRIORITY_DEFAULT  0x40 /* Midpoint is the default */

     * 最高优先级  

           
           #define NVIC_SYSH_PRIORITY_MAX   0x00 /* Zero is maximum priority */

     * 优先级步长  

           
           #define NVIC_SYSH_PRIORITY_STEP 0x40 /* Three bits priority used, bits[7-6] as group */

     * 子优先级步长  

           
           #define NVIC_SYSH_PRIORITY_SUBSTEP  0x20 /* Three bits priority used, bit[5] as sub */


# 二、中断绑定处理函数

在中断处理过程中，可以通过以下三种方式绑定处理函数。每种方式适用于不同场景，具有各自的优缺点。

## 1、使用irq_attach
    
    
    int irq_attach(int irq, xcpt_t isr, FAR void *arg)

  1. 工作机制。

     * 当中断触发时，isr 在中断上下文中被调用。
     * 这种方式的优点是效率高，因为中断处理直接在中断上下文中完成。
     * isr 执行期间会屏蔽所有中断应，对实时性要求较高的系统不太合适。
     * isr中不能调用会导致阻塞的 API（例如 sleep、wait 等）。
  2. 解除绑定。  

         
         irq_detach(irq)

  3. 优缺点。

     * 优点：处理效率高。
     * 缺点：中断处理期间屏蔽所有中断，影响系统实时性。


## 2、使用irq_attach_thread
    
    
    int irq_attach_thread(int irq, xcpt_t isr, xcpt_t isrthread, FAR void *arg, int priority, int stack_size)

  1. 工作机制。

     * 用户需提供 1 个或者 2 个处理函数：
       * isr 在中断上下文中被调用，通常用于屏蔽当前中断并快速唤醒 isrthread。
       * isrthread 在线程上下文中被调用，用于处理剩余中断任务。
     * 如果 isr 为 NULL，会直接调用 isrthread。
  2. 优势。

     * isr 的执行时间被尽可能缩短，从而提升系统实时性。
     * isrthread 作为线程运行，支持优先级调度，可以被其他高优先级任务抢占。
  3. 劣势。

     * 消耗更多内存（独立线程栈和中断线程结构体）。
     * 增加一次上下文切换，降低效率。
     * 中断处理完成时间会有一定延迟（约 5 微秒）。
  4. 解除绑定。  

         
         irq_detach_thread(irq)


## 3、使用irq_attach_wqueue
    
    
    int irq_attach_wqueue(int irq, xcpt_t isr, xcpt_t isrwork, FAR void *arg, int priority)

  1. 工作机制。

     * 用户需提供 1 个或 2 个处理函数：
       * isr 在中断上下文中被调用。
       * isrwork 在工作队列上下文中被调用。
     * 与 irq_attach_thread 的区别在于，isrwork 在工作队列中被执行，而不是独立线程中。
  2. 优势。

     * 多个优先级相同的中断可以复用同一个工作队列，从而节省内存。
     * 高优先级的工作队列可以抢占低优先级队列。
     * 如果中断数量较多，比 irq_attach_thread 更节省内存。
  3. 劣势。

     * 如果只有一个中断，工作队列的创建会带来额外开销。
     * 在多核系统中，控制线程属性和数量的灵活性较差。
  4. 解除绑定。  

         
         irq_detach_wqueue(irq)


## 总结对比

绑定方式 | 优点 | 缺点 | 使用场景  
---|---|---|---  
irq_attach | 效率高，直接在中断上下文中处理。 | 中断期间屏蔽所有中断，不适合实时性要求高的系统。 | 处理逻辑简单、实时性要求不高的场景。  
irq_attach_thread | 提升实时性，支持优先级调度。 | 消耗更多内存，增加上下文切换，处理完成有一定延迟。 | 实时性要求高的场景。  
irq_attach_wqueue | 节省内存，支持工作队列复用。 | 单一中断场景效率低，多核场景灵活性不足。 | 中断数量多、内存资源有限的场景。  
  
# 三、中断线程/工作队列的实现示例

以下是绑定中断并实现中断线程或工作队列的示例代码。

## 1、绑定中断

使用 irq_attach_work 函数绑定中断处理程序：  

    
    
    irq_attach_work(IRQ, isrhandle, isrwork, arg, 253)

  * isrhandle：中断处理函数，在中断上下文中执行。
  * isrwork：中断线程或工作队列处理函数，在线程上下文中执行。
  * arg：传递给处理函数的参数。
  * 253：优先级设置。


## 2、中断处理函数示例

在 isrhandle 中返回 IRQ_WAKE_THREAD，以唤醒中断线程或工作队列。如果返回 OK，则不会唤醒中断线程。示例代码如下：  

    
    
    static int isrhandle(int irq, void *regs, void *arg)  
    {  
        up_disabled_irq(irq); // 屏蔽中断，确保退出后中断不会再次触发  
        return IRQ_WAKE_THREAD; // 唤醒中断线程或工作队列  
    }

## 3、中断线程/工作队列处理函数示例

isrwork 用于处理中断任务，并在完成后清除中断状态。示例代码如下：  

    
    
    static int isrwork(int irq, void *regs, void *arg)
    {
      // 执行中断处理逻辑
      // 清除中断的pending位
      up_enabled_irq(irq); // 重新使能中断。
      return OK;
    }

## 4、特殊情况：One-shot 中断

对于一些 one-shot 中断，可以将 isrhandle 设置为 NULL，直接使用 isrwork 处理中断任务。

# 四、中断结构体优化

在中断使用时，系统通常会定义一个全局中断结构体数组：  

    
    
    struct irq_info_s g_irqvector[NR_IRQS];

其中，NR_IRQS 表示系统支持的最大中断号，通常大于 200。然而，实际使用的中断数量通常只有十几个，并且这些中断号是离散分布的。这种设计会导致以下问题：

  * 内存浪费：即使只使用少量中断，也需要为所有可能的中断号分配内存，存储 NR_IRQS 个结构体。
  * 低效资源利用：大部分中断号对应的结构体未被使用，造成资源浪费。


## 1、优化策略与实现原理

为了解决上述问题，可以通过如下动态映射的方式优化中断结构体的存储。

### 映射关系数组

定义一个映射关系数组，用于动态建立中断号与中断结构体的映射：  

    
    
    irq_mapped_t g_irqmap[NR_IRQS]

  * 该数组仅占用 NR_IRQS 字节的额外内存。
  * 在中断使用时，动态建立映射关系。


### 精简中断结构体数组

将 g_irqvector 定义为：  

    
    
    struct irq_info_s g_irqvector[CONFIG_ARCH_NUSER_INTERRUPTS];

  * CONFIG_ARCH_NUSER_INTERRUPTS 表示系统中可能使用的最大中断数量加 1 。
  * 通过限制数组大小，仅为实际可能使用的中断分配内存。


### 中断使用统计

使用 g_irqmap_count 统计当前已使用的中断数量，便于监控和调试。

## 2、配置示例

通过以下宏配置启用优化：  

    
    
    CONFIG_ARCH_MINIMAL_VECTORTABLE_DYNAMINC=y
    CONFIG_ARCH_MINIMAL_VECTORTABLE=y
    CONFIG_ARCH_NUSER_INTERRUPTS=24

  * CONFIG_ARCH_MINIMAL_VECTORTABLE_DYNAMIC：启用动态映射功能。
  * CONFIG_ARCH_MINIMAL_VECTORTABLE：启用精简中断向量表。
  * CONFIG_ARCH_NUSER_INTERRUPTS：设置最大可能使用的中断数量。


## 3、优化效果

  * 内存节省：仅为实际使用的中断分配存储空间，避免为未使用的中断号浪费内存。
  * 灵活性提升：通过动态映射关系，支持离散分布的中断号。
  * 可扩展性：通过配置宏灵活调整中断数量限制。


# 五、相关仓

  * [nuttx](<https://github.com/open-vela//nuttx>)

---

## Vendor 代码仓说明

> 路径: Vendor 代码仓说明
> 来源: [https://doc.openvela.com/document?id=604&language=cn&version=dev](https://doc.openvela.com/document?id=604&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/chip_porting/Vendor.md>) | 简体中文 ]

# 一、概述

为了保障厂商代码的隔离和隐私安全，在 openvela 代码中，可以通过 vendor 目录为厂商代码创建独立的存放目录。具体的目录名称采用厂商的缩写作为标识。

# 二、目录结构

## 1、顶层目录

代码下载完成后，整体目录结构如下：  

    
    
    $ tree -L 1
    .
    ├── apps
    ├── build.sh -> nuttx/tools/build.sh
    ├── external
    ├── frameworks
    ├── nuttx
    ├── prebuilts
    ├── tests
    └── <vendor>
    
    7 directories, 1 file

  * nuttx 包括内核、网络、文件系统等内容。
  * apps 包括示例代码、系统服务、nsh（NuttShell CLI）等内容。
  * external 存放 openvela 系统支持的第三方库，这些库以源码形式提供。
  * prebuilts 包含代码编译所需要的工具链（toolchain）。
  * tests 存放由 openvela 发布的测试集，覆盖网络、文件系统以及系统调用等 API 测试内容。
  * frameworks 提供 openvela 框架的导出头文件，以 .a 库文件形式提供。
  * build.sh 用于代码编译的脚本文件，可通过附加编译参数生成 nuttx.bin 文件。


## 2、vendor 目录结构

vendor 目录用于存放厂商的相关代码和配置。其目录内容布局如下：  

    
    
    $ tree -L 1
    .
    ├── <vendor_name>
    ├── Make.defs
    ├── Makefile
    ├── sim
    └── xiaomi
    
    3 directories, 2 files

  * vendor_name 厂商代码存放的根目录，厂商的所有代码均应存放于此处。
  * sim 包含启动 openvela Simulator 仿真环境所需的配置和源码。
  * xiaomi 存放小米（Xiaomi）提供的库文件，例如蓝牙 bluelet 等相关代码库。


# 三、Vendor 目录和文件

厂商初次获取代码时，vendor_name 目录的布局如下：  

    
    
    //目录位置
    $ pwd
    /home/{name_path}/workspace/velaos/vendor/<vendor_name>
    
    //目录layout
    $ tree -l
    ├── boards
    │   └── <chip_name>
    │       └── <board_name>
    │           ├── configs
    │           │   └── nsh
    │           │       └── defconfig
    │           ├── include
    │           │   ├── board.h
    │           │   └── nsh_romfsimg.h
    │           ├── Kconfig
    │           ├── scripts
    │           │   ├── ld.script
    │           │   └── Make.defs
    │           └── src
    │               ├── board_name.h
    │               ├── etc
    │               │   ├── group
    │               │   ├── init.d
    │               │   │   ├── rcS
    │               │   │   └── rc.sysinit
    │               │   └── passwd
    │               ├── Makefile
    │               ├── <vendor_name>_appinit.c
    │               ├── <vendor_name>_boot.c
    │               └── <vendor_name>_bringup.c
    ├── chips
    │   └── <chip_name>
    │       ├── chip.h
    │       ├── include
    │       │   ├── chip.h
    │       │   └── irq.h
    │       ├── Kconfig
    │       ├── Make.defs
    │       ├── <vendor_name>_irq.c
    │       ├── <vendor_name>_irq.h
    │       ├── <vendor_name>_lowputc.c
    │       ├── <vendor_name>_lowputc.h
    │       ├── <vendor_name>_start.c
    │       ├── <vendor_name>_start.h
    │       └── <vendor_name>_timeisr.c

## 1、boards 目录

boards 目录主要存放和板级硬件相关的所有代码。 每块板的代码组织在 boards/<chip_name>/<board_name> 路径下，其中：

  * chip_name：芯片名称。
  * board_name：板的名称。


### boards/<chip_name>/<board_name> 目录

  * configs 存放该板的所有配置文件。默认包含 nsh（NuttShell CLI）的配置，提供基础操作系统功能。厂商可基于 nsh 配置点亮 openvela，并逐步添加更多功能。
  * include 包含与板相关的头文件：
    * board.h：声明适用于该板的宏和函数，厂商可根据需求修改。
    * nsh_romfsimg.h：提供系统文件的 ROM 文件系统镜像（romfs bin），无需厂商修改。
  * Kconfig 定义与板相关的配置项，包括功能开关和外设选择，厂商需要根据实际需求调整。
  * scripts 包含与构建流程相关的脚本和配置文件：
    * ld.script：板的链接脚本。
    * Make.defs：定义编译流程和文件规则，需厂商根据要求修改。
  * src 包括板级启动和初始化相关的源代码和配置文件。
    * etc：
      * 保存操作系统和应用的启动脚本：
        * rc.sysinit：核心应用启动和文件系统挂载。
        * rcS：应用程序启动脚本。
      * 系统账户文件：
        * group 和 passwd：默认提供示例文件，实际使用时厂商需重新定义。
    * <vendor_name>_*.c 文件： 包括必要的板级启动代码，如外设初始化文件（vendor_name_appinit.c、vendor_name_boot.c 等），用于初始化外设和板级配置，厂商可根据需求扩展这些文件。
    * Makefile：用于构建编译的源文件以及加入 etc 目录的目标文件。


## 2\. chips 目录

chips 目录存放与芯片启动及内部组件（如 UART 驱动、DMA 驱动）相关的代码。 每颗芯片代码组织在 chips/<chip_name> 路径下。

### chips/<chip_name> 子目录说明

  * include 芯片相关的头文件：
    * chip.h：存放芯片通用的宏定义和函数声明。
    * irq.h：中断相关内容。
  * Kconfig 定义与芯片相关的配置项，包括芯片型号、功能选择和模块配置。
  * Make.defs 定义芯片代码的构建流程，列出参与编译的 C 文件。
  * <vendor_name>_*.c 文件： 包含芯片启动所需的默认实现代码，例如：
    * UART 驱动（vendor_name_lowputc.c）。
    * 中断处理（vendor_name_irq.c 和 vendor_name_irq.h）。
    * 系统启动代码（vendor_name_start.c 和 vendor_name_timeisr.c）。 厂商可根据芯片和硬件需求补充其他模块代码。

---

