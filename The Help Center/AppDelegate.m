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
@property (weak) IBOutlet NSTextField *subscribeKeyTextField;
@property (weak) IBOutlet NSTextField *publishKeyTextField;

- (IBAction)showChat:(id)sender;

@property (weak) IBOutlet NSWindow *window;
@property NSMutableArray <NSWindowController *> *chatWindowControllers;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // We can open multiple windows
    self.chatWindowControllers = [NSMutableArray array];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)openChatWindow {
    self.publishKey = self.publishKeyTextField.stringValue;
    self.subscribeKey = self.subscribeKeyTextField.stringValue;
    if (self.publishKey && self.publishKey.length > 0 && self.subscribeKey && self.subscribeKey.length > 0) {
        THCHelpChat *chatWindow = [[THCHelpChat alloc] initWithWindowNibName:@"THCHelpChat"];
        [self.chatWindowControllers addObject:chatWindow];
        [chatWindow showWindow:self];
        chatWindow.window.delegate = self;
    } else {
        NSError *error = [NSError errorWithDomain:@"com.chat" code:1345 userInfo:nil];
        NSAlert *alert = [NSAlert alertWithError:error];
        alert.alertStyle = NSAlertStyleWarning;
        alert.messageText = @"Missing PubNub keys";
        alert.informativeText = @"Subscribe & Publish keys are missing";
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            NSLog(@"returncode: %ld", returnCode);
        }];
        
    }
}

- (IBAction)showChat:(id)sender {
    [self openChatWindow];
}

#pragma mark - NSWindow Delegate
- (void)windowWillClose:(NSNotification *)notification {
    NSArray <NSWindowController *> *chatWindows = self.chatWindowControllers;
    for (NSWindowController *controller in chatWindows) {
        if ([controller.window isEqualTo:notification.object]) {
            [self.chatWindowControllers removeObject:controller];
        }
    }
}

@end
