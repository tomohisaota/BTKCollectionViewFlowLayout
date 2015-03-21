//
//  BTKCollectionViewCell.m
//  BTKCollectionViewSample
//
//  Created by Tomohisa Ota on 2014/02/21.
//  Copyright (c) 2014 Tomohisa Ota. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self == nil){
        return nil;
    }
    self.layer.borderColor = UIColor.blackColor.CGColor;
    self.layer.borderWidth = 1;
    
    _label = UILabel.new;
    _label.font = [UIFont boldSystemFontOfSize:10];
    
    _label.textAlignment = NSTextAlignmentCenter;
    _label.textColor = [UIColor blackColor];
    _label.backgroundColor = [UIColor whiteColor];

    [self.contentView addSubview:_label];
    self.contentView.alpha = 0.7;
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.label.frame = self.bounds;
}

@end
