//
//  RMMessage.m
//  ChatClient
//
//  Created by Robert Mooney on 07/07/2012.
//  Copyright (c) 2012 Robert Mooney. All rights reserved.
//

#import "RMMessage.h"

@implementation RMMessage

@synthesize username = _username;
@synthesize text = _text;
@synthesize type = _type;
@synthesize followOn = _followOn;

- (id)initWithString:(NSString *)string
{
    self = [super init];
    if (self) {
        NSArray *messageComponents = [string componentsSeparatedByString:@":"];
        _username = [messageComponents objectAtIndex:0];
        _text = [[messageComponents subarrayWithRange:NSMakeRange(1, [messageComponents count] - 1)] componentsJoinedByString:@":"];
        
        if ([_username isEqualToString:@""]) {
            _type = RMMessageTypeSystem;
        }
    }
    return self;
}

- (NSString *)description
{
    NSString *username;
    
    if (self.isFollowOn) {
        username = @">";
    } else if (_type == RMMessageTypeSystem) {
        username = @"[system]";
    } else {
        username = [NSString stringWithFormat:@"[%@]", _username];
    }
    
    return [NSString stringWithFormat:@"%@ %@", username, _text];
}

@end
