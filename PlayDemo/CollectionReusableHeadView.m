//
//  CollectionReusableHeadView.m
//  PlayDemo
//
//  Created by 肖杰 on 2017/6/17.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "CollectionReusableHeadView.h"

@implementation CollectionReusableHeadView
- (instancetype)init {
    return [[CollectionReusableHeadView alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _lable = [[UILabel alloc] init];
        [self addSubview:_lable];
    }
    return self;
}

-(void)layoutSubviews {
    _lable.frame = CGRectMake(0, 0, self.bounds.size.width/2, self.bounds.size.height);
    _lable.font = [UIFont systemFontOfSize:14];
}

@end
