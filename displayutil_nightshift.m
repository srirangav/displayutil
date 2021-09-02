/*
    displayutil - displayutil_nightshift.m

    History:

    v. 1.0.0 (04/01/2021) - Initial version
    v. 1.0.1 (04/15/2021) - Add support for nightshift schedules

    Copyright (c) 2021 Sriranga R. Veeraraghavan <ranga@calalum.org>

    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
    THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    DEALINGS IN THE SOFTWARE.
 */

#import <stdio.h>
#import <stdlib.h>
#import "CBBlueLightClient.h"
#import "displayutil_argutils.h"
#import "displayutil_nightshift.h"

/* strings to select nightshift mode */

const char *gStrModeNightShiftLong           = "nightshift";
const char *gStrModeNightShiftShort          = "ns";
const char *gStrModeNightShiftSchedule       = "schedule";
const char *gStrModeNightShiftScheduleSunset = "sunset";

/* nightshift constants */

static const char *gStrNightShiftRange         = "0.0 - 1.0";
static const char *gStrNightSiftScheduleSunset = "sunset to sunrise";
static const char *gStrNightShiftScheduleNone  = "none";
static const char *gStrNightShiftScheduleRange = "[h]h:mm [h]h:mm";

/* error messages */

static const char *gStrErrNoNS       = "nightshift not supported";
static const char *gStrErrNoNSClient = "cannot create a nightshift client";
static const char *gStrErrNSStatus   = "cannot get nightshift status";
static const char *gStrErrNSStrength = "cannot get nightshift strength";
static const char *gStrErrInvalidNSStrength
                                     = "nightshift strength must be 0.0-1.0";
static const char *gStrErrNSSetStrength
                                     = "cannot change nightshift strength";
static const char *gStrErrNSSetState = "cannot update nightshift state";
static const char *gStrErrNSMode     = "cannot change nightshift schedule";
static const char *gStrErrNSBadSched = "invalid schedule";

/* prototypes */

static bool isNightShiftAvailable(void);
static bool setNightShiftEnabled(bool status);
static bool isValidHourForNightShift(int hr);
static bool isValidMinForNightShift(int min);

/* private functions */

/* isNightShiftAvailable - check to see if nightshift is available */

static bool isNightShiftAvailable(void)
{
    return [CBBlueLightClient supportsBlueLightReduction];
}

/* setNightShiftEnabled - set the nightshift status */

static bool setNightShiftEnabled(bool status)
{
    CBBlueLightClient *blueLightClient = nil;
    float nightShiftStrength = 0;

    if (isNightShiftAvailable() != true)
    {
        fprintf(stderr, "error: %s\n", gStrErrNoNS);
        return false;
    }

    blueLightClient = [[CBBlueLightClient alloc] init];
    if (blueLightClient == nil)
    {
        fprintf(stderr, "error: %s\n", gStrErrNoNSClient);
        return false;
    }

    /*
        if nightshift is being enabled, but the current strength
        is 0 (or less, which shouldn't happen), set the strength
        to 1.0 (maximum)
    */

    if (status == true)
    {
        if ([blueLightClient getStrength: &nightShiftStrength] == true &&
            nightShiftStrength <= 0.0)
        {
             [blueLightClient setStrength: 1.0 commit: TRUE];
        }
    }

    [blueLightClient setEnabled: status];
    [blueLightClient release];

    return true;
}

/* isValidHour - check if the specified number is a valid hour */

static bool isValidHourForNightShift(int hr)
{
    return (hr >= 0 && hr <= 23);
}

/* isValidMin - check if the specified number is a valid minute */

static bool isValidMinForNightShift(int min)
{
    return (min >= 0 && min <= 59);
}

/* public functions */

/* printNightShiftUsage - print usage message for nightshift mode */

