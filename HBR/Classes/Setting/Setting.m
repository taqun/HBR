//
//  Setting.m
//  HBR
//
//  Created by taqun on 2015/06/30.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

#import "Setting.h"

@implementation Setting

+ (NSString *)hbConsumerKey{
    return HB_CONSUMER_KEY;
}

+ (NSString *)hbConsumerSecret{
    return HB_CONSUMER_SECRET;
}

+ (NSString *)gaTrackingId{
    return GA_TRACKING_ID;
}

+ (NSString *)iapProductId{
    return IAP_PRODUCT_ID;
}

@end
