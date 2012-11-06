//
//  SendPhotosProgressViewController.m
//  PhotoTransfer
//
//  Created by Yu Jianjun on 9/20/12.
//  Copyright (c) 2012 Yu Jianjun. All rights reserved.
//

#import "SendPhotosProgressViewController.h"

#define kImageType @"ImageType"
#define kImageName @"ImageName"
#define kImageData @"ImageData"
#define kImageSize @"ImageSize"

@interface SendPhotosProgressViewController ()

@end

@implementation SendPhotosProgressViewController
@synthesize photosNumberProgressLabel;
@synthesize photosSizeProgressLabel;
@synthesize progressIndicator;

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
    
    self.navigationItem.title = NSLocalizedString(@"Send Photos", nil);
    
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPhotosAction:)];
    
    self.navigationItem.rightBarButtonItem = addBarButtonItem;
    
    [addBarButtonItem release];
    
    [self initProgress];
    
    if ([self.photoPathArray count]) {
        
        [self startRequestWithPhotoPathArray];
    }
}

-(void)setProgressLabelText {
    
    self.photosSizeProgressLabel.text = [NSString stringWithFormat:@"%0.2fMB/%0.2fMB", self.transferedPhotosSize, self.photosSumSize];
    
    self.photosNumberProgressLabel.text = [NSString stringWithFormat:@"%d/%d",self.transferedPhotosNumber, self.photosSumNumber];
}

-(void)initProgress {
    
    self.photosSumSize = 0.0;
    self.transferedPhotosSize = 0.0;
    
    self.transferedPhotosNumber = 0;
    self.photosSumNumber = 0.0;
    
    [self setProgressLabelText];
}


-(void)startRequestWithPhotoPathArray {
    [self initProgress];
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%d", self.host, self.port];
    
    NSLog(@"urlString = %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Stop anything already in the queue before removing it
	[[self networkQueue] cancelAllOperations];
    
	// Creating a new queue each time we use it means we don't have to worry about clearing delegates or resetting progress tracking
	[self setNetworkQueue:[ASINetworkQueue queue]];
    
    [self.networkQueue setUploadProgressDelegate:self.progressIndicator];
	[[self networkQueue] setDelegate:self];
	[[self networkQueue] setRequestDidFinishSelector:@selector(requestFinished:)];
	[[self networkQueue] setRequestDidFailSelector:@selector(requestFailed:)];
	[[self networkQueue] setQueueDidFinishSelector:@selector(queueFinished:)];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *attributesError = nil;
    
    for (NSString *photoPath in self.photoPathArray) {
                
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:photoPath error:&attributesError];
        
        if (attributesError) {
            NSLog(@"attributesError = %@", attributesError);
            continue;
        }
        
        NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
        long long fileSize = [fileSizeNumber longLongValue];
        
        self.photosSumSize = self.photosSumSize + fileSize/(1024.0*1024.0);
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        [request setFile:photoPath forKey:@"photo"];
        
        [[self networkQueue] addOperation:request];
        
    }
    
	[[self networkQueue] go];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.photosSumNumber = [self.photoPathArray count];
    
    [self setProgressLabelText];
}

-(void)startRequestWithPhotos:(NSMutableArray *)photos {
    
    [self initProgress];
   
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%d", self.host, self.port];
    
    NSLog(@"urlString = %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Stop anything already in the queue before removing it
	[[self networkQueue] cancelAllOperations];
    
	// Creating a new queue each time we use it means we don't have to worry about clearing delegates or resetting progress tracking
	[self setNetworkQueue:[ASINetworkQueue queue]];
    
    [self.networkQueue setUploadProgressDelegate:self.progressIndicator];
	[[self networkQueue] setDelegate:self];
	[[self networkQueue] setRequestDidFinishSelector:@selector(requestFinished:)];
	[[self networkQueue] setRequestDidFailSelector:@selector(requestFailed:)];
	[[self networkQueue] setQueueDidFinishSelector:@selector(queueFinished:)];
        
    for (NSDictionary *photoInfo in photos) {
        
        self.photosSumSize = self.photosSumSize + [[photoInfo objectForKey:kImageSize] floatValue];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        [request setData:[photoInfo objectForKey:kImageData] withFileName:[photoInfo objectForKey:kImageName] andContentType:[photoInfo objectForKey:kImageType]  forKey:@"photo"];
                
        [[self networkQueue] addOperation:request];
        
    }
    
	[[self networkQueue] go];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;    
    
    self.photosSumNumber = [photos count];
    
    [self setProgressLabelText];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	// You could release the queue here if you wanted
	if ([[self networkQueue] requestsCount] == 0) {
        
		// Since this is a retained property, setting it to nil will release it
		// This is the safest way to handle releasing things - most of the time you only ever need to release in your accessors
		// And if you an Objective-C 2.0 property for the queue (as in this example) the accessor is generated automatically for you
		[self setNetworkQueue:nil];
	}
    
	//... Handle success
	NSLog(@"Request finished");
    
  //  NSLog(@"responseString = %@", [request responseString]);
    
    self.transferedPhotosNumber = self.transferedPhotosNumber + 1;
    self.transferedPhotosSize = self.photosSumSize * self.progressIndicator.progress;
    
    [self setProgressLabelText];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	// You could release the queue here if you wanted
	if ([[self networkQueue] requestsCount] == 0) {
		[self setNetworkQueue:nil];
	}
    
	//... Handle failure
	NSLog(@"Request failed");
    
    self.isRequestFailed = YES;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Failed to send photos", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    [alertView release];
}


- (void)queueFinished:(ASINetworkQueue *)queue
{
	// You could release the queue here if you wanted
	if ([[self networkQueue] requestsCount] == 0) {
		[self setNetworkQueue:nil];
	}
	NSLog(@"Queue finished");
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    if (!self.isRequestFailed) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Send Photos Success", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        [alertView release];
    }
}

