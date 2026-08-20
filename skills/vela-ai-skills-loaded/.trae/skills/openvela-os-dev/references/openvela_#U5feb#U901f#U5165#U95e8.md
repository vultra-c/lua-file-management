# 快速入门

> 来源: openvela官方
> 共 14 篇文档

---

## 快速入门（Ubuntu）

> 路径: 快速入门（Ubuntu）
> 来源: [https://doc.openvela.com/document?id=847&language=cn&version=dev](https://doc.openvela.com/document?id=847&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/quickstart/openvela_ubuntu_quick_start.md>) | 简体中文 ]

本指南将指导您在 **Ubuntu 22.04** 操作系统上完成 openvela 的开发环境准备、源代码下载、编译构建，并最终通过 Vela Emulator 运行编译产物。

> **环境要求**
> 
> 本文仅适配 **Ubuntu 22.04** 。不支持在 Windows Subsystem for Linux (WSL) 或 Docker 容器环境中进行编译。
> 
> **AI 辅助搭建（可选）**
> 
> 如果您使用 AI 编程助手（如 [Claude Code](<https://docs.anthropic.com/en/docs/claude-code>)），可以通过 openvela AI Skills 自动完成以下全部搭建流程：
>     
>     
>     > git clone https://github.com/open-vela/.claude.git .claude
>     >
> 
> 然后告诉 AI 助手："帮我搭建 openvela 开发环境"。
> 
> AI 将自动完成环境检测、依赖安装、代码源选择、源码下载、编译和模拟器启动，并在遇到问题时提供针对性的解决方案。
> 
> 如需手动搭建，请继续阅读以下步骤。

# 步骤一：准备工作

在开始之前，请确保您的开发环境满足以下要求。

## 1\. 硬件要求

  * **硬盘：** 至少 40 GB 可用空间，用于存放源代码和编译产物。
  * **内存：** 至少 16 GB RAM。


## 2\. 操作系统要求

  * **操作系统：** Ubuntu 22.04 (arm64/x86_64)


## 3\. 安装开发工具

在开始之前，您需要安装编译 openvela 所需的软件包。

打开终端，执行以下命令，更新软件包列表并安装 Git、curl、CMake、Python 3、libc++abi-dev 和 build-essential 工具链。  

    
    
    sudo apt update
    sudo apt install git curl cmake python3 libc++abi-dev build-essential

## 4\. 安装 Git LFS 组件

> **说明** ：本项目包含大体积的二进制文件（如模型权重、数据集）。请务必配置 **Git LFS** ，**否则拉取的文件将损坏（仅显示为几 KB 的指针文本）而无法运行** 。

请在 Ubuntu 终端中执行以下命令进行安装和初始化：  

    
    
    # 第一步：配置官方源并安装 (确保获取最新版)
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
    sudo apt-get install git-lfs
    
    # 第二步：初始化配置 (重要：必须执行此步，否则 LFS 不会生效)
    git lfs install

# 步骤二：下载源代码

openvela 使用 repo 工具管理其分布在多个 Git 仓库中的源代码。

## 1\. 安装 Repo 工具

repo 是一个构建于 Git 之上的代码库管理工具。执行以下命令来安全地下载并安装它。  

    
    
    curl -sSL "https://storage.googleapis.com/git-repo-downloads/repo" > repo
    chmod +x repo
    sudo mv repo /usr/local/bin

安装完成后，可运行 repo --version 进行验证。

## 2\. 初始化并同步代码库

  1. 创建一个工作目录，用于存放 openvela 的所有源代码。  

         
         mkdir openvela && cd openvela

  2. 使用 repo 初始化项目清单，并指定 dev 分支。

请根据您的网络环境和偏好，从以下任一平台选择一种方式（推荐使用 SSH）来初始化仓库。

### 选项 A：从 GitHub 下载

     * 方式一：SSH（推荐）

此方式需要您先将 SSH 公钥添加至您的 GitHub 账户，请参考 [GitHub 官方文档](<https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account>)。  

           
           repo init -u ssh://git@github.com/open-vela/manifests.git -b dev -m openvela.xml --repo-url=https://mirrors.tuna.tsinghua.edu.cn/git/git-repo/ --git-lfs

     * 方式二：HTTPS  

           
           repo init -u https://github.com/open-vela/manifests.git -b dev -m openvela.xml --repo-url=https://mirrors.tuna.tsinghua.edu.cn/git/git-repo/ --git-lfs

### 选项 B：从 Gitee 下载

     * 方式一：SSH (推荐)

此方式需要您先将 SSH 公钥添加至您的 Gitee 账户，请参考 [Gitee 官方文档](<https://gitee.com/help/articles/4191>)。  

           
           repo init -u ssh://git@gitee.com/open-vela/manifests.git -b dev -m openvela.xml --repo-url=https://mirrors.tuna.tsinghua.edu.cn/git/git-repo/ --git-lfs

     * 方式二：HTTPS  

           
           repo init -u https://gitee.com/open-vela/manifests.git -b dev -m openvela.xml --repo-url=https://mirrors.tuna.tsinghua.edu.cn/git/git-repo/ --git-lfs

### 选项 C：从 GitCode 下载

     * 方式一：SSH (推荐)

此方式需要您先将 SSH 公钥添加至您的 GitCode 账户，请参考 [GitCode 官方文档](<https://docs.gitcode.com/docs/help/home/user_center/security_management/ssh>)。  

           
           repo init -u ssh://git@gitcode.com/open-vela/manifests.git -b dev -m openvela.xml --repo-url=https://mirrors.tuna.tsinghua.edu.cn/git/git-repo/ --git-lfs

     * 方式二：HTTPS  

           
           repo init -u https://gitcode.com/open-vela/manifests.git -b dev -m openvela.xml --repo-url=https://mirrors.tuna.tsinghua.edu.cn/git/git-repo/ --git-lfs

  3. 执行同步命令，repo 将根据清单文件 (openvela.xml) 下载所有相关的源代码仓库。  

         
         repo sync -c -j8

![alt text](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455080835_004.png)

> **操作提示**
> 
>      * 首次同步耗时较长，具体时间取决于您的网络状况和磁盘性能。
>      * 若因网络问题中断，可重复执行 repo sync 进行增量同步。


# 步骤三：编译源代码

完成源代码下载后，请在 openvela 根目录下执行以下编译步骤。

## 1\. （可选）自定义内核配置

您可以通过 menuconfig 命令打开图形化界面，以调整 NuttX 内核与组件的配置。  

    
    
    ./build.sh vendor/openvela/boards/vela/configs/goldfish-arm64-v8a-ap/ --cmake menuconfig

> **操作技巧**
> 
>   * 按 / 键可搜索配置项。
>   * 按 空格键 可切换选中状态（启用/禁用/模块化）。
>   * 配置完成后，选择 **Save** 保存并退出。
> 


![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455081002_006.png)

## 2\. 执行编译

执行以下命令，构建整个项目。  

    
    
    ./build.sh vendor/openvela/boards/vela/configs/goldfish-arm64-v8a-ap/ --cmake -j$(nproc)

编译成功后，您将在 cmake_out/vela_goldfish-arm64-v8a-ap 目录下找到 nuttx 等编译产物。

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455081114_007.png)

# 步骤四：运行模拟器

在 openvela 根目录下，执行以下脚本启动 Vela Emulator 并加载您的编译产物。  

    
    
    ./emulator.sh cmake_out/vela_goldfish-arm64-v8a-ap/

模拟器启动后，您将看到 goldfish-armv8a-ap> 提示符，表明 openvela 已成功运行。

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455081344_008.png)

# 后续步骤

  * 常见问题

    * [快速入门常见问题](</document?id=590&version=dev&language=cn>)
    * [开发者常见问题解答](</document?id=861&version=dev&language=cn>)
  * 进一步阅读

    * [使用模拟器调试](</document?id=593&version=dev&language=cn>)
    * [ADB 命令](</document?id=592&version=dev&language=cn>)
    * [发送模拟器控制台命令](</document?id=594&version=dev&language=cn>)

---

## openvela VS Code 插件使用指南

> 路径: openvela VS Code 插件使用指南
> 来源: [https://doc.openvela.com/document?id=849&language=cn&version=dev](https://doc.openvela.com/document?id=849&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/quickstart/vscode_plugin_usage.md>) | 简体中文 ]

本文档指导开发者在 Ubuntu 环境下安装 openvela VS Code 插件，并完成 openvela 项目的创建、编译、调试及应用开发。

# 一、环境准备

在开始之前，请确保开发环境满足以下软硬件要求。

## 1、硬件配置

  * **硬盘** ：至少 **40 GB** 可用空间（用于存放源代码及编译产物）。
  * **内存** ：至少 **16** **GB** RAM。


## 2、操作系统

  * **系统版本** ：Ubuntu 22.04 (支持 arm64 或 x86_64 架构)。


# 二、安装 openvela 扩展插件

> **注意** ：调试功能依赖 C++ 插件，因此必须在 VS Code 中进行安装和运行。

在 VS Code(版本 >= 1.99.0)扩展市场搜索并安装 。

  * vela.vs-aiot-ide-vela

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455081948_010.png)

  * vela.vela-preview

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455082055_011.png)


# 三、配置与验证环境

插件安装完成后，需检查开发环境并安装必要的构建工具链和依赖包。

## 1、检查并安装依赖

参考下图，在 VS Code 中执行环境检查。如提示缺少组件，请按照向导提示进行安装。

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455082231_012.png)

## 2、验证环境就绪

当所有依赖安装成功后，界面将显示如下内容，表明环境准备就绪：

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455082333_013.png)

# 四、创建 openvela 项目

## 1、初始化项目目录

在文件系统中创建一个新目录（例如 openvela）。

> **警告** ：请确保该目录的**绝对路径** 中**不包含中文字符或空格等特殊符号** ，否则会导致编译系统（Build System）报错。

## 2、获取源代码

  1. 在 VS Code 中，参考下图步骤打开“创建项目”向导。

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455082445_014.png)

  2. 配置项目参数：

     * 选择源：根据网络情况选择合适的仓库源。
     * 选择分支：选择合适分支分支。

       * trunk (主干稳定分支)：经全面测试的稳定版本，dev 分支的稳定功能会合并于此。推荐大多数追求稳定性的用户使用。
       * dev (开发分支)：汇集了最新的功能与修复，可能不稳定。推荐给希望体验新功能或参与贡献的开发者。
     * 下载方式：选择 SSH 或 HTTPS。

说明：若选择 SSH 方式，请确保已在对应代码托管平台配置 SSH Key（可点击界面中的蓝色链接查看详细文档）。

  3. 选择第一步创建的项目目录 openvela，单击右上角 **Select** ，如下图所示：

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455082548_015.png)

  4. 等待项目创建完成，下载进度如下图所示： 

**注意** ：下载源码过程耗时较长，请防止电脑进入休眠状态。

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455082651_016.png)


## 3、配置编译参数

  1. 打开创建完成的 openvela 目录：

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455082758_017.png)

  2. 点击左侧 openvela **帆船** 图标，然后点击**配置 (Configure)** 按钮，如下图所示：

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455082861_018.png)

  3. 选择相应的 defconfig 文件及其它可选参数：

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455082965_019.png)


# 五、编译与运行

## 1、编译项目

  1. 点击**编译（Build）** 按钮，等待构建系统完成编译：

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455083063_020.png)

  2. 编译完成效果如下图所示：

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455083180_021.png)


## 2、运行模拟器

  1. 点击**运行 (Run)** 按钮，启动模拟器：

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455083286_022.png)

  2. 在模拟器终端输入 lvgldemo，启动 openvela 演示应用：

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455083398_023.png)

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455083762_024.png)


# 六、调试应用

  1. 单击**调试（Debug）** 按钮，系统将启动模拟器并挂载调试进程：

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455083907_025.png)

  2. 打开源代码文件 apps/system/ping/ping.c，在 main 函数处设置断点：

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455084017_026.png)

  3. 在模拟器终端执行 ping 命令。系统将运行 Ping 应用并自动命中断点，进入调试模式。

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455084124_027.png)


# 七、开发原生应用

## 1、创建应用

  1. 在插件界面点击**创建原生应用（Create Native App）：**

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455084241_028.png)

  2. 选择应用模板：

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455084355_029.png)

  3. 输入项目名称（例如 Whackmole1）：

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455084499_030.png)


## 2、编译与运行新应用

  1. 创建完成后，VS Code 会自动定位到新应用的源代码目录。

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455084607_031.png)

  2. 重新执行**编译 (Build)** -> **运行 (Run)** 。

  3. 在模拟器终端输入应用名称（如 Whackmole1）启动新应用。


# 八、资源管理与可视化预览

openvela 插件提供了强大的可视化预览功能，支持图片、字体和二进制资源，并支持模拟器文件系统挂载。

## 1、挂载数据卷

首次使用 openvela 仓库时，系统会自动弹出终端执行挂载命令，将 vela_data.bin 挂载到本地目录。

开发者可通过右键菜单手动管理挂载状态：

  * 挂载 openvela：执行挂载。

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455084707_032.png)

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455084837_033.png)

  * 重新挂载 openvela：当模拟器中文件发生变化（例如执行了 adb push）时，需执行此操作以刷新文件系统。

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455084953_034.png)

  * 卸载 openvela：断开挂载连接。


## 2、文件预览

支持普通图片、.bin、.ttf 等格式的预览（支持绝对路径与相对路径）。

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455085081_035.png)

## 3、悬浮 (Hover) 预览

**代码资源预览** ：鼠标悬停在资源路径字符串上时，将显示资源缩略图。

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455085205_036.png)

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455085326_037.png)

## 4、调试时变量预览

在调试模式下，鼠标悬停在变量上可获取当前值并进行预览。

> **操作技巧** ：按住 Alt 键可在“调试值悬浮显示”和“普通资源悬浮显示”之间切换。

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455085477_038.png)

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455085584_039.png)

## 5、配置预览基准目录

  1. 点击 VS Code 的**设置 (Settings)** 按钮（或使用快捷键 Ctrl+,）。
  2. 在左侧菜单找到 **Extensions（扩展）并选择 AIoT Image Preview** 。
  3. 设置 Base Dir 参数以适配不同环境（如 simulator 版本）。

![](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455085704_040.png)

---

## 快速入门常见问题

> 路径: 快速入门常见问题
> 来源: [https://doc.openvela.com/document?id=590&language=cn&version=dev](https://doc.openvela.com/document?id=590&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/faq/QuickStart_FAQ.md>) | 简体中文 ]

# 1、无法读取远程仓库

## 问题描述

初始化 openvela 仓库时出现以下错误：  

    
    
    repo init --partial-clone -u git@gitee.com:open-vela/manifests.git -b dev -m openvela.xml --git-lfs

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455089855_003.png)

## 原因分析

**未正确设置 SSH 公钥** ，导致无法通过 SSH 协议访问 Gitee 或 GitHub 远程仓库。

## 解决方案

参考官方文档完成 SSH 公钥的生成和配置：

  * [GitHub](<https://docs.github.com/zh/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account>)
  * [Gitee](<https://gitee.com/help/articles/4191#article-header0>)


# 2、无法访问 Google 源代码仓库

## 问题描述

运行 repo 初始化命令时，出现以下错误：  

    
    
    fatal: unable to access 'https://gerrit.googlesource.com/git-repo/': Failed to connect to gerrit.googlesource.com

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455089961_001.png)

## 问题原因

网络限制、镜像源区域限制或 DNS 解析问题导致无法访问 Google 的代码仓库。

## 解决方案

  * 永久修改 repo 源：  

        
        # 查找repo脚本路径
        which repo
        # 例如执行结果为 /usr/bin/repo
            
        # 切换清华源, /usr/bin/repo 换为实际文件路径
        sed -i 's#https://gerrit.googlesource.com/git-repo#https://mirrors.tuna.tsinghua.edu.cn/git/git-repo#' /usr/bin/repo
            
        # 或切换到中科大源(备用，如果清华源出现不稳定情况可以替换)，/usr/bin/repo 换为实际文件路径
        sed -i 's#https://gerrit.googlesource.com/git-repo#https://mirrors.ustc.edu.cn/aosp/git-repo#' /usr/bin/repo

  * 临时修改 repo 源：  

        
        # 清华源
        repo init xxxxxx  --repo-url=https://mirrors.tuna.tsinghua.edu.cn/git/git-repo
            
        # 中科大源(备用)
        repo init xxxxxx  --repo-url=https://mirrors.ustc.edu.cn/aosp/git-repo


# 3、repo sync 因网络中断失败

## 问题描述

执行 repo sync 命令时中断，出现 fatal: early EOF 错误。  
![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455090065_004.jpg)

## 问题原因

  * **SSH** 协议在网络波动时稳定性不足。
  * 大文件传输超时。


## 解决方案

切换为 **HTTPS** 协议进行下载。

  * Github：  

        
        repo init --partial-clone -u https://github.com/open-vela/manifests.git -b dev -m openvela.xml --git-lfs
            
            
        # Install Git LFS (Large File Storage) for managing large files
        sudo apt install git-lfs
        cd .repo/manifests 
        git lfs install
        git lfs --version
        cd ../../

  * Gitee：  

        
        repo init --partial-clone -u https://gitee.com/open-vela/manifests.git -b dev -m openvela.xml --git-lfs
            
            
        # Install Git LFS (Large File Storage) for managing large files
        sudo apt install git-lfs
        cd .repo/manifests 
        git lfs install
        git lfs --version
        cd ../../


# 4、内存不足导致代码拉取失败

## 问题描述

代码同步过程中终端被终止，查看 /var/log/syslog 发现 OOM 相关日志。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455090190_005.png)

## 问题原因

  * 在 Ubuntu 22.04 及以上版本中，当内存使用率超过 50% 且持续 20 秒以上，且该内存无法被回收时，systemd-oomd 进程会终止占用大量内存的进程。

  * 物理内存低于 16GB。


## 解决方案

  1. 暂时关闭 systemd-oomd 守护进程：  

         
         sudo systemctl stop systemd-oomd systemd-oomd.socket
         sudo systemctl status systemd-oomd

  2. 下载完成后重新启用守护进程：  

         
         sudo systemctl start systemd-oomd systemd-oomd.socket
         sudo systemctl status systemd-oomd


# 5、Git LFS 文件下载异常

## 问题描述

首次编译时出现大文件相关错误：

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455090301_007.jpg)

## 问题原因

该问题通常由 Git 大文件存储（Git LFS）文件未正确下载导致，可能由以下原因引起：

  1. 使用的 repo 工具版本过低（低于 v2.10）。
  2. 未正确配置 Git LFS 支持。
  3. 网络中断导致 LFS 文件下载不完整。


## 解决方案

  1. 检查 repo 版本：  

         
         repo --version

  2. 确认 repo 版本兼容性：


**版本号** | **发布日期** | **支持情况**  
---|---|---  
v2.4 | 2021-01 | 实验性支持，部分功能不稳定。  
v2.10 | 2022-03 | 正式支持。  
v2.22 | 2023-至今 | 默认启用，功能稳定。  
  
  3. 版本过低时更新 repo：

如果版本低于 v2.22，请重新安装 repo。


# 6、Qt 平台插件初始化失败

## 问题描述

运行模拟器时出现以下错误：  

    
    
    ./emulator.sh vela

错误提示：  

    
    
    No Qt platform plugin could be initialized

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455090427_002.jpg)

## 问题原因

源代码路径中包含中文字符，导致工具无法正确解析路径。

