//
//  ShowAlert.h
//  sohoto
//
//  Created by heyo on 12-7-31.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define TEXT_FIELD_TAG    9999
#define kDismissAlertDelay 2 //s

//OK cancel alert view
#define kOkCancelAlertOk 1
#define kOkCancelAlertCancel 0

@interface NSObject (ShowAlert)
- (void)showAlertMessage:(NSString *)msg;
- (void)dimissAlert:(UIAlertView *)alertView;
- (void)showAlertMessage:(NSString *)msg dismissAfterDelay:(NSTimeInterval)delay;
- (void)showAlertMessage:(NSString *)msg title:(NSString *)title tag:(NSInteger)tag delegate:(id)delegate;
- (void)showAlertMessageWithOkButton:(NSString *)msg title:(NSString *)title tag:(NSInteger)tag delegate:(id)delegate;
- (void)showAlertMessageWithOkCancelButton:(NSString *)msg title:(NSString *)title tag:(NSInteger)tag delegate:(id)delegate;
- (void)showTextFieldAlertWithOkCancelButton:(NSString *)title tag:(NSInteger)tag delegate:(id)delegate defaultValue:(NSString *)defaultValue placeHolder:(NSString *)placeHolder;
- (void)showPasswordFieldAlertWithOkCancelButton:(NSString *)title tag:(NSInteger)tag delegate:(id)delegate;
@end
