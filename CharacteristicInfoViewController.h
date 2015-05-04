//
//  CharacteristicInfoViewController.h
//  BLE4.0Demo
//
//  Created by kakaxi on 15/5/1.
//  Copyright (c) 2015年 kakaxi Email:631965569@qq.com  . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface CharacteristicInfoViewController : UIViewController


@property(nonatomic,retain)CBCharacteristic *curCharacteristic;

@end
