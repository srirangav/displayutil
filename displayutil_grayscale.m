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

#import "displayutil_grayscale.h"

/* strings to select grayscale mode */

const char *gStrModeGrayscaleLong  = "grayscale";
const char *gStrModeGrayscaleShort = "gs";

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
