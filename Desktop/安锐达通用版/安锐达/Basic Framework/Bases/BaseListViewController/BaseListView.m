//
//  BaseListView.m
//  GWFramework
//
//  Created by 郭炜 on 2017/6/1.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "BaseListView.h"
#import "BaseDataModel.h"
#import "AutoBindCell.h"
#import "Contains.h"
#import "BaseListViewRequest.h"
static NSString *selectedForModel = @"isSelectedWhileEditing";

@interface BaseListView () {
    Class _cls;
    bool isDeleteClicked;//标记是否点击删除按钮
    BOOL flag;
    BOOL loadMoreAgain;
}

@end

@implementation BaseListView

#pragma mark -- 初始化界面 --
- (void)initSubviews {
    [super initSubviews];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [UIView new];
    if (self.useOwnRefreshHeaderControll) {
        self.tableView.mj_header = [self.MJRefreshHeaderClass headerWithRefreshingTarget:self refreshingAction:@selector(refresh:)];
    }else {
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh:)];
    }
    if (self.action) {
        [self.tableView.mj_header beginRefreshing];
    }
}

#pragma mark -- 数据封装模型 --
- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = [NSMutableArray arrayWithArray:dataSource];
    Class tempClass = self.modelClass;
    for (int i = 0; i < _dataSource.count; i ++) {
        if ([_dataSource[i] class] == tempClass) {
            continue;
        }
        BaseDataModel *model;
        if (tempClass) {
            model = [[tempClass alloc] init];
            [model updateWithData:_dataSource[i]];
        }else {
            model = [self modelWithData:_dataSource[i]];
        }
        if (model) {
            _dataSource[i] = model;
        }
    }
    if (self.preHandleDataSource && [self.preHandleDataSource respondsToSelector:@selector(baseListviewWillShow:)]) {
        [self.preHandleDataSource performSelector:@selector(baseListviewWillShow:) withObject:_dataSource];
    }
    [self.tableView reloadData];
}

#pragma mark -- 构造 --
- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier {
    _CellIdentifier = identifier;
    [self.tableView registerClass:cellClass  forCellReuseIdentifier:(NSString *)identifier];
}

- (void)registerNibView:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier {
    _CellIdentifier = identifier;
    [self.tableView registerNib:nib forCellReuseIdentifier:(NSString *)identifier];
}

#pragma mark -- refresh && loadMore--
- (void)refresh:(NSNotification *)notification {
    [self refreshWithBlock:nil];
}

- (void)refreshWithBlock:(void (^)())block {
    _page = 1;
    if (self.didBeforeRefresh) {
        self.didBeforeRefresh();
    }
    if (self.tableView.mj_header.state == MJRefreshStateRefreshing || self.tableView.mj_header.state == MJRefreshStateIdle) {
        BaseListViewRequest *request = [BaseListViewRequest requestWithSuccessBlock:^(NSInteger errCode, NSDictionary *responseDict, id model) {
            if (!responseDict) {
                [self.tableView.mj_header endRefreshing];
            }else {
                if ([responseDict objectForKey:@"pageCount"]) {
                    _pageCount = ((NSString *)[responseDict objectForKey:@"pageCount"]).intValue;
                    _page = ((NSString *)[responseDict objectForKey:@"page"]).intValue;
                    if (_pageCount > _page) {
                        if (self.tableView.mj_footer == nil) {
                            if (self.useOwnRefreshFooterControll) {
                                self.tableView.mj_footer = [self.MJRefreshFooterClass footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
                            }else {
                                self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
                            }
                        }
                    }
                }
                self.jsonDataSource = [responseDict mutableCopy];
                [self setDataSource:[responseDict objectForKey:@"content"]];
                [self.tableView.mj_header endRefreshing];
                isDeleteClicked = NO;
                if (block) block();
            }
        } failureBlock:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"刷新失败"];
            [self.tableView.mj_header endRefreshing];
        }];
        request.url = self.action;
        request.param = self.para?self.para:[NSDictionary new];
        [request startRequest];
    }
}

