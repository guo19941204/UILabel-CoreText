//
//  BaseListView.h
//  GWFramework
//
//  Created by 郭炜 on 2017/6/1.
//  Copyright © 2017年 郭炜. All rights reserved.
//

/*** 该自动绑定列表视图  目前只支持单个section的  如果需要分组展示  可根据服务器返回的字段 判断分组的标识 ***/
#import "QMUICommonTableViewController.h"

@class AutoBindCell,BaseDataModel;
@interface BaseListView : QMUICommonTableViewController {
    int _page;
    int _pageSize;
    int _pageCount;
    NSIndexPath *editingRow;
    NSMutableDictionary *cells;
    AutoBindCell *currentCell;
}

/*** 数据模型 */
@property (nonatomic, strong) BaseDataModel *Data;
/*** 表头  可自定义一个不同的Cell作为 header */
@property (nonatomic, strong) UITableViewCell *header;
/*** 数据源 <NSArray * BaseDataModel>*/
@property (nonatomic, strong) NSMutableArray *dataSource;
/*** 数据源 列表的json数据***/
@property (nonatomic, strong) NSMutableDictionary *jsonDataSource;
/*** 请求参数 */
@property (nonatomic, strong) NSMutableDictionary *para;
/*** 请求url  必须摄者action才能进行自动绑定*/
@property (nonatomic, copy) NSString *action;
/*** 代理 点击事件*/
@property (nonatomic, strong) id listener;
/*** 代理 数据源  设置preHandleDataSource=self 可在数据封装成模型数据 列表还未加载的时候进行业务处理*/
@property (nonatomic, strong) id preHandleDataSource;
/*** 侧滑删除按钮提示，默认为“删除” */
@property (nonatomic, copy) NSString *deleteTitleWithLeftSlide;
/*** tableview滚动delegate的回调 */
@property (nonatomic, copy) void(^ScrollViewScrollBlock)(UIScrollView *scrollView);
/*** 删除回调 */
@property (nonatomic, copy) void(^DeleteWithModelBlock)(BaseDataModel *model);
/*** 数据加载之前处理   可在该回调中添加toast等处理*/
@property (nonatomic, copy) void(^didBeforeRefresh)(void);
/*** 是否使用自定义的下拉刷新控件 默认为NO      注意 如果要使用自定义的刷新控件的时候 self.listView.useOwnRefreshHeaderControll = YES; 必须放在 registNib||registClass 之前！不然不会生效*/
@property (nonatomic, assign) BOOL useOwnRefreshHeaderControll;
/*** 是否使用自定义的上拉加载刷新控件 默认为NO */
@property (nonatomic, assign) BOOL useOwnRefreshFooterControll;
/*** 如果要使用新的下拉刷新控件  设置changeRefreshControl为self，在子controller中做处理***/
@property (nonatomic, strong) Class MJRefreshHeaderClass;
/*** 如果要使用新的上拉加载控件  设置changeRefreshControl为self，在子controller中做处理 */
@property (nonatomic, strong) Class MJRefreshFooterClass;

/*** cell的identify */
@property (nonatomic, strong, readonly) NSString *CellIdentifier;
/*** 编辑模式的类型 ***/
@property (assign, nonatomic) UITableViewCellEditingStyle editingStyle;



/*** 根据cell类初始化cell ***/
- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier;
/*** 根据nib初始化cell ***/
- (void)registerNibView:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier;
/*** 设置该列表数据对应的模型 ***/
- (void)setModelClass:(Class)cls;
/*** 获取该列表对应的模型类 ***/
- (Class)modelClass;
/*** 刷新  数据刷新完可在block回调中做其他业务处理  比如隐藏toast***/
-(void)refreshWithBlock:(void (^)())block;
/*** 刷新 ***/
- (void)refresh:(NSNotification*)notification;
/*** 多选删除 ***/
-(void)deleteAllSelectedModel;




@end
