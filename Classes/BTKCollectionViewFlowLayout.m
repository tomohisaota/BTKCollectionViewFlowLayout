//
//  BTKCollectionViewFlowLayout.m
//  BTKCollectionViewFlowLayout
//
//  Created by Tomohisa Ota on 2015/03/16.
//  Copyright (c) 2015 Tomohisa Ota. All rights reserved.
//

#import "BTKCollectionViewFlowLayout.h"

@interface BTKCollectionViewFlowLayoutSectionInfo : NSObject

@property(nonatomic,assign,readwrite) CGRect headerRect;
@property(nonatomic,assign,readwrite) CGRect footerRect;
@property(nonatomic,assign,readonly) CGRect bodyRect;
@property(nonatomic,assign,readonly) CGRect backgroundRect;

@property(nonatomic,assign,readonly) BOOL hasHeader;
@property(nonatomic,assign,readonly) BOOL hasFooter;

@end

@implementation BTKCollectionViewFlowLayoutSectionInfo

- (CGRect)bodyRect
{
    CGRect r;
    if(self.headerRect.origin.x == self.footerRect.origin.x){
        r.origin.x = self.headerRect.origin.x;
        r.origin.y = CGRectGetMaxY(self.headerRect);
        r.size.width = CGRectGetWidth(self.headerRect);
        r.size.height = CGRectGetMinY(self.footerRect) - CGRectGetMaxY(self.headerRect);
    }
    else{
        r.origin.x = CGRectGetMaxX(self.headerRect);
        r.origin.y = self.headerRect.origin.y;
        r.size.width = CGRectGetMinX(self.footerRect) - CGRectGetMaxX(self.headerRect);
        r.size.height = CGRectGetHeight(self.headerRect);
    }
    return r;
}

- (CGRect)backgroundRect
{
    return CGRectUnion(self.headerRect, self.footerRect);
}

- (NSString*) debugDescription
{
    return [NSString stringWithFormat:@"header = %@ footer = %@ body = %@ background = %@",NSStringFromCGRect(self.headerRect),NSStringFromCGRect(self.footerRect),NSStringFromCGRect(self.bodyRect),NSStringFromCGRect(self.backgroundRect)];
}

- (BOOL)hasHeader
{
    return self.headerRect.size.width != 0 && self.headerRect.size.height != 0;
}

- (BOOL)hasFooter
{
    return self.footerRect.size.width != 0 && self.footerRect.size.height != 0;
}

@end


@interface BTKCollectionViewFlowLayout()

@property(nonatomic,strong,readonly) NSArray *infos;

@end

@implementation BTKCollectionViewFlowLayout

- (instancetype)init
{
    self = super.init;
    [self commonInit];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self commonInit];
    return self;
}

