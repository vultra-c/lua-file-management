# 快应用_接口_系统

> 来源: 小米快应用官方
> 共 11 篇文档

---

## #电量信息 battery

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/system/battery.html](https://iot.mi.com/vela/quickapp/zh/features/system/battery.html)

# [#](<#电量信息-battery>) 电量信息 battery

## [#](<#接口声明>) 接口声明
    
    
    { "name": "system.battery" }
    

## [#](<#导入模块>) 导入模块
    
    
    import battery from '@system.battery' 
    // 或 
    const battery = require('@system.battery')
    

## [#](<#接口定义>) 接口定义

### [#](<#battery-getstatus-object>) battery.getStatus(OBJECT)

获取当前设备的电量信息

#### [#](<#参数>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#success-返回值>) success 返回值：

参数名 | 类型 | 说明  
---|---|---  
charging | Boolean | 是否正在充电  
level | Number | 当前电量，0.0 - 1.0 之间  
  
#### [#](<#示例>) 示例
    
    
    battery.getStatus({
      success: function(data) {
          console.log(`handling success: ${data.level}`)
      },
      fail: function(data, code) {
          console.log(`handling fail, code = ${code}`)
      }
    })
    

## [#](<#支持明细>) 支持明细

设备产品 | 说明  
---|---  
小米 S1 Pro 运动健康手表 | 不支持  
小米手环 8 Pro | 不支持  
小米手环 9 / 9 Pro | 不支持  
Xiaomi Watch S3 | 不支持  
Redmi Watch 4 | 不支持  
小米腕部心电血压记录仪 | 不支持  
小米手环 10 | 支持  
Xiaomi Watch S4 | 支持  
REDMI Watch 5 | 支持  
REDMI Watch 6 | 支持  
Xiaomi Watch S5 | 支持

---

## #蓝牙 bluetooth

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/system/bluetooth.html](https://iot.mi.com/vela/quickapp/zh/features/system/bluetooth.html)

# [#](<#蓝牙-bluetooth>) 蓝牙 bluetooth

## [#](<#接口声明>) 接口声明
    
    
    { "name": "system.bluetooth.ble" }
    

## [#](<#导入模块>) 导入模块
    
    
    import bluetoothBLE from '@system.bluetooth.ble'
    或
    const bluetoothBLE = require("@system.bluetooth.ble")
    

## [#](<#接口定义>) 接口定义

### [#](<#bluetoothble-createscanner>) bluetoothBLE.createScanner()

初始化蓝牙模块。

#### [#](<#参数>) 参数：

无

#### [#](<#返回值>) 返回值：

[Scanner](<#Scanner>) 实例

#### [#](<#示例>) 示例：
    
    
    const scanner = bluetoothBLE.createScanner();
    

### [#](<#bluetoothble-creategattclientdevice-deviceid-addresstype>) bluetoothBLE.createGattClientDevice(deviceId, addressType)

创建一个 GattClientDevice（通用属性协议客户端）实例。

#### [#](<#参数-2>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
deviceId | String | 是 | 对端设备地址， 例如："XX:XX:XX:XX:XX:XX"。  
addressType | String | 否 | 表示设备地址类型，可选值为：'PUBLIC'、'RANDOM'、'ANONYMOUS' 、'UNKNOWN'，默认值：UNKNOWN。  
  
#### [#](<#返回值-2>) 返回值：

[GattClientDevice](<#GattClientDevice>) 实例。

#### [#](<#示例-2>) 示例：
    
    
    const gattClientDevice = bluetoothBLE.createGattClientDevice("XX:XX:XX:XX:XX:XX", 'PUBLIC');
    

## [#](<#scanner>) Scanner

### [#](<#方法>) 方法

### [#](<#startblescan-object>) startBLEScan(OBJECT)

发起 BLE 扫描流程。

#### [#](<#object-对象的属性>) OBJECT 对象的属性：

属性名 | 类型 | 必填 | 描述  
---|---|---|---  
filters | Array<[ScanFilter](<#ScanFilter>)> | 是 | 对端设备地址， 例如："XX:XX:XX:XX:XX:XX"。  
options | [ScanOptions](<#ScanOptions>) | 否 | 表示扫描的参数配置，可选参数。  
success | Function | 否 | 成功回调。  
fail | Function | 否 | 失败回调。  
complete | Function | 否 | 执行结束后的回调。  
  
#### [#](<#scanfilter>) ScanFilter

扫描过滤参数。

参数名 | 类型 | 可读 | 可写 | 描述  
---|---|---|---|---  
deviceId | String | 是 | 是 | 表示过滤的 BLE 设备地址，例如："XX:XX:XX:XX:XX:XX"。  
name | String | 是 | 是 | 表示过滤的 BLE 设备名。  
serviceUuid | String | 是 | 是 | 表示过滤包含该 UUID 服务的设备，例如：00001888-0000-1000-8000-00805f9b34fb。  
  
#### [#](<#scanoptions>) ScanOptions

扫描的配置参数。

参数名 | 类型 | 可读 | 可写 | 描述  
---|---|---|---|---  
dutyMode | [ScanDuty](<#ScanDuty>) | 是 | 是 | 表示扫描模式，默认值为 SCAN_MODE_LOW_POWER。  
  
#### [#](<#scanduty>) ScanDuty

枚举，扫描模式。

名称 | 默认值 | 说明  
---|---|---  
SCAN_MODE_LOW_POWER | 0 | 表示低功耗模式，默认值。  
SCAN_MODE_BALANCED | 1 | 表示均衡模式。  
SCAN_MODE_LOW_LATENCY | 2 | 表示低延迟模式。  
  
#### [#](<#示例-3>) 示例：
    
    
    let scanner = bluetoothBLE.createScanner();
    scanner.startBLEScan({
      filters: [
        {
          deviceId: "XX:XX:XX:XX:XX:XX",
          name: "test",
          serviceUuid: "00001888-0000-1000-8000-00805f9b34fb",
        }
      ],
      options: {
        dutyMode: ScanDuty.SCAN_MODE_LOW_POWER,
      },
      success: function () {
        console.log(`startBLEScan success`);
      },
      fail: function (data, code) {
        console.log(`startBLEScan fail, code = ${code}`);
      },
      complete: function () {
        console.log(`startBLEScan complete`);
      },
    });
    

### [#](<#scanner-stopblescan>) Scanner.stopBLEScan()

停止 BLE 扫描流程。

#### [#](<#参数-3>) 参数：

无

#### [#](<#返回值-3>) 返回值：

无

#### [#](<#示例-4>) 示例：
    
    
    scanner.stopBLEScan();
    

### [#](<#scanner-getscanstate-object>) Scanner.getScanState(OBJECT)

获得当前Scanner的扫描状态。

#### [#](<#object-对象的属性-2>) OBJECT 对象的属性：

属性名 | 类型 | 必填 | 描述  
---|---|---|---  
success | Function | 否 | 成功回调。  
fail | Function | 否 | 失败回调。  
complete | Function | 否 | 执行结束后的回调。  
  
#### [#](<#success-回调对象的属性>) success 回调对象的属性：

属性名 | 类型 | 说明  
---|---|---  
scanState | [ScanState](<#ScanState>) | 扫描状态。  
  
#### [#](<#scanstate>) ScanState

枚举，BLE扫描状态。

名称 | 默认值 | 说明  
---|---|---  
STATE_NON_SCAN | 0 | 表示本地未开始扫描周围设备。  
STATE_SCANING | 1 | 表示本地正在扫描周围设备。  
  
#### [#](<#示例-5>) 示例：
    
    
    scanner.getScanState({
      success: function (data) {
        console.log(`getScanState success, state = ${data.scanState}`);
      },
      fail: function (data, code) {
        console.log(`getScanState fail, code = ${code}`);
      },
      complete: function () {
        console.log(`getScanState complete`);
      },
    });
    

### [#](<#scanner-subscribebledevicefind-object>) Scanner.subscribeBLEDeviceFind(OBJECT)

订阅 BLE 设备发现上报事件。

#### [#](<#object-对象的属性-3>) OBJECT 对象的属性：

属性名 | 类型 | 必填 | 说明  
---|---|---|---  
callback | Function | 否 | 设备发现上报回调。  
fail | Function | 否 | 失败回调。  
  
#### [#](<#返回值-4>) 返回值：

类型 | 说明  
---|---  
Number | 订阅 id。  
  
#### [#](<#callback-回调参数>) callback 回调参数：

类型 | 说明  
---|---  
Array<[ScanResult](<#ScanResult>)> | 扫描结果上报数据。  
  
#### [#](<#scanresult>) ScanResult

扫描结果上报数据。

参数名 | 类型 | 可读 | 可写 | 描述  
---|---|---|---|---  
deviceId | String | 是 | 否 | 表示扫描到的设备地址，例如："XX:XX:XX:XX:XX:XX"。  
rssi | Number | 是 | 否 | 表示扫描到的设备的 rssi 值。  
data | ArrayBuffer | 是 | 否 | 表示扫描到的设备发送的广播包。  
addressType | String | 是 | 否 | 表示设备地址类型，取值为：'PUBLIC' 、'RANDOM'、'ANONYMOUS' 、'UNKNOWN' 。  
  
#### [#](<#示例-6>) 示例：
    
    
    let scanner = bluetoothBLE.createScanner();
    const subscribeId = scanner.subscribeBLEDeviceFind({
      callback(data) {
        for (let i = 0; i < data.length; i++) {
          console.info(`subscribeBLEDeviceFind deviceId = ${data[i].deviceId}, rssi = ${data[i].rssi}, addressType = ${data[i].addressType}`);
        }
      },
      fail(data, code) {
        console.log(`subscribeBLEDeviceFind fail, code = ${code}`);
      },
    });
    

### [#](<#scanner-unsubscribebledevicefind-subscribeid>) Scanner.unsubscribeBLEDeviceFind(subscribeId)

取消订阅 BLE 设备发现上报事件。

#### [#](<#参数-4>) 参数：

类型 | 说明  
---|---  
Number | 订阅 id  
  
#### [#](<#返回值-5>) 返回值：

无

#### [#](<#示例-7>) 示例：
    
    
    scanner.unsubscribeBLEDeviceFind(subscribeId);
    

### [#](<#scanner-close>) Scanner.close()

关闭Scanner功能，调用该接口后Scanner实例将不能再使用。

#### [#](<#参数-5>) 参数：

无

#### [#](<#返回值-6>) 返回值：

无

#### [#](<#示例-8>) 示例：
    
    
    scanner.close();
    

## [#](<#gattclientdevice>) GattClientDevice

### [#](<#方法-2>) 方法

### [#](<#gattclientdevice-connect-object>) GattClientDevice.connect(OBJECT)

client 端发起连接远端蓝牙低功耗设备。

#### [#](<#object-对象的属性-4>) OBJECT 对象的属性：

属性名 | 说明 |  |   
---|---|---|---  
success | Function | 否 | client端发送指令成功后回调（非连接成功）。  
fail | Function | 否 | 失败回调。  
complete | Function | 否 | 执行结束后的回调。  
  
#### [#](<#success-的回调参数>) success 的回调参数：

无

#### [#](<#示例-9>) 示例：
    
    
    let gattClientDevice = bluetoothBLE.createGattClientDevice("XX:XX:XX:XX:XX:XX");
    gattClientDevice.connect({
      success: function () {
        console.log(`send connect success`);
      },
      fail: function (data, code) {
        console.log(`connect fail, code = ${code}`);
      },
      complete: function () {
        console.log(`connect complete`);
      }
    });
    

### [#](<#gattclientdevice-disconnect-object>) GattClientDevice.disconnect(OBJECT)

client 端断开与远端蓝牙低功耗设备的连接。

#### [#](<#object-对象的属性-5>) OBJECT 对象的属性：

属性名 | 说明 |  |   
---|---|---|---  
success | Function | 否 | client端发送指令成功后回调。  
fail | Function | 否 | 失败回调。  
complete | Function | 否 | 执行结束后的回调。  
  
#### [#](<#success-的回调参数-2>) success 的回调参数：

无

#### [#](<#示例-10>) 示例：
    
    
    gattClientDevice.disconnect({
      success: function () {
        console.log(`disconnect success`);
      },
      fail: function (data, code) {
        console.log(`disconnect fail, code = ${code}`);
      },
      complete: function () {
        console.log(`disconnect complete`);
      }
    });
    

### [#](<#gattclientdevice-close>) GattClientDevice.close()

关闭客户端功能，注销 client 在协议栈的注册，调用该接口后 GattClientDevice 实例将不能再使用。

#### [#](<#返回值-7>) 返回值：

类型 | 说明  
---|---  
Boolean | 调用接口成功返回 true，失败返回 false。  
      
    
    let result = gattClientDevice.close();
    console.log(`gattClientDevice close ${result}`);
    

### [#](<#gattclientdevice-getservices-object>) GattClientDevice.getServices(OBJECT)

client 端获取蓝牙低功耗设备的所有服务，即服务发现 。

#### [#](<#object-对象的属性-6>) OBJECT 对象的属性：

属性名 | 类型 | 必填 | 说明  
---|---|---|---  
success | Function | 否 | 成功回调。  
fail | Function | 否 | 失败回调。  
complete | Function | 否 | 执行结束后的回调。  
  
#### [#](<#success-的回调参数-3>) success 的回调参数：

类型 | 描述  
---|---  
Array<[GattService](<#GattService>)> | 服务端的 service 数据。  
  
#### [#](<#示例-11>) 示例：
    
    
    function outputServices(services) {
      console.log("bluetooth services size is ", services.length);
      for (let i = 0; i < services.length; i++) {
        console.log("bluetooth serviceUuid is " + services[i].serviceUuid);
      }
    }
    
    let gattClientDevice = bluetoothBLE.createGattClientDevice("XX:XX:XX:XX:XX:XX");
    gattClientDevice.connect();
    gattClientDevice.getServices({
      success: function (services) {
        outputServices(services);
      },
      fail: function (data, code) {
        console.log(`getServices fail, code = ${code}`);
      },
      complete: function () {
        console.log(`getServices complete`);
      },
    });
    

### [#](<#gattclientdevice-readcharacteristicvalue-object>) GattClientDevice.readCharacteristicValue(OBJECT)

client 端读取蓝牙低功耗设备特定服务的特征值。

#### [#](<#object-对象的属性-7>) OBJECT 对象的属性：

属性名 | 类型 | 必填 | 说明  
---|---|---|---  
characteristic | [BLECharacteristic](<#BLECharacteristic>) | 是 | 待读取的特征值。  
success | Function | 否 | 服务端返回数据后，进行回调。  
fail | Function | 否 | 失败回调。  
complete | Function | 否 | 执行结束后的回调。  
  
#### [#](<#success-的回调参数-4>) success 的回调参数：

类型 | 说明  
---|---  
[BLECharacteristic](<#BLECharacteristic>) | client 读取特征值，通过回调函数获取。  
  
#### [#](<#示例-12>) 示例：
    
    
    let gattClientDevice = bluetoothBLE.createGattClientDevice("XX:XX:XX:XX:XX:XX");
    let descriptors = [];
    let bufferDesc = new ArrayBuffer(8);
    let descV = new Uint8Array(bufferDesc);
    descV[0] = 11;
    let descriptor = {
      serviceUuid: "00001810-0000-1000-8000-00805F9B34FB",
      characteristicUuid: "00001820-0000-1000-8000-00805F9B34FB",
      descriptorUuid: "00002903-0000-1000-8000-00805F9B34FB",
      descriptorValue: bufferDesc,
    };
    descriptors[0] = descriptor;
    
    let bufferCCC = new ArrayBuffer(8);
    let cccV = new Uint8Array(bufferCCC);
    cccV[0] = 1;
    let characteristic = {
      serviceUuid: "00001810-0000-1000-8000-00805F9B34FB",
      characteristicUuid: "00001820-0000-1000-8000-00805F9B34FB",
      characteristicValue: bufferCCC,
      descriptors: descriptors,
    };
    
    gattClientDevice.readCharacteristicValue({
      characteristic,
      success: function (data) {
        console.log(`readCharacteristicValue uuid: ${data.characteristicUuid}`);
        if (data.characteristicValue) {
          let value = new Uint8Array(data.characteristicValue);
          console.log(`readCharacteristicValue value: ${value[0]}, ${value[1]}, ${value[2]}, ${value[3]}`);
        }
      },
      fail: function (data, code) {
        console.log(`readCharacteristicValue fail, code = ${code}`);
      },
      complete: function () {
        console.log(`readCharacteristicValue complete`);
      },
    });
    

### [#](<#gattclientdevice-readdescriptorvalue-object>) GattClientDevice.readDescriptorValue(OBJECT)

client 端读取蓝牙低功耗设备特定的特征包含的描述符。

#### [#](<#object-对象的属性-8>) OBJECT 对象的属性：

属性名 | 类型 | 必填 | 说明  
---|---|---|---  
descriptor | [BLEDescriptor](<#BLEDescriptor>) | 是 | 待读取的描述符。  
success | Function | 否 | 服务端返回数据后，进行回调。  
fail | Function | 否 | 失败回调。  
complete | Function | 否 | 执行结束后的回调。  
  
#### [#](<#success-的回调参数-5>) success 的回调参数：

类型 | 说明  
---|---  
[BLEDescriptor](<#BLEDescriptor>) | 描述 descriptor 的接口参数定义 。  
  
#### [#](<#示例-13>) 示例：
    
    
    let gattClientDevice = bluetoothBLE.createGattClientDevice("XX:XX:XX:XX:XX:XX");
    let bufferDesc = new ArrayBuffer(8);
    let descV = new Uint8Array(bufferDesc);
    descV[0] = 11;
    let descriptor = {
      serviceUuid: "00001810-0000-1000-8000-00805F9B34FB",
      characteristicUuid: "00001820-0000-1000-8000-00805F9B34FB",
      descriptorUuid: "00002903-0000-1000-8000-00805F9B34FB",
      descriptorValue: bufferDesc,
    };
    
    gattClientDevice.readDescriptorValue({
      descriptor,
      success: function (data) {
        console.log("readDescriptorValue uuid: " + data.descriptorUuid);
        if (data.descriptorValue) {
          let value = new Uint8Array(data.descriptorValue);
          console.log(`readDescriptorValue value: ${value[0]}, ${value[1]}, ${value[2]}, ${value[3]}`);
        }
      },
      fail: function (data, code) {
        console.log(`readDescriptorValue fail, code = ${code}`);
      },
      complete: function () {
        console.log(`readDescriptorValue complete`);
      },
    });
    

### [#](<#gattclientdevice-writecharacteristicvalue-object>) GattClientDevice.writeCharacteristicValue(OBJECT)

client 端向低功耗蓝牙设备写入特定的特征值。

#### [#](<#object-对象的属性-9>) OBJECT 对象的属性：

属性名 | 类型 | 必填 | 说明  
---|---|---|---  
characteristic | [BLECharacteristic](<#BLECharacteristic>) | 是 | 蓝牙设备特征对应的二进制值及其它参数。  
success | Function | 否 | client端发送指令成功后回调（非服务端成功）。  
fail | Function | 否 | 失败回调。  
complete | Function | 否 | 执行结束后的回调。  
  
#### [#](<#success-的回调参数-6>) success 的回调参数：

无

#### [#](<#示例-14>) 示例：
    
    
    let gattClientDevice = bluetoothBLE.createGattClientDevice("XX:XX:XX:XX:XX:XX");
    let descriptors = [];
    let bufferDesc = new ArrayBuffer(8);
    let descV = new Uint8Array(bufferDesc);
    descV[0] = 11;
    let descriptor = {
      serviceUuid: "00001810-0000-1000-8000-00805F9B34FB",
      characteristicUuid: "00001820-0000-1000-8000-00805F9B34FB",
      descriptorUuid: "00002903-0000-1000-8000-00805F9B34FB",
      descriptorValue: bufferDesc,
    };
    descriptors[0] = descriptor;
    
    let bufferCCC = new ArrayBuffer(8);
    let cccV = new Uint8Array(bufferCCC);
    cccV[0] = 1;
    let characteristic = {
      serviceUuid: "00001810-0000-1000-8000-00805F9B34FB",
      characteristicUuid: "00001820-0000-1000-8000-00805F9B34FB",
      characteristicValue: bufferCCC,
      descriptors: descriptors,
    };
    
    gattClientDevice.writeCharacteristicValue({
      characteristic,
      success: function () {
        console.log(`writeCharacteristicValue success`);
      },
      fail: function (data, code) {
        console.log(`writeCharacteristicValue fail, code = ${code}`);
      },
      complete: function () {
        console.log(`writeCharacteristicValue complete`);
      }
    });
    

### [#](<#gattclientdevice-writedescriptorvalue-object>) GattClientDevice.writeDescriptorValue(OBJECT)

client 端向低功耗蓝牙设备特定的描述符写入二进制数据。

#### [#](<#oejbct-对象的属性>) OEJBCT 对象的属性：

属性名 | 类型 | 必填 | 说明  
---|---|---|---  
descriptor | BLEDescriptor | 是 | 蓝牙设备描述符的二进制值及其它参数。  
success | Function | 否 | client端发送指令成功后回调（非服务端成功）。  
fail | Function | 否 | 失败回调。  
complete | Function | 否 | 执行结束后的回调。  
  
#### [#](<#success-的回调参数-7>) success 的回调参数：

无

#### [#](<#示例-15>) 示例：
    
    
    let gattClientDevice = bluetoothBLE.createGattClientDevice("XX:XX:XX:XX:XX:XX");
    let bufferDesc = new ArrayBuffer(8);
    let descV = new Uint8Array(bufferDesc);
    descV[0] = 22;
    let descriptor = {
      serviceUuid: "00001810-0000-1000-8000-00805F9B34FB",
      characteristicUuid: "00001820-0000-1000-8000-00805F9B34FB",
      descriptorUuid: "00002903-0000-1000-8000-00805F9B34FB",
      descriptorValue: bufferDesc,
    };
    
    gattClientDevice.writeDescriptorValue({
      descriptor,
      success: function () {
        console.log(`writeDescriptorValue success`);
      },
      fail: function (data, code) {
        console.log(`writeDescriptorValue fail, code = ${code}`);
      },
      complete: function () {
        console.log(`writeDescriptorValue complete`);
      }
    });
    

### [#](<#gattclientdevice-setblemtusize-object>) GattClientDevice.setBLEMtuSize(OBJECT)

client 协商远端蓝牙低功耗设备的最大传输单元（Maximum Transmission Unit, MTU）。注意：在调用 connect 接口连接成功后才能使用。

#### [#](<#oeject-对象的属性>) OEJECT 对象的属性：

属性名 | 类型 | 必填 | 说明  
---|---|---|---  
mtu | Number | 是 | 设置范围为 22~512。  
success | Function | 否 | client端发送指令成功后回调（非服务端成功）。  
fail | Function | 否 | 失败回调。  
complete | Function | 否 | 执行结束后的回调。  
  
#### [#](<#success-的回调参数-8>) success 的回调参数：

无

#### [#](<#示例-16>) 示例：
    
    
    let gattClientDevice = bluetoothBLE.createGattClientDevice("XX:XX:XX:XX:XX:XX");
    gattClientDevice.setBLEMtuSize({
      mtu: 128,
      success: function () {
        console.log(`setBLEMtuSize success`);
      },
      fail: function (data, code) {
        console.log(`setBLEMtuSize fail, code = ${code}`);
      },
      complete: function () {
        console.log(`setBLEMtuSize complete`);
      }
    });
    

### [#](<#gattclientdevice-setnotifycharacteristicchanged-object>) GattClientDevice.setNotifyCharacteristicChanged(OBJECT)

向服务端发送设置通知此特征值请求。

#### [#](<#object-对象的属性-10>) OBJECT 对象的属性：

属性名 | 类型 | 必填 | 说明  
---|---|---|---  
characteristic | [BLECharacteristic](<#BLECharacteristic>) | 是 | 蓝牙低功耗特征。  
enable | Boolean | 是 | 启用接收 notify 设置为 true，否则设置为 false。  
success | Function | 否 | client端发送指令成功后回调（非服务端成功）。  
fail | Function | 否 | 失败回调。  
complete | Function | 否 | 执行结束后的回调。  
  
#### [#](<#success-的回调参数-9>) success 的回调参数：

无

#### [#](<#示例-17>) 示例：
    
    
    let arrayBuffer = new ArrayBuffer(8);
    let descV = new Uint8Array(arrayBuffer);
    descV[0] = 11;
    let descriptor = {
      serviceUuid: "00001810-0000-1000-8000-00805F9B34FB",
      characteristicUuid: "00001820-0000-1000-8000-00805F9B34FB",
      descriptorUuid: "00002902-0000-1000-8000-00805F9B34FB",
      descriptorValue: arrayBuffer,
    };
    descriptors[0] = descriptor;
    
    let arrayBufferC = new ArrayBuffer(8);
    let characteristic = {
      serviceUuid: "00001810-0000-1000-8000-00805F9B34FB",
      characteristicUuid: "00001820-0000-1000-8000-00805F9B34FB",
      characteristicValue: arrayBufferC,
      descriptors: descriptors,
    };
    
    let gattClientDevice = bluetoothBLE.createGattClientDevice("XX:XX:XX:XX:XX:XX");
    gattClientDevice.setNotifyCharacteristicChanged({
      characteristic,
      enable: false,
      success: function () {
        console.log(`setNotifyCharacteristicChanged success`);
      },
      fail: function (data, code) {
        console.log(`setNotifyCharacteristicChanged fail, code = ${code}`);
      },
      complete: function () {
        console.log(`setNotifyCharacteristicChanged complete`);
      }
    });
    

### [#](<#gattclientdevice-onblecharacteristicchange>) GattClientDevice.onBLECharacteristicChange

订阅蓝牙低功耗设备的特征值变化事件。需要先调用 setNotifyCharacteristicChanged 接口才能接收 server 端的通知。

#### [#](<#事件回调参数>) 事件回调参数：

类型 | 说明  
---|---  
[BLECharacteristic](<#BLECharacteristic>) | 蓝牙低功耗设备的特征值。  
  
#### [#](<#示例-18>) 示例：
    
    
    let gattClientDevice = bluetoothBLE.createGattClientDevice("XX:XX:XX:XX:XX:XX");
    gattClientDevice.onBLECharacteristicChange = function (data) {
      console.log(`readCharacteristicValue uuid: ${data.characteristicUuid}`);
      if (data.characteristicValue) {
        let value = new Uint8Array(data.characteristicValue);
        console.log(`readCharacteristicValue value: ${value[0]}, ${value[1]}, ${value[2]}, ${value[3]}`);
      }
    }
    

### [#](<#gattclientdevice-onbleconnectionstatechange>) GattClientDevice.onBLEConnectionStateChange

client 端订阅蓝牙低功耗设备的连接状态变化事件。

#### [#](<#事件回调参数-2>) 事件回调参数：

类型 | 说明  
---|---  
[BLEConnectionState](<#BLEConnectionState>) | 表示连接状态。  
  
#### [#](<#示例-19>) 示例：
    
    
    let gattClientDevice = bluetoothBLE.createGattClientDevice("XX:XX:XX:XX:XX:XX");
    gattClientDevice.onBLEConnectionStateChange = function (state) {
      console.log(`onBLEConnectionStateChange state = ${state}`);
    };
    

### [#](<#gattclientdevice-getdevicename-object>) GattClientDevice.getDeviceName(OBJECT)

client 获取远端蓝牙低功耗设备名。

#### [#](<#object-对象的属性-11>) OBJECT 对象的属性：

属性名 | 类型 | 必填 | 说明  
---|---|---|---  
success | Function | 否 | 成功回调。  
fail | Function | 否 | 失败回调。  
complete | Function | 否 | 执行结束后的回调。  
  
#### [#](<#success-回调对象参数的属性>) success 回调对象参数的属性：

参数名 | 类型 | 说明  
---|---|---  
deviceName | String | client 获取对端 server 设备名，通过注册回调函数获取。  
  
#### [#](<#示例-20>) 示例：
    
    
    let gattClientDevice = bluetoothBLE.createGattClientDevice("XX:XX:XX:XX:XX:XX");
    gattClientDevice.getDeviceName({
      success: function (data) {
        console.log(`getDeviceName success, name = ${data.deviceName}`);
      },
      fail: function (data, code) {
        console.log(`getDeviceName fail, code = ${code}`);
      },
      complete: function () {
        console.log(`getDeviceName complete`);
      },
    });
    

### [#](<#gattclientdevice-getrssivalue-object>) GattClientDevice.getRssiValue(OBJECT)

client 获取远端蓝牙低功耗设备的信号强度 (Received Signal Strength Indication, RSSI)，调用 connect 接口连接成功后才能使用。

#### [#](<#object-对象的属性-12>) OBJECT 对象的属性：

属性名 | 类型 | 必填 | 说明  
---|---|---|---  
success | Function | 否 | 成功回调。  
fail | Function | 否 | 失败回调。  
complete | Function | 否 | 执行结束后的回调。  
  
#### [#](<#success-回调对象参数的属性-2>) success 回调对象参数的属性：

属性名 | 类型 | 说明  
---|---|---  
rssi | Number | 信号强度，单位 dBm，通过注册回调函数获取。  
  
#### [#](<#示例-21>) 示例：
    
    
    let gattClientDevice = bluetoothBLE.createGattClientDevice("XX:XX:XX:XX:XX:XX");
    
    gattClientDevice.getRssiValue({
      success: function (data) {
        console.log(`getRssiValue success, rssi = ${data.rssi}`);
      },
      fail: function (data, code) {
        console.log(`getRssiValue fail, code = ${code}`);
      },
      complete: function () {
        console.log(`getRssiValue complete`);
      },
    });
    

## [#](<#gattservice>) GattService

描述 GattService 的对象属性定义。

属性名 | 类型 | 可读 | 可写 | 描述  
---|---|---|---|---  
serviceUuid | String | 是 | 是 | 特定服务（service）的 UUID，例如：00001888-0000-1000-8000-00805f9b34fb。  
isPrimary | Boolean | 是 | 是 | 如果是主服务设置为 true，否则设置为 false。  
characteristics | Array<[BLECharacteristic](<#BLECharacteristic>)> | 是 | 是 | 当前服务包含的特征列表。  
includeServices | Array<[GattService](<#GattService>)> | 是 | 是 | 当前服务依赖的其它服务。  
  
## [#](<#blecharacteristic>) BLECharacteristic

描述 characteristic 的对象属性定义 。

属性名 | 类型 | 可读 | 可写 | 描述  
---|---|---|---|---  
serviceUuid | String | 是 | 是 | 特定服务（service）的 UUID，例如：00001888-0000-1000-8000-00805f9b34fb。  
characteristicUuid | String | 是 | 是 | 特定特征（characteristic）的 UUID，例如：00002a11-0000-1000-8000-00805f9b34fb。  
characteristicValue | ArrayBuffer | 是 | 是 | 特征对应的二进制值。  
descriptors | Array<[BLEDescriptor](<#BLEDescriptor>)> | 是 | 是 | 特定特征的描述符列表。  
properties | [GattProperties](<#GattProperties>) | 是 | 是 | 特定特征的属性描述。  
  
## [#](<#bledescriptor>) BLEDescriptor

描述 descriptor 的对象属性定义 。

参数名 | 类型 | 可读 | 可写 | 描述  
---|---|---|---|---  
serviceUuid | String | 是 | 是 | 特定服务（service）的 UUID，例如：00001888-0000-1000-8000-00805f9b34fb。  
characteristicUuid | String | 是 | 是 | 特定特征（characteristic）的 UUID，例如：00002a11-0000-1000-8000-00805f9b34fb。  
descriptorUuid | String | 是 | 是 | 描述符（descriptor）的 UUID，例如：00002902-0000-1000-8000-00805f9b34fb。  
descriptorValue | ArrayBuffer | 是 | 是 | 描述符对应的二进制值。  
  
## [#](<#gattproperties>) GattProperties

特定特征的属性描述定义。

属性名 | 类型 | 是否必填 | 描述  
---|---|---|---  
read | Boolean | 否 | 该特征值是否支持 read 操作。  
write | Boolean | 否 | 该特征值是否支持 write 操作。true表示需要对端设备的回复。  
writeNoResponse | Boolean | 否 | 该特征值是否支持 write 操作。true表示该特征支持写操作，无需对端设备回复。  
notify | Boolean | 否 | 该特征值是否支持 notify 操作。true表示该特征可通知对端设备。  
indicate | Boolean | 否 | 该特征值是否支持 indicate 操作。true表示该特征可通知对端设备，需要对端设备的回复。  
  
## [#](<#bleconnectionstate>) BLEConnectionState

BLE 的连接状态枚举。

名称 | 状态值 | 描述  
---|---|---  
STATE_DISCONNECTED | 0 | 表示 profile 已断连。  
STATE_CONNECTING | 1 | 表示 profile 正在连接。  
STATE_CONNECTED | 2 | 表示 profile 已连接。  
STATE_DISCONNECTING | 3 | 表示 profile 正在断连。  
  
## [#](<#状态码>) 状态码

错误码 | 描述  
---|---  
203 | 该功能不支持  
205 | 重复提交，如：gattClient 连接成功后，再次连接  
10001 | 当前系统蓝牙未打开  
10008 | 蓝牙未知错误  
10012 | 连接错误  
10013 | 无内存或连接资源  
10014 | 没有找到指定蓝牙设备  
  
## [#](<#后台运行限制>) 后台运行限制

禁止使用。

## [#](<#支持明细>) 支持明细

设备产品 | 说明  
---|---  
小米 S1 Pro 运动健康手表 | 不支持  
小米手环 8 Pro | 不支持  
小米手环 9 / 9 Pro | 不支持  
Xiaomi Watch S3 | 不支持  
Redmi Watch 4 | 不支持  
小米腕部心电血压记录仪 | 不支持  
小米手环 10 | 不支持  
Xiaomi Watch S4 | 不支持  
REDMI Watch 5 | 不支持  
REDMI Watch 6 | 不支持  
Xiaomi Watch S5 | 支持

---

## #屏幕亮度 brightness

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/system/brightness.html](https://iot.mi.com/vela/quickapp/zh/features/system/brightness.html)

# [#](<#屏幕亮度-brightness>) 屏幕亮度 brightness

## [#](<#接口声明>) 接口声明
    
    
    { "name": "system.brightness" }
    

## [#](<#导入模块>) 导入模块
    
    
    import brightness from '@system.brightness' 
    // 或 
    const brightness = require('@system.brightness')
    

## [#](<#接口定义>) 接口定义

### [#](<#brightness-getvalue-object>) brightness.getValue(OBJECT)

获得当前屏幕亮度值

#### [#](<#参数>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#success-返回值>) success 返回值：

参数值 | 类型 | 说明  
---|---|---  
value | Integer | 屏幕亮度，取值范围 0-255  
  
#### [#](<#示例>) 示例：
    
    
    brightness.getValue({
      success: function(data) {
        console.log(`handling success, value = ${data.value}`)
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

### [#](<#brightness-setvalue-object>) brightness.setValue(OBJECT)

设置当前屏幕亮度值

#### [#](<#参数-2>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
value | Integer | 是 | 屏幕亮度，取值范围 0-255  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#示例-2>) 示例：
    
    
    brightness.setValue({
      value: 100,
      success: function() {
        console.log('handling success')
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

### [#](<#brightness-getmode-object>) brightness.getMode(OBJECT)

获得当前屏幕亮度模式

#### [#](<#参数-3>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#success-返回值-2>) success 返回值：

参数值 | 类型 | 说明  
---|---|---  
mode | Integer | 0 为手动调节屏幕亮度，1 为自动调节屏幕亮度  
  
#### [#](<#示例-3>) 示例：
    
    
    brightness.getMode({
      success: function(data) {
        console.log(`handling success, mode = ${data.mode}`)
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

### [#](<#brightness-setmode-object>) brightness.setMode(OBJECT)

设置当前屏幕亮度模式

#### [#](<#参数-4>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
mode | Integer | 是 | 0 为手动调节屏幕亮度，1 为自动调节屏幕亮度  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#示例-4>) 示例：
    
    
    brightness.setMode({
      mode: 1,
      success: function() {
        console.log('handling success')
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

### [#](<#brightness-setkeepscreenon-object>) brightness.setKeepScreenOn(OBJECT)

设置是否保持常亮状态

#### [#](<#参数-5>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
keepScreenOn | Boolean | 是 | 是否保持屏幕常亮  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#示例-5>) 示例：
    
    
    brightness.setKeepScreenOn({
      keepScreenOn: true,
      success: function() {
        console.log('handling success')
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })

---

## #事件 event4+

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/system/event.html](https://iot.mi.com/vela/quickapp/zh/features/system/event.html)

# [#](<#事件-event>) 事件 event[4+](</vela/quickapp/zh/guide/version/APILevel4>)

## [#](<#接口声明>) 接口声明
    
    
    { "name": "system.event" }
    

## [#](<#导入模块>) 导入模块
    
    
    import event from '@system.event' 
    // 或 
    const event = require('@system.event')
    

## [#](<#接口定义>) 接口定义

### [#](<#event-publish-object>) event.publish (OBJECT)

发布公共事件

#### [#](<#参数>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
eventName | String | 是 | 事件名称，公共事件保留名称被系统占用，请勿使用  
options | Object | 否 | 事件参数  
  
#### [#](<#options-参数>) options 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
params | Object | 否 | 事件参数  
permissions | Array<String> | 否 | 订阅者的权限，拥有权限的包才能收到发送的事件  
  
#### [#](<#系统支持的公共事件>) 系统支持的公共事件：

系统内部事件名称 | 订阅者所需权限 | 说明  
---|---|---  
usual.event.BATTERY_CHANGED | 无 | 电量改变，参数：level:0.0 - 1.0 之间  
usual.event.DISCHARGING | 无 | 停止充电  
usual.event.CHARGING | 无 | 开始充电  
  
#### [#](<#返回值>) 返回值：

无

#### [#](<#示例>) 示例：
    
    
    event.publish({
      eventName: 'myEventName',
      options: {
        params: { age: 10, name: 'peter' },
        permissions: ['com.example.demo']
      }
    })
    

### [#](<#event-subscribe-object>) event.subscribe(OBJECT)

订阅公共事件

#### [#](<#参数-2>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
eventName | String | 是 | 事件名称  
callback | Function | 是 | 回调函数  
  
#### [#](<#回调参数>) 回调参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
params | Object | 否 | 事件参数  
package | String | 否 | 事件推送者包名  
  
#### [#](<#返回值-2>) 返回值：

类型 | 必填 | 说明  
---|---|---  
Number | 是 | 事件id，订阅失败返回undefined  
  
#### [#](<#示例-2>) 示例：
    
    
    const evtId = event.subscribe({
      eventName: 'myEventName',
      callback: function(res) {
        if (res.package === 'com.example.demo') {
          console.log(res.params)
        }
      }
    })
    console.log(evtId)
    

### [#](<#event-unsubscribe-object>) event.unsubscribe(OBJECT)

取消订阅公共事件

#### [#](<#参数-3>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
id | Number | 是 | 订阅id  
  
#### [#](<#示例-3>) 示例：
    
    
    const evtId = event.subscribe({
      eventName: 'myEventName',
      callback: function(res) {
        if (res.package === 'com.example.demo') {
          console.log(res.params)
        }
      }
    })
    
    event.unsubscribe({ id: evtId })
    

## [#](<#支持明细>) 支持明细

设备产品 | 说明  
---|---  
小米 S1 Pro 运动健康手表 | 不支持  
小米手环 8 Pro | 不支持  
小米手环 9 / 9 Pro | 不支持  
Xiaomi Watch S3 | 不支持  
Redmi Watch 4 | 不支持  
小米腕部心电血压记录仪 | 不支持  
小米手环 10 | 支持  
Xiaomi Watch S4 | 支持  
REDMI Watch 5 | 支持  
REDMI Watch 6 | 支持  
Xiaomi Watch S5 | 支持

---

## #地理位置 geolocation

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/system/geolocation.html](https://iot.mi.com/vela/quickapp/zh/features/system/geolocation.html)

# [#](<#地理位置-geolocation>) 地理位置 geolocation

## [#](<#接口声明>) 接口声明
    
    
    { "name": "system.geolocation" }
    

## [#](<#导入模块>) 导入模块
    
    
    import geolocation from '@system.geolocation' 
    // 或 
    const geolocation = require('@system.geolocation')
    

## [#](<#接口定义>) 接口定义

### [#](<#geolocation-getlocation-object>) geolocation.getLocation(OBJECT)

获取地理位置

#### [#](<#权限要求>) 权限要求

精确设备定位

开发者需要在 manifest.json 里面配置权限：
    
    
    {
      "permissions": [
        { "name": "hapjs.permission.LOCATION" }
      ]
    }
    

#### [#](<#参数>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
timeout | Number | 否 | 设置超时时间，单位是 ms，默认值为 30000  
success | Function | 是 | 成功回调  
fail | Function | 否 | 失败回调，可能是因为缺乏权限  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#success-返回值>) success 返回值：

参数名 | 类型 | 说明  
---|---|---  
longitude | Number | 经度，浮点数  
latitude | Number | 纬度，浮点数  
altitude | Number | 海拔、高度，单位m，浮点数  
speed | Number | 速度值，单位m/s，浮点数  
accuracy | Number | 精确度，值为正整数  
accuracyInfo | { horizontal: Number, vertical: Number } | 精确度信息，包含水平和垂直方向精准度  
  
#### [#](<#fail-返回错误代码>) fail 返回错误代码：

错误码 | 说明  
---|---  
203 | 该功能不支持  
204 | 超时返回  
  
#### [#](<#示例>) 示例：
    
    
    geolocation.getLocation({
      success: function(data) {
        console.log(
          `handling success: longitude = ${data.longitude}, latitude = ${
            data.latitude
          }, speed = ${data.speed}, altitude = ${data.altitude}`
        )
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}, errorMsg=${data}`)
      }
    })
    

### [#](<#geolocation-subscribe-object>) geolocation.subscribe(OBJECT)

监听地理位置。如果多次调用，仅最后一次调用生效

#### [#](<#权限要求-2>) 权限要求

精确设备定位

开发者需要在 manifest.json 里面配置权限：
    
    
    {
      "permissions": [
        { "name": "hapjs.permission.LOCATION" }
      ]
    }
    

#### [#](<#参数-2>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
callback | Function | 是 | 每次位置信息发生变化，都会被回调  
fail | Function | 否 | 失败回调  
  
#### [#](<#callback-返回值>) callback 返回值：

参数名 | 类型 | 说明  
---|---|---  
longitude | Number | 经度，浮点数  
latitude | Number | 纬度，浮点数  
altitude | Number | 海拔、高度，单位m，浮点数  
speed | Number | 速度值，单位m/s，浮点数  
accuracy | Number | 精确度，值为正整数  
  
#### [#](<#fail-返回错误代码-2>) fail 返回错误代码：

错误码 | 说明  
---|---  
203 | 该功能不支持  
  
#### [#](<#示例-2>) 示例：
    
    
    geolocation.subscribe({
      callback: function(data) {
        console.log(
          `handling success: longitude = ${data.longitude}, latitude = ${
            data.latitude
          }, speed = ${data.speed}, altitude = ${data.altitude}`
        )
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}, errorMsg=${data}`)
      }
    })
    

### [#](<#geolocation-unsubscribe>) geolocation.unsubscribe()

取消监听地理位置

#### [#](<#权限要求-3>) 权限要求

精确设备定位

开发者需要在 manifest.json 里面配置权限：
    
    
    {
      "permissions": [
        { "name": "hapjs.permission.LOCATION" }
      ]
    }
    

#### [#](<#参数-3>) 参数：

无

#### [#](<#示例-3>) 示例：
    
    
    geolocation.unsubscribe()
    

## [#](<#支持明细>) 支持明细

设备产品 | 说明  
---|---  
小米 S1 Pro 运动健康手表 | 不支持  
小米手环 8 Pro | 不支持  
小米手环 9 / 9 Pro | 不支持  
Xiaomi Watch S3 | 支持  
Redmi Watch 4 | 不支持  
小米腕部心电血压记录仪 | 不支持  
小米手环 10 | 不支持  
Xiaomi Watch S4 | 支持  
REDMI Watch 5 | 支持  
REDMI Watch 6 | 支持  
Xiaomi Watch S5 | 支持

---

## #网络信息 network

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/system/network.html](https://iot.mi.com/vela/quickapp/zh/features/system/network.html)

# [#](<#网络信息-network>) 网络信息 network

## [#](<#接口声明>) 接口声明
    
    
    { "name": "system.network" }
    

## [#](<#导入模块>) 导入模块
    
    
    import network from '@system.network' 
    // 或 
    const network = require('@system.network')
    

## [#](<#接口定义>) 接口定义

### [#](<#network-gettype-object>) network.getType(OBJECT)

获取网络类型

#### [#](<#参数>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调，可能是因为缺乏权限  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#success-返回object值>) success 返回Object值：

参数名 | 类型 | 说明  
---|---|---  
type | String | 网络类型，可能的值为 2g，3g，4g，wifi，none，5g，bluetooth，others  
  
#### [#](<#示例>) 示例：
    
    
    network.getType({
      success: function(data) {
        console.log(`handling success: ${data.type}`)
      }
    })
    

### [#](<#network-subscribe-object>) network.subscribe(OBJECT)

监听网络类型变化。如果多次调用，仅最后一次调用生效

#### [#](<#参数-2>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
callback | Function | 否 | 每次网络发生变化，都会被回调  
fail | Function | 否 | 失败回调，可能是因为缺乏权限  
  
#### [#](<#callback-返回object值>) callback 返回Object值：

参数名 | 类型 | 说明  
---|---|---  
type | String | 网络类型，可能的值为 2g，3g，4g，wifi，none，5g，bluetooth，others。注：网络类型为 none 以外的值并不保证设备一定能访问到目标服务器，需要请求接口进行判断  
  
#### [#](<#示例-2>) 示例：
    
    
    network.subscribe({
      callback: function(data) {
        console.log(`handling callback ${data.type}`)
      }
    })
    

### [#](<#network-unsubscribe>) network.unsubscribe()

取消监听网络类型变化

#### [#](<#参数-3>) 参数：

无

#### [#](<#示例-3>) 示例：
    
    
    network.unsubscribe()
    

## [#](<#支持明细>) 支持明细

设备产品 | 说明  
---|---  
小米 S1 Pro 运动健康手表 | 支持  
小米手环 8 Pro | 不支持  
小米手环 9 / 9 Pro | 不支持  
Xiaomi Watch S3 | 支持  
Redmi Watch 4 | 不支持  
小米腕部心电血压记录仪 | 不支持  
小米手环 10 | 不支持  
Xiaomi Watch S4 | 支持  
REDMI Watch 5 | 支持  
REDMI Watch 6 | 支持  
Xiaomi Watch S5 | 支持

---

## #录音 record

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/system/record.html](https://iot.mi.com/vela/quickapp/zh/features/system/record.html)

# [#](<#录音-record>) 录音 record

## [#](<#接口声明>) 接口声明
    
    
    { "name": "system.record" }
    

## [#](<#导入模块>) 导入模块
    
    
    import record from '@system.record' 
    // 或 
    const record = require('@system.record')
    

## [#](<#接口定义>) 接口定义

### [#](<#record-start-object>) record.start(OBJECT)

开始录音

#### [#](<#参数>) 参数：

参数名 | 类型 | 必填 | 默认值 | 说明  
---|---|---|---|---  
duration | Number | 否 | 0 | 录音时长，单位为 ms。如果 duration 为有效值将在达到指定值时停止录音，默认为0开始录音不做定时终止，需要通过调用stop方法终止录音。若录音过程中被打断会立刻返回录音结果。  
sampleRate | Number | 否 | 8000 | 采样率。不同的音频格式所支持的采样率范围不同。默认设置为 8000，建议使用 8000/16000/32000/44100/48000  
numberOfChannels | Number | 否 | 1 | 录音通道数，有效值 1/2  
encodeBitRate | Number | 否 | 128000 | 编码码率。编码码率的取值与采样率和音频格式有关，参考下表中比特率数值，输入错误的值会使用根据采样率及通道数计算出的比特率值。  
frameSize | Number | 否 | - | PCM音频数据帧大小，单位 Byte。传入 frameSize 后，每录制指定帧大小的内容后，会通过 onframerecorded 回调录制的文件内容，不指定则不会回调。注意：回调帧数据大小不一定是设置的frameSize，有可能会调整为一个合适的值；设置此参数时，success回调将不返回uri；传入非法值（例如：小于等于零的数）时，success 回调的uri正常返回，onframerecorded事件将不会触发  
format | String | 否 | pcm | 音频格式，有效值 pcm/opus/wav。缺省为 pcm  
success | Function | 否 | - | 录音完成成功回调  
fail | Function | 否 | - | 录音过程中失败回调  
complete | Function | 否 | - | 录音结束后的回调  
  
#### [#](<#pcm-wav-比特率参考>) PCM / WAV 比特率参考

对于pcm/wav录音场景，如果输入的是错误的比特率，编码器会根据采样率和通道数计算出比特率。

采样率 (Hz) | 声道数 | 比特率 (bp/s)  
---|---|---  
8000 | 1 | 128000  
8000 | 2 | 256000  
16000 | 1 | 256000  
16000 | 2 | 512000  
32000 | 1 | 512000  
32000 | 2 | 1024000  
44100 | 1 | 705600  
44100 | 2 | 1411200  
48000 | 1 | 768000  
48000 | 2 | 1536000  
  
#### [#](<#opus-比特率参考>) Opus 比特率参考

当使用opus格式录音时，下面表中的比特率范围对应着特定的采样率和声道数，这样的编码压缩比算法效率是最好的。当设置的比特率不在此范围时，也可以正常录音，但压缩比和算法效率不是最佳。

采样率 (Hz) | 声道数 | 比特率 (bp/s)  
---|---|---  
8000 | 1 | 8363 ~ 12800  
8000 | 2 | 13892 ~ 19200  
12000 | 1 | 11975 ~ 20400  
12000 | 2 | 25427 ~ 34400  
16000 | 1 | 14221 ~ 22800  
16000 | 2 | 31651 ~ 44000  
24000 | 1 | 24892 ~ 34000  
24000 | 2 | 47685 ~ 64800  
48000 | 1 | 50077 ~ 67200  
48000 | 2 | 98554 ~ 103600  
  
#### [#](<#success-返回值>) success 返回值：

参数名 | 类型 | 说明  
---|---|---  
uri | String | 录音文件的存储路径，在应用的缓存目录中  
  
#### [#](<#fail-返回错误码>) fail 返回错误码：

错误码 | 说明  
---|---  
200 | 系统空间不足  
205 | 录音已在进行中  
202 | 参数错误  
  
#### [#](<#示例>) 示例：
    
    
    record.start({
      duration: 10000,
      sampleRate: 8000,
      numberOfChannels: 1,
      encodeBitRate: 128000,
      format: 'pcm',
      success: function(data) {
        console.log(`handling success: ${data.uri}`)
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}, errorMsg=${data}`)
      },
      complete: function () {
        console.log(`handling complete`)
      }
    })
    

### [#](<#record-stop>) record.stop()

停止录音

#### [#](<#参数-2>) 参数：

无

#### [#](<#示例-2>) 示例：
    
    
    record.stop()
    

## [#](<#事件>) 事件

### [#](<#record-onframerecorded>) record.onframerecorded

监听已录制完指定帧大小的文件事件。如果设置了 frameSize，则会回调此事件。

#### [#](<#回调object参数>) 回调Object参数：

参数名 | 类型 | 说明  
---|---|---  
frameBuffer | Uint8Array | 录制的音频数据帧。通常音频数据帧大小为指定的 bufferSize，但是如果指定的 bufferSize 太小则会自动调整为一个合适的大小。  
isLastFrame | boolean | 是否是最后一帧数据。  
  
#### [#](<#示例-3>) 示例：
    
    
    record.onframerecorded = function (res) {
      // 获取音频数据：res.frameBuffer
      // 是否是最后一帧：res.isLastFrame
      console.log('==== onframerecorded', res)
    }
    

注意：

  1. 当录音被打断时，结束当前录制并调用成功回调录制文件地址，调用完成回调结束前次录制；
  2. 当前frameSize大小受限于底层socket单次数据传输的大小，有效范围最大值为4096，设置大于此范围按最大值生效；
  3. 当正在进行录音过程中，有如下操作：SCO电话、Ring铃声、Alarm闹钟、Enforced求救音、Notify通知消息、开启另外一个录音，这些操作会抢夺音频焦点打断当前录音，使其状态变更为stop。被打断的录音会调用success并返回录制uri（文件录音）以及complete回调，流式录音onframerecorded会上报最后一帧完成录制。
  4. 目前产品上bes层针对采样率16000单声道的录制有增益处理，录制出的音频音量比其他配置音量大。


## [#](<#支持明细>) 支持明细

设备产品 | 说明  
---|---  
小米 S1 Pro 运动健康手表 | 不支持  
小米手环 8 Pro | 不支持  
小米手环 9 / 9 Pro | 不支持  
Xiaomi Watch S3 | 不支持  
Redmi Watch 4 | 不支持  
小米腕部心电血压记录仪 | 不支持  
小米手环 10 | 不支持  
Xiaomi Watch S4 | 不支持  
REDMI Watch 5 | 不支持  
REDMI Watch 6 | 不支持  
Xiaomi Watch S5 | 支持

---

## #传感器 sensor

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/system/sensor.html](https://iot.mi.com/vela/quickapp/zh/features/system/sensor.html)

# [#](<#传感器-sensor>) 传感器 sensor

## [#](<#接口声明>) 接口声明
    
    
    { "name": "system.sensor" }
    

## [#](<#导入模块>) 导入模块
    
    
    import sensor from '@system.sensor' 
    // 或 
    const sensor = require('@system.sensor')
    

## [#](<#接口定义>) 接口定义

### [#](<#方法>) 方法

### [#](<#sensor-subscribepressure-object>) sensor.subscribePressure(OBJECT)

监听压力、压强感应数据。如果多次调用，仅最后一次调用生效

#### [#](<#参数>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
callback | Function | 是 | 每次位置信息发生变化，都会被回调  
  
#### [#](<#callback-返回值>) callback 返回值：

参数名 | 类型 | 说明  
---|---|---  
pressure | Number | 压力、压强，单位hpa，百帕，浮点数  
  
#### [#](<#示例>) 示例：
    
    
    sensor.subscribePressure({
      callback: function(ret) {
        console.log(`handling callback, pressure = ${ret.pressure}`)
      }
    })
    

### [#](<#sensor-unsubscribepressure>) sensor.unsubscribePressure()

取消压力、压强感应数据

#### [#](<#参数-2>) 参数：

无

#### [#](<#示例-2>) 示例：
    
    
    sensor.unsubscribePressure()
    

### [#](<#sensor-subscribeaccelerometer-object>) sensor.subscribeAccelerometer(OBJECT)

监听加速度感应数据

#### [#](<#参数-3>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
interval | String | 否 | 监听加速度数据回调函数的执行频率，默认normal  
callback | Function | 是 | 重力感应数据变化后会回调此函数  
fail | Function | 否 | 订阅错误回调  
  
#### [#](<#interval-的合法值>) interval 的合法值：

值 | 说明  
---|---  
game | 适用于更新游戏的回调频率，在 20ms/次 左右  
ui | 适用于更新 UI 的回调频率，在 60ms/次 左右  
normal | 普通的回调频率，在 200ms/次 左右  
  
#### [#](<#callback-返回值-2>) callback 返回值：

参数名 | 类型 | 说明  
---|---|---  
x | Number | x 轴坐标  
y | Number | y 轴坐标  
z | Number | z 轴坐标  
  
#### [#](<#示例-3>) 示例：
    
    
    sensor.subscribeAccelerometer({
      callback: function(ret) {
        console.log(`handling callback, x = ${ret.x}, y = ${ret.y}, z = ${ret.z}`)
      },
      fail: function(msg, code) {
        console.log(`handling callback, fail:`, msg, code)
      }
    })
    

### [#](<#sensor-unsubscribeaccelerometer>) sensor.unsubscribeAccelerometer()

取消监听加速度感应数据

#### [#](<#参数-4>) 参数：

无

#### [#](<#示例-4>) 示例：
    
    
    sensor.unsubscribeAccelerometer()
    

### [#](<#sensor-subscribecompass-object>) sensor.subscribeCompass(OBJECT)

监听罗盘数据。如果多次调用，仅最后一次调用生效

#### [#](<#参数-5>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
callback | Function | 是 | 罗盘数据变化后会回调此函数  
fail | Function | 否 | 订阅失败回调  
  
#### [#](<#callback-返回值-3>) callback 返回值：

参数名 | 类型 | 说明  
---|---|---  
direction | Number | 表示设备的 y 轴和地球磁场北极之间的角度，当面朝北，角度为 0；朝南角度为 π；朝东角度 π/2；朝西角度-π/2  
accuracy | Number | 精度，详见compass精度说明  
  
#### [#](<#fail-返回错误代码>) fail 返回错误代码：

错误码 | 说明  
---|---  
1000 | 当前设备不支持罗盘传感器  
  
#### [#](<#示例-5>) 示例：
    
    
    sensor.subscribeCompass({
      callback: function (res) {
        console.log(`handling subscribeCompass callback, direction = ${res.direction}, accuracy = ${res.accuracy}`)
      },
      fail: function (data, code) {
        console.log(`handling subscribeCompass fail, code = ${code}`)
      }
    })
    

### [#](<#sensor-unsubscribecompass>) sensor.unsubscribeCompass()

取消监听加速度感应数据

#### [#](<#参数-6>) 参数：

无

#### [#](<#示例-6>) 示例：
    
    
    sensor.unsubscribeCompass()
    

### [#](<#compass精度说明>) compass精度说明：

值 | 说明  
---|---  
3 | 高精度  
2 | 中等精度  
1 | 低精度  
-1 | 不可信，传感器失去连接  
0 | 不可信，原因未知  
  
## [#](<#支持明细>) 支持明细

接口 | 已支持设备产品 | 不支持设备产品  
---|---|---  
subscribePressure | Xiaomi Watch S3、小米手环 9 Pro、小米手环 10、Xiaomi Watch S4、Xiaomi Watch S5 | 小米 S1 Pro 运动健康手表、小米手环 8 Pro、小米手环 9、Redmi Watch 4、Xiaomi Watch H1、REDMI Watch 5、REDMI Watch 6  
unsubscribePressure | Xiaomi Watch S3、小米手环 9 Pro、小米手环 10、Xiaomi Watch S4、Xiaomi Watch S5 | 小米 S1 Pro 运动健康手表、小米手环 8 Pro、小米手环 9、Redmi Watch 4、Xiaomi Watch H1、REDMI Watch 5、REDMI Watch 6  
subscribeAccelerometer | 小米手环 9 / 9 Pro、小米手环 10、Xiaomi Watch S5 | Xiaomi Watch S3、小米 S1 Pro 运动健康手表、小米手环 8 Pro、Redmi Watch 4、Xiaomi Watch H1、Xiaomi Watch S4、REDMI Watch 5、REDMI Watch 6  
unsubscribeAccelerometer | 小米手环 9 / 9 Pro、小米手环 10、Xiaomi Watch S5 | Xiaomi Watch S3、小米 S1 Pro 运动健康手表、小米手环 8 Pro、Redmi Watch 4、Xiaomi Watch H1、Xiaomi Watch S4、REDMI Watch 5、REDMI Watch 6  
subscribeCompass / unsubscribeCompass | Xiaomi Watch S4、REDMI Watch 5 、REDMI Watch 6、Xiaomi Watch S5 | 其余小米环表设备

---

## #振动 vibrator

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/system/vibrator.html](https://iot.mi.com/vela/quickapp/zh/features/system/vibrator.html)

# [#](<#振动-vibrator>) 振动 vibrator

## [#](<#接口声明>) 接口声明
    
    
    { "name": "system.vibrator" }
    

## [#](<#导入模块>) 导入模块
    
    
    import vibrator from '@system.vibrator' 
    // 或 
    const vibrator = require('@system.vibrator')
    

## [#](<#接口定义>) 接口定义

### [#](<#vibrator-vibrate-object>) vibrator.vibrate(OBJECT)

触发振动

#### [#](<#参数>) 参数：

参数 | 类型 | 必填 | 说明  
---|---|---|---  
mode | String | 否 | 振动模式，"long"表示长振动，"short"表示短振动。默认为 long  
  
#### [#](<#示例>) 示例：
    
    
    vibrator.vibrate({
      mode: 'long'
    })
    

### [#](<#vibrator-start-object>) vibrator.start(OBJECT)

开始振动

#### [#](<#参数-2>) 参数：

参数 | 类型 | 必填 | 说明  
---|---|---|---  
duration | Number | 是 | 振动持续时间(单位 ms)，必须为正整数  
interval | Number | 是 | 振动间隔时间(单位 ms)，必须为正整数  
count | Number | 是 | 振动次数，必须为正整数  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#success-返回值>) success 返回值：

参数名 | 类型 | 说明  
---|---|---  
id | Number | 唯一的 ID，标识振动任务  
  
#### [#](<#fail-返回值>) fail 返回值：

错误码 | 说明  
---|---  
205 | 任务已存在  
202 | 参数错误  
  
#### [#](<#示例-2>) 示例：
    
    
    vibrator.start({
      duration: 1000,
      interval: 1000,
      count: 10,
      success: function (data) {
        console.log(`handling success, id = ${data.id}`)
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}, errorMsg=${data}`)
      },
      complete: function () {
        console.log(`handling complete`)
      }
    })
    

### [#](<#vibrator-stop-number>) vibrator.stop(Number)

停止振动

#### [#](<#参数-3>) 参数：

类型 | 必填 | 说明  
---|---|---  
Number | 是 | 振动任务 ID  
  
#### [#](<#返回值>) 返回值：

类型 | 说明  
---|---  
Boolean | true：成功；false：失败  
  
#### [#](<#示例-3>) 示例：
    
    
    vibrator.stop(1)
    

### [#](<#vibrator-getsystemdefaultmode>) vibrator.getSystemDefaultMode()

获取系统默认振动模式

#### [#](<#参数-4>) 参数：

无

#### [#](<#返回值-2>) 返回值：

类型 | 说明  
---|---  
Number | 0：关闭振动；1：标准振动；2：加强振动  
  
#### [#](<#示例-4>) 示例：
    
    
    vibrator.getSystemDefaultMode()
    

## [#](<#支持明细>) 支持明细

接口 | 已支持设备产品 | 不支持设备产品  
---|---|---  
vibrate | 小米 S1 Pro 运动健康手表、小米手环 8 Pro、小米手环 9 / 9 Pro、Redmi Watch 4、Xiaomi Watch H1、Xiaomi Watch S3、小米手环 10、Xiaomi Watch S4、REDMI Watch 5、REDMI Watch 6、Xiaomi Watch S5 | -  
start | Xiaomi Watch S5 | Xiaomi Watch S3、Xiaomi Watch S4、REDMI Watch 5、REDMI Watch 6、小米 S1 Pro 运动健康手表、小米手环 8 Pro、小米手环 9 / 9 Pro、小米手环 10、Redmi Watch 4、Xiaomi Watch H1  
stop | Xiaomi Watch S5 | Xiaomi Watch S3、Xiaomi Watch S4、REDMI Watch 5、REDMI Watch 6、小米 S1 Pro 运动健康手表、小米手环 8 Pro、小米手环 9 / 9 Pro、小米手环 10、Redmi Watch 4、Xiaomi Watch H1  
getSystemDefaultMode | Xiaomi Watch S5 | Xiaomi Watch S3、Xiaomi Watch S4、REDMI Watch 5、REDMI Watch 6、小米 S1 Pro 运动健康手表、小米手环 8 Pro、小米手环 9 / 9 Pro、小米手环 10、Redmi Watch 4、Xiaomi Watch H1

---

## #系统音量 volume

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/system/volume.html](https://iot.mi.com/vela/quickapp/zh/features/system/volume.html)

# [#](<#系统音量-volume>) 系统音量 volume

## [#](<#接口声明>) 接口声明
    
    
    { "name": "system.volume" }
    

## [#](<#导入模块>) 导入模块
    
    
    import volume from '@system.volume' 
    // 或 
    const volume = require('@system.volume')
    

## [#](<#接口定义>) 接口定义

### [#](<#volume-getmediavalue-object>) volume.getMediaValue (OBJECT)

获取当前多媒体音量

#### [#](<#参数>) 参数

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#success-返回值>) success 返回值：

参数值 | 类型 | 说明  
---|---|---  
value | Number | 系统媒体当前音量，0.0-1.0 之间  
  
#### [#](<#示例>) 示例
    
    
    volume.getMediaValue({
      success: function(data) {
        console.log(`handling success: ${data.value}`)
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

### [#](<#volume-setmediavalue-object>) volume.setMediaValue (OBJECT)

设置当前多媒体音量

#### [#](<#参数-2>) 参数

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
value | Number | 是 | 设置的音量，0.0-1.0 之间  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#fail-返回值>) fail 返回值：

[支持通用错误码](</vela/quickapp/zh/features/grammar.html#通用错误码>)

#### [#](<#示例-2>) 示例
    
    
    volume.setMediaValue({
      value: 0.5,
      success: function() {
        console.log('handling success')
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

## [#](<#事件>) 事件

### [#](<#volume-onmediavaluechanged>) volume.onMediaValueChanged

多媒体音量发生变化事触发

#### [#](<#回调object参数>) 回调Object参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
value | Number | 是 | 系统媒体当前音量，范围：0.0-1.0 之间  
  
#### [#](<#示例-3>) 示例
    
    
    volume.onMediaValueChanged = function(res) {
      console.log('volume media value changed:', res.value)
    }

---

## #解压缩 zip

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/system/zip.html](https://iot.mi.com/vela/quickapp/zh/features/system/zip.html)

# [#](<#解压缩-zip>) 解压缩 zip

## [#](<#接口声明>) 接口声明
    
    
    { "name": "system.zip" }
    

## [#](<#导入模块>) 导入模块
    
    
    import zip from '@system.zip'
    // 或
    const zip = require('@system.zip')
    

## [#](<#接口定义>) 接口定义

### [#](<#zip-decompress-object>) zip.decompress(OBJECT)

解压文件

#### [#](<#参数>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
srcUri | String | 是 | 源文件的 uri，不能是 tmp 类型的 uri  
dstUri | String | 是 | 目标目录的 uri，不能是应用资源路径和 tmp 类型的 uri  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#success-返回值>) success 返回值：

无

#### [#](<#fail-返回值>) fail 返回值：

错误码 | 说明  
---|---  
202 | 参数错误  
300 | I/O 错误  
  
#### [#](<#示例>) 示例：
    
    
    zip.decompress({
      srcUri: 'internal://cache/test.zip',
      dstUri: 'internal://files/unzip/',
      success: function() {
        console.log(`handling success`)
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })

---

