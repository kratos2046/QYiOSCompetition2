//
//  RecommentCollectionViewCell.m
//  PlayDemo
//
//  Created by 肖杰 on 2017/6/16.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "RecommentCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"

@interface RecommentCollectionViewCell (){
    CGFloat width;
    CGFloat height;
}

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *text;

@end

@implementation RecommentCollectionViewCell

- (instancetype)init {
    return [[RecommentCollectionViewCell alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imgView = [[UIImageView alloc] init];
        _text = [[UILabel alloc] init];
        [self addSubview:_imgView];
        [self addSubview:_text];
    }
    return self;
}

- (void)setDataModel:(RecommentCollectionViewCellDataModel *)dataModel {
   [ _imgView setImageWithURL:[NSURL URLWithString:dataModel.imgUrl]];
    _text.text = dataModel.text;
}

- (void)layoutSubviews {
    width = self.bounds.size.width;
    height = self.bounds.size.height;
    _imgView.frame =CGRectMake(0, 0, width, height-20);
    _text.frame = CGRectMake(0, height-20, width, 20);
    _text.font = [UIFont systemFontOfSize:10];
}


@end
