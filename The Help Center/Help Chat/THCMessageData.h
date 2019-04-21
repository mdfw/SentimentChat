//
//  THCMessageData.h
//  The Help Center
//
//  Created by Mark on 4/21/19.
//  Copyright © 2019 Mark Williams. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface THCMessageData : NSObject
@property NSDictionary *message;
@property NSDictionary *sentiment;
@property NSDate *messageTime;
@property NSString *uuid;
@end

NS_ASSUME_NONNULL_END
