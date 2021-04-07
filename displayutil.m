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

#import <stdio.h>
#import <string.h>
#import <strings.h>

#import <ApplicationServices/ApplicationServices.h>
#import <Foundation/Foundation.h>
#import <objc/objc.h>

#import "displayutil_argutils.h"
#import "displayutil_listDisplays.h"
#import "displayutil_grayscale.h"
#ifndef NO_NS
#import "displayutil_nightshift.h"
#endif /* NO_NS */
#ifndef NO_DM
#import "displayutil_darkmode.h"
#endif /* NO_DM */

enum
{
    gDisplayUtilECOkay = 0,
    gDisplayUtilECErr  = 1,
};

/* modes */

static const char *gStrModeHelpShort         = "-h";
static const char *gStrModeHelpLong          = "-help";

/* prototypes */

static void printUsage(void);

/* printUsage - print out the usage message */

static void printUsage(void)
{
#ifndef NO_DM
    printDarkModeUsage();
#endif /* NO_DM */

    printGrayScaleUsage();

    printListDisplaysUsage();

#ifndef NO_NS
    printNightShiftUsage();
#endif /* NO_NS */
}

/* main */

int main (int argc, char** argv)
{
    bool listMainDisplayOnly = false;
#ifndef NO_NS
    float nightShiftStrength = 0;
    char *endptr = NULL;
#endif /* NO_NS */

    /*
        print a usage message if help mode was specified or if no mode was
        specified
    */

    if (argc < 2 ||
        argv[1] == NULL ||
        isArg(argv[1], gStrModeHelpLong, gStrModeHelpShort) == true)
    {
        printUsage();
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

        if (isArgEnable(argv[2]) == true)
        {
            return (darkModeEnable() ?
                gDisplayUtilECOkay : gDisplayUtilECErr);
        }

        /* disable darkmode */

        if (isArgDisable(argv[2]) == true)
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

        printDarkModeUsage();

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

        printGrayScaleUsage();

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
            printListDisplaysUsage();
            return gDisplayUtilECErr;
        }

        if (listMainDisplayOnly == true)
        {
            return (listMainDisplay() == true ?
                        gDisplayUtilECOkay : gDisplayUtilECErr);
        }

        return (listAllDisplays() == true ?
                    gDisplayUtilECOkay : gDisplayUtilECErr);
    }

    /* nightshift */

#ifndef NO_NS
    if (isArg(argv[1], gStrModeNightShiftLong, gStrModeNightShiftShort))
    {

        /* if no arguments, just display the current nightshift setting */

        if (argc < 3)
        {
            return (printNightShiftStatus() == true ?
                       gDisplayUtilECOkay : gDisplayUtilECErr);
            return gDisplayUtilECErr;
        }

        /* enable nightshift */

        if (isArgEnable(argv[2]) == true)
        {
            return (nightShiftEnable() == true ?
                       gDisplayUtilECOkay : gDisplayUtilECErr);
        }

        /* turn off nightshift */

        if (isArg(argv[2], gStrOff, NULL) == true)
        {
            return (nightShiftDisable() == true ?
                       gDisplayUtilECOkay : gDisplayUtilECErr);
        }

        /* disable nightshift */

        if (isArg(argv[2], gStrDisable, NULL) == true)
        {
            return (setNightShiftStrength(0.0) == true ?
                       gDisplayUtilECOkay : gDisplayUtilECErr);
        }

        /* see if a valid setting was specified */

        nightShiftStrength = strtof(argv[2], &endptr);
        if ((nightShiftStrength >= 0.0 &&
             nightShiftStrength <= 1.0) &&
             (endptr == NULL || endptr[0] == '\0'))
        {
            return (setNightShiftStrength(nightShiftStrength) == true ?
                       gDisplayUtilECOkay : gDisplayUtilECErr);
        }

        /* unknown or unsupported option for nightshift */

        fprintf(stderr,
                "%s: error: %s: invalid argument: '%s'\n",
                 gPgmName,
                 gStrModeNightShiftLong,
                 argv[2]);
        printNightShiftUsage();
        return gDisplayUtilECErr;
    }
#endif /* NO_NS */

    /* unsupported or unknown mode */

    fprintf(stderr,
            "%s: error: invalid argument: '%s'\n",
            gPgmName,
            argv[1]);
    printUsage();
    return gDisplayUtilECErr;
}
