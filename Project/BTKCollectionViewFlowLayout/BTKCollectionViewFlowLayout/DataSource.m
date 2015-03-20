//
//  DataSource.m
//  BTKCollectionViewFlowLayout
//
//  Created by Tomohisa Ota on 2015/03/20.
//  Copyright (c) 2015年 Tomohisa Ota. All rights reserved.
//

#import "DataSource.h"
#import "BTKCollectionViewCell.h"

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
        [collectionView registerClass:[BTKCollectionViewCell class]
                forCellWithReuseIdentifier:[self reuseIdentifierForType:i]];
    }
    [collectionView registerClass:[UICollectionReusableView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
              withReuseIdentifier:@"Header"];
    [collectionView registerClass:[UICollectionReusableView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
              withReuseIdentifier:@"Footer"];
    [collectionView registerClass:[UICollectionReusableView class]
       forSupplementaryViewOfKind:self.bodyViewKind
              withReuseIdentifier:@"Body"];
    [collectionView registerClass:[UICollectionReusableView class]
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
    return 1000;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BTKViewControllerCellType type = [self typeForIndexPath:indexPath];
    BTKCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self reuseIdentifierForType:type]
                                                                            forIndexPath:indexPath];
    switch (type) {
        case BTKViewControllerCellTypeFizz:{
            UILabel *textLabel = (UILabel*)[cell viewWithTag:1];
            if(!textLabel){
                textLabel = [[UILabel alloc]init];
                textLabel.textAlignment = NSTextAlignmentCenter;
                textLabel.tag = 1;
                textLabel.backgroundColor = [UIColor whiteColor];
                textLabel.text = @"Fizz";
                textLabel.textColor = [UIColor blueColor];
                [cell addSubview:textLabel];
                [cell setNeedsLayout];
            }
            break;
        }
        case BTKViewControllerCellTypeBuzz:{
            UILabel *textLabel = (UILabel*)[cell viewWithTag:1];
            if(!textLabel){
                textLabel = [[UILabel alloc]init];
                textLabel.textAlignment = NSTextAlignmentCenter;
                textLabel.tag = 1;
                textLabel.backgroundColor = [UIColor whiteColor];
                textLabel.text = @"Buzz";
                textLabel.textColor = [UIColor redColor];
                [cell addSubview:textLabel];
                [cell setNeedsLayout];
            }
            break;
        }
        case BTKViewControllerCellTypeFizzBuzz:{
            // Fizz Buzz should be button
            UIButton *textButton = (UIButton*)[cell viewWithTag:1];
            if(!textButton){
                textButton = [UIButton buttonWithType:UIButtonTypeCustom];
                textButton.tag = 1;
                textButton.backgroundColor = [UIColor whiteColor];
                [textButton setTitle:@"Fizz Buzz" forState:UIControlStateNormal];
                [textButton setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
                [textButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
                [cell addSubview:textButton];
                [cell setNeedsLayout];
            }
            break;
        }
        case BTKViewControllerCellTypeNum:
        default:{
            UILabel *textLabel = (UILabel*)[cell viewWithTag:1];
            if(!textLabel){
                textLabel = [[UILabel alloc]init];
                textLabel.textAlignment = NSTextAlignmentCenter;
                textLabel.tag = 1;
                textLabel.backgroundColor = [UIColor whiteColor];
                textLabel.textColor = [UIColor blackColor];
                [cell addSubview:textLabel];
                [cell setNeedsLayout];
            }
            // Num should be updated
            textLabel.text = [NSString stringWithFormat:@"%zd",indexPath.item + 1];
            break;
        }
    }
    // view with tag 1 is the target view.
    // Resize target view to fill cell
    if(!cell.onLayoutSubview){
        cell.onLayoutSubview = ^(BTKCollectionViewCell *cell){
            UIView *view = [cell viewWithTag:1];
            view.frame = cell.bounds;
        };
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
        UICollectionReusableView *v = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                         withReuseIdentifier:@"Footer"
                                                                                forIndexPath:indexPath];
        v.layer.borderColor = [UIColor.yellowColor colorWithAlphaComponent:0.8].CGColor;
        v.layer.borderWidth = 5;
        return v;
    }
    else if([kind isEqualToString:UICollectionElementKindSectionHeader]){
        UICollectionReusableView *v = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                         withReuseIdentifier:@"Header"
                                                                                forIndexPath:indexPath];
        v.layer.borderColor = [UIColor.blueColor colorWithAlphaComponent:0.8].CGColor;
        v.layer.borderWidth = 5;
        return v;
    }
    else if([kind isEqualToString:self.bodyViewKind]){
        UICollectionReusableView *v = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                         withReuseIdentifier:@"Body"
                                                                                forIndexPath:indexPath];
        v.layer.borderColor = [UIColor.greenColor colorWithAlphaComponent:0.8].CGColor;
        v.layer.borderWidth = 5;
        return v;
    }
    else if([kind isEqualToString:self.backgroundViewKind]){
        UICollectionReusableView *v = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                         withReuseIdentifier:@"Background"
                                                                                forIndexPath:indexPath];
        v.layer.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.8].CGColor;
        return v;
    }
    // should not come here...
    return nil;
}

@end
