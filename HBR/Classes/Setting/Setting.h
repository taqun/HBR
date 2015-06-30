//
//  Setting.h
//  HBR
//
//  Created by taqun on 2015/06/30.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Setting : NSObject

+ (NSString *)hbConsumerKey;
+ (NSString *)hbConsumerSecret;

+ (NSString *)gaTrackingId;

+ (NSString *)iapProductId;

@end
