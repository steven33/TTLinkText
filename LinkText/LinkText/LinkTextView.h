//
//  LinkTextView.h
//  LinkText
//
//  Created by lifangjian on 2018/4/14.
//  Copyright © 2018年 Steven. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PartModel;
typedef void(^ClickBlock)(PartModel *partModel);
@interface LinkTextView : UITextView

@property (nonatomic,copy)ClickBlock clickBlock;

- (void)TT_setLinkText:(NSString *)text clickBlock:(ClickBlock)block;

@end
