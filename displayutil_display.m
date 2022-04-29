/*
    displayutil - displayutil_common.m

    History:

    v. 1.0.0 (09/09/2021) - Initial version
    
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

#import "displayutil_display.h"

const char *gStrDisp    = "display id";
const char *gStrMain    = "main";
const char *gStrStatus  = "status";
const char *gStrUnavail = "unavailable";

/* maximum number of supported displays */

const UInt32 gMaxDisplays = MAXDISPLAYS;

/* error messages */

const char *gStrErrGetDisplays   = "cannot get display information";
const char *gStrErrNoSuchDisplay = "display not found";

#ifdef USE_IOSVCPORT4DISP

/* IODisplayConnect constant */

static const char *gIODisplayConnect = "IODisplayConnect";

/* private functions prototypes */

static bool CFNumberEqualsUInt32(CFNumberRef numberRef, 
                                 uint32_t uint32Val); 

/* private functions */

static bool CFNumberEqualsUInt32(CFNumberRef numberRef, 
                                 uint32_t uint32Val) 
{
    int64_t int64Val;
  
    if (numberRef == NULL) 
    {
        return (uint32Val == 0);
    }
    
    /* there's no CFNumber type guaranteed to be a uint32, so pick
        something bigger that's guaranteed not to truncate */

    if (!CFNumberGetValue(numberRef, 
                          kCFNumberSInt64Type, 
                          &int64Val)) 
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

io_service_t getIOServicePortForDisplay(CGDirectDisplayID display) 
{
    uint32_t vendor = 0, model = 0, serial = 0;
    CFMutableDictionaryRef matching = NULL;
    CFDictionaryRef info = NULL;
    CFNumberRef vendorID = NULL;
    CFNumberRef productID = NULL;
    CFNumberRef serialNumber = NULL;
    io_service_t service = 0, matching_service = 0;
    io_iterator_t iter;    
    
    matching = IOServiceMatching(gIODisplayConnect);
    if (matching == nil)
    {
        return matching_service;
    }

    if (IOServiceGetMatchingServices(kIOMasterPortDefault, 
                                     matching, 
                                     &iter))
    {
        return matching_service;
    }

    vendor = CGDisplayVendorNumber(display);
    model = CGDisplayModelNumber(display); 
    serial = CGDisplaySerialNumber(display);

    while ((service = IOIteratorNext(iter)) != 0) 
    {
        info = 
            IODisplayCreateInfoDictionary(service, 
                                          kIODisplayNoProductName);
        if (info == NULL)
        {
            continue;
        }
        
        vendorID = 
            CFDictionaryGetValue(info, 
                                 CFSTR(kDisplayVendorID));
        productID = 
            CFDictionaryGetValue(info, 
                                 CFSTR(kDisplayProductID));
        serialNumber = 
            CFDictionaryGetValue(info, 
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

#endif /* USE_IOSVCPORT4DISP */

