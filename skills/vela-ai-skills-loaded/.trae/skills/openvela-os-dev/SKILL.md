---
name: "openvela-os-dev"
description: "openvela 操作系统官方开发文档参考：环境搭建、应用开发、设备开发、调试测试、芯片移植与开放 API。当用户涉及 openvela / AIoT 系统相关问题（架构、编译、移植、驱动、调试）需查阅官方资料时加载本 skill。"
---

# openvela 操作系统开发

本 skill 内置 openvela（小米开源 AIoT 操作系统）官方开发文档。使用前先确定用户的子主题，再读取 `references/` 下对应的原始文档；回答时优先以官方接口签名、编译命令和示例为准。

## 参考文档路由

| 用户意图 / 子主题 | 读取文件 |
|---|---|
| 系统简介、技术架构、内核、定位 | `references/openvela_了解 openvela.md` |
| 环境搭建、源码下载、编译构建、模拟器运行（快速入门） | `references/openvela_快速入门.md` |
| 应用（上层软件）开发 | `references/openvela_应用开发.md` |
| 设备（驱动 / 硬件适配）开发 | `references/openvela_设备开发.md` |
| 调试方法、日志、故障排查 | `references/openvela_调试.md` |
| 测试开发、用例编写 | `references/openvela_测试开发.md` |
| 芯片移植、新平台适配 | `references/openvela_芯片移植.md` |
| 社区贡献、代码规范、提交流程 | `references/openvela_贡献.md` |
| 开放能力 / API 参考 | `references/openvela_API 参考.md` |
| 常见问题 FAQ | `references/openvela_FAQ.md` |

## 使用原则

- 每个参考文件内部可能包含多篇子文档，按文件内的章节标题定位所需小节，勿整篇照搬。
- 若问题跨多个主题（如设备开发中的编译报错），可读取多个相关文件交叉核对。
- 文档中以内联图片或相对链接（如 `</docs/vela/...>`）形式的资源，如无法直接解析，则依据文字内容作答，不臆造缺失信息。
- 回答命名的接口、编译命令、配置项时，引用数据以官方文档原文为准。