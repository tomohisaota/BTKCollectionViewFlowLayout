//
//  CommanderView.h
//  BTKCollectionViewFlowLayout
//
//  Created by Tomohisa Ota on 2015/03/20.
//  Copyright (c) 2015年 Tomohisa Ota. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommanderView : UIView

+ (instancetype)newView;

@property (nonatomic,assign,readwrite) BOOL isStickyHeader;
@property (nonatomic,assign,readwrite) BOOL isStickyFooter;

@property (nonatomic,assign,readwrite) UICollectionViewScrollDirection scrollDirection;
@property (nonatomic,assign,readwrite) UIControlContentHorizontalAlignment horizontalAlignment;
@property (nonatomic,assign,readwrite) UIControlContentVerticalAlignment verticalAlignment;

@property (nonatomic,copy,readwrite) void (^onValueUpdate)();

@end
