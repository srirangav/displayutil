/*
    displayutil - displayutil_argutils.m

    History:

    v. 1.0.0 (04/06/2021) - Initial version

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

#import "displayutil_argutils.h"

/* program name */

const char *gPgmName = "displayutil";

/* option strings */

const char *gStrEnable  = "enable";
const char *gStrOn      = "on";
const char *gStrDisable = "disable";
const char *gStrOff     = "off";
const char *gStrStatus  = "status";

/* isArg - check if the arg is the requested mode */

bool isArg(const char *arg,
           const char *longMode,
           const char *shortMode)
{
    if (arg == NULL || arg[0] == '\0')
    {
        return false;
    }

    if (longMode != NULL &&
        strncasecmp(arg, longMode, strlen(longMode)) == 0)
    {
        return true;
    }

    if (shortMode != NULL &&
        strncasecmp(arg, shortMode, strlen(shortMode)) == 0)
    {
        return true;
    }

    return false;
}

/* isArg - check if the arg is enable mode */

bool isArgEnable(const char *arg)
{
    if (arg == NULL)
    {
        return false;
    }

    if (strncasecmp(arg, gStrOn, strlen(gStrOn)) == 0 ||
        strncasecmp(arg, gStrEnable, strlen(gStrEnable)) == 0)
    {
        return true;
    }

    return false;
}

/* isArg - check if the arg is disable mode */

bool isArgDisable(const char *arg)
{
    if (arg == NULL)
    {
        return false;
    }

    if (strncasecmp(arg, gStrOff, strlen(gStrOff)) == 0 ||
        strncasecmp(arg, gStrDisable, strlen(gStrDisable)) == 0)
    {
        return true;
    }

    return false;
}