void printNightShiftUsage(void)
{
    /* basic usage */
    
    fprintf(stderr,
            "%s [%s|%s] [%s|%s|%s|%s]\n",
            gPgmName,
            gStrModeNightShiftLong,
            gStrModeNightShiftShort,
            gStrOn,
            gStrEnable,
            gStrOff,
            gStrDisable);

    /* set strength */
    
    fprintf(stderr,
            "%s [%s|%s] [%s]\n",
            gPgmName,
            gStrModeNightShiftLong,
            gStrModeNightShiftShort,
            gStrNightShiftRange);

    /* schedule */
    
    fprintf(stderr,
            "%s [%s|%s] [%s [%s|%s|%s]]\n",
            gPgmName,
            gStrModeNightShiftLong,
            gStrModeNightShiftShort,
            gStrModeNightShiftSchedule,
            gStrDisable,
            gStrModeNightShiftScheduleSunset,
            gStrNightShiftScheduleRange);
}

/* printNightShiftStatus - print the current status of nightshift */

bool printNightShiftStatus(nightShiftStatus_t status)
{
    CBBlueLightClient *blueLightClient = nil;
    CBBlueLightClient_StatusData_t blueLightStatus;
    float nightShiftStrength = 0;

    if (isNightShiftAvailable() != true)
    {
        fprintf(stderr,
                "%s: error: %s\n",
                gStrModeNightShiftLong,
                gStrErrNoNS);
        return false;
    }

    blueLightClient = [[CBBlueLightClient alloc] init];
    if (blueLightClient == nil)
    {
        fprintf(stderr,
                "%s: error: %s\n",
                gStrModeNightShiftLong,
                gStrErrNoNSClient);
        return false;
    }

    if ([blueLightClient getBlueLightStatus: &blueLightStatus] != true)
    {
        fprintf(stderr,
                "%s: error: %s\n",
                gStrModeNightShiftLong,
                gStrErrNSStatus);
        [blueLightClient release];
        return false;
    }

    if (status == nightShiftStatusAll ||
        status == nightShiftStatusStrengthOnly)
    {
        if ([blueLightClient getStrength: &nightShiftStrength] != true)
        {
            fprintf(stderr,
                    "%s: error: %s\n",
                    gStrModeNightShiftLong,
                    gStrErrNSStrength);
            [blueLightClient release];
            return false;
        }
    }

    if (status == nightShiftStatusAll)
    {
        fprintf(stdout,
                "%s: %s",
                gStrModeNightShiftLong,
                (blueLightStatus.enabled == true ? gStrOn : gStrOff));
    }

    /*
        check the nightshift mode and print out the nightshift schedule:

        mode == 0: no schedule
        mode == 1: sunset to sunrise
        mode == 2: custom schedule
    */

    if (status == nightShiftStatusAll ||
        status == nightShiftStatusScheduleOnly)
    {
        if (blueLightStatus.mode != 0) {
            if (blueLightStatus.sunsetToSunrise == true &&
                blueLightStatus.mode == 1)
            {
                if (status == nightShiftStatusAll)
                {
                    fprintf(stdout, ", schedule is from %s", gStrNightSiftScheduleSunset);
                }
                else
                {
                    fprintf(stdout, 
                            "%s: %s: %s\n", 
                            gStrModeNightShiftSchedule,
                            gStrModeNightShiftLong,
                            gStrNightSiftScheduleSunset);
                }
            }
            else
            {
                if (status == nightShiftStatusAll)
                {
                    fprintf(stdout,
                            ", schedule is from %d:%02d to %d:%02d",
                            blueLightStatus.schedule.from.hour,
                            blueLightStatus.schedule.from.minute,
                            blueLightStatus.schedule.to.hour,
                            blueLightStatus.schedule.to.minute);
                }
                else 
                {
                    fprintf(stdout,
                            "%s: %s: %d:%02d to %d:%02d\n",
                            gStrModeNightShiftLong,
                            gStrModeNightShiftSchedule,
                            blueLightStatus.schedule.from.hour,
                            blueLightStatus.schedule.from.minute,
                            blueLightStatus.schedule.to.hour,
                            blueLightStatus.schedule.to.minute);
                }
            }
        }
        else if (status == nightShiftStatusScheduleOnly)
        {
            fprintf(stdout, 
            "%s: %s: %s\n", 
            gStrModeNightShiftLong,
            gStrModeNightShiftSchedule, 
            gStrNightShiftScheduleNone);        
        }
    }

    if (status == nightShiftStatusAll ||
        status == nightShiftStatusStrengthOnly)
    {
        fprintf(stdout, ", strength: %0.2f\n", nightShiftStrength);
    }

    [blueLightClient release];

    return true;
}

