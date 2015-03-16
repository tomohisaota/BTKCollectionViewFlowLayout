//
//  BTKCollectionViewCell.h
//  BTKCollectionViewSample
//
//  Created by Tomohisa Ota on 2014/02/21.
//  Copyright (c) 2014年 Tomohisa Ota. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTKCollectionViewCell : UICollectionViewCell

@property(copy) void (^onLayoutSubview)(BTKCollectionViewCell *cell);

@end
