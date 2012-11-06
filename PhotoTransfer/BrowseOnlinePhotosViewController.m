//
//  BrowseOnlinePhotosViewController.m
//  PhotoTransfer
//
//  Created by Yu Jianjun on 10/4/12.
//  Copyright (c) 2012 Yu Jianjun. All rights reserved.
//

#import "BrowseOnlinePhotosViewController.h"
#import "ServerInfo.h"
#import "ShowAlert.h"
#import "SBJson/SBJson.h"
#import "UIImageView+WebCache.h"

#define CELL_HEIGHT 80.0

@interface BrowseOnlinePhotosViewController ()

@end

@implementation BrowseOnlinePhotosViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)requestPhotoList {

    NSString *urlString = [NSString stringWithFormat:@"http://%@:%d/photoList", self.host, self.port];
    
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    self.photoListRequest = request;
    
    [_photoListRequest setDelegate:self];
    [_photoListRequest startAsynchronous];
}
- (void)requestFinished:(ASIHTTPRequest *)request
{    
    NSData *responseData = [request responseData];
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSLog(@"responseString = %@", responseString);
    
    NSDictionary *responseDict = [responseString JSONValue];
    
    self.photoList = [responseDict objectForKey:@"photoList"];
    
    [responseString release];
    
    [self.photoListTableView reloadData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    
    [self showAlertMessage:[error localizedDescription]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = self.hostName;
    
    [self requestPhotoList];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_photoList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    NSString *photoUrlString = [self.photoList objectAtIndex:indexPath.row];
    
    NSString *escapedValue =
    [(NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                         nil,
                                                         (CFStringRef)photoUrlString,
                                                         NULL,
                                                         NULL,
                                                         kCFStringEncodingUTF8)
     autorelease];
    
    NSURL *photoUrl = [NSURL URLWithString:escapedValue];
    
    [cell.imageView setImageWithURL:photoUrl placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    cell.textLabel.text = [photoUrlString lastPathComponent];
    
    // Configure the cell...
    
    return cell;
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return CELL_HEIGHT;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    NSMutableArray *theMWPhotos = [[NSMutableArray alloc] initWithCapacity:[_photoList count]];
    
    for (NSString *photoUrlString in self.photoList) {
    
        NSString *escapedValue =
        [(NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                             nil,
                                                             (CFStringRef)photoUrlString,
                                                             NULL,
                                                             NULL,
                                                             kCFStringEncodingUTF8)
         autorelease];
        
        
        MWPhoto *photo= [[MWPhoto alloc] initWithURL:[NSURL URLWithString:escapedValue]];
        
        photo.caption = [photoUrlString lastPathComponent];
        
        [theMWPhotos addObject:photo];
        
        [photo release];
    }
    
    self.mwPhotos = theMWPhotos;
    
    // Create browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    //browser.wantsFullScreenLayout = NO;
    [browser setInitialPageIndex:indexPath.row];
    
    
    [self.navigationController pushViewController:browser animated:YES];
    
    [browser release];
    [theMWPhotos release];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _mwPhotos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _mwPhotos.count)
        return [_mwPhotos objectAtIndex:index];
    return nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_photoListRequest clearDelegatesAndCancel];
    [_photoListRequest release];
    
    [_photoListTableView release];
    [_photoList release];
    [_host release];
    
    [_mwPhotos release];
    
    [_hostName release];
    
    [super dealloc];
}
- (void)viewDidUnload {
    [self setPhotoListTableView:nil];
    [super viewDidUnload];
}
@end
