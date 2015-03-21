//
//  ViewController.m
//  BTKCollectionViewFlowLayout
//
//  Created by Tomohisa Ota on 2015/03/16.
//  Copyright (c) 2015 Tomohisa Ota. All rights reserved.
//

#import "ViewController.h"
#import "BTKCollectionViewFlowLayout.h"
#import "CommanderView.h"

@interface ViewController ()

@property(nonatomic,strong,readonly) BTKCollectionViewFlowLayout *collectionViewLayout;
@property(nonatomic,strong,readonly) UICollectionView *collectionView;


@property(nonatomic,strong,readonly) CommanderView *controlView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    _dataSource = DataSource.new;
    
    _controlView = CommanderView.newView;
    __weak typeof(self) wSelf = self;
    self.controlView.onValueUpdate = ^{
        [wSelf readViewSettings];
    };
    
    _collectionViewLayout = BTKCollectionViewFlowLayout.new;
    
    //_collectionViewLayout.shouldAlignToPointGrid = NO;
    _collectionView = [UICollectionView.alloc initWithFrame:self.view.bounds
                                       collectionViewLayout:self.collectionViewLayout];
    [self.dataSource prepareCollectionView:self.collectionView];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self.dataSource;
    [self.view addSubview:self.collectionView];
    [self.view addSubview:_controlView];
    [self readViewSettings];
}

- (void) readViewSettings
{
    self.collectionViewLayout.shouldStickHeaderViews = self.controlView.isStickyHeader;
    self.collectionViewLayout.shouldStickFooterViews = self.controlView.isStickyFooter;
    self.collectionViewLayout.scrollDirection = self.controlView.scrollDirection;
    self.collectionViewLayout.collectionElementKindSectionBody = self.controlView.hasBody ? self.dataSource.bodyViewKind : nil;
    self.collectionViewLayout.collectionElementKindSectionBackground = self.controlView.hasBackground ?self.dataSource.backgroundViewKind : nil;

    [self.collectionView reloadData];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    const CGFloat controlViewHeight = 130;
    CGRect b = self.view.bounds;
    self.collectionView.frame = UIEdgeInsetsInsetRect(b, UIEdgeInsetsMake(0, 0, controlViewHeight, 0));
    self.controlView.frame = UIEdgeInsetsInsetRect(b, UIEdgeInsetsMake(CGRectGetHeight(self.collectionView.frame), 0, 0, 0));
}

#pragma mark UICollectionViewDelegateFlowLayout

- (UIEdgeInsets) collectionView:(UICollectionView *)collectionView
                         layout:(UICollectionViewLayout *)collectionViewLayout
         insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (CGFloat) collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

- (CGSize) collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
   sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([self.dataSource typeForIndexPath:indexPath]) {
        case BTKViewControllerCellTypeFizz:
            return CGSizeMake(10, 20);
        case BTKViewControllerCellTypeBuzz:
            return CGSizeMake(50, 40);
        case BTKViewControllerCellTypeFizzBuzz:
            return CGSizeMake(10, 40);
        case BTKViewControllerCellTypeNum:
        default:
            return CGSizeMake(50, 20);
    }
}

- (CGSize) collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
   referenceSizeForHeaderInSection:(NSInteger)section
{
    return self.controlView.hasHeader ? CGSizeMake(30, 30) : CGSizeZero;
}

- (CGSize) collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section
{
    return self.controlView.hasFooter ? CGSizeMake(30, 30) : CGSizeZero;
}

#pragma mark BTKCollectionViewDelegateFlowLayout

- (UIControlContentHorizontalAlignment) collectionView:(UICollectionView *)collectionView
                                                layout:(UICollectionViewLayout *)collectionViewLayout
                         horizontalAlignmentForSection:(NSInteger)section
{
    return self.controlView.horizontalAlignment;
}

- (UIControlContentVerticalAlignment) collectionView:(UICollectionView *)collectionView
                                              layout:(UICollectionViewLayout *)collectionViewLayout
                         verticalAlignmentForSection:(NSInteger)section
{
    return self.controlView.verticalAlignment;
}

@end
