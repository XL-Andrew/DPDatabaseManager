//
//  DBManager.h
//
//  Created by Andrew on 2017/7/10.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPDatabaseManager : NSObject

/* 
 * 实例化
 */
+ (instancetype)sharedDBManager;

/* 创建表或插入数据
 *
 * @param  model    所需存储的Model数据
 * @param  fileName 表名
 *
 * @return 是否创建或插入成功
 */
- (BOOL)insertDataWithModel:(id)model withFileName:(NSString *)fileName;

/* 获取表中最后一条数据
 *
 * @param  kclass   Model类
 * @param  fileName 表名
 *
 * @return Model类
 */
- (id)getLastDataWithModelClass:(Class)kclass withFileName:(NSString *)fileName;

/*
 * 倒序查找指定数量数据
 *
 * @param  count 所需数据个数
 * @param  kclass Model类
 * @param  fileName 表名
 *
 * @return 所存Model类数组
 */
- (NSArray *)getDataWithCount:(NSUInteger)count withModelClass:(Class)kclass withFileName:(NSString *)fileName;

/* 获取表中全部数据
 *
 * @param  kclass Model类
 * @param  fileName 表名
 *
 * @return 所存Model类数组
 */
- (NSArray *)getAllDataWithModelClass:(Class)kclass withFileName:(NSString *)fileName;

/*
 * 删除表文件
 */
- (BOOL)deleteDBFileWithFileName:(NSString *)fileName;

@end
