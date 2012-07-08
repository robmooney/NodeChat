//
//  RMMessage.h
//  ChatClient
//
//  Created by Robert Mooney on 07/07/2012.
//  Copyright (c) 2012 Robert Mooney. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    RMMessageTypeNormal,
    RMMessageTypeUser,
    RMMessageTypeSystem,
} RMMessageType;

@interface RMMessage : NSObject

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *text;
@property (assign, nonatomic) RMMessageType type;

- (id)initWithString:(NSString *)string;

@end
