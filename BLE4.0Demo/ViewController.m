//
//  ViewController.m
//  BLE4.0Demo
//
//  Created by kakaxi on 15/4/17.
//  Copyright (c) 2015年 kakaxi Email:631965569@qq.com  . All rights reserved.
//

#import "ViewController.h"
#import "BLEmanager.h"
#import "BlePeripheral.h"
#import "SecViewController.h"
#import "AppDelegate.h"
#import "Commom.h"
#import "Header.h"
#import "MBProgressHUD.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,BLEMangerDelegate>
{
    BLEmanager *m_bleManger;
    UITableView *m_tableView_peripheral;
    
    NSTimer *m_timer_threesec;  //3s扫描定时器
    NSTimer *m_timer_Connect;   //10s连接定时器
    
    BlePeripheral *m_current_peripheralInfo;
    
    MBProgressHUD *showConnectingHUD;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    UINavigationController *rootNAV = [[UINavigationController alloc]initWithRootViewController:self];
    appdelegate.window.rootViewController = rootNAV;
    self.navigationController.navigationBarHidden = NO;
    
    UIBarButtonItem *ScanButton = [[UIBarButtonItem alloc] initWithTitle:@"扫描" style:UIBarButtonItemStylePlain target:self action:@selector(scanPeripheralResult:)];
    self.navigationItem.rightBarButtonItem = ScanButton;

    m_tableView_peripheral = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,MainScreen_Width , MainScreen_Height)];
    m_tableView_peripheral.delegate = self;
    m_tableView_peripheral.dataSource = self;
    [self.view addSubview:m_tableView_peripheral];
    
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    if ([Commom sharedInstance].currentPeripheral!=nil) {
        if ([Commom sharedInstance].currentPeripheral.state == CBPeripheralStateConnected) {
            
            showConnectingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            showConnectingHUD.mode = MBProgressHUDModeIndeterminate;
            showConnectingHUD.labelText = @"取消连接中...";
            showConnectingHUD.removeFromSuperViewOnHide = YES;
            
            [m_bleManger.m_manger cancelPeripheralConnection:[Commom sharedInstance].currentPeripheral]; //取消连接
            
            
        }
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    m_bleManger = [BLEmanager shareInstance];
    m_bleManger.mange_delegate = self;
}
-(void)viewWillDisappear:(BOOL)animated
{
   m_bleManger.mange_delegate = nil;
}
-(void)scanPeripheralResult:(id)sender
{

    
    NSArray *services = [[NSArray alloc]init];
    
    [m_bleManger.m_manger scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES,CBCentralManagerScanOptionSolicitedServiceUUIDsKey : services }];
     m_timer_threesec=[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(scanresult) userInfo:nil repeats:YES];
    
    NSLog(@"scan_services = %@",services);
    
    showConnectingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    showConnectingHUD.mode = MBProgressHUDModeIndeterminate;
    showConnectingHUD.labelText = @"正在扫描中...";
    showConnectingHUD.removeFromSuperViewOnHide = YES;
}


