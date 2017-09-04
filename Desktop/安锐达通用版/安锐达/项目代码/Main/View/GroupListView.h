//
//  GroupListView.h
//  安锐达
//
//  Created by 郭炜 on 2017/7/10.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YKMultiLevelTableView,YKNodeModel;
typedef void(^SelectBlock)(YKNodeModel *node);
@interface GroupListView : UIView
@property (nonatomic, strong) YKMultiLevelTableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *onLines;
@property (nonatomic, copy) SelectBlock block;

- (instancetype)initWithFrame:(CGRect)frame GroupList:(NSMutableArray *)groupList dataSource:(NSMutableArray *)dataSource online:(NSMutableDictionary *)onlineList;
@end
