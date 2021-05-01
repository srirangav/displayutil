/*
    CBTrueToneClient.h - partial header for private true tone client framework

    Based on:

    $ strings /System/Library/PrivateFrameworks/CoreBrightness.framework/CoreBrightness
    $ nm /System/Library/PrivateFrameworks/CoreBrightness.framework/CoreBrightness
*/

#ifndef CBTrueToneClient_h
#define CBTrueToneClient_h

#import <Foundation/Foundation.h>

@interface CBTrueToneClient : NSObject

    - (BOOL) enabled;

    - (BOOL) setEnabled: (BOOL)enabled;

    - (BOOL) supported;

    - (BOOL) available;

@end

#endif /* CBTrueToneClient_h */
