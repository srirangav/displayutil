/*
    displayutil - displayutil.m

    displayutil command line interface

    History:

    v. 1.0.0  (04/01/2021) - Initial version
    v. 1.0.1  (04/15/2021) - Add support for nightshift schedules
    v. 1.0.2  (04/30/2021) - Add support for truetone
    v. 1.0.3  (09/03/2021) - Add support for brightness
    v. 1.0.4  (09/05/2021) - Add support for help mode for each sub mode
    v. 1.0.5  (09/07/2021) - Add support for verbose listing of display
                             information
    v. 1.0.6  (09/12/2021) - Add support for verbose and extended mode
                             listing of display information
    v. 1.0.7  (09/17/2021) - change verbose, extended, and hidden modes
                             to -l (long), -a (all), and -p (private),
                             respectively
    v. 1.0.8  (04/27/2022) - add support for setting the main display's
                             brightness
    v. 1.0.9  (04/30/2022) - add support for setting display resolutions
    v. 1.0.10 (11/12/2022) - list display resolution when no argument or
                             just a display is specified for resolution
                             mode

    Copyright (c) 2021-2022 Sriranga R. Veeraraghavan <ranga@calalum.org>

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
#import <Foundation/Foundation.h>

#import "displayutil_display.h"
#import "displayutil_argutils.h"
#import "displayutil_listDisplays.h"
#import "displayutil_grayscale.h"
#import "displayutil_brightness.h"
#import "displayutil_resolution.h"
#ifndef NO_DM
#import "displayutil_darkmode.h"
#endif /* NO_DM */
#ifndef NO_NS
#import "displayutil_nightshift.h"
#endif /* NO_NS */
#ifndef NO_TT
#import "displayutil_truetone.h"
#endif /* NO_TT */

enum
{
    gDisplayUtilECOkay = 0,
    gDisplayUtilECErr  = 1,
};

/* prototypes */

static void printUsage(void);

/* printUsage - print out the usage message */

static void printUsage(void)
{
    printBrightnessUsage();

#ifndef NO_DM
    printDarkModeUsage();
#endif /* NO_DM */

    printGrayScaleUsage();

    printListDisplaysUsage();

#ifndef NO_NS
    printNightShiftUsage();
#endif /* NO_NS */

#ifndef NO_TT
    printTrueToneUsage();
#endif /* NO_TT */

    printResolutionUsage();
}

/* main */