-(NSString *)getImageTypeFromUTI:(NSString *)uti {
    
    NSLog(@"uti = %@", uti);
    
    if ([uti isEqualToString:@"public.png"]) {
        
        return @"image/png";
    }
    
    if ([uti isEqualToString:@"public.jpeg"]) {
        
        return @"image/jpeg";
    }
    return nil;
}

-(void)processChoosedPhotos:(NSArray *)info {
    
    NSError *error = nil;
    
    NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:[info count]];
    for (ALAsset *result in info) {
        
        if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
        
            ALAssetRepresentation* representation = [result defaultRepresentation];
            // create a buffer to hold the data for the asset's image
            uint8_t *buffer = (Byte*)malloc(representation.size);// copy the data from the asset into the buffer
            NSUInteger length = [representation getBytes:buffer fromOffset: 0.0  length:representation.size error:&error];
            
            if (length == 0) {
                
                NSLog(@"error = %@", [error description]);
                free(buffer);
                continue;
            }
        
            // convert the buffer into a NSData object, free the buffer after
            
            NSData *photoData = [[NSData alloc] initWithBytesNoCopy:buffer length:representation.size freeWhenDone:YES];
            
            // setup a dictionary with a UTI hint.  The UTI hint identifies the type of image we are dealing with (ie. a jpeg, png, or a possible RAW file)
            
            // specify the source hint
          
            NSString *imageType = [self getImageTypeFromUTI:[representation UTI]];
            
            float imageSize = representation.size/(1024.0*1024.0);
            
            NSLog(@"imageSize = %f", imageSize);
            
            NSDictionary *photoInfo = [[NSDictionary alloc] initWithObjectsAndKeys: imageType,kImageType, photoData, kImageData,[representation filename], kImageName,[NSNumber numberWithFloat:imageSize] ,kImageSize, nil];
            

            [photos addObject:photoInfo];
            

            [photoData release];
            [photoInfo release];
         
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self startRequestWithPhotos:photos];
        
        [photos release];
        
    });
}

-(void)addPhotosAction:(id)sender {
    AGImagePickerController *imagePickerController = [[AGImagePickerController alloc] initWithFailureBlock:^(NSError *error) {
        
        if (error == nil)
        {
            NSLog(@"User has cancelled.");
            [self dismissModalViewControllerAnimated:YES];
        } else
        {
            NSLog(@"Error: %@", error);
            
            // Wait for the view controller to show first and hide it after that
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self dismissModalViewControllerAnimated:YES];
            });
        }
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        
    } andSuccessBlock:^(NSArray *info) {
        
        dispatch_queue_t processPhotosQueue = dispatch_queue_create("com.yujianjun.processPhotosQueue", NULL
                                                                    );
        
        dispatch_async(processPhotosQueue, ^{
            
            [self processChoosedPhotos:info];
        });
        
        
        [self dismissModalViewControllerAnimated:YES];
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        
        
    }];
        
    [self presentModalViewController:imagePickerController animated:YES];
    [imagePickerController release];
    
}


- (void)viewDidUnload
{
    [self setProgressIndicator:nil];
    [self setPhotosNumberProgressLabel:nil];
    [self setPhotosSizeProgressLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [progressIndicator release];
    [_networkQueue cancelAllOperations];
    [_networkQueue release];
    [photosNumberProgressLabel release];
    [photosSizeProgressLabel release];
    [_host release];
    [_photoPathArray release];
    [super dealloc];
}
@end
