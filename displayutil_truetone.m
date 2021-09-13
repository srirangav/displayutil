/*
    displayutil - displayutil_truetone.m

    enable / disable truetone 
    
    History:

    v. 1.0.0 (04/29/2021) - Initial version

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
#import "CBTrueToneClient.h"
#import "displayutil_argutils.h"
#import "displayutil_truetone.h"

/* strings to select grayscale mode */

const char *gStrModeTrueToneLong  = "truetone";
const char *gStrModeTrueToneShort = "tt";

/* error messages */

static const char *gStrErrNoTTClient = "cannot create a truetone client";
static const char *gStrErrTTNotAvail = "truetone not available/supported";
/* prototypes */

static bool setTrueToneEnabled(bool status);

/* setTrueToneEnabled - private function to set truetone state */

static bool setTrueToneEnabled(bool status)
{
    CBTrueToneClient *trueToneClient = nil;
    bool retVal = false;
    
    trueToneClient = [[CBTrueToneClient alloc] init];
    if (trueToneClient == nil)
    {
        fprintf(stderr,
                "%s: error: %s\n",
                gStrModeTrueToneLong,
                gStrErrNoTTClient);
        return retVal;
    }
    
    if ([trueToneClient supported] == true &&
        [trueToneClient available] == true)
    {
        retVal = [trueToneClient setEnabled: status];
    }
    else
    {
        fprintf(stderr,
                "%s: error: %s\n",
                gStrModeTrueToneLong,
                gStrErrTTNotAvail);
    }
    
    [trueToneClient release];
    
    return retVal;
}

/* printTrueToneUsage - print usage message for truetone mode */

void printTrueToneUsage(void)
{
    fprintf(stderr,
            "%s [%s|%s] [%s|%s|%s|%s]\n",
            gPgmName,
            gStrModeTrueToneLong,
            gStrModeTrueToneShort,
            gStrOn,
            gStrEnable,
            gStrOff,
            gStrDisable);
}

/* isTrueToneEnabled - return true if truetone mode is on */

trueToneStatus_t isTrueToneEnabled(void)
{
    CBTrueToneClient *trueToneClient = nil;
    trueToneStatus_t retVal = trueToneNotSupported;
    
    trueToneClient = [[CBTrueToneClient alloc] init];
    if (trueToneClient == nil)
    {
        fprintf(stderr,
                "%s: error: %s\n",
                gStrModeTrueToneLong,
                gStrErrNoTTClient);
        return retVal;
    }
    
    if ([trueToneClient supported] == true &&
        [trueToneClient available] == true)
    {
        retVal = ([trueToneClient enabled] == true 
                    ? trueToneEnabled : trueToneDisabled);
    }
    
    [trueToneClient release];
    
    return retVal;
}

/* trueToneEnable - turn on truetone mode */

bool trueToneEnable(void)
{
    return setTrueToneEnabled(true);
}

/* trueToneDisable - turn off truetone mode */

bool trueToneDisable(void)
{
    return setTrueToneEnabled(false);
}
