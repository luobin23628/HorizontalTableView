

//
//  HorizontalTableView.m
//  
//  
//  Created by luobin on 12-38.
//  Copyright (c) __MyCompanyName__. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "TKHorizontalTableView.h"

#define kTKCellDefaultWidth 320

@interface TKHorizontalTableViewCell ()

@property (nonatomic, assign) NSUInteger index;

@end

@implementation TKHorizontalTableViewCell
@synthesize selected;
@synthesize highlighted;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, 100, 100)];
    return self;
}

- (void)prepareForReuse {
    
}

@end

@interface TKHorizontalTableView ()

@property (nonatomic, readwrite, retain) UIView *containerView;
@property (nonatomic, readwrite, retain) NSMutableSet *reusableCells;
@property (nonatomic, readwrite, retain) NSMutableArray *widths;
@property (nonatomic, readwrite, assign) CGFloat widthForHeader;
@property (nonatomic, readwrite, assign) CGFloat widthForFooter;

@property (nonatomic, readwrite, retain) NSMutableSet *visibleCellIndexes;

@property (nonatomic, readwrite) NSInteger highlightedIndex;
@property (nonatomic, readwrite) NSInteger selectedIndex;

- (void)initData;

@end

@implementation TKHorizontalTableView
@synthesize containerView;
@synthesize dataSource;
@synthesize numberOfCells;
@synthesize delegate;
@synthesize headerView;
@synthesize footerView;
@synthesize highlightedIndex;
@synthesize selectedIndex;

#pragma mark - initalizer and dealloc
- (void)initData
{
    self.autoresizesSubviews = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
	self.showsHorizontalScrollIndicator = YES;
	self.showsVerticalScrollIndicator = NO;
    self.alwaysBounceVertical = NO;
    
    if (self.reusableCells == nil) {
        self.reusableCells = [NSMutableSet set];
    }
    if (self.widths == nil) {
        self.widths = [NSMutableArray array];
    }
    
    if (self.visibleCellIndexes == nil) {
        self.visibleCellIndexes  = [NSMutableSet set];
    }
    
    self.selectedIndex = NSNotFound;
    self.highlightedIndex = NSNotFound;
    
    if (self.containerView == nil) {
        UIView *anContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        [anContainerView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:anContainerView];
        self.containerView = anContainerView;
    }
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self initData];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
    }
    return self;
}

- (void)dealloc {
    self.headerView = nil;
    self.footerView = nil;
    self.widths = nil;
    self.reusableCells = nil;
    self.containerView = nil;
    self.visibleCellIndexes = nil;
}

#pragma mark - touch event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    NSInteger indexForRow = [self indexForCellAtPoint:touchPoint];
    if (indexForRow != NSNotFound) {
        [self highlightCellAtIndex:indexForRow];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
//    [self unhighlightCell];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self unhighlightCell];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self unhighlightCell];
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    NSInteger indexForRow = [self indexForCellAtPoint:touchPoint];
    if (indexForRow != NSNotFound) {
        [self selectCellAtIndex:indexForRow];
    }
}

