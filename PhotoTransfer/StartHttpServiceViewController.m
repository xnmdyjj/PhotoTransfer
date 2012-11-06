//
//  ReceivePhotosViewController.m
//  PhotoTransfer
//
//  Created by Yu Jianjun on 9/19/12.
//  Copyright (c) 2012 Yu Jianjun. All rights reserved.
//

#import "StartHttpServiceViewController.h"

#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "MyHTTPConnection.h"
#import "Constants.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "ServerInfo.h"

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface StartHttpServiceViewController ()

@end

@implementation StartHttpServiceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = NSLocalizedString(@"HTTP Server Started", nil);
    
    // Configure our logging framework.
	// To keep things simple and fast, we're just going to log to the Xcode console.
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	
	// Initalize our http server
	httpServer = [[HTTPServer alloc] init];
	
	// Tell the server to broadcast its presence via Bonjour.
	// This allows browsers such as Safari to automatically discover our service.
	[httpServer setType:kServiceType];
    [httpServer setDomain:@"local."];
	
	// Normally there's no need to run our server on any specific port.
	// Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
	// However, for easy testing you may want force a certain port so you can just hit the refresh button.
    [httpServer setPort:8080];
	
	// Serve files from the standard Sites folder
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
	[httpServer setDocumentRoot:documentsDirectory];
	
	[httpServer setConnectionClass:[MyHTTPConnection class]];
	
	NSError *error = nil;
	if([httpServer start:&error])
	{
		//DDLogInfo(@"Started HTTP Server on port %hu", [httpServer listeningPort]);
        
        NSString *ipAddress = [self getIPAddress];
        
        self.serverUrlString = [NSString stringWithFormat:@"http://%@:%hu", ipAddress, [httpServer listeningPort]];
        
        [self.receiveTableView reloadData];
        
        ServerInfo *sharedInstance = [ServerInfo sharedManager];
        
        sharedInstance.host = ipAddress;
        sharedInstance.port = [httpServer listeningPort];
        
	}
	else
	{
		DDLogError(@"Error starting HTTP Server: %@", error);
	}
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
        
        self.navigationItem.leftBarButtonItem = cancelBarButtonItem;
        
        [cancelBarButtonItem release];
    }
}


-(void)cancelAction:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(dismissReceivePhotosViewController)]) {
        
        [self.delegate dismissReceivePhotosViewController];
    }
}

// Get IP Address
- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en1"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    
    cell.textLabel.text = self.serverUrlString;
    
    // Configure the cell...
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    
    return NSLocalizedString(@"receivePhotosDesKey", nil);
}


- (void)viewDidUnload
{
    [self setReceiveTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void)dealloc {
    
    [httpServer stop];
    
    [httpServer release];

    [_receiveTableView release];
    [super dealloc];
}

@end
