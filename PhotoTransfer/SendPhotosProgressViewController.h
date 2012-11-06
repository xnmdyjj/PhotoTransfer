//
//  SendPhotosProgressViewController.h
//  PhotoTransfer
//
//  Created by Yu Jianjun on 9/20/12.
//  Copyright (c) 2012 Yu Jianjun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AGImagePickerController.h"
#import "asihttprequest/ASIFormDataRequest.h"
#import "asihttprequest/ASINetworkQueue.h"

@interface SendPhotosProgressViewController : UIViewController 

@property (nonatomic, retain) NSString *host;

@property (nonatomic, assign) UInt16 port;

@property (nonatomic, retain) NSMutableArray *photoPathArray;

@property (retain, nonatomic) IBOutlet UIProgressView *progressIndicator;

@property (retain, nonatomic) ASINetworkQueue *networkQueue;

@property (nonatomic, assign) float photosSumSize;

@property (nonatomic, assign) float transferedPhotosSize;

@property (nonatomic, assign) NSInteger photosSumNumber;
@property (nonatomic, assign) NSInteger transferedPhotosNumber;

@property (retain, nonatomic) IBOutlet UILabel *photosNumberProgressLabel;
@property (retain, nonatomic) IBOutlet UILabel *photosSizeProgressLabel;

@property (nonatomic, assign) BOOL isRequestFailed;


@end
