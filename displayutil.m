/*
    displayutil - displayutil.m

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

/*
    cc -W -Wall -Wextra -Wshadow -Wcast-qual -Wmissing-declarations \
       -Wmissing-prototypes -Werror=format-security \
       -Werror=implicit-function-declaration \
       -D_FORTIFY_SOURCE=2 -D_GLIBCXX_ASSERTIONS \
       -fasynchronous-unwind-tables -fexceptions -fpic \
       -fstack-protector-all -fstack-protector-strong -fwrapv \
       -F /System/Library/PrivateFrameworks \
       -framework UniversalAccess \
       -framework SkyLight \
       -framework ApplicationServices \
       -framework CoreBrightness \
       -o displayutil \
       displayutil_listDisplays.m \
       displayutil_grayscale.m \
       displayutil_darkmode.m \
       displayutil.m
*/

#import <stdio.h>
#import <string.h>
#import <strings.h>

#import <ApplicationServices/ApplicationServices.h>

#ifndef NO_NS
#import <stdlib.h>
#import "CBBlueLightClient.h"
#endif /* NO_NS */

#import <objc/objc.h>

#import "displayutil_listDisplays.h"
#import "displayutil_grayscale.h"
#ifndef NO_DM
#import "displayutil_darkmode.h"
#endif /* NO_DM */

/* program name */

static const char *gPgmName = "displayutil";

enum
{
    gDisplayUtilECOkay = 0,
    gDisplayUtilECErr  = 1,
};

/* modes */

static const char *gStrModeHelpShort         = "-h";
static const char *gStrModeHelpLong          = "-help";
#ifndef NO_NS
static const char *gStrModeNightShiftLong    = "nightshift";
static const char *gStrModeNightShiftShort   = "ns";
#endif /* NO_NS */

/* commands */

static const char *gStrEnable  = "enable";
static const char *gStrOn      = "on";

static const char *gStrDisable = "disable";
static const char *gStrOff     = "off";

/* nightshift related constants */

#ifndef NO_NS
static const float gNightShiftDisable   = 0.0;
static const char *gStrNightShiftRange  = "0.0 - 1.0";
#endif /* NO_NS */

/* error messages */

static const char *gStrErrListDisplays = "cannot list displays";
#ifndef NO_NS
static const char *gStrErrNoNS          = "nightshift not supported";
static const char *gStrErrNoNSClient    = "cannot create a nightshift client";
static const char *gStrErrNSStatus      = "cannot get nightshift status";
static const char *gStrErrNSStrength    = "cannot get nightshift strength";
#endif /* NO_NS */

/* prototypes */

static bool isArg(const char *arg,
                  const char *longMode,
                  const char *shortMode);
static bool isArgEnable(const char *arg);
static bool isArgDisable(const char *arg);

/* isArg - check if the arg is the requested mode */

