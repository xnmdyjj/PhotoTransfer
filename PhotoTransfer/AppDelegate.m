//
//  AppDelegate.m
//  PhotoTransfer
//
//  Created by Yu Jianjun on 9/19/12.
//  Copyright (c) 2012 Yu Jianjun. All rights reserved.
//

#import "AppDelegate.h"
#import "PhotoTransferHomeViewController.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [super dealloc];
}

// Creates a writable copy of the bundled default database in the application Documents directory.
- (void)createIndexHtmlIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSLog(@"documentsDirectory = %@", documentsDirectory);
      
    NSString *indexHtmlPath = [documentsDirectory stringByAppendingPathComponent:@"index.html"];
    success = [fileManager fileExistsAtPath:indexHtmlPath];
    if (success)
        return;
 
    NSString *defaultIndexHtmlPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"index.html"];
    
    success = [fileManager copyItemAtPath:defaultIndexHtmlPath toPath:indexHtmlPath error:&error];
    
    if (!success) {
        
        NSLog(@"copy index html file to documents directory failed:%@", [error description]);
        
        return;
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    PhotoTransferHomeViewController *controller = [[PhotoTransferHomeViewController alloc] initWithNibName:@"PhotoTransferHomeViewController" bundle:nil];

    UINavigationController *aNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    self.navigationController = aNavigationController;
    
    self.window.rootViewController = self.navigationController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [controller release];
    [aNavigationController release];
    

    [self createIndexHtmlIfNeeded];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
