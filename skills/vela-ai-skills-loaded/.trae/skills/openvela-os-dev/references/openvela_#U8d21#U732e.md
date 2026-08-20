# 贡献

> 来源: openvela官方
> 共 4 篇文档

---

## 贡献代码

> 路径: 贡献代码
> 来源: [https://doc.openvela.com/document?id=772&language=cn&version=dev](https://doc.openvela.com/document?id=772&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//CONTRIBUTING.md>) | 简体中文 ]

openvela 由一支活跃的软件工程师和研究人员团队开发。欢迎你加入 openvela 开源社区，为改进此项目做出任何贡献！

openvela 主要遵循 Apache License 2.0 许可证，具体请参看 LICENSE 文件。

# 签署贡献者许可协议 (CLA)

为了参与社区贡献，首次提交代码时，需要签署相应的**贡献者许可协议（Contributor License Agreement, CLA）** 。以下是针对不同平台的具体步骤：

  * **Gitee 平台** :

    * 请访问 [Gitee CLA 签署页面](<https://gitee.com/organizations/open-vela/cla/zs6b7c48u6juka2tsnrnkzx6k88np85e>) 完成签署。
    * 您可以通过 [我签署的 CLA](<https://gitee.com/profile/clas>) 查看签署状态。
  * **GitHub 平台** :

    * 在提交新的 Pull Request (PR) 后，系统会提示您完成 CLA 的签署。请根据提示操作以完成签署流程。


# 错误报告

如果您认为在 openvela 中发现了错误，请首先确保您已使用了最新版本的 openvela 进行了测试（您的问题可能已得到修复）。

如果未解决，请搜索问题列表，查看是否已有类似的问题。

# 功能请求

请提交一个 Issue，描述您希望添加的功能、您需要它的原因以及预期的工作方式。

# 提交代码

如果您想给 openvela 增加新功能或者修复一些错误，先确认是否已有类似的问题。如果没有，请您新建一个问题，和大家讨论您的想法。

## 分支策略

  * **trunk** ：**trunk** 分支不接受 pull request。
  * **dev** ：从 **dev** 分支 fork 代码，并推送 pull request。


## 提交代码前的准备工作

在创建新的 Pull Request 之前，请遵循以下指南。这将有助于加快代码的审核与合入周期。

  * **遵循代码风格规范** ：确保您的代码提交符合 [openvela 代码风格检查指南](</document?id=774&version=dev&language=cn>)。在提交前运行本地检查，可以有效避免在持续集成 (CI) 流程中出现不必要的失败。
  * **添加许可证头部** ：为所有新增的文件添加标准的许可证头部信息。
  * **补充单元测试** ：为您的代码变更添加必要且充分的单元测试，以验证其正确性。
  * **补充集成测试** ：如果您的变更涉及多个模块的交互，请添加相应的集成测试。
  * **保持提交的原子性** ：请勿修改与本次变更无关的代码。一次提交应聚焦于一个独立的功能或修复，避免混合不相关的格式化调整或代码重排。


## 提交您的更改

### 1 测试您的更改

请运行测试套件以确保没有出现任何问题。 

### 2 签署贡献者许可协议

**首次提交需完成** ：签署贡献者许可协议，请参考[签署贡献者许可协议 (CLA)](<#一签署贡献者许可协议-cla>)章节。

### 3 提交代码

  1. 检查当前状态。  

         
         # 查看工作区状态
         git status

  2. 暂存更改。  

         
         # 添加特定文件到暂存区
         git add path/to/changed/file.cpp
         # 或添加所有更改
         git add .

  3. 提交更改。  

         
         # 创建提交
         git commit -m "简明扼要的提交信息"
         # 或使用详细提交信息
         git commit

  4. 配置上游仓库。  

         
         # 显示现有远程仓库地址
         git remote -v
         
         # 添加上游远程仓库引用（仅首次需要执行）
         git remote add upstream git@github.com:open-vela/[repository].git
         
         # 显示现有远程仓库地址（应包含origin和upstream）
         git remote -v

  5. 获取最新代码并变基。  

         
         # 获取上游仓库的最新代码
         git fetch upstream
         
         # 将当前分支变基到最新主分支
         git rebase upstream/dev

  6. 解决冲突（如有）。  

         
         # 检测冲突状态（推荐）  
         git status                   
         # 编辑冲突文件（如 conflict.cpp），可使用任何编辑器，如nano、vim、VSCode等
         nano conflict.cpp            
         # 标记为已解决  
         git add conflict.cpp  
         
         # 解决所有冲突后继续变基操作
         git rebase --continue
         
         # 确认变基完成状态
         git status

  7. 强制推送更新：  

         
         # 强制推送更新后的分支到您的远程仓库
         git push --force origin dev


### 4 创建合入请求

  1. 访问 GitHub 上您的 fork 仓库。

  2. 单击 **New pull request** 按钮。

  3. 单击 **Create pull request** 创建合入请求。

  4. 填写合入请求信息。


### 5 合入请求后续工作

  * 保持关注合入请求的评审意见。
  * 及时响应评审者的反馈。
  * 如需修改，在同一分支上进行更改并推送。

---

## 贡献文档

> 路径: 贡献文档
> 来源: [https://doc.openvela.com/document?id=773&language=cn&version=dev](https://doc.openvela.com/document?id=773&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/contribute/process/doc_dev_process.md>) | 简体中文 ]

# 流程图

![documentation_development_process](https://vela-open-doc.cnbj1.mi-fds.com/vela-open-doc/1779455191883_001.png)

# 一、开发工程师要做的

## 1、开发文档

如果你负责开发某一特性，你需要与文档团队一起配合，确保在版本发布之前完成该特性所配套文档的开发。否则，未提供配套文档的特性在发布时可能被移除。

  * 联系[文档团队资料作者](<https://github.com/open-vela/docs/tree/dev//zh-cn/contribute/process/doc_reviewer.md>)，讨论文档设计。
  * 参考[文档写作模板](<https://github.com/open-vela//docs/zh-cn/contribute/process/template>)进行配套文档的写作。
  * 为功能特性撰写详细的文档初稿，提交 PR 并在描述中提供对应的需求 Issue 链接。


## 2、提交PR评审

  * 提交 PR 后，会自动指定技术专家和资料专家进行评审。
  * 技术专家审核后给出 Approve 的结论。
  * 资料专家审核后给出 DocsApprove 的评论。


## 3、提交测试

  * 文档随版本转测试后，文档工程师会对文档进行测试。
  * 测试过程中发现的文档问题，以 Issue 形式提交到 Docs 仓，对应文档作者闭环确认测试意见并完成文档修改。


## 4、提交翻译

  * 建议自行翻译。
  * 如需文档团队翻译，请在中文文档完成评审测试定稿后提交翻译需求。提交翻译需求时请配套提供以下信息：

    * 新增术语请补充至[术语表](</document?id=584&version=dev&language=cn>)。
    * 英文截图。


# 二、文档工程师要做的

## 1、评审文档

### 内容易理解

  * 逻辑准确，术语一致。
  * 步骤清晰，有效指导开发者完成相关任务开发
  * 图文结合，避免只有大量篇幅的文字描述。


### 整体信息架构

  * 新增 Markdown 页面时，需确保：

    * 该页面内容使用了正确的内容模板。
  * 变更 Markdown 页面时，需确保：

    * 该页面对社区其他内容链接未产生影响，建议本地进行检查。


## 2、测试文档

文档工程师对文档进行测试，测试过程中发现的文档问题，以 Issue 形式跟踪，对应文档作者闭环确认测试意见并完成文档修改。

## 3、翻译文档

完成核心文档的翻译需求。

---

## 代码风格检查指南

> 路径: 代码风格检查指南
> 来源: [https://doc.openvela.com/document?id=774&language=cn&version=dev](https://doc.openvela.com/document?id=774&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//en/contribute/code_style_check_guide.md>) | 简体中文 ]

# 概述

本文档描述了如何使用 **clang-format** 工具进行代码风格检查，包括默认配置文件存在和不存在的情况下的检查方法。

# 检查流程

根据项目中是否存在 .clang-format 配置文件，执行不同的检查命令。

> **说明** ：openvela 项目使用 **clang-format 14** 版本进行代码风格检查。

## 场景一：使用默认配置文件检查

当项目中存在默认的代码风格配置文件 .clang-format 时：  

    
    
    clang-format -n <filepath> --Werror

## 参数说明

  * -n：仅检查，不修改文件。
  * \--Werror：将格式警告视为错误。


## 场景二：使用 WebKit 风格检查

当项目中不存在默认的代码风格配置文件时：  

    
    
    clang-format --style=WebKit -n <filepath> --Werror

## 参数说明

  * -n：仅检查，不修改文件。
  * \--Werror：将格式警告视为错误。
  * \--style=WebKit：使用 WebKit 预定义的代码风格。

---

## 第三方开源软件说明

> 路径: 第三方开源软件说明
> 来源: [https://doc.openvela.com/document?id=775&language=cn&version=dev](https://doc.openvela.com/document?id=775&language=cn&version=dev)

[ [English](<https://github.com/open-vela/docs/tree/dev//Third_Party_and_Open_Source_Components.md>) | 简体中文 ]

**组件** | **License** | **是否有修改** | **开源代码地址**  
---|---|---|---  
libsodium | ISC License | 否 | https://github.com/jedisct1/libsodium  
minmea | MIT License | 是 | https://github.com/kosma/minmea  
libyuv | BSD-3-Clause | 否 | https://chromium.googlesource.com/libyuv  
lvgl | MIT License | 是 | https://github.com/lvgl/lvgl  
lua | MIT License | 否 | https://github.com/lua/lua  
cJSON | MIT License | 是 | https://github.com/DaveGamble/cJSON  
MQTT-C | MIT License | 否 | https://github.com/LiamBindle/MQTT-C  
microADB | Apache License 2.0 | 是 | https://github.com/spiriou/microADB  
argtable3 | BSD-3-Clause | 否 | https://github.com/argtable/argtable3  
libuv | MIT License | 是 | https://github.com/libuv/libuv  
Unity | MIT License | 否 | https://github.com/ThrowTheSwitch/Unity  
aac | Fraunhofer FDK AAC License | 是 | https://github.com/mstorsjo/fdk-aac  
avb | Apache License 2.0 | 是 | https://android.googlesource.com/platform/external/avb/  
bzip2 | BSD | 否 | https://sourceware.org/bzip2/  
cAT | MIT License | 是 | https://github.com/marcinbor85/cAT  
Chipmunk2D | MIT License | 是 | http://chipmunk2d.net https://github.com/slembcke/Chipmunk2D  
cmocka | Apache License 2.0 | 是 | https://gitlab.com/cmocka/cmocka  
cmsis | Apache License 2.0 | 是 | https://github.com/ARM-software/CMSIS_5  
coremark | Apache License 2.0 | 是 | https://github.com/eembc/coremark  
curl | MIT License | 是 | https://curl.se https://github.com/curl/curl  
zlib | Zlib | 是 | http://www.zlib.org https://github.com/madler/zlib  
ddelta | BSD | 是 | https://github.com/julian-klode/ddelta  
dlg | BSL-1.0 | 否 | https://github.com/nyorain/dlg  
enet | MIT License | 否 | https://github.com/lsalzman/enet  
freetype | FreeType License | 是 | https://github.com/freetype/freetype  
googlebenchmark | Apache License 2.0 | 是 | https://github.com/google/benchmark  
googletest | BSD-3-Clause | 是 | https://google.github.io/googletest/  
inipp | MIT License | 否 | https://github.com/mcmtroffaes/inipp  
iperf2 | MIT License | 否 | https://github.com/esnet/iperf  
iperf3 | MIT License | 是 | https://github.com/esnet/iperf  
json-c | BSD-3-Clause | 否 | https://github.com/json-c/json-c  
lc3 | Apache License 2.0 | 是 | https://www.bluetooth.com/specifications/specs/low-complexity-communication-codec-1-0/  
libdivide | Zlib | 是 | https://github.com/ridiculousfish/libdivide  
libexpat | MIT License | 否 | https://github.com/libexpat/libexpat  
libfluoride-sbc | Apache License 2.0 | 否 | https://github.com/artem/libldac  
libpng | libpng-2.0 | 是 | https://github.com/pnggroup/libpng  
libtar | University of Illinois/NCSA Open Source License | 是 | https://repo.or.cz/w/libtar.git  
mbedtls | Apache License 2.0 | 是 | https://github.com/Mbed-TLS/mbedtls  
nanopb | Zlib | 否 | https://github.com/nanopb/nanopb  
Ne10 | BSD-3-Clause | 是 | https://github.com/projectNe10/Ne10  
nghttp2 | MIT License | 否 | https://github.com/nghttp2/nghttp2  
nng | MIT License | 是 | https://github.com/nanomsg/nng  
opus | BSD-3-Clause | 是 | https://opus-codec.org/ https://gitlab.xiph.org/xiph/opus  
protobuf-c | BSD-2-Clause | 否 | https://github.com/protobuf-c/protobuf-c  
quirc | ISC License | 是 | https://github.com/dlbeer/quirc  
rtos-benchmark | Apache License 2.0 | 是 | https://github.com/zephyrproject-rtos/rtos-benchmark  
thorvg | MIT License | 否 | https://github.com/thorvg/thorvg  
tinyxml2 | zlib License | 是 | https://github.com/leethomason/tinyxml2  
unqlite | Apache License 2.0 | 是 | https://github.com/symisc/unqlite  
dhara | ISC License | 否 | https://github.com/dlbeer/dhara  
fatfs | FatFs License(BSD style) | 是 | http://elm-chan.org/fsw/ff/00index_e.html  
littlefs | BSD-3-Clause | 是 | https://github.com/littlefs-project/littlefs  
libsamplerate | BSD-2-Clause | 否 | https://github.com/libsndfile/libsamplerate  
openlibm | MIT License | 是 | https://github.com/JuliaMath/openlibm  
libcxx | Apache License 2.0 | 是 | https://github.com/llvm/llvm-project/tree/main/libcxx  
libcxxabi | MIT License | 是 | https://itanium-cxx-abi.github.io/cxx-abi  
tlsf | BSD | 否 | https://github.com/mattconte/tlsf  
libmetal | Apache License 2.0 | 是 | https://github.com/OpenAMP/libmetal  
open-amp | Apache License 2.0 | 是 | https://github.com/OpenAMP/open-amp  
apps | Apache License 2.0 | 是 | https://github.com/apache/nuttx-apps  
nuttx | Apache License 2.0 | 是 | https://github.com/apache/nuttx  
kmgk | Apache License 2.0 | 是 | https://github.com/linaro-swg/kmgk  
optee_client | BSD 2-clause | 是 | https://github.com/OP-TEE/optee_client  
optee_examples | BSD 2-clause | 否 | https://github.com/linaro-swg/optee_examples  
optee_os | BSD 2-Clause | 是 | https://github.com/OP-TEE/optee_os  
nist-sts | [License](<https://unlicense.org/>) | 是 | https://github.com/terrillmoore/NIST-Statistical-Test-Suite  
libtomcrypt | LibTom | 是 | https://github.com/libtom/libtomcrypt  
test-tlb | GPL-2.0 | 是 | https://github.com/torvalds/test-tlb  
tinycrypt | BSD 2-Clause | 是 | https://github.com/intel/tinycrypt  
unpv13e | [License](<https://github.com/unpbook/unpv13e/blob/master/LICENSE>) | 否 | https://github.com/unpbook/unpv13e  
wasm-micro-runtime | Apache License 2.0 | 是 | https://github.com/bytecodealliance/wasm-micro-runtime  
gemmlowp | Apache License 2.0 | 否 | https://github.com/google/gemmlowp  
kissfft | BSD-3-Clause | 否 | https://github.com/mborgerding/kissfft  
libtommath | LibTom | 否 | https://github.com/libtom/libtommath  
ruy | Apache License 2.0 | 否 | https://github.com/google/ruy  
CMSIS-NN | Apache License 2.0 | 否 | https://github.com/ARM-software/CMSIS-NN  
tflite-micro | Apache License 2.0 | 是 | https://github.com/tensorflow/tflite-micro  
connectedhomeip | Apache License 2.0 | 是 | https://github.com/project-chip/connectedhomeip  
nlassert | Apache License 2.0 | 否 | https://github.com/nestlabs/nlassert  
nlio | Apache License 2.0 | 否 | https://github.com/nestlabs/nlio  
nlunit-test | Apache License 2.0 | 否 | https://github.com/nestlabs/nlunit-test  
pigweed | Apache License 2.0 | 否 | https://github.com/google/pigweed  
jsoncpp | MIT License | 是 | https://github.com/open-source-parsers/jsoncpp  
flatbuffers | Apache License 2.0 | 否 | https://github.com/google/flatbuffers  
fff | MIT License | 否 | https://github.com/meekrosoft/fff  
libc-test | MIT License | 否 | https://github.com/AssemblyScript/libc-test  
ltp | GPL-2.0 | 是 | https://github.com/linux-test-project/ltp  
stressapptest | Apache License 2.0 | 是 | https://github.com/stressapptest/stressapptest  
abseil-cpp | Apache License 2.0 | 否 | https://github.com/abseil/abseil-cpp  
native | Apache License 2.0 | 是 | https://android.googlesource.com/platform/frameworks/native/  
interfaces | Apache License 2.0 | 否 | https://android.googlesource.com/platform/hardware/interfaces/  
libhardware | Apache License 2.0 | 否 | https://android.googlesource.com/platform/hardware/libhardware/  
chre | Apache License 2.0 | 是 | https://android.googlesource.com/platform/system/chre/  
core | Apache License 2.0 | 是 | https://android.googlesource.com/platform/system/core  
keymaster | Apache License 2.0 | 是 | https://android.googlesource.com/platform/system/keymaster  
libbase | Apache License 2.0 | 是 | https://android.googlesource.com/platform/system/libbase  
libcppbor | Apache License 2.0 | 是 | https://android.googlesource.com/platform/system/libcppbor  
libfmq | Apache License 2.0 | 否 | https://android.googlesource.com/platform/system/libfmq  
libhidl | Apache License 2.0 | 是 | https://android.googlesource.com/platform/system/libhidl  
libhwbinder | Apache License 2.0 | 是 | https://android.googlesource.com/platform/system/libhwbinder  
logging | Apache License 2.0 | 否 | https://android.googlesource.com/platform/system/logging  
security | Apache License 2.0 | 是 | https://android.googlesource.com/platform/system/security  
aidl | Apache License 2.0 | 是 | https://android.googlesource.com/platform/system/tools/aidl  
hidl | Apache License 2.0 | 是 | https://android.googlesource.com/platform/system/tools/hidl  
atomic_queue | MIT License | 是 | https://github.com/max0x7ba/atomic_queue  
auto-pts | GPL-2.0 | 是 | https://github.com/auto-pts/auto-pts  
c-ares | MIT License | 是 | https://github.com/c-ares/c-ares  
cmark-gfm | MIT License | 是 | https://github.com/github/cmark-gfm  
cpuid | ISC | 否 | https://github.com/tycho/cpuid  
dbus | GPL-2.0 | 是 | https://gitlab.freedesktop.org/dbus/dbus  
erpc | BSD-3-clause | 是 | https://github.com/EmbeddedRPC/erpc  
exfatprogs | GPL-2.0 | 是 | https://github.com/namjaejeon/exfatprogs  
fluoride | Apache License 2.0 | 是 | https://github.com/anchao/fluoride  
fmt | MIT License | 是 | https://github.com/fmtlib/fmt  
freetype | freetype license | 是 | https://gitlab.freedesktop.org/freetype/freetype  
dlg | Boost Software License - Version 1.0 | 否 | https://github.com/nyorain/dlg  
glib | LGPL-2.1 | 是 | https://github.com/GNOME/glib  
gvdb | LGPL-2.1 | 否 | https://github.com/GNOME/gvdb  
harfbuzz | "Old MIT" license | 否 | https://github.com/harfbuzz/harfbuzz  
ldns | Apache License 2.0 | 是 | https://github.com/NLnetLabs/ldns  
modp_b64 | BSD License | 否 | https://chromium.googlesource.com/chromium/src/third_party/modp_b64  
libhelix-aac | Apache License 2.0 | 是 | https://github.com/pschatzmann/arduino-libhelix/tree/main/src/libhelix-aac  
libhelix-mp3 | Apache License 2.0 | 是 | https://github.com/pschatzmann/arduino-libhelix/tree/main/src/libhelix-mp3  
libjpeg-turbo | libjpeg-turbo license | 是 | https://github.com/libjpeg-turbo/libjpeg-turbo  
libldac | Apache License 2.0 | 是 | https://android.googlesource.com/platform/external/libldac/  
opencore-amr | Apache License 2.0 | 是 | https://sourceforge.net/projects/opencore-amr/  
libssh-mirror | BSD 2-Clause | 是 | https://gitlab.com/libssh/libssh-mirror/  
libtar | BSD | 是 | https://repo.or.cz/libtar.git  
libwebp | BSD-3-Clause license | 是 | https://chromium.googlesource.com/webm/libwebp  
lz4 | BSD | 是 | https://github.com/lz4/lz4  
mdns | [License](<https://github.com/mjansson/mdns/blob/main/LICENSE>) | 是 | https://github.com/mjansson/mdns  
mmc-utils | GPL-2.0 | 是 | https://git.kernel.org/pub/scm/utils/mmc/mmc-utils.git  
mtp-responder | Apache License 2.0 | 是 | https://review.tizen.org/git/?p=framework/connectivity/mtp-responder.git  
ofono | GPL-2.0 license | 是 | https://github.com/ubports/ofono  
ell | LGPL-2.1 license | 是 | https://github.com/bryanperris/ell  
protobuf | [License](<https://github.com/protocolbuffers/protobuf/blob/main/LICENSE>) | 否 | https://github.com/protocolbuffers/protobuf  
rapidjson | MIT License | 是 | https://github.com/Tencent/rapidjson  
ril | Apache License 2.0 | 是 | https://android.googlesource.com/platform/hardware/ril/+/refs/tags/android-7.0.0_r7  
rlottie | LGPL-v2.1 license | 否 | https://github.com/TelegramMessenger/rlottie  
silk-v3-decoder | Apache License 2.0 | 是 | https://github.com/kn007/silk-v3-decoder  
sqlite | BSD | 否 | https://github.com/sqlite/sqlite  
stress | GPL-2.0 | 是 | https://github.com/resurrecting-open-source-projects/stress  
sysklogd | GPL-2.0 | 是 | https://github.com/troglobit/sysklogd  
sil-kit | MIT License | 否 | https://github.com/vectorgrp/sil-kit  
sil-kit-adapters-qemu | MIT License | 否 | https://github.com/vectorgrp/sil-kit-adapters-qemu  
sil-kit-adapters-vcan | MIT License | 否 | https://github.com/vectorgrp/sil-kit-adapters-vcan  
yoga | MIT License | 否 | https://github.com/facebook/yoga  
zblue | Apache License 2.0 | 是 | https://github.com/zephyrproject-rtos/zephyr  
zint | GPL-3.0 | 否 | https://github.com/zint/zint  
nuttx | Apache License 2.0 | 是 | https://github.com/apache/nuttx  
SEGGER_SystemView | [License](<https://github.com/RT-Thread-packages/SEGGER_SystemView/blob/master/SystemView_Src/License_SystemView.txt>) | 否 | https://github.com/RT-Thread-packages/SEGGER_SystemView  
dtc | GPL-2.0 | 否 | https://github.com/dgibson/dtc  
libmcs | SPDX | 否 | https://gitlab.com/gtd-gmbh/libmcs  
newlib | LGPL | 否 | https://sourceware.org/pub/newlib  
libstdc++ | GPL-2.0 | 否 | https://github.com/gcc-mirror/gcc/tree/master/libstdc%2B%2B-v3/libsupc%2B%2B  
uClibc++ | LGPL-2.1 | 否 | [https://cxx.uclibc.org/src/](<https://git.busybox.net/uClibc++>)  
tlsf | BSD | 是 | https://github.com/mattconte/tlsf  
X-TRACK | MIT License | 否 | https://github.com/FASTSHIFT/X-TRACK  
wamr | Apache License 2.0 | 否 | https://github.com/bytecodealliance/wasm-micro-runtime  
libopencore-amr | Apache License 2.0 | 是 | https://github.com/BelledonneCommunications/opencore-amr/blob/master  
kconfig-frontends | GPL-2.0 | 是 | https://bitbucket.org/nuttx/tools/src/master/kconfig-frontends/  
FFmpeg | LGPL v2.1+ | 是 | https://github.com/FFmpeg/FFmpeg.git

---

