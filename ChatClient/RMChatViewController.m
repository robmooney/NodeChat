//
//  RMChatViewController.m
//  ChatClient
//
//  Created by Robert Mooney on 06/07/2012.
//  Copyright (c) 2012 Robert Mooney. All rights reserved.
//

#import "RMChatViewController.h"
#import "RMChatClient.h"
#import "RMMessageCell.h"
#import "RMMessage.h"


#pragma mark Private interface

@interface RMChatViewController () <RMChatClientDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) RMChatClient *chatClient;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) RMMessage *previousMessage;
@property (strong, nonatomic) UIAlertView *joinDialog;

- (void)showJoinDialog;
- (void)scrollMessagesToEnd;
- (CGSize)messageLabelSizeForText:(NSString *)text;
- (void)joinChatWithUsername:(NSString *)username;
- (void)sendMessageAndUpdateUI;

@end

#pragma mark - Implementation

@implementation RMChatViewController

@synthesize tableView = _tableView;
@synthesize messageField = _messageField;
@synthesize toolbar = _toolbar;
@synthesize sendButton = _sendButton;

@synthesize chatClient = _chatClient;
@synthesize messages = _messages;
@synthesize previousMessage = _previousMessage;
@synthesize joinDialog = _joinDialog;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    

    if (!self.chatClient) {  
        [self showJoinDialog];
    }
    
    if (!self.messages) {
        self.messages = [NSMutableArray array];
    }
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];    
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)showJoinDialog
{   
    self.joinDialog = [[UIAlertView alloc] initWithTitle:@"Welcome to Node Chat!" 
                                                        message:@"Enter your nickname" 
                                                       delegate:self 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:@"Join", nil];
    self.joinDialog.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [self.joinDialog textFieldAtIndex:0];
    textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    textField.autocorrectionType = UITextAutocorrectionTypeDefault;
    textField.returnKeyType = UIReturnKeyJoin;
    textField.delegate = self;
    [self.joinDialog show];
}

- (void)scrollMessagesToEnd
{
    if ([self.messages count]) {        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([self.messages count] - 1) inSection:0] 
                              atScrollPosition:UITableViewScrollPositionBottom 
                                      animated:YES];
    }
}


- (CGSize)messageLabelSizeForText:(NSString *)text
{
    return [text sizeWithFont:[UIFont systemFontOfSize:17.0f] constrainedToSize:CGSizeMake(200.0f, CGFLOAT_MAX)];
}


- (void)joinChatWithUsername:(NSString *)username
{
    self.chatClient = [[RMChatClient alloc] initWithUsername:username];
    self.chatClient.delegate = self;        
    [self.chatClient connect];
}

- (void)sendMessageAndUpdateUI
{
    [self.chatClient sendText:self.messageField.text];
    self.messageField.text = @"";
    self.sendButton.enabled = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark - Actions

- (IBAction)sendMessage:(id)sender
{
    [self sendMessageAndUpdateUI];
}

- (IBAction)hideKeyboard:(id)sender
{
    [self.messageField resignFirstResponder];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RMMessageCell *cell;    
    RMMessage *message = [self.messages objectAtIndex:indexPath.row]; 
    CGFloat offset = 0.0f;
    
    if (message.isFollowOn) {
        offset = -33.0f;
    }
    
    CGSize textSize;
    
    switch (message.type) {
        case RMMessageTypeSystem:
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"SystemMessageCell"];
            cell.messageLabel.frame = CGRectMake(20.0f, 11.0f, 280.0f, 21.0f);
            break;
        case RMMessageTypeUser:
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"UserMessageCell"];            
            textSize = [self messageLabelSizeForText:message.text];
            cell.messageLabel.frame = CGRectMake(295.0f - textSize.width, 52.0f + offset, textSize.width, textSize.height);
            cell.bubbleImageView.frame = CGRectMake(280.0f - textSize.width, 33.0f + offset, textSize.width + 30.0f, textSize.height + 32.0f);
            break;
        case RMMessageTypeNormal:
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
            textSize = [self messageLabelSizeForText:message.text];
            cell.messageLabel.frame = CGRectMake(25.0f, 52.0f + offset, textSize.width, textSize.height);
            cell.bubbleImageView.frame = CGRectMake(10.0f, 33.0f + offset, textSize.width + 30.0f, textSize.height + 32.0f);
            break;
    }
    
    cell.usernameLabel.text = message.username;
    cell.messageLabel.text = message.text;
    
    cell.usernameLabel.hidden = message.isFollowOn;
    
    return cell;    
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RMMessage *message = [self.messages objectAtIndex:indexPath.row];
    
    CGFloat offset = 0.0f;
    
    if (message.isFollowOn) {
        offset = -33.0f;
    }
    
    switch (message.type) {
        case RMMessageTypeSystem:
            return 44.0f;
        case RMMessageTypeUser:
        case RMMessageTypeNormal: {
            CGSize textSize = [self messageLabelSizeForText:message.text];
            return 52.0f + offset + textSize.height + 20.0f;
        }
    }
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *username = [alertView textFieldAtIndex:0].text;  
    
    if ([username length] && [username rangeOfString:@":"].location == NSNotFound) {
        [self joinChatWithUsername:username];
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.messageField becomeFirstResponder];
        });
        
    } else {
        [self showJoinDialog];
    }   
}

