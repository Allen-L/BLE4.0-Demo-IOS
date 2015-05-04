//
//  BLEmanager.m
//  BLE4.0Demo
//
//  Created by kakaxi on 15/4/17.
//  Copyright (c) 2015年 kakaxi Email:631965569@qq.com  . All rights reserved.
//

#import "BLEmanager.h"
#import "BlePeripheral.h"
@implementation BLEmanager
@synthesize m_manger;
@synthesize m_peripheral;
@synthesize m_array_peripheral;
@synthesize mange_delegate;



//单例
#undef	AS_SINGLETON
#define AS_SINGLETON( __class ) \
+ (__class *)sharedInstance;

#undef	DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
+ (__class *)sharedInstance \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[__class alloc] init]; } ); \
return __singleton__; \
}

static BLEmanager *sharedBLEmanger=nil;
-(id)init
{
    self = [super init];
    if (self) {
        if (!m_array_peripheral) {
            
            m_manger = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
            //m_peripheral = [[CBPeripheral alloc]init];
        

            m_array_peripheral = [[NSMutableArray alloc]init];
        }
    }
    return self;
}


+(BLEmanager *)shareInstance;
{
    @synchronized(self){
        if (sharedBLEmanger == nil) {
            sharedBLEmanger = [[self alloc]init];
        }
    }
    return sharedBLEmanger;
}

-(void)initCentralManger;
{
    m_manger = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central;
{
    if (central.state == CBCentralManagerStatePoweredOff) {
        NSLog(@"系统蓝牙关闭了，请先打开蓝牙");
    }else{
        //可以自己判断其他的类型
        /*
         CBCentralManagerStateUnknown = 0,
         CBCentralManagerStateResetting,
         CBCentralManagerStateUnsupported,
         CBCentralManagerStateUnauthorized,
         CBCentralManagerStatePoweredOff,
         CBCentralManagerStatePoweredOn,
         */
    }
}

/*!
 *  @method centralManager:didDiscoverPeripheral:advertisementData:RSSI:
 *
 *  @param central              The central manager providing this update.
 *  @param peripheral           A <code>CBPeripheral</code> object.
 *  @param advertisementData    A dictionary containing any advertisement and scan response data.
 *  @param RSSI                 The current RSSI of <i>peripheral</i>, in dBm. A value of <code>127</code> is reserved and indicates the RSSI
 *								was not available.
 *
 *  @discussion                 This method is invoked while scanning, upon the discovery of <i>peripheral</i> by <i>central</i>. A discovered peripheral must
 *                              be retained in order to use it; otherwise, it is assumed to not be of interest and will be cleaned up by the central manager. For
 *                              a list of <i>advertisementData</i> keys, see {@link CBAdvertisementDataLocalNameKey} and other similar constants.
 *
 *  @seealso                    CBAdvertisementData.h
 *
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
{
    
    //这个方法是一旦扫描到外设就会调用的方法，注意此时并没有连接上外设，这个方法里面，你可以解析出当前扫描到的外设的广播包信息，当前RSSI等，现在很多的做法是，会根据广播包带出来的设备名，初步判断是不是自己公司的设备，才去连接这个设备，就是在这里面进行判断的
    
    NSString *localName = [advertisementData valueForKey:@"kCBAdvDataLocalName"];
   // NSLog(@"localName = %@ RSSI = %@",localName,RSSI);
    
    
    NSArray *services = [advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
    
    
    NSLog(@"advertisementData = %@",advertisementData);
    
    BOOL isExist = [self comparePeripheralisEqual:peripheral RSSI:RSSI];
    if (!isExist) {
        BlePeripheral *l_per = [[BlePeripheral alloc]init];
        l_per.m_peripheral = peripheral;
        l_per.m_peripheralIdentifier = [peripheral.identifier UUIDString];
        l_per.m_peripheralLocaName = localName;
        l_per.m_peripheralRSSI = RSSI;
        l_per.m_peripheralUUID       =  (__bridge NSString *)(CFUUIDCreateString(NULL, peripheral.UUID)); //IOS 7.0 之后弃用了，功能和 identifier 一样
        
        //[NSTemporaryDirectory()stringByAppendingPathComponent:[NSStringstringWithFormat:@"%@-%@", prefix, uuidStr]]
        l_per.m_peripheralServices   = [services count];
        
    
        [m_array_peripheral addObject:l_per];
    }
    
 
}
/*!
 *  @method centralManager:didConnectPeripheral:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has connected.
 *
 *  @discussion         This method is invoked when a connection initiated by {@link connectPeripheral:options:} has succeeded.
 *
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;
{
    
    [m_manger stopScan];
    
    m_peripheral = peripheral;
    m_peripheral.delegate = self;
    
    NSLog(@"已经连接上了: %@",peripheral.name);
    
    [mange_delegate bleMangerConnectedPeripheral:YES]; //delegate 给出去外面一个通知什么的，表明已经连接上了
    
    [m_peripheral discoverServices:nil]; //我们直接一次读取外设的所有的： Services ,如果只想找某个服务，直接传数组进去就行，比如你只想扫描服务UUID为 FFF1和FFE2 的这两项服务
    /*
    NSArray *array_service = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"FFF1"], [CBUUID UUIDWithString:@"FFE2"],nil];
    [m_peripheral discoverServices:array_service];
    */
    
}
/*!
 *  @method centralManager:didFailToConnectPeripheral:error:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has failed to connect.
 *  @param error        The cause of the failure.
 *
 *  @discussion         This method is invoked when a connection initiated by {@link connectPeripheral:options:} has failed to complete. As connection attempts do not
 *                      timeout, the failure of a connection is atypical and usually indicative of a transient issue.
 *
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
{
    //看苹果的官方解释 {@link connectPeripheral:options:} ,也就是说链接外设失败了
    NSLog(@"链接外设失败");
}
/*!
 *  @method centralManager:didDisconnectPeripheral:error:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has disconnected.
 *  @param error        If an error occurred, the cause of the failure.
 *
 *  @discussion         This method is invoked upon the disconnection of a peripheral that was connected by {@link connectPeripheral:options:}. If the disconnection
 *                      was not initiated by {@link cancelPeripheralConnection}, the cause will be detailed in the <i>error</i> parameter. Once this method has been
 *                      called, no more methods will be invoked on <i>peripheral</i>'s <code>CBPeripheralDelegate</code>.
 *
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
{
    //自己看看官方的说明，这个函数被调用是有前提条件的，首先你的要先调用过了 connectPeripheral:options:这个方法，其次是如果这个函数被回调的原因不是因为你主动调用了 cancelPeripheralConnection 这个方法，那么说明，整个蓝牙连接已经结束了，不会再有回连的可能，得要重来了
    NSLog(@"didDisconnectPeripheral");
    
    //如果你想要尝试回连外设，可以在这里调用一下链接函数
    /*
    [central connectPeripheral:peripheral options:@{CBCentralManagerScanOptionSolicitedServiceUUIDsKey : @YES,CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES}];
     */
    [mange_delegate bleMangerDisConnectedPeripheral:peripheral];
    
}


- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral NS_AVAILABLE(NA, 6_0);
{
    //这个函数一般不会被调用，他被调用是因为 peripheral.name 被修改了，才会被调用
    
}
/*!
 *  @method peripheralDidInvalidateServices:
 *
 *  @param peripheral	The peripheral providing this update.
 *
 *  @discussion			This method is invoked when the @link services @/link of <i>peripheral</i> have been changed. At this point,
 *						all existing <code>CBService</code> objects are invalidated. Services can be re-discovered via @link discoverServices: @/link.
 *
 *	@deprecated			Use {@link peripheral:didModifyServices:} instead.
 */
- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral NS_DEPRECATED(NA, NA, 6_0, 7_0);
{
    //这个函数一般也不会被调用，它是在你已经读取过一次外设的 services 之后，没有断开，这个时候外设突然来个我的某个服务不让用了，这个时候才会被调用，你得要再一次读取外设的 services 即可
}
/*!
 *  @method peripheral:didModifyServices:
 *
 *  @param peripheral			The peripheral providing this update.
 *  @param invalidatedServices	The services that have been invalidated
 *
 *  @discussion			This method is invoked when the @link services @/link of <i>peripheral</i> have been changed.
 *						At this point, the designated <code>CBService</code> objects have been invalidated.
 *						Services can be re-discovered via @link discoverServices: @/link.
 */
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices NS_AVAILABLE(NA, 7_0);
{
    //类似上面
    
}
/*!
 *  @method peripheralDidUpdateRSSI:error:
 *
 *  @param peripheral	The peripheral providing this update.
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link readRSSI: @/link call.
 *
 *  @deprecated			Use {@link peripheral:didReadRSSI:error:} instead.
 */
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error NS_DEPRECATED(NA, NA, 5_0, 8_0);
{
    //这个函数一看就知道了，当外设更新了RSSI的时候被调用，当然，外设不会无故给你老是发RSSI，听硬件那边工程师说，蓝牙协议栈里面的心跳包是可以把RSSI带过来的，但是不知道什么情况，被封杀了，你的要主动调用 [peripheral readRSSI];方法，人家外设才给你回RSSI，不过这个方法现在被弃用了。用下面的方法来接收
    //已经弃用
    
}
/*!
 *  @method peripheral:didReadRSSI:error:
 *
 *  @param peripheral	The peripheral providing this update.
 *  @param RSSI			The current RSSI of the link.
 *  @param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link readRSSI: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error NS_AVAILABLE(NA, 8_0);
{
    
    //同上，这个就是你主动调用了 [peripheral readRSSI];方法回调的RSSI，你可以根据这个RSSI估算一下距离什么的
    NSLog(@" peripheral Current RSSI:%@",RSSI);
    
}
/*!
 *  @method peripheral:didDiscoverServices:
 *
 *  @param peripheral	The peripheral providing this information.
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverServices: @/link call. If the service(s) were read successfully, they can be retrieved via
 *						<i>peripheral</i>'s @link services @/link property.
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error;
{
    //到这里，说明你上面调用的  [m_peripheral discoverServices:nil]; 方法起效果了，我们接着来找找特征值UUID
    for (CBService *s in [peripheral services]) {
        [peripheral discoverCharacteristics:nil forService:s];  //同上，如果只想找某个特征值，传参数进去
    }
    
}
/*!
 *  @method peripheral:didDiscoverIncludedServicesForService:error:
 *
 *  @param peripheral	The peripheral providing this information.
 *  @param service		The <code>CBService</code> object containing the included services.
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverIncludedServices:forService: @/link call. If the included service(s) were read successfully,
 *						they can be retrieved via <i>service</i>'s <code>includedServices</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error;
{
    //基本用不上
}
/*!
 *  @method peripheral:didDiscoverCharacteristicsForService:error:
 *
 *  @param peripheral	The peripheral providing this information.
 *  @param service		The <code>CBService</code> object containing the characteristic(s).
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverCharacteristics:forService: @/link call. If the characteristic(s) were read successfully,
 *						they can be retrieved via <i>service</i>'s <code>characteristics</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
    //发现了（指定）的特征值了，如果你想要有所动作，你可以直接在这里做，比如有些属性为 notify 的 Characteristics ,你想要监听他们的值，可以这样写
    /*
    for (CBCharacteristic *c in service.characteristics) {
        if ([[c.UUID UUIDString] isEqualToString:@"FFF2"]) {
            [peripheral setNotifyValue:YES forCharacteristic:c]; //不想监听的时候，设置为：NO 就行了
        }
    }
     */
    
}
/*!
 *  @method peripheral:didUpdateValueForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method is invoked after a @link readValueForCharacteristic: @/link call, or upon receipt of a notification/indication.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
{
    //这个可是重点了，你收的一切数据，基本都从这里得到,你只要判断一下 [characteristic.UUID UUIDString] 符合你们定义的哪个，然后进行处理就行，值为：characteristic.value 一切数据都是这个，至于怎么解析，得看你们自己的了
   //[characteristic.UUID UUIDString]  注意： UUIDString 这个方法是IOS 7.1之后才支持的,要是之前的版本，得要自己写一个转换方法
    NSLog(@"receiveData = %@,fromCharacteristic.UUID = %@",characteristic.value,characteristic.UUID);
    [mange_delegate bleMangerReceiveDataPeripheralData:characteristic.value from_Characteristic:characteristic];
    
}
/*!
 *  @method peripheral:didWriteValueForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a {@link writeValue:forCharacteristic:type:} call, when the <code>CBCharacteristicWriteWithResponse</code> type is used.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
{
    //这个方法比较好，这个是你发数据到外设的某一个特征值上面，并且响应的类型是 CBCharacteristicWriteWithResponse ，上面的官方文档也有，如果确定发送到外设了，就会给你一个回应，当然，这个也是要看外设那边的特征值UUID的属性是怎么设置的,看官方文档，人家已经说了，条件是，特征值UUID的属性：CBCharacteristicWriteWithResponse
    if (!error) {
        NSLog(@"说明发送成功，characteristic.uuid为：%@",[characteristic.UUID UUIDString]);
    }else{
        NSLog(@"发送失败了啊！characteristic.uuid为：%@",[characteristic.UUID UUIDString]);
    }
        
}
/*!
 *  @method peripheral:didUpdateNotificationStateForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link setNotifyValue:forCharacteristic: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

{
    //这个方法被调用是因为你主动调用方法： setNotifyValue:forCharacteristic 给你的反馈
    NSLog(@"你更新了对特征值:%@ 的通知",[characteristic.UUID UUIDString]);
    
}

-(BOOL) comparePeripheralisEqual :(CBPeripheral *)disCoverPeripheral RSSI:(NSNumber *)RSSI
{
    if ([m_array_peripheral count]>0) {
        for (int i=0;i<[m_array_peripheral count];i++) {
            BlePeripheral *l_per = [m_array_peripheral objectAtIndex:i];
            if ([disCoverPeripheral isEqual:l_per.m_peripheral]) {
                l_per.m_peripheralRSSI = RSSI;
                return YES;
            }
        }
    }
    return NO;
}

@end
