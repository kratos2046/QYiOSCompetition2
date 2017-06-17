//
//  RecommentCollectionViewCellDataModel.m
//  PlayDemo
//
//  Created by 肖杰 on 2017/6/16.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "RecommentCollectionViewCellDataModel.h"

@interface RecommentCollectionViewCellDataModel ()


@end

@implementation RecommentCollectionViewCellDataModel
- (instancetype) initWithDict:(ZPVideoInfo *)info {
    if (self = [super init]) {
        _imgUrl = info.img;
        _text = info.shortTitle;
    }
    return self;
}
@end
