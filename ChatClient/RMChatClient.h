//
//  RMChatClient.h
//  ChatClient
//
//  Created by Robert Mooney on 05/07/2012.
//  Copyright (c) 2012 Robert Mooney. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RMMessage;
@protocol RMChatClientDelegate;

#pragma mark -

@interface RMChatClient : NSObject

@property (weak, nonatomic) id <RMChatClientDelegate> delegate;
@property (strong, nonatomic, readonly) NSString *username;
@property (assign, nonatomic, readonly, getter = isConnected) BOOL connected;

- (id)initWithUsername:(NSString *)username;
- (void)connect;
- (void)sendText:(NSString *)text;
- (void)disconnect;

@end

#pragma mark -

@protocol RMChatClientDelegate <NSObject>

@required
- (void)chatClientDidConnect:(RMChatClient *)chatClient;
- (void)chatClient:(RMChatClient *)chatClient didSendMessage:(RMMessage *)message;
- (void)chatClient:(RMChatClient *)chatClient didReceiveMessage:(RMMessage *)message;
- (void)chatClient:(RMChatClient *)chatClient didReceiveError:(NSError *)error;
- (void)chatClientDidDisconnect:(RMChatClient *)chatClient;

@end