/* nightShiftEnable - enable nightshift */

bool nightShiftEnable(void)
{
    return setNightShiftEnabled(true);
}

/* nightShiftDisable - disable nightshift */

bool nightShiftDisable(void)
{
    return setNightShiftEnabled(false);
}

/* setNightShiftStrength - set nightshift's strength */

bool setNightShiftStrength(float strength)
{
    CBBlueLightClient *blueLightClient = nil;
    bool retcode = false;

    if (strength < 0.0 || strength > 1.0)
    {
        fprintf(stderr, "error: %s\n", gStrErrInvalidNSStrength);
        return retcode;
    }

    if (isNightShiftAvailable() != true)
    {
        fprintf(stderr, "error: %s\n", gStrErrNoNS);
        return retcode;
    }

    blueLightClient = [[CBBlueLightClient alloc] init];
    if (blueLightClient == nil)
    {
        fprintf(stderr, "error: %s\n", gStrErrNoNSClient);
        return retcode;
    }

    if ([blueLightClient setStrength: strength commit: TRUE] != true)
    {
        fprintf(stderr, "error: %s\n", gStrErrNSSetStrength);
        [blueLightClient release];
        return retcode;
    }

    retcode = [blueLightClient setEnabled: (strength == 0.0 ? FALSE : TRUE)];
    [blueLightClient release];

    if (retcode != true)
    {
        fprintf(stderr, "error: %s\n", gStrErrNSSetState);
    }

    return retcode;
}

/* nightShiftScheduleDisable - disable the nightshift schedule */

bool nightShiftScheduleDisable(void)
{
    CBBlueLightClient *blueLightClient = nil;
    bool retcode = false;

    if (isNightShiftAvailable() != true)
    {
        fprintf(stderr, "error: %s\n", gStrErrNoNS);
        return retcode;
    }

    blueLightClient = [[CBBlueLightClient alloc] init];
    if (blueLightClient == nil)
    {
        fprintf(stderr, "error: %s\n", gStrErrNoNSClient);
        return retcode;
    }

    retcode = [blueLightClient setMode: CBBlueLightClientModeNoSchedule];
    [blueLightClient release];

    if (retcode != true)
    {
        fprintf(stderr, "error: %s\n", gStrErrNSMode);
    }

    return retcode;
}

/*
    nightShiftScheduleSunsetSunrise - set the nightshift schedule to be
                                      sunset to sunrise
*/

bool nightShiftScheduleSunsetSunrise(void)
{
    CBBlueLightClient *blueLightClient = nil;
    bool retcode = false;

    if (isNightShiftAvailable() != true)
    {
        fprintf(stderr, "error: %s\n", gStrErrNoNS);
        return retcode;
    }

    blueLightClient = [[CBBlueLightClient alloc] init];
    if (blueLightClient == nil)
    {
        fprintf(stderr, "error: %s\n", gStrErrNoNSClient);
        return retcode;
    }

    retcode = [blueLightClient setMode: CBBlueLightClientModeSunsetSunrise];
    [blueLightClient release];

    if (retcode != true)
    {
        fprintf(stderr, "error: %s\n", gStrErrNSMode);
    }

    return retcode;
}

/* nightShiftSchedule - set the nightshift schedule */

