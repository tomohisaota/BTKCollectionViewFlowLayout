//
//  ViewController.m
//  BTKCollectionViewFlowLayout
//
//  Created by Tomohisa Ota on 2015/03/16.
//  Copyright (c) 2015年 Tomohisa Ota. All rights reserved.
//

#import "ViewController.h"
#import "BTKCollectionViewFlowLayout.h"

#import "BTKCollectionViewCell.h"

typedef enum BTKViewControllerCellType : NSUInteger {
    BTKViewControllerCellTypeNum, // Default
    BTKViewControllerCellTypeFizz,
    BTKViewControllerCellTypeBuzz,
    BTKViewControllerCellTypeFizzBuzz,
    BTKViewControllerCellTypeEnd
} BTKViewControllerCellType;

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
    _collectionView = [UICollectionView.alloc initWithFrame:self.view.bounds
                                       collectionViewLayout:self.collectionViewLayout];
    _collectionView.contentInset = UIEdgeInsetsMake(50, 50, 50, 50);
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self valueChanged:nil];
    
    // Register cell for each type
    for(int i = 0 ; i < BTKViewControllerCellTypeEnd ; i++){
        [self.collectionView registerClass:[BTKCollectionViewCell class]
                forCellWithReuseIdentifier:[self reuseIdentifierForType:i]];
    }
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:@"Header"];
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:@"Footer"];

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

- (NSString*) reuseIdentifierForType : (BTKViewControllerCellType) type
{
    return [NSString stringWithFormat:@"Cell%zd",type];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 12;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView
      numberOfItemsInSection:(NSInteger)section
{
    return 20;
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

#pragma mark UICollectionViewDelegateFlowLayout

- (UICollectionReusableView*) collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if([kind isEqualToString:UICollectionElementKindSectionFooter]){
        UICollectionReusableView *v = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                         withReuseIdentifier:@"Footer"
                                                                                forIndexPath:indexPath];
        v.backgroundColor = [UIColor yellowColor];
        return v;
    }
    else{
        UICollectionReusableView *v = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                         withReuseIdentifier:@"Header"
                                                                                forIndexPath:indexPath];
        v.backgroundColor = [UIColor blueColor];
        return v;
    }
}

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
    switch ([self typeForIndexPath:indexPath]) {
        case BTKViewControllerCellTypeFizz:
            return CGSizeMake(100, 20);
        case BTKViewControllerCellTypeBuzz:
            return CGSizeMake(50, 40);
        case BTKViewControllerCellTypeFizzBuzz:
            return CGSizeMake(100, 40);
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
