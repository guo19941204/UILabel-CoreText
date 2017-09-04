//
//  GroupListView.m
//  安锐达
//
//  Created by 郭炜 on 2017/7/10.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "GroupListView.h"
#import "Contains.h"
#import "DesModel.h"
#import "GroupModel.h"
#import "YKMultiLevelTableView.h"
#import "YKNodeModel.h"

@interface GroupListView () {
    NSMutableArray *_groupList;
    NSMutableArray *_dataSource;
    NSMutableArray *newGroupList;
}

@end
@implementation GroupListView

- (instancetype)initWithFrame:(CGRect)frame GroupList:(NSMutableArray *)groupList dataSource:(NSMutableArray *)dataSource online:(NSMutableDictionary *)onlineList {
    if (self = [super initWithFrame:frame]) {
        _groupList = groupList;
        _dataSource = dataSource;
        newGroupList = [NSMutableArray array];
        self.onLines = onlineList;
        [self addSubview:self.tableView];
    }
    return self;
}

#pragma mark -- data --
- (NSMutableArray *)handleData {
    NSMutableArray *parantIds = [[NSMutableArray alloc] init];
    NSMutableArray *childIds = [[NSMutableArray alloc] init];
    NSMutableDictionary *groupLevel = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *keys = [[NSMutableDictionary alloc] init];
    NSMutableArray *allkesArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < _groupList.count; i ++) {
        GroupModel *model = _groupList[i];
        [childIds addObject:[NSString stringWithFormat:@"%ld",model.groupId]];
        [parantIds addObject:[NSString stringWithFormat:@"%ld",model.fGroupId]];
        [allkesArray addObject:[NSString stringWithFormat:@"%ld",model.groupId]];
        [allkesArray addObject:[NSString stringWithFormat:@"%ld",model.fGroupId]];
    }
    for (NSString *str in allkesArray) {
        [keys setValue:str forKey:str];
    }
    for (int i = 0; i < _groupList.count; i ++) {
        NSString *parentId = parantIds[i];
        BOOL isFirstLevel = YES;
        for (int j = 0 ; j < _groupList.count; j ++) {
            NSString *childId = childIds[j];
            if ([parentId isEqualToString:childId]) {
                isFirstLevel = NO;
                break;
            }
        }
        if (isFirstLevel) {
            [groupLevel setValue:@(1) forKey:parentId];
            break;
        }
    }
    while (1) {
        for (int i = 0; i < childIds.count; i ++) {
            //获取对应idx下的parentID
            NSString *childId = childIds[i];
            NSString *parentId = parantIds[i];
            if ([groupLevel.allKeys containsObject:parentId]) {
                //如果等级列表中包含 则+1
                int level = [[groupLevel objectForKey:parentId] intValue];
                [groupLevel setValue:@(level+1) forKey:childId];
            }
        }
        if ([groupLevel.allKeys isEqualToArray:keys.allKeys]) {
            break;
        }
    }
    NSMutableArray *returnData = [[NSMutableArray alloc] init];
    for (int i = 0; i < _groupList.count; i ++) {
        GroupModel *model = _groupList[i];
        NSString *fGroupId = [NSString stringWithFormat:@"%ld",model.fGroupId];
        NSString *groupId = [NSString stringWithFormat:@"%ld",model.groupId];
        YKNodeModel *ykModel = [YKNodeModel nodeWithParentID:fGroupId name:model.groupName childrenID:groupId level:[[groupLevel objectForKey:groupId] intValue] isExpand:NO];
        [returnData addObject:ykModel];
    }
    
    for (int i = 0; i < _dataSource.count; i ++) {
        DesModel *model = _dataSource[i];
        NSString *groupId = [NSString stringWithFormat:@"%ld",model.groupId];
        NSString *childId = [NSString stringWithFormat:@"%d",i+1000];
        int level = [[groupLevel objectForKey:groupId] intValue] + 1;
        YKNodeModel *ykModel = [YKNodeModel nodeWithParentID:groupId name:model.title childrenID:childId level:level isExpand:NO];
        ykModel.desModel = model;
        [returnData addObject:ykModel];
    }
    return returnData;
}

- (YKMultiLevelTableView *)tableView {
    if (!_tableView) {
        CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH-110-150, SCREEN_HEIGHT);
        _tableView = [[YKMultiLevelTableView alloc] initWithFrame:frame
                                               nodes:[self handleData]
                                          rootNodeID:@"0"
                                    needPreservation:YES
                                         selectBlock:^(YKNodeModel *node) {
                                             NSLog(@"--select node name=%@", node.name);
                                             self.block(node);
                                         }];
        _tableView.onlines = self.onLines;
    }
    return _tableView;
}
@end
