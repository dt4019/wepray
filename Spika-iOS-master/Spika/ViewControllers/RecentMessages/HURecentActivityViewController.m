/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Clover Studio Ltd. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "HURecentActivityViewController.h"
#import "HURecentActivityViewController+Style.h"
#import "DatabaseManager.h"
#import "HUActivityMessageCell.h"
#import "MAKVONotificationCenter.h"
#import "HUCachedImageLoader.h"
#import "Utils.h"

#import "AppDelegate.h"
#import "UserManager.h"


@interface HURecentActivityViewController ()

@end

@implementation HURecentActivityViewController

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Recent activity", nil);
		
		void(^observerBlock)(MAKVONotification *notification) = ^(MAKVONotification *notification) {
			DatabaseManager *manager = [notification target];
			[[notification observer] updateDataWithNewRecentActivity:manager.recentActivity];
		};
		
		[[MAKVONotificationCenter defaultCenter] addObserver:self
													  object:[DatabaseManager defaultManager]
													 keyPath:@"recentActivity"
													 options:0
													   block:observerBlock];
    }
    return self;
}

-(void) updateDataWithNewRecentActivity:(ModelRecentActivity *)recentActivity {
	

	self.activity = recentActivity;
    

	[self.tableView reloadData];
	
	//[self.tableView endUpdates];
}

+(HURecentActivityViewController *) newRecentActivityViewController {
	
	HURecentActivityViewController *viewController = [HURecentActivityViewController new];
	viewController.activity = [DatabaseManager defaultManager].recentActivity;
	
	return viewController;
}

#pragma mark - View lifecycle

-(void) loadView {
	
	[super loadView];
	
//    [self addSlideButtonItem];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _noItemsLabel = [self noItemsLabel];
	[self.view addSubview:_noItemsLabel];
    
    _noItemsLabel.hidden = YES;
    
    
    self.navigationItem.rightBarButtonItem = [CSKit barButtonItemWithNormalImageNamed:@"icon_users"
                                                                            highlighted:nil
                                                                                 target:self
                                                                               selector:@selector(toggleSubMenu:)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//    [self showTutorialIfCan:NSLocalizedString(@"tutorial-recent",nil)];
    [[AlertViewManager defaultManager] showHUD];
    locationManager = [[CLLocationManager alloc]init];
    CLLocationCoordinate2D location = [locationManager.location coordinate];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:locationManager.location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       NSString *city = @"";
                       if (error == nil){
                           // get name address by location
                           CLPlacemark *placemark = [placemarks objectAtIndex:0];
                           NSDictionary *addressDictionary = placemark.addressDictionary;
                           city = [addressDictionary objectForKey:@"State"];
                       }
                       // load current user
                       ModelUser *_user = [UserManager defaultManager].getLoginedUser;
                       // check if about of user contains city
                       if (city.length > 0) {
                           NSRange range = [_user.about rangeOfString:city];
                           if (range.length == 0) {
                               // add city to about
                               _user.about = [_user.about stringByAppendingString:[NSString stringWithFormat:@";%@", city]];
                           }
                       }
                       NSArray *arr = [_user.about componentsSeparatedByString:@";"];
                       // get before location
                       NSString *beforeLocation = @"";
                       if (arr.count > 0) {
                           beforeLocation = [arr objectAtIndex:0];
                       }
                       // update loacation in about
                       if (beforeLocation.length > 0) {
                           NSString *newLocation = [NSString stringWithFormat:@"%f,%f", location.latitude, location.longitude];
                           _user.about = [_user.about stringByReplacingOccurrencesOfString:beforeLocation withString:newLocation];
                       }
                       
                       [[DatabaseManager defaultManager] updateUser:_user
                                                           oldEmail:_user.email
                                                            success:^(BOOL isSuccess, NSString *errStr){
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    [[AlertViewManager defaultManager] hideHUD];
                                                                    if (isSuccess) {
                                                                        [[UserManager defaultManager] reloadUserDataWithCompletion:^(id result) {
                                                                            NSLog(@"update location of current user success");
                                                                        }];
                                                                        
                                                                    }
                                                                });
                                                                
                                                            } error:^(NSString *errStr){
                                                                [[AlertViewManager defaultManager] hideHUD];
                                                                NSLog(@"update location of current user fail");
                                                            }];
                   }];
}
// Setting the title of the tab.
- (NSString *)tabTitle
{
    return @"Chatting";
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.userInteractionEnabled = true;
    
    self.navigationItem.leftBarButtonItem = [CSKit barButtonItemWithNormalImageNamed:@"hu_profile_icon"
                                                                         highlighted:nil
                                                                              target:self
                                                                            selector:@selector(toggleMyProfile:)];
//    self.navigationItem.leftBarButtonItems = [self backBarButtonItemsWithSelector:@selector(backButtonDidPress:)];
//    self.navigationItem.leftBarButtonItem=nil;
//    [self.navigationItem setHidesBackButton:YES animated:NO];
    self.navigationItem.titleView.center = self.navigationController.navigationBar.center;
}

