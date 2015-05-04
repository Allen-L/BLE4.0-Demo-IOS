//
//  CharacteristicInfoViewController.m
//  BLE4.0Demo
//
//  Created by kakaxi on 15/5/1.
//  Copyright (c) 2015年 kakaxi Email:631965569@qq.com  . All rights reserved.
//

#import "CharacteristicInfoViewController.h"
#import "Commom.h"
@interface CharacteristicInfoViewController ()
{
    Commom *common;
}
@end

@implementation CharacteristicInfoViewController
@synthesize curCharacteristic;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    common = [Commom sharedInstance];
    
    [self characteristicInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)characteristicInfo
{
    NSLog(@"characteristicInfo = %@",curCharacteristic.description);
    
    UILabel *lable_PeripheralName = [[UILabel alloc]initWithFrame:CGRectMake(10, 64, MainScreen_Width-10, 40)];
    
    UILabel *lable_UUID           = [[UILabel alloc]initWithFrame:CGRectMake(10, 114, MainScreen_Width-10, 40)];
    
    UILabel *lable_Status         = [[UILabel alloc]initWithFrame:CGRectMake(10, 164, MainScreen_Width-10, 40)];
    
    UILabel *lable_Descriptors    = [[UILabel alloc]initWithFrame:CGRectMake(10, 214, MainScreen_Width-10, 40)];
    
    UILabel *lable_Properties     = [[UILabel alloc]initWithFrame:CGRectMake(10, 264, MainScreen_Width-10, 40)];
    
    lable_PeripheralName.text     = [NSString stringWithFormat:@"Name:  %@",common.currentPeripheral.name];
    lable_UUID.text               = [NSString stringWithFormat:@"UUID:  %@",[curCharacteristic.UUID UUIDString]];
    lable_Status.text             = [NSString stringWithFormat:@"Status:  %d",common.currentPeripheral.state];
    lable_Descriptors.text        = [NSString stringWithFormat:@"Descriptors:  %@",curCharacteristic.descriptors];
    lable_Properties.text         = [NSString stringWithFormat:@"Properties:  %u",curCharacteristic.properties];
    

    [self.view addSubview:lable_PeripheralName];
    [self.view addSubview:lable_UUID];
    [self.view addSubview:lable_Status];
    [self.view addSubview:lable_Descriptors];
    [self.view addSubview:lable_Properties];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
