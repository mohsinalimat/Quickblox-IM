//
//  LJFRegisterVC.m
//  FiyChat
//
//  Created by lijianfei on 14-7-14.
//  Copyright (c) 2014年 lijianfei. All rights reserved.
//

#import "LJFRegisterVC.h"

@interface LJFRegisterVC ()<QBActionStatusDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameField;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UITextField *repasswordField;




- (IBAction)registerAction:(id)sender;




@end

@implementation LJFRegisterVC

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
    
    
}
#pragma mark
#pragma mark UITextFieldDelegate
//取消键盘第一响应者
- (void)resignFirstResponder:(UITapGestureRecognizer *)tap
{
    [self.userNameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.repasswordField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark
#pragma mark QBActionStatusDelegate

-(void)completedWithResult:(Result*)result
{
	if([result isKindOfClass:[QBUUserResult class]])
    {
		QBUUserResult *res = (QBUUserResult *)result;
        
		if(res.success)
        {
            //取消注册中中提示框
            [self hideHUB];
            //注册成功提示框
            [self successedHUD];
            [self performSelector:@selector(delayPop) withObject:nil afterDelay:2.0];
		    NSLog(@"Registration successful.");
		}
        else
        {
            //取消注册中提示框
            [self hideHUB];
            
            //注册失败提示框
            [self errorHUDWithtext:@"注册失败，已存在用户名"];
            NSLog(@"errors=%@", result.errors);
		}
	}	
}

//延迟pop
- (void)delayPop
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark
#pragma mark  didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)showLoadingHUD
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
    
	HUD.delegate = self;
	HUD.labelText = @"注册中...";
    [HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
}
- (void)myTask
{
    sleep(100);
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
	HUD.labelText = @"注册成功";
	
	[HUD show:YES];
	[HUD hide:YES afterDelay:2];
}

#pragma mark
#pragma mark  Action

- (IBAction)registerAction:(id)sender
{
    NSLog(@"注册");
    //回收键盘
    [self.userNameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.repasswordField resignFirstResponder];
    
    if (self.userNameField.text.length == 0|| self.passwordField.text.length ==0 || self.repasswordField.text.length == 0 )
    {
        //显示提示框
        [self errorHUDWithtext:@"用户名或密码为空"];
    }
    else if (![self.passwordField.text isEqualToString:self.repasswordField.text])
    {
        //显示提示框
        [self errorHUDWithtext:@"两次输入密码不一致"];
        
    }
    else if (self.passwordField.text.length <  8 )
    {
        //显示提示框
        [self errorHUDWithtext:@"密码长度需大于8"];
        
    }
    else
    {
        QBUUser *user = [QBUUser user];
        user.login = self.userNameField.text;
        user.password = self.passwordField.text;
        [QBUsers signUp:user delegate:self];
        
        //增加注册中提示框
        [self showLoadingHUD];
    }

    
}
@end
