//
//  THCChatCellView.h
//  The Help Center
//
//  Created by Mark on 4/21/19.
//  Copyright © 2019 Mark Williams. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface THCChatCellView : NSTableCellView
@property IBOutlet NSTextField *user;
@property IBOutlet NSTextField *time;
@property IBOutlet NSTextField *chatText;
@property IBOutlet NSTextField *sentiment;
@end

NS_ASSUME_NONNULL_END
