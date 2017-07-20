//
//  DBManager.m
//
//  Created by Andrew on 2017/7/10.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "DPDatabaseManager.h"
#import "FMDB.h"
#import <objc/runtime.h>

typedef enum : NSUInteger {
    SQLStringTypeCreate,            //创建
    SQLStringTypeInsert,            //插入
    SQLStringTypeUpdate,            //更新
    SQLStringTypeGetTheLastData,    //获取最后一条
    SQLStringTypeGetSeveralData,    //倒叙查询几条
    SQLStringTypeGetAllData,        //获取全部
} SQLStringType;

//自增字段
#define AUTOINCREMENT_FIELD @"chatID"

@interface DPDatabaseManager ()

@property (nonatomic, strong) FMDatabaseQueue *baseQueue;

@property (nonatomic, copy) NSString *dbFilePath;   //数据库路径

@property (nonatomic, copy) NSString *dbTableName;   //数据库文件名

@end

@implementation DPDatabaseManager

static DPDatabaseManager *_instance;
+ (instancetype)sharedDBManager
{
    static dispatch_once_t onceToken_FileManager;
    
    dispatch_once(&onceToken_FileManager, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

#pragma mark - public
//创建表 && 插入数据
- (BOOL)insertDataWithModel:(id)model withFileName:(NSString *)fileName
{
    [self getFilePathWithFileName:fileName];
    BOOL __block result;
    [self.baseQueue inDatabase:^(FMDatabase *db) {
        if ([db open])
        {
            //为数据库设置缓存，提高查询效率
            [db setShouldCacheStatements:YES];
            if(![db tableExists:_dbTableName]) {//表不存在
                    if(![db tableExists:_dbTableName]) {
                        if ([db executeUpdate:[self concatenateSQLStringWithType:SQLStringTypeCreate withModel:model withDataCount:0]]) {
                            if ([db executeUpdate:[self concatenateSQLStringWithType:SQLStringTypeInsert withModel:model withDataCount:0]]) {
                                result = YES;
                                NSLog(@"表创建成功 数据插入成功");
                            } else {
                                result = NO;
                                NSLog(@"数据插入失败");
                            }
                        }
                    }
                    
            } else { //表已存在
                if ([db executeUpdate:[self concatenateSQLStringWithType:SQLStringTypeInsert withModel:model withDataCount:0]]) {
                    result = YES;
                    NSLog(@"数据插入成功");
                } else {
                    result = NO;
                    NSLog(@"数据插入失败");
                }
            }
        }
        [db close];
        
    }];
    return result;
}

//获取最后一条数据
- (id)getLastDataWithModelClass:(Class)kclass withFileName:(NSString *)fileName
{
    [self getFilePathWithFileName:fileName];
    id __block objc = [[[kclass class] alloc]init];
    [self.baseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        if ([db open]) {
            if(![db tableExists:_dbTableName]) {
                NSLog(@"表格不存在");
                return;
            }
            FMResultSet *res = [db executeQuery:[self concatenateSQLStringWithType:SQLStringTypeGetTheLastData withModel:nil withDataCount:0]];
            while ([res next]) {
                
                NSString __block *jsonString = @"";
                [[res resultDictionary] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if (![key isEqualToString:AUTOINCREMENT_FIELD]) {
                        jsonString = [NSString stringWithFormat:@"%@",obj];
                    }
                }];
                
                objc = [self getModel:kclass withDataDic:[self dictionaryWithJsonString:jsonString]];
                
            }
        }
        [db close];
    }];
    return objc;
}

//倒序查找指定数量数据
- (NSArray *)getDataWithCount:(NSUInteger)count withModelClass:(Class)kclass withFileName:(NSString *)fileName
{
    [self getFilePathWithFileName:fileName];
    NSMutableArray *result = [[NSMutableArray alloc]init];
    [self.baseQueue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            
            if(![db tableExists:_dbTableName]) {
                NSLog(@"表格不存在");
                return;
            }
            FMResultSet *res = [db executeQuery:[self concatenateSQLStringWithType:SQLStringTypeGetSeveralData withModel:nil withDataCount:count]];
            
            while ([res next]) {
                
                NSString __block *jsonString = @"";
                [[res resultDictionary] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if (![key isEqualToString:AUTOINCREMENT_FIELD]) {
                        jsonString = [NSString stringWithFormat:@"%@",obj];
                    }
                }];
                
                id objc = [[[kclass class] alloc]init];
                objc = [self getModel:kclass withDataDic:[self dictionaryWithJsonString:jsonString]];
                [result addObject:objc];
            }
        }
        [db close];
    }];
    return [result copy];
}

