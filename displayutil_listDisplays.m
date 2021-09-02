/*
    displayutil - displayutil_listDisplays.m

    lists online displays

    History:

    v. 1.0.0 (04/01/2021) - Initial version
    v. 1.0.1 (04/08/2021) - Add support for additional information available
                            through CGDisplayModeRef

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

static bool getDisplayProperties(CGDirectDisplayID displayId,
                                 displayProperties_t *props);
static bool printDisplayProps(CGDirectDisplayID display);

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
        CGDisplayModeRelease(mode);
    }
    else
    {
        props->heightInPixels = 0;
        props->widthInPixels = 0;
        props->refresh = 0;
        props->uiCapable = false;
    }

    return true;
}

/* printDisplayProps - print out a display's properties */

static bool printDisplayProps(CGDirectDisplayID display)
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

    /* if the display is rotated, print out the rotation angle */

    if (fpclassify(displayProps.angle) != FP_ZERO)
    {
        fprintf(stdout, " (%3.1f deg)", displayProps.angle);
    }

    /* print out the display's refresh rate */

    if (displayProps.refresh > 0)
    {
        fprintf(stdout, " (%3.1f Hz)", displayProps.refresh);
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

bool listMainDisplay(void)
{
    return printDisplayProps(CGMainDisplayID());
}

/* listAllDisplays - list information about all display */

bool listAllDisplays(void)
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
        printDisplayProps(displays[i]);
    }

    return true;
}

/* listDisplay - list information about the specified display */

bool listDisplay(unsigned long display)
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
            ret = printDisplayProps(displays[i]);
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
