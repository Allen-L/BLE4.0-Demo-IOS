//
//  BlePeripheral.m
//  BLE4.0Demo
//
//  Created by kakaxi on 15/4/17.
//  Copyright (c) 2015年 kakaxi Email:631965569@qq.com  . All rights reserved.
//

#import "BlePeripheral.h"

@implementation BlePeripheral
-(id) init
{
    if((self = [super init])) {
        self.m_peripheralIdentifier = @"";
        self.m_peripheralLocaName   = @"";
        self.m_peripheralName       = @"";
        self.m_peripheralUUID       = @"";
        self.m_peripheralRSSI       = 0;
        self.m_peripheralServices   = 0;
    }
    return self;
}
@end
