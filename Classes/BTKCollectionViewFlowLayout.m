//
//  BTKCollectionViewFlowLayout.m
//  BTKCollectionViewFlowLayout
//
//  Created by Tomohisa Ota on 2015/03/16.
//  Copyright (c) 2015年 Tomohisa Ota. All rights reserved.
//

#import "BTKCollectionViewFlowLayout.h"

@implementation BTKCollectionViewFlowLayout

- (instancetype)init
{
    self = super.init;
    if(self){
        _horizontalAlignment = UIControlContentHorizontalAlignmentFill;
        _verticalAlignment = UIControlContentVerticalAlignmentCenter;
    }
    return self;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attrs = [super layoutAttributesForElementsInRect:rect].mutableCopy;
    if(self.scrollDirection == UICollectionViewScrollDirectionVertical){
        [self updateHorizontalAlighnmentOfLayoutAttributes:attrs];
    }
    else{
        [self updateVerticalAlighnmentOfLayoutAttributes:attrs];
    }
    if(self.shouldStickHeaderViews || self.shouldStickFooterViews){
        [self updateStickyViews:attrs];
    }
    return attrs.copy;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    return nil;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    return nil;
}

- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    BOOL shouldInvalidate = [super shouldInvalidateLayoutForBoundsChange:newBounds];
    
    shouldInvalidate |= self.shouldStickHeaderViews || self.shouldStickFooterViews;
    
    BOOL invalidate;
    if(self.scrollDirection == UICollectionViewScrollDirectionVertical){
        invalidate = CGRectGetWidth(self.collectionView.bounds) != CGRectGetWidth(newBounds);
    }
    else{
        invalidate = CGRectGetHeight(self.collectionView.bounds) != CGRectGetHeight(newBounds);
    }
    if(invalidate){
        [self invalidateLayout];
    }
    return shouldInvalidate || invalidate;
}

#pragma mark Alignment

- (void) addMissingHeaderAndFooterViews: (NSMutableArray*) attrs
{
    NSMutableIndexSet *sectionsItemExists = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *sectionsHeaderExists = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *sectionsFooterExists = [NSMutableIndexSet indexSet];
    
    for (UICollectionViewLayoutAttributes *attr in attrs) {
        NSInteger s = attr.indexPath.section;
        if (attr.representedElementCategory == UICollectionElementCategoryCell) {
            [sectionsItemExists addIndex:s];
        }
        else if (attr.representedElementKind == UICollectionElementKindSectionHeader) {
            [sectionsHeaderExists addIndex:s];
        }
        else if (attr.representedElementKind == UICollectionElementKindSectionFooter) {
            [sectionsFooterExists addIndex:s];
        }
    }
    
    NSMutableIndexSet *headerMissingSections = sectionsItemExists.mutableCopy;
    NSMutableIndexSet *footerMissingSections = sectionsItemExists.mutableCopy;
    [headerMissingSections removeIndexes:sectionsHeaderExists];
    [footerMissingSections removeIndexes:sectionsFooterExists];
    
    // Add missing headers only if sticky header is enabled
    if(self.shouldStickHeaderViews){
        [headerMissingSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
            UICollectionViewLayoutAttributes *attr = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                          atIndexPath:indexPath];
            [attrs addObject:attr];
        }];
    }

    // Add missing footers only if sticky footer is enabled
    if(self.shouldStickFooterViews){
        [footerMissingSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
            UICollectionViewLayoutAttributes *attr = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                          atIndexPath:indexPath];
            [attrs addObject:attr];
        }];
    }
}