- (void)loadMore {
    if (!loadMoreAgain) {
        loadMoreAgain = YES;
        BaseListViewRequest *request = [BaseListViewRequest requestWithSuccessBlock:^(NSInteger errCode, NSDictionary *responseDict, id model) {
            if (!responseDict) {
                [self.tableView.mj_footer endRefreshing];
            }else {
                [self.tableView.mj_footer endRefreshing];
                if ([responseDict objectForKey:@"pageCount"]) {
                    _pageCount = ((NSString *)[responseDict objectForKey:@"pageCount"]).intValue;
                    _page = ((NSString *)[responseDict objectForKey:@"page"]).intValue;
                    if (_pageCount == _page) {
                        [self.tableView.mj_footer removeFromSuperview];
                        self.tableView.mj_footer = nil;
                    }
                }
                NSArray *list = [responseDict objectForKey:@"content"];
                for(int i = 0;i < list.count;i ++){
                    BaseDataModel *model;
                    Class tempClass = self.modelClass;
                    if(tempClass){
                        model = [[tempClass alloc]init];
                        [model updateWithData:list[i]];
                    }else{
                        model = [self modelWithData:list[i]];
                    }
                    if(model)[self.dataSource addObject:model];
                    else [self.dataSource addObject:list[i]];
                }
                [self.tableView reloadData];
            }
        } failureBlock:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"加载更多失败"];
            [self.tableView.mj_footer endRefreshing];
        }];
        request.url = [NSString stringWithFormat:@"%@?sevpagespage=%d&sevpagecount=20",_action,_page+1];
        request.param = self.para?self.para:[NSDictionary new];
        [request startRequest];
    }
}

#pragma mark -- 代理方法 --
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.header) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.header) {
        if (section == 0) {
            return 1;
        }
    }
    return self.dataSource.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BaseDataModel *data = [self.dataSource objectAtIndex:indexPath.row];
    if (self.listener && [self.listener respondsToSelector:@selector(selectRowAtIndexPath:)]) {
        [self.listener performSelector:@selector(selectRowAtIndexPath:) withObject:data];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AutoBindCell *cell = [tableView dequeueReusableCellWithIdentifier:_CellIdentifier];
    if ([self modelClass]) {
        BaseDataModel *data = [self.dataSource objectAtIndex:indexPath.row];
        cell.Data = data;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;
    height = [self.tableView qmui_heightForCellWithIdentifier:_CellIdentifier cacheByIndexPath:indexPath configuration:^(__kindof UITableViewCell *cell) {
        AutoBindCell *cellDynamic = (AutoBindCell *)cell;
        if ([self modelClass]) {
            BaseDataModel *data = [self.dataSource objectAtIndex:indexPath.row];
            cellDynamic.Data = data;
        }
    }];
    return height;
}
#pragma mark -- 其他 --
- (BaseDataModel*)modelWithData:(NSDictionary*)data {
    return nil;
}

#pragma mark - 全选删除

-(void)deleteAllSelectedModel{
    for (BaseDataModel *model in self.dataSource) {
        if (model) {
            BOOL isSelected =[[model getValueWithKey:selectedForModel] boolValue];
            if (isSelected) {
                [model deleteWithBlock:^(){
                    [self refresh:nil];
                }];
            }
        }
    }
}

//侧滑删除按钮
-(NSString*)tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexpath{
    return self.deleteTitleWithLeftSlide?self.deleteTitleWithLeftSlide:@"删除";
}

//编辑模式下的状态（多选）
-(UITableViewCellEditingStyle )tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.editingStyle) {
        return self.editingStyle;
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (!isDeleteClicked) {
            isDeleteClicked = YES;
            BaseDataModel *model = self.dataSource[indexPath.row];
            if (self.DeleteWithModelBlock) {
                self.DeleteWithModelBlock(model);
            }else{
                [model deleteWithBlock:^(){
                    [self refresh:nil];
                    
                }];
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.ScrollViewScrollBlock) {
        self.ScrollViewScrollBlock(scrollView);
    }
}

#pragma mark -- init --
- (void)setAction:(NSString *)action {
    if (!_action) {
        _action = action;
        [self.tableView.mj_header beginRefreshing];
    }else {
        _action = action;
    }
}

- (void)setPara:(NSMutableDictionary *)para {
    _para = para;
}

-(void)setModelClass:(Class)cls{
    _cls=cls;
    if(_cls){
        NSString* modelName=[NSString stringWithFormat:@"%@",[self modelClass]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:[NSString stringWithFormat:@"addOrDelete%@",modelName] object:nil];
    }
}

- (Class)modelClass {
    return _cls;
}


@end
