/*
    displayutil - displayutil_brightness.m

    get/set the brightness for a display

    History:

    v. 1.0.0 (09/03/2021) - Initial working version
    
    Based on: https://github.com/nriley/brightness/blob/master/brightness.c

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
#import <IOKit/graphics/IOGraphicsLib.h>
#import "displayutil_argutils.h"
#import "displayutil_brightness.h"

/* strings to select the brightness mode */

const char *gStrModeBrightnessLong              = "brightness";
const char *gStrModeBrightnessShort             = "br";

/* informational / error messages */

static const char *gStrModeBrightnessRange      = "0.0 - 1.0";
static const char *gStrErrBrightnessUnsupported = "changing brightness unsupported";
static const char *gStrErrBrightnessSetFailed   = "changing brightness failed";
static const char *gStrErrBrightnessGetFailed   = "cannot get brightness setting";

/* prototypes */

/* From: https://github.com/nriley/brightness/blob/master/brightness.c */

extern double CoreDisplay_Display_GetUserBrightness(CGDirectDisplayID id)
  __attribute__((weak_import));
extern void CoreDisplay_Display_SetUserBrightness(CGDirectDisplayID id,
                                                  double brightness)
  __attribute__((weak_import));
extern bool DisplayServicesCanChangeBrightness(CGDirectDisplayID id)
  __attribute__((weak_import));
extern void DisplayServicesBrightnessChanged(CGDirectDisplayID id,
                                             double brightness)
  __attribute__((weak_import));

#ifdef USE_DS

/* Below functions are necessary on Apple Silicon/macOS 11. */

extern int DisplayServicesGetBrightness(CGDirectDisplayID id,
                                        float *brightness)
  __attribute__((weak_import));
extern int DisplayServicesSetBrightness(CGDirectDisplayID id,
                                        float brightness)
  __attribute__((weak_import));

#endif /* USE_DS */

/* private functions prototypes */

#ifdef NEED_IOSVCPORT

static bool CFNumberEqualsUInt32(CFNumberRef numberRef, 
                                 uint32_t uint32Val); 
static io_service_t getIOServicePortForDisplay(CGDirectDisplayID display); 

#endif /* NEED_IOSVCPORT */

/* private functions */

#ifdef NEED_IOSVCPORT

static bool CFNumberEqualsUInt32(CFNumberRef numberRef, 
                                 uint32_t uint32Val) 
{
    int64_t int64Val;
  
    if (numberRef == NULL) {
        return (uint32Val == 0);
    }
    
    /* there's no CFNumber type guaranteed to be a uint32, so pick
        something bigger that's guaranteed not to truncate */

    if (!CFNumberGetValue(numberRef, kCFNumberSInt64Type, &int64Val)) 
    {
        return false;
    }
    
    return (int64Val == uint32Val);
}

/* 
    getIOServicePortForDisplay - gets the IOServicePort for the 
                                 specified display 
    
    Based on: https://github.com/nriley/brightness/blob/master/brightness.c
*/

static io_service_t getIOServicePortForDisplay(CGDirectDisplayID display) 
{
    uint32_t vendor = 0, model = 0, serial = 0;
    CFMutableDictionaryRef matching;
    CFDictionaryRef info;
    CFNumberRef vendorID, productID, serialNumber;
    io_service_t service = 0, matching_service = 0;
    io_iterator_t iter;    
    
    vendor = CGDisplayVendorNumber(display);
    model  = CGDisplayModelNumber(display); 
    serial = CGDisplaySerialNumber(display);

    matching = IOServiceMatching("IODisplayConnect");
    if (matching == nil)
    {
        return matching_service;
    }

    if (IOServiceGetMatchingServices(kIOMasterPortDefault, matching, &iter))
    {
        return matching_service;
    }

    while ((service = IOIteratorNext(iter)) != 0) 
    {
        info = IODisplayCreateInfoDictionary(service, 
                                             kIODisplayNoProductName);
        if (info == NULL)
        {
            continue;
        }
        
        vendorID = CFDictionaryGetValue(info, 
                                        CFSTR(kDisplayVendorID));
        productID = CFDictionaryGetValue(info, 
                                         CFSTR(kDisplayProductID));
        serialNumber = CFDictionaryGetValue(info, 
                                            CFSTR(kDisplaySerialNumber));

        CFRelease(info);

        if (CFNumberEqualsUInt32(vendorID, vendor) &&
            CFNumberEqualsUInt32(productID, model) &&
            CFNumberEqualsUInt32(serialNumber, serial)) 
        {
            matching_service = service;
            break;
        }
    }

    IOObjectRelease(iter);
    
    return matching_service;
}

#endif /* NEED_IOSVCPORT */


/* public functions */

/* printBrightnessUsage - print usage message for brightness mode */

void printBrightnessUsage(void)
{
    fprintf(stderr,
            "%s [%s|%s [%s|%s|%s [%s]]]\n",
            gPgmName,
            gStrModeBrightnessLong,
            gStrModeBrightnessShort,
            gStrAll,
            gStrMain,
            gStrDisp,
            gStrModeBrightnessRange);
}

/* setBrightnessForDisplay - sets the brightness for the specified display */

