//
//  HelpChat.m
//  The Help Center
//
//  Created by Mark on 4/20/19.
//  Copyright © 2019 Mark Williams. All rights reserved.
//

/*
 Implements a chat interface with PubNub as the transportation layer.
 Uses PubNub's native interface with AWS Comprehend to do sentiment analysis.
 
 Chats are sent on channel "Channel-helpchat". The AWS Comprehend interface listens on that channel and, after analysis, sends analysis back on channel "Channel-sentiment"
 
 When a chat is sent/received, the JSON/Dictionary looks like:
 {
    channel = "Channel-helpchat";
    envelope = "<PNEnvelopeInformation: 0x600000091e90>";
    message =     {
        data =         {
            comprehend =             {
                language = en;
                location = text;
            };
        senderName = Bob;
        text = Hello;
        uuid = "290322D3-BD94-4E38-A18E-0E68CD571702";
        };
    };
    region = 1;
    subscription = "Channel-helpchat";
    timetoken = 15558878388718730;
 }
 
 When the sentiment data is recieved, it looks like:
 {
    channel = "Channel-sentiment";
    envelope = "<PNEnvelopeInformation: 0x60c000083b60>";
    message =     {
        event = sentimentAnalysis;
        originalUUID = "290322D3-BD94-4E38-A18E-0E68CD571702";
        sender = 1510099933557;
        sentiment =         {
            Sentiment = NEUTRAL;
            SentimentScore =             {
                Mixed = "0.013588612899184227";
                Negative = "0.06471899151802063";
                Neutral = "0.8002764582633972";
                Positive = "0.1214159354567528";
            };
        };
    };
    region = 1;
    subscription = "Channel-sentiment";
    timetoken = 15558878398029440;
 }
 */

#import "THCHelpChat.h"
#import <PubNub/PubNub.h>
#import "THCChatCellView.h"
#import "THCMessageData.h"

NSString * const kMessageDataKeyUUID = @"uuid";
NSString * const kSentimentMessageDataKeyUUID = @"originalUUID";
NSString * const kMessageDataKeyText = @"text";
NSString * const kMessageDataKeyData = @"data";
NSString * const kMessageDataKeySenderName = @"senderName";
NSString * const kMessageDataKeySentiment = @"sentiment";
NSString * const kMessageDataKeySentimentCapped = @"Sentiment";


@interface THCHelpChat ()
@property (nonatomic, strong) PubNub *pubNubClient;
@property NSString *mainChannel;
@property NSString *sentimentChannel;

/* Storing the messages in an array is not ideal but easy.
 Especially since when we get sentiment information back, we have to parse the whole array to insert it.
 However, for the demo, it will work.
 */
@property NSMutableArray *messagesArray;

@property (weak) IBOutlet NSTextField *nameTextField; // A name for the chat.
@property (weak) IBOutlet NSTextField *questionTextField; // The chat text
@property (weak) IBOutlet NSTableView *messagesTable; // The table where all the data stays.

- (IBAction)sendMessage:(id)sender;

@end

@implementation THCHelpChat

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.messagesArray = [NSMutableArray array];
    self.mainChannel = @"Channel-helpchat";
    self.sentimentChannel = @"Channel-sentiment";
    
    [self setUpPubNub];
}

#pragma mark - set up pubnub
- (void)setUpPubNub {
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"YOUR_PUBNUB_PUBLISH_KEY" subscribeKey:@"YOUR_PUBNUB_SUBSCRIBE_KEY"];
    configuration.stripMobilePayload = NO;  // Removes an API deprecation warning
    self.pubNubClient = [PubNub clientWithConfiguration:configuration];
    [self.pubNubClient addListener:self];
    
    // Subscribe to the two channels without presence observation
    [self.pubNubClient subscribeToChannels: @[self.mainChannel, self.sentimentChannel] withPresence:NO];
}

