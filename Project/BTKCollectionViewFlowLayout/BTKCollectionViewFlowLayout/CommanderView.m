//
//  CommanderView.m
//  BTKCollectionViewFlowLayout
//
//  Created by Tomohisa Ota on 2015/03/20.
//  Copyright (c) 2015年 Tomohisa Ota. All rights reserved.
//

#import "CommanderView.h"

@interface CommanderView()

@property (nonatomic,weak,readwrite) IBOutlet UISwitch *stickyHeaderSwicth;
@property (nonatomic,weak,readwrite) IBOutlet UISwitch *stickyFooterSwicth;

@property (nonatomic,weak,readwrite) IBOutlet UISegmentedControl *scrollDirectionControl;
@property (nonatomic,weak,readwrite) IBOutlet UISegmentedControl *hAlignControl;
@property (nonatomic,weak,readwrite) IBOutlet UISegmentedControl *vAlignControl;

@end

@implementation CommanderView

+ (instancetype)newView
{
    NSString *className = NSStringFromClass([self class]);
    return [[[NSBundle mainBundle] loadNibNamed:className owner:nil options:0] firstObject];
}

- (void)awakeFromNib{
    for(UISwitch *v in @[self.stickyFooterSwicth,self.stickyHeaderSwicth]){
        [v addTarget:self
              action:@selector(valueChanged:)
    forControlEvents:UIControlEventValueChanged];
    }
    for(UISegmentedControl *v in @[self.scrollDirectionControl,self.hAlignControl,self.vAlignControl]){
        [v addTarget:self
              action:@selector(valueChanged:)
    forControlEvents:UIControlEventValueChanged];
    }
}

- (void)valueChanged:(id)sender
{
    if(self.onValueUpdate){
        self.onValueUpdate();
    }
}

- (BOOL)isStickyHeader
{
    return self.stickyHeaderSwicth.on;
}

- (void)setIsStickyHeader:(BOOL)isStickyHeader
{
    self.stickyHeaderSwicth.on = isStickyHeader;
}

- (BOOL)isStickyFooter
{
    return self.stickyFooterSwicth.on;
}

- (void)setIsStickyFooter:(BOOL)isStickyFooter
{
    self.stickyFooterSwicth.on = isStickyFooter;
}

- (UICollectionViewScrollDirection)scrollDirection
{
    if(self.scrollDirectionControl.selectedSegmentIndex == 0){
        return UICollectionViewScrollDirectionVertical;
    }
    else{
        return UICollectionViewScrollDirectionHorizontal;
    }
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    if(scrollDirection == UICollectionViewScrollDirectionVertical){
        self.scrollDirectionControl.selectedSegmentIndex = 0;
    }
    else{
        self.scrollDirectionControl.selectedSegmentIndex = 1;
    }
}

- (UIControlContentHorizontalAlignment) horizontalAlignment
{
    switch (self.hAlignControl.selectedSegmentIndex) {
        case 1:
            return UIControlContentHorizontalAlignmentLeft;
        case 2:
            return UIControlContentHorizontalAlignmentCenter;
        case 3:
            return UIControlContentHorizontalAlignmentRight;
        case 0:
        default:
            return UIControlContentHorizontalAlignmentFill;
    }
}

- (void)setHorizontalAlignment:(UIControlContentHorizontalAlignment)horizontalAlignment
{
    NSInteger index;
    switch (horizontalAlignment) {
        case UIControlContentHorizontalAlignmentLeft:
            index = 0;
            break;
        case UIControlContentHorizontalAlignmentCenter:
            index = 1;
            break;
        case UIControlContentHorizontalAlignmentRight:
            index = 2;
            break;
        case UIControlContentHorizontalAlignmentFill:
        default:
            index = 3;
            break;
    }
    self.hAlignControl.selectedSegmentIndex = index;
}

- (UIControlContentVerticalAlignment) verticalAlignment
{
    switch (self.vAlignControl.selectedSegmentIndex) {
        case 1:
            return UIControlContentVerticalAlignmentTop;
        case 2:
            return UIControlContentVerticalAlignmentCenter;
        case 3:
            return UIControlContentVerticalAlignmentBottom;
        case 0:
        default:
            return UIControlContentVerticalAlignmentFill;
    }
}


@end
