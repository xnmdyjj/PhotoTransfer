//
//  BrowseOnlinePhotosViewController.h
//  PhotoTransfer
//
//  Created by Yu Jianjun on 10/4/12.
//  Copyright (c) 2012 Yu Jianjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "asihttprequest/ASIHTTPRequest.h"
#import "MWPhotoBrowser.h"

@interface BrowseOnlinePhotosViewController : UIViewController<MWPhotoBrowserDelegate>
@property (retain, nonatomic) IBOutlet UITableView *photoListTableView;

@property (retain, nonatomic) NSArray *photoList;

@property (retain, nonatomic) ASIHTTPRequest *photoListRequest;

@property (nonatomic, retain) NSString *host;

@property (nonatomic, assign) UInt16 port;

@property (nonatomic, retain) NSMutableArray *mwPhotos;

@property (nonatomic, retain) NSString *hostName;

@end
