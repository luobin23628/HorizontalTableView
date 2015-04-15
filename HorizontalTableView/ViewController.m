//
//  ViewController.m
//  HorizontalTableView
//
//  Created by binluo on 15/4/15.
//  Copyright (c) 2015年 binluo. All rights reserved.
//

#import "ViewController.h"
#import "TKHorizontalTableView.h"

@interface ViewController ()<TKHorizontalTableViewDelegate, TKHorizontalTableViewDataSource>

@property (nonatomic, strong) TKHorizontalTableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tableView = [[TKHorizontalTableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}


#pragma mark -  TKHorizontalTableViewDataSource


- (NSInteger)numberOfRowsInTableView:(TKHorizontalTableView *)tableView {
    return 20;
}

- (TKHorizontalTableViewCell *)tableView:(TKHorizontalTableView *)tableView cellAtIndex:(NSUInteger)index {
    TKHorizontalTableViewCell *cell = [tableView dequeueReusableCell];
    if (!cell) {
        cell = [[TKHorizontalTableViewCell alloc] init];
    }
    cell.backgroundColor = [UIColor colorWithWhite:index/20.0 alpha:1];
    return cell;
}

#pragma mark -  TKHorizontalTableViewDelegate

- (CGFloat)tableView:(TKHorizontalTableView *)tableView widthForCellAtIndex:(NSUInteger)index {
    return 100;
}

- (void)tableView:(TKHorizontalTableView *)tableView didSelectCellAtIndex:(NSUInteger)index {
    
}


@end
