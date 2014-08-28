//
//  LJFMessageVC.h
//  FiyChat
//
//  Created by lijianfei on 14-7-14.
//  Copyright (c) 2014年 lijianfei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJFMessageVC : LJFBaseVC<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,assign) NSInteger recipientID;

@end
