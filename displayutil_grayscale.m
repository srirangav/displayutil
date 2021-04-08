/*
    displayutil - displayutil_grayscale.m

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
#import "displayutil_argutils.h"
#import "displayutil_grayscale.h"

/*
    Private APIs for setting grayscale mode:
    https://gist.github.com/danielpunkass/df0d72be11b8956f2ef4f4d52cce7a41
    https://apple.stackexchange.com/questions/240446/how-to-enable-disable-grayscale-mode-in-accessibility-via-terminal-app
 */

#ifdef USE_UA
extern void UAGrayscaleSetEnabled(int enabled);
extern int  UAGrayscaleIsEnabled();
#else
CG_EXTERN bool CGDisplayUsesForceToGray(void);
CG_EXTERN void CGDisplayForceToGray(bool forceToGray);
#endif /* USE_UA */

/* strings to select grayscale mode */

const char *gStrModeGrayscaleLong  = "grayscale";
const char *gStrModeGrayscaleShort = "gs";

/* printGrayScaleUsage - print usage message for grayscale mode */

void printGrayScaleUsage(void)
{
    fprintf(stderr,
            "%s [%s|%s] [%s|%s|%s|%s]\n",
            gPgmName,
            gStrModeGrayscaleLong,
            gStrModeGrayscaleShort,
            gStrOn,
            gStrEnable,
            gStrOff,
            gStrDisable);
}

/* isGrayScaleEnabled - return true if grayscale mode is on */

bool isGrayScaleEnabled(void)
{
#ifdef USE_UA
    return (UAGrayscaleIsEnabled() ? true : false);
#else
    return (CGDisplayUsesForceToGray() ? true : false);
#endif /* USE_UA */
}

/* grayScaleEnable - turn on grayscale mode */

void grayScaleEnable(void)
{
#ifdef USE_UA
    UAGrayscaleSetEnabled(1);
#else
    CGDisplayForceToGray(true);
#endif /* USE_UA*/
}

/* grayScaleDisable - turn off grayscale mode */

void grayScaleDisable(void)
{
#ifdef USE_UA
            UAGrayscaleSetEnabled(0);
#else
            CGDisplayForceToGray(false);
#endif /* USE_UA */
}
