//
//  LJFRoomVC.m
//  FiyChat
//
//  Created by lijianfei on 14-7-14.
//  Copyright (c) 2014年 lijianfei. All rights reserved.
//

#import "LJFRoomVC.h"
#import "MJRefresh.h"
#import "LJFRoomMessageVC.h"
@interface LJFRoomVC ()


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

- (IBAction)addRoomAction:(id)sender;

@property (nonatomic,strong) NSMutableArray *rooms;

@end

@implementation LJFRoomVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [[QBChat instance] loginWithUser:[LJFDataManager sheard].currentQBUser];
    
//    [self requestRooms];
//    [self showLoadingHUD];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.rooms = [NSMutableArray array];
    
//    [self requestRooms];
//    [self showLoadingHUD];
    [[QBChat instance] setDelegate:self];
    [self setupRefresh];

}
# pragma
# pragma mark  请求聊天室个数数据
- (void)requestRooms
{
    BOOL point;
    point = [[QBChat instance]  requestAllRooms];
    
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
    return self.rooms.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"room"];
    
    if (tableView != self.tableView)
    {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"room"];
        }
    }
    
    QBChatRoom *chatRoom = (QBChatRoom *)self.rooms[indexPath.row];
    cell.tag  = indexPath.row;
    cell.textLabel.text = chatRoom.name.length == 0 ? chatRoom.JID : chatRoom.name;
    
    return cell;
}
#pragma
#pragma mark - 集成刷新控件
/*
 1.将MJRefresh文件夹整个导入所需的工程中。(支持ARC,MRC工程要注意设置)
 
 2.文件夹中的MJRefresh.bundle—>arrow@2x.png 图片可自行替换,这个会在刷新过程中显示。
 
 3.可以在MJRefreshConst.h和MJRefreshConst.m文件中自定义显示的文字内容和文字颜色。
 
 4.只要你的view能够滚动，就能集成这个控件，比如UIScrollView、UITableView、UICollectionView
 
 5  导入头文件   #import "MJRefresh.h"
 */


- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    // 自动刷新(一进入程序就下拉刷新)
    [self.tableView headerBeginRefreshing];
}

#pragma
#pragma mark - 下拉刷新

//开始进入刷新状态
- (void)headerRereshing
{
    [self requestRooms];
//    [self showLoadingHUD];
    
    // 2.2秒后刷新表格UI
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 刷新表格
        [self.tableView reloadData];
        
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        [self.tableView headerEndRefreshing];
    });
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    LJFRoomMessageVC *messageVC = segue.destinationViewController;
    
    NSInteger index = [self.tableView indexPathForSelectedRow].row;
    
    QBChatRoom *room = (QBChatRoom *)self.rooms[index];
    
    messageVC.nowRoom = room;
    
    messageVC.title = room.name;
    //隐藏tabbar
    messageVC.hidesBottomBarWhenPushed = YES;
    
}

//创建房间
- (IBAction)addRoomAction:(id)sender
{
    NSLog(@"创建房间");
    //需要连接成功后才能建立房建
//    [[QBChat instance] loginWithUser:[LJFDataManager sheard].currentQBUser];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"输入要创建的群组名" message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.delegate = self;
    [alert show];
}


#pragma mark -
#pragma mark QBChatDelegate

- (void)chatDidLogin
{
    NSLog(@"%s,%d",__FUNCTION__,__LINE__);
    
    [self requestRooms];
}

- (void)chatRoomDidCreate:(QBChatRoom *)room
{
    NSLog(@"Room did create %@", room);
}

- (void)chatDidReceiveListOfRooms:(NSArray *)rooms;
{
    NSLog(@"%s,%d",__FUNCTION__,__LINE__);
//    [self hideHUB];
    [self.rooms removeAllObjects];
    [self.rooms addObjectsFromArray:rooms];
    [self.tableView reloadData];
}
#pragma mark
#pragma mark  HUD

- (void)showLoadingHUD
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
    
	HUD.delegate = self;
	HUD.labelText = @"刷新中...";
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
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        
        // Create a new Chat room
        NSString *roomName = [alertView textFieldAtIndex:0].text;
        if (roomName.length != 0)
        {
            NSLog(@"%@",roomName);
            //创建群组
            [[QBChat instance] createOrJoinRoomWithName:roomName membersOnly:NO persistent:YES];
            [self requestRooms];
//            [self showLoadingHUD];
        }
        else
        {
            NSLog(@"房间名不能为空");
        }
        
    }
}
@end
