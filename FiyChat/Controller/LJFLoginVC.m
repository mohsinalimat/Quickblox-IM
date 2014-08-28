//
//  LJFLoginVC.m
//  FiyChat
//
//  Created by lijianfei on 14-7-14.
//  Copyright (c) 2014年 lijianfei. All rights reserved.
//

#import "LJFLoginVC.h"



#define socialLoginContext @"socialLoginContext"
#define typicalLoginContext @"typicalLoginContext"

@interface LJFLoginVC ()<UITextFieldDelegate, QBActionStatusDelegate,QBChatDelegate>


@property (weak, nonatomic) IBOutlet UITextField *userNameField;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;


- (IBAction)loginAction:(id)sender;


@end

@implementation LJFLoginVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //添加取消键盘手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResponder:)];
    
    [self.view addGestureRecognizer:tap];
    
    [[QBChat instance] setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark UITextFieldDelegate
//取消键盘第一响应者
- (void)resignFirstResponder:(UITapGestureRecognizer *)tap
{
    [self.userNameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
-(void)completedWithResult:(Result *)result
{
	if([result isKindOfClass:[QBUUserLogInResult class]])
    {
        
        
		QBUUserLogInResult *res = (QBUUserLogInResult *)result;
        //写入单例
        res.user.password = self.passwordField.text;
        [LJFDataManager sheard].currentQBUser = res.user;
        
		if(res.success)
        {
            //取消登录中提示框
            [self hideHUB];
            
            //增加登录成功提示框
            [self successedHUD];
            
            
            //登录成功
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            UITabBarController *tabBar= [storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
            
            [self presentViewController:tabBar animated:NO completion:^{
                
                [[QBChat instance] loginWithUser:[LJFDataManager sheard].currentQBUser];
                NSLog(@"");
            }];
            NSLog(@"Authentication successful");
		}
        else if(401 == result.status)
        {
            //取消登录中提示框
            [self hideHUB];

            //增加没有注册提示框
            [self errorHUDWithtext:@"没有注册"];
		    NSLog(@"Not registered!");
		}
        else
        {
            //取消登录中提示框
            [self hideHUB];

            //增加链接失败提示框
            [self errorHUDWithtext:@"链接失败"];
            NSLog(@"errors=%@", result.errors);
		}
	}
    


}

#pragma mark -
#pragma mark QBChatDelegate

// Chat delegate
-(void) chatDidLogin
{
    // You have successfully signed in to QuickBlox Chat
    NSLog(@"%s,%d",__FUNCTION__,__LINE__);
}

- (void)chatDidNotLogin
{
    NSLog(@"%s,%d",__FUNCTION__,__LINE__);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark
#pragma mark  HUD

- (void)showLoadingHUD
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
    
	HUD.delegate = self;
	HUD.labelText = @"登录中...";
    [HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
}
- (void)hideHUB
{
    [HUD hide:YES];
}

- (void)successedHUD
{
    //显示提示框
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    
	[self.navigationController.view addSubview:HUD];
	
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right.png"]] ;
	
	// Set custom view mode
	HUD.mode = MBProgressHUDModeCustomView;
	
	HUD.delegate = self;
	HUD.labelText = @"登录成功";
	
	[HUD show:YES];
	[HUD hide:YES afterDelay:2];
}
//error提示框
- (void)errorHUDWithtext:(NSString *)text
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
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

#pragma mark
#pragma mark  Action

- (IBAction)loginAction:(id)sender
{
    NSLog(@"登录");
    
    //回收键盘
    [self.userNameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    
    if (self.userNameField.text.length == 0|| self.passwordField.text.length ==0 )
    {
        //显示提示框
        [self errorHUDWithtext:@"用户名或密码为空"];
    }
    else
    {

        [QBUsers logInWithUserLogin:self.userNameField.text
                           password:self.passwordField.text
                           delegate:self context:typicalLoginContext];
        //增加登录中提示框
        [self showLoadingHUD];
    }

    
}
@end