#pragma mark - override super class
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview) {
        [self reloadData];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect visibleBounds = CGRectMake(self.contentOffset.x, 0, self.bounds.size.width, self.bounds.size.height);
    
    // 重用不可见的cell
    for (TKHorizontalTableViewCell *cell in self.visibleCells) {
        
        if (! CGRectIntersectsRect(cell.frame, visibleBounds)) {
            cell.highlighted = NO;
            cell.selected = NO;
            [self.reusableCells addObject:cell];
            [cell removeFromSuperview];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forColumnAtIndex:)]) {
                [self.delegate tableView:self didEndDisplayingCell:cell forColumnAtIndex:cell.index];
            }
        }
    }
    
    CGFloat height = self.bounds.size.height - self.contentInset.top - self.contentInset.bottom;
    CGFloat totalWidth = 0;
    NSMutableSet *theVisibleCellIndexes = [NSMutableSet set];
    
    //循环cell，计算出新增的cell
    for (NSUInteger row = 0; row < numberOfCells; row++) {
        double width = [[self.widths objectAtIndex:row] doubleValue];
        CGRect rect = CGRectMake(self.widthForHeader + totalWidth, 0, width, height);
        
        if (CGRectIntersectsRect(visibleBounds, rect)) {
            [theVisibleCellIndexes addObject:[NSNumber numberWithUnsignedInteger:row]];
            
            BOOL cellIsMissing = ![self.visibleCellIndexes containsObject:[NSNumber numberWithUnsignedInteger:row]];
            if (cellIsMissing) {
                TKHorizontalTableViewCell *cell = [dataSource tableView:self cellAtIndex:row];
                NSAssert(cell != nil, @"Cell must not be nil.");
                cell.index = row;
                cell.highlighted = (self.highlightedIndex == row);
                cell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
                cell.selected = (self.selectedIndex == row);
                cell.frame = rect;
                if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:willDisplayCell:forColumnAtIndex:)]) {
                    [self.delegate tableView:self willDisplayCell:cell forColumnAtIndex:row];
                }
                [containerView addSubview:cell];
            }
        }
        totalWidth += width;
    }
    self.visibleCellIndexes = theVisibleCellIndexes;

    self.headerView.frame = CGRectMake(0, 0, self.widthForHeader, height);
    
    CGRect rect = self.headerView.frame;
    if (self.headerView
        && self.headerView.superview != containerView
        && CGRectIntersectsRect(visibleBounds, rect)) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:willDisplayHeaderView:)]) {
            [self.delegate tableView:self willDisplayHeaderView:self];
        }
        [containerView addSubview:self.headerView];
    } else if (self.headerView
               &&self.headerView.superview == containerView
               && !CGRectIntersectsRect(visibleBounds, rect)) {
        [self.headerView removeFromSuperview];
        if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:didEndDisplayingHeaderView:)]) {
            [self.delegate tableView:self didEndDisplayingHeaderView:self];
        }
    }
    
    self.footerView.frame = CGRectMake(self.widthForHeader + totalWidth, 0, self.widthForFooter, height);
    rect = self.footerView.frame;
    if (self.footerView
        && self.footerView.superview != containerView
        && CGRectIntersectsRect(visibleBounds, rect)) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:willDisplayFooterView:)]) {
            [self.delegate tableView:self willDisplayFooterView:self];
        }
        [containerView addSubview:self.footerView];
    } else if (self.footerView
               && self.footerView.superview == containerView
               && !CGRectIntersectsRect(visibleBounds, rect)) {
        [self.footerView removeFromSuperview];
        if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:didEndDisplayingFooterView:)]) {
            [self.delegate tableView:self didEndDisplayingFooterView:self];
        }
    }
    
    CGRect contentRect = CGRectMake(0, 0, self.headerView.frame.size.width + totalWidth + self.footerView.frame.size.width, height);
    containerView.frame = contentRect;
    
    self.contentSize = CGSizeMake(self.headerView.frame.size.width + totalWidth + self.footerView.frame.size.width, height);
}

#pragma mark - overrid super method setDelegate
- (void)setDelegate:(id<TKHorizontalTableViewDelegate>)theDelegate
{
    [super setDelegate:theDelegate];
    delegate = theDelegate;
}

#pragma mark - public method
- (TKHorizontalTableViewCell *)cellForIndex:(NSInteger)index
{
    for (UIView *subview in containerView.subviews) {
        if ([subview isKindOfClass:TKHorizontalTableViewCell.class]) {
            TKHorizontalTableViewCell *horizontalTableViewCell = (TKHorizontalTableViewCell *)subview;
            if (horizontalTableViewCell.index == index) {
                return horizontalTableViewCell;
            }
        }
    }
    return nil;
}

- (TKHorizontalTableViewCell *)dequeueReusableCell {
    TKHorizontalTableViewCell *cell = [self.reusableCells anyObject];
    if (cell) {
//        [[cell retain] autorelease];
        [self.reusableCells removeObject:cell];
        [cell prepareForReuse];
    }
    return cell;
}

- (NSInteger)indexForCellAtPoint:(CGPoint)point {
    if (0 < point.x < self.bounds.size.width && 0 < point.y < self.bounds.size.height) {
        CGFloat width = self.widthForHeader;
        for (NSUInteger row = 0; row < numberOfCells; row++) {
            width += [[self.widths objectAtIndex:row] doubleValue];
            if (width >= point.x) {
                return row;
            }
        }
    }
    return NSNotFound;
}