- (void) commonInit
{
    _infos = NSMutableArray.new;
    _horizontalAlignment = UIControlContentHorizontalAlignmentFill;
    _verticalAlignment = UIControlContentVerticalAlignmentFill;
    
    _zIndexForBody = 1;
    _zIndexForItem = 2;
    _zIndexForHeader = 3;
    _zIndexForFooter = 3;
    _zIndexForBackground = 0;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    NSInteger numOfSections = self.collectionView.numberOfSections;
    
    NSMutableArray *headers = NSMutableArray.new;
    NSMutableArray *footers = NSMutableArray.new;
    
    for(NSInteger s = 0 ; s < numOfSections ; s++){
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0
                                                     inSection:s];
        UICollectionViewLayoutAttributes *header = [super layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                         atIndexPath:indexPath];
        UICollectionViewLayoutAttributes *footer = [super layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                         atIndexPath:indexPath];
        if(header == nil){
            header = UICollectionViewLayoutAttributes.new;
        }
        [headers addObject:header];
        if(footer == nil){
            footer = UICollectionViewLayoutAttributes.new;
        }
        [footers addObject:footer];
    }
    
    NSMutableArray *infos = NSMutableArray.new;
    for(NSInteger s = 0 ; s < numOfSections ; s++){
        BTKCollectionViewFlowLayoutSectionInfo *info = BTKCollectionViewFlowLayoutSectionInfo.new;
        [infos addObject:info];
        
        UICollectionViewLayoutAttributes *header = headers[s];
        info.headerRect = header.frame;
        
        UICollectionViewLayoutAttributes *footer = footers[s];
        if(!CGSizeEqualToSize(footer.frame.size, CGSizeZero)){
            info.footerRect = footer.frame;
            continue;
        }
        
        CGFloat l;
        if(s == numOfSections - 1){
            __block CGRect contentRect = CGRectZero;
            [[self itemAttributesInSection:s] enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attr, NSUInteger i, BOOL *stop) {
                if(i==0){
                    contentRect = attr.frame;
                }
                else{
                    contentRect = CGRectUnion(contentRect, attr.frame);
                }
            }];
            
            UIEdgeInsets insets = [self sectionInsetForSection:s];
            contentRect = UIEdgeInsetsInsetRect(contentRect, UIEdgeInsetsMake(-insets.top, -insets.left, -insets.bottom, -insets.right));
            if(self.scrollDirection == UICollectionViewScrollDirectionVertical){
                l = CGRectGetHeight(contentRect);
            }
            else{
                l = CGRectGetWidth(contentRect);
            }
        }
        else{
            // Calculate footer frame from next header
            UICollectionViewLayoutAttributes *nextHeader = headers[s+1];
            if(self.scrollDirection == UICollectionViewScrollDirectionVertical){
                l = CGRectGetMinY(nextHeader.frame) - CGRectGetMaxY(header.frame);
            }
            else{
                l = CGRectGetMinY(nextHeader.frame) - CGRectGetMaxY(header.frame);
            }
        }
        CGFloat x,y;
        if(self.scrollDirection == UICollectionViewScrollDirectionVertical){
            x = CGRectGetMinX(header.frame);
            y = CGRectGetMaxY(header.frame) + l;
        }
        else{
            x = CGRectGetMaxX(header.frame) + l;
            y = CGRectGetMinY(header.frame);
        }
        info.footerRect = CGRectMake(x, y, 0, 0);
    }
    
    //Override header size
    UIEdgeInsets i = self.collectionView.contentInset;
    if(self.scrollDirection == UICollectionViewScrollDirectionVertical){
        CGFloat w = CGRectGetWidth(self.collectionView.frame) - i.left - i.right;
        for(NSInteger s = 0 ; s < numOfSections ; s++){
            BTKCollectionViewFlowLayoutSectionInfo *info = infos[s];
            CGRect r = info.headerRect;
            r.size.width = w;
            info.headerRect = r;
            
            r = info.footerRect;
            r.size.width = w;
            info.footerRect = r;
        }
    }
    else{
        CGFloat h = CGRectGetHeight(self.collectionView.frame) - i.top - i.bottom;
        for(NSInteger s = 0 ; s < numOfSections ; s++){
            BTKCollectionViewFlowLayoutSectionInfo *info = infos[s];
            CGRect r = info.headerRect;
            r.size.height = h;
            info.headerRect = r;
            
            r = info.footerRect;
            r.size.height = h;
            info.footerRect = r;
        }
    }
    _infos = infos.copy;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attrs = [super layoutAttributesForElementsInRect:rect].mutableCopy;
    [self removeIncorrectAttributes:attrs];
    [self updateAlighnmentOfLayoutAttributes:attrs];
    [self alignPointGridAlignmentOfLayoutAttributes:attrs];
    
    [self updateStickyViews:attrs];
    [self addAdditionalSupplimentalViews:attrs];
    [self updateZIndexes:attrs];
    
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
    BOOL sizeChanged;
    if(self.scrollDirection == UICollectionViewScrollDirectionVertical){
        sizeChanged = CGRectGetWidth(self.collectionView.bounds) != CGRectGetWidth(newBounds);
    }
    else{
        sizeChanged = CGRectGetHeight(self.collectionView.bounds) != CGRectGetHeight(newBounds);
    }
    if(sizeChanged){
        [self invalidateLayout];
    }
    shouldInvalidate |= sizeChanged;
    
    if(self.shouldStickHeaderViews || self.shouldStickFooterViews){
        if(!shouldInvalidate){
            // Partial Update only if shouldInvalidate is NO
            // Use Zero rect to create empty invalidation context from super class
            UICollectionViewLayoutInvalidationContext *context = [self invalidationContextForBoundsChange:CGRectZero];
            [self invalidateLayoutWithContext:context];
        }
    }

    return shouldInvalidate;
}

