//
//  ReceivedPhotosViewController.h
//  PhotoTransfer
//
//  Created by Yu Jianjun on 9/22/12.
//  Copyright (c) 2012 Yu Jianjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@interface ReceivedPhotosViewController : UITableViewController <MWPhotoBrowserDelegate, UIActionSheetDelegate>

@property (nonatomic, retain) NSMutableArray *photos;

@property (nonatomic, retain) NSMutableArray *mwPhotos;

@property (nonatomic, retain) UIBarButtonItem *actionButton;

@property (nonatomic, retain) UIBarButtonItem *cancelButton;

@end