- (NSInteger)indexForCell:(TKHorizontalTableViewCell *)cell {
    if (cell.superview == containerView) {
        return cell.index;
    }
    return NSNotFound;
}

- (void)selectCellAtIndex:(NSInteger)row {
   if (0 <= row && row < numberOfCells) {
       if ( row != self.selectedIndex) {
           [self deselectCell];
       }
       
       if ([self.delegate respondsToSelector:@selector(tableView:willSelectCellAtIndex:)]) {
           [self.delegate tableView:self willSelectCellAtIndex:row];
       }
       
       if ( row != self.selectedIndex) {
           TKHorizontalTableViewCell *cell = [self cellForIndex:row];
           cell.selected = YES;
           self.selectedIndex = row;
       }
       
       if ([self.delegate respondsToSelector:@selector(tableView:didSelectCellAtIndex:)]) {
           [self.delegate tableView:self didSelectCellAtIndex:row];
       }
   }
}

- (void)deselectCell {
    if (self.selectedIndex != NSNotFound) {
        
        if ([self.delegate respondsToSelector:@selector(tableView:willDeselectCellAtIndex:)]) {
            [self.delegate tableView:self willDeselectCellAtIndex:self.selectedIndex];
        }
        
        TKHorizontalTableViewCell *cell = [self cellForIndex:self.selectedIndex];
        cell.selected = NO;
        self.selectedIndex = NSNotFound;
        
        if ([self.delegate respondsToSelector:@selector(tableView:didDeselectCellAtIndex:)]) {
            [self.delegate tableView:self didDeselectCellAtIndex:self.selectedIndex];
        }
    }
}

- (void)highlightCellAtIndex:(NSInteger)row {
    if (0 <= row < numberOfCells && row != self.highlightedIndex) {
        [self unhighlightCell];
        
        TKHorizontalTableViewCell *cell = [self cellForIndex:row];
        cell.highlighted = YES;
        self.highlightedIndex = row;
    }
}

- (void)unhighlightCell {
    if (self.highlightedIndex != NSNotFound) {
        TKHorizontalTableViewCell *cell = [self cellForIndex:self.highlightedIndex];
        cell.highlighted = NO;
        self.highlightedIndex = NSNotFound;
    }
}

- (void)reloadData {
    // 重用所有cell
    
    for (TKHorizontalTableViewCell *cell in self.visibleCells) {
        cell.highlighted = NO;
        cell.selected = NO;
        [self.reusableCells addObject:cell];
        [cell removeFromSuperview];
    }
    [self.visibleCellIndexes removeAllObjects];
    [self.widths removeAllObjects];
    self.selectedIndex = NSNotFound;
    self.highlightedIndex = NSNotFound;
    
    [self.headerView removeFromSuperview];
    [self.footerView removeFromSuperview];
    
    numberOfCells = [self.dataSource numberOfRowsInTableView:self];
    
    if ([self.delegate respondsToSelector:@selector(tableView:widthForCellAtIndex:)]) {
        for (NSInteger i = 0; i < numberOfCells; i++) {
            NSUInteger height = [self.delegate tableView:self widthForCellAtIndex:i];
            [self.widths addObject:[NSNumber numberWithDouble:height]];
        }
    } else {
        for (NSInteger i = 0; i < numberOfCells; i++) {
            [self.widths addObject:[NSNumber numberWithDouble:kTKCellDefaultWidth]];
        }
    }
    
    if (self.headerView && [delegate respondsToSelector:@selector(widthForHeaderInTableView:)]) {
        self.widthForHeader = [delegate widthForHeaderInTableView:self];
    } else {
        self.widthForHeader = self.headerView.frame.size.width;
    }

    if (self.footerView && [delegate respondsToSelector:@selector(widthForFooterInTableView:)]) {
        self.widthForFooter = [delegate widthForFooterInTableView:self];
    } else {
        self.widthForFooter = self.footerView.frame.size.width;
    }
    [self layoutSubviews];
}

- (NSArray *)visibleCells
{
    NSMutableArray *visibleCells = [NSMutableArray array];
    for (UIView *view in [containerView subviews]) {
        if ([view isKindOfClass:[TKHorizontalTableViewCell class]]) {
            [visibleCells addObject:view];
        }
    }
    return visibleCells;
}

@end
