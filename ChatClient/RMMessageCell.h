//
//  RMMessageCell.h
//  ChatClient
//
//  Created by Robert Mooney on 07/07/2012.
//  Copyright (c) 2012 Robert Mooney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RMMessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bubbleImageView;

@end