- (void) updateStickyViews : (NSMutableArray*) attrs
{
    [self addMissingHeaderAndFooterViews:attrs];
    
    CGPoint contentOffset = self.collectionView.contentOffset;
    for (UICollectionViewLayoutAttributes *attr in attrs) {
        if((attr.representedElementKind != UICollectionElementKindSectionHeader) &&
            attr.representedElementKind != UICollectionElementKindSectionFooter){
            continue;
        }
        NSInteger s = attr.indexPath.section;
        NSInteger numOfItems = [self.collectionView numberOfItemsInSection:s];
        if(numOfItems == 0){
            continue;
        }
        UIEdgeInsets insets = [self sectionInsetForSection:s];
        
        // Calculate Content Rect for the section
        CGRect contentRect = CGRectZero;
        for(NSInteger i = 0 ; i < numOfItems ; i++){
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i
                                                         inSection:s];
            UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:indexPath];
            if(i==0){
                contentRect = attr.frame;
            }
            else{
                contentRect = CGRectUnion(contentRect, attr.frame);
            }
        }
        contentRect = UIEdgeInsetsInsetRect(contentRect, UIEdgeInsetsMake(-insets.top, -insets.left, -insets.bottom, -insets.right));
        
        CGRect f = attr.frame;
        
        CGFloat width = CGRectGetWidth(attr.frame);
        CGFloat height = CGRectGetHeight(attr.frame);
        if (attr.representedElementKind == UICollectionElementKindSectionHeader) {
            if(self.shouldStickHeaderViews){
                if(self.scrollDirection == UICollectionViewScrollDirectionVertical){
                    CGFloat topOfView = contentOffset.y + self.collectionView.contentInset.top;
                    CGFloat relativeToFirst = CGRectGetMinY(contentRect) - height;
                    CGFloat relativeToLast = CGRectGetMaxY(contentRect) - height  + 1;
                    f.origin.y = MIN(MAX(topOfView,relativeToFirst),relativeToLast);
                }
                else{
                    CGFloat leftOfView = contentOffset.x + self.collectionView.contentInset.left;
                    CGFloat relativeToFirst = CGRectGetMinX(contentRect) - width;
                    CGFloat relativeToLast = CGRectGetMaxX(contentRect) - width + 1;
                    f.origin.x = MIN(MAX(leftOfView,relativeToFirst),relativeToLast);
                }
            }
        }
        else{
            if(self.shouldStickFooterViews){
                if(self.scrollDirection == UICollectionViewScrollDirectionVertical){
                    CGFloat bottomOfView = contentOffset.y + self.collectionView.frame.size.height - height - self.collectionView.contentInset.bottom;
                    CGFloat relativeToFirst = CGRectGetMinY(contentRect);
                    CGFloat relativeToLast = CGRectGetMaxY(contentRect) + 1;
                    f.origin.y = MIN(MAX(bottomOfView,relativeToFirst),relativeToLast);
                }
                else{
                    CGFloat rightOfView = contentOffset.x + self.collectionView.frame.size.width - width - self.collectionView.contentInset.right;
                    CGFloat relativeToFirst = CGRectGetMinX(contentRect);
                    CGFloat relativeToLast = CGRectGetMaxX(contentRect) + 1;
                    f.origin.x = MIN(MAX(rightOfView,relativeToFirst),relativeToLast);
                }
            }
        }
        attr.zIndex = 1024;
        attr.frame = f;
    }
}

- (void) updateVerticalAlighnmentOfLayoutAttributes : (NSMutableArray*) attrs
{
    // Collect item layout per mid y
    NSMutableDictionary *rowCollections = NSMutableDictionary.new;
    for (UICollectionViewLayoutAttributes *attr in attrs)
    {
        // Process items only
        if (attr.representedElementKind != nil) {
            continue;
        }
        NSNumber *xCenter = @(CGRectGetMidX(attr.frame));
        if (!rowCollections[xCenter]){
            rowCollections[xCenter] = NSMutableArray.new;
        }
        [rowCollections[xCenter] addObject:attr];
    }
    
    for(NSArray *attrs in rowCollections.allValues){
        UICollectionViewLayoutAttributes *firstAttr = attrs.firstObject;
        NSInteger s = firstAttr.indexPath.section;
        CGFloat itemSpace = [self interitemSpacingForSection:s];
        UIEdgeInsets i = [self sectionInsetForSection:s];
        
        CGFloat minX = CGFLOAT_MAX;
        CGFloat maxX = CGFLOAT_MIN;
        CGFloat totalItemHeight = 0;
        for (UICollectionViewLayoutAttributes *attr in attrs){
            minX = MIN(minX,CGRectGetMinX(attr.frame));
            maxX = MAX(maxX,CGRectGetMaxX(attr.frame));
            totalItemHeight += CGRectGetHeight(attr.frame);
        }
        
        CGFloat totalHeight = totalItemHeight + itemSpace * (attrs.count -1);
        CGFloat totalMargin = CGRectGetHeight(self.collectionView.bounds) - totalHeight;
        
        UIControlContentVerticalAlignment vAlign = [self verticalAlignmentForSection:s];
        UIControlContentHorizontalAlignment hAlign = [self horizontalAlignmentForSection:s];
        CGFloat y = 0;
        if(vAlign == UIControlContentVerticalAlignmentCenter){
            y = (NSInteger)(i.top + (totalMargin-i.top-i.bottom) / 2.f);
        }
        else if(vAlign == UIControlContentVerticalAlignmentTop){
            y = i.top;
        }
        else if(vAlign == UIControlContentVerticalAlignmentBottom){
            y = (NSInteger)(i.top + (totalMargin -i.top - i.bottom));
        }
        for (UICollectionViewLayoutAttributes *attr in attrs){
            CGRect f = attr.frame;
            // update vertical alignment
            if(vAlign != UIControlContentVerticalAlignmentFill){
                f.origin.y = y;
                y += CGRectGetHeight(f) + itemSpace;
            }
            // update horizontal alignment
            if(hAlign == UIControlContentHorizontalAlignmentLeft){
                f.origin.x = minX;
            }
            else if(hAlign == UIControlContentHorizontalAlignmentRight){
                f.origin.x = maxX - f.size.width;
            }
            attr.frame = f;
        }
    };
}

