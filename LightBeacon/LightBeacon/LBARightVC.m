//
//  LBARightVC.m
//  LightBeacon
//
//  Created by Jonathan Fox on 7/2/15.
//  Copyright (c) 2015 Jon Fox. All rights reserved.
//

#import "LBARightVC.h"
#import "LBAFavsTVCell.h"
#import "LBACenterVC.h"
#import "LBAConstants.h"

@interface LBARightVC () <UITableViewDelegate, UITableViewDataSource, LBAFavsTVCellProtocol>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic) LBAFavsTVCell *favsCell;
@property (weak, nonatomic) IBOutlet UIView *currentColorSwatch;
@property (nonatomic) NSMutableArray *favorites;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (nonatomic) BOOL newColorAdded;
@property (nonatomic) NSMutableDictionary *colorDictionary;
@property (nonatomic) UIColor *currentColor;
@end

@implementation LBARightVC
{
    NSUserDefaults *defaults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    self.currentColor = [self getCurrentColor];
    self.currentColorSwatch.backgroundColor = self.currentColor;
    self.favorites = [[defaults objectForKey:FAVORITES_ARRAY]mutableCopy];
    if (!self.favorites) {
        self.favorites = [@[]mutableCopy];
    }
}

- (IBAction)closeButtonTapped:(UIBarButtonItem *)sender {
    [self.delegate handleCloseButtonTap];
}

- (IBAction)addToFavsButtonTapped:(UIButton *)sender {
    float red = [defaults floatForKey:CURRENT_COLOR_RED];
    float green = [defaults floatForKey:CURRENT_COLOR_GREEN];
    float blue = [defaults floatForKey:CURRENT_COLOR_BLUE];
    float alpha = [defaults floatForKey:CURRENT_ALPHA];
    self.colorDictionary = [@{@"name":@"", @"red":[NSNumber numberWithFloat:red], @"green":[NSNumber numberWithFloat:green], @"blue":[NSNumber numberWithFloat:blue], @"alpha":[NSNumber numberWithFloat:alpha]}mutableCopy];
    [(NSMutableArray *)self.favorites insertObject:self.colorDictionary atIndex:0];
    self.newColorAdded = YES;
    [self.tableview beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableview insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableview endUpdates];
}

- (IBAction)editButtonTapped:(UIButton *)sender {
    [self.tableview setEditing:YES animated:YES];
    [self.delegate handleEditButtonTap];
    self.editButton.hidden = YES;
    self.doneButton.hidden = NO;
    [self.tableview reloadData];
}

- (IBAction)doneButtonTapped:(UIButton *)sender {
    [self.tableview setEditing:NO animated:YES];
    [self.delegate handleDoneButtonTap];
    self.editButton.hidden = NO;
    self.doneButton.hidden = YES;
    [self.tableview reloadData];
}

#pragma mark - TABLEVIEW DATASOURCE
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.favorites.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    self.favsCell = [LBAFavsTVCell new];
    [tableView registerNib:[UINib nibWithNibName:@"LBAFavsTVCell" bundle:nil] forCellReuseIdentifier:@"FavsCell"];
    self.favsCell = [tableView dequeueReusableCellWithIdentifier:@"FavsCell"];
    
    self.favsCell.favsTextField.text = [self.favorites[indexPath.row] objectForKey:@"name"];
    self.favsCell.favsTextField.userInteractionEnabled = self.tableview.editing ? YES : NO;
        if (self.newColorAdded && indexPath.row == 0) {
            self.favsCell.favsTextField.userInteractionEnabled = YES;
            [self.favsCell.favsTextField becomeFirstResponder];
        }
    float red = [[self.favorites[indexPath.row] objectForKey:@"red"] floatValue];
    float green = [[self.favorites[indexPath.row] objectForKey:@"green"] floatValue];
    float blue = [[self.favorites[indexPath.row] objectForKey:@"blue"] floatValue];
    float alpha = [[self.favorites[indexPath.row] objectForKey:@"alpha"] floatValue];
    
    self.favsCell.cellSwatchBackgroundColor = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
    self.favsCell.favsSwatch.backgroundColor = self.favsCell.cellSwatchBackgroundColor;
    
    if (indexPath.row == 0) {self.favsCell.delegate = self;}
    
    return self.favsCell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LBAFavsTVCell *cell = (LBAFavsTVCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.favsSwatch.backgroundColor = cell.cellSwatchBackgroundColor;
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithWhite:255.0 alpha:0.3];
    [cell setSelectedBackgroundView:bgColorView];
    
    [self.delegate changeBackgroundColorToColor:cell.cellSwatchBackgroundColor];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    return footer;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSMutableDictionary *temp = self.favorites[fromIndexPath.row];
    [self.favorites removeObjectAtIndex:fromIndexPath.row];
    [self.favorites insertObject:temp atIndex:toIndexPath.row];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.tableview beginUpdates];
        [(NSMutableArray *)self.favorites removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableview endUpdates];
        [defaults setObject:self.favorites forKey:FAVORITES_ARRAY];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 62;
}

#pragma mark - LBAFavsTVCell Delegate
-(void)keyboardResigned{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    LBAFavsTVCell *cell = (LBAFavsTVCell *)[self.tableview cellForRowAtIndexPath:indexPath];
    NSString *name = cell.favsTextField.text;
    [self.colorDictionary setValue:name forKey:@"name"];
    [self.favorites replaceObjectAtIndex:0 withObject:self.colorDictionary];
    [defaults setObject:self.favorites forKey:FAVORITES_ARRAY];
}

#pragma mark - HELPERS
-(UIColor *)getCurrentColor{
    float red = [defaults floatForKey:CURRENT_COLOR_RED];
    float green = [defaults floatForKey:CURRENT_COLOR_GREEN];
    float blue = [defaults floatForKey:CURRENT_COLOR_BLUE];
    float alpha = [defaults floatForKey:CURRENT_ALPHA];
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}

@end
