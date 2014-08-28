//
//  LJFRosterVC.m
//  FiyChat
//
//  Created by lijianfei on 14-7-14.
//  Copyright (c) 2014年 lijianfei. All rights reserved.
//

#import "LJFRosterVC.h"
#import "LJFRosterCell.h"
#import "MJRefresh.h"
#import "LJFMessageVC.h"
@interface LJFRosterVC ()<QBActionStatusDelegate>
{
    NSInteger _page;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *users;


@end

@implementation LJFRosterVC

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
     self.users = [NSMutableArray array];
    
    // 2.集成刷新控件
    [self setupRefresh];
    
    _page = 1;
//    [self fetchResultsWithPage:_page pageSize:10];
    
    
}


# pragma 
# pragma mark -内存警告
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    LJFMessageVC *messageVC = segue.destinationViewController;
    
    NSInteger index = [self.tableView indexPathForSelectedRow].row;
    
    QBUUser *user = (QBUUser *)self.users[index];
    
    messageVC.recipientID = user.ID;
    
    messageVC.title = user.login;
    //隐藏tabbar
    messageVC.hidesBottomBarWhenPushed = YES;

    
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
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
}

#pragma 
#pragma mark - 上拉加载

- (void)footerRereshing
{
    // 1.添加数据
    
    _page++;
    [self fetchResultsWithPage:_page pageSize:10];
    
    // 2.2秒后刷新表格UI
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 刷新表格
        [self.tableView reloadData];
        
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        [self.tableView footerEndRefreshing];
    });
}


#pragma
#pragma mark - 下拉刷新

//开始进入刷新状态
- (void)headerRereshing
{
    [self.users removeAllObjects];
    _page = 1;
    // 1.添加数据
    [self fetchResultsWithPage:_page pageSize:10];
    
    // 2.2秒后刷新表格UI
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 刷新表格
        [self.tableView reloadData];
        
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        [self.tableView headerEndRefreshing];
    });
}



# pragma
# pragma mark  - 请求用户个数数据
- (void)fetchResultsWithPage:(NSInteger)page pageSize:(NSInteger)pageSize
{
    // Retrieve QuickBlox users
    // 10 users per page
    //
    PagedRequest *request = [[PagedRequest alloc] init];
	request.perPage = pageSize;
	request.page = page;
	[QBUsers usersWithPagedRequest:request delegate:self];
}
#pragma mark
#pragma mark- QBActionStatusDelegate

- (void)completedWithResult:(Result *)result
{
    // Got users
    //
    if(result.success)
    {
        QBUUserPagedResult *res = (QBUUserPagedResult*)result;
//        NSLog(@"%@",res.users);
        
        [self.users addObjectsFromArray:res.users];
        
        for (int i = 0; i < self.users.count; i++)
        {
            QBUUser *user = (QBUUser *)self.users[i];
            NSLog(@"%@",user.login);
            if ([user.login isEqualToString:[LJFDataManager sheard].currentQBUser.login])
            {
                [self.users removeObjectAtIndex:i];
            }
        }
        
        
        
        [self.tableView reloadData];
    }
}
# pragma
# pragma mark - tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LJFRosterCell * cell = [tableView dequeueReusableCellWithIdentifier:@"roster"];
    
    if (tableView != self.tableView)
    {
        if (cell == nil) {
            cell = [[LJFRosterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"roster"];
        }
    }
    
    if (self.users.count != 0)
    {
        QBUUser *user = (QBUUser *)self.users[indexPath.row];
        //    cell.tag = indexPath.row;
        cell.userNameLabel.text = user.login;
    }
   
    
    return cell;
    
}
#pragma
#pragma mark - searchBar and SearchDisplay delegate
// return NO to not become first responder
// 询问searchBar 是否可以编辑，返回NO，则searchBar不能获得编辑
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"%s",__func__);
    return YES;
}
// called when text starts editing
// 当searchBar 开始编辑的时候触发，当searchBar获得焦点
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    //显示cancel按钮
    //    searchBar.showsCancelButton = YES;
    //    searchBar.showsBookmarkButton = YES;
    NSLog(@"%s",__func__);
    
}
// return NO to not resign first responder
// 当想要取消 searchBar 的第一响应者的时候，会咨询该方法，看searchBar 是否可以取消第一响应者，如果返回值是NO，则不能取消
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"%s",__func__);
    return YES;
    
}
// called when text ends editing
//当searchBar取消第一响应者的时候触发，也就是searchBar结束编辑
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"%s",__func__);
    
}
// called when text changes (including clear)
// 当searchBar里面的内容改变时触发，包括清空操作
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //苹果提供的 NSPredicate 类，主要用于指定过滤条件，该对象可以准确的描述所需的条件，对每一个对象用谓词进行筛选，判断该对象是否与筛选条件一致
    //predicateWithFormat 来创建一个用于筛选信息的谓词
    //self关键字，类似于方法调用中的一个self指针，表示当前被检索是否匹配的对象，contains [cd] 是一个字符串运算符，contains表示包含的意思，而后面的[cd] 则表示不区分大小写，不区分发音符号，另外还有两种格式，[c] 表示不区分大小写， [d] 表示不区分发音符号
    //对于我们的数组自带一个用来筛选的方法，filteredArrayUsingPredicate:可以根据我们创建的谓词，来循环检索数组中的每个对象是否满足条件，一旦符合条件，则将该对象标记为YES，循环检索完毕，将所有被标记的YES的对象存储在一个数组中返回
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains [cd] %@",searchText];
    //    NSLog(@"%@",searchText);
    
    //    self.filterArr = [[[_dicColor allKeys] filteredArrayUsingPredicate:predicate] sortedArrayUsingSelector:@selector(compare:)] ;
    
    
    //    NSLog(@"%@",_filterArr);
    
    NSLog(@"%s",__func__);
    
}
// called when keyboard search button pressed
// 当键盘上的 Search 按钮被点击时触发
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //    [searchBar resignFirstResponder];
    NSLog(@"%s",__func__);
    
}


// called when bookmark button pressed
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"%s",__func__);
    
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    //    [searchBar resignFirstResponder];
    //    searchBar.showsCancelButton = NO;
    //    searchBar.showsBookmarkButton = NO;
    NSLog(@"%s",__func__);
    
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope NS_AVAILABLE_IOS(3_0)
{
    NSLog(@"%s",__func__);
    
}


@end
