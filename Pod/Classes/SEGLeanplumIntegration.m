//
//  SEGLeanplumIntegration.m
//  Leanplum Segment iOS Integration Version 1.0.1
//
//  Copyright (c) 2016 Leanplum. All rights reserved.
//

#import "SEGLeanplumIntegration.h"

@implementation SEGLeanplumIntegration

- (instancetype)initWithSettings:(NSDictionary *)settings
{
    if (self = [super init]) {
        NSString *appId = [settings objectForKey:@"appId"];
        NSString *token = [settings objectForKey:@"clientKey"];
        bool isDevelopmentMode = [[settings objectForKey:@"devMode"] boolValue];

        if (!appId || appId.length == 0) {
            @throw([NSException
                exceptionWithName:@"Leanplum Error"
                           reason:[NSString
                                      stringWithFormat:@"Leanplum: Please add "
                                                       @"Leanplum app id in "
                                                       @"Segment settings."]
                         userInfo:nil]);
        }
        if (!token || token.length == 0) {
            @throw([NSException
                exceptionWithName:@"Leanplum Error"
                           reason:[NSString
                                      stringWithFormat:@"Leanplum: Please add "
                                                       @"Leanplum client key "
                                                       @"in Segment settings."]
                         userInfo:nil]);
        }

        if (isDevelopmentMode) {
            [Leanplum setAppId:appId withDevelopmentKey:token];
        } else {
            [Leanplum setAppId:appId withProductionKey:token];
        }

        [Leanplum start];
    }
    return self;
}

- (void)identify:(SEGIdentifyPayload *)payload
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [Leanplum setUserId:payload.userId withUserAttributes:payload.traits];
    });
}

- (void)track:(SEGTrackPayload *)payload
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Since Leanplum has value field that can be associated with any event,
        // we have to extract that field from segments and send it with our event as a value.
        if ([payload.properties objectForKey:@"value"])
        {
            id object = [payload.properties objectForKey:@"value"];
            if ([object isKindOfClass:[NSNumber class]])
            {
                double value = [object doubleValue];
                [Leanplum track:payload.event withValue:value andParameters:payload.properties];
            }
            else
            {
                [Leanplum track:payload.event withParameters:payload.properties];
            }
        }
        else
        {
            [Leanplum track:payload.event withParameters:payload.properties];
        }
        
    });
}

- (void)screen:(SEGScreenPayload *)payload
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [Leanplum advanceTo:payload.name withParameters:payload.properties];
    });
}

@end
