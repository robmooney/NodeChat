//
//  RMChatViewController.h
//  ChatClient
//
//  Created by Robert Mooney on 06/07/2012.
//  Copyright (c) 2012 Robert Mooney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RMChatViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

- (IBAction)sendMessage:(id)sender;
- (IBAction)hideKeyboard:(id)sender;

@end
