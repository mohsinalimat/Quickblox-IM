//
//  LJFAppDelegate.h
//  FiyChat
//
//  Created by lijianfei on 14-7-14.
//  Copyright (c) 2014年 lijianfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@interface LJFAppDelegate : UIResponder <UIApplicationDelegate,QBActionStatusDelegate,MBProgressHUDDelegate>
{
	MBProgressHUD *HUD;
}
@property (strong, nonatomic) UIWindow *window;

@end
