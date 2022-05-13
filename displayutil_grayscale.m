/*
    displayutil - displayutil_grayscale.m

    enable / disable grayscale mode
    
    History:

    v. 1.0.0 (04/01/2021) - Initial version
    v. 1.0.1 (09/05/2021) - add legacy preference updating
    v. 1.0.2 (09/11/2021) - start universal access daemon to put grayscale
                            changes into effect immediately
                            
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
#import <IOKit/graphics/IOGraphicsLib.h>

#import "displayutil_argutils.h"
#import "displayutil_grayscale.h"

/*
    Private APIs for setting grayscale mode:
    
    https://gist.github.com/danielpunkass/df0d72be11b8956f2ef4f4d52cce7a41
    https://apple.stackexchange.com/questions/240446/how-to-enable-disable-grayscale-mode-in-accessibility-via-terminal-app

    use universal access instead of core graphics on M1, see:

    https://github.com/brettferdosi/grayscale/blob/master/Sources/Bridge.h
        
    Alternative to the Universal Access functions is to use the Media 
    Accessibility functions:
    
        extern _Bool MADisplayFilterPrefGetCategoryEnabled(int filter);
        extern void  MADisplayFilterPrefSetCategoryEnabled(int filter, _Bool enable);
        extern int MADisplayFilterPrefGetType(int filter);
        extern void MADisplayFilterPrefSetType(int filter, int type);

        int __attribute__((weak)) SYSTEM_FILTER = 0x1;
        int __attribute__((weak)) GRAYSCALE_TYPE = 0x1;
    
    enable using Media Accessibility functions:
    
        1. set the system filter to grayscale:
    
            MADisplayFilterPrefSetType(SYSTEM_FILTER, GRAYSCALE_TYPE)

        2. enable the system filter:
        
            MADisplayFilterPrefSetCategoryEnabled(SYSTEM_FILTER, true)
    
        3. start universal access daemon to put the setting into effect
    
            _UniversalAccessDStart(UNIVERSALACCESSD_MAGIC)
    
    disable:

        1. disable the system filter:
            
            MADisplayFilterPrefSetCategoryEnabled(SYSTEM_FILTER, false)
    
        3. start universal access daemon to put the setting into effect
    
            _UniversalAccessDStart(UNIVERSALACCESSD_MAGIC)    
 */

#ifdef USE_UA

int __attribute__((weak)) UNIVERSALACCESSD_MAGIC = 0x8;

extern void UAGrayscaleSetEnabled(int enabled);
extern int  UAGrayscaleIsEnabled(void);
extern void UAGrayscaleSynchronizeLegacyPref(void);
extern void _UniversalAccessDStart(int magic);

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
    /* enable grayscale using universal access */
    UAGrayscaleSetEnabled(1);
    /* synchronize the preference setting */    
    UAGrayscaleSynchronizeLegacyPref();
    /* start universal access daemon in case it is not running */
    _UniversalAccessDStart(UNIVERSALACCESSD_MAGIC);
#else
    CGDisplayForceToGray(true);
#endif /* USE_UA*/
}

/* grayScaleDisable - turn off grayscale mode */

void grayScaleDisable(void)
{
#ifdef USE_UA
    UAGrayscaleSetEnabled(0);
    UAGrayscaleSynchronizeLegacyPref();
    _UniversalAccessDStart(UNIVERSALACCESSD_MAGIC);
#else
    CGDisplayForceToGray(false);
#endif /* USE_UA */
}
