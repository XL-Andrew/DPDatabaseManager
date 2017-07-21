//
//  DemoModel.h
//  DPDatabaseManager
//
//  Created by Andrew on 2017/7/20.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DemoModel : NSObject <NSCoding>

@property (nonatomic, copy) NSString *userName;

@property (nonatomic, assign) NSUInteger userAge;

@property (nonatomic, assign) BOOL isAdult;

@end
