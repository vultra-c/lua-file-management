# 快应用_最佳实践

> 来源: 小米快应用官方
> 共 3 篇文档

---

## #启动时延优化

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/best-practice/start.html](https://iot.mi.com/vela/quickapp/zh/guide/best-practice/start.html)

# [#](<#启动时延优化>) 启动时延优化

## [#](<#避免settimeout延迟>) 避免setTimeout延迟

logo页如非必要，在执行页面跳转时，不要增加setTimeout延迟跳转。如果是需要等待异步结果返回，例如获取storage后决定跳转的下一个页面，建议将异步方法封装成同步，使用await，等待结果返回后立即执行跳转。以storage为例：
    
    
    // ❌不推荐写法
    onInit(){
      this.checkifHome()
      setTimeout(() => {
        if(!this.ifHome){
          router.push({uri:'pages/home'})
        }
      },1000)
    }
    checkifHome(){
      const that = this 
      storage.get({
        key: 'ifHome',
        success: function(data) {
          that.ifHome = data
        },
        fail: function(data, code) {
          console.log(`handling fail, code = ${code}`)
        }
      })
    }
    
    
    
    // ✅推荐写法一
    onInit(){
      storage.get({
        key: 'ifHome',
        success: function(data) {
          if(!data){
            router.push({uri:'pages/home'})
          }
        },
        fail: function(data, code) {
          console.log(`handling fail, code = ${code}`)
        }
      })
    }
    
    
    
    // ✅推荐写法二
    async onInit(){
      const ifHome = await checkifHome()
      if(!ifHome){
        router.push({uri:'pages/home'})
      }
    }
    checkifHome(){
      return new Promise((resolve, reject) => {
        storage.get({
          key: 'ifHome',
          success: function(data) {
            resolve(data) 
          },
          fail: function(data, code) {
            console.log(`handling fail, code = ${code}`)
            reject(code)
          }
        })
      })
    }
    
    
    
    // ✅推荐写法三
    //可统一封装promise.js,方便其他异步接口复用
    export function promisify(fn) {
      if (typeof fn !== 'function') {
        throw Error('[promisify] the type of `fn` should be function');
      }
    
      return (opts={}) => {
        let { success, fail, complete, ...args } = opts;
    
        if (typeof success === 'function' || typeof fail === 'function' || typeof complete === 'function') {
          console.warn('[promisify] [WARN] The `success`, `fail` and `complete` callback will be ignored');
        }
    
        return new Promise((resolve, reject) => {
          try {
            fn({
              ...args,
              success: data => resolve(data),
              fail: (data, code) => {
                let err = new Error(data);
                err.code = code;
                reject(err);
              }
            });
          } catch (error) {
            reject(error)
          }
        })
      }
    }
    
    //统一封装storage方法
    import storage from '@system.storage';
    import {promisify} from './promise';
    
    const _get = promisify(storage.get);
    const _set = promisify(storage.set);
    const _clear = promisify(storage.clear);
    const _delete = promisify(storage.delete);
    export default {
      getItem(key) {
        return _get({key});
      },
    
      setItem(key, value) {
        return _set({key, value});
      },
    
      deleteItem(key) {
        return _delete({key});
      },
    
      clear() {
        return _clear();
      },
    }
    
    //logo.ux
    async onInit(){
       const ifHome = await storage.getItem('ifHome')
      if(!ifHome){
         router.push({uri:'pages/home'})
      }
    }
    

## [#](<#首页数据缓存>) 首页数据缓存

首页数据如果二次进入，需要再次展示的，可以考虑在应用（或首页）退出时增加上缓存，下次进入从logo页读取缓存后将数据存储在全局，首页page在onInit时直接读取，然后同时发起异步请求进行更新即可；

## [#](<#logo页避免http请求>) logo页避免http请求

建议不要在logo页引入http请求，尽可能放到首页执行，防止弱网或者无网情况阻塞页面跳转；

## [#](<#ui先行>) UI先行

如音乐类应用，进入应用建议默认状态为不播放，可以UI先行，如果歌曲信息获取成功立即展示，无需等到audio资源加载完成展示；

## [#](<#隐私页信息使用静态数据>) 隐私页信息使用静态数据

隐私页的数据代码里使用静态的数据，不用动态获取。需要展示长文本的，可以通过二维码扫码查看，二维码直接本地写死一个h5链接，不要通过接口去获取；

## [#](<#减少从console打印>) 减少从console打印

尽可能减少console打印，特别是长日志，很影响性能，避免很长的（>10行）console打印，尽可能减少json对象的打印，如果是debug期间需要打印日志，建议使用console.debug，并且配置quickapp.config.js（具体配置如下），在打release包的时候过滤掉console.debug的日志；
    
    
    const TerserPlugin = require("terser-webpack-plugin")
    const webpack = require("webpack")
    
    module.exports = {
      postHook: (config) => {
        if (config.mode === "production") {
          config.optimization.minimize = true
          config.optimization.minimizer = [
            new TerserPlugin({
              terserOptions: {
                compress: {
                  pure_funcs: ["console.debug"]
                }
              }
            })
          ]
        }
      }
    }
    

## [#](<#图片缓存-裁剪>) 图片缓存/裁剪

如果有较大的（>100kb）动态图片，建议首次加载增加loading页，下载并缓存到本地，后续通过internal://files/XXX.png加载（重要：一般非必要不建议引入在线大图，引入的大图尺寸也不要超过屏幕尺寸，且大小不超过200kb，尽量使用本地图片代替在线图片，或者在线图片里支持resize-尺寸裁剪）
    
    
    //login.ux
    export function downloadFile(url) {// 下载图片
      return new Promise((resolve, reject) => {
        if(!url){
          resolve('')
        }
        request.download({
          url,
          success: function (ret) {
            const token = ret.token
            request.onDownloadComplete({
              token: token,
              success: function (ret) {
                console.info(`### request.download ### ret`,ret)
                resolve(ret.uri)
              },
              fail: function (msg, code) {
                console.info(`### request.onDownloadComplete ### ${code}: ${msg}`)
                resolve(null)
              }
            })
          }
        })
      })
    }
    const formUrl = 'http://XXX.cdn.homeBg.png'
    downloadFile(formUrl).then(url => {
      global.homeBgUrl = url; //url => 'internal://files/homeBg.png'
    })
     
    //home.ux
    <image class="w-466 h-466" src="{{bgImage}}" alt="../../common/images/homeBg.png"></image>
    //....
      computed:{
        bgImage() {
          const img =  global.homeBgUrl || 'http://XXX.cdn.homeBg.png'
          return img
        }
      }
    //....
     
     //logo页
     global.homeBgUrl = await storage.getItem('homeBgUrl')
     
     //根据条件变化，及时进行图片清理
     logoOut(){
       file.delete({
        uri:global.homeBgUrl,
        success: function(data) {
          console.info(`###delFile sucess ${data}`)
          resolve(true)
        },
        fail: function(data, code) {
          resolve(false)
          console.log(`###delFile fail, code = ${code}`)
        }
      })
    }
    

## [#](<#通信类应用通信之前使用diagnosis方法判断连接状态>) 通信类应用通信之前使用diagnosis方法判断连接状态

使用interconnect实现手表app和手机app的通信时，摒弃之前的轮询调用getApkStatus方法，改用新api [diagnosis](</vela/quickapp/zh/features/network/interconnect.html#connect-diagnosis-object>)
    
    
    data: {
       status: '',
       connectNum: 3,
       conn: null
    },
    onInit() {
       this.conn = interconnect.instance();
       this.connectStatus();
    }, 
    
    
    
    // ❌ 不推荐写法
    connectStatus() {
      let status = this.conn.getApkStatus();
      if (status === 'CONNECTED' || this.connectNum === 0){
        this.status = status;
        // do something
      } else if (this.connectNum > 0) {
        this.connectNum --;
        setTimeout(() => {
          this.connectStatus()
        },500)
      }
    }
    
    
    
    // ✅推荐写法
    connectStatus() {
      this.conn.diagnosis({
        success: (data) => {
          console.log(`handling success, status= ${data.status}`)
          // do something
        },
        fail: (data,code) => {
          console.log(`handling fail, code = ${code}`)
          // do something
        }
      })
    }  
    

## [#](<#使用interconnect传输多条数据>) 使用interconnect传输多条数据

手表app向手机app传输多条数据时，若传输数量不大，建议直接一次性发送，无需增加延迟发送
    
    
    // ❌不推荐写法
    sendMsg(list) {
      for (let x in list) { 
        setTimeout(() => {
          this.conn.send({
            data: list[x],
            success: ()=>{ },
            fail: (data: {data, code})=> { }
          })
        },x*500) 
      }
    }
    
    
    
    // ✅推荐写法
    sendMsg(list) {
      for (let x in list) {            
        this.conn.send({
          data: list[x],
          success: ()=>{ },
          fail: (data: {data, code})=> { }
        })
      }
    }

---

## #常用业务优化

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/best-practice/business.html](https://iot.mi.com/vela/quickapp/zh/guide/best-practice/business.html)

# [#](<#常用业务优化>) 常用业务优化

## [#](<#list与长文案优化>) list与长文案优化

说明

list过长以及长文案（例如大段的隐私协议，用户协议）显示时，所能用到的优化手段

  * list

list列表，在初始化渲染时，原则上，如果内容超过10条，建议使用分页式渲染，或是触底发送请求新的数据，切勿初始化渲染大量数据，会造成页面渲染卡顿。

  * 长文案

长文案一般是需要在小的设备屏幕上显示大量的文字内容，例如“用户协议”，“隐私协议”，“未成年人保护协议”等等

    * 通常建议是用二维码显示协议链接，通过扫码在手机上浏览也是一种比较常用的设计。
    * 如果产品需要一次性全量渲染，会一定程度上造成页面的渲染卡顿，影响首次渲染的用户体验，这里推荐的是分块渲染文案。下面是代码示例：


    
    
    <!-- 渲染文案的区域,同时绑定handleScroll滚动监听 -->
    <template>
      <scroll id="scroll" scroll-y="true" class="scroll" onscroll="handleScroll">
        <div id="content" class="connent">
          <block if="{{currentKey >= 0}}">
            <text class="header-1">{{contentArray[0]}}</text>
          </block>
            <block if="{{currentKey >= 1}}">
            <text class="header-1">{{contentArray[1]}}</text>
          </block>
            <block if="{{currentKey >= 2}}">
            <text class="header-1">{{contentArray[2]}}</text>
          </block>
        </div>
      </scroll>
    </template>
    <!-- 把文案内容以数组形式保存，并记录当前所渲染的文案的序列号 -->
    <script>
    export default {
      data:{
        contentArray:[
          {
            content:'文案一..........'
          },
          {
            content:'文案二..........'
          },
          {
            content:'文案三..........'
          }
        ],
        //当前所需所渲染到的文案序列号
        currentKey:0,
        //当前总高度
        currentTHEight:0,
      }
      //onReady时先给当前总高度赋一次值
      onReady(){
        this.$element('content').getBoundingClientRect({
          success: (data) => {
            const { height } = data;
            this.currentTHEight = height
          }
        })
      }
      //实时判断滚动高度与总体高度，如果快触底了，则进行下一个文案的加载,同时给总高度重新赋值
      handleScroll(e) {
        if(currentTHEight - e.scrollY <40){
            this.currentKey = currentKey + 1
        }
        this.$element('content').getBoundingClientRect({
          success: (data) => {
            const { height } = data;
            this.currentTHEight = height
          }
        })
      }
    }
    
    </script>
    

## [#](<#swiper-多图优化>) Swiper 多图优化

说明

当使用swiper轮播图时，如果图片很多。请避免同时渲染多张图片。保证可视区内以及左右图片的渲染即可

假设现在一个相册有`200`张图片需要展示，就需要在`swiper`中创建`200`个子组件，无疑对性能是不友好的，因此考虑`swiper`只显示`3`个子组件，在左右滑动过程中动态更新子组件中的图片来实现`Swiper`中的数据懒加载。右滑懒加载主要过程如下：

  * 右滑懒加载实现过程 假设有`5`张图片的数组为`data=[0,1,2,3,4]`，现在需要将这`5`张图片在含有`3`个子组件的`swiper`中展示。

    1. 当用户点击第一张图，`swiper`中的数据为`data[0],data[1],data[2]`
    2. 当从第一张图片滑动到第二张图片的时候，`swiper`的数组仍然为`data[0],data[1],data[2]`
    3. 当从第2张滑动到第`3`张图片时，需要修改`swiper`第一个组件的数据为第三张图片的下一个数据`data[3]`，并且将`swiper`的`loop`属性设置为true，此时`swiper`的数据为`data[3],data[1],data[2]`；
    4. 当从`data[3]`滑动到`data[4]`时需要注意的是`data[4]`是最后一条数据，如果最后一条数据也不在`swiper`的最后一个组件中，需要将`swiper`中的所有数据进行重置为`data[len-3],data[len-2],data[len-1]`，以保证最后一张图片一定在`swiper`最后的一个组件中，并将`loop`设置为`false`，不允许从最后一张滑动到第一张。


![alt text](/vela/quickapp/images/components/business-swiper.jpg) `Swiper懒加载实例`

  * 具体实现思路


在代码中通过`@change`事件监听`swiper`的滑动。判断左滑右滑逻辑如下：
    
    
    // 判断右滑
    if (
      (!(this.currentIndex === 0 && index === length - 1) && index > this.currentIndex) ||
      (index === 0 && this.currentIndex === length - 1)
    ) {
    }else{
    }
    

右滑的逻辑如下：
    
    
    //更新数据索引
    this.dataIndex = this.dataIndex + 1
    //更新下一次右滑的索引
    const updateIndex = this.dataIndex + 1
    if (updateIndex < this.bigThumbnailInfo.length) {
      //下一次右滑更新为当前的下一张
      updateItem = this.bigThumbnailInfo[updateIndex]
      // 如果滑动前是
      if (this.currentIndex === 0) {
        //未滑动前是第一张，右滑更新swiper的最后一个
        this.data[length - 1] = updateItem
        resIndex = length - 1
      } else {
        // console.info("右滑：更新左边的")
        this.data[this.currentIndex - 1] = updateItem
        resIndex = this.currentIndex - 1
      }
    }
    

左滑代码逻辑如下：
    
    
    //更新数据索引
    this.dataIndex = this.dataIndex - 1
    //更新下一次右滑的索引
    const updateIndex = this.dataIndex - 1
    //下一次左滑更新为当前的上一张
    updateItem = this.bigThumbnailInfo[updateIndex]
    if (this.currentIndex === length - 1) {
      //未滑动前在最后一张，左滑更新swiper第一个
      this.data[0] = updateItem
      resIndex = 0
    } else {
      this.data[this.currentIndex + 1] = updateItem
      resIndex = this.currentIndex + 1
    }
    

判断如果当前是最后一张图片代码如下：
    
    
    this.data = [
      this.bigThumbnailInfo[len - 3],
      this.bigThumbnailInfo[len - 2],
      this.bigThumbnailInfo[len - 1]
    ]
    indexTemp = 2
    this.swiperIndex = this.currentIndex
    this.isloop = false
    

判断即将更新的图片是第一张图片：
    
    
    this.data = [
      this.bigThumbnailInfo[0],
      this.bigThumbnailInfo[1],
      this.bigThumbnailInfo[2]
    ]
    indexTemp = 0
    this.swiperIndex = this.currentIndex
    this.isloop = false
    

如果不是第一张也不是最后一张图片，设置`swiper`的`loop`为`true`:
    
    
    this.isloop = true
    

## [#](<#设备帧率的优化建议>) 设备帧率的优化建议

  * 有背景图或者图片的时候，尽量减少设置`border-radius`，使用带圆角的图片
  * 图片大小与`div`或者`image`组件大小保持一致，尽量不缩放图片
  * 减少`动态样式`修改
  * 减少标签的`嵌套层级`
  * 减少回流重绘


## [#](<#其他优化建议>) 其他优化建议

  * 增加try catch捕获异常
  * 数据请求较慢的场景建议增加loading
  * 若对图片视觉质量无高要求，建议优先采用 PNG8 格式，可有效降低图片体积、提升动画 / 页面的渲染帧率。

---

## #内存优化

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/best-practice/memory.html](https://iot.mi.com/vela/quickapp/zh/guide/best-practice/memory.html)

# [#](<#内存优化>) 内存优化

由于运动手表整体内存较小，对于三方应用内存占用量要求比较高。根据之前遇到的问题，给出一份三方应用开发时的注意事项清单，以帮助开发者尽量降低应用的内存占用，符合手表应用验收标准。

## [#](<#代码注意事项>) 代码注意事项

  1. 和 UI 无关，不需要绑定的数据，不要声明到 viewModel 的数据里，减少 observer 或者数据代理


    
    
    <template>
      <div>
        <text>{{name}}</text>     
      </div>
    </template>
    
    <script>
      const someObj = { a: 1 } // 推荐写法
      export default {
        protected: {
          name: 'aaa',
          someObj: { // 不推荐写法
            a: 1
          }
        }
      }
    </script>
    

  2. 页面对象更新时，尽量原地更新，不要重新赋值，开辟新的内存空间


    
    
    export default {
      protected: {
        list: [{
          name: 'aa',
          age: 22
        }]
      },
      
      onClick() {
        // 不推荐写法
        this.list = [{
          name: 'bb',
          age: 21
        }]
        // 推荐写法
        this.list[0].name = 'bb',
        this.list[0].age = 21
      }
    }
    

  3. 页面中声明的属性和方法不要缓存到全局上


页面销毁时，为清理内存，会将页面对象相关的属性和方法尽量解除引用。如果被引用到全局，就无法清理其占用的内存，并且在其他地方调用该缓存的属性和方法，可能引起报错。
    
    
    export default {
      protected: {
        list: [{
          name: 'aa',
          age: 22
        }]
      },
      
      onShow() {
        this.$app.$def.somearray.push(this.foo) // 不推荐写法
      }，
      
      foo() {
        this.list.push({
          name: 'bb',
          age: 21
        })
      }
    }
    

  4. 页面销毁时，清除未执行完的定时器


    
    
    export default {
      protected: {
        timer: null
      }
      
      onShow() {
        this.timer = setTimeout(()=>{}, 1000000)
      }
      
      onDestroy() {
        if(this.timer){
          clearTimeout(this.timer)
        }
      }
    }
    

  5. 读取文件数据，用完后及时释放


    
    
    let fileData; // 读取文件数据
    let storageData; // 读取storage数据
    
    file.readText({
      uri: 'internal://files/work/demo.txt',
      success: function(data) {
        fileData = data.text;
        console.log('text: ' + data.text)
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    });
    storage.get({
      key: 'A1',
      success: function(data) {
        storageData = data;
        console.log('handling success')
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    
    // 用完后及时释放
    fileData = null;
    storageData = null;
    

  6. 调用runGC方法


通过执行全局对象global上的runGC方法，及时进行垃圾回收，避免内存泄漏。不要频繁调用，防止页面卡顿。
    
    
    global.runGC()
    

  7. `static`属性


`template`模板中提供了`static`属性支持，如果绑定的变量后面不会再改变，添加`static`标记有助于框架减少实现动态节点，减少内存，也会降低页面销毁删除对象的时间。
    
    
    <template>
      <div>
        <text static >{{name}}</text>
        <image static src="/assets/icon/a.png"/>   
      </div>
    </template>
    
    <script>
      export default {
        protected: {
          name: 'aaa'
        }
      }
    </script>
    

另外，还支持在 `template` 上使用`.static`修饰符修饰节点的某个静态属性，适用于节点的该属性值仅在初始时被赋值一次，之后不会再变更。使用语法：`attr.static="{{ attrValue }}"`

注意

  * 节点的 `if` / `for` 静态属性只能通过 `.static` 修饰词进行修饰
  * 节点的 `static` 属性优先级比 `.static`高。对于声明了 `static` 属性的节点，可以不需要额外声明某个属性的静态修饰词 `attr.static`


    
    
    <template>
      <div>
        <div if.static="{{ bool }}">
          <text style="{{ styl }}" someattr="{{ some }}" class="{{ cls }}" static>{{name}}</text>
    
          <input style="{{ styl }}" name="{{ some }}" class="{{ cls }}" value="{{ name }}" static />
        </div>
    
        <text
          if.static="{{ bool }}"
          style.static="{{ styl }}"
          someattr.static="{{ some }}"
          class.static="{{ cls }}"
          value.static
        >{{name}}</text>
    
        <input
          if.static="{{ bool }}"
          style.static="{{ styl }}"
          someattr.static="{{ some }}"
          class.static="{{ cls }}"
          value.static="{{name}}"
        />
      </div>
    </template>
    
    <script>
      export default {
        private: {
          name: 'aaa',
          bool: true,
          cls: 'basic-text',
          some: 'someattr',
          styl: {
            backgroundColor: '#d1d1d1'
          }
        }
      }
    </script>
    

`block`组件是一个逻辑区块节点，如果增加了`static`属性，表示`block`包含的所有节点都是静态数据绑定，绑定的数据只计算一次，后面不会再发生改变，适用于绑定一些枚举值或者不可变的列表数据等，有效减少内存占用。
    
    
    <template>
      <!-- block 内部节点数据只计算一次只渲染一次 -->
      <block static>
        <text class="{{cls}}">标题： {{title}}</text>
        <text>条件渲染</text>
        <list>
          <list-item for="{{list}}" type="item">
            <text>{{$item}}</text>
          </list-item>
        </list>
      </block>
    </template>
    <script>
      export default {
        private: {
          title: '我是标题1',
          cls: 'txt-cls',
          display: true,
          list: ['a', 'b', 'c']
        }
      }
    </script>
    

## [#](<#减少打包代码体积>) 减少打包代码体积

  1. 减少不必要的三方依赖，选用轻量的三方依赖


对于`package.json`中的三方依赖，去除没有用到的依赖，对于必要的大型依赖，尽可能替换成轻量的依赖。

  2. 使用全局方法


将通用的方法、常量和对象实例统一挂在`global`上，在页面中不用再`import`，需要用的时候直接从`global`上取。
    
    
    // global.js
    import foo from './foo'
    import bar from './bar'
    
    global.foo = foo
    global.bar = bar
    
    // app.ux
    import  './global'
    
    
    // pages/xxx/index.js
    const {foo, bar} = global
    
    export default {
        // 调用foo、bar
        //......
    }
    

以QQ音乐为例，以下为优化前后效果对比：

| 优化前 | 替换轻量级依赖 | 使用全局方法  
---|---|---|---  
代码行数 | 21965 | 13156 | 6807  
最大内存 | 4842844 | 3295928 | 1872528  
  
  3. 在保证图片质量的前提下，尽量用低分辨率图片  
大尺寸图片在加载时会占用较多内存，可以先将大尺寸图片缩放成小尺寸图片，再进行压缩(<https://tinypng.com>[ (opens new window)](<https://tinypng.com>))，减少图片的体积。

  4. 去除没有用到的css和js  
对于css中没有用到的样式，js中没有用到的变量和函数，可以删除或者注释，精简代码。

  5. 尽可能减少页面数量  
在不影响业务需求的前提下，用最少的页面去实现，减少代码体积，简化应用逻辑。

---

