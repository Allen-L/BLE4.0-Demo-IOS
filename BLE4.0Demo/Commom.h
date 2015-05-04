//
//  Commom.h
//  BLE4.0Demo
//
//  Created by kakaxi on 15/4/18.
//  Copyright (c) 2015年 kakaxi Email:631965569@qq.com  . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Header.h"
@interface Commom : NSObject
AS_SINGLETON(Commom);

@property(nonatomic,copy)CBPeripheral *currentPeripheral;

@end