#pragma mark - pubnub protocols for receiving
// Handle new message from one of channels on which client has been subscribed.
- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    
    //NSLog(@"Recieved Data: %@", message.data);
    if ([message.data.channel isEqualToString: self.mainChannel] ) {
        NSDictionary *messageData = [message.data.message objectForKey:kMessageDataKeyData];
        [self storeRecievedMessage:messageData];
    } else if ([message.data.channel isEqualToString: self.sentimentChannel] ) {
        [self storeSentimentMessage:message.data.message];
    }
    //NSLog(@"%@", self.messagesArray);
    [self.messagesTable reloadData];
}

- (void)storeRecievedMessage:(NSDictionary *)messageData {
    NSString *uuid = [messageData objectForKey:kMessageDataKeyUUID];
    if (uuid && uuid.length > 0) {
        THCMessageData *messageDict = [[THCMessageData alloc] init];
        messageDict.message = messageData;
        messageDict.messageTime = [NSDate date];
        messageDict.uuid = uuid;
        [self.messagesArray addObject:messageDict];
    } else {
        NSLog(@"No UUID - cannot save message");
    }
}

- (void)storeSentimentMessage:(NSDictionary *)messageData {
    NSString *uuid = [messageData objectForKey:kSentimentMessageDataKeyUUID];
    if (uuid && uuid.length > 0) {
        for (THCMessageData *thisMessage in self.messagesArray) {
            if ([thisMessage.uuid isEqualToString:uuid]) {
                thisMessage.sentiment = [messageData objectForKey:kMessageDataKeySentiment];
            }
        }
    } else {
        NSLog(@"No UUID - cannot save message");
    }
}


#pragma mark - sending
- (IBAction)sendMessage:(id)sender {
    NSString *text = self.questionTextField.stringValue;
    NSString *name = self.nameTextField.stringValue;
    NSString *iden = [[NSUUID UUID] UUIDString];
    NSDictionary *payload = @{kMessageDataKeyData: @{kMessageDataKeyUUID: iden, kMessageDataKeyText: text, kMessageDataKeySenderName: name, @"comprehend": @{@"language": @"en", @"location": kMessageDataKeyText}}};

    [self.pubNubClient publish:payload toChannel:self.mainChannel withCompletion:^(PNPublishStatus * _Nonnull status) {
        if (!status.isError) {
            NSLog(@"Sent!");
        } else {
            NSLog(@"Failed: %ld", (long)status.category);
        }
    }];
}

#pragma mark - table datasource and delegate
/*
 Normally these should be put in their own controller to keep our view controllers from growing out of control.
 However, that can make it difficult to reason about. For this demo we're leaving them in.
 
 Bug: Table rows are not variable height. Should fix that.
 */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.messagesArray.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [self.messagesArray objectAtIndex:row];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    THCChatCellView *chatCell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    THCMessageData *messageData = [self.messagesArray objectAtIndex:row];
    chatCell.user.stringValue = [messageData.message objectForKey:kMessageDataKeySenderName];
    chatCell.chatText.stringValue = [messageData.message objectForKey:kMessageDataKeyText];
    NSString *dateString = [NSDateFormatter localizedStringFromDate:messageData.messageTime
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle];

    chatCell.time.stringValue = dateString;
    if (messageData.sentiment) {
        NSString *sentimentString = [messageData.sentiment objectForKey:kMessageDataKeySentimentCapped];
        chatCell.sentiment.stringValue = sentimentString;
        if ([sentimentString isEqualToString:@"POSITIVE"]) {
            chatCell.sentiment.textColor = [NSColor greenColor];
        } else if ([sentimentString isEqualToString:@"NEGATIVE"]) {
            chatCell.sentiment.textColor = [NSColor redColor];
        } else {
            chatCell.sentiment.textColor = [NSColor systemGrayColor];
        }
        
    } else {
        chatCell.sentiment.stringValue = @"";
    }
    return chatCell;
}
@end
