/*
    displayutil - displayutil_darkmode.m

    enable / disable darkmode 
    
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
#import <ApplicationServices/ApplicationServices.h>

#import "displayutil_argutils.h"
#import "displayutil_darkmode.h"

/*
    Private APIs for setting dark mode:
    https://saagarjha.com/blog/2018/12/01/scheduling-dark-mode/
 */

extern BOOL SLSGetAppearanceThemeLegacy(void);
#ifdef USE_SLSNOTIFYING
extern BOOL SLSSetAppearanceThemeNotifying(BOOL mode, BOOL notifyListeners);
#else
extern BOOL SLSSetAppearanceThemeLegacy(BOOL mode);
#endif /* USE_SLSNOTIFYING */

/* strings to select darkmode */

const char *gStrModeDarkModeLong  = "darkmode";
const char *gStrModeDarkModeShort = "dm";

/* printDarkModeUsage - print usage message for darkmode */

void printDarkModeUsage(void)
{
    fprintf(stderr,
            "%s [%s|%s] [%s|%s|%s|%s]\n",
            gPgmName,
            gStrModeDarkModeLong,
            gStrModeDarkModeShort,
            gStrOn,
            gStrEnable,
            gStrOff,
            gStrDisable);
}

/* isDarkModeEnabled - returns true if darkmode is enabled */

bool isDarkModeEnabled(void)
{
    return SLSGetAppearanceThemeLegacy();
}

/* darkModeEnable - turn on darkmode */

bool darkModeEnable(void)
{
#ifdef USE_SLSNOTIFYING
    return SLSSetAppearanceThemeNotifying(true, true);
#else
    return SLSSetAppearanceThemeLegacy(true);
#endif /* USE_SLSNOTIFYING */
}

/* darkModeDisable - turn off darkmode */

bool darkModeDisable(void)
{
#ifdef USE_SLSNOTIFYING
    return SLSSetAppearanceThemeNotifying(false, true);
#else
    return SLSSetAppearanceThemeLegacy(false);
#endif /* USE_SLSNOTIFYING */
}
