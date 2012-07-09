//
//  RMChatClient.m
//  ChatClient
//
//  Created by Robert Mooney on 05/07/2012.
//  Copyright (c) 2012 Robert Mooney. All rights reserved.
//

#import "RMChatClient.h"
#import "RMMessage.h"

#define SERVER_HOST "Robs-MacBook-Air.local"

@interface RMChatClient () <NSStreamDelegate>

@property (strong, nonatomic) NSInputStream *inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;
@property (strong, nonatomic) RMMessage *outgoingMessage;

@end

@implementation RMChatClient

@synthesize delegate = _delegate;
@synthesize username = _username;
@synthesize connected = _connected;

@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;

@synthesize outgoingMessage = _outgoingMessage;

- (id)initWithUsername:(NSString *)username
{
    NSParameterAssert(username);
    self = [super init];
    if (self) {
        _username = username;
    }
    return self;
}

- (id)init
{
    // will throw exception
    return [self initWithUsername:nil];
}

- (void)connect
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    CFStreamCreatePairWithSocketToHost(NULL, CFSTR(SERVER_HOST), 4000, &readStream, &writeStream);
    
    NSInputStream *inputStream = (__bridge_transfer NSInputStream *)readStream;
    NSOutputStream *outputStream = (__bridge_transfer NSOutputStream *)writeStream;    
    
    inputStream.delegate = self;
    outputStream.delegate = self;
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    [outputStream open];
    
    self.inputStream = inputStream;
    self.outputStream = outputStream; 
    
    NSData *messageData = [[self.username stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding];        
    [self.outputStream write:messageData.bytes maxLength:messageData.length]; 
    
    _connected = YES;
}

- (void)disconnect
{    
    [self.inputStream close];
    [self.outputStream close];    
    [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] 
                                forMode:NSDefaultRunLoopMode];    
    [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] 
                                 forMode:NSDefaultRunLoopMode];    
    self.inputStream = nil;
    self.outputStream = nil;
    
    _connected = NO;
    [self.delegate chatClientDidDisconnect:self];
}

- (void)sendText:(NSString *)text
{
    if (self.isConnected) {        
        RMMessage *message = [[RMMessage alloc] initWithString:[NSString stringWithFormat:@"%@:%@\n", self.username, text]];
        message.type = RMMessageTypeUser;
        self.outgoingMessage = message;
               
        NSData *messageData = [[text stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding];        
        [self.outputStream write:messageData.bytes maxLength:messageData.length]; 
    }   
}

#pragma mark - Stream delegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    
    if (eventCode & NSStreamEventOpenCompleted) {
        if (aStream == self.outputStream) {            
            [self.delegate chatClientDidConnect:self];
        }
    }
    
    if (eventCode & NSStreamEventHasSpaceAvailable) {
        if (self.outgoingMessage) {
            [self.delegate chatClient:self didSendMessage:self.outgoingMessage];
            self.outgoingMessage = nil;
        }
    }
    
    if (eventCode & NSStreamEventHasBytesAvailable) {    
        //read data
        uint8_t buffer[1024];
        int len;
        while (self.inputStream.hasBytesAvailable) {
            len = [self.inputStream read:buffer maxLength:sizeof(buffer)];
            if (len > 0) {
                NSData *messageData = [[NSData alloc] initWithBytes:buffer length:len];
                NSString *messageString = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];        
                
                RMMessage *message = [[RMMessage alloc] initWithString:messageString];
                
                if ([message.username isEqualToString:self.username]) {
                    message.type = RMMessageTypeUser;
                }
                
                [self.delegate chatClient:self didReceiveMessage:message];
            }
        }        
    }
    
    if (eventCode & NSStreamEventEndEncountered) {
        [self disconnect];
    }
    
    if (eventCode & NSStreamEventErrorOccurred) {
        [self.delegate chatClient:self didReceiveError:aStream.streamError];
        [self disconnect];
    }
}

@end
