//
//  AppDelegate.m
//  The Help Center
//
//  Created by Mark on 4/10/19.
//  Copyright © 2019 Mark Williams. All rights reserved.
//

#import "AppDelegate.h"
#import "THCHelpChat.h"

@interface AppDelegate ()
- (IBAction)showChat:(id)sender;

@property (weak) IBOutlet NSWindow *window;
@property (strong) THCHelpChat *chatWindow;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self openChatWindow];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)openChatWindow {
    if (!self.chatWindow) {
        self.chatWindow = [[THCHelpChat alloc] initWithWindowNibName:@"THCHelpChat"];
    }
    [self.chatWindow showWindow:self];
}

- (IBAction)showChat:(id)sender {
    [self openChatWindow];
}
@end
