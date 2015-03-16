//
//  BTKCollectionViewCell.m
//  BTKCollectionViewSample
//
//  Created by Tomohisa Ota on 2014/02/21.
//  Copyright (c) 2014年 Tomohisa Ota. All rights reserved.
//

#import "BTKCollectionViewCell.h"

@implementation BTKCollectionViewCell

- (void)layoutSubviews{
    [super layoutSubviews];
    if(self.onLayoutSubview){
        self.onLayoutSubview(self);
    }
}

@end
