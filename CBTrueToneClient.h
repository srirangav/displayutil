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
