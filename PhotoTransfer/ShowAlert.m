//
//  ShowAlert.m
//  sohoto
//
//  Created by heyo on 12-7-31.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ShowAlert.h"

@implementation NSObject (ShowAlert)

- (void)showAlertMessage:(NSString *)msg {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:nil//NSLocalizedString(@"Notice", nil)
                              message:msg
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (void)dimissAlert:(UIAlertView *)alertView {
    if (alertView) {
        [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:YES];
        //[alertView release];
    }
}

// never show more than one auto dismiss alert at same time, it will cause crash
- (void)showAlertMessage:(NSString *)msg dismissAfterDelay:(NSTimeInterval)delay {
    UIAlertView *alertView = [[[UIAlertView alloc]
                               initWithTitle:nil//NSLocalizedString(@"Notice", nil)
                               message:nil
                               delegate:nil
                               cancelButtonTitle:nil
                               otherButtonTitles:nil] autorelease];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 260.0f, 40.0f)];
    label.numberOfLines = 2; // if the text too long, the alert view should not be dismissed automatic.
    label.text = msg;
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    // Show alert and wait for it to finish displaying
    [alertView show];
    while (CGRectEqualToRect(alertView.bounds, CGRectZero));
    
    // Find the center for the text field and add it
    CGRect bounds = alertView.bounds;
    label.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f - 5.0);
    [alertView addSubview:label];
    [label release];
    [alertView show];
    [self performSelector:@selector(dimissAlert:) withObject:alertView afterDelay:delay];
}

- (void)showAlertMessage:(NSString *)msg title:(NSString *)title tag:(NSInteger)tag delegate:(id)delegate {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:title
                              message:msg
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"取消", nil)
                              otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
    alertView.tag = tag;
    alertView.delegate = delegate;
    [alertView show];
    [alertView release];
}

- (void)showAlertMessageWithOkButton:(NSString *)msg title:(NSString *)title tag:(NSInteger)tag delegate:(id)delegate {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:title
                              message:msg
                              delegate:delegate
                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
                              otherButtonTitles:nil];
    alertView.tag = tag;
    alertView.delegate = delegate;
    [alertView show];
    [alertView release];
}

- (void)showAlertMessageWithOkCancelButton:(NSString *)msg title:(NSString *)title tag:(NSInteger)tag delegate:(id)delegate {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:title
                              message:msg
                              delegate:delegate
                              cancelButtonTitle:NSLocalizedString(@"取消", nil)
                              otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
    alertView.tag = tag;
    [alertView show];
    [alertView release];
}

- (void)showTextFieldAlertWithOkCancelButton:(NSString *)title tag:(NSInteger)tag delegate:(id)delegate defaultValue:(NSString *)defaultValue placeHolder:(NSString *)placeHolder{
    // Create alert
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:@"\n\n"
                                                       delegate:delegate
                                              cancelButtonTitle:NSLocalizedString(@"取消", nil)
                                              otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
    alertView.tag = tag;    
    // Build text field
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 260.0f, 30.0f)];
    tf.borderStyle = UITextBorderStyleRoundedRect;
    tf.tag = TEXT_FIELD_TAG;
    tf.text = defaultValue;
    tf.placeholder = placeHolder;
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    tf.keyboardType = UIKeyboardTypePhonePad;
    tf.keyboardAppearance = UIKeyboardAppearanceAlert;
    tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    // Show alert and wait for it to finish displaying
    [alertView show];
    while (CGRectEqualToRect(alertView.bounds, CGRectZero));
    
    // Find the center for the text field and add it
    CGRect bounds = alertView.bounds;
    tf.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f - 10.0f);
    [alertView addSubview:tf];
    //    [tf becomeFirstResponder];
    [tf release];
    [alertView release];
}


- (void)showPasswordFieldAlertWithOkCancelButton:(NSString *)title tag:(NSInteger)tag delegate:(id)delegate
{
    // Create alert
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:@"\n\n"
                                                       delegate:delegate
                                              cancelButtonTitle:NSLocalizedString(@"取消", nil)
                                              otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
    alertView.tag = tag;    
    // Build text field
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 260.0f, 30.0f)];
    tf.borderStyle = UITextBorderStyleRoundedRect;
    tf.tag = TEXT_FIELD_TAG;
    tf.clearButtonMode = UITextFieldViewModeNever;
    tf.keyboardType = UIKeyboardTypeDefault;
    tf.returnKeyType = UIReturnKeyDone;
    tf.keyboardAppearance = UIKeyboardAppearanceAlert;
    tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    tf.secureTextEntry = YES;
    // Show alert and wait for it to finish displaying
    [alertView show];
    while (CGRectEqualToRect(alertView.bounds, CGRectZero));
    
    // Find the center for the text field and add it
    CGRect bounds = alertView.bounds;
    tf.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f - 10.0f);
    [alertView addSubview:tf];
    //    [tf becomeFirstResponder];
    [tf release];
    [alertView release];

}

@end
