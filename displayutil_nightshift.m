/*
    displayutil - displayutil_nightshift.m

    History:

    v. 1.0.0 (04/01/2021) - Initial version

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

const char *gStrModeNightShiftLong  = "nightshift";
const char *gStrModeNightShiftShort = "ns";

/* nightshift constants */

static const char *gStrNightShiftRange = "0.0 - 1.0";

/* error messages */

static const char *gStrErrNoNS       = "nightshift not supported";
static const char *gStrErrNoNSClient = "cannot create a nightshift client";
static const char *gStrErrNSStatus   = "cannot get nightshift status";
static const char *gStrErrNSStrength = "cannot get nightshift strength";
static const char *gStrErrInvalidNSStrength
                                     = "nightshift strength must be 0.0-1.0";

/* prototypes */

static bool isNightShiftAvailable(void);
static bool setNightShiftEnabled(bool status);

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

/* printNightShiftUsage - print usage message for nightshift mode */

void printNightShiftUsage(void)
{
    fprintf(stderr,
            "%s [%s|%s] [[%s|%s|%s|%s] | %s]\n",
            gPgmName,
            gStrModeNightShiftLong,
            gStrModeNightShiftShort,
            gStrOn,
            gStrEnable,
            gStrOff,
            gStrDisable,
            gStrNightShiftRange);
}

/* isNightShiftEnabled - check whether nightshift is enabled */

bool printNightShiftStatus(void)
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

    if ([blueLightClient getStrength: &nightShiftStrength] != true)
    {
        fprintf(stderr,
                "%s: error: %s\n",
                gStrModeNightShiftLong,
                gStrErrNSStrength);
        [blueLightClient release];
        return false;
    }

    fprintf(stdout,
            "%s: %s (%0.4f)\n",
            gStrModeNightShiftLong,
            (blueLightStatus.enabled == true ? gStrOn : gStrOff),
            nightShiftStrength);

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

    if (strength < 0.0 || strength > 1.0)
    {
        fprintf(stderr, "error: %s\n", gStrErrInvalidNSStrength);
        return false;
    }

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

    [blueLightClient setStrength: strength commit: TRUE];
    [blueLightClient setEnabled: (strength == 0.0 ? FALSE : TRUE)];
    [blueLightClient release];

    return true;
}