- (void) updateHorizontalAlighnmentOfLayoutAttributes : (NSMutableArray*) attrs
{
    // Collect item layout per mid y
    NSMutableDictionary *rowCollections = NSMutableDictionary.new;
    for (UICollectionViewLayoutAttributes *attr in attrs)
    {
        // Process items only
        if (attr.representedElementKind != nil) {
            continue;
        }
        NSNumber *yCenter = @(CGRectGetMidY(attr.frame));
        if (!rowCollections[yCenter]){
            rowCollections[yCenter] = NSMutableArray.new;
        }
        [rowCollections[yCenter] addObject:attr];
    }
    
    for(NSArray *attrs in rowCollections.allValues){
        UICollectionViewLayoutAttributes *firstAttr = attrs.firstObject;
        NSInteger s = firstAttr.indexPath.section;
        CGFloat itemSpace = [self interitemSpacingForSection:s];
        UIEdgeInsets i = [self sectionInsetForSection:s];
        
        CGFloat minY = CGFLOAT_MAX;
        CGFloat maxY = CGFLOAT_MIN;
        CGFloat totalItemWidth = 0;
        for (UICollectionViewLayoutAttributes *attr in attrs){
            minY = MIN(minY,CGRectGetMinY(attr.frame));
            maxY = MAX(maxY,CGRectGetMaxY(attr.frame));
            totalItemWidth += CGRectGetWidth(attr.frame);
        }
        
        CGFloat totalWidth = totalItemWidth + itemSpace * (attrs.count -1);
        CGFloat totalMargin = CGRectGetWidth(self.collectionView.bounds) - totalWidth;
        
        UIControlContentVerticalAlignment vAlign = [self verticalAlignmentForSection:s];
        UIControlContentHorizontalAlignment hAlign = [self horizontalAlignmentForSection:s];
        CGFloat x = 0;
        if(hAlign == UIControlContentHorizontalAlignmentCenter){
            x = (NSInteger)(i.left + (totalMargin-i.left-i.right) / 2.f);
        }
        else if(hAlign == UIControlContentHorizontalAlignmentLeft){
            x = i.left;
        }
        else if(hAlign == UIControlContentHorizontalAlignmentRight){
            x = (NSInteger)(i.left + (totalMargin -i.left - i.right));
        }
        for (UICollectionViewLayoutAttributes *attr in attrs){
            CGRect f = attr.frame;
            // update horizontal alignment
            if(hAlign != UIControlContentHorizontalAlignmentFill){
                f.origin.x = x;
                x += CGRectGetWidth(f) + itemSpace;
            }
            // update vertical alignment
            if(vAlign == UIControlContentVerticalAlignmentTop){
                f.origin.y = minY;
            }
            else if(vAlign == UIControlContentVerticalAlignmentBottom){
                f.origin.y = maxY - f.size.height;
            }
            attr.frame = f;
        }
    };
}

#pragma mark Access Delegate

- (CGFloat) interitemSpacingForSection:(NSInteger)section
{
    id<UICollectionViewDelegateFlowLayout> delegate = (id)self.collectionView.delegate;
    if(![delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]){
        return self.minimumInteritemSpacing;
    }
    return [delegate collectionView:self.collectionView
                             layout:self
minimumInteritemSpacingForSectionAtIndex:section];
}

- (UIEdgeInsets) sectionInsetForSection:(NSInteger)section
{
    id<UICollectionViewDelegateFlowLayout> delegate = (id)self.collectionView.delegate;
    if(![delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]){
        return self.sectionInset;
    }
    return [delegate collectionView:self.collectionView
                             layout:self
             insetForSectionAtIndex:section];
}

- (UIControlContentHorizontalAlignment) horizontalAlignmentForSection:(NSInteger)section
{
    id<BTKCollectionViewDelegateFlowLayout> delegate = (id)self.collectionView.delegate;
    if(![delegate respondsToSelector:@selector(collectionView:layout:horizontalAlignmentForSection:)]){
        return self.horizontalAlignment;
    }
    return [delegate collectionView:self.collectionView
                             layout:self
      horizontalAlignmentForSection:section];
}

- (UIControlContentVerticalAlignment)verticalAlignmentForSection:(NSInteger)section
{
    id<BTKCollectionViewDelegateFlowLayout> delegate = (id)self.collectionView.delegate;
    if(![delegate respondsToSelector:@selector(collectionView:layout:verticalAlignmentForSection:)]){
        return self.verticalAlignment;
    }
    return [delegate collectionView:self.collectionView
                             layout:self
        verticalAlignmentForSection:section];
}

@end
