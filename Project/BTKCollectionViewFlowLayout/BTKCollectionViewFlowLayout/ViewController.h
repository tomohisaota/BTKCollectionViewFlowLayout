//
//  ViewController.h
//  BTKCollectionViewFlowLayout
//
//  Created by Tomohisa Ota on 2015/03/16.
//  Copyright (c) 2015 Tomohisa Ota. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTKCollectionViewDelegateFlowLayout.h"
#import "DataSource.h"

@interface ViewController : UIViewController<BTKCollectionViewDelegateFlowLayout>

@property(nonatomic,strong,readonly) DataSource *dataSource;

@end

