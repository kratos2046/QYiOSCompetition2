//
//  CollectionReusableFooterView.m
//  PlayDemo
//
//  Created by 肖杰 on 2017/6/17.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "CollectionReusableFooterView.h"

@implementation CollectionReusableFooterView
- (instancetype)init {
    return [[CollectionReusableFooterView alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _btn= [[UIButton alloc] init];
        [self addSubview:_btn];
    }
    return self;
}

-(void)layoutSubviews {
    _btn.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [_btn setTitle:@"获取更多视频.." forState:UIControlStateNormal];
    [_btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnClick:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(CollectionReusableFooterViewBtnClick:)]) {
        [self.delegate CollectionReusableFooterViewBtnClick:btn];
    }
}

@end
