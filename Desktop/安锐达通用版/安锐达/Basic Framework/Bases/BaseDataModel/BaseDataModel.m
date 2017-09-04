//
//  BaseDataModel.m
//  BaseViews
//
//  Created by 郭炜 on 2017/5/31.
//  Copyright © 2017年 郭炜. All rights reserved.
//

#import "BaseDataModel.h"
#import "ModelRequest.h"

@interface BaseDataModel () {
    NSDictionary *getDic;
    NSMutableDictionary *_values;
    NSMutableDictionary *_newValues;
    Boolean (^callBack) (void);
    void (^callBackLoad)(BaseDataModel *model);
}

@end

@implementation BaseDataModel
static NSMutableDictionary* records;

/**
 *  records={@"xxxEntity:{identify:xxxEntity,identify:xxxEntity}";@"xxxModel":{identify:xxxModel,identify:xxxModel}};
 *
 */
+ (NSMutableDictionary *)getCacheWithModel:(Class)model {
    if(!records)records = [NSMutableDictionary new];
    NSString *modelName = [NSString stringWithFormat:@"%@",model];
    NSMutableDictionary *cache = records[modelName];
    if(!cache){
        cache = [NSMutableDictionary new];
        records[modelName] = cache;
    }
    return cache;
}

+ (void)removeDataForModelName:(NSString *)modelName {
    [records removeObjectForKey:modelName];
}

-(NSMutableDictionary *)values{
    if(!_values){
        _values = [NSMutableDictionary new];
    }
    if(!_newValues){
        _newValues = [NSMutableDictionary new];
    }
    return _values;
}

#pragma mark -- 构造方法 --
- (id)initWithId:(NSString *)Id {
    self = [self init];
    if(self){
        if(self.keyName){
            if(Id && ![@"" isEqual:Id]) {
                [self.values setObject:Id forKey:self.keyName];
                NSMutableDictionary *cache = [BaseDataModel getCacheWithModel:self.class];
                BaseDataModel *data = cache[Id];
                if(!data){
                    cache[Id] = self;
                    [self reloadWithBlock:nil];
                }else{
                    self = data;
                }
            }
        }
    }else{
        self = [super init];
    }
    return self;
}

- (void)reloadWithBlock:(id)block {
    if(!self.urlForView)return;
    ModelRequest *request = [ModelRequest requestWithSuccessBlock:^(NSInteger errCode, NSDictionary *responseDict, id model) {
        if ([responseDict isKindOfClass:[NSDictionary class]]) {
            if (responseDict[self.keyName]) {
                self.inited = YES;
                _values = [NSMutableDictionary dictionaryWithDictionary:responseDict];
                _newValues = [NSMutableDictionary new];
                self.needNotify = YES;
                [self notifyDataChanged];
                callBack = block;
                if (callBack) {
                    callBack();
                }
            }
        }
    } failureBlock:^(NSError *error) {
        
    }];
    request.url = self.urlForView;
    request.param = @{self.keyName:self.identifier};
    [request startRequest];
}

- (void)callBackWithId:(NSString *)Id callback:(id)block {
    if(self){
        if(self.keyName){
            if(Id&&![@"" isEqual:Id]){
                [self.values setObject:Id forKey:self.keyName];
                //没有从模型里面取，因为从模型里面取的话有时候会少字段 该问题未解决
                [self reloadWithBlock:^(){
                    callBackLoad = block;
                    if (callBackLoad) {
                        callBackLoad(self);
                    }
                }];
            }
        }
    }else{
        callBackLoad(nil);
    }
}

-(id)initAndGetWithPara:(NSDictionary *)para andKeyName:(NSString *)KeyName{
    self=[self init];
    if(self){
        if(self.keyName){
            if(para[KeyName]&&![@"" isEqual:para[KeyName]]){
                NSArray *arr = [para allKeys];
                for (int i=0; i<arr.count; i++) {
                    [self.values setObject:para[arr[i]] forKey:arr[i]];
                }
                getDic = para;
                NSMutableDictionary* cache=[BaseDataModel getCacheWithModel:self.class];
                BaseDataModel* data=cache[para[KeyName]];
                if(!data){
                    cache[para[KeyName]]=self;
                    [self getDataWithBlock:nil];
                }else{
                    self=data;
                }
            }
        }
    }else{
        self=[super init];
    }
    return self;
}

