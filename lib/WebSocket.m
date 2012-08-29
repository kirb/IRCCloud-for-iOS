//
//  WebSocket.m
//  UnittWebSocketClient
//
//  Created by Josh Morris on 9/26/11.
//  Copyright 2011 UnitT Software. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License. You may obtain a copy of
//  the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

#import "WebSocket.h"
#import "WebSocketFragment.h"
#import "HandshakeHeader.h"


enum 
{
    WebSocketWaitingStateMessage = 0, //Starting on waiting for a new message
    WebSocketWaitingStateHeader = 1, //Waiting for the remaining header bytes
    WebSocketWaitingStatePayload = 2, //Waiting for the remaining payload bytes
    WebSocketWaitingStateFragment = 3 //Waiting for the next fragment
};
typedef NSUInteger WebSocketWaitingState;


@interface WebSocket(Private)
- (void) dispatchFailure:(NSError*) aError;
- (void) dispatchClosed:(NSUInteger) aStatusCode message:(NSString*) aMessage error:(NSError*) aError;
- (void) dispatchOpened;
- (void) dispatchTextMessageReceived:(NSString*) aMessage;
- (void) dispatchBinaryMessageReceived:(NSData*) aMessage;
- (void) continueReadingMessageStream;
- (NSString*) buildOrigin;
- (NSString*) buildPort;
- (NSString*) getRequest: (NSString*) aRequestPath;
- (NSData*) getSHA1:(NSData*) aPlainText;
- (void) generateSecKeys;
- (NSString *)getExtensionsAsString:(NSArray *)aExtensions;
- (BOOL)supportsAnotherSupportedVersion:(NSString *)aResponse;
- (BOOL) isUpgradeResponse: (NSString*) aResponse;
- (NSMutableArray*) getServerExtensions:(NSMutableArray*) aServerHeaders;
- (BOOL) isValidServerExtension:(NSArray*) aServerExtensions;
- (void) sendClose:(NSUInteger) aStatusCode message:(NSString*) aMessage;
- (void) sendMessage:(NSData*) aMessage messageWithOpCode:(MessageOpCode) aOpCode;
- (void) sendMessage:(WebSocketFragment*) aFragment;
- (int) handleMessageData:(NSData*) aData offset:(NSUInteger) aOffset;
- (void) handleCompleteFragment:(WebSocketFragment*) aFragment;
- (void) handleCompleteFragments;
- (void) handleClose:(WebSocketFragment*) aFragment;
- (void) handlePing:(NSData*) aMessage;
- (void) closeSocket;
- (void) scheduleForceCloseCheck:(NSTimeInterval) aInterval;
- (void) checkClose:(NSTimer*) aTimer;
- (NSString*) buildStringFromHeaders:(NSMutableArray*) aHeaders resource:(NSString*) aResource;
- (NSMutableArray*) buildHeadersFromString:(NSString*) aHeaders;
- (HandshakeHeader*) headerForKey:(NSString*) aKey inHeaders:(NSMutableArray*) aHeaders;
- (NSArray*) headersForKey:(NSString*) aKey inHeaders:(NSMutableArray*) aHeaders;
@end


@implementation WebSocket

NSString* const WebSocketException = @"WebSocketException";
NSString* const WebSocketErrorDomain = @"WebSocketErrorDomain";

enum 
{
    TagHandshake = 0,
    TagMessage = 1
};

WebSocketWaitingState waitingState;

@synthesize config;
@synthesize delegate;
@synthesize readystate;

#pragma mark Public Interface
- (void) open
{
    UInt16 port = self.config.isSecure ? 443 : 80;
    if (self.config.url.port)
    {
        port = [self.config.url.port intValue];
    }
    NSError* error = nil;
    BOOL successful = false;
    @try 
    {
        successful = [socket connectToHost:self.config.url.host onPort:port error:&error];
        if (self.config.version == WebSocketVersion07)
        {
            closeStatusCode = WebSocketCloseStatusNormal;
        }
        else
        {
            closeStatusCode = 0;
        }
        closeMessage = nil;
    }
    @catch (NSException *exception) 
    {
        error = [NSError errorWithDomain:WebSocketErrorDomain code:0 userInfo:exception.userInfo]; 
    }
    @finally 
    {
        if (!successful)
        {
            [self dispatchClosed:WebSocketCloseStatusProtocolError message:nil error:error];
        }
    }
}

- (void) close
{
    [self close:WebSocketCloseStatusNormal message:nil];
}

- (void) close:(NSUInteger) aStatusCode message:(NSString*) aMessage
{
    readystate = WebSocketReadyStateClosing;
    //any rev before 10 does not perform a UTF8 check
    if (self.config.version < WebSocketVersion10)
    {
        [self sendClose:aStatusCode message:aMessage];        
    }
    else
    {
        if (aMessage && [aMessage canBeConvertedToEncoding:NSUTF8StringEncoding])
        {
            [self sendClose:aStatusCode message:aMessage];
        }
        else
        {
            [self sendClose:aStatusCode message:nil];
        }
    }
    isClosing = YES;
}

