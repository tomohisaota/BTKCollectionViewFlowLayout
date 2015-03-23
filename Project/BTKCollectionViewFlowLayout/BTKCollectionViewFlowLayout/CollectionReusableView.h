//
//  CollectionReusableView.h
//  BTKCollectionViewFlowLayout
//
//  Created by Tomohisa Ota on 2015/03/22.
//  Copyright (c) 2015年 Tomohisa Ota. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionReusableView : UICollectionReusableView

@property(nonatomic,assign,readwrite) BOOL isVertical;
@property(nonatomic,strong,readonly) UILabel *label;

@end