bool setBrightnessForDisplay(unsigned long display, float brightness)
{
    CGDisplayErr err;
    CGDisplayCount onlineDisplayCnt, i;
    CGDirectDisplayID displays[MAXDISPLAYS];
    bool ret = false;

    /* confirm that the requested brightness level is between 0 and 1 */
        
    if (brightness < 0.0 || brightness > 1.0)
    {
        return ret;
    }
    
    err = CGGetOnlineDisplayList(gMaxDisplays,
                                 displays,
                                 &onlineDisplayCnt);
    if (err != kCGErrorSuccess)
    {
        fprintf(stderr,
                "error: %s: %s\n",
                gStrModeBrightnessLong,
                gStrErrGetDisplays);
        return ret;
    }

    for (i = 0; i < onlineDisplayCnt; i++)
    {
        if (displays[i] != display)
        {
            continue;
        }    
        
        if (!DisplayServicesCanChangeBrightness((CGDirectDisplayID)display))
        {
            fprintf(stderr,
                    "error: %s: %s on %lu\n",
                    gStrModeBrightnessLong,
                    gStrErrBrightnessUnsupported,
                    display);
            break;
        }
        
#ifdef USE_DS
        if (DisplayServicesSetBrightness((CGDirectDisplayID)display, 
                                         brightness))
        {
            fprintf(stderr,
                    "error: %s: %s\n",
                    gStrModeBrightnessLong,
                    gStrErrBrightnessSetFailed);
            break;
        }
#else
        CoreDisplay_Display_SetUserBrightness((CGDirectDisplayID)display, 
                                              (double)brightness);
#endif /* USE_DS */

        DisplayServicesBrightnessChanged((CGDirectDisplayID)display, 
                                         (double)brightness);
        ret = true;
        break;
    }
    
    return ret;
}

/* printBrightnessForDisplay - print the brightness for the main display */

bool printBrightnessForMainDisplay(void)
{
    return printBrightnessForDisplay(CGMainDisplayID());
}

/* printBrightnessForDisplay - print the brightness for all displays */

bool printBrightnessForAllDisplays(void)
{
    CGDisplayErr err;
    CGDisplayCount onlineDisplayCnt, i;
    CGDirectDisplayID displays[MAXDISPLAYS];
    float currentBrightness = 0.0;
    bool failed = false;
    
    err = CGGetOnlineDisplayList(gMaxDisplays,
                                 displays,
                                 &onlineDisplayCnt);
    if (err != kCGErrorSuccess)
    {
        fprintf(stderr,
                "error: %s: %s\n",
                gStrModeBrightnessLong,
                gStrErrGetDisplays);
        return false;
    }

    for (i = 0; i < onlineDisplayCnt; i++)
    {
#ifdef USE_DS
        if (DisplayServicesGetBrightness((CGDirectDisplayID)displays[i],
                                         &currentBrightness))
        {
            fprintf(stderr,
                    "error: %s: %s\n",
                    gStrModeBrightnessLong,
                    gStrErrBrightnessGetFailed);
            failed = true;
            continue;
        }
#else
        currentBrightness = 
            (float)CoreDisplay_Display_GetUserBrightness((CGDirectDisplayID)displays[i]);
#endif /* USE_DS */

        /* print out the brightness for this display */
        fprintf(stdout, 
                "0x%08X: %0.2f\n", 
                (CGDirectDisplayID)displays[i], 
                currentBrightness);
    }

    return (!failed);
}

/* printBrightnessForDisplay - print the brightness for the specified display */

bool printBrightnessForDisplay(unsigned long display)
{
    CGDisplayErr err;
    CGDisplayCount onlineDisplayCnt, i;
    CGDirectDisplayID displays[MAXDISPLAYS];
    float currentBrightness = 0.0;
    bool ret = false, failed = false;
    
    err = CGGetOnlineDisplayList(gMaxDisplays,
                                 displays,
                                 &onlineDisplayCnt);
    if (err != kCGErrorSuccess)
    {
        fprintf(stderr,
                "error: %s: %s\n",
                gStrModeBrightnessLong,
                gStrErrGetDisplays);
        return ret;
    }

    for (i = 0; i < onlineDisplayCnt; i++)
    {
        if (displays[i] != display)
        {
            continue;
        }
        
#ifdef USE_DS
        if (DisplayServicesGetBrightness((CGDirectDisplayID)displays[i],
                                         &currentBrightness))
        {
            fprintf(stderr,
                    "error: %s: %s\n",
                    gStrModeBrightnessLong,
                    gStrErrBrightnessGetFailed);
            failed = true;
            break;
        }
#else
        currentBrightness = 
            (float)CoreDisplay_Display_GetUserBrightness((CGDirectDisplayID)displays[i]);
#endif /* USE_DS */

        /* print out the brightness for this display */
        fprintf(stdout, 
                "0x%08X: %0.2f\n", 
                (CGDirectDisplayID)display, 
                currentBrightness);
        ret = true;
        break;
    }

    if (ret == false && failed == false)
    {
        fprintf(stderr,
                "error: %s: %s: '%lu'\n",
                gStrModeBrightnessLong,
                gStrErrNoSuchDisplay,
                display);
    }

    return ret;
}
