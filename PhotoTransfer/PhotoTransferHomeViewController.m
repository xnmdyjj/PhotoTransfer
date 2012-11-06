//
//  PhotoTransferHomeViewController.m
//  PhotoTransfer
//
//  Created by Yu Jianjun on 9/19/12.
//  Copyright (c) 2012 Yu Jianjun. All rights reserved.
//

#import "PhotoTransferHomeViewController.h"
#import "ReceivedPhotosViewController.h"
#import "SearchDeviceViewController.h"


@interface PhotoTransferHomeViewController ()


@end

@implementation PhotoTransferHomeViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        _bannerView = [[ADBannerView alloc] init];
        _bannerView.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = NSLocalizedString(@"Photo Transfer", nil);
    
    self.dataArray = [NSArray arrayWithObjects:
                      NSLocalizedString(@"Send Photos", nil),NSLocalizedString(@"Browse Photos", nil),
                      
                      NSLocalizedString(@"Received Photos", nil),
                      
                      NSLocalizedString(@"Start HTTP Server", nil), nil];
    
    
    [self.view addSubview:_bannerView];
}


-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self layoutAnimated:NO];
}

- (void)layoutAnimated:(BOOL)animated
{    
    CGRect contentFrame = self.view.bounds;
    CGRect bannerFrame = _bannerView.frame;
    if (_bannerView.bannerLoaded) {
        contentFrame.size.height -= _bannerView.frame.size.height;
        bannerFrame.origin.y = contentFrame.size.height;
    } else {
        bannerFrame.origin.y = contentFrame.size.height;
    }
    
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        self.tableView.frame = contentFrame;
        [self.tableView layoutIfNeeded];
        _bannerView.frame = bannerFrame;
    }];
}


- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self layoutAnimated:YES];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [self layoutAnimated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
        case 2:
            return 1;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
            break;
        case 1:
            cell.textLabel.text = [self.dataArray objectAtIndex:2];
            break;
        case 2:
            cell.textLabel.text = [self.dataArray objectAtIndex:3];
            break;
        default:
            break;
    }

    // Configure the cell...
    
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    if (section == 2) {
        return NSLocalizedString(@"photoTransferDesKey", nil);
    }
    
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            if (indexPath.row) {
                [self browsePhotosAction];
            }else{
                [self sendPhotosAction];
            }
            break;
        case 1:
            [self showReceivedPhotos];
            break;
        case 2:
            [self receivePhotosAction];
            break;
        default:
            break;
    }
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)receivePhotosAction{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        StartHttpServiceViewController *controller = [[StartHttpServiceViewController alloc] initWithNibName:@"StartHttpServiceViewController" bundle:nil];
        
        [self.navigationController pushViewController:controller animated:YES];
        
        [controller release];
    }else {
        
        StartHttpServiceViewController *controller = [[StartHttpServiceViewController alloc] initWithNibName:@"StartHttpServiceViewController" bundle:nil];
        controller.delegate = self;
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self.navigationController presentModalViewController:navigationController animated:YES];
                
        [controller release];
        
        [navigationController release];
        
    }
}

- (void)sendPhotosAction{
    
    SearchDeviceViewController *controller = [[SearchDeviceViewController alloc] initWithNibName:@"SearchDeviceViewController" bundle:nil];
    
    [self.navigationController pushViewController:controller animated:YES];
    
    [controller release];

}

- (void)showReceivedPhotos{
    ReceivedPhotosViewController *controller = [[ReceivedPhotosViewController alloc] initWithStyle:UITableViewStylePlain];
    
    [self.navigationController pushViewController:controller animated:YES];
    
    [controller release];
}

-(void)browsePhotosAction {
    
    SearchDeviceViewController *controller = [[SearchDeviceViewController alloc] initWithNibName:@"SearchDeviceViewController" bundle:nil];
    
    controller.isBrowsePhotos = YES;
    
    [self.navigationController pushViewController:controller animated:YES];
    
    [controller release];
}

#pragma mark - ReceivePhotosViewControllerDelegate

-(void)dismissReceivePhotosViewController {
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
    
    _bannerView.delegate = nil;
    [_bannerView release];
    
    [_tableView release];
    [_dataArray release];
    
    [super dealloc];
}
@end
