//
//  ServerInfo.h
//  PhotoTransfer
//
//  Created by Yu Jianjun on 10/6/12.
//  Copyright (c) 2012 Yu Jianjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerInfo : NSObject

@property (nonatomic, retain) NSString *host;
@property (nonatomic, assign) NSInteger port;

+ (id)sharedManager;

@end
