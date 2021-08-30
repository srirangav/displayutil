/*
    displayutil - displayutil_argutils.h

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

#ifndef displayutil_argutils_h
#define displayutil_argutils_h

#import <ApplicationServices/ApplicationServices.h>

/* program name */

extern const char *gPgmName;

/* option strings */

extern const char *gStrEnable;
extern const char *gStrOn;
extern const char *gStrDisable;
extern const char *gStrOff;
extern const char *gStrStatus;
extern const char *gStrUnavail;
extern const char *gStrMain;
extern const char *gStrAll;

/* maximum number of supported displays */

#ifndef MAXDISPLAYS
#define MAXDISPLAYS 16
#endif /* MAXDISPLAYS */
extern const UInt32 gMaxDisplays;

/* error messages */

extern const char *gStrErrGetDisplays;

/* prototypes */

bool isArg(const char *arg,
           const char *longMode,
           const char *shortMode);
bool isArgEnable(const char *arg);
bool isArgDisable(const char *arg);

#endif /* displayutil_argutils_h */
