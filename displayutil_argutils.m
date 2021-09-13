/*
    displayutil - displayutil_argutils.m

    command line argument handling utility functions
    
    History:

    v. 1.0.0 (04/06/2021) - Initial version
    v. 1.0.1 (04/15/2021) - Restrict args to exact matches
    v. 1.0.2 (09/05/2021) - add help mode
    v. 1.0.3 (09/07/2021) - add verbose mode
  
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

#import <strings.h>
#import "displayutil_argutils.h"

/* program name */

const char *gPgmName = "displayutil";

/* option strings */

const char *gStrEnable  = "enable";
const char *gStrOn      = "on";
const char *gStrDisable = "disable";
const char *gStrOff     = "off";
const char *gStrMain    = "main";
const char *gStrAll     = "all";
const char *gStrModeHelpShort     = "-h";
const char *gStrModeHelpLong      = "-help";
const char *gStrModeVerboseShort  = "-v";
const char *gStrModeVerboseLong   = "-verbose";
const char *gStrModeExtendedShort = "-e";
const char *gStrModeExtendedLong  = "-extended";
const char *gStrModeHiddenLong    = "-hidden";

const char *gStrStatus  = "status";
const char *gStrUnavail = "unavailable";
const char *gStrDisp    = "display id";

/* maximum number of supported displays */

const UInt32 gMaxDisplays = MAXDISPLAYS;

/* error messages */

const char *gStrErrGetDisplays   = "cannot get display information";
const char *gStrErrNoSuchDisplay = "display not found";


/* isArg - check if the arg is the requested mode */

bool isArg(const char *arg,
           const char *longMode,
           const char *shortMode)
{
    size_t modeStrLen = 0;
    
    if (arg == NULL || arg[0] == '\0')
    {
        return false;
    }

    if (longMode != NULL) 
    {
        modeStrLen = strlen(longMode);
        if (strncasecmp(arg, longMode, modeStrLen) == 0)
        {
            return (strlen(arg) == modeStrLen ? true : false);
        }
    }

    if (shortMode != NULL)
    {
        modeStrLen = strlen(shortMode);
        if (strncasecmp(arg, shortMode, modeStrLen) == 0)
        {
            return (strlen(arg) == modeStrLen ? true : false);
        }
    }

    return false;
}

/* isArgEnable - check if the arg is enable mode */

bool isArgEnable(const char *arg)
{
    return isArg(arg, gStrEnable, gStrOn);
}

/* isArgDisable - check if the arg is disable mode */

bool isArgDisable(const char *arg)
{
    return isArg(arg, gStrDisable, gStrOff);
}

/* isArgHelp - check if the arg is help mode */

bool isArgHelp(const char *arg)
{
    return isArg(arg, gStrModeHelpLong, gStrModeHelpShort);
}

/* isArgVerbose - check if the arg is verbose mode */

bool isArgVerbose(const char *arg)
{
    return isArg(arg, gStrModeVerboseLong, gStrModeVerboseShort);
}

/* isArgExtended - check if the arg is extended mode */

bool isArgExtended(const char *arg)
{
    return isArg(arg, gStrModeExtendedLong, gStrModeExtendedShort);
}

/* isArgHidden - check if the arg is hidden mode */

bool isArgHidden(const char *arg)
{
    return isArg(arg, gStrModeHiddenLong, NULL);
}
