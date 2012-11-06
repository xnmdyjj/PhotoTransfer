//
//  ReceivePhotosViewController.h
//  PhotoTransfer
//
//  Created by Yu Jianjun on 9/19/12.
//  Copyright (c) 2012 Yu Jianjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HTTPServer;

@protocol StartHttpServiceViewControllerDelegate <NSObject>

@optional

-(void)dismissReceivePhotosViewController;

@end

@interface StartHttpServiceViewController : UIViewController {
    
    HTTPServer *httpServer;
}
@property (retain, nonatomic) IBOutlet UITableView *receiveTableView;

@property (retain, nonatomic) NSString *serverUrlString;

@property (assign, nonatomic) id<StartHttpServiceViewControllerDelegate> delegate;

@end
