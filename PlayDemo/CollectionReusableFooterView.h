//
//  CollectionReusableFooterView.h
//  PlayDemo
//
//  Created by 肖杰 on 2017/6/17.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CollectionReusableFooterViewDelegate <NSObject>

- (void)CollectionReusableFooterViewBtnClick:(UIButton *)btn;

@end

@interface CollectionReusableFooterView : UICollectionReusableView
@property (nonatomic, strong)UIButton *btn;
@property (nonatomic, weak)id<CollectionReusableFooterViewDelegate> delegate;
@end
