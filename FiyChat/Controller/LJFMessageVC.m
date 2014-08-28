//
//  LJFMessageVC.m
//  FiyChat
//
//  Created by lijianfei on 14-7-14.
//  Copyright (c) 2014年 lijianfei. All rights reserved.
//

#import "LJFMessageVC.h"
#import "UIViewAdditions.h"

@interface LJFMessageVC ()<QBChatDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *customView;

@property (weak, nonatomic) IBOutlet UITextField *messageField;

@property (weak, nonatomic) IBOutlet UIButton *sendButton;


- (IBAction)sendAction:(id)sender;

@property (nonatomic,strong) NSMutableArray *messages;

@end

@implementation LJFMessageVC

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
    
    if (IS_IPHONE_5)
    {
        self.customView.size = CGSizeMake(320, 32);
        self.customView.bottom = self.view.bottom;
        self.tableView.bottom = self.customView.top;
        self.tableView.size = CGSizeMake(320, self.customView.top);
    }
    else
    {
        //好奇怪的storyboard
        self.customView.size = CGSizeMake(320, 32);
        self.customView.bottom = self.view.bottom;
        self.tableView.size = CGSizeMake(320, self.customView.top);
        
    }
    //设置button圆角边
    [self.sendButton.layer setCornerRadius:10.0];
    //键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAction:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    //去掉cell的分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor lightGrayColor];
    
    //初始化聊天数组
    self.messages = [NSMutableArray array];
    
    //加载coredata数据
    
    //添加取消键盘响应手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [self.view addGestureRecognizer:tap];
    
    [[QBChat instance] setDelegate:self];


}
//tableview显示内容滚动到底部
- (void)toBottom
{
    //滚动到底部
    if (self.messages.count > 1) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

//取消键盘响应
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [UIView animateWithDuration:0.25 animations:^{
        self.customView.bottom = self.view.bottom;
        self.tableView.size = CGSizeMake(320, self.customView.top);
        
    }];
    return YES;
}
//手势
- (void)tapView:(UITapGestureRecognizer *)tap
{
    [self.messageField resignFirstResponder];
    [UIView animateWithDuration:0.25 animations:^{
        self.customView.bottom = self.view.bottom;
        self.tableView.size = CGSizeMake(320, self.customView.top);
    }];
}


- (void)keyboardAction:(NSNotification *)notification
{
    
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    //自定义输入栏做移位动画
    if (height == 216) {
        [UIView animateWithDuration:0.25 animations:^{
            self.customView.bottom = self.view.bottom-216;
            //使tableview与自定义输入栏位置匹配
            self.tableView.size = CGSizeMake(320, self.customView.top);
            [self toBottom];
        }];
    }
    else if (height == 252)
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.customView.bottom = self.view.bottom-252;
            
            self.tableView.size = CGSizeMake(320, self.customView.top);
            [self toBottom];
        }];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma
#pragma mark - tabView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"message"];
    //cell的选择时的颜色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor lightGrayColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    QBChatMessage *message = self.messages[indexPath.row];
    if (message.recipientID == self.recipientID)
    {
        cell.detailTextLabel.text = message.text;
        cell.textLabel.text = @"";
    }
    else
    {
        cell.textLabel.text = message.text;
        cell.detailTextLabel.text = @"";
    }
    return cell;
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
#pragma mark Additional
//播放来信铃声
static SystemSoundID soundID;
- (void)playNotificationSound
{
    if(soundID == 0){
        NSString *path = [NSString stringWithFormat: @"%@/sound.mp3", [[NSBundle mainBundle] resourcePath]];
        NSURL *filePath = [NSURL fileURLWithPath: path isDirectory: NO];
        
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
    }
    AudioServicesPlaySystemSound(soundID);
}

#pragma mark -
#pragma mark QBChatDelegate

- (void)chatDidReceiveMessage:(QBChatMessage *)message
{
    [self playNotificationSound];
    NSLog(@"New message: %@", message);
    [self.messages addObject:message];
    
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];

    
}

- (IBAction)sendAction:(id)sender
{
    //激活连接
//    [[QBChat instance] loginWithUser:[LJFDataManager sheard].currentQBUser];
    
    if (self.messageField.text.length > 0)
    {
        QBChatMessage *message = [QBChatMessage message];
        message.recipientID = self.recipientID; // opponent's id
        message.text = self.messageField.text;
        
        [[QBChat instance] sendMessage:message];
        self.messageField.text = @"";
        
        [self.messages addObject:message];
        
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
         [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else
    {
        //显示提示框
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"输入框为空...";
        hud.margin = 10.f;
        hud.yOffset = 0;
        hud.removeFromSuperViewOnHide = YES;
        
        [hud hide:YES afterDelay:2];
    }

}
@end
