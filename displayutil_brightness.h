/*
    displayutil - displayutil_brightness.h

    History:

    v. 1.0.0 (04/01/2021) - Initial version
    v. 1.1.0 (04/27/2022) - add support for setting the main display's
                            brightness

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

#ifndef displayutil_brightness_h
#define displayutil_brightness_h

#import <ApplicationServices/ApplicationServices.h>

/* mode and option strings for list mode */

extern const char *gStrModeBrightnessLong;
extern const char *gStrModeBrightnessShort;

/* prototypes */

void printBrightnessUsage(void);
bool setBrightnessForDisplay(unsigned long display, float brightness);
bool setBrightnessForMainDisplay(float brightness);
bool printBrightnessForDisplay(unsigned long display);
bool printBrightnessForMainDisplay(void);
bool printBrightnessForAllDisplays(void);

#endif /* displayutil_brightness_h */