- (UICollectionViewLayoutInvalidationContext *)invalidationContextForBoundsChange:(CGRect)newBounds
{
    UICollectionViewLayoutInvalidationContext *context = [super invalidationContextForBoundsChange:newBounds];
    if(!self.shouldStickHeaderViews && !self.shouldStickFooterViews){
        return context;
    }
    if(![context respondsToSelector:@selector(invalidateSupplementaryElementsOfKind:atIndexPaths:)]){
        // invalidateSupplementaryElementsOfKind is not supported
        return context;
    }
    if(self.shouldStickHeaderViews){
        NSMutableArray *indexePaths = NSMutableArray.new;
        [self.infos enumerateObjectsUsingBlock:^(BTKCollectionViewFlowLayoutSectionInfo *info, NSUInteger s, BOOL *stop) {
            if(!info.hasHeader){
                return;
            }
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:s];
            [indexePaths addObject:indexPath];
        }];
        [context invalidateSupplementaryElementsOfKind:UICollectionElementKindSectionHeader
                                          atIndexPaths:indexePaths];
    }
    if(self.shouldStickFooterViews){
        NSMutableArray *indexePaths = NSMutableArray.new;
        [self.infos enumerateObjectsUsingBlock:^(BTKCollectionViewFlowLayoutSectionInfo *info, NSUInteger s, BOOL *stop) {
            if(!info.hasFooter){
                return;
            }
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:s];
            [indexePaths addObject:indexPath];
        }];
        [context invalidateSupplementaryElementsOfKind:UICollectionElementKindSectionFooter
                                          atIndexPaths:indexePaths];
    }
    return context;
}

#pragma mark Apple Bug workaround

- (void) removeIncorrectAttributes: (NSMutableArray*) attrs
{
    // Apple bug workaround
    // http://stackoverflow.com/questions/12927027/uicollectionview-flowlayout-not-wrapping-cells-correctly-ios
    for (UICollectionViewLayoutAttributes *attr in attrs.copy) {
        if (attr.representedElementCategory != UICollectionElementCategoryCell) {
            continue;
        }
        if(self.scrollDirection == UICollectionViewScrollDirectionVertical){
            if (CGRectGetMaxX(attr.frame) <= self.collectionViewContentSize.width) {
                continue;
            }
        }
        else{
            if (CGRectGetMaxY(attr.frame) <= self.collectionViewContentSize.height) {
                continue;
            }
        }
        [attrs removeObject:attr];
    }
}


#pragma mark zIndex

- (void) updateZIndexes: (NSArray*) attrs
{
    for (UICollectionViewLayoutAttributes *attr in attrs) {
        [self updateZIndex:attr];
    }
}

- (void) updateZIndex: (UICollectionViewLayoutAttributes*) attr
{
    if (attr.representedElementCategory == UICollectionElementCategoryCell) {
        attr.zIndex = self.zIndexForItem;
    }
    else if (attr.representedElementKind == UICollectionElementKindSectionHeader) {
        attr.zIndex = self.zIndexForHeader;
    }
    else if (attr.representedElementKind == UICollectionElementKindSectionFooter) {
        attr.zIndex = self.zIndexForFooter;
    }
    else if ([attr.representedElementKind isEqualToString:self.collectionElementKindSectionBody]) {
        attr.zIndex = self.zIndexForBody;
    }
    else if ([attr.representedElementKind isEqualToString:self.collectionElementKindSectionBackground]) {
        attr.zIndex = self.zIndexForBackground;
    }
}

#pragma mark Sticky Headers

- (void) addMissingHeaderAndFooterViews: (NSMutableArray*) attrs
{
    if(!self.shouldStickHeaderViews && !self.shouldStickFooterViews){
        return;
    }
    
    NSIndexSet *sectionsItemExists = [self sectionsItemExists:attrs];
    NSIndexSet *sectionsHeaderExists = [self sectionsHeaderExists:attrs];
    NSIndexSet *sectionsFooterExists = [self sectionsFooterExists:attrs];
    
    NSMutableIndexSet *headerMissingSections = sectionsItemExists.mutableCopy;
    NSMutableIndexSet *footerMissingSections = sectionsItemExists.mutableCopy;
    [headerMissingSections removeIndexes:sectionsHeaderExists];
    [footerMissingSections removeIndexes:sectionsFooterExists];
    
    // Add missing headers only if sticky header is enabled
    if(self.shouldStickHeaderViews){
        [headerMissingSections enumerateIndexesUsingBlock:^(NSUInteger s, BOOL *stop) {
            BTKCollectionViewFlowLayoutSectionInfo *info = self.infos[s];
            if(!info.hasHeader){
                return;
            }
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:s];
            UICollectionViewLayoutAttributes *attr = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                          atIndexPath:indexPath];
            if(attr){
                [attrs addObject:attr];
            }
        }];
    }
    
    // Add missing footers only if sticky footer is enabled
    if(self.shouldStickFooterViews){
        [footerMissingSections enumerateIndexesUsingBlock:^(NSUInteger s, BOOL *stop) {
            BTKCollectionViewFlowLayoutSectionInfo *info = self.infos[s];
            if(!info.hasFooter){
                return;
            }
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:s];
            UICollectionViewLayoutAttributes *attr = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                          atIndexPath:indexPath];
            if(attr){
                [attrs addObject:attr];
            }
        }];
    }
}

