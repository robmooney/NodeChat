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

@interface RMChatViewController () <RMChatClientDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) RMChatClient *chatClient;
@property (strong, nonatomic) NSMutableArray *messages;

- (void)showJoinDialog;

@end

@implementation RMChatViewController

@synthesize tableView = _tableView;
@synthesize messageField = _messageField;
@synthesize toolbar = _toolbar;

@synthesize chatClient = _chatClient;
@synthesize messages = _messages;

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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Welcome to Node Chat!" 
                                                        message:@"Enter your nickname" 
                                                       delegate:self 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:@"Join", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeWords;
    [alertView show];    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark - Actions

- (IBAction)sendMessage:(id)sender
{
    [self.chatClient sendText:self.messageField.text];
    self.messageField.text = @"";
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
    
    switch (message.type) {
        case RMMessageTypeSystem:
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"SystemMessageCell"];
            break;
        case RMMessageTypeUser:
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"UserMessageCell"];
            break;
        case RMMessageTypeNormal:
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
            break;
    }
    
    cell.usernameLabel.text = message.username;
    cell.messageLabel.text = message.text;
    
    if (message.type == RMMessageTypeSystem) {    
        cell.messageLabel.frame = CGRectMake(20.0f, 11.0f, 280.0f, 21.0f);
    } else {    
        CGSize textSize = [message.text sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(280.0f, CGFLOAT_MAX)];
        cell.messageLabel.frame = CGRectMake(20.0f, 52.0f, 280.0f, textSize.height);
    }
    
    return cell;    
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RMMessage *message = [self.messages objectAtIndex:indexPath.row];
    
    switch (message.type) {
        case RMMessageTypeSystem:
            return 44.0f;
        case RMMessageTypeUser:
        case RMMessageTypeNormal: {
            CGSize textSize = [message.text sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(280.0f, CGFLOAT_MAX)];
            return 52.0f + textSize.height + 20.0f;
        }
    }
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *username = [alertView textFieldAtIndex:0].text;  
    
    if ([username length] && [username rangeOfString:@":"].location == NSNotFound) {
        self.chatClient = [[RMChatClient alloc] initWithUsername:username];
        self.chatClient.delegate = self;        
        [self.chatClient connect];
    } else {
        [self showJoinDialog];
    }   
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
    [self.messages addObject:message];
    
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
    [self.tableView scrollToRowAtIndexPath:messageIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([self.messages count] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];            
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
