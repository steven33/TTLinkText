//
//  ViewController.m
//  LinkText
//
//  Created by lifangjian on 2018/4/13.
//  Copyright © 2018年 Steven. All rights reserved.
//

#import "ViewController.h"
#import "LinkTextView.h"
#import "PartModel.h"
#import "TTFeedbackViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *text = @"欢迎使用探探, 在使用过程中有疑问请<a href=”tantanapp://feedback”>反馈</a>";
    
    
    LinkTextView *linkText = [[LinkTextView alloc] initWithFrame:CGRectMake(0, 10, 300, 300)];
    linkText.font = [UIFont systemFontOfSize:20];
    __weak typeof(self) weakself = self;
    [linkText TT_setLinkText:text clickBlock:^(PartModel *partModel) {
        NSLog(@"%@",partModel.text);
        TTFeedbackViewController *ttBackVC = [TTFeedbackViewController new];
        ttBackVC.title = partModel.attributes[@"href"];
        [weakself.navigationController pushViewController:ttBackVC animated:YES];
        
    }];
    [self.view addSubview:linkText];
    
    
}

@end