static bool isArg(const char *arg,
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

static bool isArgEnable(const char *arg)
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

static bool isArgDisable(const char *arg)
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

/* main */

int main (int argc, char** argv)
{

    bool listMainDisplayOnly = false;

#ifndef NO_NS
    CBBlueLightClient *blueLightClient = nil;
    CBBlueLightClient_StatusData_t blueLightStatus;
    float nightShiftStrength = gNightShiftDisable;
    char *endptr = NULL;
#endif /* NO_NS */

    /*
        print a usage message if help mode was specified or if no mode was
        specified
    */

    if (argc < 2 || argv[1] == NULL ||
        isArg(argv[1], gStrModeHelpLong, gStrModeHelpShort) == true)
    {

        /* darkmode usage */

#ifndef NO_DM
        fprintf(stderr,
                "%s [%s|%s] [%s|%s|%s|%s]\n",
                gPgmName,
                gStrModeDarkModeLong,
                gStrModeDarkModeShort,
                gStrOn,
                gStrEnable,
                gStrOff,
                gStrDisable);
#endif /* NO_DM */

        /* grayscale usage */

        fprintf(stderr,
                "%s [%s|%s] [%s|%s|%s|%s]\n",
                gPgmName,
                gStrModeGrayscaleLong,
                gStrModeGrayscaleShort,
                gStrOn,
                gStrEnable,
                gStrOff,
                gStrDisable);

        /* list displays usage */

        fprintf(stderr,
                "%s [%s|%s [%s|%s]]\n",
                gPgmName,
                gStrModeListDisplaysLong,
                gStrModeListDisplaysShort,
                gStrModeListDisplaysAll,
                gStrModeListDisplaysMain);

        /* nightshift usage */

#ifndef NO_NS
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
#endif /* NO_NS */

        return gDisplayUtilECOkay;
    }

    /* dark mode */

#ifndef NO_DM
    if (isArg(argv[1], gStrModeDarkModeLong, gStrModeDarkModeShort) == true)
    {

        /* if no arguments, just display the current darkmode setting */

        if (argc < 3 ||
            argv[2] == NULL || argv[2][0] == '\0')
        {
            fprintf(stdout,
                    "%s: %s\n",
                    gStrModeDarkModeLong,
                    isDarkModeEnabled() ? gStrOn : gStrOff);
                return gDisplayUtilECOkay;
        }

        /* enable darkmode */

        if (isArgEnable(argv[2]))
        {
            return (darkModeEnable() ?
                gDisplayUtilECOkay : gDisplayUtilECErr);
        }

        /* disable darkmode */

        if (isArgDisable(argv[2]))
        {
            return (darkModeDisable() ?
                gDisplayUtilECOkay : gDisplayUtilECErr);
        }

        /* unknown or unsupported option for darkmode */

        fprintf(stderr,
                "%s: error: %s: invalid argument: '%s'\n",
                 gPgmName,
                 gStrModeDarkModeLong,
                 argv[2]);

        return gDisplayUtilECErr;
    }
#endif /* NO_DM */

    /* grayscale */

    if (isArg(argv[1], gStrModeGrayscaleLong, gStrModeGrayscaleShort))
    {

        /* if no arguments, just display the current grayscale setting */

        if (argc < 3 ||
            argv[2] == NULL || argv[2][0] == '\0')
        {
            fprintf(stdout,
                    "%s: %s\n",
                    gStrModeGrayscaleLong,
                    isGrayScaleEnabled() ? gStrOn : gStrOff);
            return gDisplayUtilECOkay;
         }

        /* enable grayscale */

        if (isArgEnable(argv[2]) == true)
        {
            grayScaleEnable();
            return gDisplayUtilECOkay;
        }

        /* disable grayscale */

        if (isArgDisable(argv[2]) == true)
        {
            grayScaleDisable();
            return gDisplayUtilECOkay;
        }

        /* unknown or unsupported option for grayscale */

        fprintf(stderr,
                "%s: error: %s: invalid argument: '%s'\n",
                 gPgmName,
                 gStrModeGrayscaleLong,
                 argv[2]);
        return gDisplayUtilECErr;
    }

    /* list displays */

    if (isArg(argv[1], gStrModeListDisplaysLong, gStrModeListDisplaysShort))
    {
        if (argc < 3)
        {
            listMainDisplayOnly = false;
        }
        else if (isArg(argv[2], gStrModeListDisplaysAll, NULL) == true)
        {
            listMainDisplayOnly = false;
        }
        else if (isArg(argv[2], gStrModeListDisplaysMain, NULL) == true)
        {
            listMainDisplayOnly = true;
        }
        else
        {
            fprintf(stderr,
                    "%s: error: %s: invalid argument: '%s'\n",
                     gPgmName,
                     gStrModeListDisplaysLong,
                     argv[2]);
            return gDisplayUtilECErr;
        }

        if (listMainDisplayOnly == true)
        {
            if (listMainDisplay() != true)
            {
                fprintf(stderr,
                        "%s: error: %s: %s\n",
                        gPgmName,
                        gStrModeListDisplaysLong,
                        gStrErrListDisplays);
                return gDisplayUtilECErr;
            }
        }
        else
        {
            if (listAllDisplays() != true)
            {
                fprintf(stderr,
                        "%s: error: %s: %s\n",
                        gPgmName,
                        gStrModeListDisplaysLong,
                        gStrErrListDisplays);
                return gDisplayUtilECErr;
            }
        }

        return gDisplayUtilECOkay;
    }

    /* nightshift */

#ifndef NO_NS
    if (isArg(argv[1], gStrModeNightShiftLong, gStrModeNightShiftShort))
    {
        /* check if nightshift is support */

        if ([CBBlueLightClient supportsBlueLightReduction] != true)
        {
            fprintf(stderr,
                    "%s: error: %s: %s\n",
                    gPgmName,
                    gStrModeNightShiftLong,
                    gStrErrNoNS);
            return gDisplayUtilECErr;
        }

        /* create a blue light client */

        blueLightClient = [[CBBlueLightClient alloc] init];
        if (blueLightClient == nil)
        {
            fprintf(stderr,
                    "%s: error: %s: %s\n",
                    gPgmName,
                    gStrModeNightShiftLong,
                    gStrErrNoNSClient);
            return gDisplayUtilECErr;
        }

        /* if no arguments, just display the current nightshift setting */

        if (argc < 3 ||
            argv[2] == NULL || argv[2][0] == '\0')
        {

            /* get the current nightshift status */

            if ([blueLightClient getBlueLightStatus: &blueLightStatus] != true)
            {
                fprintf(stderr,
                        "%s: error: %s: %s\n",
                        gPgmName,
                        gStrModeNightShiftLong,
                        gStrErrNSStatus);
                [blueLightClient release];
                return gDisplayUtilECErr;
            }

            /* get the strength of the blue light setting */

            if ([blueLightClient getStrength: &nightShiftStrength] != true)
            {
                fprintf(stderr,
                        "%s: error: %s: %s\n",
                        gPgmName,
                        gStrModeNightShiftLong,
                        gStrErrNSStrength);
                [blueLightClient release];
                return gDisplayUtilECErr;
            }

            /* print out the current blue light status and strength */

            fprintf(stdout,
                    "%s: %s (strength = %f)\n",
                    gStrModeNightShiftLong,
                    (blueLightStatus.enabled == 1 ? gStrOn : gStrOff),
                    nightShiftStrength);
            [blueLightClient release];
            return gDisplayUtilECOkay;
        }

        /* TODO - check for failures */

        /* enable nightshift */

        if (isArgEnable(argv[2]))
        {
            [blueLightClient setEnabled: TRUE];
            [blueLightClient release];
            return gDisplayUtilECOkay;
        }

        /* disable nightshift */

        if (isArgDisable(argv[2]))
        {
            [blueLightClient setEnabled: FALSE];
            [blueLightClient release];
            return gDisplayUtilECOkay;
        }

        /* see if a valid setting was specified */

        nightShiftStrength = strtof(argv[2], &endptr);
        if ((nightShiftStrength >= 0.0 &&
             nightShiftStrength <= 1.0) &&
             (endptr == NULL || endptr[0] == '\0'))
        {
            [blueLightClient setStrength: nightShiftStrength commit: TRUE];
            [blueLightClient setEnabled:
                (nightShiftStrength == 0.0 ? FALSE : TRUE)];
            [blueLightClient release];
            return gDisplayUtilECOkay;
        }

        /* unknown or unsupported option for nightshift */

        fprintf(stderr,
                "%s: error: %s: invalid argument: '%s'\n",
                 gPgmName,
                 gStrModeNightShiftLong,
                 argv[2]);
        [blueLightClient release];
        return gDisplayUtilECErr;
    }
#endif /* NO_NS */

    /* unsupported or unknown mode */

    fprintf(stderr,
            "%s: error: invalid argument: '%s'\n",
            gPgmName,
            argv[1]);
    return gDisplayUtilECErr;
}