## 解决方案

将源码移动到不包含中文字符的目录路径中。

# 7、如何使用 build.sh 编译 NuttX 支持的开发板

以 qemu-armv7a:nsh 为例，提供两种编译方式：

  * 使用 build.sh 脚本进行编译：  

        
        # 使用改进的 build.sh 脚本
        ./build.sh qemu-armv7a:nsh -j12

  * 使用 configure.sh 脚本进行编译：  

        
        # 使用 NuttX 自带的配置脚本
        ./tools/configure.sh -l qemu-armv7a:nsh
        make -j12


build.sh 脚本对编译流程进行了优化，操作更简便，建议优先使用。

---

## ADB 命令

> 路径: 模拟器 > ADB 命令
> 来源: [https://doc.openvela.com/document?id=592&language=cn&version=dev](https://doc.openvela.com/document?id=592&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/quickstart/emulator/Android_Debug_Bridge_commands.md>) | 简体中文 ]

ADB 是一个功能丰富的命令行工具，用于与设备进行通信。adb 通过访问设备的 Unix shell 来在设备上运行各种命令。作为一种客户端-服务器程序，包括以下三个组件：

  * 客户端：用于发送命令，客户端在开发工作站上运行，可以通过发送 adb 命令从命令行终端调用客户端。

  * 守护程序 (adbd)：用于在设备上运行命令，守护程序在每个设备上作为后台进程运行。

  * 服务器：用于管理客户端与守护程序之间的通信，服务器在开发工作站上作为后台进程运行。


# 一、ADB 的工作原理

所有 adb 客户端均使用端口 5037 与 adb 服务器通信。当启动某个 adb 客户端时，该客户端会先检查是否有 adb 服务器进程已在运行。如果没有，它会启动服务器进程。服务器在启动后会与本地 TCP 端口 5037 绑定，并监听 adb 客户端发出的命令。

随后服务器会与所有正在运行的设备建立连接。通过扫描 5555 到 5585 之间（该范围用于前 16 个模拟器）的奇数号端口查找模拟器。服务器一旦发现 adb 守护程序 (adbd)，便会与相应的端口建立连接。

每个模拟器都使用一对按顺序排列的端口：一个用于控制台连接的偶数号端口，另一个用于 adb 连接的奇数号端口。例如：

模拟器 1，控制台：5554；模拟器 1，adb：5555。

模拟器 2，控制台：5556；模拟器 2，adb：5557。

依此类推，在端口 5555 处与 adb 连接的模拟器与控制台监听端口为 5554 的模拟器是同一个。

服务器与所有设备均建立连接后，便可以使用 adb 命令访问这些设备。由于服务器管理与设备的连接，并处理来自多个 adb 客户端的命令，因此可以从任意客户端或从某个脚本控制任意设备。

# 二、查询设备

发送 adb 命令前，需要了解哪些设备实例已连接到 adb 服务器，可使用如下命令查询已连接设备的列表：  

    
    
    adb devices

adb 会为每个设备输出以下状态信息：

  * 序列号：adb 会创建一个字符串，用于通过端口号唯一标识设备。例如：emulator-5554
  * 状态：设备的连接状态可以是以下几项之一：

    * offline：设备未连接到 adb 或没有响应。

    * device：设备已连接到 adb 服务器，但是此状态并不表示 Guest 系统已完全启动并可正常运行，有可能在设备连接到 adb 时系统仍在启动。系统完成启动后，设备通常处于此运行状态。

    * no device：未连接任何设备。


## 1、未列出模拟器的情形

adb devices 命令的极端命令序列会导致正在运行的模拟器不显示在 adb devices 输出中（即使在桌面上可以看到该模拟器）。当满足以下所有条件时，就会发生这种情况：

  * adb 服务器未在运行。

  * 在使用 emulator 命令时，将 -port 或 -ports 选项的端口值设为 5554 到 5584 之间的奇数。

  * 选择的奇数号端口处于空闲状态，因此可以与指定端口号的端口建立连接；或者该端口处于忙碌状态，模拟器切换到了符合第 2 条要求的另一个端口。

  * 启动模拟器后才启动 adb 服务器。


# 三、向指定设备发送命令

adb 要指定目标，请按以下步骤操作：

  1. 使用 devices 命令获取目标设备的序列号。

  2. 获得序列号后，使用 -s 选项与 adb 命令来指定序列号。


## 1、设置端口转发

可以使用 forward 命令设置任意用于转发的端口，将特定主机端口上的请求转发到设备上的其他端口。以下示例设置了主机 6100 端口到设备 7100 端口的转发：  

    
    
    adb forward tcp:6100 tcp:7100

以下示例设置了主机 6100 端口到 local:logd 的转发：  

    
    
    adb forward tcp:6100 local:logd

如果尝试确定发送到设备上指定端口的内容，上述做法可能会非常有用。系统会将收到的所有数据写入系统日志记录守护程序，并显示在设备日志中。

## 2、向设备推送或获取文件

可以使用 pull 和 push 命令将文件复制到设备或从设备复制文件。

如需从设备中复制某个文件或目录（及其子目录），使用以下命令：  

    
    
    adb pull remote local

如需将某个文件或目录（及其子目录）复制到设备，使用以下命令：  

    
    
    adb push local remote

将 local 和 remote 替换为开发工作站（本地）和设备（远程）上的目标文件/目录的路径，使用如下命令：  

    
    
    adb push myfile.txt /sdcard/myfile.txt

## 3、停止 adb 服务器

在某些情况下，可能需要先终止 adb 服务器进程，然后重启才能解决问题，例如发生 adb 不响应命令的这种情况。

如需停止 adb 服务器，使用 adb kill-server 命令，然后通过发出任意 adb 命令来重启服务器。

## 4、发送 adb 命令

可以通过开发工作站上的命令行或通过脚本发送 adb 命令，例如：  

    
    
    adb [-d | -e | -s serial_number] command

如果只有一个模拟器在运行或者只连接了一个设备，系统会默认将 adb 命令发送至该设备。如果有多个模拟器正在运行并且/或者连接了多个设备，需要使用 -d、-e 或 -s 选项指定应向其发送命令的目标设备。

可以使用以下命令来查看所有受支持 adb 命令的详细列表：  

    
    
    adb --help

# 四、发送 shell 命令

可以使用 shell 命令通过 adb 发出设备命令，也可以使用该命令启动交互式 shell。如需发出单个命令，请使用如下所示的 shell 命令：  

    
    
    adb [-d |-e | -s serial_number] shell shell_command

要在设备上启动交互式 shell，请使用如下所示的 shell 命令：  

    
    
    adb [-d | -e | -s serial_number] shell

如需退出交互式 shell，请按 Control+D 或输入 exit。

---

## 使用模拟器调试

> 路径: 模拟器 > 使用模拟器调试
> 来源: [https://doc.openvela.com/document?id=593&language=cn&version=dev](https://doc.openvela.com/document?id=593&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/quickstart/emulator/Debugging_Vela_with_Vela_Emulator.md>) | 简体中文 ]

# 一、使用 GDB Console

使用下列命令，在 Ubuntu 22.04 版本的系统上安装所需的软件包：  

    
    
    sudo apt update
    sudo apt install gdb-multiarch

模拟器支持通过 GDB 远程连接工具（gdbstub）使用 GDB。可以像在真实硬件上使用 JTAG 等低级调试工具一样，调试 openvela 代码。可以停止和启动虚拟机，检查寄存器和内存等状态，并设置断点和观察点。

通过传递 -s 和 -S 选项启动模拟器来使用 GDB。 -s 选项将使模拟器在 TCP 端口 1234 上侦听来自 GDB 的传入连接，而 -S 将使模拟器从 GDB 获取通知前，不会启动 guest 虚拟机。

要启用与 GDB Server 的连接，您需要将 -qemu -S -s 参数传递给 emulator.sh。  

    
    
    ./emulator.sh vela -qemu -S -s

打开新的终端，运行 gdb-multiarch：  

    
    
    gdb-multiarch nuttx/nuttx

  

    
    
    GNU gdb (Ubuntu 12.1-0ubuntu1~22.04.2) 12.1
    Copyright (C) 2022 Free Software Foundation, Inc.
    License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
    This is free software: you are free to change and redistribute it.
    There is NO WARRANTY, to the extent permitted by law.
    Type "show copying" and "show warranty" for details.
    This GDB was configured as "x86_64-linux-gnu".
    Type "show configuration" for configuration details.
    For bug reporting instructions, please see:
    <https://www.gnu.org/software/gdb/bugs/>.
    Find the GDB manual and other documentation resources online at:
        <http://www.gnu.org/software/gdb/documentation/>.
    
    For help, type "help".
    Type "apropos word" to search for commands related to "word"...
    Reading symbols from nuttx/nuttx...

需要创建一个远程连接，用与主机 GDB 连接到模拟器的 GDB Server。

连接后，可以在模拟环境中像调试其他应用程序一样进行调试。  

    
    
    (gdb) target remote localhost:1234

  

    
    
    Remote debugging using localhost:1234
    __start () at armv7-a/arm_head.S:207
    207		cpsid		if, #PSR_MODE_SYS

设置一个断点：  

    
    
    (gdb) b nx_start

  

    
    
    Breakpoint 1 at 0x601cdc: file init/nx_start.c, line 317.

继续执行：  

    
    
    (gdb) c

  

    
    
    Continuing.
    
    Breakpoint 1, nx_start () at init/nx_start.c:317
    317	{

显示源代码：  

    
    
    (gdb) l

  

    
    
    312	 *   Does not return.
    313	 *
    314	 ****************************************************************************/
    315	
    316	void nx_start(void)
    317	{
    318	  int i;
    319	
    320	  sinfo("Entry\n");
    321

显示当前 GDB 会话的所有断点信息：  

    
    
    (gdb) info break

  

    
    
    Num     Type           Disp Enb Address    What
    1       breakpoint     keep y   0x00601cdc in nx_start at init/nx_start.c:317
    	breakpoint already hit 1 time

启用或禁用断点：  

    
    
    disable <breakpoint-number>
    enable <breakpoint-number>

删除断点：  

    
    
    d <breakpoint-number>

退出 GDB：  

    
    
    (gdb) q

# 二、使用 Visual Studio Code

  1. 单击[此处](<https://code.visualstudio.com/>)下载安装 Visual Studio Code。

  2. 安装 Visual Studio Code 扩展。  

         
         code --install-extension ms-vscode.cpptools-extension-pack

  3. 打开 openvela 工作区。

可以通过 File > Open Folder... 菜单，选择 openvela 所在的文件夹的方式，打开工作区。

或者，如果使用终端启动 Visual Studio Code，可以将 openvela 源码所在的路径，作为第一个参数，传递给 code 命令。

例如，使用下列命令，可以打开当前目录，作为 Visual Studio Code 的工作区。  

         
         code .

  4. 添加启动配置。

在 Visual Studio Code 中调试或运行 openvela 源码，在调试视图上选择 Run and Debug，或者按 F5 键，Visual Studio Code 会运行当前的活动文件。

在大多数调试场景中，创建启动配置文件是非常有用的。它可以配置和保存调试的详细设置。你可以将这些配置信息保存在工作区（项目根文件夹）的 .vscode 文件夹中的 launch.json 文件中，或直接保存在用户设置或工作区设置中。

要创建 launch.json 文件，请在运行启动视图中选择 create a launch.json file。

以下是用于调试 openvela 的启动配置：  

         
         {
             // Use IntelliSense to learn about possible attributes.
             // Hover to view descriptions of existing attributes.
             // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
             "version": "0.2.0",
             "configurations": [
                 {
                     "name": "Debug openvela",
                     "type": "cppdbg",
                     "request": "launch",
                     "program": "${workspaceFolder}/nuttx/nuttx",
                     "cwd": "${workspaceFolder}",
                     "MIMode": "gdb",
                     "miDebuggerPath": "/usr/bin/gdb-multiarch",
                     "miDebuggerServerAddress": "localhost:1234"
                 }
             ]
         }

返回文件资源管理器视图 (Ctrl+Shift+E)，可以看到 Visual Studio Code 已经创建一个“.vscode”文件夹并将“launch.json”文件添加到工作区。

  5. 通过传递 -s 和 -S 选项启动模拟器来使用 GDB。  

         
         ./emulator.sh vela -qemu -S -s

  6. 开始调试会话。

为了启动调试会话，首先使用 Run and Debug 视图中的 Configuration 下拉列表，选择 Debug openvela 的配置。设置启动配置后，使用 F5 启动调试会话。


# 三、使用 Clion (远程调试)

  1. 下载并且安装 [Clion (建议使用较新版本)](<https://www.jetbrains.com/clion/>)。

  2. 打开 SSH Configurations 菜单。

可以在 Welcome 页面 Customize | All Settings 打开菜单，如果已经打开工程 可以点击 File | Close Project 返回 Welcome 页面。

点击 + 符号，填写好相应信息后测试连接成功后保存，例如：

![003.png](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455091350_003.png)

  3. 配置并选择远程工程。

在 Welcome 页面选择 Remote Development | SSH | New Project，选择刚才创建的 SSH 连接，点击右下角 Check Connection and Continute，选择一个 IDE 版本，然后项目路径选择克隆下来的 vela 工程路径根目录后点击 Start IDE and Connect。例如：

![004.png](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455091464_004.png)

等待下载完成后点击确定 Authenticate：

![005.png](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455091568_005.png)

  4. 创建调试配置。

点击 Add Configuration | Remote GDB Server 并且配置实例如下：

![006.png](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455091688_006.png)

Target 创建样例如下：

![007.png](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455091820_007.png)

  5. 通过传递 -s 和 -S 选项启动模拟器来使用 GDB。  

         
         ./emulator.sh vela -qemu -S -s

  6. 开始调试会话。

点击 debug 按钮即可进行调试：

![008.png](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455091918_008.png)

如果弹出认证对话框 输入密码或者选择配置的 ssh key 即可：

![009.png](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455092040_009.png)

![010.png](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455092134_010.png)

---

## 发送模拟器控制台命令

> 路径: 模拟器 > 发送模拟器控制台命令
> 来源: [https://doc.openvela.com/document?id=594&language=cn&version=dev](https://doc.openvela.com/document?id=594&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/quickstart/emulator/Send_emulator_console_commands.md>) | 简体中文 ]

每个正在运行的虚拟设备都提供了一个控制台，可用来查询和控制模拟设备的环境。

# 一、启动和停止控制台会话

如需访问控制台并输入命令，请从终端窗口中使用 telnet 连接到控制台端口，并提供身份验证令牌。每当控制台显示 OK 时，表明已可以开始接受命令。通常不会显示常见的命令提示符。

要连接到正在运行的虚拟设备的控制台，请执行以下操作：

  1. 打开终端窗口并输入以下命令：  

         
         telnet localhost console-port

模拟器会监听端口 5554 到 5585 上的连接，并且仅接受来自 localhost 的连接。

adb devices 命令也会输出正在运行的虚拟设备及其控制台端口号的列表。

  2. 控制台显示 OK 后，输入 auth auth_token 命令。

在输入控制台命令之前，模拟器控制台会进行身份验证。auth_token 必须与 HOME 目录中 .emulator_console_auth_token 文件的内容相符。

如果该文件不存在，则 telnet localhost console-port 命令会创建该文件，其中包含一个随机生成的身份验证令牌。如需停用身份验证，请从 .emulator_console_auth_token 文件中删除令牌，或者创建一个空文件（如果该文件不存在）。

  3. 连接到控制台后，输入控制台命令。

输入 help、help command 或 help-verbose 可查看控制台命令的列表并了解特定的命令。

  4. 如要退出控制台会话，请输入 quit 或 exit。

下面是一个会话示例：  

         
         $ telnet localhost 5554
         Trying ::1...
         telnet: connect to address ::1: Connection refused
         Trying 127.0.0.1...
         Connected to localhost.
         Escape character is '^]'.
         Android Console: Authentication required
         Android Console: type 'auth <auth_token>' to authenticate
         Android Console: you can find your <auth_token> in
         '/Users/me/.emulator_console_auth_token'
         OK
         auth 123456789ABCdefZ
         Android Console: type 'help' for a list of commands
         OK
         help-verbose
         Android console command help:
             help|h|?         Prints a list of commands
             help-verbose     Prints a list of commands with descriptions
             ping             Checks if the emulator is alive
             automation       Manages emulator automation
             event            Simulates hardware events
             geo              Geo-location commands
             gsm              GSM related commands
             cdma             CDMA related commands
             crash            Crashes the emulator instance
             crash-on-exit    Simulates crash on exit for the emulator instance
             kill             Terminates the emulator instance
             restart          Restarts the emulator instance
             network          Manages network settings
             power            Power related commands
             quit|exit        Quits control session
             redir            Manages port redirections
             sms              SMS related commands
             avd              Controls virtual device execution
             qemu             QEMU-specific commands
             sensor           Manages emulator sensors
             physics          Manages physical model
             finger           Manages emulator finger print
             debug            Controls the emulator debug output tags
             rotate           Rotates the screen clockwise by 90 degrees
             screenrecord     Records the emulator's display
             fold             Folds the device
             unfold           Unfolds the device
             multidisplay     Configures the multi-display
             nodraw           turn on/off NoDraw mode. (experimental)
             resize-display   resize the display resolution to the preset size
             virtualscene-image  customize virtualscene image for virtulscene camera
             proxy            manage network proxy server settings
             phonenumber      set phone number for the device
         
         
         try 'help <command>' for command-specific help
         OK
         exit
         Connection closed by foreign host.


# 二、模拟器命令参考

## 1、常规命令

  * avd {stop|start|status|name}

查询、控制和管理虚拟设备，具体说明如下：

    * stop：停止设备的执行。
    * start：开始设备的执行。
    * status：查询虚拟设备状态，可以是 running 或 stopped。
    * name：查询虚拟设备名称。
  * kill

终止虚拟设备。

  * ping

检查虚拟设备是否正在运行。

  * rotate

以 45 度的增量逆时针旋转 AVD。


## 2、端口重定向

  * redir list

列出当前端口重定向。

  * redir add protocol:host-port:guest-port

添加新的端口重定向，具体说明如下：

    * protocol：必须是 tcp 或 udp。

    * host-port：要在主机上打开的端口号。

    * guest-port：要在模拟器上将数据传输到的端口号。

  * redir del protocol:host-port

删除端口重定向。

    * protocol：必须是 tcp 或 udp。

    * host-port：要在主机上打开的端口号。


## 3、地理位置

通过向模拟器发送 GPS 定位，设置向模拟器内运行的应用报告的地理位置。

  * geo fix longitude latitude [altitude] [satellites] [velocity]

向模拟器发送简单的 GPS 定位。 以十进制度为单位指定 longitude 和 latitude。使用 1 到 12 之间的数字指定用于确定位置的 satellites 数量，并以米为单位指定 altitude，以节为单位指定 velocity。

  * geo nmea sentence

向模拟设备发送 NMEA 0183 语句，就像是从模拟的 GPS 调制解调器发送的一样。让 sentence 以 “\$GP” 开头。 目前仅支持“$GPGGA” 和 “$GPRCM” 语句。以下示例是一个 GPGGA（全球定位系统定位数据）语句，它描述了 GPS 接收器接收的时间、位置和定位数据：  

        
        geo nmea $GPGGA ,hhmmss.ss,llll.ll,a,yyyyy.yy,a,x,xx,x.x,x.x,M,x.x,M,x.x,xxxx


## 4、虚假硬件事件

  * event types

列出所有虚假事件类型。对于包含代码的事件，代码数列在右侧的圆括号中。  

        
        event types
        event <type> can be an integer or one of the following aliases:
            EV_SYN
            EV_KEY    (405 code aliases)
            EV_REL    (2 code aliases)
            EV_ABS    (27 code aliases)
            EV_MSC
            EV_SW     (4 code aliases)
            EV_LED
            EV_SND
            EV_REP
            EV_FF
            EV_PWR
            EV_FF_STATUS
            EV_MAX
        OK

  * event send types [types ...]

发送一个或多个虚假事件类型。

  * event codes type

列出指定虚假事件类型的事件代码。

  * event send type[:code]:[value] [...]

发送一个或多个虚假事件以及可选的代码和代码值。

如需了解到底要发送哪个事件，可以在手动按模拟器上按钮的同时使用 adb 命令。

  * event text message

发送用于模拟按键的字符串。该消息必须是 UTF-8 字符串。 Unicode 消息会根据当前设备键盘进行反向映射，不受支持的字符会被静默舍弃。


## 5、电源状态控制

  * power display

显示电池和充电器状态。

  * power ac {on|off}

将交流电充电状态设为 on 或 off。

  * power status {unknown|charging|discharging|not-charging|full}

按照说明更改电池状态。

  * power present {true|false}

设置电池存在状态。

  * power health {unknown|good|overheat|dead|overvoltage|failure}

设置电池运行状况。

  * power capacity percent

将电池剩余电量状态设为 0 到 100 之间的百分比。


## 6、在模拟器上管理传感器

这些命令与 AVD 中可用的传感器有关。除了使用 sensor 命令之外，还可以在模拟器的 Virtual sensors 屏幕上的 Accelerometer 和 Additional sensors 标签页中查看和调整相关设置。

  * sensor status

列出所有传感器及其状态。下面是 sensor status 命令的输出示例：  

        
        sensor status
        acceleration: enabled.
        gyroscope: enabled.
        magnetic-field: enabled.
        orientation: enabled.
        temperature: enabled.
        proximity: enabled.
        light: enabled.
        pressure: enabled.
        humidity: enabled.
        magnetic-field-uncalibrated: enabled.
        gyroscope-uncalibrated: enabled.
        hinge-angle0: disabled.
        hinge-angle1: disabled.
        hinge-angle2: disabled.
        heart-rate: disabled.
        rgbc-light: disabled.
        wrist-tilt: disabled.
        acceleration-uncalibrated: enabled.

  * sensor get sensor-name

获取 sensor-name 的设置。以下示例会获取加速度传感器的值：  

        
        sensor get acceleration
        acceleration = 2.23517e-07:9.77631:0.812348

以英文冒号 (:) 分隔的 acceleration 值是指虚拟传感器的 x、y 和 z 坐标。

  * sensor set sensor-name value-x:value-y:value-z

设置 sensor-name 的值。以下示例将加速度传感器设为以英文冒号分隔的 x、y 和 z 值。  

        
        sensor set acceleration 2.23517e-07:9.77631:0.812348

---

## Sim 环境音频功能开发指南

> 路径: 模拟器 > Sim 环境音频功能开发指南
> 来源: [https://doc.openvela.com/document?id=850&language=cn&version=dev](https://doc.openvela.com/document?id=850&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/quickstart/emulator/sim_audio_guide.md>) | 简体中文 ]

# 一、 简介

本文档旨在指导开发者在 openvela Sim（模拟器）环境中进行音频功能的开发与测试。通过 Sim 环境，开发者可以利用 host 主机的音频能力模拟嵌入式设备的音频输入输出，验证驱动逻辑与中间件功能。

主要测试范围包括：

  1. 使用 nxplayer、nxrecorder、nxlooper 验证 **Audio** **Driver** 的基础功能。
  2. 使用 mediatool 验证 **Media Framework** 的业务逻辑。


# 二、 模块架构

Sim 环境下的音频子系统由以下核心模块构成：

  1. **Audio Driver**

     * 在 Sim 环境下，底层驱动通过映射 Host 主机（Linux）的 ALSA 接口来模拟音频硬件的输入与输出。
  2. **命令行工具集 (CLI Tools)**

     * **nxplayer** ：音频播放测试工具。
     * **nxrecorder** ：音频录制测试工具。
     * **nxlooper** ：音频回环（Loopback）测试工具。
     * 以上工具均基于 Audio Driver 实现。
  3. **Media Framework**

     * 包含 Media Framework、RPC 通信、Audio Policy（音频策略）等组件。
     * 对外提供播放、录音、音频通路切换及音量控制等标准接口。
  4. **mediatool**

     * 基于 Media Framework 实现的命令行交互程序，用于测试框架层功能。


# 三、 编译配置

请在 openvela 的构建系统（Kconfig）中进行如下配置。

## 1、Audio Driver 配置

启用基础音频驱动支持及缓冲区配置：  

    
    
    CONFIG_AUDIO=y                          # 启用 AUDIO 子系统
    CONFIG_AUDIO_NUM_BUFFERS=2              # 驱动缓冲区数量
    CONFIG_AUDIO_BUFFER_NUMBYTES=8192       # 单个缓冲区大小 (Bytes)

## 2、命令行工具配置

启用 nxplayer、nxrecorder 和 nxlooper 工具：  

    
    
    CONFIG_SYSTEM_NXPLAYER=y
    CONFIG_SYSTEM_NXRECORDER=y
    CONFIG_SYSTEM_NXLOOPER=y              
    
    # 其他相关配置保持默认即可

## 3、Media Framework 配置

Media Framework 支持跨核操作。在 Sim 环境中，通常涉及 AP（应用处理器）与 Audio DSP（数字信号处理器）的模拟。

### AP 侧配置

将 Media Framework 主体编译在 AP 核时的配置：  

    
    
    CONFIG_MEDIA=y  
    CONFIG_MEDIA_SERVER=y
    CONFIG_MEDIA_SERVER_CONFIG_PATH="/etc/media/"
    CONFIG_MEDIA_SERVER_PROGNAME="mediad"
    CONFIG_MEDIA_SERVER_STACKSIZE=2097152
    CONFIG_MEDIA_SERVER_PRIORITY=245
    CONFIG_MEDIA_TOOL=y
    CONFIG_MEDIA_TOOL_STACKSIZE=16384    
    CONFIG_MEDIA_TOOL_PRIORITY=100
    CONFIG_MEDIA_CLIENT_LISTEN_STACKSIZE=4096
     
    CONFIG_PFW=y
    CONFIG_LIB_XML2=y
    CONFIG_HAVE_CXX=y
    CONFIG_HAVE_CXXINITIALIZE=y
    CONFIG_LIBCXX=y
    CONFIG_LIBSUPCXX=y

### AUDIO 侧配置

将 Media Framework 主体编译在 Audio 核时的配置（包含 FFmpeg 支持）：  

    
    
    CONFIG_MEDIA=y
    CONFIG_MEDIA_SERVER=y
    
    # CONFIG_MEDIA_FOCUS is not set
    CONFIG_MEDIA_SERVER_CONFIG_PATH="/etc/media/"
    CONFIG_MEDIA_SERVER_PROGNAME="mediad"
    CONFIG_MEDIA_SERVER_STACKSIZE=81920
    CONFIG_MEDIA_SERVER_PRIORITY=245
    CONFIG_MEDIA_TOOL=y
    CONFIG_MEDIA_TOOL_STACKSIZE=16384
    CONFIG_MEDIA_TOOL_PRIORITY=100
    CONFIG_MEDIA_CLIENT_LISTEN_STACKSIZE=4096
    
    # Audio Policy
    CONFIG_PFW=y                       
    CONFIG_LIB_XML2=y                 
    CONFIG_HAVE_CXX=y
    CONFIG_HAVE_CXXINITIALIZE=y
    CONFIG_LIBCXX=y
    CONFIG_LIBSUPCXX=y
    CONFIG_KVDB
    
    # FFmpeg 核心配置
    CONFIG_LIB_FFMPEG=y 
    CONFIG_LIB_FFMPEG_CONFIGURATION="--disable-sse --enable-avcodec --enable-avdevice --enable-avfilter --enable-avformat --enable-decoder='aac,aac_latm,flac,mp3,pcm_s16le,libopus,libfluoride_sbc,libfluoride_sbc_packed,silk' --enable-demuxer='aac,mp3,pcm_s16le,flac,mov,ogg,wav,silk' --enable-encoder='aac,pcm_s16le,libopus,libfluoride_sbc,silk' --enable-hardcoded-tables --enable-indev=nuttx --enable-ffmpeg --enable-ffprobe --enable-filter='adevsrc,adevsink,afade,amix,amovie_async,amoviesink_async,astats,astreamselect,aresample,volume' --enable-libopus --enable-muxer='opus,opusraw,pcm_s16le,silk,wav' --enable-outdev=bluelet,nuttx --enable-parser='aac,flac' --enable-protocol='cache,concat,file,http,https,rpmsg,tcp,unix' --enable-swresample --tmpdir='/stream'"

# 四、FFmpeg 扩展配置

Media Framework 基于 FFmpeg 实现。开发者需根据项目需求配置 FFmpeg 组件（demuxer, muxer, decoder, encoder, filter 等）。

## 1、基础配置字符串

核心配置字符串参考如下（需写入 .config 或相关构建文件）：  

    
    
    CONFIG_LIB_FFMPEG_CONFIGURATION="--disable-sse --enable-avcodec --enable-avdevice --enable-avfilter --enable-avformat --enable-decoder='aac,aac_latm,flac,mp3,pcm_s16le,libopus,libfluoride_sbc,libfluoride_sbc_packed,silk' --enable-demuxer='aac,mp3,pcm_s16le,flac,mov,ogg,wav,silk' --enable-encoder='aac,pcm_s16le,libopus,libfluoride_sbc,silk' --enable-hardcoded-tables --enable-indev=nuttx --enable-ffmpeg --enable-ffprobe --enable-filter='adevsrc,adevsink,afade,amix,amovie_async,amoviesink_async,astats,astreamselect,aresample,volume' --enable-libopus --enable-muxer='opus,opusraw,pcm_s16le,silk,wav' --enable-outdev=bluelet,nuttx --enable-parser='aac,flac' --enable-protocol='cache,concat,file,http,https,rpmsg,tcp,unix' --enable-swresample --tmpdir='/stream'"

**配置说明：**

  * \--enable-decoder: 启用指定的解码器。
  * \--enable-filter: 启用指定的过滤器。


**故障排查：**

如果遇到类似 Failed to avformat_open_input ret -1330794744, Protocol not found. 的错误，通常意味着缺少相应的协议或格式支持，请检查并修改上述配置字符串以扩展 FFmpeg 能力。

## 2、依赖库配置

部分 FFmpeg 解码器依赖第三方解码库，必须在 Kconfig 中显式启用这些依赖项：  

    
    
    # libhelix_aac 依赖
    CONFIG_LIB_HELIX_AAC=y
    CONFIG_LIB_HELIX_AAC_SBR=y
    
    # libfluoride_sbc,libfluoride_sbc_packed 依赖
    CONFIG_LIB_FLUORIDE_SBC=y
    CONFIG_LIB_FLUORIDE_SBC_DECODER=y
    CONFIG_LIB_FLUORIDE_SBC_ENCODER=y
    
    # libopus 依赖
    CONFIG_LIB_OPUS=y
    
    #silk 依赖
    CONFIG_LIB_SILK=y

# 五、调试工具使用指南

本节介绍如何在 Sim 环境中运行并测试音频工具。

## 1、环境启动

  1. **运行模拟器**

进入 nuttx 目录并启动 GDB 进行调试运行：  

         
         cd nuttx
         sudo gdb --args ./nuttx

  2. **挂载 Host 文件系统**

在 NuttX Shell 中（nsh），将 Host 主机的音频流目录挂载到 Sim 环境的 /stream 目录：  

         
         # 替换 <username> 为实际用户名
         mount -t hostfs -o fs=/home/<username>/Streams/ /stream


## 2、nxplayer 使用说明

nxplayer 用于测试音频播放功能。

### 场景 A：播放 PCM 原始数据

**测试用例** ：播放 /stream/8000.pcm（单声道，16bits，44100Hz）。  

    
    
    nxplayer
    
    # 指定播放设备
    device pcm0p
    
    # 格式: playraw <path> <channels> <width> <rate>
    playraw /stream/8000.pcm 1 16 44100

### 场景 B：播放 MP3 文件 (模拟 Offload)

**Host 依赖** ： 模拟 MP3 解码需要 Host 主机安装 libmad 库  

    
    
    sudo apt install libmad0-dev:i386

**测试用例** ：   

    
    
    nxplayer 
    # 指定 Offload 播放设备
    device pcm1p
    # 播放文件
    play /stream/1.mp3help
    
    # 停止播放
    stop

**功能限制** ：

  * 支持带 ID3V2 header 的文件。
  * 支持不带任何 ID3 header 的文件。
  * **暂不支持** ID3V1 格式。


## 3、nxrecorder 使用说明

nxrecorder 用于测试音频录制功能。

### 场景 A：录制 PCM 原始数据

**测试用例** ：录制双声道、16bits、48000Hz 的音频到 1.pcm。   

    
    
    nxrecorder
    # 指定录音设备
    device pcm0c
    # 格式: recordraw <path> <channels> <width> <rate>
    recordraw /stream/1.pcm 2 16 48000
    
    # 停止录音
    stop

验证方法：检查 Host 主机对应目录下是否生成 1.pcm 且能正常播放。

### 场景 B：录制 MP3 文件 (模拟 Offload)

**Host 依赖** ： 模拟 MP3 编码需要 Host 主机安装 libmp3lame 库：  

    
    
    sudo apt-get install libmp3lame-dev:i386

**测试用例** ：  

    
    
    nxrecorder
    
    # 指定 Offload 录音设备
    device pcm1c
    
    # 录制 MP3
    record /stream/100.mp3 2 16 44100

## 4、nxlooper 使用说明

nxlooper 用于测试音频回环（Loopback），即录音数据直接送入播放通道。

### 场景 A：PCM 数据回环
    
    
    nxlooper
    # 指定播放设备
    device pcm0p
    # 指定录音设备
    device pcm0c
    # 启动回环: 2通道 16bit 48kHz
    loopback 2 16 48000
    
    # 停止回环
    stop

### 场景 B：MP3 数据回环
    
    
    nxlooper
    device pcm1p
    device pcm1c
    # 最后一个参数 '8' 代表格式代码 (AUDIO_FMT_MP3)
    loopback 2 16 44100 8
    
    # 停止回环
    stop

**参数说明** ： loopback 命令格式为：loopback <channels> <width> <rate> [format]

其中 [format] 参数对应 audio.h 中的定义（默认为 PCM）：  

    
    
    /* 位于 ./nuttx/include/nuttx/audio/audio.h */
    #define AUDIO_FMT_UNDEF             0x00
    #define AUDIO_FMT_OTHER             0x01
    #define AUDIO_FMT_MPEG              0x02
    #define AUDIO_FMT_AC3               0x03
    #define AUDIO_FMT_WMA               0x04
    #define AUDIO_FMT_DTS               0x05
    #define AUDIO_FMT_PCM               0x06
    #define AUDIO_FMT_WAV               0x07
    #define AUDIO_FMT_MP3               0x08
    #define AUDIO_FMT_MIDI              0x09
    #define AUDIO_FMT_OGG_VORBIS        0x0a
    #define AUDIO_FMT_FLAC              0x0b

# 六, mediatool 使用说明

关于 mediatool 的详细命令与使用方法，请参考 [Mediatool 介绍](</document?id=705&version=dev&language=cn>)。

---

## openvela 开发板支持列表

> 路径: 开发板 > openvela 开发板支持列表
> 来源: [https://doc.openvela.com/document?id=596&language=cn&version=dev](https://doc.openvela.com/document?id=596&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/dev_board/Development_Board.md>) | 简体中文 ]

厂商名称 | 开发板型号 | 芯片型号 | 适配案例 | 典型应用场景 | 购买渠道 | 开发板问题咨询  
---|---|---|---|---|---|---  
意法半导体 (STMicroelectronics) | [STM32H750B-DK](<https://www.st.com.cn/zh/evaluation-tools/stm32h750b-dk.html#documentation>) | [STM32H750XBH6](<https://www.st.com.cn/zh/microcontrollers-microprocessors/stm32h750xb.html#documentation>) | [在 STM32H750 上部署 openvela](</document?id=597&version=dev&language=cn>) | 智能家居、工业控制、医疗电子 | [购买链接](<https://shop314814286.taobao.com/?weexShopTab=allitemsbar&weexShopSubTab=allitems&shopFrameworkType=native&sourceType=other&suid=74be4e31-a352-413d-bf81-72909dd711a5&shareUniqueId=31021130754&ut_sk=1.ZUQzpvSPtZsDAM22wgMusrSy_21646297_1743386335140.Copy.shop&un=0ebec934d3cc95cdbbeeeafdb2768e28&share_crt_v=1&un_site=0&spm=a2159r.13376460.0.0&sp_tk=bVZWMmV3bFZkbFI%3D&cpp=1&shareurl=true&short_name=h.6etlMBbY1ZEjXgI&bxsign=scdnpFVDezWrEooi2xHR3oT8fAOZA8b4hwRYH5nD-IkJzr_e6YrW1NWxn3VpZEVnrZ-9OpQT-aJKRxCaAu6Jbcs_PY7aOntLtLTTy6VNNJRR26yZttuARyPNJT51Pyeq_Ei&app=chrome>) | [ST MCU 中国支持](<mailto:mcu.china@st.com>)  
意法半导体 (STMicroelectronics) | STM32F411CEU6 | [STM32F411CE](<https://www.st.com/en/microcontrollers-microprocessors/stm32f411ce.html>) | [在 STM32F411 上使用 openvela 点亮 LED](</document?id=598&version=dev&language=cn>) | 物联网、工业自动化 | [购买链接](<https://item.taobao.com/item.htm?abbucket=11&id=594670660262&ns=1&pisk=g--sY9MMDTfFh3IYhNDUVsm6s9IjkvorC-6vEKEaHGITDxO2Tn7AgVAflIRhkhSwQB1vaB1T0qfaci9XiIRXnAXAMIdfgFuE4dvGmihzG0oyIpevwdA_WlpKHtBuMv7TzUdWfihramaUpNcNDIRWgwmLJTfdBtCADvwdUtjAHOIxd6BfErF9MIHC9tBfHrCYXJedH6UTBsBY9pB5UsBAHZHBp6XADsdAWv9pPvPC3V6vCYgJpnSrQjJdOoEvA9hcbdwLfT-PC9CWBhwaQxX15_pOOfhY-UbW6ZtmFkOBcs_VZN2-EMpk8CBCVcNlCep5XTttnrSJrBtfyggqIG-MBUQv2j4vNCx66U9U1us2fpKNKIw87dbv8hbkbXE12UvNbEd-TP59PtIPVu57qiUbdaqfd_kIdr4DOa-FTSi8kjbOKOnrdvNQoNBhd9MIdr4cW9XtivMQOrf..&priceTId=2147831d17537712154442218e1cfd&spm=a21n57.sem.item.50.51873903rAXiL0&utparam={"aplus_abtest"%3A"88650fbdf45c34af5c7b5b5527a5bc29"}&xxc=taobaoSearch>) | [ST MCU 中国支持](<mailto:mcu.china@st.com>)  
乐鑫科技 (Espressif) | [ESP32S3EYE](<https://www.espressif.com.cn/zh-hans/dev-board/esp32-s3-eye-cn>) | [ESP32S3](<https://www.espressif.com.cn/zh-hans/products/socs/esp32-s3>) | [在 ESP32-S3-EYE 开发板上移植 openvela](</document?id=599&version=dev&language=cn>) | AIoT、人机交互、智能家居 | [购买链接](<https://item.taobao.com/item.htm?spm=a21n57.sem.item.1.3d75390372IH5V&priceTId=2147816e17537599042042013e18b1&utparam={"aplus_abtest"%3A"63d6c7ec4d03ab8b3f05e1c978046905"}&id=664295688431&ns=1&abbucket=5&xxc=taobaoSearch&pisk=g6ojYejoDsfX9HqOCrvPA5v-azq11L-ehOwtKAIVBoEAXdGZaczT_Ec_5fluWmrq3bNtTbNAbFVVflMssflsIK2T6fh__q8yYxD0jldF5H-EnbrNkflbWSHJBJ2UHLzA82hIcldeTh_PerA4XflBXBtRyJV8HReAXL18pJZTBlevF7e_KNCx6fp7yRy1HsFT68K8Q7QOW5U92geQH1ITMrpSe72TX5hTWLM-ZlsbUKNohpTpMPPB8XDYNGItDh48OaP8E8iSOrFLl7stU0wblWHxA9rsb8nrVyzPQQq-K4lYFktft-g-doesjpQ_1Pi0V-gksn4jpRhg00pOkW3qgunxROItFoNr60aAGQNKmYn32z-pdYnogxmSQOKTUXP-nmE6vpqbDSE7EcRlD5g-Wmz0jsd_s0M-DVsPMMPQLCb1Fyj_FWJWFNbihI1rYxEZcdaYE8RwFL_EIreuFWJWFNbgk82rQL958Af..>) | [乐鑫开发者社区](<https://www.espressif.com.cn/zh-hans/contact-us/technical-inquiries>)  
乐鑫科技 (Espressif) | [ESP32S3BOX](<https://www.espressif.com.cn/zh-hans/news/ESP32-S3-BOX_video>) | [ESP32S3](<https://www.espressif.com.cn/zh-hans/products/socs/esp32-s3>) | [请参考：在 ESP32-S3-EYE 开发板上移植 openvela](</document?id=599&version=dev&language=cn>) | AIoT、人机交互、智能家居 | [购买链接](<https://item.taobao.com/item.htm?id=732842971319&pisk=gOJq2JVGWxHVbZ7AiL6a8Sea8mWA3OuCnd_1jhxGcZbcldTwjGsanSVco3xlxawsDtGOQF7yWZ1fnZwNQh8951v15drvUey_hqhvjRW1I2gIdvtYGOBiRBruwraAAiqmCibcqtI6UFpmpvtvDNE4SDOodlr9DuE0sNYGE_jAbOj0IZmPEGIGI-fgn3blyaXGj1j0r_jCvo2ciF4lrGS0IGV0nTblfiWGSFXi43bRbObiw4vHBzS1i0bPYQmK2MCV-nbzL3pPmpFv0ali_LRcgw2CzR2MUi-ZrOVgLf_H9Z1C8UD73O-lbU5Bg2y27hxps_JaomTHmEppsnkr-t9vmBfMKVFM8t8NtKfzjJBVEaXPqpm_9a9PlFvVZDwF1TvCttASwq113M8MHEraIexWAKCJQ2zlWIsdEGJtx57Nsg58WgmIXdd4S55c2g7I40o60-dJbzfdD5FOMmIPRmf065Cc2g7I40PT6sLA4wici&spm=a1z10.3-c.w4002-8715811646.9.4dc69a382dycIm>) | [乐鑫开发者社区](<https://www.espressif.com.cn/zh-hans/contact-us/technical-inquiries>)  
恒玄科技 (Bestechnic) | [BES2600WM MAIN BOARD V1.1](<https://www.fortune-co.com/index.php?s=/Cn/Public/singlePage/catid/176.html>) | BES2600WM-AX4F | [Readme](<https://github.com/open-vela//vendor_bes/blob/dev/boards/best2003_ep/aos_evb/Readme>) | 智能穿戴、AI 玩具 | [联系代理商](<https://www.fortune-co.com/Tech/projectDetail/id/64.html>) | [联系代理商](<https://www.fortune-co.com/Tech/projectDetail/id/64.html>)  
旗芯微半导体 | [FC7300F8M-EVB](<https://www.flagchip.com.cn/Pro/3/3.html>) | [FC7300F8MDT](<https://www.flagchip.com.cn/Pro/3/3.html>) | [FC7300F8M-EVB 开发板 openvela 运行指南](</document?id=851&version=dev&language=cn>) | 域/区控制器、驾驶辅助系统、电池管理系统、电机控制等 | [联系代理商](<https://www.flagchip.com.cn/Pro/3/3.html>) | [联系代理商](<https://www.flagchip.com.cn/Pro/3/3.html>)  
英飞凌半导体 | [TC4D9-EVB](<https://itools.infineon.com/aurix_tc4xx_code_examples/documents/Board_Users_Manual_TriBoard-TC4X9-COM-V2_0_0.pdf>) | [AURIX ™ TC4x](<https://www.infineon.cn/products/microcontroller/32-bit-tricore/aurix-tc4x/tc4dx#products>) | [TC4D9-EVB 开发板 openvela 运行指南](</document?id=852&version=dev&language=cn>) | 车辆运动控制器、区域控制器、车载网关等 | [联系代理商](<https://www.infineon.cn/contact-us/where-to-buy>) | [联系代理商](<https://www.infineon.cn/contact-us/where-to-buy>)

---

## 在 STM32H750 上部署 openvela

> 路径: 开发板 > 在 STM32H750 上部署 openvela
> 来源: [https://doc.openvela.com/document?id=597&language=cn&version=dev](https://doc.openvela.com/document?id=597&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/quickstart/development_board/STM32H750.md>) | 简体中文 ]

# 一、概述

本文档旨在指导如何在 STMicroelectronics STM32H750 微控制器开发板（STM32H750）上部署 openvela，并基于 openvela 操作系统运行 Light and Versatile Graphics Library（LVGL）图形库的演示程序（Demo）。

# 二、准备工作

## 1、搭建开发环境

  1. 配置编译环境：

编译 openvela 需要配置相关的开发环境，详情请参见[快速入门](</document?id=847&version=dev&language=cn>)。

  2. 安装编译工具：  

         
         sudo apt install gcc-arm-none-eabi binutils-arm-none-eabi

  3. 软件下载：

     1. 下载安装 STM32CubeProgrammer 工具，该工具用于烧录程序。下载地址为 [STM32CubeProgrammer 官方下载链接](<https://www.st.com/en/development-tools/stm32cubeprog.html>)。

     2. 安装完成后，执行如下命令安装 libusb，该库用于连接 USB 设备：   

            
            sudo apt-get install libusb-1.0.0-dev

     3. 下载 [stsw-link](<https://www.st.com/en/development-tools/stsw-link007.html#get-software>) 软件包并解压，解压后可获得相关的驱动文件适配您的平台。根据压缩包中的 readme.txt 文件指引完成安装。以下是具体的安装命令：  

            
            sudo sh st-stlink-udev-rules-xxxx-linux-noarch.sh

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455093374_018.png)

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455093543_026.png)

     4. 启动后界面如下：

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455093653_005.png)


## 2、连接开发板

  1. 使用 **USB** 数据线将开发板的 **ST-Link** 调试接口连接到上位机，如下图所示：

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455093762_006.png)

  2. 启动 STM32CubeProgrammer，点击红框处**刷新** 按钮，如果 **Serial number** 下拉框出现数字序列，表示已成功检测到开发板。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455093877_007.png)

  3. 在左侧导航栏选择 **Erasing & Programming**，如下图所示：

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455093975_008.png)

  4. 选择 **ST-LINK** 方式，点击绿色 **Connect** 按钮。当按键变为 **Disconnect** 时，表示开发板已成功连接，如下图所示：

**说明** ：**ST-LINK** 的说明文档请参见[官方文档](<https://www.st.com/resource/en/technical_note/tn1235-overview-of-stlink-derivatives-stmicroelectronics.pdf>)。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455094077_009.png)


# 三、运行 Demo

## 1、下载代码

参考[快速入门](</document?id=847&version=dev&language=cn>)完成代码下载。

## 2、编译代码

在完成代码仓库克隆和下载后，按以下流程为 STM32H750B‑DK 开发板生成所需二进制文件：  

    
    
    # 进入 nuttx 根目录  
    cd nuttx
    
    # 配置开发板环境  
    /build.sh stm32h750b-dk:lvgl -j8
    
    # 在运行 make 编译前，可使用 make menuconfig 命令修改配置，确保所需的功能模块已经启用（如示例中的 LVGL Demo）
    
    # 开始编译 
    make

编译完成后，生成的文件位于 nuttx 目录下，包括：

  * nuttx.bin
  * nuttx.hex

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455094179_010.jpg)


## 3、运行程序

  1. 打开上一步安装的 **STM32CubeProgrammer** 工具。

  2. 选择需要下载的二进制文件，即上一步编译生成的 nuttx.hex 文件，并勾选 **Skip flash erase before programming** ，如下图所示：

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455094276_011.png)

  3. 单击 **Start Programming** 按钮开始下载。下载完成后，会弹出提示框，并且日志窗口会输出相关信息。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455094392_012.png)

  4. 如果下载过程中出现 Error，请单击 **Full chip erase** 按钮擦除芯片数据，然后重新下载固件，即可恢复正常。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455094501_019.png)

  5. 使用串口工具（如 **Minicom** 或 **Tera Term** ）连接并访问开发板，以下以 Minicom 为例，使用如下命令：  

         
         sudo minicom -D /dev/ttyACM0 -b 115200

  6. 在 Minicom 串口终端中执行文件系统查看命令，具体操作如下：

     1. 首次使用 Minicom 的配置事项：如果无法接收键盘输入，请修改 Minicom 的相关配置。

     2. 使用以下命令打开 Minicom 配置界面：  

            
            sudo minicom -s

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455094640_013.png)

     3. 进入 Serial port setup 配置目录，确保以下两项配置值为 No：

        * Hardware Flow Control: No
        * Software Flow Control: No

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455094744_014.png)

     4. 配置完成后重新打开 Minicom。如果仍无法输入，请尝试按下开发板上的黑色按键，重新上电后再打开 Minicom。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455094920_015.png)

  7. 输入以下命令运行示例程序：  

         
         lvgldemo

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455095027_016.png)

  8. 示例程序运行结果如下图所示：

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455095134_017.png)


# 四、开发板简介

## 1、外观

  1. 开发板正面。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455095245_001.png)

  2. 开发板背面。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455095394_002.png)


## 2、主要硬件特性

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455095592_003.png)

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455095715_004.png)

开发板更多详情请参见[官方文档](<https://www.st.com.cn/zh/evaluation-tools/stm32h750b-dk.html#documentation>)。

# 五、附录

## 1、新建开发板配置文件目录

  1. 在 nuttx/boards/arm/stm32h7 目录下，为 **STM32H750B-DK** 开发板新建以下配置文件结构，以支持 openvela 项目的开发需求。  

         
         nuttx/boards/arm/stm32h7
         └── stm32h750b-dk     // 新建开发板目录
             └── configs
             │   ├── lvgl          // 新建 defconfig 目录
             │   │   └── defconfig // 配置选项
             │   └── nsh           // 其他 defconfig 目录
             │       └── defconfig // 配置选项
             ├── include           // 开发板配置信息
             │   └── board.h
             ├── scripts           // 启动脚本、链接文件
             │   ├── flash.ld
             │   ├── ...
             │   └── flash_m4.ld
             ├── src                 // 开发板资源文件  
             │   ├── stm32h745b-dk.h
             │   ├── ...
             │   └── stm32_boot.c
             ├── CMakeLists.txt      // CMake 配置文件
             └── Kconfig             // 内核配置文件

确保 **configs** 目录中包含基于 **lvgl** 的 defconfig 文件以应用相关配置选项。

  2. 液晶显示控制器（LCDC, LCD Controller）引脚配置调整。

为了确保屏幕正常显示，需要根据 STM32H750B-DK 开发板的硬件信息，调整液晶显示控制器的引脚配置，使其与实际硬件设置保持一致。引脚映射修改步骤如下：

     1. 根据开发板[用户手册](<https://www.st.com/resource/en/user_manual/um2488-discovery-kits-with-stm32h745xi-and-stm32h750xb-mcus-stmicroelectronics.pdf>)和[设备引脚图说明](<https://www.st.com/resource/en/schematic_pack/mb1381-h750xb-b01-schematic.pdf>)，查找 LCD Connector 各个信号与芯片引脚的对应关系。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455095827_020.png)

     2. 以 LCD panel 的 R3（红色数据位 3）为例：

        1. R3 信号连接到 STM32H750 芯片的 PH9 引脚。
        2. 在 stm32h7xxx_pinmap.h 文件中，GPIO_PORTH 与 GPIO_PIN9 组合为宏定义 GPIO_LTDC_R3_1。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455095934_021.png)

     3. 修改当前编译配置所包含的 board.h 文件，将 GPIO_LTDC_R3 的定义更改为：  

            
            #define GPIO_LTDC_R3  GPIO_LTDC_R3_1 | GPIO_SPEED_XXXX

其中，请根据实际硬件需求设置 GPIO_SPEED_XXXX。

     4. 其余相关信号引脚请按上述方法进行调整，确保所有引脚定义与硬件设计一致。


## 2、启用双缓冲绘制模式

开发板默认采用单缓冲显示模式，易导致屏幕在滑动时出现抖动。请按以下步骤配置双缓冲显示模式，以提升显示效果和用户体验。

### 2.1 配置 SDRAM 以支持双缓冲模式

  1. 根据屏幕大小计算双缓冲模式的 RAM 需求。


以 480 × 272 分辨率和 16 位（2 字节）色深为例，双缓冲方式需两帧缓冲区：  

    
    
    // 屏幕宽 * 屏幕高 * 颜色深度/8 * buff数
    480 * 272 * 2 * 2 = 522240 Bytes
    
    
    > **注意**
    >
    > 开发板内部的静态随机存取存储器（SRAM，Static Random Access Memory）容量不足，需使用外部同步动态随机存取存储器（SDRAM， Synchronous Dynamic Random Access Memory）。
    

  2. 配置 SDRAM 地址映射。

​根据 STM32H750B-DK 开发板的[用户手册](<https://www.st.com/resource/en/user_manual/um2488-discovery-kits-with-stm32h745xi-and-stm32h750xb-mcus-stmicroelectronics.pdf>)和[编程手册](<https://www.st.com/resource/en/programming_manual/pm0253-stm32f7-series-and-stm32h7-series-cortexm7-processor-programming-manual-stmicroelectronics.pdf>)，完成 SDRAM 地址映射的配置。

     1. 确认 SDRAM 管理方式。

根据用户手册，SDRAM 由灵活内存控制器（FMC, Flexible Memory Controller）进行管理。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455096222_022.png)

     2. 查阅地址映射信息。

在编程手册的 FMC 章节，查找外部设备的地址映射图：

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455096346_023.png)

     3. 选择 Bank 并配置地址。

开发板配备 128 MB SDRAM，由两块 64 MB Bank 组成。任选其中一块，记录起始地址作为基地址，并在链接脚本中声明。

     4. 编辑链接脚本。

打开 nuttx/boards/arm/stm32h7/stm32h750b-dk/scripts/flash.ld，添加 SDRAM 地址声明。示例配置如下：  

            
            /* 配置 SDRAM 区域 */
            sdram (rw) : ORIGIN = 0xD0000000, LENGTH = 8M

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455096470_024.png)

        * ORIGIN：SDRAM 起始地址。
        * LENGTH：配置所需容量值，请确保不超出 SDRAM 实际映射终止地址。


