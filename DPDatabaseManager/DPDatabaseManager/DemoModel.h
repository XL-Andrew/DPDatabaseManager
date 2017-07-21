//
//  DemoModel.h
//  DPDatabaseManager
//
//  Created by Andrew on 2017/7/20.
//  Copyright © 2017年 Andrew. All rights reserved.
//

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
