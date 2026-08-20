# 了解 openvela

> 来源: openvela官方
> 共 2 篇文档

---

## openvela 开源项目

> 路径: openvela 开源项目
> 来源: [https://doc.openvela.com/document?id=583&language=cn&version=dev](https://doc.openvela.com/document?id=583&language=cn&version=dev)

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455079538_openvela.svg)

# openvela

[ [English](<https://github.com/open-vela/docs/tree/dev//README.md>) | 简体中文]

# openvela 简介

openvela 操作系统专为 AIoT 领域量身定制，以轻量化、标准兼容、安全性和高度可扩展性为核心特点。openvela 以其卓越的技术优势，已成为众多物联网设备和 AI 硬件的技术首选，涵盖了智能手表、运动手环、智能音箱、耳机、智能家居设备以及机器人等多个领域。

Vela 的命名源自拉丁语中船帆的含义，也是南方星空中船帆星座的名字。我们选择这个名字的意义是希望与开发者一道携手，共同踏上星辰大海的征途。

# 技术架构

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455079648_001.png)

  * **内核层**

提供基础的操作系统（OS）功能，包括任务调度、跨进程间通信（IPC）、文件系统管理。此外，还提供设备驱动、轻量级 TCP/IP 协议栈和电源管理等精简高效的组件。同时，内核层支持同构多核和异构多核架构，以提升系统在不同架构下的性能支持能力。

  * **服务框架层**

通用的服务框架，专为扩展系统服务设计，包含连接子系统、图形子系统、多媒体子系统、安全子系统和 XPC 跨核通信能力等。该层提供灵活的服务扩展支持，是系统功能扩展的重要基础。

  * **维测工具**

常用工具和维测框架，除了常见的 Logger 和 Debugger 工具外，还包含 Emulator 这一强大的高仿真设备模拟器工具。Emulator 支持全面功能仿真，同时支持 CPU 指令集仿真。

目前模拟器已支持多种产品形态，包括智慧面板、手表、手环和智能有屏音箱等。通过 Emulator 开发者可以使用 PC 端丰富的调试工具和信息，无需真实设备即可进行应用开发调试，降低开发和调试难度。


# 技术优势

  * **高度可扩展**

openvela 的设计注重模块化与可扩展性，使其能够灵活适应多样的物联网应用场景。小到仅配备 32KB RAM 的微型 BLE 模组，大到拥有 512MB RAM 的智能有屏音箱，openvela 都能提供高度可扩展的支持。

  * **一站式解决方案**

随着时间的推移，openvela 不断沉淀了各类 AIoT 应用的共性需求，成为一个功能完备的软件平台，为各类物联网解决方案提供了全面的支持。厂商采用 openvela，可以显著降低研发成本并加速产品的上市时间。

  * **成熟的异构计算支持**

openvela 为异构多核系统提供了强大的支持，实现了 MCU、MPU、DSP、GPU 以及 NPU 等不同处理单元间无缝的 IPC 通信机制。此外，openvela 还提供了一个高级的 RPC 框架，简化了 openvela 与 Android 和 Linux 系统的通信，使快速打造一个异构融合操作系统成为可能。

  * **标准兼容和高可移植性**

openvela 内核基于 Apache NuttX ，这个被称为 "Tiny Linux" 的系统为 openvela 提供了高标准的 POSIX 兼容性。通过持续提升其 POSIX 兼容性，openvela 当前已达到 89% 的兼容水平。这种高标准的兼容性意味着在其他标准操作系统（例如 Linux）上开发的软件可以轻松迁移到 openvela，几乎不需要额外的工作。

  * **全面的连接套件**

openvela 提供了广泛的协议支持，包括蓝牙 BR/EDR/LE、LE Mesh、WiFi、Matter、LTE Cat1、以太网、CAN/LIN 等。同时，它还能与小米的 HyperConnect 协议无缝集成，提供了强大的连接能力。

  * **丰富的开发者工具**

openvela 提供了一系列完备的开发者工具，包括系统监控、性能分析、调试器、追踪、崩溃分析和日志分析工具，为开发者提供了强大的支持。


# 硬件支持

  * openvela 支持各种不同的架构（ARM32、ARM64、RISC-V、Xtensa、MIPS、CEVA 等）和硬件平台。请在[硬件支持](<https://nuttx.apache.org/docs/latest/platforms/index.html>)页面上查看完整列表。
  * 关于**开发板** 的适配案例，请参见[案例文档](</document?id=596&version=dev&language=cn>)。


# 最新动态

  * openvela 官方网站正式上线：openvela 现已拥有独立的官方网站，为开发者提供更加便捷的信息获取渠道，包括项目介绍、文档中心、社区动态等。欢迎访问 [openvela 官网](<https://openvela.com>)。

  * openvela 生态迎来重要里程碑：润芯微智能科技股份有限公司自主研发的 **[Gemini-S1](<https://rivotek.feishu.cn/wiki/Onndw4lmniFBnEk0Rb7cDbwOnTc>)** 开发板成为首款通过 openvela 官方兼容性认证的开发板，标志着 openvela 生态建设迈出了坚实的一步。

  * 硬件生态大幅扩展：新增对 **英飞凌 AURIX™ TC4** 、**旗芯微 (Flagchip) MCU** 以及 **QEMU-R52 SIL** 平台的适配支持。（查看 [TC4 指南](</document?id=852&version=dev&language=cn>) / [旗芯微指南](</document?id=851&version=dev&language=cn>)）

  * Ubuntu 开发体验升级：openvela VS Code 插件现已**完美支持 Ubuntu 环境** 。Linux 开发者现在也可以享受从项目创建、编译构建到系统调试的一站式流畅体验，开发效率显著提升。即刻体验：[VS Code 插件使用指南](</document?id=849&version=dev&language=cn>)。


# 版本发布管理 (Version Strategy)

我们基于 trunk 分支进行版本发布，通过标签（Tags）管理发布历史，确保生产环境的可追溯性与稳定性。

## 发布标签 (Release Tags)

发布标签是基于 trunk 分支创建的不可变标记（Immutable Marker）。每个标签代表一个正式发布的 openvela 版本。

  * **生产环境建议** ：为了确保系统的最高稳定性和安全性，我们**强烈建议** 在生产环境（Production Environment）中使用最新的发布标签，而非直接使用分支代码。


## 已发布版本列表

以下是当前已发布的稳定版本及其变更说明：

  * **trunk-5.5** ：请查阅 [v5.5 版本发布说明](<https://github.com/open-vela/docs/tree/dev//zh-cn/release_notes/v5.5.md>) 了解详细变更。

  * **trunk-5.4** ：请查阅 [v5.4 版本发布说明](<https://github.com/open-vela/docs/tree/dev//zh-cn/release_notes/v5.4.md>) 了解详细变更。

  * **trunk-5.2** ：请查阅 [v5.2 版本发布说明](<https://github.com/open-vela/docs/tree/dev//zh-cn/release_notes/v5.2.md>) 了解详细变更。


## 硬件适配特别说明 (Hardware Adaptation Guide)

为提升适配效率并确保代码稳定性，针对进行硬件移植（Porting）的开发者，我们提供以下建议：

  * **推荐基准** ：建议**优先基于 openvela 最新发布版本** （即 trunk 上的 Release Tag）进行硬件适配开发。
  * **风险提示** ：当前 **dev 分支** 处于快速迭代期，代码更新较为频繁，可能存在底层接口变动或临时性问题，**不推荐** 作为硬件适配的基准代码。
  * **获取支持** ：如有适配需求或在过程中遇到技术疑问，欢迎**提交 Issue** 或者通过**微信社区** 与我们取得联系，openvela 团队将提供必要的开发支持。


## 版本维护策略

openvela 遵循严格的版本维护生命周期：

  * **补丁更新** ：针对已发布版本中发现的关键缺陷（Critical Bugs）或安全漏洞，团队将发布新的补丁版本标签（Patch Release）进行修复。
  * **命名规则** ：补丁版本将在原版本号基础上递增，例如 trunk-5.2.1。


# 代码分支管理 (Branch Strategy)

openvela 采用双分支模型来平衡系统的创新性与稳定性。请根据您的开发需求选择合适的分支。

## dev (开发分支)

  * **定义** ：这是 openvela 的前沿开发分支，汇集了最新的功能特性与缺陷修复。
  * **状态** ：代码更新频率高，处于持续集成与快速迭代状态，可能包含尚未完全验证的特性，因此可能存在不稳定性。
  * **适用人群** ：

    * 希望抢先体验新功能的开发者。
    * 计划向社区提交代码、参与核心功能建设的贡献者。


## trunk (主干稳定分支)

  * **定义** ：这是经过全面测试的主干分支，代表了当前系统的稳定状态。
  * **状态** ：dev 分支中的功能在经过严格测试验证稳定后，会被合并至此分支。
  * **适用人群** ：大多数对系统稳定性有较高要求的用户，以及进行标准应用开发的工程师。


# 快速入门

## 设备开发

如果您想要体验 openvela，我们提供一个功能完备的模拟器，无需硬件平台即可使用。有关详细信息，请参阅如下指南。

[快速入门（Ubuntu）](</document?id=847&version=dev&language=cn>)

> **AI 辅助搭建** ：如果您使用 AI 编程助手，只需 git clone https://github.com/open-vela/.claude.git .claude，然后告诉 AI "帮我搭建 openvela 开发环境"，即可自动完成全部搭建流程。详见 [openvela AI Skills](<https://github.com/open-vela/.claude>)。

## 快应用开发

[快应用快速入门](<https://iot.mi.com/vela/quickapp/zh/guide/start/use-ide.html>)

# 子仓库列表

子仓库链接 | 描述  
---|---  
[frameworks](<https://github.com/open-vela/frameworks>) | openvela 服务框架：主要包含蓝牙、电话、图形、多媒体、应用框架、安全、系统服务框架（KVDB、OTA、healthd、binder、charger 等）。  
[vendor](<https://github.com/open-vela/vendor>) | 芯片原厂的驱动和框架。  
[nuttx](<https://github.com/open-vela/nuttx>) | 基于开源实时操作系统 NuttX 打造的内核，提供基础的内核功能，包括任务调度、跨进程通信、文件系统、TCP/IP 协议栈、设备驱动和电源管理等，同时对上提供标准的 POSIX 接口。如果您想要对 NuttX 操作系统有更深入了解，可以在 [Apache NuttX](<https://nuttx.apache.org/>) 官网查看更多信息。  
[apps](<https://github.com/open-vela/apps>) | apps 是开源实时操作系统（NuttX）的应用程序库，包含了一系列为 NuttX RTOS 设计的应用程序和实用工具。这些应用程序和工具包括 shell 命令行工具、文件系统工具、网络工具等，它们可以帮助开发者更方便地开发和调试基于 NuttX RTOS 的嵌入式系统。  
[external](<https://github.com/open-vela/external>) | openvela 引入的三方库。  
[tests](<https://github.com/open-vela/tests>) | 该仓库包含接口测试，具体包括多媒体、文件系统、内存管理和 socket 通信等核心 API 的测试。  
[docs](<https://github.com/open-vela/docs>) | openvela 对应的开发者文档。  
  
# 开发者文档

  * [文档中心](<https://doc.openvela.com/document>)
  * [API 参考文档](</document?id=1104&version=dev&language=cn>) — 内核接口、网络接口、应用框架 API 完整说明


# 应用示例中心

汇总可供开发者参考学习的原生应用与快应用示例。

## 原生应用 (Native Apps)

以下是一些典型的原生应用示例，展示了不同模块和功能的使用方法。

  * [音乐播放器](</document?id=738&version=dev&language=cn>)：演示音频播放、列表管理和后台服务。
  * [智能手环](</document?id=739&version=dev&language=cn>)：演示睡眠监测、心率监测、音乐播放、秒表计时。
  * [自行车码表](</document?id=737&version=dev&language=cn>)：演示 GPS 定位、实时数据显示和运动轨迹记录。
  * [计算器](<https://github.com/open-vela/packages_demos/blob/dev/calculator/Readme.md>)：一个基础的 UI 与逻辑交互示例。
  * [亲戚计算器](</document?id=735&version=dev&language=cn>)：演示复杂的条件逻辑与算法实现。
  * [打地鼠](</document?id=734&version=dev&language=cn>)：演示游戏循环、随机数生成和动画效果。


查看完整的原生应用列表，请访问[原生应用示例仓库](</document?id=583&version=dev&language=cn>)。

## 快应用（Quick Apps）

  * [小米手环天气预报应用](<https://github.com/open-vela/packages_fe_examples/blob/dev/weather/README.md>)：提供简洁直观的未来七日天气信息展示。
  * [音乐播放器](<https://github.com/open-vela/packages_fe_examples/blob/dev/player/README.md>)：演示一个基础的音乐播放器，包含音乐的播放，音量调节，歌单查看。
  * [日历](<https://github.com/open-vela/packages_fe_examples/blob/dev/calendar/README.md>)：演示一个基础的日历。


快应用相关示例正在持续丰富中。查看所有示例，请访问[快应用示例仓库](<https://github.com/open-vela//packages_fe_examples>)。

# 参与贡献

  * [代码贡献指南](</document?id=772&version=dev&language=cn>)
  * [文档贡献指南](</document?id=773&version=dev&language=cn>)


# 许可协议

openvela 项目由多个独立的仓库组成，其许可证策略如下：

  1. 基本原则

openvela 项目整体采用 Apache 2.0 作为主许可证，各代码库的许可证以各仓库根目录下 LICENSE 文件为准。

  2. Vendor 仓库

vendor 目录下的仓库由芯片厂商等第三方提供，它们遵循各自独立的许可证（如 MIT, BSD 等），不受 openvela 项目的 Apache 2.0 许可证约束。使用前请务必查阅并遵守其规定。

  3. 第三方依赖组件

项目代码中引用的第三方开源组件及其许可证信息，请参阅[第三方开源组件声明](</document?id=775&version=dev&language=cn>)文件。


# 社区与支持

我们欢迎您通过多种渠道与 openvela 社区互动和贡献。

## 技术讨论与贡献

  * **Issues** : 如果你有任何问题、建议或发现任何 Bug，请在 Issues 页面提交一个新的 Issue。请尽量提供详细的信息，以便我们更快地理解和解决问题。
  * **Pull Requests** : 如果你发现了问题并已经修复，欢迎提交 Pull Request。请确保遵循我们的[贡献指南](</document?id=772&version=dev&language=cn>)。
  * **Discussions** : 如果你有更广泛的话题或讨论，可以在 Discussions 页面发起一个新的讨论。


## 微信社区

欢迎加入 **openvela** 社区！扫描下方二维码关注公众号，或添加小助手入群。

官方公众号 | 技术交流群  
---|---  
![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455079947_openvela_WeChat_Official_Account.png) | ![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455080054_assistant_qr.jpg)  
**关注我们**  
获取一手资讯与深度技术文章 | **加入群聊**  
扫码添加好友

---

## 术语

> 路径: 术语
> 来源: [https://doc.openvela.com/document?id=584&language=cn&version=dev](https://doc.openvela.com/document?id=584&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/overview/glossary.md>) | 简体中文 ]

# A

  * ADB（Android Debug Bridge）


# B

  * Build artifacts

代码编译出来的文件。

  * Bssid（Basic Service Set Identifier）

通常指无线接入点（AP，Access Point）的 MAC 地址。


# C

  * CA（Client Application）

客户端应用。

  * CPC（Cross Processor Communication）

跨处理器通讯。


# F

  * FB （Frame Buffer）

帧缓冲区。

  * FS（File System）

文件系统。


# G

  * GIC（Generic Interrupt Controller）

通用中断控制器，主要在 ARM-A 系列和 ARM-R 系列处理器中使用。


# H

  * HCI（Host Controller Interface）

主机控制接口。


# I

  * IRQ（Interrupt request）

中断请求。

  * IPC（Inter-Process Communication）

进程间通信。

  * ISR（Interrupt Service Routine）

中断服务例程。


# L

  * LCDC（LCD Control）

LCD 控制信号。


# M

  * MMIO（Memory Mapped Input Output）

内存映射输入输出。

  * MTD（Memory Technology Device）

内存技术设备。

  * MCU（Microcontroller Unit）

微控制器/单片机。


# N

  * NVIC（Nested Virtual Interrupt Controller）

嵌套虚拟中断控制器，用于管理中断和异常，主要在 ARM-M 系列处理器中使用。


# O

  * OpenAMP（Open Asymmetric Multi-Processing）

开放的异构多核处理库，实现了 Remoteproc 和基于 VirtIO 的 RPMsg。

  * OPTEE（Open Portable Trusted Execution Environment）

开放可移植可信执行环境。


# P

  * PCI（Peripheral Component Interconnect）

一种外设总线互联协议，广泛应用于各类平台中。

  * PLIC（Platform-Level Interrupt Controller）

平台级中断控制器，与 GIC 类似，主要用于 RISC-V 平台的中断管理。

  * PMU （Performance Monitor Unit）

性能监控单元。


# R

  * RAM（Random Access Memory）

随机存取存储器。

  * RPMsg（Remote Processor Message）

一种用于和远端处理器进行通信的消息机制。

  * RTT（Real Time Transfer）

Segger 提供的基于内存实时传输方案。


# S

  * Screen Tearing

画面撕裂。

  * Syslog

系统日志。

  * SysView （SystemView）

SystemView 是 Segger 提供的一种实时记录和可视化工具，旨在分析和剖析嵌入式系统的行为。

  * SMP（Symmetric Multiprocessing）

对称多处理。


# T

  * TEE（Trusted Execution Environment）

可信执行环境。

  * TA（Trusted Application）

可信应用。

  * TE（Tearing Effect）

是指在显示器上显示快速移动的图像时，会出现屏幕撕裂的现象。


# V

  * VFS（Virtual File System）

虚拟文件系统。

  * VirtIO（Virtual I/O）

虚拟化 I/O。

---

