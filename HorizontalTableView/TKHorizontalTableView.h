


//
//  HorizontalTableView.h
//  
//
//  Created by luobin on 12-38.
//  Copyright (c) __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface TKHorizontalTableViewCell : UIView

@property (nonatomic,getter=isSelected) BOOL selected; 
@property (nonatomic,getter=isHighlighted) BOOL highlighted;

- (void)prepareForReuse;

@end

@class TKHorizontalTableView;
@class TKHorizontalTableViewCell;

@protocol TKHorizontalTableViewDataSource <NSObject>

- (NSInteger)numberOfRowsInTableView:(TKHorizontalTableView *)tableView;
- (TKHorizontalTableViewCell *)tableView:(TKHorizontalTableView *)tableView cellAtIndex:(NSUInteger)index;

@end


@protocol TKHorizontalTableViewDelegate<UIScrollViewDelegate>

@optional
// Variable width support
- (CGFloat)tableView:(TKHorizontalTableView *)tableView widthForCellAtIndex:(NSUInteger)index;
- (CGFloat)widthForHeaderInTableView:(TKHorizontalTableView *)tableView;
- (CGFloat)widthForFooterInTableView:(TKHorizontalTableView *)tableView;

// Called before the user changes the selection.
- (void)tableView:(TKHorizontalTableView *)tableView willSelectCellAtIndex:(NSUInteger)index;
- (void)tableView:(TKHorizontalTableView *)tableView willDeselectCellAtIndex:(NSUInteger)index;
// Called after the user changes the selection.
- (void)tableView:(TKHorizontalTableView *)tableView didSelectCellAtIndex:(NSUInteger)index;
- (void)tableView:(TKHorizontalTableView *)tableView didDeselectCellAtIndex:(NSUInteger)index;


- (void)tableView:(TKHorizontalTableView *)tableView willDisplayCell:(TKHorizontalTableViewCell *)cell forColumnAtIndex:(NSUInteger)index;
- (void)tableView:(TKHorizontalTableView *)tableView willDisplayHeaderView:(UIView *)view;
- (void)tableView:(TKHorizontalTableView *)tableView willDisplayFooterView:(UIView *)view;
- (void)tableView:(TKHorizontalTableView *)tableView didEndDisplayingCell:(TKHorizontalTableViewCell *)cell forColumnAtIndex:(NSUInteger)index;
- (void)tableView:(TKHorizontalTableView *)tableView didEndDisplayingHeaderView:(UIView *)view;
- (void)tableView:(TKHorizontalTableView *)tableView didEndDisplayingFooterView:(UIView *)view;

@end


@interface TKHorizontalTableView : UIScrollView

@property (nonatomic, assign) IBOutlet id <TKHorizontalTableViewDataSource> dataSource;
@property (nonatomic, assign) IBOutlet id <TKHorizontalTableViewDelegate> delegate;
@property (nonatomic, readonly) NSUInteger numberOfCells;
@property (nonatomic, readonly) NSArray *visibleCells;
@property (nonatomic, strong) UIView *headerView;                 //default is nil
@property (nonatomic, strong) UIView *footerView;                 //default is nil

- (TKHorizontalTableViewCell *)cellForIndex:(NSInteger)index;
- (TKHorizontalTableViewCell *)dequeueReusableCell;
- (NSInteger)indexForCellAtPoint:(CGPoint)point;
- (NSInteger)indexForCell:(TKHorizontalTableViewCell *)cell;

- (void)selectCellAtIndex:(NSInteger)row;
- (void)deselectCell;
- (void)reloadData;

@end




