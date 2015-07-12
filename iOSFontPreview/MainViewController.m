//
//  MainViewController.m
//  iOSFontPreview
//
//  Created by WeiHan on 7/7/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import "MainViewController.h"
#import "DOPDropDownMenu.h"
#import <MBProgressHUD.h>

#define kSTR_ALL    @"All"

#pragma mark - Font Names

NSArray *GetFontNames(NSString *familyName)
{
    return [UIFont fontNamesForFamilyName:familyName];
}

NSString *GetMainFontName(NSString *familyName)
{
    NSArray *fonts = GetFontNames(familyName);
    
    if (!(fonts && fonts.count > 0)) {
        return nil;
    }
    
    NSString *resultFont = fonts[0];
    NSInteger minLength = [resultFont length];
    
    for (NSString *fontName in fonts) {
        if ([fontName rangeOfString:@"regular" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            resultFont = fontName;
            break;
        }
        
        if (fontName.length < minLength) {
            minLength = fontName.length;
            resultFont = fontName;
        }
    }
    
    return resultFont;
}

NSArray *GetAllFamilyFontNames()
{
    NSArray *familyNames = [UIFont familyNames];
    NSMutableArray *fontList = [NSMutableArray new];
    
    for (NSString *family in familyNames) {
        [fontList addObjectsFromArray:GetFontNames(family)];
    }
    
    return fontList;
}

#pragma mark - MainViewController

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource, DOPDropDownMenuDelegate, DOPDropDownMenuDataSource>

@property (nonatomic, strong) NSArray *allFamilyNames;
@property (nonatomic, strong) NSArray *allFamilyFontNames;

@property (nonatomic, strong) UITableView *fontTable;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"iOS Font Preview";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self buildData];
    [self buildView];
}

- (void)buildView
{
    UIView *superView = self.view;
    
    DOPDropDownMenu *menu = [[DOPDropDownMenu alloc] initWithOrigin:CGPointMake(0, 64) andHeight:40];
    menu.delegate = self;
    menu.dataSource = self;
    menu.menuTableHeight = 400;
    menu.menuItemHeight = 50;
    [superView addSubview:menu];
    
    _fontTable = [[UITableView alloc] initWithFrame:superView.frame style:UITableViewStyleGrouped];
    _fontTable.delegate = self;
    _fontTable.dataSource = self;
    _fontTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [superView addSubview:_fontTable];
    [_fontTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(menu.mas_bottom);
        make.left.and.right.equalTo(@0);
        make.bottom.equalTo(superView.mas_bottom);
    }];
}

- (void)buildData
{
    NSArray *familyNames = [UIFont familyNames];
    NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:kSTR_ALL, nil];
    [arr addObjectsFromArray:familyNames];
    _allFamilyNames = arr;
    
    _allFamilyFontNames = GetAllFamilyFontNames();
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *fontName = _allFamilyFontNames[indexPath.section];
    [UIPasteboard generalPasteboard].string = fontName;
    
#if HUD
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"已复制此字体名称到剪贴板";
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
#else
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:fontName message:@"已复制此字体名称到剪贴板" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
#endif
}

#pragma mark - DOPDropDownMenuDataSource

- (NSInteger)menu:(DOPDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column
{
    return _allFamilyNames.count;
}

- (NSString *)menu:(DOPDropDownMenu *)menu titleForRowAtIndexPath:(DOPIndexPath *)indexPath
{
    NSInteger idx = indexPath.row;
    
    NSString *family = _allFamilyNames[idx];
    if ([family isEqualToString:kSTR_ALL]) {
        return family;
    }
    
    return GetMainFontName(family);
}

- (NSInteger)numberOfColumnsInMenu:(DOPDropDownMenu *)menu
{
    return 1;
}

#pragma mark - DOPDropDownMenuDelegate

- (void)menu:(DOPDropDownMenu *)menu didSelectRowAtIndexPath:(DOPIndexPath *)indexPath
{
    NSInteger idx = indexPath.row;
    NSString *family = _allFamilyNames[idx];
    
    if ([family isEqualToString:kSTR_ALL]) {
        _allFamilyFontNames = GetAllFamilyFontNames();
    } else {
        _allFamilyFontNames = GetFontNames(family);
    }
    
    [_fontTable reloadData];
    
}

@end
