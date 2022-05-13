/*
    CBBlueLightClient.h - partial header for private blue light client
                          framework

    Based on:

    $ strings /System/Library/PrivateFrameworks/CoreBrightness.framework/CoreBrightness
    $ nm /System/Library/PrivateFrameworks/CoreBrightness.framework/CoreBrightness

    See also:

    https://github.com/jenghis/nshift/blob/master/nshift/CBBlueLightClient.h
    https://github.com/elanini/NightShifter/blob/master/CBBlueLightClient.h
    https://github.com/Skittyblock/LightsOut/blob/master/Tweak.xm
    https://saagarjha.com/blog/2018/12/01/scheduling-dark-mode/
    https://github.com/nst/iOS-Runtime-Headers/blob/master/PrivateFrameworks/CoreBrightness.framework/CBBlueLightClient.h
*/

#ifndef CBBlueLightClient_h
#define CBBlueLightClient_h

enum
{
    CBBlueLightClientModeNoSchedule     = 0,
    CBBlueLightClientModeSunsetSunrise  = 1,
    CBBlueLightClientModeCustomSchedule = 2,
};

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
    BOOL sunsetToSunrise;
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

    - (BOOL)setMode: (int)mode;

    - (BOOL)setSchedule: (CBBlueLightClient_Schedule_t *)schedule;

    + (BOOL)supportsBlueLightReduction;

    - (BOOL)getBlueLightStatus: (CBBlueLightClient_StatusData_t *)status;

@end

#endif /* CBBlueLightClient_h */
