//
//  ViewController.m
//  BTKCollectionViewFlowLayout
//
//  Created by Tomohisa Ota on 2015/03/16.
//  Copyright (c) 2015 Tomohisa Ota. All rights reserved.
//

#import "ViewController.h"
#import "BTKCollectionViewFlowLayout.h"

@interface ViewController ()

@property(nonatomic,strong,readonly) BTKCollectionViewFlowLayout *collectionViewLayout;
@property(nonatomic,strong,readonly) UICollectionView *collectionView;


@property(nonatomic,strong,readonly) UIView *controlView;
@property(nonatomic,strong,readonly) UISegmentedControl *scrollDirectionControl;
@property(nonatomic,strong,readonly) UISegmentedControl *hAlignControl;
@property(nonatomic,strong,readonly) UISegmentedControl *vAlignControl;
@property(nonatomic,strong,readonly) UISwitch *stickyHeaderSwicth;
@property(nonatomic,strong,readonly) UISwitch *stickyFooterSwicth;

@end

@implementation ViewController

- (void)viewDidLoad
{
    _dataSource = DataSource.new;
    
    _controlView = UIView.new;
    _scrollDirectionControl = [UISegmentedControl.alloc initWithItems:@[@"Vertical",@"Horizontal"]];
    _scrollDirectionControl.selectedSegmentIndex = 0;

    _hAlignControl = [UISegmentedControl.alloc initWithItems:@[
        @"Fill",
        @"Left",
        @"Center",
        @"Right"]];
    _hAlignControl.selectedSegmentIndex = 0;

    _vAlignControl = [UISegmentedControl.alloc initWithItems:@[
        @"Fill",
        @"Top",
        @"Center",
        @"Bottom"]];
    _vAlignControl.selectedSegmentIndex = 0;
    
    for(UISegmentedControl *v in @[_scrollDirectionControl,_hAlignControl,_vAlignControl]){
        [v addTarget:self
              action:@selector(valueChanged:)
    forControlEvents:UIControlEventValueChanged];
    }

    _stickyHeaderSwicth = UISwitch.new;
    _stickyFooterSwicth = UISwitch.new;

    for(UISwitch *v in @[_stickyFooterSwicth,_stickyHeaderSwicth]){
        [v addTarget:self
              action:@selector(valueChanged:)
    forControlEvents:UIControlEventValueChanged];
    }
    
    _collectionViewLayout = BTKCollectionViewFlowLayout.new;
    _collectionViewLayout.collectionElementKindSectionBody = self.dataSource.bodyViewKind;
    _collectionViewLayout.collectionElementKindSectionBackground = self.dataSource.backgroundViewKind;
    
    //_collectionViewLayout.shouldAlignToPointGrid = NO;
    _collectionView = [UICollectionView.alloc initWithFrame:self.view.bounds
                                       collectionViewLayout:self.collectionViewLayout];
    //_collectionView.contentInset = UIEdgeInsetsMake(50, 50, 50, 50);
    [self.dataSource prepareCollectionView:self.collectionView];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self.dataSource;
    [self valueChanged:nil];
    

    [self.view addSubview:self.collectionView];
    [self.view addSubview:_controlView];
    [_controlView addSubview:_scrollDirectionControl];
    [_controlView addSubview:_hAlignControl];
    [_controlView addSubview:_vAlignControl];
    [_controlView addSubview:_stickyHeaderSwicth];
    [_controlView addSubview:_stickyFooterSwicth];
}
     
 - (void)valueChanged:(id)sender
{
    self.collectionViewLayout.scrollDirection = self.scrollDirection;
    self.collectionViewLayout.shouldStickHeaderViews = self.stickyHeaderSwicth.isOn;
    self.collectionViewLayout.shouldStickFooterViews = self.stickyFooterSwicth.isOn;
    [self.collectionView reloadData];
}

- (UICollectionViewScrollDirection) scrollDirection
{
    if(self.scrollDirectionControl.selectedSegmentIndex == 0){
        return UICollectionViewScrollDirectionVertical;
    }
    else{
        return UICollectionViewScrollDirectionHorizontal;
    }
}

- (UIControlContentHorizontalAlignment) horizontalAlignment
{
    switch (self.hAlignControl.selectedSegmentIndex) {
        case 1:
            return UIControlContentHorizontalAlignmentLeft;
        case 2:
            return UIControlContentHorizontalAlignmentCenter;
        case 3:
            return UIControlContentHorizontalAlignmentRight;
        case 0:
        default:
            return UIControlContentHorizontalAlignmentFill;
    }
}

- (UIControlContentVerticalAlignment) verticalAlignment
{
    switch (self.vAlignControl.selectedSegmentIndex) {
        case 1:
            return UIControlContentVerticalAlignmentTop;
        case 2:
            return UIControlContentVerticalAlignmentCenter;
        case 3:
            return UIControlContentVerticalAlignmentBottom;
        case 0:
        default:
            return UIControlContentVerticalAlignmentFill;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    const CGFloat controlViewHeight = 96;
    CGRect b = self.view.bounds;
    self.collectionView.frame = UIEdgeInsetsInsetRect(b, UIEdgeInsetsMake(0, 0, controlViewHeight, 0));
    self.controlView.frame = UIEdgeInsetsInsetRect(b, UIEdgeInsetsMake(CGRectGetHeight(self.collectionView.frame), 0, 0, 0));
    CGFloat x = (NSInteger)(CGRectGetWidth(self.controlView.bounds)/2) + CGRectGetWidth(self.stickyHeaderSwicth.frame)/2;
    self.scrollDirectionControl.center = CGPointMake(x, controlViewHeight * 1 / 6);
    self.hAlignControl.center          = CGPointMake(x, controlViewHeight * 3 / 6);
    self.vAlignControl.center          = CGPointMake(x, controlViewHeight * 5 / 6);
    
    x = self.stickyHeaderSwicth.center.x;
    self.stickyHeaderSwicth.center = CGPointMake(x, controlViewHeight * 1 / 4);
    self.stickyFooterSwicth.center = CGPointMake(x, controlViewHeight * 3 / 4);
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
    return CGSizeMake(30, 30);
}

- (CGSize) collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(30, 30);
}

#pragma mark BTKCollectionViewDelegateFlowLayout

- (UIControlContentHorizontalAlignment) collectionView:(UICollectionView *)collectionView
                                                layout:(UICollectionViewLayout *)collectionViewLayout
                         horizontalAlignmentForSection:(NSInteger)section
{
    return self.horizontalAlignment;
}

- (UIControlContentVerticalAlignment) collectionView:(UICollectionView *)collectionView
                                              layout:(UICollectionViewLayout *)collectionViewLayout
                         verticalAlignmentForSection:(NSInteger)section
{
    return self.verticalAlignment;
}

@end
