//
//  BTKCollectionViewDelegateFlowLayout.h
//  BTKCollectionViewFlowLayout
//
//  Created by Tomohisa Ota on 2015/03/16.
//  Copyright (c) 2015 Tomohisa Ota. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BTKCollectionViewDelegateFlowLayout <UICollectionViewDelegateFlowLayout>

@optional

/** Horizontal Alignment for each section*/
- (UIControlContentHorizontalAlignment)collectionView:(UICollectionView *)collectionView
                                               layout:(UICollectionViewLayout*)collectionViewLayout
                        horizontalAlignmentForSection:(NSInteger)section;

/** Vertical Alignment for each section*/
- (UIControlContentVerticalAlignment)collectionView:(UICollectionView *)collectionView
                                             layout:(UICollectionViewLayout*)collectionViewLayout
                        verticalAlignmentForSection:(NSInteger)section;

@end
