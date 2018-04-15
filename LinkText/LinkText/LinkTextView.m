//
//  LinkTextView.m
//  LinkText
//
//  Created by lifangjian on 2018/4/14.
//  Copyright © 2018年 Steven. All rights reserved.
//

#import "LinkTextView.h"
#import "PartModel.h"
@interface LinkTextView ()
#define  kCoverViewTag 111

@property (nonatomic,strong)NSMutableArray *textPartModels;
@property (nonatomic,copy)NSString *linkText;
@property (nonatomic, strong)NSMutableArray *rectsArray;


@end
@implementation LinkTextView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setEditable:NO];
        [self setScrollEnabled:NO];
        
    }
    return self;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return NO;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return NO;
}
- (void)TT_setLinkText:(NSString *)text clickBlock:(ClickBlock)block
{
    self.clickBlock = block;
    [self extractTextStyle:text];
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:self.linkText];
    [content addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, self.linkText.length)];
    self.attributedText = content;
    NSMutableArray *selectedArray = [NSMutableArray array];
    for (int i = 0; i < self.textPartModels.count; i++) {
        PartModel *partModel = self.textPartModels[i];
        NSRange range = NSMakeRange(partModel.position, partModel.text.length);
        [content addAttribute:NSFontAttributeName value:self.font range:range];
        [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:range];
        [content addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
        
        // self.selectedRange  影响  self.selectedTextRange
        self.selectedRange = range;
        NSArray *selectionRects = [self selectionRectsForRange:self.selectedTextRange];
        self.selectedRange = NSMakeRange(0, 0);

        for (UITextSelectionRect *selectionRect in selectionRects) {
            CGRect rect = selectionRect.rect;
            if (rect.size.width == 0 || rect.size.height == 0) {
                continue;
            }
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:[NSValue valueWithCGRect:rect] forKey:@"rect"];
            [dic setObject:partModel forKey:@"partmodel"];
            [selectedArray addObject:dic];
        }
        [self.rectsArray addObject:selectedArray];

    
    }
    self.attributedText = content;

}
- (void)extractTextStyle:(NSString*)data{
    
    NSScanner *scanner = nil;
    NSString *text = nil;
    NSString *tag = nil;
    
    NSMutableArray *partModels = [NSMutableArray array];
    
    NSInteger last_position = 0;
    
    scanner = [NSScanner scannerWithString:data];
    while (![scanner isAtEnd]) {
        [scanner scanUpToString:@"<" intoString:NULL];
        [scanner scanUpToString:@">" intoString:&text];
        
        NSString *delimiter = [NSString stringWithFormat:@"%@>",text];
        NSUInteger position = [data rangeOfString:delimiter].location;
        
        //把link标签去掉
        if (position!=NSNotFound) {
            data = [data stringByReplacingOccurrencesOfString:delimiter withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(last_position, position + delimiter.length-last_position)];
        }
        if ([text rangeOfString:@"</"].location==0) {
            //结束标签 （</a>）
            tag = [text substringFromIndex:2];
            if (position != NSNotFound) {
                for (int i = (int)(partModels.count) - 1; i>=0; i--) {
                    //开始标签与结束标签之间的文本就是 链接文本
                    PartModel *partModel = partModels[i];
                    if (partModel.text == nil && [partModel.tagLabel isEqualToString:tag]) {
                        NSString *linkText = [data substringWithRange:NSMakeRange(partModel.position, position - partModel.position)];
                        partModel.text = linkText;
                        break;
                    }
                }
                
            }
        }
        else{
            //开始标签 (<a href='https://www.xxx.com/223?232323&2323'>)
            NSArray *textParts = [[text substringFromIndex:1] componentsSeparatedByString:@" "];
//            NSLog(@"%@",textParts);
            tag = [textParts objectAtIndex:0];//a
            NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
            
            for (int i = 1; i < textParts.count; i++) {
                NSArray *pair = [[textParts objectAtIndex:i] componentsSeparatedByString:@"="];
                if (pair.count >= 2) {//大于2相当于多个=
                    [attributes setObject:[[pair subarrayWithRange:NSMakeRange(1, pair.count - 1)] componentsJoinedByString:@"="] forKey:[pair objectAtIndex:0]];
                }
            }
            
            PartModel *partmodel = [[PartModel alloc] init];
            partmodel.text = nil;
            partmodel.tagLabel = tag;
            partmodel.attributes = attributes;
            partmodel.position = position;
            [partModels addObject:partmodel];
            
        }
        
        last_position = position;
        
    }
    self.textPartModels = partModels;
    self.linkText = data;
    
    
}

- (NSMutableArray *)rectsArray{
    if (!_rectsArray) {
        _rectsArray = [[NSMutableArray alloc] init];
        
    }
    return _rectsArray;
}
#pragma mark-点击
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    NSArray *selectedArray = [self touchingLinkTextWithPoint:point];
    PartModel *partModel;
    for (NSDictionary *dic in selectedArray) {
        if (dic) {
            partModel = dic[@"partmodel"];
            UIView *cover = [[UIView alloc] init];
            cover.backgroundColor = [UIColor colorWithRed:225/225 green:0 blue:0 alpha:0.1];
            cover.frame = [dic[@"rect"] CGRectValue];
            cover.tag = kCoverViewTag;
            [self insertSubview:cover atIndex:0];
        }
    }
    if (self.clickBlock && partModel) {
        self.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.userInteractionEnabled = YES;
            self.clickBlock(partModel);
            [self remove];
        });

    }
}
- (NSArray *)touchingLinkTextWithPoint:(CGPoint)point
{
    // 从所有的特殊的范围中找到点击的那个点
    for (NSArray *selecedArray in self.rectsArray) {
        for (NSDictionary *dic in selecedArray) {
            CGRect myRect = [dic[@"rect"] CGRectValue];
            if(CGRectContainsPoint(myRect, point) ){
                return selecedArray;
            }
        }
    }
    return nil;
}
/** 点击结束的时候 */
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self remove];

}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self remove];
}
- (void)remove{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (UIView *subView in self.subviews) {
            if (subView.tag == kCoverViewTag) {
                [subView removeFromSuperview];
            }
        }
    });
}
@end
