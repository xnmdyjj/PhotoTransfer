//
//  SendPhotosViewController.m
//  PhotoTransfer
//
//  Created by Yu Jianjun on 9/19/12.
//  Copyright (c) 2012 Yu Jianjun. All rights reserved.
//

#import "SearchDeviceViewController.h"
#import "SendPhotosProgressViewController.h"
#import "BrowseOnlinePhotosViewController.h"
#import "GCDAsyncSocket.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"
#import <netinet/in.h>
#import <arpa/inet.h>
#import "Constants.h"

#define kCustomRowCount     7

@interface SearchDeviceViewController ()

@end

@implementation SearchDeviceViewController
@synthesize localServersTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        services = [[NSMutableArray alloc] init];
        searching = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = NSLocalizedString(@"Local Devices", nil);
	// Start browsing for bonjour services

	netServiceBrowser = [[NSNetServiceBrowser alloc] init];
	
	[netServiceBrowser setDelegate:self];
    

	[netServiceBrowser searchForServicesOfType:kServiceType inDomain:@"local."];
    

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [[NSBundle mainBundle] loadNibNamed:@"SearchDeviceHeaderView" owner:self options:nil];
    }else {
        [[NSBundle mainBundle] loadNibNamed:@"SearchDeviceHeaderView_iPad" owner:self options:nil];

    }
    
    self.searchingLabel.text = NSLocalizedString(@"Searching Device...", nil);
    
    self.localServersTableView.tableHeaderView = self.headerView;
    
    self.headerView = nil;
    
}

// Sent when browsing begins
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser
{
    searching = YES;
    [self updateUI];
}

// Sent when browsing stops
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
    searching = NO;
    [self updateUI];
}

// Sent if browsing fails
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
             didNotSearch:(NSDictionary *)errorDict
{
    searching = NO;
    [self handleError:[errorDict objectForKey:NSNetServicesErrorCode]];
}

// Sent when a service appears
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
           didFindService:(NSNetService *)aNetService
               moreComing:(BOOL)moreComing
{
    [services addObject:aNetService];
    if(!moreComing)
    {
        [self updateUI];
    }
}

// Sent when a service disappears
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
         didRemoveService:(NSNetService *)aNetService
               moreComing:(BOOL)moreComing
{
    [services removeObject:aNetService];
    
    if(!moreComing)
    {
        [self updateUI];
    }
}

// Error handling code
- (void)handleError:(NSNumber *)error
{
    NSLog(@"An error occurred. Error code = %d", [error intValue]);
    // Handle error here
}

// UI update code
- (void)updateUI
{
    if(searching)
    {
        // Update the user interface to indicate searching
        
        // Also update any UI that lists available services
        
        [self.localServersTableView reloadData];
        
    }
    else
    {
        // Update the user interface to indicate not searching
        
        self.localServersTableView.tableHeaderView = nil;
        
    }
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

    return [services count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
  
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    // Set up the cell...
    NSNetService *netService = [services objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [netService name];
    
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
    
    NSNetService *netService = [services objectAtIndex:indexPath.row];
    
    
    service = [[NSNetService alloc] initWithDomain:@"local." type:kServiceType
                                              name:[netService name]];
    [service setDelegate:self];
    [service resolveWithTimeout:5.0];
    
}


- (void)connectToNextAddress
{
	BOOL done = NO;
	
	while (!done && ([serverAddresses count] > 0))
	{
		NSData *addr;
		
		// Note: The serverAddresses array probably contains both IPv4 and IPv6 addresses.
		//
		// If your server is also using GCDAsyncSocket then you don't have to worry about it,
		// as the socket automatically handles both protocols for you transparently.
	
		addr = [serverAddresses objectAtIndex:0];
        [serverAddresses removeObjectAtIndex:0];
        
		NSLog(@"Attempting connection to %@", addr);
		
		NSError *err = nil;
		if ([asyncSocket connectToAddress:addr error:&err])
		{
			done = YES;
		}
		else
		{
			NSLog(@"Unable to connect: %@", err);
		}
		
	}
	
	if (!done)
	{
		NSLog(@"Unable to connect to any resolved address");
	}
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	NSLog(@"Socket:DidConnectToHost: %@ Port: %hu", host, port);
	connected = YES;
    
    asyncSocket.delegate = nil;
    [asyncSocket disconnect];
    [asyncSocket release];
    asyncSocket = nil;

    if (!self.isBrowsePhotos) {
        SendPhotosProgressViewController *controller;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            controller = [[SendPhotosProgressViewController alloc] initWithNibName:@"SendPhotosProgressViewController" bundle:nil];
        }else {
            
            controller = [[SendPhotosProgressViewController alloc] initWithNibName:@"SendPhotosProgressView_iPad" bundle:nil];
        }
        
        controller.host = host;
        controller.port = port;
        controller.photoPathArray = self.photoPathArray;
        
        [self.navigationController pushViewController:controller animated:YES];
        
        [controller release];
        
        self.photoPathArray = nil;
    }else {
     
        BrowseOnlinePhotosViewController *controller = [[BrowseOnlinePhotosViewController alloc] initWithNibName:@"BrowseOnlinePhotosViewController" bundle:nil];
        controller.host = host;
        controller.port = port;
        controller.hostName = service.name;
        
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
    
    service.delegate = nil;
    [service release];
    service = nil;
    
    [serverAddresses removeAllObjects];
    [serverAddresses release];
    serverAddresses = nil;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	NSLog(@"SocketDidDisconnect:WithError: %@", err);
	
	if (!connected)
	{
		[self connectToNextAddress];
	}
}

// Sent when addresses are resolved
- (void)netServiceDidResolveAddress:(NSNetService *)netService
{
    // Make sure [netService addresses] contains the
    // necessary connection information
    if ([self addressesComplete:[netService addresses]
                 forServiceType:[netService type]]) {
        
    
        NSLog(@"netServiceDidResolveAddress");
        
        if (serverAddresses == nil)
        {
            serverAddresses = [[netService addresses] mutableCopy];
        }
        
        if (asyncSocket == nil)
        {
            asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
          
            [self connectToNextAddress];
        }
    }
}

// Sent if resolution fails
- (void)netService:(NSNetService *)netService
     didNotResolve:(NSDictionary *)errorDict
{
    [self handleError:[errorDict objectForKey:NSNetServicesErrorCode]];
  //  [services removeObject:netService];
}

// Verifies [netService addresses]
- (BOOL)addressesComplete:(NSArray *)addresses
           forServiceType:(NSString *)serviceType
{
    // Perform appropriate logic to ensure that [netService addresses]
    // contains the appropriate information to connect to the service
    return YES;
}

- (void)viewDidUnload
{
    [self setLocalServersTableView:nil];
    [self setHeaderView:nil];
    [self setSearchingLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc {
    netServiceBrowser.delegate = nil;
    [netServiceBrowser stop];
    [netServiceBrowser release];
    netServiceBrowser = nil;
    
    [services removeAllObjects];
    [services release];
    
    service.delegate = nil;
    [service release];
    service = nil;
    
    asyncSocket.delegate = nil;
    [asyncSocket release];
    asyncSocket = nil;
    
    [serverAddresses removeAllObjects];
    [serverAddresses release];
    serverAddresses = nil;
    
    [localServersTableView release];
    
    [_photoPathArray release];
    
    [_headerView release];
    [_searchingLabel release];
    [super dealloc];
}

@end
