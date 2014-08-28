//
//  LJFAppDelegate.m
//  FiyChat
//
//  Created by lijianfei on 14-7-14.
//  Copyright (c) 2014年 lijianfei. All rights reserved.
//

#import "LJFAppDelegate.h"

@implementation LJFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //my Quickblox key
    [QBSettings setApplicationID:12215];
    [QBSettings setAuthorizationKey:@"bnfDcjmtzCpZE8S"];
    [QBSettings setAuthorizationSecret:@"AjrsuejHrnKat86"];
    
    [QBSettings setAccountKey:@"7yvNe17TnjNUqDoPwfqp"];
    // 注册连接
    [QBAuth createSessionWithDelegate:self];
    [self showLoadingHUD];
    
    
    return YES;
}

#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox queries delegate
- (void)completedWithResult:(Result *)result
{
    if (result.success)
    {
        [self hideHUB];
        [self successedHUD];
    }
    else
    {
        [self hideHUB];
        [self errorHUDWithtext:@"连网失败"];
    }
}

#pragma mark
#pragma mark  HUD

- (void)showLoadingHUD
{
    HUD = [[MBProgressHUD alloc] initWithView:self.window.rootViewController.view];
	[self.window.rootViewController.view addSubview:HUD];
    
	HUD.delegate = self;
	HUD.labelText = @"连网中...";
    [HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
}
- (void)hideHUB
{
    [HUD hide:YES];
}

- (void)successedHUD
{
    //显示提示框
    HUD = [[MBProgressHUD alloc] initWithView:self.window.rootViewController.view];
    
	[self.window.rootViewController.view addSubview:HUD];
	
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right.png"]] ;
	
	// Set custom view mode
	HUD.mode = MBProgressHUDModeCustomView;
	
	HUD.delegate = self;
	HUD.labelText = @"连网成功";
	
	[HUD show:YES];
	[HUD hide:YES afterDelay:2];
}
//error提示框
- (void)errorHUDWithtext:(NSString *)text
{
    HUD = [[MBProgressHUD alloc] initWithView:self.window.rootViewController.view];
    [self.window.rootViewController.view addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]] ;
    // Set custom view mode
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.delegate = self;
    HUD.labelText = text;
    [HUD show:YES];
    [HUD hide:YES afterDelay:2];
}
- (void)myTask
{
    sleep(100);
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    [[QBChat instance] logout];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
//    [[QBChat instance] loginWithUser:user];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//    [[QBChat instance] logout];
}

@end
