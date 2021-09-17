/*
    displayutil - displayutil_argutils.h

    History:

    v. 1.0.0 (04/06/2021) - Initial version
    v. 1.0.1 (09/05/2021) - add help mode
    v. 1.0.2 (09/07/2021) - add verbose mode
    v. 1.0.3 (09/17/2021) - change verbose, extended, and hidden modes
                            to -l (long), -a (all), and -p (private),
                            respectively

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
extern const char *gStrDisp;
extern const char *gStrModeAll;
extern const char *gStrModeAllLong;
extern const char *gStrModeHelpShort;
extern const char *gStrModeHelpLong;
extern const char *gStrModeLong;
extern const char *gStrModeLongAll;
extern const char *gStrModePrivate;

/* maximum number of supported displays */

#ifndef MAXDISPLAYS
#define MAXDISPLAYS 16
#endif /* MAXDISPLAYS */
extern const UInt32 gMaxDisplays;

/* error messages */

extern const char *gStrErrGetDisplays;
extern const char *gStrErrNoSuchDisplay;

/* prototypes */

bool isArg(const char *arg,
           const char *longMode,
           const char *shortMode);
bool isArgEnable(const char *arg);
bool isArgDisable(const char *arg);
bool isArgAll(const char *arg);
bool isArgAllLong(const char *arg);
bool isArgHelp(const char *arg);
bool isArgLong(const char *arg);
bool isArgPrivate(const char *arg);

#endif /* displayutil_argutils_h */
