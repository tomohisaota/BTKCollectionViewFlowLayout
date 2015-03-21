//
//  DataSource.m
//  BTKCollectionViewFlowLayout
//
//  Created by Tomohisa Ota on 2015/03/20.
//  Copyright (c) 2015年 Tomohisa Ota. All rights reserved.
//

#import "DataSource.h"
#import "CollectionViewCell.h"
#import "CollectionReusableView.h"

@implementation DataSource

- (instancetype)init
{
    self = super.init;
    if(self == nil){
        return nil;
    }
    _bodyViewKind =  @"BodyKind";
    _backgroundViewKind = @"BackgroundKind";
    return self;
}

- (void) prepareCollectionView:(UICollectionView*)collectionView
{
    // Register cell for each type
    for(int i = 0 ; i < BTKViewControllerCellTypeEnd ; i++){
        [collectionView registerClass:[CollectionViewCell class]
                forCellWithReuseIdentifier:[self reuseIdentifierForType:i]];
    }
    [collectionView registerClass:[CollectionReusableView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
              withReuseIdentifier:@"Header"];
    [collectionView registerClass:[CollectionReusableView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
              withReuseIdentifier:@"Footer"];
    [collectionView registerClass:[CollectionReusableView class]
       forSupplementaryViewOfKind:self.bodyViewKind
              withReuseIdentifier:@"Body"];
    [collectionView registerClass:[CollectionReusableView class]
       forSupplementaryViewOfKind:self.backgroundViewKind
              withReuseIdentifier:@"Background"];
}

- (NSString*) reuseIdentifierForType : (BTKViewControllerCellType) type
{
    return [NSString stringWithFormat:@"Cell%zd",type];
}

- (BTKViewControllerCellType) typeForIndexPath : (NSIndexPath*)indexPath
{
    NSInteger count = indexPath.item + 1;
    BOOL fizz = count % 3 == 0;
    BOOL buzz = count % 5 == 0;
    if(fizz && buzz){
        return BTKViewControllerCellTypeFizzBuzz;
    }
    else if(fizz){
        return BTKViewControllerCellTypeFizz;
    }
    else if(buzz){
        return BTKViewControllerCellTypeBuzz;
    }
    else{
        return BTKViewControllerCellTypeNum;
    }
}

#pragma mark UICollectionViewDataSource

- (NSInteger) collectionView:(UICollectionView *)collectionView
      numberOfItemsInSection:(NSInteger)section
{
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BTKViewControllerCellType type = [self typeForIndexPath:indexPath];
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self reuseIdentifierForType:type]
                                                                            forIndexPath:indexPath];
    switch (type) {
        case BTKViewControllerCellTypeFizz:{
            cell.label.text = @"Fizz";
            break;
        }
        case BTKViewControllerCellTypeBuzz:{
            cell.label.text = @"Buzz";
            break;
        }
        case BTKViewControllerCellTypeFizzBuzz:{
            // Fizz Buzz should be button
            cell.label.text = @"Fizz Buzz";
            break;
        }
        case BTKViewControllerCellTypeNum:
        default:{
            cell.label.text = [NSString stringWithFormat:@"%zd",indexPath.item + 1];
            break;
        }
    }
    return cell;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 12;
}

- (UICollectionReusableView*) collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if([kind isEqualToString:UICollectionElementKindSectionFooter]){
        CollectionReusableView *v = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                       withReuseIdentifier:@"Footer"
                                                                              forIndexPath:indexPath];
        v.layer.borderColor = UIColor.redColor.CGColor;
        v.layer.borderWidth = 2;
        v.label.text = [NSString stringWithFormat:@"Footer %zd",indexPath.section];
        v.label.textColor = UIColor.redColor;
        return v;
    }
    else if([kind isEqualToString:UICollectionElementKindSectionHeader]){
        CollectionReusableView *v = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                       withReuseIdentifier:@"Header"
                                                                              forIndexPath:indexPath];
        v.layer.borderColor = UIColor.blueColor.CGColor;
        v.layer.borderWidth = 2;
        v.label.text = [NSString stringWithFormat:@"Header %zd",indexPath.section];
        v.label.textColor = UIColor.blueColor;
        return v;
    }
    else if([kind isEqualToString:self.bodyViewKind]){
        CollectionReusableView *v = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                       withReuseIdentifier:@"Body"
                                                                              forIndexPath:indexPath];
        v.layer.borderColor = UIColor.greenColor.CGColor;
        v.layer.borderWidth = 2;
        v.label.text = [NSString stringWithFormat:@"Body %zd",indexPath.section];
        v.label.textColor = UIColor.greenColor;
        v.label.textAlignment = NSTextAlignmentCenter;
        return v;
    }
    else if([kind isEqualToString:self.backgroundViewKind]){
        CollectionReusableView *v = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                       withReuseIdentifier:@"Background"
                                                                              forIndexPath:indexPath];
        if(indexPath.section % 2 == 0){
            v.layer.backgroundColor = UIColor.lightGrayColor.CGColor;
        }
        else{
            v.layer.backgroundColor = UIColor.grayColor.CGColor;
        }
        v.label.text = [NSString stringWithFormat:@"Background %zd",indexPath.section];
        v.label.textColor = UIColor.whiteColor;
        v.label.textAlignment = NSTextAlignmentRight;
        return v;
    }
    // should not come here...
    return nil;
}

@end