#pragma mark - UITableViewDatasource

-(HUModelActivityCategory *) categoryForIndexPath:(NSIndexPath *)indexPath {
	return [self categoryForSection:indexPath.section];
}

-(HUModelActivityCategory *) categoryForSection:(NSInteger)section {
	return self.activity.categories[section];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
    if(self.activity.categories.count == 0){
        _noItemsLabel.hidden = NO;
    }else{
        _noItemsLabel.hidden = YES;
    }
    
	return self.activity.categories.count;
    
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	HUModelActivityCategory *category = [self categoryForSection:section];
	return category.notifications.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return [HUActivityMessageCell cellHeightForMessage:nil];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	HUModelActivityCategory *category = [self categoryForIndexPath:indexPath];
	HUModelActivityNotification *notification = category.notifications[indexPath.row];
	ModelMessage *message = notification.messages.lastObject;
	
	static NSString *cellIdentifier = @"CellIdentifier";
	HUActivityMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[HUActivityMessageCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:cellIdentifier];
    }
	
	cell.textLabel.text = message.body;
    cell.timestampLabel.text = [Utils formatDate:[NSDate dateWithTimeIntervalSince1970:message.modified]];
                           
	cell.counterView.count = notification.count;
	
	cell.avatarIconView.image = [UIImage imageNamed:@"user_stub"];
    
    [HUCachedImageLoader imageFromUrl:message.avatarThumbUrl completionHandler:^(UIImage *image) {
        if(image)
            cell.avatarIconView.image = image;
    }];
    
	return cell;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	HUModelActivityCategory *category = [self categoryForSection:section];
	return [self newTableHeaderViewWithTitle:NSLocalizedString([category.name uppercaseString], nil)];
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	return [[self class] heightForHeaderView];
}

#pragma mark - UITableViewDelegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    self.view.userInteractionEnabled = false;
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	HUModelActivityCategory *category = [self categoryForIndexPath:indexPath];
	//ModelMessage *message = category.allMessages[indexPath.row];
	HUModelActivityNotification *note = category.notifications[indexPath.row];
	
    if([note.category.targetType isEqualToString:@"group"]){
        
        [[DatabaseManager defaultManager] findGroupByID:note.targetId success:^(id result) {
            
            ModelGroup *group = (ModelGroup *) result;
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowGroupWall object:group];
            
        } error:^(NSString *errorString) {

            
        }];

        
    }else{

        [[DatabaseManager defaultManager] findUserWithID:note.targetId success:^(id result) {
            ModelUser *user = (ModelUser *)result;
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowUserWall object:user];
            
        } error:^(NSString *errorString) {
            
        }];
        
    }
    

}

-(void) toggleSubMenu:(UIButton*) button {
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSideMenuUsersSelected object:nil];
}
-(void) toggleMyProfile:(UIButton*) button {
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSideMenuMyProfileSelected object:nil];
}

-(void) backButtonDidPress:(id)sender {
    [[AppDelegate getInstance].navigationController popViewControllerAnimated:YES];
}

@end
