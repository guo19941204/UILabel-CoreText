//
//  BaseDataModel.h
//  BaseViews
//
//  Created by 郭炜 on 2017/5/31.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseDataModel : NSObject

/*** view接口     列表中某一列的数据接口  传递keyName做参数 ***/
@property (nonatomic, retain) NSString *urlForView;
/*** edit接口       修改列表某一列数据接口  传递keyName做参数***/
@property (nonatomic, retain) NSString *urlForEdit;
/*** delete接口   删除列表某一列数据接口   传递keyName做参数***/
@property (nonatomic, retain) NSString *urlForDelete;
/*** keyName 数据库主键  根据keyName查询接口数据  列表每列数据中都必须有keyName ***/
@property (nonatomic, retain) NSString *keyName;
/*** identify  keyName字段下对应的值 */
@property (nonatomic, strong) NSString *identifier;
/*** inited  是否被初始化成功 */
@property (nonatomic, assign) BOOL inited;
/*** needNotify  是否注册通知*/
@property (nonatomic, assign) BOOL needNotify;
/*** needUpdate  是否需要更新 */
@property (nonatomic, assign) BOOL needUpdate;
/*** listener  观察者 */
@property (nonatomic, strong) NSMutableArray *listener;

/*** 给模型主键keyName 设值 ***/
-(void)setId:(NSString *)Id;
/*** 从内存中删除modelName类的所有模型 ***/
+(void)removeDataForModelName:(NSString*)modelName;
/*** 模型中，通过key名获取到对应的值 ***/
-(id)getValueWithKey:(NSString*)key;
/*** 给模型设值 ***/
-(void)setValue:(id)value withKey:(NSString*)key;
/*** 用于模型内容改变  添加观察 ***/
- (void)addDataChangedListener:(id<NSObject>)listener;
/*** 移除 ***/
- (void)removeDataChangedListener:(id<NSObject>)listener;
/*** 移除 ***/
- (void)removeAllListener;
/*** 通知模型数据已经修改 ***/
-(void)notifyDataChanged;
/*** 通过主键值初始化模型 ***/
-(id)initWithId:(NSString*)Id;
/*** 通过字典数据初始化模型 ***/
-(id)initWithData:(NSDictionary*)data;
/*** 通过字典更新数据模型 ***/
-(void)updateWithData:(NSDictionary*)data;
/*** 刷新数据模型 ***/
-(void)reloadWithBlock:(id)block;
-(void)updateWithBlock:(id)block;
/*** 删除数据模型 ***/
-(void)deleteWithBlock:(id)block;
-(void)restore;
/*** 删除新数据模型中的数据 ***/
-(void)backOldValue;
/*** 获取更新后模型的cout ***/
-(NSInteger)getUpdateDataCount;
/*** 将修改后的数据模型的值 与旧模型的值合二为一 返回为旧模型的值 ***/
- (NSMutableDictionary *)bindValues;
/*** 获取数据 传递id keyName ***/
-(id)initAndGetWithPara:(NSDictionary *)para andKeyName:(NSString *)KeyName;
/*** 通过id初始化模型 数据返回取到模型值后回调 ***/
- (void)callBackWithId:(NSString *)Id callback:(id)block;
/*** delet方法，针对identitifier对应的value并不是keyname对应的value，传一个keyname进来删除 ***/
- (void)deleteWithKeyName:(NSString *)keyName block:(id)block;

@end