#pragma mark - Text field delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{    
    if (textField == self.messageField) {  
        // empty string + range.location == 0 denotes first character being deleted, disable send, otherwise enable
        self.sendButton.enabled = ([string length] + range.location) ? YES : NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.messageField) {        
        [self sendMessageAndUpdateUI];
    } else {
        NSString *username = [self.joinDialog textFieldAtIndex:0].text;  
        [self.joinDialog dismissWithClickedButtonIndex:0 animated:YES];
         
         if ([username length] && [username rangeOfString:@":"].location == NSNotFound) {
             [self joinChatWithUsername:username];
             
             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC);
             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                 [self.messageField becomeFirstResponder];
             });
         } else {
             [self showJoinDialog];
         }   
    }
    return NO;
}

#pragma mark - Chat client delegate

- (void)chatClientDidConnect:(RMChatClient *)chatClient
{
    NSLog(@"Joined chat!");
}

- (void)chatClient:(RMChatClient *)chatClient didSendMessage:(RMMessage *)message
{
    NSLog(@"Message sent!");
}

- (void)chatClient:(RMChatClient *)chatClient didReceiveMessage:(RMMessage *)message
{
    if (self.previousMessage) {
        if ([self.previousMessage.username isEqualToString:message.username]) {
            message.followOn = YES;
        }
    }    
    
    [self.messages addObject:message];
    
    self.previousMessage = message;
    
    UITableViewRowAnimation rowAnimation;
    
    switch (message.type) {
        case RMMessageTypeSystem:
            rowAnimation = UITableViewRowAnimationFade;
            break;
        case RMMessageTypeUser:
            rowAnimation = UITableViewRowAnimationRight;
            break;
        case RMMessageTypeNormal:
            rowAnimation = UITableViewRowAnimationLeft;
            break;
    }
    
    NSIndexPath *messageIndexPath = [NSIndexPath indexPathForRow:([self.messages count] - 1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:messageIndexPath] 
                          withRowAnimation:rowAnimation];
    [self scrollMessagesToEnd];
}

- (void)chatClient:(RMChatClient *)chatClient didReceiveError:(NSError *)error
{
    NSLog(@"%@", error);
    
    [[[UIAlertView alloc] initWithTitle:@"Error" 
                                message:[error localizedDescription] 
                               delegate:nil 
                      cancelButtonTitle:@"OK" 
                      otherButtonTitles:nil] show];
}

- (void)chatClientDidDisconnect:(RMChatClient *)chatClient
{    
    NSLog(@"Left chat!");
}

#pragma mark - Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    if (self.messageField.isFirstResponder) {
        
        NSTimeInterval animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationCurve animationCurve = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] intValue];
        CGRect keyboardFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        [UIView animateWithDuration:animationDuration delay:0.0 options:animationCurve animations:^ {
            self.tableView.frame = UIEdgeInsetsInsetRect(self.tableView.frame, UIEdgeInsetsMake(0.0f, 0.0f, keyboardFrame.size.height, 0.0));
            self.toolbar.frame = CGRectOffset(self.toolbar.frame, 0.0f, -keyboardFrame.size.height);
        } completion:^ (BOOL finished) {
            [self scrollMessagesToEnd];            
        }];  
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (self.messageField.isFirstResponder) {
        NSTimeInterval animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationCurve animationCurve = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] intValue];
        CGRect keyboardFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        [UIView animateWithDuration:animationDuration delay:0.0 options:animationCurve animations:^ {
            self.tableView.frame = UIEdgeInsetsInsetRect(self.tableView.frame, UIEdgeInsetsMake(0.0f, 0.0f, -keyboardFrame.size.height, 0.0));
            self.toolbar.frame = CGRectOffset(self.toolbar.frame, 0.0f, keyboardFrame.size.height);
        } completion:NULL];   
    }
}

@end
