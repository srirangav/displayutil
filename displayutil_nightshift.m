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
const char *gStrModeNightShiftScheduleNone   = "none";

/* nightshift constants */

static const char *gStrNightShiftRange = "0.0 - 1.0";
static const char *gStrScheduleSunset  = "sunset to sunrise";

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

/* prototypes */

static bool isNightShiftAvailable(void);
static bool setNightShiftEnabled(bool status);

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

/* public functions */

/* printNightShiftUsage - print usage message for nightshift mode */

void printNightShiftUsage(void)
{
    fprintf(stderr,
            "%s [%s|%s] [[%s|%s|%s|%s] | [%s [%s|%s]] | %s]\n",
            gPgmName,
            gStrModeNightShiftLong,
            gStrModeNightShiftShort,
            gStrOn,
            gStrEnable,
            gStrOff,
            gStrDisable,
            gStrModeNightShiftSchedule,
            gStrModeNightShiftScheduleSunset,
            gStrDisable,
            gStrNightShiftRange);
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
                    fprintf(stdout, 
                            ", %s: %s", 
                            gStrModeNightShiftSchedule,
                            gStrScheduleSunset);
                }
                else
                {
                    fprintf(stdout, 
                            "%s: %s: %s\n", 
                            gStrModeNightShiftSchedule,
                            gStrModeNightShiftLong,
                            gStrScheduleSunset);
                }
            }
            else
            {
                if (status == nightShiftStatusAll)
                {
                    fprintf(stdout,
                            ", %s: %2d:%02d to %2d:%02d",
                            gStrModeNightShiftSchedule,
                            blueLightStatus.schedule.from.hour,
                            blueLightStatus.schedule.from.minute,
                            blueLightStatus.schedule.to.hour,
                            blueLightStatus.schedule.to.minute);
                }
                else 
                {
                    fprintf(stdout,
                            "%s: %s: %2d:%02d to %2d:%02d\n",
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
            gStrModeNightShiftScheduleNone);        
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
