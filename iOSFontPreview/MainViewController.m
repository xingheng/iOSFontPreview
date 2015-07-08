//
//  MainViewController.m
//  iOSFontPreview
//
//  Created by WeiHan on 7/7/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *allFamilyNames;
@property (nonatomic, strong) NSArray *allFamilyFontNames;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"iOS Font Preview";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self buildView];
    [self buildData];
}

- (void)buildView
{
    UITableView *fontTable = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    fontTable.delegate = self;
    fontTable.dataSource = self;
    fontTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:fontTable];
}

- (void)buildData
{
    NSArray *arr = [UIFont familyNames];
    _allFamilyNames = arr;
    
    NSMutableArray *fontList = [NSMutableArray new];
    
    for (NSString *family in arr) {
        NSArray *familyNames = [UIFont fontNamesForFamilyName:family];
        [fontList addObjectsFromArray:familyNames];
    }
    
    _allFamilyFontNames = fontList;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _allFamilyFontNames.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strCellID = @"fontTableCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strCellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCellID];
    }
    
    NSString *fontName = _allFamilyFontNames[indexPath.section];
    UIFont *font = [UIFont fontWithName:fontName size:25];
    
    cell.textLabel.text = @"字体预览 - Font Preview";
    cell.textLabel.font = font;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *fontName = _allFamilyFontNames[section];
    return fontName;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *fontName = _allFamilyFontNames[indexPath.section];
    [UIPasteboard generalPasteboard].string = fontName;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:fontName message:@"已复制此字体名称到剪贴板" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
