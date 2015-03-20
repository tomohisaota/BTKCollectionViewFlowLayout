//
//  DataSource.h
//  BTKCollectionViewFlowLayout
//
//  Created by Tomohisa Ota on 2015/03/20.
//  Copyright (c) 2015年 Tomohisa Ota. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum BTKViewControllerCellType : NSUInteger {
    BTKViewControllerCellTypeNum, // Default
    BTKViewControllerCellTypeFizz,
    BTKViewControllerCellTypeBuzz,
    BTKViewControllerCellTypeFizzBuzz,
    BTKViewControllerCellTypeEnd
} BTKViewControllerCellType;

@interface DataSource : NSObject<UICollectionViewDataSource>

@property(nonatomic,strong,readonly) NSString *bodyViewKind;
@property(nonatomic,strong,readonly) NSString *backgroundViewKind;

- (void) prepareCollectionView:(UICollectionView*)collectionView;
- (BTKViewControllerCellType) typeForIndexPath : (NSIndexPath*)indexPath;

@end