-(void)scanresult
{
    showConnectingHUD.hidden = YES;
    [m_tableView_peripheral reloadData];
    
//    if ([m_bleManger.m_array_peripheral count]>0) {
//        for ( BlePeripheral *l_peri in  m_bleManger.m_array_peripheral) {
//            NSLog(@"name = %@\n iden = %@\n rssi = %@",l_peri.m_peripheralName,l_peri.m_peripheralIdentifier,l_peri.m_peripheralRSSI);
//        }
//    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 100;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

{
    return [m_bleManger.m_array_peripheral count];
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
    
    UILabel *lable_Name     = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, MainScreen_Width, 30)];
    lable_Name.textAlignment = NSTextAlignmentCenter;
    
    UILabel *lable_Iden     = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, MainScreen_Width, 20)];
    lable_Iden.font = [UIFont systemFontOfSize:12.0];
    
    UILabel *lable_UUID     = [[UILabel alloc] initWithFrame:CGRectMake(10, 35+20+5, MainScreen_Width, 20)];
    lable_UUID.font = [UIFont systemFontOfSize:12.0];
    
    
    UILabel *lable_RSSI = [[UILabel alloc] initWithFrame:CGRectMake(10, 82, MainScreen_Width*0.25, 18)];
    lable_RSSI.font = [UIFont systemFontOfSize:12.0];

    UILabel *lable_Services = [[UILabel alloc] initWithFrame:CGRectMake(10+MainScreen_Width*0.35, 82, MainScreen_Width*0.35, 18)];
    lable_Services.font = [UIFont systemFontOfSize:12.0];
    
    [mycell.contentView addSubview:lable_Name];
    [mycell.contentView addSubview:lable_RSSI];
    [mycell.contentView addSubview:lable_Iden];
    [mycell.contentView addSubview:lable_Services];
    [mycell.contentView addSubview:lable_UUID];
    
    if (m_bleManger.m_array_peripheral.count >0) {
        BlePeripheral *l_peri = [m_bleManger.m_array_peripheral objectAtIndex:indexPath.row];
        
        lable_Name.text     =  [NSString stringWithFormat:@"Name:%@",l_peri.m_peripheralLocaName];
        lable_RSSI.text     =  [NSString stringWithFormat:@"RSSI=%@",l_peri.m_peripheralRSSI];
        lable_Iden.text     =  [NSString stringWithFormat:@"Iden:%@",l_peri.m_peripheralIdentifier];
        lable_Services.text =  [NSString stringWithFormat:@"Services:%d",l_peri.m_peripheralServices];
        lable_UUID.text     =  [NSString stringWithFormat:@"UUID:%@",l_peri.m_peripheralUUID]; ;
//        mycell.textLabel.text = [NSString stringWithFormat:@"RSSI=%@ iden=%@ ",l_peri.m_peripheralRSSI,l_peri.m_peripheralIdentifier];
    }
    
    return mycell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [m_timer_threesec invalidate];
     BlePeripheral *l_peri = [m_bleManger.m_array_peripheral objectAtIndex:indexPath.row];
    [m_bleManger.m_manger connectPeripheral:l_peri.m_peripheral options:nil];
    [[Commom sharedInstance]setCurrentPeripheral:l_peri.m_peripheral];
    [m_bleManger.m_manger stopScan];
    
    showConnectingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    showConnectingHUD.mode = MBProgressHUDModeIndeterminate;
    showConnectingHUD.labelText = @"正在连接中...";
    showConnectingHUD.removeFromSuperViewOnHide = YES;
    
    m_timer_Connect = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(connectPeripheralFailed) userInfo:nil repeats:NO];
    
}

#pragma mark_BLEMangerDelegate
-(void)bleMangerConnectedPeripheral :(BOOL)isConnect;
{
    if (isConnect == YES) {
        
        showConnectingHUD.hidden = YES;
        [m_timer_Connect invalidate];
        SecViewController *secVC = [[SecViewController alloc]init];
        [self.navigationController pushViewController:secVC animated:YES];
        [m_bleManger.m_manger stopScan];
    }
}
-(void)bleMangerReceiveDataPeripheralData :(NSData *)data from_Characteristic :(CBCharacteristic *)curCharacteristic;
{
    NSLog(@"接收到外设特征值为:%@ 发送的数据:%@",[curCharacteristic.UUID  UUIDString],data);
}
-(void)bleMangerDisConnectedPeripheral :(CBPeripheral *)_peripheral;
{
    if ([_peripheral isEqual:[Commom sharedInstance].currentPeripheral]) {
        NSLog(@ "已经断开了链接");
        [showConnectingHUD hide:YES];
        [self scanPeripheralResult:nil]; //调用扫描
    }
}

#pragma mark_NSTimer Function
-(void)connectPeripheralFailed
{
    [showConnectingHUD setHidden:YES];
    showConnectingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    showConnectingHUD.mode = MBProgressHUDModeText;
    showConnectingHUD.labelText = @"连接失败了！！！";
    showConnectingHUD.removeFromSuperViewOnHide = YES;
    [showConnectingHUD hide:YES afterDelay:1.0];
    
    [self scanPeripheralResult:nil]; //调用扫描
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
