//
//  ServerInfo.m
//  PhotoTransfer
//
//  Created by Yu Jianjun on 10/6/12.
//  Copyright (c) 2012 Yu Jianjun. All rights reserved.
//

#import "ServerInfo.h"

static ServerInfo *sharedMyManager = nil;

@implementation ServerInfo

#pragma mark Singleton Methods
+ (id)sharedManager {
    @synchronized(self) {
        if(sharedMyManager == nil)
            sharedMyManager = [[super allocWithZone:NULL] init];
    }
    return sharedMyManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedManager] retain];
}
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
- (id)retain {
    return self;
}
- (unsigned)retainCount {
    return UINT_MAX; //denotes an object that cannot be released
}
- (oneway void)release {
    // never release
}
- (id)autorelease {
    return self;
}
- (id)init {
    if (self = [super init]) {
        
        
    }
    return self;
}

-(void)dealloc {
    [_host release];
    [super dealloc];
}
@end
