//
//  DPDatabaseUtils.m
//  DPDatabaseManager
//
//  Created by Andrew on 2017/7/21.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "DPDatabaseUtils.h"
#import <UIKit/UIKit.h>

@implementation DPDatabaseUtils

+ (NSString *)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
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

//根据id变量类型转化为对应string以供存储
+ (NSString *)setIDVariableToString:(id)varialeValue
{
    //NSString类型
    if ([varialeValue isKindOfClass:[NSString class]]) {
        return varialeValue?[NSString stringWithFormat:@"%@:NSString",varialeValue]:@"";
    }
    //BOOL类型
    else if ([[NSString stringWithFormat:@"%@",[varialeValue class]] isEqualToString:@"__NSCFBoolean"]) {
        return varialeValue?[NSString stringWithFormat:@"%@:NSNumberBOOL",varialeValue]:@"";
    }
    //NSSNumber类型
    else if ([varialeValue isKindOfClass:[NSNumber class]]) {
        
        NSString *memberValueType = @":NSNumber";
        
        if (strcmp([varialeValue objCType], @encode(char)) == 0 ||
            strcmp([varialeValue objCType], @encode(unsigned char)) == 0) {
            memberValueType = @":NSNumberChar";
        } else if (strcmp([varialeValue objCType], @encode(short)) == 0 ||
                   strcmp([varialeValue objCType], @encode(unsigned short)) == 0) {
            memberValueType = @":NSNumberShort";
        } else if (strcmp([varialeValue objCType], @encode(int)) == 0 ||
                   strcmp([varialeValue objCType], @encode(unsigned int)) == 0) {
            memberValueType = @":NSNumberInt";
        } else if (strcmp([varialeValue objCType], @encode(long)) == 0 ||
                   strcmp([varialeValue objCType], @encode(unsigned long)) == 0) {
            memberValueType = @":NSNumberLong";
        } else if (strcmp([varialeValue objCType], @encode(long long)) == 0 ||
                   strcmp([varialeValue objCType], @encode(unsigned long long)) == 0) {
            memberValueType = @":NSNumberLongLong";
        } else if (strcmp([varialeValue objCType], @encode(float)) == 0) {
            memberValueType = @":NSNumberFloat";
        } else if (strcmp([varialeValue objCType], @encode(double)) == 0) {
            memberValueType = @":NSNumberDouble";
        } else if (strcmp([varialeValue objCType], @encode(NSInteger)) == 0) {
            memberValueType = @":NSNumberNSInteger";
        } else if (strcmp([varialeValue objCType], @encode(NSUInteger)) == 0) {
            memberValueType = @":NSNumberNSUInteger";
        }
        
        return varialeValue?[NSString stringWithFormat:@"%@%@",varialeValue,memberValueType]:@"";
    }
    //UIView类型
    else if ([[varialeValue class] isSubclassOfClass:[UIView class]] || [[varialeValue class] isKindOfClass:[UIView class]]) {
        return varialeValue?[NSString stringWithFormat:@"%@:UIView",varialeValue]:@"";
    }
    
    return varialeValue?[NSString stringWithFormat:@"%@:id",varialeValue]:@"";
}

//根据存储的信息转为对应的变量类型
+ (id)getIDVariableValueTypesWithString:(NSString *)string
{
    NSString *idValueType = [[string componentsSeparatedByString:@":"] lastObject];
    NSString *idValue = [string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@":%@",idValueType] withString:@""];
    
    if ([idValueType isEqualToString:@"NSNumber"]) {
        return [NSNumber numberWithInteger:[idValue integerValue]];
    } else if ([idValueType isEqualToString:@"NSNumberChar"]) {
        return [NSNumber numberWithChar:[idValue intValue]];
    } else if ([idValueType isEqualToString:@"NSNumberFloat"]) {
        return [NSNumber numberWithFloat:[idValue floatValue]];
    } else if ([idValueType isEqualToString:@"NSNumberDouble"]) {
        return [NSNumber numberWithDouble:[idValue doubleValue]];
    } else if ([idValueType isEqualToString:@"NSNumberShort"]) {
        return [NSNumber numberWithShort:[idValue intValue]];
    } else if ([idValueType isEqualToString:@"NSNumberInt"]) {
        return [NSNumber numberWithInt:[idValue doubleValue]];
    } else if ([idValueType isEqualToString:@"NSNumberLong"]) {
        return [NSNumber numberWithLong:[idValue floatValue]];
    } else if ([idValueType isEqualToString:@"NSNumberLongLong"]) {
        return [NSNumber numberWithLongLong:[idValue longLongValue]];
    } else if ([idValueType isEqualToString:@"NSNumberNSInteger"]) {
        return [NSNumber numberWithInteger:[idValue integerValue]];
    } else if ([idValueType isEqualToString:@"NSNumberNSUInteger"]) {
        return [NSNumber numberWithUnsignedInteger:[idValue integerValue]];
    } else if ([idValueType isEqualToString:@"NSNumberBOOL"]) {
        return [NSNumber numberWithBool:[idValue boolValue]];
    } else if ([idValueType isEqualToString:@"UIView"]) {
        return NSClassFromString(idValue);
    } else if ([idValueType isEqualToString:@"NSString"]) {
        return idValue;
    }
    return @"";
}

@end
