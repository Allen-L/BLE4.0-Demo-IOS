//
//  BlePeripheral.h
//  BLE4.0Demo
//
//  Created by kakaxi on 15/4/17.
//  Copyright (c) 2015年 kakaxi Email:631965569@qq.com  . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface BlePeripheral : NSObject
@property(nonatomic,copy)CBPeripheral *m_peripheral;
@property(nonatomic,copy) NSString *m_peripheralIdentifier;
@property(nonatomic,copy) NSString *m_peripheralLocaName;
@property(nonatomic,copy) NSString *m_peripheralName;
@property(nonatomic,copy) NSString *m_peripheralUUID;
@property(nonatomic,copy) NSNumber *m_peripheralRSSI;
@property(nonatomic)     NSInteger  m_peripheralServices;
@end
