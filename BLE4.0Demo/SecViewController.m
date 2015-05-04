//
//  SecViewController.m
//  BLE4.0Demo
//
//  Created by kakaxi on 15/4/17.
//  Copyright (c) 2015年 kakaxi Email:631965569@qq.com  . All rights reserved.
//

#import "SecViewController.h"
#import "BLEmanager.h"
#import "Commom.h"
#import "CharacteristicInfoViewController.h"
@interface SecViewController ()<BLEMangerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    float   testProgress ;
    int     progressDir ;

    
    BLEmanager *m_bleManger;
    Commom *common;
    
    NSMutableArray *array_services;
    NSMutableArray *array_characteristics;
    
    UITableView *m_table_peripheralInfo;
    
    NSMutableDictionary *m_dic_DeviceInfo;
}
@end

@implementation SecViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    
    m_bleManger = [BLEmanager shareInstance];
    m_bleManger.mange_delegate = self;
    
    common = [Commom sharedInstance];
    array_services = [[NSMutableArray alloc]init];
    array_characteristics = [[NSMutableArray alloc]init];
    
    UIBarButtonItem *ScanButton = [[UIBarButtonItem alloc] initWithTitle:@"Info" style:UIBarButtonItemStylePlain target:self action:@selector(PeripheralInfo:)];
    self.navigationItem.rightBarButtonItem = ScanButton;
    
    
    m_table_peripheralInfo = [[UITableView alloc]initWithFrame:CGRectMake(0, 64,MainScreen_Width , MainScreen_Height-64)];
    m_table_peripheralInfo.delegate = self;
    m_table_peripheralInfo.dataSource = self;
    [self.view addSubview:m_table_peripheralInfo];
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    m_bleManger.mange_delegate = self;
}
-(void)viewWillDisappear:(BOOL)animated
{
    m_bleManger.mange_delegate = nil;
    
}