### 2.2 配置 LTDC 的帧缓冲到 SDRAM

为让双缓冲帧缓冲运行于 SDRAM 中，需要在 **make menuconfig** 中设置以下配置：  

    
    
    // make menuconfig 填加如下配置
    CONFIG_STM32H7_LTDC=y
    CONFIG_STM32H7_LTDC_FB_BASE=0xd0000000
    CONFIG_STM32H7_LTDC_FB_SIZE=522240

完成后，帧缓冲区会指定到 SDRAM 起始地址。

### 2.3 修改 LCDC 驱动以支持双缓冲

为适配双缓冲显示模式，需要对液晶显示控制器（LCDC, LCD Controller）相关驱动文件进行如下修改。

  1. 定位并打开驱动文件。

找到 STM32H7 平台的 LTDC 驱动源码文件：  

         
         nuttx/arch/arm/src/stm32h7/stm32_ltdc.c

  2. 修改驱动参数以支持双缓冲。

     1. 配置帧缓冲区（Frame Buffer）大小。

将帧缓冲区大小公式修改为支持双缓冲，此处将高度乘以 2，即预留两倍显示区域用于双缓冲。  

            
            // 设置 STM32_LTDC_L1_FBSIZE 支持双缓冲  
            #define STM32_LTDC_L1_FBSIZE        (STM32_LTDC_L1_STRIDE * STM32_LTDC_HEIGHT * 2)

     2. 设置虚拟分辨率（Virtual Y Resolution）。