bool nightShiftSchedule(int startHr, int startMin, int endHr, int endMin)
{
    CBBlueLightClient_Schedule_t schedule;
    CBBlueLightClient *blueLightClient = nil;
    bool retcode = false;

    if (isNightShiftAvailable() != true)
    {
        fprintf(stderr, "error: %s\n", gStrErrNoNS);
        return retcode;
    }

    if (isValidHourForNightShift(startHr) != true ||
        isValidMinForNightShift(startMin) != true ||
        isValidHourForNightShift(endHr) != true ||
        isValidMinForNightShift(endMin) != true)
    {
        fprintf(stderr, 
                "error: %s: '%02d:%02d' to %02d:%02d'\n", 
                gStrErrNSBadSched,
                startHr,
                startMin,
                endHr,
                endMin);
        return retcode;
    }
    
    schedule.from.hour = startHr;
    schedule.from.minute = startMin;
    schedule.to.hour = endHr;
    schedule.to.minute = endMin;
    
    blueLightClient = [[CBBlueLightClient alloc] init];
    if (blueLightClient == nil)
    {
        fprintf(stderr, "error: %s\n", gStrErrNoNSClient);
        return retcode;
    }
    
    if ([blueLightClient setSchedule: &schedule] != true)
    {
        fprintf(stderr, "error: %s\n", gStrErrNSMode);
        [blueLightClient release];
        return retcode;
    }
    
    retcode = [blueLightClient setMode: CBBlueLightClientModeCustomSchedule];
    [blueLightClient release];

    if (retcode != true)
    {
        fprintf(stderr, "error: %s\n", gStrErrNSMode);
    }

    return retcode;
}

/* 
    strToTimeComponents - if an argument is a valid time ([h]h:mm), 
                          split it into its hour and minute components
*/

bool strToTimeComponents(const char *arg, int *hour, int *min)
{
    NSString *argStr = nil, *hrStr = nil, *minStr = nil;
    NSArray *argComponents = nil;
    NSCharacterSet *notDigits = nil;
    int hourRaw = 0, minRaw = 0;
    
    if (arg == NULL || hour == NULL || min == NULL)
    {
        return false;
    }

    argStr = [[NSString alloc] initWithUTF8String: arg];
    if (argStr == nil)
    {
        return false;
    }

    /* 
        if the argument is a valid time it should be in the form [h]h:mm, 
        so the array created by splitting the argument should only have
        2 components. 
    */
        
    argComponents = [argStr componentsSeparatedByString:@":"];
    if (argComponents == nil)
    {
        [argStr release];
        return false;
    }

    /* invalid time if there are more than 2 substrings */
    
    if ([argComponents count] != 2 ||
        [[argComponents objectAtIndex: 0] 
            isKindOfClass:[NSString class]] != true ||
        [[argComponents objectAtIndex: 1] 
            isKindOfClass:[NSString class]] != true)
    {
        [argComponents release];
        [argStr release];
        return false;
    }

    hrStr = [argComponents objectAtIndex: 0];
    minStr = [argComponents objectAtIndex: 1];

    /* 
        valid hour and min should contain only digits, the hour string should 
        be no longer than 2 numbers, and the min string should contains exactly 
        two numbers
        based on: https://samplecodebank.blogspot.com/2013/06/NSCharacterSet-decimalDigitCharacterSet-example.html
    */
    
    notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    
    if ([hrStr isEqualToString: @""] ||
        [hrStr length] > 2 ||
        [hrStr rangeOfCharacterFromSet: notDigits].location != NSNotFound ||
        [minStr isEqualToString: @""] ||
        [minStr length] != 2 ||
        [minStr rangeOfCharacterFromSet: notDigits].location != NSNotFound)
    {
        [notDigits release];
        [argComponents release];
        [argStr release];
        return false;
    }
    
    hourRaw = [hrStr intValue];
    minRaw = [minStr intValue];

    [notDigits release];
    [argComponents release];
    [argStr release];

    /* check if the hour and min are valid */
    
    if (isValidHourForNightShift(hourRaw) != true || 
        isValidMinForNightShift(minRaw) != true)
    {
        return false;
    }   
        
    *hour = hourRaw;
    *min = minRaw;
    
    return true;
}
