//
//  CollectionReusableView.m
//  BTKCollectionViewFlowLayout
//
//  Created by Tomohisa Ota on 2015/03/22.
//  Copyright (c) 2015年 Tomohisa Ota. All rights reserved.
//

#import "CollectionReusableView.h"

@implementation CollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self == nil){
        return nil;
    }
    _label = UILabel.new;
    _label.font = [UIFont boldSystemFontOfSize:10];
    [self addSubview:_label];
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    const CGFloat sideMargin = 5;
    self.label.frame = CGRectMake(sideMargin, 5, CGRectGetWidth(self.frame) - sideMargin * 2, 15);
}

@end
