# DPDatabaseManager

基于FMDB进行二次封装，创建的用途主要用于聊天记录的存储。
###主要功能
* 直接存储Model
* 从数据库中取出的对象为传入的Model类型
* 从数据库中取出的全部数据是由传入的Model类型组成的数组集合

###支持大部分Model数据类型
例如：

```
#import <Foundation/Foundation.h>

@interface DemoModel : NSObject

@property (nonatomic, copy) NSString *string;

@property (nonatomic, assign) NSInteger integer;

@property (nonatomic, assign) NSUInteger uinteger;

@property (nonatomic, assign) BOOL kBool;

@property (nonatomic, assign) char kchar;

@property (nonatomic, assign) float kfloat;

@property (nonatomic, assign) double kdouble;

@property (nonatomic, assign) int kint;

@property (nonatomic, assign) id kid;

@property (nonatomic, retain) NSArray *array;

@property (nonatomic, retain) NSMutableArray *mutableArray;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic, retain) NSMutableDictionary *mutableDictionary;

@end

```

###使用方法  

* 单例方式实例化  

```
+ (instancetype)sharedDBManager;
```

* 插入数据  

```
/* 创建表或插入数据
 *
 * @param  model    所需存储的Model数据
 * @param  fileName 表名
 *
 * @return 是否创建或插入成功
 */
- (BOOL)insertDataWithModel:(id)model withFileName:(NSString *)fileName;
```

* 获取表中最后一条数据

```
/* 获取表中最后一条数据
 *
 * @param  kclass   Model类
 * @param  fileName 表名
 *
 * @return Model类
 */
- (id)getLastDataWithModelClass:(Class)kclass withFileName:(NSString *)fileName;
```

* 倒序查找指定数量数据

```
/*
 * @param  count    所需数据个数
 * @param  kclass   Model类
 * @param  fileName 表名
 *
 * @return 所存Model类数组
 */
- (NSArray *)getDataWithCount:(NSUInteger)count withModelClass:(Class)kclass withFileName:(NSString *)fileName;
```

* 获取表中全部数据


```
/*
 * @param  kclass   Model类
 * @param  fileName 表名
 *
 * @return 所存Model类数组
 */
- (NSArray *)getAllDataWithModelClass:(Class)kclass withFileName:(NSString *)fileName;
```

* 删除表文件


```
- (BOOL)deleteDBFileWithFileName:(NSString *)fileName;
```