//获取全部数据
- (NSArray *)getAllDataWithModelClass:(Class)kclass withFileName:(NSString *)fileName
{
    [self getFilePathWithFileName:fileName];
    NSMutableArray *result = [[NSMutableArray alloc]init];
    [self.baseQueue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            
            if(![db tableExists:_dbTableName]) {
                NSLog(@"表格不存在");
                return;
            }
            FMResultSet *res = [db executeQuery:[self concatenateSQLStringWithType:SQLStringTypeGetAllData withModel:nil withDataCount:0]];
            
            while ([res next]) {
                
                NSString __block *jsonString = @"";
                [[res resultDictionary] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if (![key isEqualToString:AUTOINCREMENT_FIELD]) {
                        jsonString = [NSString stringWithFormat:@"%@",obj];
                    }
                }];
                
                id objc = [[[kclass class] alloc]init];
                objc = [self getModel:kclass withDataDic:[self dictionaryWithJsonString:jsonString]];
                [result addObject:objc];
            }
        }
        [db close];
    }];
    return [result copy];
}

- (BOOL)deleteDBFileWithFileName:(NSString *)fileName
{
    [self getFilePathWithFileName:fileName];
    if ([[NSFileManager defaultManager] removeItemAtPath:_dbFilePath error:nil]) {
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - private

//拼接SQL语句方法
- (NSString *)concatenateSQLStringWithType:(SQLStringType)type withModel:(id)model withDataCount:(NSUInteger)count
{
    NSString *statementString = @"";
    
    switch (type) {
        case SQLStringTypeCreate: {
            statementString = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,JSON TEXT)",_dbTableName,AUTOINCREMENT_FIELD];
        }
            break;
        case SQLStringTypeInsert: {
            NSString *jsonString = @"";
            
            NSMutableDictionary *jsonDic = [NSMutableDictionary dictionary];
            
            unsigned int numIvars;      //成员变量个数
            NSString *kvarsKey = @"";   //获取成员变量的名字
            NSMutableArray *kvarsKeyArr = [NSMutableArray array];  //成员变量名字数组
            
            Ivar *vars = class_copyIvarList([model class], &numIvars);
            
            //获取成员变量名字/类型
            for(int i = 0; i < numIvars; i++) {
                
                Ivar thisIvar = vars[i];
                kvarsKey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
                if ([kvarsKey hasPrefix:@"_"]) {
                    kvarsKey = [kvarsKey stringByReplacingOccurrencesOfString:@"_" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 1)];
                }
                [kvarsKeyArr addObject:kvarsKey];
            }
            
            //拼接字典 key - 变量名称 value - 变量值
            [kvarsKeyArr enumerateObjectsUsingBlock:^(NSString *memberKey, NSUInteger idx, BOOL * _Nonnull stop) {
                id memberValue = [model valueForKey:memberKey]?:@"";
                [jsonDic setObject:memberValue forKey:memberKey];
            }];
            
            //字典转json
            jsonString = [self dictionaryToJson:jsonDic];
            
            statementString = [NSString stringWithFormat:@"INSERT INTO %@ (JSON) VALUES ('%@')",_dbTableName,jsonString];
            
            free(vars);
        }
            break;
        case SQLStringTypeUpdate: {
            //暂不支持
        }
            break;
        case SQLStringTypeGetSeveralData: {
            statementString = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ DESC LIMIT %ld",_dbTableName,AUTOINCREMENT_FIELD,count];
        }
            break;
        case SQLStringTypeGetTheLastData: {
            statementString = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ DESC LIMIT 1",_dbTableName,AUTOINCREMENT_FIELD];
        }
            break;
            
        case SQLStringTypeGetAllData: {
            statementString = [NSString stringWithFormat:@"SELECT * FROM %@",_dbTableName];
        }
            break;
            
        default:
            break;
    }
    
    return statementString;
}

