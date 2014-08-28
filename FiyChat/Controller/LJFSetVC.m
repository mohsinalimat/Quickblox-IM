//
//  LJFSetVC.m
//  FiyChat
//
//  Created by lijianfei on 14-7-14.
//  Copyright (c) 2014年 lijianfei. All rights reserved.
//

#import "LJFSetVC.h"

@interface LJFSetVC ()<QBActionStatusDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;



- (IBAction)logOutAction:(id)sender;



@end

@implementation LJFSetVC

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
}

# pragma
# pragma mark  didReceiveMemoryWarning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma
# pragma mark tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"set"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

# pragma
# pragma mark   QBActionStatusDelegate
-(void)completedWithResult:(Result*)result
{
	if([result isKindOfClass:[QBUUserLogOutResult class]])
    {
		QBUUserLogOutResult *res = (QBUUserLogOutResult *)result;
        
		if(res.success)
        {
            [self hideHUB];
            
		    NSLog(@"LogOut successful.");
            [self dismissViewControllerAnimated:NO completion:^{
                [LJFDataManager  disConnect];
            }];
		}
        else
        {
            [self hideHUB];
            [self errorHUDWithtext:@"退出失败"];
            NSLog(@"errors=%@", result.errors);
		}
	}	
}
#pragma mark
#pragma mark  HUD

- (void)showLoadingHUD
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
    
	HUD.delegate = self;
	HUD.labelText = @"退出中...";
    [HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
}
- (void)hideHUB
{
    [HUD hide:YES];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//退出登录
- (IBAction)logOutAction:(id)sender
{
    [self showLoadingHUD];
    [QBUsers logOutWithDelegate:self];
 
}
@end
