//
//  BLEmanager.h
//  BLE4.0Demo
//
//  Created by kakaxi on 15/4/17.
//  Copyright (c) 2015年 kakaxi Email:631965569@qq.com  . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BLEMangerDelegate <NSObject>

-(void)bleMangerConnectedPeripheral :(BOOL)isConnect;
-(void)bleMangerDisConnectedPeripheral :(CBPeripheral *)_peripheral;
-(void)bleMangerReceiveDataPeripheralData :(NSData *)data from_Characteristic :(CBCharacteristic *)curCharacteristic;

@end

@interface BLEmanager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    CBCentralManager *_m_manger;
    CBPeripheral     *_m_peripheral;
    
    NSMutableArray *m_array_peripheral;
    
}

+(BLEmanager *)shareInstance;
@property(nonatomic,copy)     NSMutableArray   *m_array_peripheral;
@property(nonatomic,strong)   CBCentralManager *m_manger;
@property(nonatomic,strong)   CBPeripheral     *m_peripheral;
@property(weak,nonatomic) id<BLEMangerDelegate> mange_delegate;
-(void)initCentralManger;
@end
