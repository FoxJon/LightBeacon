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
#import "LBACoreDataManager.h"
#import "Favorite.h"
#import "User.h"

@interface LBARightVC () <UITableViewDelegate, UITableViewDataSource, LBAFavsTVCellProtocol>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic) LBAFavsTVCell *favsCell;
@property (weak, nonatomic) IBOutlet UIView *currentColorSwatch;
@property (nonatomic) NSMutableArray *favoritesArray;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (nonatomic) BOOL newColorAdded;
@property (nonatomic) UIColor *currentColor;
@property (nonatomic) Favorite *favorite;
@property (nonatomic) User *user;

@end

@implementation LBARightVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [User fetchCurrentUser];
    self.favoritesArray = [[LBACoreDataManager sharedManager]fetchEntityWithName:@"Favorite" andSortDescriptor:@"tag" ascending:YES];
    self.currentColor = [self getCurrentColor];
    self.currentColorSwatch.backgroundColor = self.currentColor;
    self.currentColorSwatch.layer.cornerRadius = self.currentColorSwatch.frame.size.width/2;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self saveContext];
}

- (IBAction)closeButtonTapped:(UIBarButtonItem *)sender {
    [self.delegate handleCloseButtonTap];
}

- (IBAction)addToFavsButtonTapped:(UIButton *)sender {
    self.favorite = [[LBACoreDataManager sharedManager]insertNewManagedObjectWithName:@"Favorite"];
    self.favorite.name = @"";
    self.favorite.red = self.user.red;
    self.favorite.green = self.user.green;
    self.favorite.blue = self.user.blue;
    self.favorite.alpha = self.user.alpha;
    self.favorite.tag = 0;
    [self saveContext];
    
    [self.favoritesArray insertObject:self.favorite atIndex:0];
    self.newColorAdded = YES;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableview insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
    return self.favoritesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    self.favsCell = [LBAFavsTVCell new];
    [tableView registerNib:[UINib nibWithNibName:@"LBAFavsTVCell" bundle:nil] forCellReuseIdentifier:@"FavsCell"];
    self.favsCell = [tableView dequeueReusableCellWithIdentifier:@"FavsCell"];
    
    self.favorite = (Favorite *)[self.favoritesArray objectAtIndex:indexPath.row];
    self.favsCell.favsTextField.text = self.favorite.name;
    self.favsCell.favsTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.favorite.tag = [NSNumber numberWithInteger:indexPath.row];
    self.favsCell.favsTextField.userInteractionEnabled = self.tableview.editing ? YES : NO;
        if (self.newColorAdded && indexPath.row == 0) {
            self.favsCell.favsTextField.userInteractionEnabled = YES;
            [self.favsCell.favsTextField becomeFirstResponder];
            self.newColorAdded = NO;
        }
    float red = [self.favorite.red floatValue];
    float green = [self.favorite.green floatValue];
    float blue = [self.favorite.blue floatValue];
    float alpha = [self.favorite.alpha floatValue];
    
    self.favsCell.cellSwatchBackgroundColor = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
    self.favsCell.favsSwatch.backgroundColor = self.favsCell.cellSwatchBackgroundColor;
    self.favsCell.favsSwatch.layer.cornerRadius = 20;

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
    NSMutableDictionary *temp = self.favoritesArray[fromIndexPath.row];
    [self.favoritesArray removeObjectAtIndex:fromIndexPath.row];
    [self.favoritesArray insertObject:temp atIndex:toIndexPath.row];
    [self.tableview reloadData];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[LBACoreDataManager sharedManager]deleteManagedObject:[self.favoritesArray objectAtIndex:indexPath.row]];
        [self.favoritesArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        [self saveContext];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 62;
}

#pragma mark - LBAFavsTVCell Delegate
-(void)keyboardResigned{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    LBAFavsTVCell *cell = (LBAFavsTVCell *)[self.tableview cellForRowAtIndexPath:indexPath];
    self.favorite.name = cell.favsTextField.text;
    [self.tableview reloadData];
    [self saveContext];
}

#pragma mark - HELPERS
-(UIColor *)getCurrentColor{
    float red = [self.user.red floatValue];
    float green = [self.user.green floatValue];
    float blue = [self.user.blue floatValue];
    float alpha = [self.user.alpha floatValue];
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}

#pragma mark - PRIVATE METHODS
- (void)saveContext{
    [[LBACoreDataManager sharedManager]saveContextForEntity:@"Favorite"];
}

@end
