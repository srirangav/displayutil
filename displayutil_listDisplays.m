/*
    displayutil - displayutil_listDisplays.m

    lists online displays

    History:

    v. 1.0.0 (04/01/2021) - Initial version
    v. 1.0.1 (04/08/2021) - Add support for additional information available
                            through CGDisplayModeRef
    v. 1.0.2 (09/03/2021) - Add support for display information about a specific
                            display
    v. 1.0.3 (09/07/2021) - add bit depth and verbose mode support

    Based on: https://gist.github.com/markandrewj/5a465e91bd29d9f9c9e0f84cedb2ca49
              https://developer.apple.com/documentation/coregraphics/quartz_display_services
              https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/QuartzDisplayServicesConceptual/Articles/DisplayInfo.html
              https://github.com/nriley/brightness/blob/master/brightness.c

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
#import <math.h>
#import <IOKit/graphics/IOGraphicsLib.h>
#import <IOKit/graphics/IOGraphicsTypes.h>
#import "displayutil_argutils.h"
#import "displayutil_listDisplays.h"

/* struct to hold a display's properties */

typedef struct
{
    UInt32 id;
    size_t heightInPts;
    size_t widthInPts;
    size_t heightInPixels;
    size_t widthInPixels;
    size_t bitdepth;
    double heightInMM;
    double widthInMM;
    double angle;
    double refresh;
    bool active;
    bool builtin;
    bool main;
    bool mirrored;
    bool accelerated;
    bool uiCapable;
    bool stereo;
} displayProperties_t;

/* strings to select list mode */

const char *gStrModeListDisplaysLong  = "list";
const char *gStrModeListDisplaysShort = "ls";

/* constants for listing displays */

static const char *gStrDisplayMain        = "main";
static const char *gStrDisplayInactive    = "inactive";
static const char *gStrDisplayBuiltin     = "builtin";
static const char *gStrDisplayAccelerated = "opengl";
static const char *gStrDisplayUICapable   = "ui";
static const char *gStrDisplayMirrored    = "mirrored";
static const char *gStrDisplayStereo      = "stereo";

/* prototypes */

static bool   getDisplayProperties(CGDirectDisplayID displayId,
                                   displayProperties_t *props);
static bool   printDisplayProps(CGDirectDisplayID display, 
                                bool verbose);
static size_t getDisplayBitDepth(CGDisplayModeRef mode);

/* private functions */

/* getDisplayProperties - get the properties for the specified display */

static bool getDisplayProperties(CGDirectDisplayID displayId,
                                 displayProperties_t *props)
{
    CGDisplayModeRef mode;
    CGSize size;

    if (props == NULL)
    {
        return false;
    }

    props->id = CGDisplayUnitNumber(displayId);
    props->heightInPts = CGDisplayPixelsHigh(displayId);
    props->widthInPts = CGDisplayPixelsWide(displayId);
    props->angle = CGDisplayRotation(displayId);
    props->accelerated = CGDisplayUsesOpenGLAcceleration(displayId);
    props->stereo = CGDisplayIsStereo(displayId);
    props->builtin = CGDisplayIsBuiltin(displayId);
    props->main = CGDisplayIsMain(displayId);
    props->mirrored = CGDisplayIsInMirrorSet(displayId);

    size = CGDisplayScreenSize(displayId);
    if (size.width > 0 && size.height > 0)
    {
        props->heightInMM = size.height;
        props->widthInMM = size.width;
    }
    else
    {
        props->heightInMM = 0.0;
        props->widthInMM = 0.0;
    }

    
    if (CGDisplayIsActive(displayId) == true &&
        CGDisplayIsOnline(displayId) == true &&
        CGDisplayIsAsleep(displayId) != true)
    {
        props->active = true;
    }
    else
    {
        props->active = false;
    }

    mode = CGDisplayCopyDisplayMode(displayId);
    if (mode != NULL)
    {
        props->heightInPixels = CGDisplayModeGetPixelWidth(mode);
        props->widthInPixels = CGDisplayModeGetPixelHeight(mode);
        props->refresh = CGDisplayModeGetRefreshRate(mode);
        props->uiCapable = CGDisplayModeIsUsableForDesktopGUI(mode);
        props->bitdepth = getDisplayBitDepth(mode);
        CGDisplayModeRelease(mode);
    }
    else
    {
        props->heightInPixels = 0;
        props->widthInPixels = 0;
        props->refresh = 0;
        props->uiCapable = false;
        props->bitdepth = 0;
    }

    return true;
}

/* 
    getDisplayBitDepth - get a display's bit depth 
    see: https://github.com/jhford/screenresolution/blob/master/cg_utils.c
         https://stackoverflow.com/questions/8210824/how-to-avoid-cgdisplaymodecopypixelencoding-to-get-bpp
         https://github.com/robbertkl/ResolutionMenu/blob/master/Resolution%20Menu/DisplayModeMenuItem.m
*/

