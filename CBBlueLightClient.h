/*
    CBBlueLightClient.h - partial header for private blue light client
                          framework

    Based on:

    $ strings /System/Library/PrivateFrameworks/CoreBrightness.framework/CoreBrightness

    See also:

    https://github.com/jenghis/nshift/blob/master/nshift/CBBlueLightClient.h
    https://github.com/elanini/NightShifter/blob/master/CBBlueLightClient.h
    https://github.com/Skittyblock/LightsOut/blob/master/Tweak.xm
*/

#ifndef CBBlueLightClient_h
#define CBBlueLightClient_h

#import <Foundation/Foundation.h>

typedef struct
{
    int hour;
    int minute;
} CBBlueLightClient_Time_t;

typedef struct
{
    CBBlueLightClient_Time_t from;
    CBBlueLightClient_Time_t to;
} CBBlueLightClient_Schedule_t;

typedef struct {
    BOOL active;
    BOOL enabled;
    BOOL sunSchedulePermitted;
    int mode;
    CBBlueLightClient_Schedule_t schedule;
    unsigned long long disableFlags;
    BOOL available;
} CBBlueLightClient_StatusData_t;

@interface CBBlueLightClient : NSObject

    - (BOOL)setStrength: (float)strength
                 commit: (BOOL)commit;

    - (BOOL)getStrength: (float *)strength;

    - (BOOL)setEnabled: (BOOL)enabled;

    + (BOOL)supportsBlueLightReduction;

    - (BOOL)getBlueLightStatus: (CBBlueLightClient_StatusData_t *)status;

@end

#endif /* CBBlueLightClient_h */
