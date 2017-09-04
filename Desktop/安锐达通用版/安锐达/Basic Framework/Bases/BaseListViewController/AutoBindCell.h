//
//  AutoBindCell.h
//  GWFramework
//
//  Created by 郭炜 on 2017/6/1.
//  Copyright © 2017年 郭炜. All rights reserved.
//
#warning 要实现动态cell高度  必须重写sizeThatFits并返回rect

#import "QMUITableViewCell.h"

@class BaseDataModel;
@interface AutoBindCell : QMUITableViewCell
/*** cell所在的tableview */
@property (nonatomic, strong) UITableView *tableView;
/*** cell的indexPath */
@property (nonatomic, strong) NSIndexPath *indexPath;
/*** cell关联的模型 */
@property (nonatomic, strong) BaseDataModel *Data;

/*** 绑定数据，如果需要特殊的数据处理，在子类cell中重写这个方法，super一次，再自定义数据的使用  ***/
- (void)handleDataWithModel:(BaseDataModel *)data;

@end