int main (int argc, char** argv)
{
    bool listMainDisplayOnly = false;
    bool setMainDisplayResolution = false, inPts = false;
    list_mode_t verbose = LIST_SHORT;
    unsigned long displayId = 0, width = 0, height = 0;
    char *endptr = NULL;
    float brightness = 0.0;
    int rc = gDisplayUtilECOkay;
    int argIndex = 0;
#ifndef NO_NS
    float nightShiftStrength = 0.0;
    int startHr = 0, startMin = 0, endHr = 0, endMin = 0;
#endif /* NO_NS */
#ifndef NO_TT
    trueToneStatus_t ttStatus;
#endif /* NO_TT */

@autoreleasepool
    {

    /*
        print a usage message if help mode was specified or if no mode was
        specified
    */

    if (argc < 2 || argv[1] == NULL || isArgHelp(argv[1]) == true)
    {
        printUsage();
        return rc;
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
                return rc;
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

        if (isArgHelp(argv[2]) != true)
        {
            fprintf(stderr,
                    "%s: error: %s: invalid argument: '%s'\n",
                     gPgmName,
                     gStrModeDarkModeLong,
                     argv[2]);
            rc = gDisplayUtilECErr;
        }

        printDarkModeUsage();

        return rc;
    }
#endif /* NO_DM */

    /* grayscale */

    if (isArg(argv[1], gStrModeGrayscaleLong, gStrModeGrayscaleShort))
    {

        /* if no arguments, just display the current grayscale setting */

        if (argc < 3 || argv[2] == NULL || argv[2][0] == '\0')
        {
            fprintf(stdout,
                    "%s: %s\n",
                    gStrModeGrayscaleLong,
                    isGrayScaleEnabled() ? gStrOn : gStrOff);
            return rc;
         }

        /* enable grayscale */

        if (isArgEnable(argv[2]) == true)
        {
            grayScaleEnable();
            return rc;
        }

        /* disable grayscale */

        if (isArgDisable(argv[2]) == true)
        {
            grayScaleDisable();
            return rc;
        }

        /* unknown or unsupported option for grayscale */

        if (isArgHelp(argv[2]) != true) {
            fprintf(stderr,
                    "%s: error: %s: invalid argument: '%s'\n",
                     gPgmName,
                     gStrModeGrayscaleLong,
                     argv[2]);
            rc = gDisplayUtilECErr;
        }

        printGrayScaleUsage();

        return rc;
    }

    /* list displays */

    if (isArg(argv[1], gStrModeListDisplaysLong, gStrModeListDisplaysShort))
    {
        /* no options were specified, just list all the display */

        if (argc < 3)
        {
            return (listAllDisplays(verbose) == true ?
                    gDisplayUtilECOkay : gDisplayUtilECErr);
        }

        // argc >= 3

        argIndex = 2;

        /* check if the verbose option specified */

        if (isArgLong(argv[argIndex]) == true)
        {
            verbose = LIST_SUPPORTED;
            argIndex++;
        }
        else if (isArgAll(argv[argIndex]) == true  ||
                 isArgAllLong(argv[argIndex]) == true)
        {
            verbose = LIST_EXTENDED;
            argIndex++;
        }
        else if (isArgPrivate(argv[argIndex]) == true)
        {
            verbose = LIST_HIDDEN;
            argIndex++;
        }

        /*
            list all the display in verbose mode, if only the verbose
            option was specified
        */

        if (argc < argIndex+1)
        {
            return (listAllDisplays(verbose) == true ?
                    gDisplayUtilECOkay : gDisplayUtilECErr);
        }

        if (isArg(argv[argIndex], gStrAll, NULL) == true)
        {
            listMainDisplayOnly = false;
        }
        else if (isArg(argv[argIndex], gStrMain, NULL) == true)
        {
            listMainDisplayOnly = true;
        }
        else if (isArgHelp(argv[argIndex]) == true)
        {
            printListDisplaysUsage();
            return rc;
        }
        else
        {
            /* see if there is display id to list */

            displayId = strtoul(argv[argIndex], &endptr, 0);

            if (endptr != NULL && endptr[0] != '\0')
            {
                fprintf(stderr,
                        "%s: error: %s: invalid argument: '%s'\n",
                         gPgmName,
                         gStrModeListDisplaysLong,
                         argv[argIndex]);
                printListDisplaysUsage();
                return gDisplayUtilECErr;
            }

            return (listDisplay(displayId, verbose) == true ?
                    gDisplayUtilECOkay : gDisplayUtilECErr);
        }

        if (listMainDisplayOnly == true)
        {
            return (listMainDisplay(verbose) == true ?
                    gDisplayUtilECOkay : gDisplayUtilECErr);
        }

        return (listAllDisplays(verbose) == true ?
                gDisplayUtilECOkay : gDisplayUtilECErr);
    }

    /* brightness */

    if (isArg(argv[1], gStrModeBrightnessLong, gStrModeBrightnessShort))
    {

        if (argc < 3)
        {
            listMainDisplayOnly = false;
        }
        else if (isArg(argv[2], gStrAll, NULL) == true)
        {
            listMainDisplayOnly = false;
        }
        else if (isArg(argv[2], gStrMain, NULL) == true)
        {
            listMainDisplayOnly = true;

            /*
                if a brightness level is specified for the main,
                display try to set the brightness to that level
            */

            if (argc >= 4 && argv[3] != NULL)
            {
                brightness = strtof(argv[3], &endptr);
                if ((brightness >= 0.0 &&
                     brightness <= 1.0) &&
                    (endptr == NULL || endptr[0] == '\0'))
                {
                    return (setBrightnessForMainDisplay(brightness) == true ?
                                gDisplayUtilECOkay : gDisplayUtilECErr);
                }
                else
                {
                    fprintf(stderr,
                            "%s: error: %s: invalid argument: '%s'\n",
                             gPgmName,
                             gStrModeBrightnessLong,
                             argv[3]);
                    printBrightnessUsage();
                    return gDisplayUtilECErr;
                }
            }

        }
        else if (isArgHelp(argv[2]) == true)
        {
            printBrightnessUsage();
            return rc;
        }
        else
        {
            /* see if a display id is specified */

            displayId = strtoul(argv[2], &endptr, 0);

            if (endptr != NULL && endptr[0] != '\0')
            {
                fprintf(stderr,
                        "%s: error: %s: invalid argument: '%s'\n",
                         gPgmName,
                         gStrModeBrightnessLong,
                         argv[2]);
                printBrightnessUsage();
                return gDisplayUtilECErr;
            }

            /*
                if a brightness level is specified for the display,
                try to set the display's brightness to that level
            */

            if (argc >= 4 && argv[3] != NULL)
            {
                brightness = strtof(argv[3], &endptr);
                if ((brightness >= 0.0 &&
                     brightness <= 1.0) &&
                    (endptr == NULL || endptr[0] == '\0'))
                {
                    return (setBrightnessForDisplay(displayId, brightness) == true ?
                                gDisplayUtilECOkay : gDisplayUtilECErr);
                }
                else
                {
                    fprintf(stderr,
                            "%s: error: %s: invalid argument: '%s'\n",
                             gPgmName,
                             gStrModeBrightnessLong,
                             argv[3]);
                    printBrightnessUsage();
                    return gDisplayUtilECErr;
                }
            }

            return (printBrightnessForDisplay(displayId) == true ?
                    gDisplayUtilECOkay : gDisplayUtilECErr);
        }

        if (listMainDisplayOnly == true)
        {
            return (printBrightnessForMainDisplay() == true ?
                    gDisplayUtilECOkay : gDisplayUtilECErr);
        }

        return (printBrightnessForAllDisplays() == true ?
                gDisplayUtilECOkay : gDisplayUtilECErr);

    }

    /* nightshift */

#ifndef NO_NS
    if (isArg(argv[1], gStrModeNightShiftLong, gStrModeNightShiftShort))
    {

        /* if no arguments, just display the current nightshift setting */

        if (argc < 3)
        {
            return (printNightShiftStatus(nightShiftStatusAll) == true ?
                    gDisplayUtilECOkay : gDisplayUtilECErr);
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

        /* update the nightshift schedule */

        if (isArg(argv[2], gStrModeNightShiftSchedule, NULL) == true)
        {
            if (argc < 4)
            {
                return (printNightShiftStatus(nightShiftStatusScheduleOnly) == true ?
                           gDisplayUtilECOkay : gDisplayUtilECErr);
            }

            /* disable the nightshift schedule */

            if (isArg(argv[3], gStrDisable, NULL) == true)
            {
                return (nightShiftScheduleDisable() == true ?
                       gDisplayUtilECOkay : gDisplayUtilECErr);
            }

            /* set the nightshift schedule to sunset to sunrise */

            if (isArg(argv[3],
                      gStrModeNightShiftScheduleSunset,
                      NULL) == true)
            {
                return (nightShiftScheduleSunsetSunrise() == true ?
                       gDisplayUtilECOkay : gDisplayUtilECErr);
            }

            /* see if a valid time interval was specified */

            if (argc >= 5)
            {
                if (strToTimeComponents(argv[3], &startHr, &startMin) != true)
                {
                    fprintf(stderr,
                            "%s: error: %s: %s: invalid argument: '%s'\n",
                             gPgmName,
                             gStrModeNightShiftLong,
                             gStrModeNightShiftSchedule,
                             argv[3]);
                    printNightShiftUsage();
                    return gDisplayUtilECErr;
                }

                if (strToTimeComponents(argv[4], &endHr, &endMin) != true)
                {
                    fprintf(stderr,
                            "%s: error: %s: %s: invalid argument: '%s'\n",
                             gPgmName,
                             gStrModeNightShiftLong,
                             gStrModeNightShiftSchedule,
                             argv[4]);
                    printNightShiftUsage();
                    return gDisplayUtilECErr;
                }

                return (nightShiftSchedule(startHr,
                                           startMin,
                                           endHr,
                                           endMin) == true ?
                        gDisplayUtilECOkay : gDisplayUtilECErr);
            }

            fprintf(stderr,
                    "%s: error: %s: %s: invalid argument: '%s'\n",
                     gPgmName,
                     gStrModeNightShiftLong,
                     gStrModeNightShiftSchedule,
                     argv[3]);
            printNightShiftUsage();
            return gDisplayUtilECErr;
        }

        /* see if a valid strength setting was specified */

        nightShiftStrength = strtof(argv[2], &endptr);
        if ((nightShiftStrength >= 0.0 &&
             nightShiftStrength <= 1.0) &&
             (endptr == NULL || endptr[0] == '\0'))
        {
            return (setNightShiftStrength(nightShiftStrength) == true ?
                       gDisplayUtilECOkay : gDisplayUtilECErr);
        }

        /* unknown or unsupported option for nightshift */

        if (isArgHelp(argv[2]) != true)
        {
            fprintf(stderr,
                    "%s: error: %s: invalid argument: '%s'\n",
                     gPgmName,
                     gStrModeNightShiftLong,
                     argv[2]);
            rc = gDisplayUtilECErr;
        }

        printNightShiftUsage();

        return rc;
    }
#endif /* NO_NS */

#ifndef NO_TT
    if (isArg(argv[1], gStrModeTrueToneLong, gStrModeTrueToneShort) == true)
    {

        /* if no arguments, just display the current truetone setting */

        if (argc < 3 ||
            argv[2] == NULL || argv[2][0] == '\0')
        {
            ttStatus = isTrueToneEnabled();

            fprintf(stdout, "%s: ", gStrModeTrueToneLong);

            switch(ttStatus)
            {
                case trueToneDisabled:
                    fprintf(stdout, "%s\n", gStrOff);
                    break;
                case trueToneEnabled:
                    fprintf(stdout, "%s\n", gStrOn);
                    break;
                case trueToneNotSupported:
                    /* intentionally fall through */
                default:
                    fprintf(stdout, "%s\n", gStrUnavail);
                    break;
            }
            return gDisplayUtilECOkay;
        }

        /* enable truetone */

        if (isArgEnable(argv[2]) == true)
        {
            return (trueToneEnable() ?
                gDisplayUtilECOkay : gDisplayUtilECErr);
        }

        /* disable truetone */

        if (isArgDisable(argv[2]) == true)
        {
            return (trueToneDisable() ?
                gDisplayUtilECOkay : gDisplayUtilECErr);
        }

        /* unknown or unsupported option for truetone */

        if (isArgHelp(argv[2]) != true)
        {
            fprintf(stderr,
                    "%s: error: %s: invalid argument: '%s'\n",
                     gPgmName,
                     gStrModeTrueToneLong,
                     argv[2]);
            rc = gDisplayUtilECErr;
        }

        printTrueToneUsage();

        return rc ;
    }
#endif /* NO_TT */

    /* set or get resolution */

    if (isArg(argv[1], gStrModeResolutionLong, gStrModeResolutionShort))
    {
        /* no options specified, just list the main display's resolution */

        if (argc < 3)
        {
            return (listMainDisplay(LIST_SHORT) == true ?
                    gDisplayUtilECOkay : gDisplayUtilECErr);
        }

        argIndex = 2;

        /* check if the help was requested */

        if (argc == 3)
        {

            if (isArgHelp(argv[argIndex]) == true)
            {
                printResolutionUsage();
                return gDisplayUtilECOkay;
            }

            if (isArg(argv[argIndex], gStrMain, NULL) == true)
            {
                return (listMainDisplay(LIST_SHORT) == true ?
                        gDisplayUtilECOkay : gDisplayUtilECErr);
            }

            /* see if there is display id to list */

            displayId = strtoul(argv[argIndex], &endptr, 0);

            if (endptr != NULL && endptr[0] != '\0')
            {
                fprintf(stderr,
                        "%s: error: %s: invalid argument: '%s'\n",
                         gPgmName,
                         gStrModeResolutionLong,
                         argv[argIndex]);
                printResolutionUsage();
                return gDisplayUtilECErr;
            }

            return (listDisplay(displayId, verbose) == true ?
                    gDisplayUtilECOkay : gDisplayUtilECErr);
        }

        if (argc < 5)
        {
            printResolutionUsage();
            return (gDisplayUtilECErr);
        }

        if (isArg(argv[argIndex], gStrMain, NULL) == true)
        {
            setMainDisplayResolution = true;
        }
        else
        {
            /* see if we have a valid display id */

            displayId = strtoul(argv[argIndex], &endptr, 0);

            if (endptr != NULL && endptr[0] != '\0')
            {
                fprintf(stderr,
                        "%s: error: %s: invalid argument: '%s'\n",
                         gPgmName,
                         gStrModeResolutionLong,
                         argv[argIndex]);
                printResolutionUsage();
                return gDisplayUtilECErr;
            }
        }

        argIndex++;

        /* see if we have a valid width */

        width = strtoul(argv[argIndex], &endptr, 0);

        if (endptr != NULL && endptr[0] != '\0')
        {
            fprintf(stderr,
                    "%s: error: %s: invalid argument: '%s'\n",
                     gPgmName,
                     gStrModeResolutionLong,
                     argv[argIndex]);
            printResolutionUsage();
            return gDisplayUtilECErr;
        }

        argIndex++;

        /* see if we have a valid height */

        height = strtoul(argv[argIndex], &endptr, 0);

        if (endptr != NULL && endptr[0] != '\0')
        {
            fprintf(stderr,
                    "%s: error: %s: invalid argument: '%s'\n",
                     gPgmName,
                     gStrModeResolutionLong,
                     argv[argIndex]);
            printResolutionUsage();
            return gDisplayUtilECErr;
        }

        if (argc >= 6)
        {
            argIndex++;
            if (isArgYes(argv[argIndex]) != true)
            {
                fprintf(stderr,
                        "%s: error: %s: invalid argument: '%s'\n",
                         gPgmName,
                         gStrModeResolutionLong,
                         argv[argIndex]);
                printResolutionUsage();
                return gDisplayUtilECErr;
            }
            inPts = true;
        }

        if (setMainDisplayResolution == true)
        {
            return (setResolutionForMainDisplay(width,
                                                height,
                                                inPts,
                                                false) == true ?
                    gDisplayUtilECOkay : gDisplayUtilECErr);
        }

        return (setResolutionForDisplay(displayId,
                                        width,
                                        height,
                                        inPts,
                                        false) == true ?
                gDisplayUtilECOkay : gDisplayUtilECErr);
    }

    /* unsupported or unknown mode */

    fprintf(stderr,
            "%s: error: invalid argument: '%s'\n",
            gPgmName,
            argv[1]);
    printUsage();
    return gDisplayUtilECErr;

    } /* @autoreleasepool */
}
