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
    const CGFloat margin = 5;
    if(self.isVertical){
        self.label.transform = CGAffineTransformMakeRotation(- M_PI / 2);
        self.label.frame = CGRectMake(5, margin , 15 , CGRectGetHeight(self.bounds) - margin * 2);
    }
    else{
        self.label.transform = CGAffineTransformIdentity;
        self.label.frame = CGRectMake(margin, 5, CGRectGetWidth(self.bounds) - margin * 2, 15);
    }
}

- (void)setIsVertical:(BOOL)isVertical
{
    _isVertical = isVertical;
    [self setNeedsLayout];
}

@end
