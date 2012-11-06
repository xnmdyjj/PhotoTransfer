//
//  PhotoFileManager.m
//  PhotoTransfer
//
//  Created by Yu Jianjun on 10/6/12.
//  Copyright (c) 2012 Yu Jianjun. All rights reserved.
//

#import "PhotoFileManager.h"
#import "ServerInfo.h"
#import "SBJson.h"


@implementation PhotoFileManager


+(NSMutableArray *)getPhotoList {
    
    NSMutableArray *photoList = [NSMutableArray array];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSError * error = nil;
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    
    if (error) {
        NSLog(@"read photos failed:%@", [error description]);
        
        return photoList;
    }
    
    if ([directoryContent count]) {
        
        ServerInfo *sharedInstance = [ServerInfo sharedManager];
        NSString *serverUrlString = [NSString stringWithFormat:@"http://%@:%d", sharedInstance.host, sharedInstance.port];
        
        for (NSString *photoName in directoryContent) {
            
            if ([photoName isEqualToString:@"index.html"] || [photoName isEqualToString:@".DS_Store"]) {
                continue;
            }
            
            NSString *photoUrlString = [serverUrlString stringByAppendingPathComponent:photoName];
            
            [photoList addObject:photoUrlString];
            
        }
        
        return photoList;
    }
    return photoList;
}


@end
