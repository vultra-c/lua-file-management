# 快应用_工具_工具链与发布

> 来源: 小米快应用官方
> 共 4 篇文档

---

## #AIoT-toolkit

> 来源: [https://iot.mi.com/vela/quickapp/zh/tools/toolkit/start.html](https://iot.mi.com/vela/quickapp/zh/tools/toolkit/start.html)

# [#](<#aiot-toolkit>) AIoT-toolkit

开发者在开发`Xiaomi Vela JS 应用`项目时，`AIoT-IDE`主要通过项目模板中内置的`AIoT-toolkit`完成项目的编译构建任务，得到构建文件（以 rpk 后缀命名，如：com.application.demo.rpk）。

## [#](<#功能支持>) 功能支持

`AIoT-toolkit`是将**源码项目** 转换为**目标代码项目** 并生成**目标代码应用** 的`命令行工具`，同时配备了 模拟器 相关功能供开发者使用。`AIoT-toolkit`提供了脱离`AIoT-IDE`，独立开发`Xiaomi Vela JS` 应用的能力。在不使用`AIoT-IDE`的情况下，可以完全通过`AIoT-toolkit`使用命令行工具进行开发，目前最新的**AIoT-toolkit2.0** 有以下常用命令：

  * 创建项目：**npm create aiot**
  * 直接运行：**aiot start** ，第一次运行会提示创建的模拟器，根据提示操作即可
  * 构建项目，生成rpk： **aiot build**
  * 构建项目-release模式：**aiot release**
  * 获取已连接设备列表: **aiot getConnectedDevices**
  * 获取设置平台：**aiot getPlatforms**
  * 创建`Xiaomi Vela JS`模拟器：**aiot crateVelaAvd**
  * 删除`Xiaomi Vela JS`模拟器：**aiot deleteVelafangAvd**


## [#](<#版本支持>) 版本支持

目前`AIoT-IDE`支持**AIoT-toolkit1.0** ，和**AIoT-toolkit2.0** ，对**AIoT-toolkit1.0** 的支持最小版本为`1.0.18`，对**AIoT-toolkit2.0** 的支持最小版本为`2.0.x`。当前最新的`AIoT-IDE`**1.6.0** 版本，推荐使用**2.0** ，**2.0** 提供了更快的编译速度和热更新支持，将给开发者提供更好的开发体验。

`AIoT-IDE`在打开一个`Xiaomi Vela JS`应用时，会主动检测**AIoT-toolkit** 版本，当前项目使用的是**AIoT-toolkit1.0时** 会提示你可以升级并查看迁移文档，如下图**标签1** 所示：

![alt text](/vela/quickapp/images/tools/ide-toolkit-1.png)

如果你项目中使用了**AIoT-toolkit2.0** ，但不是当前`AIoT-IDE`支持的最小正式版本，则会强制提示你升级。如下图**标签1** 所示：

![alt text](/vela/quickapp/images/tools/ide-toolkit-2.png)

## [#](<#功能优化>) 功能优化

对比**AIoT-toolkit1.0** ，**AIoT-toolkit2.0** 有以下重大改进：  
1.模板语法中可以直接写复杂函数
    
    
    <div 
        id="{{(x=> x+ y)(1)}}" 
        onclick="(evt)=>{
           const x = 10;
           return sum(x, evt, y)
        }">
    </div>
    

2.class的变量可以包含多个类名(之前每个变量只能包含1个类名)
    
    
    class="a {{x}}"  // x="a1 a2 a3"
    

3.style可以是string，也可以是object(之前只是object)
    
    
     <div style="a{{b}}c">
    
     </div>
    

4.样式顺序可以随意写(之前必须按固定顺序)
    
    
     border: solid red 10px; 
    

5.错误提示定位到行列 ![alt text](/vela/quickapp/images/tools/ide-toolkit-3.png)

---

## #升级迁移