-(void)getDataWithBlock:(id)block{
    if(!self.urlForView)return;
    ModelRequest *request = [ModelRequest requestWithSuccessBlock:^(NSInteger errCode, NSDictionary *responseDict, id model) {
        if ([responseDict isKindOfClass:[NSDictionary class]]) {
            if (responseDict[self.keyName]) {
                self.inited = YES;
                _values = [NSMutableDictionary dictionaryWithDictionary:responseDict];
                _newValues = [NSMutableDictionary new];
                self.needNotify = YES;
                [self notifyDataChanged];
                callBack = block;
                if (callBack) {
                    callBack();
                }
            }
        }
    } failureBlock:^(NSError *error) {
        
    }];
    request.url = self.urlForView;
    request.param = getDic;
    [request startRequest];
}

-(id)initWithData:(NSDictionary*)json{
    self=[self init];
    if(self){
        if(self.keyName){
            if(json[self.keyName]){
                NSMutableDictionary* cache=[BaseDataModel getCacheWithModel:self.class];
                BaseDataModel* data=cache[json[self.keyName]];
                if(!data){
                    _values=[NSMutableDictionary dictionaryWithDictionary:json];
                    _newValues=[NSMutableDictionary new];
                    cache[json[self.keyName]]=self;
                    self.inited=YES;
                    self.needNotify=YES;
                    [self notifyDataChanged];
                }else{
                    self=data;
                    if(!self.needUpdate)[self updateWithData:json];
                }
            }
        }
    }else{
        self=[super init];
    }
    return self;
}

- (void)updateWithData:(NSDictionary*)data {
    NSMutableDictionary* cache=[BaseDataModel getCacheWithModel:self.class];
    if(data[self.keyName]){
        BaseDataModel* oldModel=cache[data[self.keyName]];
        if(oldModel){
            if(self!=oldModel){
                for (id item in oldModel.listener) {
                    [self.listener addObject:item];
                }
                [oldModel removeAllListener];
                cache[data[self.keyName]]=self;
                self.inited=YES;
                _values=[NSMutableDictionary dictionaryWithDictionary:data];
                self.needNotify=YES;
            }
        }else{
            cache[data[self.keyName]]=self;
            self.inited=YES;
            _values=[NSMutableDictionary dictionaryWithDictionary:data];
            _newValues=[NSMutableDictionary new];
            self.needNotify=YES;
        }
    }
    for (NSString* key in data.allKeys) {
        [self setValue:data[key] withKey:key];
    }
    [self notifyDataChanged];
}

- (void)updateWithBlock:(id)block {
    callBack=block;
    if(self.inited&&!self.needUpdate) {
        if(callBack)callBack();
        return;
    }
    if(!self.urlForEdit){
        if(callBack)callBack();
        return;
    }
    NSMutableDictionary*para=[_values copy];
    for (NSString* key in _newValues.allKeys) {
        para[key]=_newValues[key];
    }
    ModelRequest *request = [ModelRequest requestWithSuccessBlock:^(NSInteger errCode, NSDictionary *responseDict, id model) {
        if (!responseDict) return;
        if ([responseDict isKindOfClass:[NSDictionary class]]) {
            if (!self.inited && responseDict[self.keyName]) {
                _values[self.keyName] = responseDict[self.keyName];
                self.inited = YES;
                NSString *modelName = [NSString stringWithFormat:@"%@",self.class];
                [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"addOrDelete%@",modelName] object:nil userInfo:nil];
            }
            self.needNotify=YES;
            [self updateWithData:responseDict];
            [_newValues removeAllObjects];
            if(callBack)callBack();
        }
    } failureBlock:^(NSError *error) {
        
    }];
    request.url = self.urlForEdit;
    request.param = para;
    [request startRequest];
}

-(void)deleteWithBlock:(id)block{
    _listener = nil;
    callBack=block;
    if(!self.inited||!self.urlForDelete){
        if(callBack)callBack();
        return;
    }
    ModelRequest *request = [ModelRequest requestWithSuccessBlock:^(NSInteger errCode, NSDictionary *responseDict, id model) {
        if([responseDict isKindOfClass:[NSDictionary class]]){
            NSMutableDictionary* cache=[BaseDataModel getCacheWithModel:self.class];
            if(self.inited){
                self.inited=NO;
                [cache removeObjectForKey:self.identifier];
                NSString* modelName=[NSString stringWithFormat:@"%@",self.class];
                [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"addOrDelete%@",modelName] object:nil userInfo:nil];
                if(callBack)callBack();
            }
        }
    } failureBlock:^(NSError *error) {
        
    }];
    request.url = self.urlForDelete;
    request.param = @{self.keyName:self.identifier};
    [request startRequest];
}

