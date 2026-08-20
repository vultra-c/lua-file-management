---
name: "xiaomi-quickapp-dev"
description: "小米 Vela JS 快应用（Quick App）官方开发文档参考：从快速入门到开发指南、系统/数据/网络等接口 API、基础/容器/表单组件、开发调试工具链、设计规范、最佳实践与版本发布。当用户开发 Vela 快应用或查询 .ux / manifest.json 用法时加载本 skill。"
---

# 小米 Vela 快应用（Quick App）开发

本 skill 内置小米 Vela JS 快应用的官方开发文档。使用前先判断用户问题落在哪个环节（项目结构、接口、组件、工具、规范），再读取 `references/` 中对应文件。

## 参考文档路由

| 用户意图 / 子主题 | 读取文件 |
|---|---|
| 初学者入门、工程目录、项目概览、应用开发全流程 | `references/mi_quickapp_快应用_开发指南.md` |
| 接口 API：能力检测、基础能力 | `references/mi_quickapp_快应用_接口_基础.md` |
| 接口 API：系统能力（设备、存储等） | `references/mi_quickapp_快应用_接口_系统.md` |
| 接口 API：数据（本地 / 云数据存储） | `references/mi_quickapp_快应用_接口_数据.md` |
| 接口 API：网络请求与连接 | `references/mi_quickapp_快应用_接口_网络.md` |
| 接口 API：安全、隐私与其他能力 | `references/mi_quickapp_快应用_接口_安全与其他.md` |
| 组件：通用属性与基础组件 | `references/mi_quickapp_快应用_组件_通用.md`、`references/mi_quickapp_快应用_组件_基础组件.md` |
| 组件：容器组件（布局类） | `references/mi_quickapp_快应用_组件_容器组件.md` |
| 组件：表单组件（输入、控件类） | `references/mi_quickapp_快应用_组件_表单组件.md` |
| 工具链：入口、IDE 使用 | `references/mi_quickapp_快应用_工具_入门.md`、`references/mi_quickapp_快应用_工具_开发.md` |
| 调试、模拟器与真机调试 | `references/mi_quickapp_快应用_工具_调试.md`、`references/mi_quickapp_快应用_工具_模拟器与设备调试.md` |
| 构建打包、签名与发布流程 | `references/mi_quickapp_快应用_工具_工具链与发布.md`、`references/mi_quickapp_快应用_发布与版本.md` |
| 多屏 / 交互设计规范 | `references/mi_quickapp_快应用_设计规范.md` |
| 开发最佳实践、性能与体验优化 | `references/mi_quickapp_快应用_最佳实践.md` |
| 其他补充说明 | `references/mi_quickapp_快应用_其他.md` |

## 使用原则

- 每个参考文件内含多篇子文档，按其章节标题定位到具体小节，避免整篇引用。
- 涉及组件写法（`.ux` 模板）、`manifest.json` 配置、接口回调时，直接引用文件中的代码示例。
- 文件内图片或站内相对链接如无法解析，则以文字内容作答，不臆造代码。
- 接口签名、属性、事件名以官方文档原文为准。