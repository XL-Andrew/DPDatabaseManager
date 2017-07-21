//
//  DPDatabaseUtils.h
//  DPDatabaseManager
//
//  Created by Andrew on 2017/7/21.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPDatabaseUtils : NSObject

//字典转json
+ (NSString *)dictionaryToJson:(NSDictionary *)dic;

//json转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

//根据id变量类型转化为对应string以供存储
+ (id)getIDVariableValueTypesWithString:(NSString *)string;

//根据存储的信息转为对应的变量类型
+ (NSString *)setIDVariableToString:(id)value;

@end