> 来源: [https://iot.mi.com/vela/quickapp/zh/tools/toolkit/update.html](https://iot.mi.com/vela/quickapp/zh/tools/toolkit/update.html)

# [#](<#升级迁移>) 升级迁移

相较于**AIoT-toolkit1.0** ，**AIoT-toolkit2.0** 对`Xiaomi Vela JS`项目编译的速度有了极大的提升，同时也带来一些**破坏性更新** 。在老项目使用了**1.0** 现准备向2.0**升级迁移** 时，请按下面的**注意事项** ，对源代码进行轻微修改。

## [#](<#注意事项>) 注意事项

开发者在从**AIoT-toolkit1.0** 升级到**AIoT-toolkit2.0** 有以下注意事项:

描述 | 解决办法  
---|---  
有些语法修正   
1\. `{{}}` 中无需再嵌套`{{}}`，`onclick="{{fun({{x}}，{{y}})}}`" 改为 `onclick="fun(x, y)"`   
  
2.不支持的样式选择器报错，例如伪类 | 修改源代码  
动态路径没有转换为完整的路径：  
**1.0写法** ：../../common   
**2.0写法** ：/common/**** | 修改源代码  
  
还有一些特殊的动态css值，从**AIoT-toolkit1.0** 升级到**AIoT-toolkit2.0** ，也要使用新的写法:

  * transform


    
    
     this.divStyle = {
       transform: JSON.stringify({
           translateX: "10px",
           translateY: "20px",
           scaleX: 2,
           scaleY: 0.5,
           rotate: "10deg",
       }),
     };
    

  * background
        
        // 线性渐变
          this.divStyle = {
              background: JSON.stringify({
                  values: [
                  {
                      type: "linearGradient",
                      directions: ["to", "left"],
                      values: ["#FF0000 10px", "#0000FF 100%"],
                  },
                  ],
              }),
          };
          // 径向渐变
          this.divStyle = {
              background: JSON.stringify({
                  values: [{
                      type: "radialGradient",
                      size: ["farthest-corner"],
                      directions: ["center"],
                      values: ["#3f87a6", "#ebf8e1", "#f69d3c"],
                  }],
              }),
          };
        

  * filter


    
    
       this.divStyle = {
           filter: JSON.stringify({
               blur: "10px",
           }),
       };
    

  * url


    
    
    this.divStyle = {
       backgroundImage: "/common/logo.png",
    };
    

注意

以上改动请务必按照注意事项中的说明进行修改，否则在升级到**2.0** 后将影响项目的正常运行和启动。

---

## #打包应用

> 来源: [https://iot.mi.com/vela/quickapp/zh/tools/release/start.html](https://iot.mi.com/vela/quickapp/zh/tools/release/start.html)

# [#](<#打包应用>) 打包应用

**`Xiaomi Vela JS 应用`** 应用的封装采用了专门的 .rpk 文件格式，而在 `AIoT-IDE` 中，我们在**顶部操作栏** 提供了打包，发布两个按钮对项目进行打包，如下图**标签1，2** 所示。

![alt text](/vela/quickapp/images/tools/ide-debug-10.png)

直接点击打包应用，会在功能面板执行打包名，打包成功后会在dist目录下生成debug包

![alt text](/vela/quickapp/images/tools/ide-debug-11.png)

debug包是为了方便开发者进行调试而设计的，因此它不会进行过多的优化。通常情况下，debug 包会包含调试信息，以便开发者进行调试和定位错误。

---

## #发布应用

> 来源: [https://iot.mi.com/vela/quickapp/zh/tools/release/release.html](https://iot.mi.com/vela/quickapp/zh/tools/release/release.html)

# [#](<#发布应用>) 发布应用

不同于顶部按钮区域的打包按钮，点击`发布`按钮发布应用，将生成**release** 包。

**release** 包是为了发布到生产环境而设计的，因此它会进行更严格的优化，以减少文件大小和加载时间。通常情况下，release 只包含必要的文件和代码，会删除所有的调试信息、注释和未使用的代码，以减小文件大小并提高性能。

同时，在生成release包前，会检查当前目录下是否**包含签名文件** ，如果没有会进入创建签名页面，按提示点击完成即可创建签名文件。

![alt text](/vela/quickapp/images/tools/ide-debug-11.gif)

签名文件**创建成功** 后，再次**点击发布** 即可创建release包。

![alt text](/vela/quickapp/images/tools/ide-debug-12.png)

---

