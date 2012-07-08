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

@end
