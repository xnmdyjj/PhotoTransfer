//
//  SendPhotosViewController.h
//  PhotoTransfer
//
//  Created by Yu Jianjun on 9/19/12.
//  Copyright (c) 2012 Yu Jianjun. All rights reserved.
//

#import <UIKit/UIKit.h>


@class GCDAsyncSocket;


@interface SearchDeviceViewController : UIViewController <NSNetServiceBrowserDelegate, NSNetServiceDelegate>{
    
    NSNetServiceBrowser *netServiceBrowser;
    
    // Keeps track of available services
    NSMutableArray *services;
    
    
    NSNetService *service;
    
    // Keeps track of search status
    BOOL searching;
    
    
    NSMutableArray *serverAddresses;
	GCDAsyncSocket *asyncSocket;
	BOOL connected;

}

@property (retain, nonatomic) IBOutlet UITableView *localServersTableView;
@property (retain, nonatomic) NSMutableArray *photoPathArray;

@property (retain, nonatomic) IBOutlet UIView *headerView;

@property (retain, nonatomic) IBOutlet UILabel *searchingLabel;

@property (nonatomic, assign) BOOL isBrowsePhotos;
@end