-(void)showPeripheralDeviceInfo
{
    m_dic_DeviceInfo = [[NSMutableDictionary alloc]init];
    CBPeripheral *peripheral = common.currentPeripheral;
    for (int i = 0; i < peripheral.services.count; i++) {
        CBService *service = [peripheral.services objectAtIndex:i];
        if ([[service.UUID UUIDString] isEqualToString:@"180A"]) {
            for (int j = 0; j < service.characteristics.count; j++) {
                CBCharacteristic *characteristic = [service.characteristics objectAtIndex:j];
                if ([[characteristic.UUID UUIDString]isEqualToString:@"2A23"]) {
                    //2A23 system ID
                    [m_dic_DeviceInfo setObject:characteristic.description forKey:@"2A23"];
                }else if ([[characteristic.UUID UUIDString]isEqualToString:@"2A24"]) {
                    //2A24 Model Number string
                    [m_dic_DeviceInfo setObject:characteristic.description forKey:@"2A24"];
                }else if ([[characteristic.UUID UUIDString]isEqualToString:@"2A25"]) {
                    //2A25 Serial Number string
                    [m_dic_DeviceInfo setObject:characteristic.description forKey:@"2A25"];
                }else if ([[characteristic.UUID UUIDString]isEqualToString:@"2A26"]) {
                    //2A26 Firmware Revision string
                    [m_dic_DeviceInfo setObject:characteristic.description forKey:@"2A26"];
                }else if ([[characteristic.UUID UUIDString]isEqualToString:@"2A27"]) {
                    //2A27 Hardware Revision string
                    [m_dic_DeviceInfo setObject:characteristic.description forKey:@"2A27"];
                }else if ([[characteristic.UUID UUIDString]isEqualToString:@"2A28"]) {
                    //2A28 Software Revision string
                    [m_dic_DeviceInfo setObject:characteristic.description forKey:@"2A28"];
                }else if ([[characteristic.UUID UUIDString]isEqualToString:@"2A29"]) {
                    //2A29 Manufacturer Name string
                    [m_dic_DeviceInfo setObject:characteristic.description forKey:@"2A29"];
                }else if ([[characteristic.UUID UUIDString]isEqualToString:@"2A2A"]) {
                    //2A2A Regulatory Certification data list
                    [m_dic_DeviceInfo setObject:characteristic.description forKey:@"2A2A"];
                }else if ([[characteristic.UUID UUIDString]isEqualToString:@"2A50"]) {
                    //2A50 PnP ID
                    [m_dic_DeviceInfo setObject:characteristic.description forKey:@"2A50"];
                }
            }
             break;
        }
    }
}
-(void)PeripheralInfo:(id)sender
{
     [self showPeripheralDeviceInfo];
    
    CBPeripheral *peripheral = common.currentPeripheral;
    for (int i = 0; i < peripheral.services.count; i++) {
        CBService *service = [peripheral.services objectAtIndex:i];
        NSLog(@"service.UUID = %@",[service.UUID UUIDString]);
        [array_services addObject:service];
        for (int j = 0; j < service.characteristics.count; j++) {
            CBCharacteristic *characteristic = [service.characteristics objectAtIndex:j];
            
            [array_characteristics addObject:[characteristic.UUID UUIDString]];
            
            NSLog(@"characteristic.UUID = %@",[characteristic.UUID UUIDString]);
            NSLog(@"characteristic.property = %u",characteristic.properties);
            NSLog(@"characteristic.description = %@",characteristic.description);
            NSLog(@"characteristic.isNotifying = %hhd",characteristic.isNotifying);
            NSLog(@"characteristic.isBroadcasted = %d",characteristic.isBroadcasted);
        }
    }
    [m_table_peripheralInfo reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)readBattery:(id)sender {
    
    for (int i = 0; i < m_bleManger.m_peripheral.services.count; i++) {
        CBService *service = [m_bleManger.m_peripheral.services objectAtIndex:i];
        if ([[service.UUID UUIDString] isEqualToString:@"180F"]) {
            for (int j = 0; j < service.characteristics.count; j++) {
                CBCharacteristic *characteristic = [service.characteristics objectAtIndex:j];
                if ([[characteristic.UUID UUIDString]isEqualToString:@"2A19"]) {
                    [m_bleManger.m_peripheral readValueForCharacteristic:characteristic];
                    break;
                }
            }
            break;
        }
    }
}

- (IBAction)readPeripheralInfo:(id)sender {
    
    for (int i = 0; i < m_bleManger.m_peripheral.services.count; i++) {
        CBService *service = [m_bleManger.m_peripheral.services objectAtIndex:i];
        if ([[service.UUID UUIDString] isEqualToString:@"180A"]) {
            for (int j = 0; j < service.characteristics.count; j++) {
                CBCharacteristic *characteristic = [service.characteristics objectAtIndex:j];
                if ([[characteristic.UUID UUIDString]isEqualToString:@"2A23"]) {
                    [m_bleManger.m_peripheral readValueForCharacteristic:characteristic];
                    break;
                }
            }
            break;
        }
    }
}

#pragma mark
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return [array_services count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    CBService *service = [array_services objectAtIndex:section];
    return [service.UUID UUIDString];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 84;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

{
    CBService *service = [array_services objectAtIndex:section];
    return [service.characteristics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

{
    NSString *cellIden = [NSString stringWithFormat:@"%ld%ld",(long)indexPath.section,(long)indexPath.row];
    UITableViewCell *mycell = [tableView dequeueReusableCellWithIdentifier:cellIden];
    
    if (!mycell) {
        mycell  = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIden];
    }
    
    for (UIView *subView in mycell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
//    UILabel *lable_Name     = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, MainScreen_Width, 30)];
//    lable_Name.textAlignment = NSTextAlignmentCenter;
    
    UILabel *lable_Iden     = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, MainScreen_Width-5, 20)];
    lable_Iden.font = [UIFont systemFontOfSize:12.0];
    
    UILabel *lable_UUID     = [[UILabel alloc] initWithFrame:CGRectMake(5, 35, MainScreen_Width-5, 40)];
    lable_UUID.numberOfLines = 2;
    lable_UUID.font = [UIFont systemFontOfSize:12.0];
    
    
    UILabel *lable_RSSI = [[UILabel alloc] initWithFrame:CGRectMake(10, 82, MainScreen_Width*0.25, 18)];
    lable_RSSI.font = [UIFont systemFontOfSize:12.0];
    
    UILabel *lable_Services = [[UILabel alloc] initWithFrame:CGRectMake(10+MainScreen_Width*0.35, 82, MainScreen_Width*0.35, 18)];
    lable_Services.font = [UIFont systemFontOfSize:12.0];
    
//    [mycell.contentView addSubview:lable_Name];
    [mycell.contentView addSubview:lable_RSSI];
    [mycell.contentView addSubview:lable_Iden];
    [mycell.contentView addSubview:lable_Services];
    [mycell.contentView addSubview:lable_UUID];
    
    
    CBService *service = [array_services objectAtIndex:indexPath.section];
    NSString *str_info = [[NSString alloc]init];
    if ([[service.UUID UUIDString] isEqualToString:@"180A"]) {
        CBCharacteristic *characteristic = [service.characteristics objectAtIndex:indexPath.row];
        
        
        if ([[characteristic.UUID UUIDString]isEqualToString:@"2A23"]) {
            //2A23 system ID
            lable_Iden.text = @"system ID";
            str_info = [m_dic_DeviceInfo objectForKey:@"2A23"];
        }else if ([[characteristic.UUID UUIDString]isEqualToString:@"2A24"]) {
            //2A24 Model Number string
            lable_Iden.text = @"Model Number string";
            str_info = [m_dic_DeviceInfo objectForKey:@"2A24"];
        }else if ([[characteristic.UUID UUIDString]isEqualToString:@"2A25"]) {
            //2A25 Serial Number string
            lable_Iden.text = @"Serial Number string";
            str_info = [m_dic_DeviceInfo objectForKey:@"2A25"];
        }else if ([[characteristic.UUID UUIDString]isEqualToString:@"2A26"]) {
            //2A26 Firmware Revision string
            lable_Iden.text = @"Firmware Revision string";
            str_info = [m_dic_DeviceInfo objectForKey:@"2A26"];
        }else if ([[characteristic.UUID UUIDString]isEqualToString:@"2A27"]) {
            //2A27 Hardware Revision string
            lable_Iden.text = @"Hardware Revision string";
            str_info = [m_dic_DeviceInfo objectForKey:@"2A27"];
        }else if ([[characteristic.UUID UUIDString]isEqualToString:@"2A28"]) {
            //2A28 Software Revision string
            lable_Iden.text = @"Software Revision string";
            str_info = [m_dic_DeviceInfo objectForKey:@"2A28"];
        }else if ([[characteristic.UUID UUIDString]isEqualToString:@"2A29"]) {
            //2A29 Manufacturer Name string
            lable_Iden.text = @"Manufacturer Name string";
            str_info = [m_dic_DeviceInfo objectForKey:@"2A29"];
        }else if ([[characteristic.UUID UUIDString]isEqualToString:@"2A2A"]) {
            //2A2A Regulatory Certification data list
            lable_Iden.text = @"Regulatory Certification data list";
            str_info = [m_dic_DeviceInfo objectForKey:@"2A2A"];
        }else if ([[characteristic.UUID UUIDString]isEqualToString:@"2A50"]) {
            //2A50 PnP ID
            lable_Iden.text = @"PnP ID";
            str_info = [m_dic_DeviceInfo objectForKey:@"2A50"];
        }

        lable_UUID.text = str_info;
        
    }else{
        CBCharacteristic *characteristic = [service.characteristics objectAtIndex:indexPath.row];
        lable_Iden.text = [characteristic.UUID UUIDString];
        lable_UUID.text = characteristic.description;
    }
   
    /*
    if (m_bleManger.m_array_peripheral.count >0) {
        BlePeripheral *l_peri = [m_bleManger.m_array_peripheral objectAtIndex:indexPath.row];
        
        lable_Name.text     =  [NSString stringWithFormat:@"Name:%@",l_peri.m_peripheralLocaName];
        lable_RSSI.text     =  [NSString stringWithFormat:@"RSSI=%@",l_peri.m_peripheralRSSI];
        lable_Iden.text     =  [NSString stringWithFormat:@"Iden:%@",l_peri.m_peripheralIdentifier];
        lable_Services.text =  [NSString stringWithFormat:@"Services:%d",l_peri.m_peripheralServices];
        lable_UUID.text     =  [NSString stringWithFormat:@"UUID:%@",l_peri.m_peripheralUUID]; ;
        //        mycell.textLabel.text = [NSString stringWithFormat:@"RSSI=%@ iden=%@ ",l_peri.m_peripheralRSSI,l_peri.m_peripheralIdentifier];
    }
    */
    return mycell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    CBService *service = [array_services objectAtIndex:indexPath.section];
    CBCharacteristic *characteristic = [service.characteristics objectAtIndex:indexPath.row];
    NSLog(@"characteristic.UUID = %@",[characteristic.UUID UUIDString]);
    CharacteristicInfoViewController *characterVC = [[CharacteristicInfoViewController alloc]init];
    characterVC.curCharacteristic = characteristic;
    [self.navigationController pushViewController:characterVC animated:YES];
}


#pragma mark_BLEDelegate
-(void)bleMangerConnectedPeripheral :(BOOL)isConnect;
{
    
}
-(void)bleMangerDisConnectedPeripheral :(CBPeripheral *)_peripheral;
{
    //DisConnect
    NSLog(@"did Disconnect Peripheral For Something");
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void)bleMangerReceiveDataPeripheralData :(NSData *)data from_Characteristic :(CBCharacteristic *)curCharacteristic;
{
    NSLog(@"receiveData=%@,FromCharacteristic=%@",data,[curCharacteristic.UUID UUIDString]);
    
}
@end