//delet方法，针对identitifier对应的value并不是keyname对应的value，传一个keyname进来删除
- (void)deleteWithKeyName:(NSString *)keyName block:(id)block {
    _listener = nil;
    callBack=block;
    if(!self.inited||!self.urlForDelete){
        if(callBack)callBack();
        return;
    }
    ModelRequest *request = [ModelRequest requestWithSuccessBlock:^(NSInteger errCode, NSDictionary *responseDict, id model) {
        if([responseDict isKindOfClass:[NSDictionary class]]){
            NSMutableDictionary* cache=[BaseDataModel getCacheWithModel:self.class];
            if(self.inited){
                self.inited=NO;
                [cache removeObjectForKey:self.identifier];
                NSString* modelName=[NSString stringWithFormat:@"%@",self.class];
                [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"addOrDelete%@",modelName] object:nil userInfo:nil];
                if(callBack)callBack();
            }
        }
    } failureBlock:^(NSError *error) {
        
    }];
    request.url = self.urlForDelete;
    request.param = @{self.keyName:self.identifier};
    [request startRequest];
}

#pragma mark -- 通知 代理回调 --
- (NSMutableArray*)listener {
    if(!_listener)_listener=[NSMutableArray new];
    return _listener;
}

- (void)addDataChangedListener:(id<NSObject>)listener {
    if (listener && [listener respondsToSelector:@selector(handleDataWithModel:)]) {
        if(!_listener){
            _listener=[NSMutableArray arrayWithObjects:listener,nil];
        }else{
            [_listener addObject:listener];
        }
        [listener performSelector:@selector(handleDataWithModel:) withObject:self];
    }
}

- (void)removeDataChangedListener:(id<NSObject>)listener {
    if(_listener){
        [_listener removeObject:listener];
    }
}

- (void)removeAllListener {
    if(_listener){
        [_listener removeAllObjects];
    }
}

- (void)dealloc {
    [_listener removeAllObjects];
}

- (void)notifyDataChanged {
    if(!self.needNotify)return;
    for (id<NSObject> delegate in _listener) {
        if (delegate && [delegate respondsToSelector:@selector(handleDataWithModel:)]) {
            [delegate performSelector:@selector(handleDataWithModel:) withObject:self];
        }
    }
    self.needNotify=NO;
}
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_values forKey:@"values"];
    
}
-(id) initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super init])
    {
        _values = [aDecoder decodeObjectForKey:@"values"];
    }
    return self;
}
- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    if (![object isKindOfClass:[BaseDataModel class]]) {
        return NO;
    }
    BaseDataModel *myItem = (BaseDataModel *)object;
    return [myItem.identifier isEqual:self.identifier];
}

- (NSUInteger)hash {
    return [self.identifier hash];
}

- (NSString*)identifier {
    if([_values objectForKey:self.keyName])return [_values objectForKey:self.keyName];
    else return @"";
}

- (void)setId:(NSString *)Id {
    if([@"" isEqualToString:self.identifier]){
        [self.values setObject:Id forKey:self.keyName];
        [self reloadWithBlock:nil];
    }
}

- (id)getValueWithKey:(NSString*)key {
    if(_newValues[key]){
        return _newValues[key];
    }
    return [self.values objectForKey:key];
}

- (void)setValue:(id)value withKey:(NSString*)key {
    if(!value)return;
    if([key isEqual:self.keyName])return;
    id oldValue=[self getValueWithKey:key];
    if(oldValue){
        Boolean compare=![self compareValue:value toValue:oldValue];
        if(compare){
            if (!_newValues) {
                _newValues=[NSMutableDictionary new];
            }
            _newValues[key]=value;
        }
        self.needNotify|=compare;
    }else{
        _newValues[key]=value;
        self.needNotify=YES;
    }
}

- (void)restore {
    [_newValues removeAllObjects];
    self.needNotify=YES;
    [self notifyDataChanged];
}

- (BOOL)needUpdate {
    return _newValues.count>0;
}

-(Boolean)compareValue:(id)value toValue:(id)another{
    @try {
        Boolean temp=NO;
        if([another isKindOfClass:[NSNumber class]]){
            temp=(value==another);
        }else{
            temp=[value isEqualToString:another];
        }
        if(!temp){
            @try {
                return [value isEqual:another];
            }
            @catch (NSException *exception) {
                return YES;
            }
        }
        return temp;
    }
    @catch (NSException *exception) {
        return YES;
    }
}

- (void)backOldValue {
    [_newValues removeAllObjects];
}

-(NSInteger)getUpdateDataCount {
    return _newValues.count;
}

- (NSMutableDictionary *)bindValues {
    
    for (NSString* key in _newValues.allKeys) {
        _values[key]=_newValues[key];
    }
    return _values;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> ---- %@",[self class],self,_values];
}


@end
