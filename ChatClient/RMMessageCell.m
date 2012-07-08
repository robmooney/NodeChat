//
//  RMMessageCell.m
//  ChatClient
//
//  Created by Robert Mooney on 07/07/2012.
//  Copyright (c) 2012 Robert Mooney. All rights reserved.
//

#import "RMMessageCell.h"

@implementation RMMessageCell

@synthesize usernameLabel = _usernameLabel;
@synthesize messageLabel = _messageLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
