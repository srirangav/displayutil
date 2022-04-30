/*
    displayutil - displayutil_resolution.h

    History:

    v. 1.0.0 (04/30/2022) - Initial version

    Copyright (c) 2022 Sriranga R. Veeraraghavan <ranga@calalum.org>

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

#ifndef displayutil_resolution_h
#define displayutil_resolution_h

#import <ApplicationServices/ApplicationServices.h>

/* mode and option strings for list mode */

extern const char *gStrModeResolutionLong;
extern const char *gStrModeResolutionShort;

/* prototypes */

void printResolutionUsage(void);
bool setResolutionForMainDisplay(size_t width, 
                                 size_t height,
                                 bool inPts,
                                 bool searchAll);
bool setResolutionForDisplay(unsigned long display, 
                             size_t width, 
                             size_t height,
                             bool inPts,
                             bool searchAll);

#endif /* displayutil_brightness_h */
