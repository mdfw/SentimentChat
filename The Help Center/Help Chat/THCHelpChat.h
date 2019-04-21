//
//  HelpChat.h
//  The Help Center
//
//  Created by Mark on 4/20/19.
//  Copyright © 2019 Mark Williams. All rights reserved.
//

/* Demo of a chat with sentiment analysis. See more info in the .m file */

#import <Cocoa/Cocoa.h>
#import <PubNub/PubNub.h>


NS_ASSUME_NONNULL_BEGIN

@interface THCHelpChat : NSWindowController <PNObjectEventListener>

@end

NS_ASSUME_NONNULL_END
