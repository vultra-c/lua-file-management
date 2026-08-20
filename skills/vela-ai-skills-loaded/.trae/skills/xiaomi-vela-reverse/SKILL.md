---
name: "xiaomi-vela-reverse"
description: "洛汐非官方 Xiaomi Vela 逆向参考文档：快应用私有/补充接口（Features 与 Extensions）、Lua 表盘开发、系统文件与设备节点、实用工具、弦应用（Sine）。当用户需要调用未公开接口、开发 Lua 表盘、或排查 Vela 系统文件与工具时加载本 skill。"
---

# Xiaomi Vela 非官方逆向参考

本 skill 内置「洛汐文档库」整理的 Xiaomi Vela（穿戴设备）非官方逆向文档。注意：这是基于公开源码、固件与设备资源整理的参考，非官方承诺。使用前先判断子主题，再读取 `references/` 对应文件。

## 参考文档路由

| 用户意图 / 子主题 | 读取文件 |
|---|---|
| 文档总览、阅读方式、免责声明 | `references/luoxe_Vela_概览.md`、`references/luoxe_开始阅读.md` |
| 快应用接口：官网接口的补充能力（Features，如 health / 系统 service） | `references/luoxe_Vela_快应用接口_Features.md` |
| 快应用接口：扩展能力（Extensions，如 brightness / device / sensor） | `references/luoxe_Vela_快应用接口_Extensions.md` |
| Lua 表盘开发（表盘结构、生命周期、dataman/topic/animengine、LVGL 控件与样式） | `references/luoxe_Vela_Lua_表盘.md` |
| 系统与工具（ROMFS /etc、/dev 节点、/data 结构、截屏等） | `references/luoxe_Vela_系统与工具.md` |
| 弦应用 Sine（特定应用 / 能力） | `references/luoxe_弦应用_Sine.md` |

## 使用原则

- 本套文档为逆向参考：接口可能随系统升级而变化，且机型可用性不同（详见各文件内的可用性表）。
- 快应用接口调用建议遵循「先 `app.canIUse('@feature.method')` 探测、再调用」的做法；Lua 表盘模块用 `pcall(require, 'module')` 探测。
- 写代码示例时保留文件中给出的模块名、参数、返回值与可用性提示；涉及设备故障、数据丢失等风险，请按文档免责声明向用户提示。
- 文件内相对链接或资源如无法解析，则以文字内容作答，不臆造接口。