调整虚拟分辨率参数 yres_virtual，以便支持双缓冲下的屏幕切换：  

            
            // 修改 g_vtable pinfo yres_virtual 的高度为 STM32_LTDC_HEIGHT * 2
            .pinfo =
                {
                .fbmem           = (uint8_t *)STM32_LTDC_BUFFER_L1,
                .fblen           = STM32_LTDC_L1_FBSIZE,
                .stride          = STM32_LTDC_L1_STRIDE,
                .display         = 0,
                .bpp             = STM32_LTDC_L1_BPP,
                .xres_virtual    = STM32_LTDC_WIDTH,
            #if defined(CONFIG_FB_DOUBLE_BUFFER)
                .yres_virtual    = STM32_LTDC_HEIGHT * 2,
            #else
                .yres_virtual    = STM32_LTDC_HEIGHT,
            #endif


### 2.4 添加 pandisplay 方法以触发显示内容更新

为了支持双缓冲模式，需要在驱动层添加 pandisplay 方法，用于触发 LCDC 重载，实现画面切换。

  1. 在虚表中新增 pandisplay 方法指针。

在 LCDC 驱动的虚表结构体 vtable 中，根据配置条件添加新方法指针：  

         
         .vtable =
             {
             .getvideoinfo    = stm32_getvideoinfo,
             .getplaneinfo    = stm32_getplaneinfo
         #ifdef CONFIG_FB_SYNC
             ,
             .waitforvsync    = stm32_waitforvsync
         #endif
         
         #if defined(CONFIG_FB_DOUBLE_BUFFER)
             ,
             .pandisplay = stm32_pandisplay
         #endif

> 说明
> 
> 该添加允许仅在启用双缓冲（CONFIG_FB_DOUBLE_BUFFER）时使用 pandisplay。

  2. 实现 pandisplay 方法以触发 LCDC 画面搬运。  

         
         // pandisplay 方法：通过 stm32_ltdc_reload 触发 LCDC 画面搬运  
         static int stm32_pandisplay(struct fb_vtable_s *vtable,
                                     struct fb_planeinfo_s *pinfo)
         {
         int ret = 0;
         
         DEBUGASSERT(vtable != NULL && vtable == &g_vtable.vtable);
         
         uint32_t new_fb_start = (uint32_t)pinfo->fbmem +
                                 pinfo->yoffset * pinfo->stride +
                                 pinfo->xoffset * (pinfo->bpp / 8);
         
         putreg32(new_fb_start, stm32_cfbar_layer_t[0]);
         ret = stm32_ltdc_reload(LTDC_SRCR_VBR, true);
         
         return ret;
         }

> 说明
> 
> 方法内部根据缓冲区参数计算新的帧起始地址，并调用重载接口，确保新内容可以及时显示在屏幕上。


### 2.5 在 Reload 中断回调中清理上一帧数据

为更好地支持双缓冲显示模式，需要在 LCDC 的 Reload 中断回调函数中，调用 fb_remove_paninfo 方法，以通知显示缓冲管理模块清空上一帧数据。

在 Reload 中断处理逻辑中，添加如下代码：  

    
    
    if (regval & LTDC_ISR_RRIF)
      {
        /* Register reload interrupt */
    
        /* Clear the interrupt status register */
        reginfo("Register reloaded\n");
        putreg32(LTDC_ICR_CRRIF, STM32_LTDC_ICR);
        priv->error = OK;
    
        fb_remove_paninfo(&g_vtable.vtable, FB_NO_OVERLAY);
      }

> 说明：
> 
>   * 当收到重载完成中断（LTDC_ISR_RRIF）时，调用 fb_remove_paninfo，通知 panbuff 清理上一帧无用数据。
>   * 此修改确保双缓冲切换过程的帧数据管理更加高效和安全。
> 


### 2.6 验证双缓冲模式配置效果

  1. 重新编译并下载程序至开发板。
  2. 启动开发板，运行图形界面演示应用（如 lvgldemo）。
  3. 观察终端日志，确认**双缓冲模式** 已激活，屏幕滑动流畅、无明显抖动。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455096573_025.jpeg)


## 3、配置开机自动启动 Demo 应用

本节介绍如何配置系统，使 Demo 应用（如 lvgldemo）在系统启动后自动运行。

### 3.1 创建系统启动脚本

参考[启动流程](</document?id=614&version=dev&language=cn>)文档，为实现自动启动功能，需要在启动流程中添加如下脚本文件：

  * nuttx/boards/arm/stm32h7/stm32h750b-dk/src/etc/init.d/``rcS
  * nuttx/boards/arm/stm32h7/stm32h750b-dk/src/etc/init.d/``rc.sysinit


其中，rc.sysinit 用于核心应用的启动和文件系统挂载；rcS 用于启动用户应用。

在 rcS 文件中添加以下内容：  

    
    
    echo "Starting System..."
    lvgldemo &

> 说明：
> 
> 此脚本会在系统启动阶段自动运行，从而启动 Demo 应用 lvgldemo。

### 3.2 配置只读内存文件系统（ROMFS）

为支持脚本自动启动，需要启用 ROMFS 相关选项并进行如下配置：

  1. 运行配置工具：  

         
         make menuconfig

  2. 启用并设置以下配置项：  

         
         CONFIG_FS_FAT=y
         CONFIG_FS_ROMFS=y
         CONFIG_FS_ROMFS_CACHE_NODE=y
         CONFIG_FS_ROMFS_CACHE_FILE_NSECTORS=1
         CONFIG_ETC_ROMFS=y
         CONFIG_ETC_ROMFSMOUNTPT="/etc"
         CONFIG_ETC_ROMFSDEVNO=0
         CONFIG_ETC_ROMFSSECTSIZE=64
         CONFIG_NSH_SYSINITSCRIPT="init.d/rc.sysinit"
         CONFIG_NSH_INITSCRIPT="init.d/rcS"
         CONFIG_NSH_SCRIPT_REDIRECT_PATH=""

  3. 保存配置并退出。


### 3.3 将启动脚编译进目标文件

要让系统在启动时自动执行创建的[系统启动脚本](<#31-创建系统启动脚本>)，可按启动流程选择以下任一方法将脚本编译到目标文件中。

##### 方法一 生成 etc_romfs.c 文件

  1. 生成 ROMFS 源文件，使用如下命令：  

         
         ./tools/mkromfsimg.sh . ../nuttx/boards/arm/stm32h7/stm32h750b-dk/src/etc/init.d/rc.sysinit ../nuttx/boards/arm/stm32h7/stm32h750b-dk/src/etc/init.d/rcS

  2. 在 nuttx/boards/arm/stm32h7/stm32h750b-dk/src/Makefile 中引用生成的文件：  

         
         ifeq ($(CONFIG_ETC_ROMFS),y)
         CSRCS += $(TOPDIR)/etc_romfs.c
         endif


##### 方法二 在 Makefile 中直接引用启动脚本

在 nuttx/boards/arm/stm32h7/stm32h750b-dk/src/Makefile 文件中, 添加 rc.sysinit 和 rcS 文件。  

    
    
    ifeq ($(CONFIG_ETC_ROMFS),y)
    RCSRCS = etc/init.d/rc.sysinit etc/init.d/rcS
    RCRAWS = etc/group etc/passwd
    endif

### 3.4 编译并下载程序

完成以上配置和修改后，执行以下步骤：

  1. 在工程根目录执行执行 make clean，清除上一次构建产生的中间文件。
  2. 执行 make，重新编译工程并生成新的固件文件（.hex 格式）。
  3. 使用适配的烧录工具，将生成的 HEX 文件写入开发板。
  4. 重新上电（或按下复位键）启动开发板。启动完成后，系统会自动运行 lvgldemo。

---

## 在 STM32F411 上使用 openvela 点亮 LED

> 路径: 开发板 > 在 STM32F411 上使用 openvela 点亮 LED
> 来源: [https://doc.openvela.com/document?id=598&language=cn&version=dev](https://doc.openvela.com/document?id=598&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/quickstart/development_board/STM32F411.md>) | 简体中文 ]

# 一、概述

本指南将引导您在 STM32F411 微控制器上，基于 openvela 实时操作系统，完成一个基础的 LED 闪烁示例。您将掌握 openvela 的基本使用流程，包括开发环境搭建、项目编译、固件烧录以及 LED 驱动的注册与使用。

# 二、最终效果

![stsw-link007](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455099865_leds.gif)

# 三、准备工作

## 1、硬件准备

  * 开发板：一块基于 STM32F411 的开发板。
  * 调试器：ST-Link V2 调试器（或开发板板载的 ST-Link）。
  * 串口工具：一个 USB 转 TTL 串口模块，用于查看日志输出。
  * 连接线：USB 数据线和若干杜邦线。


## 2、软件与工具链准备

请在您的开发主机（Ubuntu）上完成以下软件的安装与配置。

  1. 搭建 openvela 开发环境。

请首先参照官方文档[快速入门](</document?id=847&version=dev&language=cn>)，完成 openvela 基础开发环境的搭建。

  2. 安装 ARM GCC 编译工具链。

该工具链用于编译目标平台的固件。打开终端，执行以下命令：  

         
         sudo apt install gcc-arm-none-eabi binutils-arm-none-eabi

  3. 安装 STM32CubeProgrammer。

此工具用于将编译好的固件烧录到 STM32 微控制器中。

     * 下载地址：请从 [ST 官网](<https://www.st.com/en/development-tools/stm32cubeprog.html>)下载与您操作系统匹配的版本并完成安装。

     * 安装依赖库：为确保 STM32CubeProgrammer 能够正常识别 USB 设备，请安装 libusb。   

           
           sudo apt-get install libusb-1.0.0-dev

  4. 安装 ST-Link 驱动。

为使 Linux 系统能以普通用户权限访问 ST-Link 设备，需要安装 udev 规则。

     * 下载地址：请从 [ST 官网](<https://www.st.com/en/development-tools/stsw-link007.html#get-software>) 下载 stsw-link007 软件包并解压。

![stsw-link007](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455100193_029.png)

     * 执行安装脚本：根据压缩包内 readme.txt 的指引，执行以下命令安装 udev 规则。  

           
           sudo sh st-stlink-udev-rules-*-linux-noarch.sh

  5. 启动后界面如下：

![STM32CubeProgrammer](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455100293_030.png)


## 3、硬件连接与验证

  1. 查看原理图准备连接硬件。

![Schematic](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455100403_031.png)

  2. 请按照下表所示，将各部件连接起来。

连接起点 | 连接终点 | 说明  
---|---|---  
PC USB 端口 | ST-Link 调试器 USB 口 | 供电与调试  
USB 转 TTL 模块 TX | 开发板 PA10 (USART1_RX) | 串口通信  
USB 转 TTL 模块 RX | 开发板 PA9 (USART1_TX) | 串口通信  
USB 转 TTL 模块 GND | 开发板 GND | 共地  
  
实物连接参考如下：

![Physical Connection](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455100530_032.jpg)

  3. 验证连接。

请通过 STM32CubeProgrammer 工具验证硬件连接是否成功。

     1. 启动 **STM32CubeProgrammer。**
     2. 在右上角的 **ST-LINK Configuration** 区域，单击**刷新** 按钮。如果 **Serial number** 下拉框中出现了设备序列号，则表明调试器已被成功识别。

![Serial number](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455100640_033.png)

     3. 在左侧导航栏选择 **Erasing & Programming**，如下图所示：

![Erasing  Programming](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455100751_034.jpeg)

     4. 选择 **J-Link** 或 **STLINK** 方式，单击绿色 **Connect** 按钮。当按钮变为 **Disconnect** 时，表示开发板已成功连接，如下图所示：

![Connect](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455100865_035.jpg)


# 四、运行 Demo

本章节将指导您如何基于 openvela 源码，为 STM32F411-minimum 开发板编译并运行一个 LED 闪烁示例。

## 1、获取示例代码

请确保您已根据官方[下载 openvela 源代码](<https://github.com/open-vela/docs/tree/dev//zh-cn/quickstart/Download_Vela_sources_zh-cn.md>)文档，在本地准备好了完整的 openvela 源代码。

## 2、(可选) 理解项目结构

openvela 的代码遵循分层设计。了解关键目录有助于您进行后续的定制开发。

  * **应用层 (Examples)** ：[nuttx-apps/examples/leds](<https://github.com/../../../open-vela/nuttx-apps/tree/dev/examples/leds>)
  * **板级支持包 (****BSP****)** ：[nuttx/boards/arm/stm32/stm32f411-minimum](<https://github.com/../../../open-vela/nuttx/tree/dev/boards/arm/stm32/stm32f411-minimum>)


下表简述了核心目录的功能：

目录路径 | 功能说明  
---|---  
nuttx/boards/arm/stm32/stm32f411-minimum/src | 存放 STM32F411 板级的特定驱动实现，如 GPIO 初始化、设备注册（例如 /dev/userleds）等。  
nuttx/arch/arm/src/stm32 | 存放 STM32 芯片家族通用的片上外设（SoC-level）驱动，如 I2C、SPI、GPIO 的底层读写和时钟配置。  
nuttx/drivers | 存放符合 openvela 标准驱动模型的上层驱动接口。应用程序通过调用这些标准接口与底层硬件交互。  
  
## 3、加载并配置项目

  1. 执行以下命令打开 menuconfig 配置界面：  

         
         ./build.sh nuttx/boards/arm/stm32/stm32f411-minimum/configs/rgbled menuconfig

  2. 选择目标开发板。

     1. 按回车键进入 **Board Selection** ，打开开发板选择菜单。

![Board Selection](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455100977_036.png)

     2. 按回车键选择 **Select target board** ，选择要编译的目标平台:

![Select target board](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455101076_037.png)

     3. 按回车键选择 **STM32F411CEU6 Minimum ARM Development Board** ，为 STM32F411CEU6 最小系统板编译固件:

![STM32F411CEU6](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455101205_038.png)

  3. 启用 LED 驱动。

     1. 按两次 Esc 键返回到第一级目录，选择 **Device Drives** :

![Device Drives](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455101383_039.png)

     2. 按 Enter 键进入 LED support：

![LED support](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455101492_040.png)

     3. 启用以下配置项：

        * **LED driver**
        * **Generic Lower Half LED Driver**

![LED Driver](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455101601_041.png)

  4. 启用示例程序。

     1. 按 **/** 键搜索并启用 **EXAMPLES_LEDS** 。

![EXAMPLES_LEDS](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455101708_042.png)

     2. 按 **/** 键搜索并禁用 **ARCH_LEDS** （避免冲突）。

![ARCH_LEDS](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455101810_043.png)

  5. 保存配置，按 **Q** 键退出菜单，选择 **Y** 键保存配置。


## 4、编译项目

  1. 返回到 openvela 根目录，使用以下命令编译 LED 示例程序：  

         
         ./build.sh nuttx/boards/arm/stm32/stm32f411-minimum/configs/rgbled -j8

  2. 编译成功后，将在 nuttx 目录下生成 nuttx.hex 和 nuttx.bin 固件文件。


## 5、烧录固件

  1. 启动 **STM32CubeProgrammer** 工具并连接开发板。

  2. 单击 **Browse** ，选择上一步生成的固件文件 **openvela/nuttx/nuttx.hex** ，并勾选 **Skip flash erase before programming** ，如下图所示：

![Browse](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455101918_044.png)

  3. 单击 **Start Programming** 开始下载。下载完成后，会弹出提示框，并且日志窗口会输出相关信息。

![Start Programming](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455102036_045.png)

  4. 如果下载过程中出现 **Error** ，请单击 **Full chip erase** 按钮擦除芯片数据，然后重新下载固件，即可恢复正常。

![Full chip erase](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455102155_046.png)


## 6、连接串口

  1. 使用 **Minicom** 或其他串口工具连接到开发板。  

         
         # 注意：您的设备号可能是 ttyACM1，请根据实际情况修改
         sudo minicom -D /dev/ttyACM0 -b 115200

  2. （可选）如果首次使用 Minicom 的无法接收键盘输入，请参考如下步骤修改 Minicom 的相关配置：

     1. 使用以下命令打开 Minicom 配置界面：  

            
            sudo minicom -s

![Serial port setup](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455102273_047.png)

     2. 进入 **Serial port setup** 配置目录，确保以下两项配置值为 **No** ：

        * Hardware Flow Control: No
        * Software Flow Control: No

![Hardware Flow Control](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455102373_048.png)

     3. 选择 Save setup as dfl 保存为默认配置，然后 Exit。

     4. 重新连接。若仍有问题，请按开发板的 Reset 键。


## 7、运行 LED 示例

  1. 重新打开 minicom，连接成功后，在 Minicom 终端中按回车，您会看到 nsh> 提示符。

![nsh](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455102494_049.png)

  2. 运行 LED 示例，请输入以下命令：  

         
         leds

  3. 您将看到开发板上的用户 LED 开始闪烁，同时串口终端会输出运行日志。


# 五、如何新增 Demo

本章将指导您如何在 openvela 的 packages/demos 目录下添加、配置并运行一个自定义的 LED 控制应用。

## 1、核心步骤概述

在 openvela 中集成一个新应用，主要遵循以下流程：

  1. **创建应用文件** ：在 packages/demos/ 下创建新目录，并编写应用的 C 源码、Kconfig 和 Makefile。
  2. **注册应用到编译系统** ：修改上层的 Make.defs 文件，让构建系统能够发现您的新应用。
  3. **配置与编译** ：通过 menuconfig 启用新应用，并编译生成包含新功能的固件。
  4. **运行与验证** ：烧录固件，并通过终端命令运行您的 Demo。


## 2、创建 Demo 源码及配置文件

  1. 创建 led 目录：  

         
         # 确保当前位于 openvela 源码根目录
         mkdir -p packages/demos/led

  2. 创建 C 语言源文件 (packages/demos/led/led_main.c)： 此文件是 Demo 的核心逻辑，它通过 ioctl 系统调用与底层 LED 驱动进行交互。  

         
         /****************************************************************************
         * Included Files
         ****************************************************************************/
         #include <nuttx/config.h>
         #include <nuttx/leds/userled.h>
         #include <sys/ioctl.h>
         #include <stdio.h>
         #include <stdlib.h>
         #include <fcntl.h>
         #include <unistd.h>
         /****************************************************************************
         * Public Functions
         ****************************************************************************/
         int main(int argc, char *argv[])
         {
             int fd;
             int ret;
             userled_set_t ledset; // 定义一个LED状态集合
             printf("Starting LED Demo...\n");
             // 1. 打开 userled 设备驱动
             fd = open("/dev/userleds", O_WRONLY);
             if (fd < 0)
             {
                 printf("Failed to open /dev/userleds, please ensure USERLED is enabled.\n");
                 return -1;
             }
             // 2. 点亮第一个LED (通常是LED 0)
             printf("Turning ON LED 0.\n");
             ledset = 1 << 0; // 使用位掩码选择第一个LED
             ret = ioctl(fd, ULEDIOC_SETALL, (unsigned long)ledset);
             if (ret < 0)
             {
                 printf("ioctl(ULEDIOC_SETALL) failed: %d\n", ret);
                 close(fd);
                 return -1;
             }
             sleep(2); // 保持点亮 2 秒
             // 3. 熄灭所有LED
             printf("Turning OFF all LEDs.\n");
             ledset = 0;
             ioctl(fd, ULEDIOC_SETALL, (unsigned long)ledset);
             // 4. 关闭设备
             close(fd);
             printf("LED Demo finished.\n");
             return 0;
         }

  3. 创建 Kconfig 文件。此文件用于在 menuconfig 中生成一个独立的配置选项来控制是否编译此 Demo。

packages/demos/led/Kconfig:  

         
         # Defines the configuration option for the custom LED Demo.
         # This will appear under "Application Configuration -> Demos".
         config APP_DEMOS_LED
             bool "Custom LED control demo"
             default n
             depends on USERLED  # This demo requires the base USERLED driver
             ---help---
                 Enable this to build the custom LED control demo, which
                 demonstrates how to turn an LED on and off via ioctl.

**说明** ：我们创建了一个独立的 APP_DEMOS_LED 选项，而不是复用 EXAMPLES_LEDS，这使得新增的 Demo 逻辑清晰，配置简单，避免了不必要的依赖和混淆。说明：

  4. 创建 Makefile 文件： 此文件定义了本应用的编译规则，如程序名、优先级和堆栈大小。

packages/demos/led/Makefile:  

         
         include $$(APPDIR)/Make.defs
         # Application details, linked to the Kconfig option
         PROGNAME  = led_demo
         PRIORITY  = 100
         STACKSIZE = 2048
         # Source file for the application
         MAINSRC = led_main.c
         include $$(APPDIR)/Application.mk


## 3、注册新 Demo 到编译系统

编辑 packages/demos/ 目录下的 Make.defs 文件，将我们的 led Demo 加入编译列表。

  1. 打开 packages/demos/Make.defs 文件。

  2. 在文件末尾添加以下代码：  

         
         # ... (other demo configurations might be here) ...
         # Add our custom LED demo to the build if it's enabled in Kconfig.
         ifneq ($$(CONFIG_APP_DEMOS_LED),)
         CONFIGURED_APPS += $$(APPDIR)/packages/demos/led
         endif


## 4、配置与编译

### 配置项目

返回 openvela 根目录，运行 menuconfig。  

    
    
    ./build.sh nuttx/boards/arm/stm32/stm32f411-minimum/configs/rgbled menuconfig

### 启用所需配置

在 menuconfig 界面中，确保以下两个选项被启用（可使用 / 键搜索）：

  * 启用底层 LED 驱动 (依赖项)

    * 路径: Device Drivers ---> LED Driver Support ---> [*] User LED Support
    * 确保勾选: CONFIG_USERLED
  * 启用 LED Demo

    * 路径: Application Configuration ---> Demos ---> [*] Custom LED control demo
    * 确保勾选: CONFIG_APP_DEMOS_LED 完成后，保存配置并退出。


完成上述配置后，保存配置并退出。

### 编译项目

切换到 openvela 的根目录，distclean 之后 build:  

    
    
    # (Optional but recommended) Clean previous build artifacts
    ./build.sh nuttx/boards/arm/stm32/stm32f411-minimum/configs/rgbled distclean
    # Build the project with the new configuration
    ./build.sh nuttx/boards/arm/stm32/stm32f411-minimum/configs/rgbled -j8

## 5、运行 Demo

请参考[第四章](<#四运行-demo>)的指导运行 Demo。

  1. 烧录固件：参考[烧录固件](<#5烧录固件>)的指导，烧录新生成的 nuttx/nuttx.hex 文件。

  2. 运行命令：连接串口终端，在 nsh> 提示符下输入 Makefile 中定义的程序名 led_demo。  

         
         nsh> led_demo

  3. 观察结果：

     * 您将在终端看到 **Starting LED Demo...** 等日志输出。
     * 同时，开发板上的用户 LED 将**点亮 2 秒钟，然后熄灭** 。


# 六、FAQ

## 1、编译时出现 undefined reference to board_userled... 错误

### 问题现象

在配置完 menuconfig 并执行编译后，链接阶段出现类似以下的 **undefined reference** 错误。

![undefined reference](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455102599_050.png)

### 原因分析

这是 USERLED 通用驱动和 ARCH_LEDS 板级特定驱动之间的配置冲突。

  * CONFIG_USERLED=y：启用了通用的 /dev/userleds 驱动框架。此框架依赖于底层的 board_userled... 函数来实现具体硬件操作。
  * CONFIG_ARCH_LEDS=y：启用了板级 LED 驱动。在这种模式下，系统认为 LED 由架构代码直接控制，因此不会编译和链接 board_userled... 相关函数，导致 USERLED 驱动找不到实现，从而产生链接错误。


### 解决方案

禁用板级 ARCH_LEDS 驱动，以允许 USERLED 通用驱动正确工作。

  1. 进入 menuconfig：  

         
         ./build.sh nuttx/boards/arm/stm32/stm32f411-minimum/configs/rgbled menuconfig

  2. 关闭 ARCH_LEDS。

  3. 清理并重新编译：  

         
         # 清理旧的配置和构建产物
         ./build.sh nuttx/boards/arm/stm32/stm32f411-minimum/configs/rgbled distclean
         # 重新编译项目
         ./build.sh nuttx/boards/arm/stm32/stm32f411-minimum/configs/rgbled -j8


## 2、程序运行时提示 Failed to open /dev/userleds

### 问题现象

在终端中运行 Demo，程序输出错误信息，无法打开设备文件。

![userleds](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455102758_051.png)

### 原因分析：

此问题表示 /dev/userleds 设备节点未被创建。这通常是因为 openvela 的 USERLED 通用驱动程序未在配置中启用，导致相关代码没有被编译进固件。

### 解决方案

按照 Demo 中的 Kconfig 文件，打开 **EXAMPLES_LEDS** 和 **USERLED** 配置。

![userleds](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455102862_052.png)

## 3、packages/demos 和 nuttx/apps/examples 目录有什么区别

  * https://github.com/open-vela/nuttx-apps/tree/dev/examples

    * 来源: NuttX 官方社区。
    * 内容: 包含由 NuttX 社区维护的、用于演示其核心功能的各种示例。
    * 性质: 通用、与上层应用无关。
  * https://github.com/open-vela/packages_demos

    * 来源: openvela 项目。
    * 内容: 包含为展示 openvela 特定功能或集成方案而创建的示例。
    * 性质: openvela 定制、与项目强相关。
  * 开发建议： 当您为 openvela 项目新增自定义 Demo 或应用时，强烈建议您在 **packages/demos** 目录下创建。


# 七、参考资料

  * **[在 STM32H750 上部署 openvela](</document?id=597&version=dev&language=cn>)**

    * 一个具体的、端到端的硬件部署实践案例。
  * **[NuttX 官方文档](<https://nuttx.apache.org/docs/latest/>)**

    * 理解 NuttX 底层机制的权威指南，特别是其**构建系统 (Build System)** 和 **Kconfig 配置** 相关的章节，对于添加新组件至关重要。
  * **[STM32CubeProgrammer 软件指南](<https://www.st.com/en/development-tools/stm32cubeprog.html>)**

    * 学习如何使用 ST 官方工具进行固件烧录、配置选项字节等操作。

---

## 在 ESP32-S3-EYE 开发板上移植 openvela 并启用 Wi-Fi 功能

> 路径: 开发板 > 在 ESP32-S3-EYE 开发板上移植 openvela 并启用 Wi-Fi 功能
> 来源: [https://doc.openvela.com/document?id=599&language=cn&version=dev](https://doc.openvela.com/document?id=599&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/quickstart/development_board/ESP32-S3-EYE.md>) | 简体中文 ]

# 一、概述

本指南详细介绍如何在乐鑫（Espressif）的 ESP32-S3-EYE 开发板上完成 openvela 系统的移植工作，并重点启用其板载 Wi-Fi 功能。

**目标读者** ： 熟悉 openvela 和嵌入式开发流程的工程师。

**最终目标** ： 成功编译并烧录一个支持 Wi-Fi 的 openvela 固件到 ESP32-S3-EYE 开发板，并通过 NuttShell (NSH) 命令行验证网络接口。

# 二、前提条件

下载源码，请参见[快速入门](</document?id=847&version=dev&language=cn>)。

# 三、准备工作：搭建 ESP32-S3 开发环境

您需要为 ESP32-S3 芯片准备专用的交叉编译工具链和烧录工具。

## 1、安装 ESP32-S3 工具链

  1. 下载工具链： 执行以下命令，下载 Xtensa 架构的交叉编译工具链。  

         
         curl -L -O --progress-bar "https://github.com/espressif/crosstool-NG/releases/download/esp-12.2.0_20230208/xtensa-esp32s3-elf-12.2.0_20230208-x86_64-linux-gnu.tar.xz"

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455106265_053.png)

  2. 解压工具链： 将下载的压缩包解压到您选择的安装目录（例如 /opt）。  

         
         tar -xf xtensa-esp32s3-elf-12.2.0_20230208-x86_64-linux-gnu.tar.xz -C /opt/

  3. 配置环境变量： 将工具链的 bin 目录添加到系统的 PATH 环境变量中，以便系统能找到编译器。  

         
         export PATH="/opt/xtensa-esp32s3-elf/bin:$PATH"

> **说明：** 为使配置永久生效，请将上述 export 命令添加到您的 ~/.bashrc 或 ~/.zshrc 文件中，并执行 source ~/.bashrc。

  4. 验证安装： 执行以下命令，如果能正确显示工具链版本，则表示安装成功。  

         
         xtensa-esp32s3-elf-gcc -v

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455106370_054.png)


## 2、安装 esptool

esptool 是用于向 Espressif 芯片烧录固件的关键工具。我们强烈建议在 Python 虚拟环境中安装它，以避免与系统其他 Python 包产生冲突。

  1. 创建并激活虚拟环境：  

         
         apt install python3.10-venv
             
         python3 -m venv myenv
         source myenv/bin/activate

成功激活后，您的命令行提示符前会显示 (myenv)。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455106477_055.png)

  2. 在虚拟环境中安装 esptool：  

         
         pip install esptool

> **注意：** 后续所有编译和烧录操作，都应在此已激活的 (myenv) 环境中执行。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455106590_056.png)


# 三、移植与编译

本章节指导您如何创建板级配置文件并编译固件。

## 1、理解 esp32s3-eye 板级代码结构

在进行配置之前，请先熟悉 esp32s3-eye 的板级支持包（BSP）[目录结构](<https://github.com/open-vela//nuttx/tree/dev/boards/xtensa/esp32s3/esp32s3-eye>)。这有助于您理解各个文件的作用。  

    
    
    esp32s3-eye/
    ├── configs/                 # 板级功能配置中心，包含不同功能的 defconfig
    │   ├── gpio/        
    │   │      └── defconfig     # GPIO引脚功能映射（如按键/LED/传感器控制）
    │   ├── i2c/           
    │   │      └── defconfig     # I2C总线参数（速率/设备地址/中断配置）
    │   ├── lcd/         
    │   │      └── defconfig     # 显示屏接口协议（SPI/I2C）、分辨率、时序参数  
    │   ├── nsh/         
    │   │      └── defconfig     # NuttShell(NSH)交互环境配置（串口终端/启动脚本）
    │   ├── usbhsh/      
    │   │       └── defconfig    # USB Host协议栈配置（外设驱动支持）  
    │   └── wifi/        
    │           └── defconfig    # Wi-Fi/BLE无线协议参数（SSID/加密方式/射频校准）
    ├── include/                 # 板级硬件抽象层头文件
    │   └── board.h              # 定义内存布局、时钟、外设基地址等
    ├── scripts/                 # 构建系统脚本
    │   └── Make.defs            # 定义交叉编译器、编译选项等
    └── src/                     # 板级驱动源码和功能初始化代码
        └── Kconfig              # Kconfig菜单配置项，用于menuconfig

## 2、创建自定义板级配置文件

您需要在 vendor 目录下为您的项目创建一套独立的板级配置。

  1. 创建目录结构。 执行以下命令，创建所需的目录。-p 参数可以确保父目录也一并被创建。  

         
         mkdir -p vendor/espressif/boards/esp32s3/esp32s3-eye/configs/openvela

  2. 添加 Wi-Fi 配置文件。 在刚创建的 openvela 目录下，新建一个名为 defconfig 的文件。此文件包含了启用 Wi-Fi 功能所需的所有 openvela 配置项。

  3. 将 [附录 A: Wi-Fi 功能 defconfig](<#附录-a-wi-fi-功能-defconfig>) 中的全部内容复制并粘贴到 vendor/espressif/boards/esp32s3/esp32s3-eye/configs/openvela/defconfig 文件中。


## 3、执行编译

现在，使用 build.sh 脚本，并指定我们刚刚创建的 defconfig 路径来编译 openvela。  

    
    
    # 确保您仍处于 (myenv) 虚拟环境中
    rm nuttx/.config
    rm nuttx/Make.defs
    
    ./build.sh vendor/espressif/boards/esp32s3/esp32s3-eye/configs/openvela/ -j8

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455106710_057.png)

# 四、烧录与验证

编译成功后，将生成的固件烧录到开发板并验证功能。

## 1、烧录固件

  1. 连接开发板：

使用 USB 线将 ESP32-S3-EYE 开发板连接到您的计算机。

  2. 确定串口设备号：

执行 ls /dev/ttyACM* 或 dmesg 命令，查找开发板对应的串口设备号，通常为 /dev/ttyACM0。

  3. 执行烧录命令：

在 nuttx 目录下，执行 make flash 命令。请将 ESPTOOL_PORT 替换为您实际的串口设备号。  

         
         # 确保您仍处于 (myenv) 虚拟环境中
         # 进入 nuttx 源码目录
         cd nuttx
             
         make -j$(nproc) flash ESPTOOL_PORT=/dev/ttyACM0 ESPTOOL_BINDIR=./

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455106846_058.png)


## 2、验证 Wi-Fi 功能

  1. 打开串口终端： 使用 minicom 或其他串口工具连接到开发板，波特率通常为 115200。  

         
         sudo minicom -D /dev/ttyACM0

  2. 检查网络接口： 系统启动后，您将看到 NSH 的命令行提示符 nsh>。输入 ifconfig 命令并按回车。

![img](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455106968_059.png)

**验证点：** 如果您在输出中能看到 wlan0 网络接口，如上图所示，即表明 Wi-Fi 驱动已成功加载，移植成功。


# 五、总结

本指南通过配置 ESP32-S3 工具链、创建并应用 defconfig 文件，成功地将 openvela 移植到了 ESP32-S3-EYE 开发板并启用了 Wi-Fi 功能。核心工作在于正确配置编译环境和提供一个包含完整网络协议栈及驱动的 defconfig。

# 六、参考文档

  * [esp32s3-eye](<https://github.com/open-vela//nuttx/tree/dev/boards/xtensa/esp32s3/esp32s3-eye>)
  * [defconfig](<https://github.com/open-vela//vendor_espressif/blob/dev/boards/esp32s3/esp32s3-eye/configs/openvela/defconfig>)
  * [Managing esptool on virtual environment](<https://nuttx.apache.org/docs/latest/platforms/xtensa/esp32s3/index.html#managing-esptool-on-virtual-environment>)


# 附录 A: Wi-Fi 功能 defconfig
    
    
    #
    # This file is autogenerated: PLEASE DO NOT EDIT IT.
    #
    # You can use "make menuconfig" to make any modifications to the installed .config file.
    # You can then do "make savedefconfig" to generate a new defconfig file that includes your
    # modifications.
    #
    # CONFIG_ARCH_LEDS is not set
    # CONFIG_NSH_ARGCAT is not set
    # CONFIG_NSH_CMDOPT_HEXDUMP is not set
    CONFIG_ARCH="xtensa"
    CONFIG_ARCH_BOARD="esp32s3-eye"
    CONFIG_ARCH_BOARD_COMMON=y
    CONFIG_ARCH_BOARD_ESP32S3_EYE=y
    CONFIG_ARCH_CHIP="esp32s3"
    CONFIG_ARCH_CHIP_ESP32S3=y
    CONFIG_ARCH_CHIP_ESP32S3WROOM1N4=y
    CONFIG_ARCH_INTERRUPTSTACK=2048
    CONFIG_ARCH_STACKDUMP=y
    CONFIG_ARCH_XTENSA=y
    CONFIG_BOARD_LOOPSPERMSEC=16717
    CONFIG_BUILTIN=y
    CONFIG_DEBUG_FULLOPT=y
    CONFIG_DEBUG_SYMBOLS=y
    CONFIG_DEFAULT_TASK_STACKSIZE=4096
    CONFIG_DEV_ZERO=y
    CONFIG_DRIVERS_IEEE80211=y
    CONFIG_DRIVERS_VIDEO=y
    CONFIG_DRIVERS_WIRELESS=y
    CONFIG_ESP32S3_EYE_LCD=y
    CONFIG_ESP32S3_GPIO_IRQ=y
    CONFIG_ESP32S3_RT_TIMER_TASK_STACK_SIZE=4096
    CONFIG_ESP32S3_SPI2_CLKPIN=21
    CONFIG_ESP32S3_SPI2_CSPIN=44
    CONFIG_ESP32S3_SPI2_MISOPIN=1
    CONFIG_ESP32S3_SPI2_MOSIPIN=47
    CONFIG_ESP32S3_SPIRAM=y
    CONFIG_ESP32S3_SPIRAM_MODE_OCT=y
    CONFIG_ESP32S3_USBSERIAL=y
    CONFIG_ESP32S3_WIFI=y
    CONFIG_EXAMPLES_FB=y
    CONFIG_EXAMPLES_LVGLDEMO=y
    CONFIG_EXAMPLES_RANDOM=y
    CONFIG_FS_PROCFS=y
    CONFIG_GRAPHICS_LVGL=y
    CONFIG_HAVE_CXXINITIALIZE=y
    CONFIG_IDLETHREAD_STACKSIZE=3072
    CONFIG_INIT_ENTRYPOINT="nsh_main"
    CONFIG_INIT_STACKSIZE=3072
    CONFIG_INTELHEX_BINARY=y
    CONFIG_IOB_NBUFFERS=124
    CONFIG_IOB_THROTTLE=24
    CONFIG_LCD_FRAMEBUFFER=y
    CONFIG_LCD_PORTRAIT=y
    CONFIG_LCD_ST7789_BGR=y
    CONFIG_LCD_ST7789_FREQUENCY=40000000
    CONFIG_LCD_ST7789_YRES=240
    CONFIG_LIBYUV=y
    CONFIG_LINE_MAX=64
    CONFIG_LV_FONT_MONTSERRAT_20=y
    CONFIG_LV_NUTTX_LCD_DOUBLE_BUFFER=y
    CONFIG_LV_USE_CLIB_MALLOC=y
    CONFIG_LV_USE_CLIB_SPRINTF=y
    CONFIG_LV_USE_CLIB_STRING=y
    CONFIG_LV_USE_DEMO_WIDGETS=y
    CONFIG_LV_USE_LOG=y
    CONFIG_LV_USE_NUTTX=y
    CONFIG_LV_USE_NUTTX_LCD=y
    CONFIG_LV_USE_NUTTX_TOUCHSCREEN=y
    CONFIG_MM_REGIONS=2
    CONFIG_NAME_MAX=48
    CONFIG_NETDB_BUFSIZE=512
    CONFIG_NETDB_DNSCLIENT=y
    CONFIG_NETDB_DNSCLIENT_RECV_TIMEOUT=2
    CONFIG_NETDB_DNSCLIENT_RETRIES=8
    CONFIG_NETDB_DNSSERVER_NOADDR=y
    CONFIG_NETDEV_LATEINIT=y
    CONFIG_NETDEV_MAX_IPv6_ADDR=4
    CONFIG_NETDEV_MULTIPLE_IPv6=y
    CONFIG_NETDEV_PHY_IOCTL=y
    CONFIG_NETDEV_STATISTICS=y
    CONFIG_NETDEV_WIRELESS_IOCTL=y
    CONFIG_NETDOWN_NOTIFIER=y
    CONFIG_NETLINK_ALLOC_CONNS=1
    CONFIG_NETLINK_ROUTE=y
    CONFIG_NETUTILS_CJSON=y
    CONFIG_NETUTILS_DHCPC_RECV_TIMEOUT_MS=200
    CONFIG_NETUTILS_DHCPC_RETRIES=20
    CONFIG_NETUTILS_IPERF=y
    CONFIG_NET_ALLOC_DEVIF_CALLBACKS=1
    CONFIG_NET_ARPTAB_SIZE=48
    CONFIG_NET_ARP_IPIN=y
    CONFIG_NET_BROADCAST=y
    CONFIG_NET_ETH_PKTSIZE=1514
    CONFIG_NET_GUARDSIZE=4
    CONFIG_NET_ICMP_ALLOC_CONNS=1
    CONFIG_NET_ICMP_NPOLLWAITERS=2
    CONFIG_NET_ICMP_SOCKET=y
    CONFIG_NET_ICMPv6=y
    CONFIG_NET_ICMPv6_ALLOC_CONNS=1
    CONFIG_NET_ICMPv6_AUTOCONF=y
    CONFIG_NET_ICMPv6_NEIGHBOR=y
    CONFIG_NET_ICMPv6_SOCKET=y
    CONFIG_NET_IPFRAG=y
    CONFIG_NET_IPv6=y
    CONFIG_NET_LOCAL=y
    CONFIG_NET_LOCAL_SCM=y
    CONFIG_NET_LOOPBACK=y
    CONFIG_NET_NETLINK=y
    CONFIG_NET_PKT=y
    CONFIG_NET_SEND_BUFSIZE=16384
    CONFIG_NET_STATISTICS=y
    CONFIG_NET_TCP=y
    CONFIG_NET_TCPBACKLOG=y
    CONFIG_NET_TCP_ALLOC_CONNS=1
    CONFIG_NET_TCP_DELAYED_ACK=y
    CONFIG_NET_TCP_NWRBCHAINS=128
    CONFIG_NET_TCP_RTO=1
    CONFIG_NET_TCP_SELECTIVE_ACK=y
    CONFIG_NET_TCP_WAIT_TIMEOUT=0
    CONFIG_NET_TCP_WRITE_BUFFERS=y
    CONFIG_NET_UDP=y
    CONFIG_NET_UDP_ALLOC_CONNS=1
    CONFIG_NET_UDP_NOTIFIER=y
    CONFIG_NET_UDP_NWRBCHAINS=64
    CONFIG_NET_UDP_WRITE_BUFFERS=y
    CONFIG_NSH_ARCHINIT=y
    CONFIG_NSH_BUILTIN_APPS=y
    CONFIG_NSH_FILEIOSIZE=512
    CONFIG_NSH_READLINE=y
    CONFIG_POSIX_SPAWN_DEFAULT_STACKSIZE=2048
    CONFIG_PREALLOC_TIMERS=4
    CONFIG_PTHREAD_MUTEX_TYPES=y
    CONFIG_RAM_SIZE=114688
    CONFIG_RAM_START=0x20000000
    CONFIG_RR_INTERVAL=200
    CONFIG_SCHED_LPWORK=y
    CONFIG_SCHED_WAITPID=y
    CONFIG_SIG_DEFAULT=y
    CONFIG_SMP=y
    CONFIG_SMP_NCPUS=2
    CONFIG_START_DAY=6
    CONFIG_START_MONTH=12
    CONFIG_START_YEAR=2011
    CONFIG_SYSLOG_BUFFER=y
    CONFIG_SYSTEM_DHCPC_RENEW6=y
    CONFIG_SYSTEM_DHCPC_RENEW=y
    CONFIG_SYSTEM_NSH=y
    CONFIG_SYSTEM_PING=y
    CONFIG_SYSTEM_PING_STACKSIZE=3072
    CONFIG_SYSTEM_TCPDUMP=y
    CONFIG_TIMER=y
    CONFIG_TLS_TASK_NELEM=4
    CONFIG_UTILS_IPERF2=y
    CONFIG_VIDEO=y
    CONFIG_VIDEO_FB=y
    CONFIG_WIRELESS=y
    CONFIG_WIRELESS_WAPI=y
    CONFIG_WIRELESS_WAPI_CMDTOOL=y
    CONFIG_WIRELESS_WAPI_INITCONF=y
    CONFIG_WIRELESS_WAPI_STACKSIZE=8192

---

## 为 STM32F407 开发板移植 openvela

> 路径: 开发板 > 为 STM32F407 开发板移植 openvela
> 来源: [https://doc.openvela.com/document?id=600&language=cn&version=dev](https://doc.openvela.com/document?id=600&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/quickstart/development_board/STM32F407.md>) | 简体中文 ]

本指南详细介绍了如何为 RoboMaster C 型开发板（后文简称“C 板”）移植 openvela 操作系统。C 板的主控芯片为 STM32F407IGH6。由于 NuttX 官方已提供对 STM32F407IG 系列芯片的支持，本指南将重点阐述板级支持包（Board Support Package, BSP）的适配过程。

完成本教程后，您将能够为一个新的硬件平台创建基础的 BSP，并成功运行 openvela 系统，实现对板载 LED 的控制。

# 您将学到什么

  * openvela 的板级移植核心思想与启动流程。
  * 如何实现板级初始化所需的关键 C 语言接口函数。
  * 如何配置 GPIO，并为系统状态和用户应用编写 LED 驱动。
  * 如何通过 Kconfig 将新开发板集成到 openvela 的构建系统中。
  * 如何为新开发板创建 defconfig 默认配置文件。


# 准备工作

在开始之前，请确保您已完成以下准备工作：

  1. 获取源码：参考文档[快速入门](<https://github.com/open-vela/docs/tree/dev//zh-cn/quickstart/Download_Vela_sources_zh-cn.md>)下载最新代码。
  2. 了解 openvela 架构：建议您预先阅读 [openvela 架构](<https://github.com/open-vela//docs/zh-cn/README_zh-cn.md#技术架构>)以理解其分层设计。
  3. 查阅[系统启动流程](</document?id=614&version=dev&language=cn>)文档，获取更详细的启动时序和函数调用关系图。


# 一、移植原理与启动流程

openvela 的移植本质上是为操作系统框架提供一套与特定硬件交互的接口。这些接口构成了板级支持包（BSP），它位于 nuttx/boards/ 目录下。本指南将通过实现一个最小功能的 BSP，让 openvela 在 C 板上启动并运行。

## 关键启动函数

openvela 在启动过程中，会按照特定顺序调用一系列由 BSP 提供的函数来完成硬件初始化。要成功启动系统，您必须在 BSP 中实现以下关键函数：

函数 | 描述  
---|---  
void stm32_boardinitialize(void) | 由系统启动代码 __start 调用。这是最早执行的板级初始化函数，用于配置最基础的硬件，如时钟和调试串口。  
void board_late_initialize(void) | 如果配置了 CONFIG_BOARD_LATE_INITIALIZE，此函数会在 OS 初始化后期被调用，通常用于初始化那些依赖 OS 服务的驱动。  
int stm32_bringup(void) | 如果配置 CONFIG_BOARD_LATE_INITIALIZE 选项，由 board_late_initialize() 调用； 如果没有配置 CONFIG_BOARD_LATE_INITIALIZE 选项，由 board_app_initialize(arg) 调用。 在 stm32_bringup 里将实现驱动的初始化。  
int board_app_initialize(uintptr_t arg) | 由 boardctl() 接口通过 BOARDIOC_INIT 命令触发，用于执行应用层或用户自定义的初始化。  
  
此外，如果您的系统配置 CONFIG_ARCH_LEDS 用于显示系统状态（如启动、Panic），则还需要实现以下函数：

函数 | 描述  
---|---  
void board_autoled_initialize(void) | 初始化用于系统状态指示的 LED 引脚，通常设置为 GPIO 输出模式。  
void board_autoled_on(int led) | 根据系统状态（如 LED_STARTED）点亮指定的 LED。  
void board_autoled_off(int led) | 根据系统状态（如 LED_PANIC 结束）熄灭指定的 LED。  
  
## 硬件配置：时钟与引脚

除了实现函数接口，您还需要在板级头文件 board.h 中定义宏，以配置 STM32 的时钟树、外设引脚功能等。这些宏将被芯片级的驱动代码（如 stm32_rcc.c）使用。

以下是 C 板时钟树的配置示例，它描述了如何将 12MHz 的外部高速晶振（HSE）通过 PLL 倍频至 168MHz 作为系统主时钟（SYSCLK）。  

    
    
    /* Clocking *****************************************************************/
    /*
     * System Clock source           : PLL (HSE)
     * SYSCLK(Hz)                    : 168000000
     * HCLK(Hz)                      : 168000000
     * AHB Prescaler                 : 1
     * APB1 Prescaler                : 4
     * APB2 Prescaler                : 2
     * HSE Frequency(Hz)             : 12000000     (STM32_BOARD_XTAL)
     * PLLM                          : 12           (STM32_PLLCFG_PLLM)
     * PLLN                          : 336          (STM32_PLLCFG_PLLN)
     * PLLP                          : 2            (STM32_PLLCFG_PLLP)
     * PLLQ                          : 7            (STM32_PLLCFG_PLLQ)
     * Main regulator output voltage : Scale1 mode
     * Flash Latency(WS)             : 5
     * Prefetch Buffer               : ON
     * Instruction cache             : ON
     * Data cache                    : ON
     */

# 二、代码实现步骤

本节将指导您完成本项目的文件创建和代码编写。

## 1、创建代码目录结构

首先，在 nuttx/boards/arm/stm32/ 目录下，创建一个名为 stm32f407-robomaster 的新目录，并建立如下的子目录和文件结构。

**代码路径** : [nuttx/boards/arm/stm32/stm32f407-robomaster/](<https://github.com/open-vela//nuttx/tree/dev/boards/arm/stm32/stm32f407-robomaster>)  

    
    
    stm32f407-robomaster
    ├── CMakeLists.txt
    ├── configs                           # defconfig 配置路径
    │   ├── led
    │   │   └── defconfig                 # LED 示例的默认配置
    │   └── nsh
    │       └── defconfig                # NuttShell (NSH) 的默认配置
    ├── include
    │   └── board.h                       # 板级硬件配置头文件
    ├── Kconfig                           # 板级 Kconfig 配置文件
    ├── scripts                           # 链接脚本
    │   ├── ld.script                     # 链接器脚本
    │   └── Make.defs                     # 板级 Make 定义
    └── src
        ├── CMakeLists.txt
        ├── Make.defs
        ├── stm32_appinit.c               # 实现 board_app_initialize
        ├── stm32_autoleds.c              # 实现系统状态 LED 控制
        ├── stm32_boot.c                  # 实现 stm32_boardinitialize
        ├── stm32_bringup.c               # 实现驱动初始化
        ├── stm32f407-robomaster.h        # 板级私有头文件，定义 GPIO
        └── stm32_userleds.c              # 实现用户层 LED 驱动接口

## 2、实现核心初始化函数

在 src/ 目录下，您需要创建并填充以下 C 文件。

### stm32_boot.c：早期硬件初始化

此文件负责实现 stm32_boardinitialize()，用于在系统启动的最初阶段配置必要的硬件。  

    
    
    #include <nuttx/config.h>
    #include "stm32f407-robomaster.h" // 板级私有定义
    
    void stm32_boardinitialize(void)
    {
    #ifdef CONFIG_ARCH_LEDS
      /* 如果启用了系统状态LED，则初始化它们 */  
      board_autoled_initialize();
    #endif
    }
    
    
    #ifdef CONFIG_BOARD_LATE_INITIALIZE
    void board_late_initialize(void)
    {
      /* 执行板级后期初始化 */
      stm32_bringup();
    }
    #endif

### stm32_bringup.c：设备驱动初始化

此文件中的 stm32_bringup() 函数负责初始化并注册所有板载设备的驱动程序。在本例中，我们只注册用户 LED 驱动。  

    
    
    #include "stm32.h"
    
    #ifdef CONFIG_USERLED
    #  include <nuttx/leds/userled.h>
    #endif
    
    #include "stm32f407-robomaster.h"
    
    int stm32_bringup(void)
    {
      int ret = OK;
    
    #ifdef CONFIG_USERLED
      /* 注册用户 LED 驱动，使其在 /dev/userleds 节点可用 */
      ret = userled_lower_initialize("/dev/userleds");
      if (ret < 0)
        {
          syslog(LOG_ERR, "ERROR: userled_lower_initialize() failed: %d\n", ret);
        }
    #endif
      /* 在此添加其他驱动的初始化，例如 I2C, SPI, SDIO 等 */
      return ret;
    }

### stm32_appinit.c：应用初始化桥梁

主要实现 int board_app_initialize(uintptr_t arg) 函数：

  * 如果打开 CONFIG_BOARD_LATE_INITIALIZE ，stm32_bringup() 将由 board_late_initialize() 调用。
  * 如果没有打开 CONFIG_BOARD_LATE_INITIALIZE，stm32_bringup() 将由 board_app_initialize(arg) 调用。  

        
        int board_app_initialize(uintptr_t arg)
        {
        #ifdef CONFIG_BOARD_LATE_INITIALIZE
          /* 如果定义了后期初始化，bringup 已被调用，此处无需操作 */
          return OK;
        #else
          /* 否则，在此处调用 bringup 来初始化驱动 */
          return stm32_bringup();
        #endif
        }


## 3、实现 LED 驱动

openvela 将 LED 分为两类：一类用于指示系统状态（autoleds），另一类供用户应用程序控制（userleds）。

### stm32_autoleds.c：系统状态 LED

该文件实现 board_autoled_* 系列函数，来控制实现 LED 的亮灭，由系统内核在特定事件（如启动、断言失败）发生时自动调用。  

    
    
    /****************************************************************************
     * Private Functions
     ****************************************************************************/
    
    static inline void set_led(bool v)
    {
      ledinfo("Turn LED %s\n", v? "on":"off");
      stm32_gpiowrite(GPIO_LEDR, v);
      stm32_gpiowrite(GPIO_LEDG, v);
      stm32_gpiowrite(GPIO_LEDB, v);
    }
    
    /****************************************************************************
     * Public Functions
     ****************************************************************************/
    #ifdef CONFIG_ARCH_LEDS
    void board_autoled_initialize(void)
    {
      /* 配置所有系统状态 LED 的 GPIO 为输出模式 */
      stm32_configgpio(GPIO_LEDR);
      stm32_configgpio(GPIO_LEDG);
      stm32_configgpio(GPIO_LEDB);
    }
    
    void board_autoled_on(int led)
    {
      ledinfo("board_autoled_on(%d)\n", led);
    
      switch (led)
        {
        case LED_STARTED:      // OS 启动完成
        case LED_HEAPALLOCATE: // 堆内存分配失败
          /* As the board provides only one soft controllable LED, we simply
           * turn it on when the board boots.
           */
    
          set_led(true);
          break;
    
        case LED_PANIC:            // 系统 Panic
          /* 在 Panic 状态下，LED 通常会快速闪烁，由上层代码控制 */
          set_led(true);
          break;
        }
    }
    
    void board_autoled_off(int led)
    {
      /* 实现与 board_autoled_on 对应的关灯逻辑 */
      switch (led)
        {
        case LED_PANIC:
    
          /* For panic state, the LED is blinking */
    
          set_led(false);
          break;
        }
    }
    
    #endif /* CONFIG_ARCH_LEDS */

### stm32_userleds.c：用户应用 LED

该文件为通用的 LED 驱动（位于 drivers/leds/userled_lower.c）提供底层的硬件操作接口。应用程序通过标准的 open(), write(), ioctl() 等VFS接口访问 /dev/userleds 来控制这些 LED。

我们需要提供下面的函数接口给 userled_lower.c 调用：  

    
    
    #include <nuttx/config.h>
    #include "stm32f407-robomaster.h"
    
    #ifndef CONFIG_ARCH_LEDS
    
    /* 定义板载用户 LED 对应的 GPIO 配置 */
    static const uint32_t g_ledcfg[BOARD_NLEDS] =
    {
      GPIO_LEDB,
      GPIO_LEDG,
      GPIO_LEDR
    };
    
    /****************************************************************************
     * Name: board_userled_initialize
     ****************************************************************************/
    
    uint32_t board_userled_initialize(void)
    {
      int i;
    
      /* 定义板载用户 LED 对应的 GPIO 配置 */
      for (i = 0; i < BOARD_NLEDS; i++)
        {
          stm32_configgpio(g_ledcfg[i]);
        }
    
      return BOARD_NLEDS;
    }   
    void board_userled(int led, bool ledon)
    {
      /* 初始化用户 LED 的 GPIO */
      if ((unsigned)led < BOARD_NLEDS)
        {
          stm32_gpiowrite(g_ledcfg[led], ledon);
        }
    }
      
    void board_userled_all(uint32_t ledset)
    {
      int i;
    
      /* Configure LED GPIOs for output */
    
      for (i = 0; i < BOARD_NLEDS; i++)
        {
          stm32_gpiowrite(g_ledcfg[i], (ledset & (1 << i)) != 0);
        }
    }

最终，在 userled_upper.c 实现下面 LED 驱动接口：  

    
    
    static int     userled_open(FAR struct file *filep);
    static int     userled_close(FAR struct file *filep);
    static ssize_t userled_write(FAR struct file *filep, FAR const char *buffer,
                            size_t buflen);
    static int     userled_ioctl(FAR struct file *filep, int cmd,
                             unsigned long arg);

## 4、定义硬件宏

在 src/stm32f407-robomaster.h 和 include/board.h 中定义与硬件相关的宏。

### stm32f407-robomaster.h：板级私有定义

此文件定义了板载外设的 GPIO 引脚和其他私有配置。  

    
    
    /* Configuration ************************************************************/
    
    /* LED.  User LEDR: the red LED is a user LED connected to board LED D12
     * corresponding to MCU I/O PH10.
     *       User LEDG: the green LED is a user LED connected to board LED D12
     * corresponding to MCU I/O PH11.
     *       User LEDB: the blue LED is a user LED connected to board LED D12
     * corresponding to MCU I/O PH13.
     *
     * - When the I/O is HIGH value, the LED is on.
     * - When the I/O is LOW, the LED is off.
     */
    
    #define GPIO_LEDB \
    (GPIO_PORTH | GPIO_PIN10 | GPIO_OUTPUT_SET | GPIO_OUTPUT | GPIO_PULLUP | \
     GPIO_SPEED_50MHz)
    
    #define GPIO_LEDG \
    (GPIO_PORTH | GPIO_PIN11 | GPIO_OUTPUT_SET | GPIO_OUTPUT | GPIO_PULLUP | \
     GPIO_SPEED_50MHz)
     
    #define GPIO_LEDR \
    (GPIO_PORTH | GPIO_PIN12 | GPIO_OUTPUT_SET | GPIO_OUTPUT | GPIO_PULLUP | \
     GPIO_SPEED_50MHz)
    
     /* Buttons
     *
     * B1 USER: the user button is connected to the I/O PA0 of the STM32
     * microcontroller.
     */
    
    #define MIN_IRQBUTTON   BUTTON_USER
    #define MAX_IRQBUTTON   BUTTON_USER
    #define NUM_IRQBUTTONS  (BUTTON_USER + 1)
    
    #define GPIO_BTN_USER \
      (GPIO_INPUT |GPIO_PULLUP |GPIO_EXTI | GPIO_PORTA | GPIO_PIN0)

### include/board.h：公共板级定义

此文件包含被 NuttX 内核和应用共享的板级定义，如时钟配置。  

    
    
    #ifndef __BOARDS_ARM_STM32_STM32F407_ROBOMASTER_INCLUDE_BOARD_H
    #define __BOARDS_ARM_STM32_STM32F407_ROBOMASTER_INCLUDE_BOARD_H
    
    /* 时钟配置宏 */
    #define STM32_BOARD_XTAL        12000000ul
    #define STM32_PLLCFG_PLLM       STM32_PLLCFG_PLLM_DIV(12)
    #define STM32_PLLCFG_PLLN       STM32_PLLCFG_PLLN_MUL(336)
    #define STM32_PLLCFG_PLLP       STM32_PLLCFG_PLLP_DIV(2)
    #define STM32_PLLCFG_PLLQ       STM32_PLLCFG_PLLQ_DIV(7)
    
    /* ...其他公共定义... */
    
    #endif /* __BOARDS_ARM_STM32_STM32F407_ROBOMASTER_INCLUDE_BOARD_H */

# 三、集成到构建系统

完成代码编写后，需要修改构建系统配置，使 openvela 能够识别和编译您的新 BSP。

## 1、Kconfig 集成

Kconfig 用于管理内核和应用的功能配置。您需要执行以下三步来集成新板。

  1. **在 nuttx/boards/Kconfig 中定义板级选项**：

添加一个新的 config 条目，用于在配置菜单中显示您的开发板。  

         
         config ARCH_BOARD_STM32F407_RM
             bool "STM32F407IGH6 ARM Development Board"    
             depends on ARCH_CHIP_STM32F407IG
             select ARCH_HAVE_LEDS
             select ARCH_HAVE_BUTTONS
             select ARCH_HAVE_IRQBUTTONS
             ---help---
                 A configuration for the STM32F407 RoboMaster development board.

  2. **在 nuttx/boards/Kconfig 中设置默认板名：**

当选中您的板型时，让 ARCH_BOARD 变量自动设置为您的 BSP 目录名。  

         
         config ARCH_BOARD
             string
             # ... 其他板的 default 设置 ...
             default "stm32f407-robomaster"      if ARCH_BOARD_STM32F407_RM

  3. **在 nuttx/boards/Kconfig 中加载板级 Kconfig 文件**：

确保选中您的板型时，会加载 BSP 目录下的 Kconfig 文件。  

         
         if ARCH_BOARD_STM32F407_RM
         source "boards/arm/stm32/stm32f407-robomaster/Kconfig"
         endif

  4. **在 stm32f407-robomaster/Kconfig 文件中可以添加此板特有的配置选项。**

我们这里以空框架演示：  

         
         #
         # For a description of the syntax of this configuration file,
         # see the file kconfig-language.txt in the NuttX tools repository.
         #
             
         if ARCH_BOARD_STM32F407_RM
             
         endif # ARCH_BOARD_STM32F407_RM


## 2、创建默认配置 (defconfig)

defconfig 文件是一个最小化的系统配置集合，为用户提供了一个开箱即用的配置起点。您应该为每个核心功能（如 NSH、特定示例）提供一个 defconfig。

nuttx/boards/arm/stm32/stm32f407-robomaster/configs/nsh/ 目录下的 defconfig 如下：  

    
    
    #
    # This file is autogenerated: PLEASE DO NOT EDIT IT.
    #
    # You can use "make menuconfig" to make any modifications to the installed .config file.
    # You can then do "make savedefconfig" to generate a new defconfig file that includes your
    # modifications.
    #
    # CONFIG_ARCH_FPU is not set
    # CONFIG_DISABLE_OS_API is not set
    # CONFIG_NSH_ARGCAT is not set
    # CONFIG_NSH_CMDOPT_HEXDUMP is not set
    # CONFIG_NSH_DISABLE_IFCONFIG is not set
    # CONFIG_NSH_DISABLE_PS is not set
    # CONFIG_STM32_SYSCFG is not set
    CONFIG_ARCH="arm"
    CONFIG_ARCH_BOARD="stm32f407-robomaster"
    CONFIG_ARCH_BOARD_STM32F407_RM=y
    CONFIG_ARCH_CHIP="stm32"
    CONFIG_ARCH_CHIP_STM32=y
    CONFIG_ARCH_CHIP_STM32F407IG=y
    CONFIG_ARCH_INTERRUPTSTACK=2048
    CONFIG_ARCH_STACKDUMP=y
    CONFIG_BOARD_LOOPSPERMSEC=8499
    CONFIG_HAVE_CXX=y
    CONFIG_INIT_ENTRYPOINT="nsh_main"
    CONFIG_INTELHEX_BINARY=y
    CONFIG_LINE_MAX=64
    CONFIG_NSH_FILEIOSIZE=512
    CONFIG_NSH_READLINE=y
    CONFIG_PREALLOC_TIMERS=4
    CONFIG_RAM_SIZE=114688
    CONFIG_RAM_START=0x20000000
    CONFIG_RAW_BINARY=y
    CONFIG_RR_INTERVAL=200
    CONFIG_SCHED_WAITPID=y
    CONFIG_START_DAY=6
    CONFIG_START_MONTH=6
    CONFIG_START_YEAR=2020
    CONFIG_STM32_FLASH_CONFIG_G=y
    CONFIG_STM32_JTAG_SW_ENABLE=y
    CONFIG_STM32_USART6=y
    CONFIG_SYSTEM_NSH=y
    CONFIG_TASK_NAME_SIZE=0
    CONFIG_USART6_SERIAL_CONSOLE=y

> **说明** ：关于 Kconfig 和 defconfig 的更多用法，请参考 [Kconfig 使用指南](</document?id=609&version=dev&language=cn>) 。

# 四、总结

至此，您已经完成了为 RoboMaster C 型开发板移植 openvela 的核心步骤。您创建了一个包含启动逻辑、驱动实现和构建系统集成的完整 BSP。不要忘记在 scripts/ 目录下提供正确的链接器脚本 ld.script 和 Make.defs 文件。

完成所有文件后，您就可以编译并烧录固件。

# 五、后续步骤

成功将 openvela 移植到 C 板后，您可以尝试运行一个应用程序来验证您的工作：

  * **点亮 LED** ：参考[在 STM32F411 上使用 openvela 点亮 LED](</document?id=598&version=dev&language=cn>)的应用层代码，编写一个简单的程序来控制 C 板上的用户 LED。

---

## FC7300F8M-EVB 开发板 openvela 运行指南

> 路径: 开发板 > FC7300F8M-EVB 开发板 openvela 运行指南
> 来源: [https://doc.openvela.com/document?id=851&language=cn&version=dev](https://doc.openvela.com/document?id=851&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/quickstart/development_board/fc7300f8m_evb_guide.md>) | 简体中文 ]

# 一、概述

本指南将指导您在旗芯微 (Flagchip) FC7300F8M-EVB 开发板上，使用 protect 模式编译、构建并运行 openvela 操作系统。

FC7300F8M-EVB 是基于 FC7300F8MDT 芯片的高性能参考板，适用于域控制器、电池管理系统 (BMS) 等场景。

# 二、预期结果

完成本指南的操作后，您将成功启动系统，并通过串口（使用 Minicom 工具）进入 NSH (NuttShell) 交互终端。

![alt text](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455108020_066.png)

# 三、前置准备

请确保您已准备好以下硬件设备，并在开发主机（Ubuntu 环境）上完成软件配置。

## 1、硬件准备

  * **开发板** ：一块 FC7300F8M-EVB 开发板。
  * **调试器** ：SEGGER J-Link 调试器（支持 SWD 模式）。
  * **线缆** ：电源线及 USB 数据线。


## 2、基础环境搭建

请参考官方文档[快速入门（Ubuntu）](</document?id=847&version=dev&language=cn>)，完成环境搭建及源代码下载。

## 3、安装 J-Link 驱动与补丁

为了支持 FC7300 系列芯片，您需要安装 J-Link 驱动并应用特定的设备补丁。

### 步骤 1：安装 JLink 驱动

获取 JLink_Linux_V688a_x86_64.deb 安装包，执行以下命令进行安装：

[下载 JLink_Linux_V688a_x86_64.deb](<https://github.com/open-vela//docs/zh-cn/quickstart/development_board/fc7300f8m_evb_guide.md/jlink/JLink_Linux_V688a_x86_64.deb>)  

    
    
    sudo dpkg -i ./JLink_Linux_V688a_x86_64.deb

### 步骤 2：添加 FC7300 设备支持

获取设备补丁包 JLink_Patch_v2.19.7z，执行以下命令将补丁应用到 J-Link 安装目录。

[下载 JLink_Patch_v2.19.7z](<https://github.com/open-vela//docs/zh-cn/quickstart/development_board/fc7300f8m_evb_guide.md/jlink/JLink_Patch_v2.19.7z>)

**注意** ：请将 <patch_path> 替换为您存放补丁文件的实际路径。  

    
    
    # 1. 解压补丁包
    sudo apt update
    sudo apt install p7zip-full
    7z x JLink_Patch_v2.19.7z
    
    # 2. 拷贝设备定义文件
    sudo cp -rf <patch_path>/JLink_Patch_v2.19/Devices/* /opt/SEGGER/JLink/Devices/
    
    # 3. 更新设备配置文件 (JLinkDevices.xml)
    
    # 场景 A：如果 /opt/SEGGER/JLink/JLinkDevices.xml 文件不存在，执行如下复制命令
    sudo cp -rp /home/mi/XXX/JLink_Patch_v2.19/JLinkDevices.xml  /opt/SEGGER/JLink/JLinkDevices.xml
    
    # 场景 B：如果配置文件已存在
    # 如果 /opt/SEGGER/JLink/JLinkDevices.xml 文件已经存在，请将压缩包中 JLinkDevices.xml 文件中的 <DataBase> 标签内内容，追加到 /opt/SEGGER/JLink/JLinkDevices.xml 文件 <DataBase> 中

# 四、系统构建与运行

本章节将详细介绍如何编译 Bootloader (BL) 和 Core0 系统镜像，并将其烧录至开发板。

## 1、编译项目

进入 openvela 源码根目录，分别构建 Bootloader 和 Core0。

### 步骤 1：编译 Bootloader(BL)
    
    
    ./build.sh vendor/flagchip/boards/fc7300/fc7300f8m-evb/configs/kbl --cmake -j8

### 步骤 2：编译核心系统 (Core0)
    
    
    ./build.sh vendor/flagchip/boards/fc7300/fc7300f8m-evb/configs/kcore0 --cmake -j8

编译成功后，生成的镜像文件将位于以下目录：

  * **BL 镜像** ：./cmake_out/fc7300f8m-evb_kbl

![alt text](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455108115_067.png)

  * **Core0 镜像** ：./cmake_out/fc7300f8m-evb_kcore0

![alt text](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455108217_068.png)


## 2、烧录镜像

您可以选择 .hex 文件（推荐）或 .bin 文件进行烧录。

**方式一：使用 .hex 文件烧录（推荐）**

此方式自带地址信息，无需手动指定烧录地址，操作更安全。  

    
    
    # 烧录 Bootloader
    cd ./cmake_out/fc7300f8m-evb_kbl
    echo "loadfile vela_bl.hex" | sudo JLinkExe -if SWD -device FC7300F8MDTxXxxxT1B -speed 4800 -NoGui 1
    
    # 烧录 Core0 及 User 镜像
    cd ./cmake_out/fc7300f8m-evb_kcore0
    echo "loadfile vela_core0.hex" | sudo JLinkExe -if SWD -device FC7300F8MDTxXxxxT1B -speed 4800 -NoGui 1
    echo "loadfile vela_core0_user.hex" | sudo JLinkExe -if SWD -device FC7300F8MDTxXxxxT1B -speed 4800 -NoGui 1

**方式二：使用 .bin 文件烧录**

需严格指定各镜像的内存起始地址。  

    
    
    # 烧录 Bootloader (地址: 0x01000000)
    cd ./cmake_out/fc7300f8m-evb_kbl
    echo "loadfile vela_bl.bin 0x01000000" | sudo JLinkExe -if SWD -device FC7300F8MDTxXxxxT1B -speed 2500 -NoGui 1                                       
    
    # 烧录 Core0 (地址: 0x01040000) 及 User 镜像 (地址: 0x011C0000)
    cd ./cmake_out/fc7300f8m-evb_kcore0
    echo "loadfile vela_core0.bin 0x01040000" | sudo JLinkExe -if SWD -device FC7300F8MDTxXxxxT1B -speed 2500 -NoGui 1
    echo "loadfile vela_core0_user.bin 0x011C0000" | sudo JLinkExe -if SWD -device FC7300F8MDTxXxxxT1B -speed 2500 -NoGui 1

**注意** ：烧录完成后，请务必**断电重启** 开发板，以确保系统正确加载。

## 3、串口连接与验证

使用 minicom 连接开发板串口，查看启动日志。

  1. 在主机终端执行以下命令（假设设备号为 /dev/ttyUSB0）：

sudo minicom -D /dev/ttyUSB0 -b 115200

  2. 按下开发板上的复位键（Reset）。

  3. 终端将输出启动信息并显示 core0> 提示符，表示系统运行正常。

![alt text](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455108317_069.png)


# 五、常见问题排查 (Troubleshooting)

## Q: Ubuntu 无法识别串口设备 /dev/ttyUSB0

**现象** ：连接开发板后，在 /dev/ 目录下找不到 ttyUSB0 设备，或者设备连接断断续续。

**原因** ：Ubuntu 系统内置的盲文显示驱动 brltty 可能会占用 USB 转串口设备，导致冲突。

**解决方案** ：  

    
    
    sudo apt remove brltty

---

## TC4D9-EVB 开发板 openvela 运行指南

> 路径: 开发板 > TC4D9-EVB 开发板 openvela 运行指南
> 来源: [https://doc.openvela.com/document?id=852&language=cn&version=dev](https://doc.openvela.com/document?id=852&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/quickstart/development_board/tc4d9_evb_guide.md>) | 简体中文 ]

# 一、概述

本指南将指导您在英飞凌 (Infineon) TC4D9-EVB 开发板上完成 openvela 操作系统的编译构建、部署及运行验证。

TC4D9-EVB 基于英飞凌 AURIX™ TC4x 系列微控制器（TC4D9/TC4Z9/TC489），集成了多路 CAN-FD、LIN、以太网、PCIe 等丰富接口，适用于汽车电子及高性能嵌入式系统的开发与原型验证。

# 二、预期效果

完成本指南的操作后，系统将成功启动，您可以通过串口终端（如 MobaXterm）进入 NSH (NuttShell) 进行交互，并支持多核切换。

![alt text](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455108933_060.png)

# 三、前置准备

本流程涉及两个操作环境：**Linux 编译主机** 用于构建代码，**Windows** **主机** 用于工具烧录。

## 1、硬件准备

  * **开发板** ：TC4D9-EVB 开发板。
  * **线缆** ：电源线及 USB 数据线（连接板载调试器接口）。


## 2、编译主机准备 (Ubuntu)

  1. 请在 Ubuntu 环境下，参照官方文档[快速入门（Ubuntu）](</document?id=847&version=dev&language=cn>)，完成 openvela 开发环境搭建和源代码下载。
  2. 打开终端，执行以下命令，更新软件包列表并安装 srecord。  

         
         sudo apt update
         sudo apt install srecord


## 3、烧录主机准备 (Windows)

TC4x 系列的烧录工具链依赖 Windows 环境，请安装以下软件。

  1. 安装 TAS 工具 (Tool Access Socket)。

TAS（Tool Access Socket）是英飞凌推出的一套工具访问中间层软件，用于为上位机开发工具提供统一、抽象的硬件访问接口，是使用烧录工具的前提。

     * 链接：[Infineon TAS](<https://softwaretools.infineon.com/tools/com.ifx.tb.tool.infineontoolaccesssockettas>)
     * **验证安装** ：安装完成后，连接开发板并上电。打开 Windows 设备管理器，若出现 Infineon DAS JDS COM 设备，即表示驱动安装成功。

![alt text](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455109037_061.png)

  2. 安装 AURIX™ Flasher 烧录工具。

用于对 TC4x 系列芯片进行擦除、编程和校验的命令行工具。

     * 下载链接：[AURIX™ Flasher Software Tool](<https://softwaretools.infineon.com/assets/com.ifx.tb.tool.aurixflashersoftwaretool>)
     * **验证安装：** 默认安装在C:\Infineon\AURIXFlasherSoftwareTool-3.0.14目录下，进入该目录查看是否已经安装，如下图所示：

![alt text](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455109149_062.png)

  3. 安装串口终端 MobaXterm。

用于与开发板进行串口通信，下载链接：[MobaXterm_Portable](<https://download.mobatek.net/2542025111600034/MobaXterm_Portable_v25.4.zip>)。


## 4、配置串口连接

  1. 将开发板通过 USB 连接到电脑。
  2. 打开 MobaXterm 软件，点击 Session。
  3. 选择 Serial，建立 **Serial** 会话。
  4. **Port** : 选择对应的 Infineon DAS JDS COM 端口。
  5. **Speed**(bps) : 设置为 115200。
  6. 点击 Advanced Serial settings，将 **Flow control** 为 None。
  7. 点击 **OK** 打开连接。


# 四、系统构建 (Ubuntu)

TC4x 架构包含多个核心，需要分别编译 Bootloader (BL) 和 6 个核心的固件。

## 1、执行编译

进入 openvela 源码根目录，执行以下命令序列：  

    
    
    # 1. 编译 Bootloader
    ./build.sh vendor/infineon/boards/aurix/tc4d9_evb/configs/bl --cmake -j16
    
    # 2. 编译各核心固件 (Core0 - Core5)
    ./build.sh vendor/infineon/boards/aurix/tc4d9_evb/configs/core0 --cmake -j16
    ./build.sh vendor/infineon/boards/aurix/tc4d9_evb/configs/core1 --cmake -j16
    ./build.sh vendor/infineon/boards/aurix/tc4d9_evb/configs/core2 --cmake -j16
    ./build.sh vendor/infineon/boards/aurix/tc4d9_evb/configs/core3 --cmake -j16
    ./build.sh vendor/infineon/boards/aurix/tc4d9_evb/configs/core4 --cmake -j16
    ./build.sh vendor/infineon/boards/aurix/tc4d9_evb/configs/core5 --cmake -j16

## 2、确认编译产物

编译完成后，请在 cmake_out/ 目录下收集以下 **7 个 .hex 文件** ：

  * cmake_out/infineon_tc4d9_evb_bl/vela_bl.hex
  * cmake_out/infineon_tc4d9_evb_core0/vela_core0.hex
  * ... 至 ...
  * cmake_out/infineon_tc4d9_evb_core5/vela_core5.hex


# 五、固件部署 (Windows)

## 1、传输固件

将上述 7 个 .hex 文件从 Ubuntu 主机复制到 Windows 主机的同一目录下（例如 D:\firmware\ 或 AURIXFlasher 安装目录）。

## 2、执行烧录

  1. 确保开发板已上电并通过 USB 连接。
  2. 进入 AURIXFlasher 安装目录（默认为 C:\Infineon\AURIXFlasherSoftwareTool-3.0.14），然后鼠标右键选择在终端打开，如下图所示：

![alt text](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455109254_063.png)

  3. 执行以下命令进行烧录（假设 hex 文件位于当前目录）：

**重要提示** ：必须烧录所有 7 个固件（BL + 6 个 Core），缺失任何一个核心的固件都可能导致系统无法正常启动。  

         
         :: 烧录 Bootloader
         ./AURIXFlasher.exe -hex vela_bl.hex
         
         
         :: 烧录 Core0 - Core5
         ./AURIXFlasher.exe -hex vela_core0.hex
         ./AURIXFlasher.exe -hex vela_core1.hex
         ./AURIXFlasher.exe -hex vela_core2.hex
         ./AURIXFlasher.exe -hex vela_core3.hex
         ./AURIXFlasher.exe -hex vela_core4.hex
         ./AURIXFlasher.exe -hex vela_core5.hex


# 六、运行与验证

## 1、启动系统

所有固件烧录完成后，系统将自动复位启动。

## 2、串口交互

返回 MobaXterm 串口窗口，您将看到启动日志并最终停留在 core0> 提示符，表示 Core0 已就绪。

![alt text](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455109352_064.png)

## 3、多核切换验证

openvela 支持在 NSH 中通过 cu (Call Utility) 命令连接到其他核心的虚拟终端。

  * **切换指令** ：在 core0 中执行 cu -l /dev/ttyCOREx (x 代表核心编号)
  * **退出指令** ：按下 Ctrl + C 返回 Core0。


**示例：切换至 Core2**

输入命令：  

    
    
    cu -l /dev/ttyCORE2

终端提示符将变更为 core2>，如下图所示：

![alt text](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455109448_065.png)

使用 ctrl + c 命令可以返回 core0。

---

