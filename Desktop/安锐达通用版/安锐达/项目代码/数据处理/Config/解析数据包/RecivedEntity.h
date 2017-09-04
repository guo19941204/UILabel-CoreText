//
//  RecivedEntity.h
//  安锐达
//
//  Created by 郭炜 on 2017/6/9.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PackHead.h"

@interface RecivedEntity : NSObject

/*** 包头信息 */
@property (nonatomic, strong) PackHead *packHead;
/*** 收到的小包数量 */
@property (nonatomic, assign) int count;
/*** 包数组 */
@property (nonatomic, strong) NSMutableDictionary  *list;
/*** 包 */
@property (nonatomic, strong) NSMutableData *data;
/*** 包长 */
@property (nonatomic, assign) int pklenth;
@property (nonatomic, copy) NSString *key;

- (NSMutableData *)getData;

@end
