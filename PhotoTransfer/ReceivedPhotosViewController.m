//
//  ReceivedPhotosViewController.m
//  PhotoTransfer
//
//  Created by Yu Jianjun on 9/22/12.
//  Copyright (c) 2012 Yu Jianjun. All rights reserved.
//

#import "ReceivedPhotosViewController.h"
#import "UIImage+Util.h"
#import "SearchDeviceViewController.h"

#define kPhotoName @"photoName"
#define kFullImage @"fullImage"
#define kThumbnail @"thumbnail"
#define kPhotoPath @"PhotoPath"

#define THUMBNAIL_WIDTH 64.0
#define THUMBNAIL_HEIGHT 64.0

#define CELL_HEIGHT 80.0

@interface ReceivedPhotosViewController ()

@end

@implementation ReceivedPhotosViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)readPhotos{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSError * error = nil;
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    
    if (error) {
        NSLog(@"read photos failed:%@", [error description]);
        
        return;
    }
    
    if ([directoryContent count]) {
        
        NSMutableArray *thePhotos = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [directoryContent count]; i++)
        {
            
            NSString *photoName = [directoryContent objectAtIndex:i];
            
            if ([photoName isEqualToString:@"index.html"] || [photoName isEqualToString:@".DS_Store"]) {
                continue;
            }
            
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:photoName];
            
            NSData *photoData = [NSData dataWithContentsOfFile:filePath];
            
            UIImage *image = [UIImage imageWithData:photoData];
            
            if (image != nil) {
                UIImage *thumbnail = [image scaleToSize:CGSizeMake(THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT)];
                
                NSDictionary *photoInfo = [[NSDictionary alloc] initWithObjectsAndKeys:photoName, kPhotoName, image, kFullImage,thumbnail, kThumbnail,filePath, kPhotoPath ,nil];
                
                [thePhotos addObject:photoInfo];
                
                [photoInfo release];
            }
        }
        
        self.photos = thePhotos;
        
        [thePhotos release];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
    });
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    self.navigationItem.title = NSLocalizedString(@"Received Photos", nil);
    
    UIBarButtonItem *actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(operateAction:)];
    
    self.actionButton = actionBarButtonItem;
    
    self.navigationItem.rightBarButtonItem = actionBarButtonItem;
    
    [actionBarButtonItem release];
    
    
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
    
    self.cancelButton = cancelBarButtonItem;
    
    [cancelBarButtonItem release];
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    dispatch_queue_t readPhotoFilesQueue = dispatch_queue_create("com.yujianjun.readPhotoFiles", NULL);
    
    dispatch_async(readPhotoFilesQueue, ^ {
        
        [self readPhotos];
    });
    
    
    UIBarButtonItem *deleteBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(deleteAction:)];
    
    UIBarButtonItem *transferBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Transfer", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(transferAction:)];
        
    UIBarButtonItem *flexibleBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self setToolbarItems:[NSArray arrayWithObjects:transferBarButtonItem, flexibleBarButtonItem, deleteBarButtonItem, nil]];
        
    [transferBarButtonItem release];
    [flexibleBarButtonItem release];
    [deleteBarButtonItem release];
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (self.tableView.editing) {
        
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if (self.tableView.editing) {
        
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

-(void)operateAction:(id)sender {
    
    self.navigationItem.rightBarButtonItem = self.cancelButton;
    
    [self.tableView setEditing:YES animated:YES];
    
    UIBarButtonItem *deleteBarButtonItem = [self.toolbarItems objectAtIndex:2];

    UIBarButtonItem *transferBarButtonItem = [self.toolbarItems objectAtIndex:0];
    
    transferBarButtonItem.enabled = NO;
    deleteBarButtonItem.enabled = NO;
    
    [self.navigationController setToolbarHidden:NO animated:YES];
}

-(void)cancelAction {
    
    self.navigationItem.rightBarButtonItem = self.actionButton;
    
    [self.tableView setEditing:NO animated:YES];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
}

-(void)transferAction:(id)sender {
    
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    if (selectedRows.count > 0)
    {
        NSMutableArray *selectedArray = [NSMutableArray array];
        for (NSIndexPath *selectionIndex in selectedRows)
        {
            NSDictionary *photoInfo = [self.photos objectAtIndex:selectionIndex.row];
            [selectedArray addObject:[photoInfo objectForKey:kPhotoPath]];
        }
        
        SearchDeviceViewController *controller = [[SearchDeviceViewController alloc] initWithNibName:@"SearchDeviceViewController" bundle:nil];
        
        controller.photoPathArray = selectedArray;
    
        [self.navigationController pushViewController:controller animated:YES];
        
        [controller release];
    }
}

-(void)deleteAction:(id)sender {
    
    // open a dialog with just an OK button
	NSString *actionTitle = ([[self.tableView indexPathsForSelectedRows] count] == 1) ?
    @"Are you sure you want to remove this item?" : @"Are you sure you want to remove these items?";
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionTitle
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showFromToolbar:self.navigationController.toolbar];	// show from our table view (pops up in the middle of the table)
	[actionSheet release];
}


-(void)removeFilesWithArray:(NSMutableArray *)deletionArray {
    
    NSError *error = nil;
    
    for (NSDictionary *photoInfo in deletionArray) {
        
        NSString *filePath = [photoInfo objectForKey:kPhotoPath];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        
        if (!success) {
            
            NSLog(@"error = %@", [error description]);
            
            continue;
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0)
	{
		// delete the selected rows
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        if (selectedRows.count > 0)
        {
            // setup our deletion array so they can all be removed at once
            NSMutableArray *deletionArray = [NSMutableArray array];
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                [deletionArray addObject:[self.photos objectAtIndex:selectionIndex.row]];
            }
            [self.photos removeObjectsInArray:deletionArray];
            
            // then delete the only the rows in our table that were selected
            [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [self removeFilesWithArray:deletionArray];
        }
    
        [self cancelAction];
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    return [_photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    NSDictionary *photoInfo = [self.photos objectAtIndex:indexPath.row];
    
    cell.imageView.image = [photoInfo objectForKey:kThumbnail];

    cell.textLabel.text = [photoInfo objectForKey:kPhotoName];
    
    // Configure the cell...
    
    return cell;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
    
    if (!self.tableView.editing) {
        
        NSMutableArray *theMWPhotos = [[NSMutableArray alloc] initWithCapacity:[_photos count]];
        
        for (NSDictionary *photoInfo in self.photos) {
            
            UIImage *image = [photoInfo objectForKey:kFullImage];
            
            MWPhoto *photo= [[MWPhoto alloc] initWithImage:image];
            
            photo.caption = [photoInfo objectForKey:kPhotoName];
            
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
        
    }else {
        
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        
        UIBarButtonItem *deleteBarButtonItem = [self.toolbarItems objectAtIndex:2];
        
        
        UIBarButtonItem *transferBarButtonItem = [self.toolbarItems objectAtIndex:0];
        
        if ([selectedRows count] > 0) {
           
            transferBarButtonItem.enabled = YES;
            deleteBarButtonItem.enabled = YES;
        }else {
            transferBarButtonItem.enabled = NO;
            deleteBarButtonItem.enabled = NO;
            
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.isEditing)
    {
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        
        UIBarButtonItem *deleteBarButtonItem = [self.toolbarItems objectAtIndex:2];
        
        UIBarButtonItem *transferBarButtonItem = [self.toolbarItems objectAtIndex:0];
        
        if ([selectedRows count] > 0) {
            
            transferBarButtonItem.enabled = YES;
            deleteBarButtonItem.enabled = YES;
        }else {
            transferBarButtonItem.enabled = NO;
            deleteBarButtonItem.enabled = NO;
            
        }
    }
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


-(void)dealloc {
    [_actionButton release];
    [_cancelButton release];
    [_photos release];
    [_mwPhotos release];
    [super dealloc];
}

@end
