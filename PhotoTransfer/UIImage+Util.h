//
//  UIImage+Util.h
//  InCity
//
//  Created by  on 12-4-12.
//  Copyright (c) 2012年 Cybercom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage(Util)

- (UIImage *)croppedImage:(CGRect)bounds;
- (UIImage*)scaleToSize:(CGSize)size;

-(UIImage*)resizedImageToSize:(CGSize)dstSize;

@end