- (void) scheduleForceCloseCheck
{
    [NSTimer scheduledTimerWithTimeInterval:self.config.closeTimeout
                                     target:self
                                   selector:@selector(checkClose:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void) checkClose:(NSTimer*) aTimer
{
    if (self.readystate == WebSocketReadyStateClosing)
    {
        [self closeSocket];
    }
}

- (void) sendClose:(NSUInteger) aStatusCode message:(NSString*) aMessage
{
    //create payload
    NSMutableData* payload = nil;
    if (aStatusCode > 0)
    {
        closeStatusCode = aStatusCode;
        payload = [NSMutableData data];
        unsigned char current = (unsigned char)(aStatusCode/0x100);
        [payload appendBytes:&current length:1];
        current = (unsigned char)(aStatusCode%0x100);
        [payload appendBytes:&current length:1];
        if (aMessage)
        {
            closeMessage = aMessage;
            [payload appendData:[aMessage dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    //send close message
    [self sendMessage:[WebSocketFragment fragmentWithOpCode:MessageOpCodeClose isFinal:YES payload:payload]];
    
    //schedule the force close
    if (self.config.closeTimeout >= 0)
    {
        [self scheduleForceCloseCheck];
    }
}

- (void) sendText:(NSString*) aMessage
{
    //no reason to grab data if we won't send it anyways
    if (!isClosing)
    {        
        //only send non-nil data
        if (aMessage)
        {
            if ([aMessage canBeConvertedToEncoding:NSUTF8StringEncoding])
            {
                [self sendMessage:[aMessage dataUsingEncoding:NSUTF8StringEncoding] messageWithOpCode:MessageOpCodeText];       
            }
            else if (self.config.version >= WebSocketVersion10)
            {
                [self close:WebSocketCloseStatusInvalidData message:nil];
            }
        }
    }
}

- (void) sendBinary:(NSData*) aMessage
{
    [self sendMessage:aMessage messageWithOpCode:MessageOpCodeBinary];
}

- (void) sendPing:(NSData*) aMessage
{
    [self sendMessage:aMessage messageWithOpCode:MessageOpCodePing];
}

- (void) sendMessage:(NSData*) aMessage messageWithOpCode:(MessageOpCode) aOpCode
{
    if (!isClosing)
    {
        NSUInteger messageLength = [aMessage length];
        if (messageLength <= self.config.maxPayloadSize)
        {
            //create and send fragment
            WebSocketFragment* fragment = [WebSocketFragment fragmentWithOpCode:aOpCode isFinal:YES payload:aMessage];
            [self sendMessage:fragment];
        }
        else
        {
            NSMutableArray* fragments = [NSMutableArray array];
            unsigned int fragmentCount = messageLength / self.config.maxPayloadSize;
            if (messageLength % self.config.maxPayloadSize)
            {
                fragmentCount++;
            }
            
            //build fragments
            for (int i = 0; i < fragmentCount; i++)
            {
                WebSocketFragment* fragment = nil;
                unsigned int fragmentLength = self.config.maxPayloadSize;
                if (i == 0)
                {
                    fragment = [WebSocketFragment fragmentWithOpCode:aOpCode isFinal:NO payload:[aMessage subdataWithRange:NSMakeRange(i * self.config.maxPayloadSize, fragmentLength)]];
                }
                else if (i == fragmentCount - 1)
                {
                    fragmentLength = messageLength % self.config.maxPayloadSize;
                    if (fragmentLength == 0)
                    {
                        fragmentLength = self.config.maxPayloadSize;
                    }
                    fragment = [WebSocketFragment fragmentWithOpCode:MessageOpCodeContinuation isFinal:YES payload:[aMessage subdataWithRange:NSMakeRange(i * self.config.maxPayloadSize, fragmentLength)]];
                }
                else
                {
                    fragment = [WebSocketFragment fragmentWithOpCode:MessageOpCodeContinuation isFinal:NO payload:[aMessage subdataWithRange:NSMakeRange(i * self.config.maxPayloadSize, fragmentLength)]];
                }
                [fragments addObject:fragment];
            }
            
            //send fragments
            for (WebSocketFragment* fragment in fragments) 
            {
                [self sendMessage:fragment];
            }
        }  
    }
}

- (void) sendMessage:(WebSocketFragment*) aFragment
{
    if (!isClosing || aFragment.opCode == MessageOpCodeClose)
    {
        [socket writeData:aFragment.fragment withTimeout:self.config.timeout tag:TagMessage];
    }
}


#pragma mark Internal Web Socket Logic
- (void) continueReadingMessageStream 
{
    [socket readDataWithTimeout:self.config.timeout tag:TagMessage];
}

- (void) closeSocket
{
    readystate = WebSocketReadyStateClosing;
    [socket disconnectAfterWriting];
}

- (void) handleCompleteFragment:(WebSocketFragment*) aFragment
{
    //if we are not in continuation and its final, dequeue
    if (aFragment.isFinal && aFragment.opCode != MessageOpCodeContinuation)
    {
//        NSLog(@"Dequeuing final fragment");
        [pendingFragments dequeue];
    }
    
    //continue to process
    switch (aFragment.opCode) 
    {
        case MessageOpCodeContinuation:
            if (aFragment.isFinal)
            {
//                NSLog(@"Handling complete list of fragments.");
                [self handleCompleteFragments];
            }
            break;
        case MessageOpCodeText:
            if (aFragment.isFinal)
            {
                if (aFragment.payloadData.length)
                {
                    NSString* textMsg = [[[NSString alloc] initWithData:aFragment.payloadData encoding:NSUTF8StringEncoding] autorelease];
                    if (textMsg)
                    {
                        [self dispatchTextMessageReceived:textMsg];
                    }
                    else if (self.config.version >= WebSocketVersion10)
                    {
                        [self close:WebSocketCloseStatusInvalidData message:nil];
                    }
                }
                else
                {
                    [self dispatchTextMessageReceived:@""];
                }
            }
            break;
        case MessageOpCodeBinary:
            if (aFragment.isFinal)
            {
                [self dispatchBinaryMessageReceived:aFragment.payloadData];
            }
            break;
        case MessageOpCodeClose:
            [self handleClose:aFragment];
            break;
        case MessageOpCodePing:
            [self handlePing:aFragment.payloadData];
            break;
    }
}

- (void) handleCompleteFragments
{
    WebSocketFragment* fragment = [pendingFragments dequeue];
    if (fragment != nil)
    {
        //init
        NSMutableData* messageData = [NSMutableData data];
        MessageOpCode messageOpCode = fragment.opCode;
        
        //loop through, constructing single message
        while (fragment != nil) 
        {
            [messageData appendData:fragment.payloadData];
            fragment = [pendingFragments dequeue];
        }
        
        //handle final message contents        
        switch (messageOpCode) 
        {            
            case MessageOpCodeText:
            {
                if (messageData.length)
                {
                    NSString* textMsg = [[[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding] autorelease];
                    if (textMsg)
                    {
                        [self dispatchTextMessageReceived:textMsg];
                    }
                    else if (self.config.version >= WebSocketVersion10)
                    {
                        [self close:WebSocketCloseStatusInvalidData message:nil];
                    }
                }
                break;
            }
            case MessageOpCodeBinary:
                [self dispatchBinaryMessageReceived:messageData];
                break;
        }
    }
}

- (void) handleClose:(WebSocketFragment*) aFragment
{
    //close status & message
    BOOL invalidUTF8 = NO;
    if (aFragment.payloadData)
    {
        NSUInteger length = aFragment.payloadData.length;
        if (length >= 2)
        {
            //get status code
            unsigned char buffer[2];
            [aFragment.payloadData getBytes:&buffer length:2];
            closeStatusCode = buffer[0] << 8 | buffer[1];
            
            //get message
            if (length > 2)
            {
                closeMessage = [[NSString alloc] initWithData:[aFragment.payloadData subdataWithRange:NSMakeRange(2, length - 2)] encoding:NSUTF8StringEncoding];
                if (!closeMessage)
                {
                    invalidUTF8 = YES;
                }
            }
        }
    }
    
    //handle close
    if (isClosing)
    {
        [self closeSocket];
    }
    else
    {
        isClosing = YES;
        if (!invalidUTF8 || self.config.version < WebSocketVersion10)
        {
            [self close:0 message:nil];
        }
        else
        {
            [self close:WebSocketCloseStatusInvalidData message:nil];
        }
    }
}

- (void) handlePing:(NSData*) aMessage
{
    [self sendMessage:aMessage messageWithOpCode:MessageOpCodePong];
    if ([delegate respondsToSelector:@selector(didSendPong:)])
    {
        [delegate didSendPong:aMessage];
    }
}

// TODO: use a temporary buffer for the fragment payload instead of a queue of fragments
- (int) handleMessageData:(NSData*) aData offset:(NSUInteger) aOffset
{
//    if (aOffset == 0) {
//        NSLog(@"HandleMessageData(%u):%@", aOffset, aData);
//    } else {
//        NSLog(@"Recursive HandleMessageData(%u):%@", aOffset, [aData subdataWithRange:NSMakeRange(aOffset, aData.length - aOffset)]);
//    }
    //init
    NSUInteger lengthOfRemainder = 0;
    NSUInteger existingLength = 0;
    int offset = -1;

    //grab last fragment, use if not complete
    WebSocketFragment* fragment = [pendingFragments lastObject];
    if (!fragment || fragment.isValid)
    {
        //assign web socket fragment since the last one was complete
        fragment = [[WebSocketFragment alloc] init];
        [pendingFragments enqueue:fragment];
        [fragment release];
//        fragment = [pendingFragments lastObject];
    }
    else
    {
        //grab existing length
        existingLength = fragment.fragment.length;
    }
    NSAssert(fragment != nil, @"Websocket fragment should never be nil");

    //if we dont know the length - try to figure it out
    if (!fragment.isHeaderValid) {
        [fragment parseHeader];

        //if we still don't have a length, see if we have enough
        if (!fragment.isHeaderValid) {
            if (![fragment parseHeader:aData from:aOffset]) {
                //if we still don't have a valid length, append all data and return
                if (fragment.fragment) {
                    [fragment.fragment appendData:aData];
                } else {
                    fragment.fragment = [NSMutableData dataWithData:aData];
                }
                return offset;
            }
        }
    }

    //determine data length
    NSUInteger possibleDataLength = aData.length - aOffset;
    NSUInteger actualDataLength = possibleDataLength;
    if ((possibleDataLength + existingLength > fragment.messageLength))
    {
        lengthOfRemainder = possibleDataLength - (fragment.messageLength - existingLength);
        actualDataLength = possibleDataLength - lengthOfRemainder;
    }

    //append actual data
    unsigned char* actualData = malloc(actualDataLength);
    [aData getBytes:actualData range:NSMakeRange(aOffset, actualDataLength)];
    if (fragment.fragment) {
        [fragment.fragment appendBytes:actualData length:actualDataLength];
    } else {
        fragment.fragment = [NSMutableData dataWithBytes:actualData length:actualDataLength];
    }
    free(actualData);

    //parse the data, if possible
//    NSLog(@"Fragment with opcode: %i, length: %i", fragment.opCode, fragment.messageLength);
    if (fragment.canBeParsed)
    {
        if (fragment.hasMask) {
            //client is not allowed to receive data that is masked and must fail the connection
            [self close:WebSocketCloseStatusProtocolError message:@"Server cannot mask data."];
            return offset;
        }
        [fragment parseContent];
//        NSLog(@"Parsed fragment: opcode=%i, length=%i", fragment.opCode, fragment.messageLength);

        //if we have a complete fragment, handle it
        if (fragment.isValid)
        {
            [self handleCompleteFragment:fragment];
        }
    }

    //if we have extra data, handle it
    if (fragment.messageLength > 0 ) {
        //if we have an offset, trim the data and call back into
        if (lengthOfRemainder > 0) {
            offset = actualDataLength + aOffset;
//            if (offset % 66 > 0) {
//                NSLog(@"Fragment: dataLength=%i, possibleDataLength=%i, actualDataLength=%i, messageLength=%i, existingLength=%i, remainder=%i, offset=%i", aData.length, possibleDataLength, actualDataLength, fragment.messageLength, existingLength, lengthOfRemainder, offset);
//            }
        }
    }
//    NSLog(@"Fragment: opCode=%i, final=%@, dataLength=%i, possibleDataLength=%i, actualDataLength=%i, messageLength=%i, existingLength=%i, remainder=%i, offset=%i", fragment.opCode, (fragment.isFinal ? @"YES" : @"NO"), aData.length, possibleDataLength, actualDataLength, fragment.messageLength, existingLength, lengthOfRemainder, offset);

    return offset;
}

//- (int) handleMessageData:(NSData*) aData offset:(NSUInteger) aOffset
//{
//    //grab last fragment, use if not complete
//    WebSocketFragment* fragment = [pendingFragments lastObject];
//    NSUInteger lengthOfRemainder = 0;
//    NSUInteger existingLength = 0;
//    NSUInteger actualDataLength = aData.length - aOffset;
//    NSLog(@"Allocating data of length: %i", actualDataLength);
//    unsigned char* actualData = malloc(actualDataLength);
//    [aData getBytes:actualData range:NSMakeRange(aOffset, actualDataLength)];
//    if (!fragment || fragment.isValid)
//    {
//        //assign web socket fragment since the last one was complete
//        fragment = [WebSocketFragment fragmentWithData:[NSData dataWithBytes:actualData length:actualDataLength]];
//        [pendingFragments enqueue:fragment];
//    }
//    else
//    {
//        //append the data
//        existingLength = fragment.fragment.length;
//        [fragment.fragment appendBytes:actualData length:actualDataLength];
//    }
//    free(actualData);
//
//    NSAssert(fragment != nil, @"Websocket fragment should never be nil");
//
//    //can we get to the header yet to determine length
//    if (!fragment.isHeaderValid) {
//        [fragment parseHeader];
//    }
//
//    //parse the data, if possible
//    NSLog(@"Fragment with opcode: %i, length: %i", fragment.opCode, aData.length);
//    if (fragment.canBeParsed)
//    {
//        if (fragment.hasMask) {
//            //client is not allowed to receive data that is masked and must fail the connection
//            [self close:WebSocketCloseStatusProtocolError message:@"Server cannot mask data."];
//            return -1;
//        }
//        [fragment parseContent];
//
//        //if we have a complete fragment, handle it
//        if (fragment.isValid)
//        {
//            [self handleCompleteFragment:fragment];
//        }
//    }
//
//    //if we have extra data, handle it
//    if (fragment.messageLength > 0 ) {
//        //determine appropriate offset, if needed
//        if ((actualDataLength + existingLength > fragment.messageLength))
//        {
//            lengthOfRemainder = actualDataLength - (fragment.messageLength - existingLength);
//        }
//
//        //if we have an offset, trim the data and call back into
//        if (lengthOfRemainder > 0 && (actualDataLength - lengthOfRemainder) > 0)
//        {
//            int offset = actualDataLength - lengthOfRemainder + aOffset;
//            NSLog(@"Fragment: dataSize=%i, messageLength=%i, existingLength=%i, remainder=%i, offset=%i", actualDataLength, fragment.messageLength, existingLength, lengthOfRemainder, offset);
//            return offset;
//        }
//    }
//
//    return -1;
//}

- (NSData*) getSHA1:(NSData*) aPlainText 
{
    CC_SHA1_CTX ctx;
    uint8_t * hashBytes = NULL;
    NSData * hash = nil;
    
    // Malloc a buffer to hold hash.
    hashBytes = malloc( CC_SHA1_DIGEST_LENGTH * sizeof(uint8_t) );
    memset((void *)hashBytes, 0x0, CC_SHA1_DIGEST_LENGTH);
    
    // Initialize the context.
    CC_SHA1_Init(&ctx);
    // Perform the hash.
    CC_SHA1_Update(&ctx, (void *)[aPlainText bytes], [aPlainText length]);
    // Finalize the output.
    CC_SHA1_Final(hashBytes, &ctx);
    
    // Build up the SHA1 blob.
    hash = [NSData dataWithBytes:(const void *)hashBytes length:(NSUInteger)CC_SHA1_DIGEST_LENGTH];
    
    if (hashBytes) free(hashBytes);
    
    return hash;
}

- (NSString*) getRequest: (NSString*) aRequestPath
{
    //create headers if they are missing
    NSMutableArray* headers = self.config.headers;
    if (headers == nil)
    {
        headers = [NSMutableArray array];
        self.config.headers = headers;
    }
    
    //handle security keys
    [self generateSecKeys];
    [headers addObject:[HandshakeHeader headerWithValue:wsSecKey forKey:@"Sec-WebSocket-Key"]];
    
    //handle host
    [headers addObject:[HandshakeHeader headerWithValue:self.config.host forKey:@"Host"]];
    
    //handle origin
    if (self.config.useOrigin) {
        if (self.config.version < WebSocketVersionRFC6455) {
            [headers addObject:[HandshakeHeader headerWithValue:self.config.origin forKey:@"Sec-WebSocket-Origin"]];
        } else {
            [headers addObject:[HandshakeHeader headerWithValue:self.config.origin forKey:@"Origin"]];
        }
    }

    //handle version
    if (self.config.version == WebSocketVersion10) {
        [headers addObject:[HandshakeHeader headerWithValue:[NSString stringWithFormat:@"%i",8] forKey:@"Sec-WebSocket-Version"]];
    } else if(self.config.version == WebSocketVersionRFC6455) {
        [headers addObject:[HandshakeHeader headerWithValue:[NSString stringWithFormat:@"%i",13] forKey:@"Sec-WebSocket-Version"]];
    } else {
        [headers addObject:[HandshakeHeader headerWithValue:[NSString stringWithFormat:@"%i",self.config.version] forKey:@"Sec-WebSocket-Version"]];
    }

    //handle protocol
    if (self.config.protocols && self.config.protocols.count > 0)
    {
        //build protocol fragment
        NSMutableString* protocolFragment = [NSMutableString string];
        for (NSString* item in self.config.protocols)
        {
            if ([protocolFragment length] > 0) 
            {
                [protocolFragment appendString:@", "];
            }
            [protocolFragment appendString:item];
        }
        
        //include protocols, if any
        if ([protocolFragment length] > 0)
        {
            [headers addObject:[HandshakeHeader headerWithValue:protocolFragment forKey:@"Sec-WebSocket-Protocol"]];
        }
    }
    
    //handle extensions
    if (self.config.extensions && self.config.extensions.count > 0)
    {
        //build extensions fragment
        NSString* extensionFragment = [self getExtensionsAsString:self.config.extensions];

        //return request with extensions
        if ([extensionFragment length] > 0)
        {
            [headers addObject:[HandshakeHeader headerWithValue:extensionFragment forKey:@"Sec-WebSocket-Extensions"]];
        }
    }
    
    return [self buildStringFromHeaders:headers resource:aRequestPath];
}

- (NSString*) getExtensionsAsString:(NSArray*) aExtensions
{
    NSMutableString* extensionFragment = [NSMutableString string];
    for (id item in aExtensions)
    {
        if ([item isKindOfClass:[NSString class]])
        {
            if ([extensionFragment length] > 0) 
            {
                [extensionFragment appendString:@"; "];
            }
            [extensionFragment appendString:(NSString*) item];
        }
        else if ([item isKindOfClass:[NSArray class]])
        {
            //build ordered list of extensions
            NSArray* items = (NSArray*) item;
            NSMutableString* itemFragment = [NSMutableString string];
            for (NSString* childItem in items)
            {
                if ([itemFragment length] > 0) 
                {
                    [itemFragment appendString:@", "];
                }
                [itemFragment appendString:childItem];
            }

            //add to list of extensions
            if ([extensionFragment length] > 0)
            {
                [extensionFragment appendString:@"; "];
            }
            [extensionFragment appendString:itemFragment];
        }
    }
    
    return extensionFragment;
}
                    
- (NSString*) buildStringFromHeaders:(NSMutableArray*) aHeaders resource:(NSString*) aResource
{
    //init
    NSMutableString* result = [NSMutableString stringWithFormat:@"GET %@ HTTP/1.1\r\nUpgrade: WebSocket\r\nConnection: Upgrade\r\n", aResource];
    
    //add headers
    if (aHeaders)
    {
        for (HandshakeHeader* header in aHeaders) 
        {
            if (header)
            {
                [result appendFormat:@"%@: %@\r\n", header.key, header.value];
            }
        }
    }
    
    //add terminator
    [result appendFormat:@"\r\n"];
    
    return result;
}

- (NSMutableArray*) buildHeadersFromString:(NSString*) aHeaders
{
    NSMutableArray* results = [NSMutableArray array];
    NSArray *listItems = [aHeaders componentsSeparatedByString:@"\r\n"];
    for (NSString* item in listItems) 
    {
        NSRange range = [item rangeOfString:@":" options:NSLiteralSearch];
        if (range.location != NSNotFound)
        {
            NSString* key = [item substringWithRange:NSMakeRange(0, range.location)];
            key = [key stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
            NSString* value = [item substringFromIndex:range.length + range.location];
            value = [value stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
            [results addObject:[HandshakeHeader headerWithValue:value forKey:key]];
        }
    }
    return results;
}

- (void) generateSecKeys
{
    NSString* initialString = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
    NSData *data = [initialString dataUsingEncoding:NSUTF8StringEncoding];
	NSString* key = [data base64EncodedString];
    wsSecKey = [key copy];
    key = [NSString stringWithFormat:@"%@%@", wsSecKey, @"258EAFA5-E914-47DA-95CA-C5AB0DC85B11"];
    data = [self getSHA1:[key dataUsingEncoding:NSUTF8StringEncoding]];
    key = [data base64EncodedString];
    wsSecKeyHandshake = [key copy];
}

- (HandshakeHeader*) headerForKey:(NSString*) aKey inHeaders:(NSMutableArray*) aHeaders
{
    for (HandshakeHeader* header in aHeaders)
    {
        if (header)
        {
            if ([header keyMatchesCaseInsensitiveString:aKey])
            {
                return header;
            }
        }
    }

    return nil;
}

- (NSArray*) headersForKey:(NSString*) aKey inHeaders:(NSMutableArray*) aHeaders
{
    NSMutableArray* results = [NSMutableArray array];
    
    for (HandshakeHeader* header in aHeaders)
    {
        if (header)
        {
            if ([header keyMatchesCaseInsensitiveString:aKey])
            {
                [results addObject:header];
            }
        }
    }
    
    return results;
}

- (BOOL) supportsAnotherSupportedVersion: (NSString*) aResponse
{
    //a HTTP 400 response is the only valid one
    if ([aResponse hasPrefix:@"HTTP/1.1 400"])
    {
        return [aResponse rangeOfString:@"Sec-WebSocket-Version"].location != NSNotFound;
    }

    return false;
}

- (BOOL) isUpgradeResponse: (NSString*) aResponse
{
    //a HTTP 101 response is the only valid one
    if ([aResponse hasPrefix:@"HTTP/1.1 101"])
    {        
        //build headers
        self.config.serverHeaders = [self buildHeadersFromString:aResponse];
        
        //check security key, if requested
        if (self.config.verifySecurityKey)
        {
            HandshakeHeader* header = [self headerForKey:@"Sec-WebSocket-Accept" inHeaders:self.config.serverHeaders];
            if (![wsSecKeyHandshake isEqualToString:header.value])
            {
                return false;
            }
        }
        
        //verify we have a "Upgrade: websocket" header
        HandshakeHeader* header = [self headerForKey:@"Upgrade" inHeaders:self.config.serverHeaders];
        if ([@"websocket" caseInsensitiveCompare:header.value] != NSOrderedSame)
        {
            return false;
        }
        
        //verify we have a "Connection: Upgrade" header
        header = [self headerForKey:@"Connection" inHeaders:self.config.serverHeaders];
        if ([@"Upgrade" caseInsensitiveCompare:header.value] != NSOrderedSame)
        {
            return false;
        }

        //verify that version specified matches the version we requested

        
        return true;
    }
    
    return false;
}

- (void) sendHandshake:(AsyncSocket*) aSocket
{
        //continue with handshake
        NSString *requestPath = self.config.url.path;
        if (requestPath == nil || requestPath.length == 0) {
            requestPath = @"/";
        }
        if (self.config.url.query)
        {
            requestPath = [requestPath stringByAppendingFormat:@"?%@", self.config.url.query];
        }
        NSString* getRequest = [self getRequest: requestPath];
        [aSocket writeData:[getRequest dataUsingEncoding:NSASCIIStringEncoding] withTimeout:self.config.timeout tag:TagHandshake];
}

- (NSMutableArray*) getServerVersions:(NSMutableArray*) aServerHeaders
{
    NSMutableArray* results = [NSMutableArray array];
    NSMutableArray * tempResults = [NSMutableArray array];

    //find all entries keyed by Sec-WebSocket-Version or Sec-WebSocket-Version-Server
    [tempResults addObjectsFromArray:[self headersForKey:@"Sec-WebSocket-Version" inHeaders:self.config.serverHeaders]];
    [tempResults addObjectsFromArray:[self headersForKey:@"Sec-WebSocket-Version-Server" inHeaders:self.config.serverHeaders]];
    
    //loop through values trimming and adding to versions
    for (HandshakeHeader* header in tempResults)
    {
        NSString* extensionValues = header.value;
        NSArray *listItems = [extensionValues componentsSeparatedByString:@","];
        for (NSString* item in listItems)
        {
            if (item)
            {
                NSString* value = [item stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                if (value && value.length)
                {
                    [results addObject:value];
                }
            }
        }
    }

    return results;
}

- (NSMutableArray*) getServerExtensions:(NSMutableArray*) aServerHeaders
{
    NSMutableArray* results = [NSMutableArray array];
    
    //loop through values trimming and adding to extensions 
    HandshakeHeader* header = [self headerForKey:@"Sec-WebSocket-Extensions" inHeaders:self.config.serverHeaders];
    if (header)
    {
        NSString* extensionValues = header.value;
        NSArray *listItems = [extensionValues componentsSeparatedByString:@","];
        for (NSString* item in listItems) 
        {
            if (item)
            {
                NSString* value = [item stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                if (value && value.length)
                {
                    [results addObject:value];
                }
            }
        }
    }
    
    return results;
}

- (BOOL) isValidServerExtension:(NSArray*) aServerExtensions
{
    if (self.config.extensions && self.config.extensions.count > 0)
    {
        //if we only have one extension, see if its in our list of accepted extensions
        if (aServerExtensions.count == 1)
        {
            NSString* serverExtension = [aServerExtensions objectAtIndex:0];
            for (id item in self.config.extensions)
            {
                if ([item isKindOfClass:[NSString class]])
                {
                    if ([serverExtension isEqualToString:(NSString*) item])
                    {
                        return YES;
                    }
                }
            }
        }
        
        //if we have a list of extensions, see if this exact ordered list exists in our list of accepted extensions
        for (id item in self.config.extensions)
        {
            if ([item isKindOfClass:[NSArray class]])
            {
                if ([aServerExtensions isEqualToArray:(NSArray*) item])
                {
                    return YES;
                }
            }
       }
        
        return NO;
    }
    
    return (aServerExtensions == nil || aServerExtensions.count == 0);
}


#pragma mark Web Socket Delegate
- (void) dispatchFailure:(NSError*) aError 
{
    if(delegate) 
    {
        [delegate didReceiveError:aError];
    }
}

- (void) dispatchClosed:(NSUInteger) aStatusCode message:(NSString*) aMessage error:(NSError*) aError
{
    if (delegate)
    {
        [delegate didClose:aStatusCode message:aMessage error:aError];
    }
}

- (void) dispatchOpened 
{
    if (delegate) 
    {
        [delegate didOpen];
    }
}

- (void) dispatchTextMessageReceived:(NSString*) aMessage 
{
    if (delegate)
    {
        [delegate didReceiveTextMessage:aMessage];
    }
}

- (void) dispatchBinaryMessageReceived:(NSData*) aMessage 
{
    if (delegate)
    {
        [delegate didReceiveBinaryMessage:aMessage];
    }
}


#pragma mark AsyncSocket Delegate
- (void) onSocketDidDisconnect:(AsyncSocket*) aSock 
{
    readystate = WebSocketReadyStateClosed;
    if (self.config.version > WebSocketVersion07)
    {
        if (closeStatusCode == 0)
        {
            if (closingError != nil)
            {
                closeStatusCode = WebSocketCloseStatusAbnormalButMissingStatus;
            }
            else
            {
                closeStatusCode = WebSocketCloseStatusNormalButMissingStatus;
            }
        }
    }
    NSLog(@"Socket disconnected.");
    [self dispatchClosed:closeStatusCode message:closeMessage error:closingError];
}

- (void)onSocket:(AsyncSocket *) aSocket didSecure:(BOOL) aDidSecure {
    if (self.config.isSecure && !aDidSecure) {
        [self close:WebSocketCloseStatusTlsHandshakeError message:nil];
    }
    else {
        [self sendHandshake:aSocket];
    }
}

- (void) onSocket:(AsyncSocket *) aSocket willDisconnectWithError:(NSError *) aError
{
    switch (self.readystate) 
    {
        case WebSocketReadyStateOpen:
        case WebSocketReadyStateConnecting:
            readystate = WebSocketReadyStateClosing;
            [self dispatchFailure:aError];
        case WebSocketReadyStateClosing:
            closingError = [aError retain]; 
    }
}

- (void) onSocket:(AsyncSocket*) aSocket didConnectToHost:(NSString*) aHost port:(UInt16) aPort 
{
    //start TLS if this is a secure websocket
    if (self.config.isSecure)
    {
        // Configure SSL/TLS settings
        NSDictionary *settings = self.config.tlsSettings;
        
        //seed with defaults if missing
        if (!settings)
        {
            settings = [NSMutableDictionary dictionaryWithCapacity:3];
        }
        
        [socket startTLS:settings];
    }
    else {
        [self sendHandshake:aSocket];
    }
}

- (void) onSocket:(AsyncSocket*) aSocket didWriteDataWithTag:(long) aTag 
{
    if (aTag == TagHandshake) 
    {
        [aSocket readDataToData:[@"\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:self.config.timeout tag:TagHandshake];
    }
}

- (void) onSocket: (AsyncSocket*) aSocket didReadData:(NSData*) aData withTag:(long) aTag 
{
    if (aTag == TagHandshake) 
    {
        NSString* response = [[[NSString alloc] initWithData:aData encoding:NSASCIIStringEncoding] autorelease];
        if ([self isUpgradeResponse: response]) 
        {
            //grab protocol from server
            HandshakeHeader* header = [self headerForKey:@"Sec-WebSocket-Protocol" inHeaders:self.config.serverHeaders];
            if (!header) {
                header = [self headerForKey:@"Sec-WebSocket-Protocol-Server" inHeaders:self.config.serverHeaders];
            }
            if (header)
            {
                //if version is rfc6455 or later, null out value if it was not a requested protocol
                if (self.config.version < WebSocketVersionRFC6455 || [self.config.protocols containsObject:header]) {
                    self.config.serverProtocol = header.value;
                }
            }
            
            //grab extensions from the server
            NSMutableArray* extensions = [self getServerExtensions:self.config.serverHeaders];
            if (extensions)
            {
                //validate the extensions, if rfc6455 or later
                if (self.config.version >= WebSocketVersionRFC6455 && self.config.extensions.count) {
                    if (![self isValidServerExtension:extensions])
                    {
                        NSString* extensionFragment = [self getExtensionsAsString:self.config.extensions];
                        [self close:WebSocketCloseStatusMissingExtensions message:extensionFragment];
                        return;
                    }
                }

                self.config.serverExtensions = extensions;
            }
            
            //handle state & delegates
            readystate = WebSocketReadyStateOpen;
            [self dispatchOpened];
            [self continueReadingMessageStream];
        }
        else if ([self supportsAnotherSupportedVersion: response])
        {
            //use property to determine if we try a different version
            BOOL retry = NO;
            NSArray* versions = [self getServerVersions:self.config.serverHeaders];
            if (self.config.retryOtherVersion) 
            {
                for(NSString* version in versions)
                {
                    if (version && version.length)
                    {
                        switch ([version intValue]) 
                        {
                            case WebSocketVersion07:
                                self.config.version = WebSocketVersion07;
                                retry = YES;
                                break;
                            case WebSocketVersion10:
                                self.config.version = WebSocketVersion10;
                                retry = YES;
                                break;
                        }
                    }
                }
            }

            //retry if able
            if (retry)
            {
                [self open];
            }
            else
            {
                //send failure since we can't retry a supported version
                [self dispatchFailure:[NSError errorWithDomain:WebSocketErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Unsupported Version", NSLocalizedDescriptionKey, response, NSLocalizedFailureReasonErrorKey, nil]]];
            }
        }
        else 
        {
            [self dispatchFailure:[NSError errorWithDomain:WebSocketErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Bad handshake", NSLocalizedDescriptionKey, response, NSLocalizedFailureReasonErrorKey, nil]]];
        }
    } 
    else if (aTag == TagMessage) 
    {
        //handle data
        int offset = 0;
        do {
            offset = [self handleMessageData:aData offset:(NSUInteger) offset];
        } while (offset >= 0);

        //keep reading
        [self continueReadingMessageStream];
    }
}


#pragma mark Lifecycle
+ (id) webSocketWithConfig:(WebSocketConnectConfig*) aConfig delegate:(id<WebSocketDelegate>) aDelegate
{
    return [[[[self class] alloc] initWithConfig:aConfig delegate:aDelegate] autorelease];
}

- (id) initWithConfig:(WebSocketConnectConfig*) aConfig delegate:(id<WebSocketDelegate>) aDelegate
{
    self = [super init];
    if (self) 
    {
        //apply properties
        self.delegate = aDelegate;
        self.config = aConfig;
        socket = [[AsyncSocket alloc] initWithDelegate:self];
        pendingFragments = [[MutableQueue alloc] init];
        isClosing = NO;
    }
    return self;
}

-(void) dealloc 
{
    socket.delegate = nil;
    [socket disconnect];
    [socket release];
    [delegate release];
    [closingError release];
    [pendingFragments release];
    [closeMessage release];
    [wsSecKey release];
    [wsSecKeyHandshake release];
    [config release];
    [super dealloc];
}

@end