static size_t getDisplayBitDepth(CGDisplayModeRef mode)
{
    size_t depth = 0;
    
#ifdef HAVE_CP_PIXEL_ENC
    CFStringRef pixelEncoding = NULL;
#else
    CFDictionaryRef dict = NULL;
    CFNumberRef num;
#endif /* HAVE_CP_PIXEL_ENC */

    /* make sure a valid mode was specified */
    
    if (mode == NULL)
    {
        return depth;
    }

#ifdef HAVE_CP_PIXEL_ENC

    /* get the bit depth from the pixel encoding (deprecated on 10.11+) */
        
    pixelEncoding = CGDisplayModeCopyPixelEncoding(mode);
    if (pixelEncoding == NULL)
    {
        return depth;
    }

    if (kCFCompareEqualTo == CFStringCompare(pixelEncoding, 
                                             CFSTR(IO1BitIndexedPixels), 
                                             kCFCompareCaseInsensitive)) 
    {
        depth = 1;
    }
    else if (kCFCompareEqualTo == CFStringCompare(pixelEncoding, 
                                                  CFSTR(IO2BitIndexedPixels), 
                                                  kCFCompareCaseInsensitive))
    {
        depth = 2;
    }
    else if (kCFCompareEqualTo == CFStringCompare(pixelEncoding, 
                                                  CFSTR(IO4BitIndexedPixels), 
                                                  kCFCompareCaseInsensitive))
    {
        depth = 4;
    }
    else if (kCFCompareEqualTo == CFStringCompare(pixelEncoding, 
                                                  CFSTR(IO8BitIndexedPixels), 
                                                  kCFCompareCaseInsensitive))
    {
        depth = 8;
    }
    else if (kCFCompareEqualTo == CFStringCompare(pixelEncoding, 
                                                  CFSTR(IO16BitDirectPixels), 
                                                  kCFCompareCaseInsensitive))
    {
        depth = 16;
    }
    else if (kCFCompareEqualTo == CFStringCompare(pixelEncoding, 
                                                  CFSTR(kIO30BitDirectPixels), 
                                                  kCFCompareCaseInsensitive))
    {
        depth = 30;
    }
    else if (kCFCompareEqualTo == CFStringCompare(pixelEncoding, 
                                                  CFSTR(IO32BitDirectPixels), 
                                                  kCFCompareCaseInsensitive))
    {
        depth = 32;
    }
    else if (kCFCompareEqualTo == CFStringCompare(pixelEncoding, 
                                                  CFSTR(kIO16BitFloatPixels), 
                                                  kCFCompareCaseInsensitive)) 
    {
        depth = 48;
    } 
    else if (kCFCompareEqualTo == CFStringCompare(pixelEncoding, 
                                                  CFSTR(kIO64BitDirectPixels), 
                                                  kCFCompareCaseInsensitive)) 
    {
        depth = 64;
    } 
    else if (kCFCompareEqualTo == CFStringCompare(pixelEncoding, 
                                                  CFSTR(kIO32BitFloatPixels), 
                                                  kCFCompareCaseInsensitive)) 
    {
        depth = 96;
    } 
    
    CFRelease(pixelEncoding);

#else

    dict = (CFDictionaryRef)*((int64_t *)mode + 2);
    if (dict == NULL)    
    {
        return depth;
    }
    
    if (CFGetTypeID(dict) == CFDictionaryGetTypeID() && 
        CFDictionaryGetValueIfPresent(dict, 
                                      kCGDisplayBitsPerPixel, 
                                      (const void**)&num))
    {
        CFNumberGetValue(num, kCFNumberSInt32Type, (void*)&depth);
    }

#endif /* HAVE_CP_PIXEL_ENC */

    return depth;
}

/* printDisplayProps - print out a display's properties */

