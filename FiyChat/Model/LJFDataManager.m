//
//  LJFDataManager.m
//  FiyChat
//
//  Created by lijianfei on 14-7-15.
//  Copyright (c) 2014年 lijianfei. All rights reserved.
//

#import "LJFDataManager.h"

@implementation LJFDataManager

static LJFDataManager *DM = nil;
static NSTimer *timer;
+ (LJFDataManager *)sheard
{
    
    // 保证sharedThemeManger 只调用一次
    
    static dispatch_once_t onceCreate;
    
    dispatch_once(&onceCreate,^{
        
        if (DM == nil) {
            
            DM = [[[self class] alloc]init];
            
        }
        
    });
    
    timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(keepConnect) userInfo:nil repeats:YES];
    [timer fire];
    
    return DM;
}

+ (void)keepConnect
{
    NSLog(@"激活连接");
    //激活连接
    [[QBChat instance] loginWithUser:DM.currentQBUser];
}

+ (void)disConnect
{
    NSLog(@"断开连接");
    [timer invalidate];
}

@end
