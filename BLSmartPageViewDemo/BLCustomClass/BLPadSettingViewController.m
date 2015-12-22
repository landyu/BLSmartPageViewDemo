//
//  BLPadSettingViewController.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/9/24.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLPadSettingViewController.h"
#import "BLSettingData.h"
#import "BLGCDKNXTunnellingAsyncUdpSocket.h"
#import "GlobalMacro.h"

#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "MyHTTPConnection.h"
#import "ZipArchive.h"

#include <ifaddrs.h>
#include <arpa/inet.h>

static const int ddLogLevel = LOG_LEVEL_VERBOSE;
@interface BLPadSettingViewController ()
{
    HTTPServer *httpServer;
}
@property (strong, nonatomic) IBOutlet UISwitch *configImportButtonOutlet;
@property (strong, nonatomic) IBOutlet UITextField *httpServerLabel;
- (IBAction)configImportButtonPressed:(UISwitch *)sender;
//@property (nonatomic, strong) UIImageView *backgroundImageView;
//@property (nonatomic, strong) UILabel *ipAddressLabel;
@end

@implementation BLPadSettingViewController
@synthesize configImportButtonOutlet;
@synthesize httpServerLabel;

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //[self.view addSubview:self.backgroundImageView];
    //[self.view addSubview:self.ipAddressLabel];
    [configImportButtonOutlet setOn:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpServerStarted:) name:@"HTTPServerStarted" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"设置";
    NSString *ipAddress = [BLSettingData sharedSettingData].deviceIPAddress;
    self.deviceIpAddressText.text = ipAddress;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - enent response
- (IBAction)deviceIpAddressChanged:(UITextField *)sender
{
    LogInfo(@"device ip = %@", sender.text);
}

- (IBAction)deviceIpAddressEditingDidEnd:(UITextField *)sender
{
    [BLSettingData sharedSettingData].deviceIPAddress = sender.text;
    [[BLSettingData sharedSettingData] save];
    LogInfo(@"Editing Did End device ip = %@", sender.text);
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingSocketSharedInstance = [BLGCDKNXTunnellingAsyncUdpSocket sharedInstance];
    if ([[tunnellingSocketSharedInstance serverIpAddress] isEqualToString:sender.text])
    {
        return;
    }
    [tunnellingSocketSharedInstance setTunnellingSocketWithClientBindToPort:0 deviceIpAddress:sender.text deviceIpPort:3671 delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    [tunnellingSocketSharedInstance tunnellingServeRestart];
}

#pragma mark - geters and setters

//- (UIImageView *)backgroundImageView
//{
//    if (!_backgroundImageView)
//    {
//        _backgroundImageView =
//        ({
//            UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG_Blue.png"]];
//            imageView;
//        });
//    }
//    return _backgroundImageView;
//}
//
//- (UILabel *)ipAddressLabel
//{
//    if (!_ipAddressLabel)
//    {
//        _ipAddressLabel =
//        ({
//            UILabel *label = [[UILabel alloc] init];
//            label.frame = CGRectMake(100, 185, 30 * 6, 30);
//            label.text = @"网关 IP：";
//            label.textColor = [UIColor whiteColor];
//            label;
//        });
//    }
//    return _ipAddressLabel;
//}



- (IBAction)configImportButtonPressed:(UISwitch *)sender
{
    if ([sender isOn])
    {
        LogInfo(@"ON");
        // Configure our logging framework.
        // To keep things simple and fast, we're just going to log to the Xcode console.
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        
        // Initalize our http server
        httpServer = [[HTTPServer alloc] init];
        
        // Tell the server to broadcast its presence via Bonjour.
        // This allows browsers such as Safari to automatically discover our service.
        [httpServer setType:@"_http._tcp."];
        
        // Normally there's no need to run our server on any specific port.
        // Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
        // However, for easy testing you may want force a certain port so you can just hit the refresh button.
        //	[httpServer setPort:12345];
        
        // Serve files from the standard Sites folder
        NSString *docRoot = [[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"web"] stringByDeletingLastPathComponent];
        DDLogInfo(@"Setting document root: %@", docRoot);
        
        [httpServer setDocumentRoot:docRoot];
        
        [httpServer setConnectionClass:[MyHTTPConnection class]];
        
        NSError *error = nil;
        if(![httpServer start:&error])
        {
            DDLogError(@"Error starting HTTP Server: %@", error);
        }
    }
    else
    {
        LogInfo(@"OFF");
        [httpServer stop];
    }
}

- (void)httpServerStarted:(NSNotification *)notification
{
    NSDictionary *serverPort = [notification userInfo];
    //LogInfo(@"port = %@", [serverPort objectForKey:@"port"]);
    //httpServerPortLabel.text = [serverPort objectForKey:@"port"];
    httpServerLabel.text = [NSString stringWithFormat:@"%@:%@",[self getIPAddress], [serverPort objectForKey:@"port"]];
}

- (NSString *)getIPAddress
{
    
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    //LogInfo(@"local ip address = %@", address);
                    break;
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}
@end
