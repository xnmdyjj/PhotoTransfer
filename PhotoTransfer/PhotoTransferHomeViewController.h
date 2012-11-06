//
//  PhotoTransferHomeViewController.h
//  PhotoTransfer
//
//  Created by Yu Jianjun on 9/19/12.
//  Copyright (c) 2012 Yu Jianjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StartHttpServiceViewController.h"
#import <iAd/iAd.h>


@interface PhotoTransferHomeViewController : UIViewController<StartHttpServiceViewControllerDelegate, ADBannerViewDelegate> {
    
     ADBannerView *_bannerView;
}


@property (nonatomic, retain) NSArray *dataArray;

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@end