// 通过字典获取模型数据
- (id)getModel:(Class)kclass withDataDic:(NSDictionary *)kDic
{
    id objc = [[[kclass class] alloc]init];
    
    unsigned int methodCount = 0;
    NSString *kvarsKey = @"";   //获取成员变量的名字
    NSString *kvarsType = @"";  //成员变量类型
    
    Ivar * ivars = class_copyIvarList([kclass class], &methodCount);
    for (int i = 0 ; i < methodCount; i ++) {
        Ivar ivar = ivars[i];
        kvarsKey = [NSString stringWithUTF8String:ivar_getName(ivar)];
        if ([kvarsKey hasPrefix:@"_"]) {
            kvarsKey = [kvarsKey stringByReplacingOccurrencesOfString:@"_" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 1)];
        }
        kvarsType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        
        NSString *tempValue = [kDic objectForKey:kvarsKey];
        
        if (!tempValue) { continue; }
        
        NSString *kDicValue = [NSString stringWithFormat:@"%@",tempValue];
        
        /*  类型码判断
            根据当前Model的成员变量类型,来给变量赋值.
         */
        
        //c - char
        if ([kvarsType isEqualToString:@"c"]) {}
        //i - int
        else if ([kvarsType isEqualToString:@"i"]) {}
        //s - short
        else if ([kvarsType isEqualToString:@"s"]) {}
        //l - long
        else if ([kvarsType isEqualToString:@"l"]) {}
        //q - long long
        else if ([kvarsType isEqualToString:@"q"]) {}
        //C - unsigned char
        else if ([kvarsType isEqualToString:@"C"]) {}
        //I - unsigned int
        else if ([kvarsType isEqualToString:@"I"]) {}
        //S - unsigned short
        else if ([kvarsType isEqualToString:@"S"]) {}
        //L - unsigned long
        else if ([kvarsType isEqualToString:@"L"]) {}
        //Q - unsigned long long
        else if ([kvarsType isEqualToString:@"Q"]) {
            [objc setValue:[NSNumber numberWithUnsignedInteger:[kDicValue integerValue]] forKey:kvarsKey];
        }
        //f - float
        else if ([kvarsType isEqualToString:@"f"]) {}
        //d - double
        else if ([kvarsType isEqualToString:@"d"]) {}
        //B - bool or a C99 _Bool
        else if ([kvarsType isEqualToString:@"B"]) {
            
            if ([kDicValue isEqualToString:@"1"]) {
                [objc setValue:@YES forKey:kvarsKey];
            } else {
                [objc setValue:@NO forKey:kvarsKey];
            }
        }
        //v - void
        else if ([kvarsType isEqualToString:@"v"]) {}
        //* - char *
        else if ([kvarsType isEqualToString:@"*"]) {}
        //@ - id
        else if ([kvarsType isEqualToString:@"@"]) {}
        //# - Class
        else if ([kvarsType isEqualToString:@"#"]) {}
        //: - SEL
        else if ([kvarsType isEqualToString:@":"]) {}
        //@"NSArray" - array
        else if ([kvarsType containsString:@"NSArray"]) {}
        //? - unknown type
        else {
            [objc setValue:[kDic objectForKey:kvarsKey] forKey:kvarsKey];
        }
    }
    free(ivars);
    return objc;
}

//获取文件路径
- (void)getFilePathWithFileName:(NSString *)fileName
{
    NSAssert(fileName || ![fileName isEqualToString:@""], @"数据库文件名不可为空!");
    _dbTableName = [@"DBA" stringByAppendingString:fileName];
    _dbFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",_dbTableName]];
}

- (NSString *)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (FMDatabaseQueue *)baseQueue
{
    if (!_baseQueue) {
        _baseQueue = [FMDatabaseQueue databaseQueueWithPath:_dbFilePath];
    }
    return _baseQueue;
}

@end