- (void) updateStickyViews : (NSMutableArray*) attrs
{
    if(!self.shouldStickHeaderViews && !self.shouldStickFooterViews){
        return;
    }
    for (UICollectionViewLayoutAttributes *attr in attrs) {
        [self updateStickyView:attr];
    }
    [self addMissingHeaderAndFooterViews:attrs];
}

- (void) updateStickyView : (UICollectionViewLayoutAttributes*) attr
{
    BOOL shouldProcess = NO;
    shouldProcess |= (attr.representedElementKind == UICollectionElementKindSectionHeader) && self.shouldStickHeaderViews;
    shouldProcess |= (attr.representedElementKind == UICollectionElementKindSectionFooter) && self.shouldStickFooterViews;
    if(!shouldProcess){
        return;
    }
    
    CGPoint contentOffset = self.collectionView.contentOffset;
    NSInteger s = attr.indexPath.section;
    
    BTKCollectionViewFlowLayoutSectionInfo *info = self.infos[s];
    CGRect r = info.bodyRect;
    CGRect f = attr.frame;
    CGFloat w = CGRectGetWidth(f);
    CGFloat h = CGRectGetHeight(f);
    if (attr.representedElementKind == UICollectionElementKindSectionHeader) {
        if(self.scrollDirection == UICollectionViewScrollDirectionVertical){
            CGFloat topOfView = contentOffset.y + self.collectionView.contentInset.top;
            CGFloat relativeToFirst = CGRectGetMinY(r) - h;
            CGFloat relativeToLast = CGRectGetMaxY(r) - h;
            f.origin.y = MIN(MAX(topOfView,relativeToFirst),relativeToLast);
        }
        else{
            CGFloat leftOfView = contentOffset.x + self.collectionView.contentInset.left;
            CGFloat relativeToFirst = CGRectGetMinX(r) - w;
            CGFloat relativeToLast = CGRectGetMaxX(r) - w;
            f.origin.x = MIN(MAX(leftOfView,relativeToFirst),relativeToLast);
        }
    }
    else{
        if(self.scrollDirection == UICollectionViewScrollDirectionVertical){
            CGFloat bottomOfView = contentOffset.y + self.collectionView.frame.size.height - h - self.collectionView.contentInset.bottom;
            CGFloat relativeToFirst = CGRectGetMinY(r);
            CGFloat relativeToLast = CGRectGetMaxY(r);
            f.origin.y = MIN(MAX(bottomOfView,relativeToFirst),relativeToLast);
        }
        else{
            CGFloat rightOfView = contentOffset.x + self.collectionView.frame.size.width - w - self.collectionView.contentInset.right;
            CGFloat relativeToFirst = CGRectGetMinX(r);
            CGFloat relativeToLast = CGRectGetMaxX(r);
            f.origin.x = MIN(MAX(rightOfView,relativeToFirst),relativeToLast);
        }
    }
    attr.frame = f;
}

#pragma mark Alignment

- (void) updateAlighnmentOfLayoutAttributes : (NSArray*) attrs
{
    if(self.scrollDirection == UICollectionViewScrollDirectionVertical){
        [self updateHorizontalAlighnmentOfLayoutAttributes:attrs];
    }
    else{
        [self updateVerticalAlighnmentOfLayoutAttributes:attrs];
    }
}

- (void) updateVerticalAlighnmentOfLayoutAttributes : (NSArray *) attrs
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
    
    UIEdgeInsets contentInset = self.collectionView.contentInset;
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
        CGFloat totalMargin = CGRectGetHeight(self.collectionView.bounds) - totalHeight - contentInset.top - contentInset.bottom;
        
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

- (void) updateHorizontalAlighnmentOfLayoutAttributes : (NSArray *) attrs
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
    
    UIEdgeInsets contentInset = self.collectionView.contentInset;
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
        CGFloat totalMargin = CGRectGetWidth(self.collectionView.bounds) - totalWidth - contentInset.left - contentInset.right;
        
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

#pragma mark Point align