static bool printDisplayProps(CGDirectDisplayID display, 
                              bool verbose)
{
    displayProperties_t displayProps;
    bool haveOpenBracket = false;

    if (getDisplayProperties(display, &displayProps) != true)
    {
        fprintf(stderr,
                "error: %s: %s\n",
                gStrModeListDisplaysLong,
                gStrErrGetDisplays);
        return false;
    }

    /* print out the display id */
    
    fprintf(stdout, "0x%08X: ", display);
    
    /* print out the dimensions of the display */

    if (displayProps.heightInPixels > 0 &&
        displayProps.widthInPixels > 0)
    {
        fprintf(stdout,
                "%-4lux%-4lu",
                displayProps.heightInPixels,
                displayProps.widthInPixels);
    }
    else
    {
        fprintf(stdout,
                "%-4lux%-4lu",
                displayProps.widthInPts,
                displayProps.heightInPts);
    }

    /* print out additional details if verbose out is requested */
    
    if (verbose)
    {
        /* if the bit depth is available, print it out */
    
        fprintf(stdout," %lubit",displayProps.bitdepth);

        /* print out the display's refresh rate */

        if (displayProps.refresh > 0)
        {
            fprintf(stdout, " %3.1fHz", displayProps.refresh);
        }
    
        /* if the display is rotated, print out the rotation angle */

        if (fpclassify(displayProps.angle) != FP_ZERO)
        {
            fprintf(stdout, " %3.1fdeg", displayProps.angle);
        }
    }
    
    /* print out whether the display is the main display */

    if (displayProps.main == true)
    {
        fprintf(stdout, " [%s", gStrDisplayMain);
        haveOpenBracket = true;
    }

    /* print out whether the display is inactive */

    if (displayProps.active == false)
    {
        if (haveOpenBracket == true)
        {
            fprintf(stdout, ", %s", gStrDisplayInactive);
        }
        else
        {
            fprintf(stdout, " [%s", gStrDisplayInactive);
            haveOpenBracket = true;
        }
    }

    /* print out whether the display is mirrored */

    if (displayProps.mirrored == true)
    {
        if (haveOpenBracket == true)
        {
            fprintf(stdout, ", %s", gStrDisplayMirrored);
        }
        else
        {
            fprintf(stdout, " [%s", gStrDisplayMirrored);
            haveOpenBracket = true;
        }
    }

    /* print out whether the display is builtin */

    if (displayProps.builtin == true)
    {
        if (haveOpenBracket == true)
        {
            fprintf(stdout, ", %s", gStrDisplayBuiltin);
        }
        else
        {
            fprintf(stdout, " [%s", gStrDisplayBuiltin);
            haveOpenBracket = true;
        }
    }

    /* print out whether the display is ui capable */

    if (displayProps.uiCapable == true)
    {
        if (haveOpenBracket == true)
        {
            fprintf(stdout, ", %s", gStrDisplayUICapable);
        }
        else
        {
            fprintf(stdout, " [%s", gStrDisplayUICapable);
            haveOpenBracket = true;
        }
    }

    /* print out whether the display is accelerated */

    if (displayProps.accelerated == true)
    {
        if (haveOpenBracket == true)
        {
            fprintf(stdout, ", %s", gStrDisplayAccelerated);
        }
        else
        {
            fprintf(stdout, " [%s", gStrDisplayAccelerated);
            haveOpenBracket = true;
        }
    }

    /* print out whether the display is in stereo mode */

    if (displayProps.stereo == true)
    {
        if (haveOpenBracket == true)
        {
            fprintf(stdout, ", %s", gStrDisplayStereo);
        }
        else
        {
            fprintf(stdout, " [%s", gStrDisplayStereo);
            haveOpenBracket = true;
        }
    }

    if (haveOpenBracket)
    {
        fprintf(stdout,"]");
        haveOpenBracket = false;
    }

    fprintf(stdout,"\n");

    // TODO - if verbose mode, print out all support resolutions
    
    return true;
}

/* public functions */

/* printListDisplaysUsage - print usage message list mode */

void printListDisplaysUsage(void)
{
    fprintf(stderr,
            "%s [%s|%s] [%s|%s|%s]\n",
            gPgmName,
            gStrModeListDisplaysLong,
            gStrModeListDisplaysShort,
            gStrAll,
            gStrMain,
            gStrDisp);
}

/* listMainDisplay - list information about the main display */

bool listMainDisplay(bool verbose)
{
    return printDisplayProps(CGMainDisplayID(), verbose);
}

/* listAllDisplays - list information about all display */

bool listAllDisplays(bool verbose)
{
    CGDisplayErr err;
    CGDisplayCount onlineDisplayCnt, i;
    CGDirectDisplayID displays[MAXDISPLAYS];

    err = CGGetOnlineDisplayList(gMaxDisplays,
                                 displays,
                                 &onlineDisplayCnt);
    if (err != kCGErrorSuccess)
    {
        fprintf(stderr,
                "error: %s: %s\n",
                gStrModeListDisplaysLong,
                gStrErrGetDisplays);
        return false;
    }

    for (i = 0; i < onlineDisplayCnt; i++)
    {
        printDisplayProps(displays[i], verbose);
    }

    return true;
}

/* listDisplay - list information about the specified display */

bool listDisplay(unsigned long display, bool verbose)
{
    CGDisplayErr err;
    CGDisplayCount onlineDisplayCnt, i;
    CGDirectDisplayID displays[MAXDISPLAYS];
    bool ret = false;
    
    err = CGGetOnlineDisplayList(gMaxDisplays,
                                 displays,
                                 &onlineDisplayCnt);
    if (err != kCGErrorSuccess)
    {
        fprintf(stderr,
                "error: %s: %s\n",
                gStrModeListDisplaysLong,
                gStrErrGetDisplays);
        return ret;
    }

    for (i = 0; i < onlineDisplayCnt; i++)
    {
        if (displays[i] == display) 
        {
            ret = printDisplayProps(displays[i], verbose);
            break;
        }
    }

    if (ret == false)
    {
        fprintf(stderr,
                "error: %s: %s: '%lu'\n",
                gStrModeListDisplaysLong,
                gStrErrNoSuchDisplay,
                display);
    }
    
    return ret;
}
