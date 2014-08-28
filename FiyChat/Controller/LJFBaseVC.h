//
//  LJFBaseVC.h
//  FiyChat
//
//  Created by lijianfei on 14-7-14.
//  Copyright (c) 2014年 lijianfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface LJFBaseVC : UIViewController<UITextFieldDelegate,MBProgressHUDDelegate>
{
	MBProgressHUD *HUD;
}


@end