- (void) alignPointGridAlignmentOfLayoutAttributes : (NSArray*) attrs
{
    if(!self.shouldAlignToPointGrid){
        return;
    }
    
    for (UICollectionViewLayoutAttributes *attr in attrs) {
        if (attr.representedElementCategory != UICollectionElementCategoryCell) {
            continue;
        }
        // Align to point grid
        CGRect f = attr.frame;
        f.origin = CGPointMake(floorf(f.origin.x), floorf(f.origin.y));
        attr.frame = f;
    }
}

#pragma mark Section Background

- (void) addAdditionalSupplimentalViews : (NSMutableArray*) attrs
{
    if(self.collectionElementKindSectionBody == nil && self.collectionElementKindSectionBackground == nil){
        return;
    }
    
    NSMutableIndexSet *sectionsElementExists = [NSMutableIndexSet indexSet];
    
    for (UICollectionViewLayoutAttributes *attr in attrs) {
        NSUInteger s = (NSUInteger)attr.indexPath.section;
        [sectionsElementExists addIndex:s];
    }
    [sectionsElementExists enumerateIndexesUsingBlock:^(NSUInteger s, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:s];
        if(self.collectionElementKindSectionBody){
            [attrs addObject:[self layoutAttributesForSupplementaryViewOfKind:self.collectionElementKindSectionBody
                                                                  atIndexPath:indexPath]];
        }
        if(self.collectionElementKindSectionBackground){
            [attrs addObject:[self layoutAttributesForSupplementaryViewOfKind:self.collectionElementKindSectionBackground
                                                                  atIndexPath:indexPath]];
        }
    }];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind
                                                                     atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attr;
    if(![elementKind isEqualToString:self.collectionElementKindSectionBody] &&
       ![elementKind isEqualToString:self.collectionElementKindSectionBackground]){
        attr = [super layoutAttributesForSupplementaryViewOfKind:elementKind
                                                     atIndexPath:indexPath];
        [self updateStickyView:attr];
    }
    else{
        attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind
                                                                              withIndexPath:indexPath];
        BTKCollectionViewFlowLayoutSectionInfo *info = self.infos[indexPath.section];
        if([elementKind isEqualToString:self.collectionElementKindSectionBody]){
            attr.frame = info.bodyRect;
        }
        else{
            attr.frame = info.backgroundRect;
        }
    }
    [self updateZIndex:attr];
    return attr;
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

#pragma mark Utils

- (NSIndexSet*) sectionsElementExists: (NSArray*) attrs
{
    NSMutableIndexSet *sections = [NSMutableIndexSet indexSet];
    
    for (UICollectionViewLayoutAttributes *attr in attrs) {
        NSInteger s = attr.indexPath.section;
        if (attr.representedElementCategory == UICollectionElementCategoryCell) {
            [sections addIndex:s];
        }
    }
    return sections.copy;
}


- (NSIndexSet*) sectionsItemExists: (NSArray*) attrs
{
    return [self sectionsElementExists:attrs
                              category:UICollectionElementCategoryCell
                                  kind:nil];
}

- (NSIndexSet*) sectionsHeaderExists: (NSArray*) attrs
{
    return [self sectionsElementExists:attrs
                              category:UICollectionElementCategorySupplementaryView
                                  kind:UICollectionElementKindSectionHeader];
}

- (NSIndexSet*) sectionsFooterExists: (NSArray*) attrs
{
    return [self sectionsElementExists:attrs
                              category:UICollectionElementCategorySupplementaryView
                                  kind:UICollectionElementKindSectionFooter];
}

- (NSIndexSet*) sectionsElementExists:(NSArray*)attrs
                             category:(UICollectionElementCategory)category
                                 kind:(NSString*)kind
{
    NSMutableIndexSet *sections = [NSMutableIndexSet indexSet];
    
    for (UICollectionViewLayoutAttributes *attr in attrs) {
        if(category != attr.representedElementCategory){
            continue;
        }
        if((kind != nil) && (![kind isEqualToString:attr.representedElementKind])){
            continue;
        }
        NSInteger s = attr.indexPath.section;
        if (attr.representedElementCategory == UICollectionElementCategoryCell) {
            [sections addIndex:s];
        }
    }
    return sections.copy;
}

- (NSArray*) itemAttributesInSection : (NSInteger)s
{
    NSMutableArray *attrs = NSMutableArray.new;
    NSInteger numOfItems = [self.collectionView numberOfItemsInSection:s];
    for(NSInteger i = 0 ; i < numOfItems ; i++){
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i
                                                     inSection:s];
        UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:indexPath];
        [attrs addObject:attr];
    }
    return attrs;
}


@end
