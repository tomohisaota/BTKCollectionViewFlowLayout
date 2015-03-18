//
//  BTKCollectionViewFlowLayout.h
//  BTKCollectionViewFlowLayout
//
//  Created by Tomohisa Ota on 2015/03/16.
//  Copyright (c) 2015 Tomohisa Ota. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTKCollectionViewDelegateFlowLayout.h"

@interface BTKCollectionViewFlowLayout : UICollectionViewFlowLayout

/** Element Kind for Body Supplimental View*/
@property(nonatomic,copy,readwrite) NSString *collectionElementKindSectionBody;

/** Align items to point grid. Useful for non retina device */
@property(nonatomic,assign,readwrite) BOOL shouldAlignToPointGrid;

/** Sticky Header Views */
@property(nonatomic,assign,readwrite) BOOL shouldStickHeaderViews;

/** Sticky Footer Views */
@property(nonatomic,assign,readwrite) BOOL shouldStickFooterViews;

/** Default Horizontal Alignment , use delegate for per-section control*/
@property(nonatomic,assign,readwrite) UIControlContentHorizontalAlignment horizontalAlignment;

/** Default Vertical Alignment , use delegate for per-section control*/
@property(nonatomic,assign,readwrite) UIControlContentVerticalAlignment verticalAlignment;

/** zIndex for Item Cells */
@property(nonatomic,assign,readwrite) NSInteger zIndexForItem;

/** zIndex for Header Views */
@property(nonatomic,assign,readwrite) NSInteger zIndexForHeader;

/** zIndex for Footer Views */
@property(nonatomic,assign,readwrite) NSInteger zIndexForFooter;

/** zIndex for Body Views */
@property(nonatomic,assign,readwrite) NSInteger zIndexForBody;

@end
