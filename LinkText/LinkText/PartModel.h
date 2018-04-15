//
//  PartModel.h
//  LinkText
//
//  Created by lifangjian on 2018/4/13.
//  Copyright © 2018年 Steven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PartModel : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *tagLabel;
@property (nonatomic, strong) NSMutableDictionary *attributes;
@property (nonatomic, assign) NSInteger position;

@end
