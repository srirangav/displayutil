/*
    displayutil - displayutil_resolution.m

    set the resolution for a display

    History:

    v. 1.0.0 (05/06/2022) - Initial working version

    Based on:

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

#import <stdio.h>
#import "displayutil_display.h"
#import "displayutil_argutils.h"
#import "displayutil_resolution.h"

/* strings to select the resolution mode */

const char *gStrModeResolutionLong  = "resolution";
const char *gStrModeResolutionShort = "rs";

/* informational / error messages */

static const char *gStrErrGetDisplayModes =
    "cannot get display mode information";
static const char *gStrErrGetResolutionUnavailable =
    "resolution not found/available";
static const char *gStrErrCantConfigure =
    "cannot configure display";
static const char *gStrErrCantComplete =
    "cannot complete display configuration";

/* private functions */

/* public functions */

/* printResolutionUsage - print usage message for resolution mode */

void printResolutionUsage(void)
{
    fprintf(stderr,
            "%s [%s|%s] [%s|%s] [width] [height] [pts]\n",
            gPgmName,
            gStrModeResolutionLong,
            gStrModeResolutionShort,
            gStrMain,
            gStrDisp);
}

/* setResolutionForDisplay - sets the resolution for the specified display */

bool setResolutionForMainDisplay(size_t width,
                                 size_t height,
                                 bool inPts,
                                 bool searchAll)
{
    return setResolutionForDisplay(CGMainDisplayID(),
                                    width,
                                    height,
                                    inPts,
                                    searchAll);
}

/* setResolutionForDisplay - sets the resolution for the specified display */

bool setResolutionForDisplay(unsigned long display,
                             size_t width,
                             size_t height,
                             bool inPts,
                             bool searchAll)
{
    CGDisplayErr err;
    CGDisplayCount onlineDisplayCnt, i;
    CGDirectDisplayID displays[MAXDISPLAYS];
    CGDisplayModeRef mode = NULL;
    CGDisplayConfigRef config;
    CFArrayRef allModes = NULL;
    CFDictionaryRef options = NULL;
    const CFStringRef dictkeys[] =
        {kCGDisplayShowDuplicateLowResolutionModes};
    const CFBooleanRef dictvalues[] =
        {kCFBooleanTrue};
    long numModes = 0, j = 0;
    size_t modeWidth = 0, modeHeight = 0;
    bool foundDisplay = false, foundMode = false;
    bool ret = false;

    /* make sure a non-zero width and height are specified */

    if (width <= 0 || height <= 0)
    {
        return ret;
    }

    /* get a list of the available displays */

    err = CGGetOnlineDisplayList(gMaxDisplays,
                                 displays,
                                 &onlineDisplayCnt);
    if (err != kCGErrorSuccess)
    {
        fprintf(stderr,
                "error: %s: %s\n",
                gStrModeResolutionLong,
                gStrErrGetDisplays);
        return ret;
    }

    /* see if the specified display is available */

    for (i = 0; i < onlineDisplayCnt; i++)
    {
        if (displays[i] != display)
        {
            continue;
        }

        /* the specified display is available */

        foundDisplay = true;
        break;
    }

    if (foundDisplay == false)
    {
        fprintf(stderr,
                "error: %s: %s: '%lu'\n",
                gStrModeResolutionLong,
                gStrErrNoSuchDisplay,
                display);
        return ret;
    }

    /* check if the requested resolution is available */

    /*
        if searchAll is true, then look through all available
        resolutions, otherwise, just look at supported
        resolutions
    */

    if (searchAll == true)
    {
        options = CFDictionaryCreate(NULL,
                                     (const void **)dictkeys,
                                     (const void **)dictvalues,
                                     1,
                                     &kCFCopyStringDictionaryKeyCallBacks,
                                     &kCFTypeDictionaryValueCallBacks);
    }

    /* get the available display modes for this display */

    allModes = CGDisplayCopyAllDisplayModes((CGDirectDisplayID)display,
                                            options);
    if (options != NULL)
    {
        CFRelease(options);
    }

    if (allModes == NULL)
    {
        fprintf(stderr,
                "error: %s: %s\n",
                gStrModeResolutionLong,
                gStrErrGetDisplayModes);
        return ret;
    }

    /* get the number of available modes that were found */

    numModes = CFArrayGetCount(allModes);

    if (numModes <= 0)
    {
        CFRelease(allModes);
        fprintf(stderr,
                "error: %s: %s\n",
                gStrModeResolutionLong,
                gStrErrGetDisplayModes);
        return ret;
    }

    for (j = 0; j < numModes; j++)
    {

        mode = (CGDisplayModeRef)CFArrayGetValueAtIndex(allModes, j);

        if (mode == NULL)
        {
            continue;
        }

        /*
            if the requested mode is a retina mode (i.e. inPts
            is true), then look at the resolution in points,
            otherwise, use the pixel resolution
        */

        if (inPts)
        {
            modeWidth = CGDisplayModeGetWidth(mode);
            modeHeight = CGDisplayModeGetHeight(mode);
        }
        else
        {
            modeWidth = CGDisplayModeGetPixelWidth(mode);
            modeHeight = CGDisplayModeGetPixelHeight(mode);
        }

        /* we found a matching mode, break */

        if (width == modeWidth && height == modeHeight)
        {
            foundMode = true;
            break;
        }
    }

    /* the requested resolution isn't available */

    if (foundMode != true)
    {
        CFRelease(allModes);
        fprintf(stderr,
                "error: %s: %s: %lu x %lu\n",
                gStrModeResolutionLong,
                gStrErrGetResolutionUnavailable,
                width,
                height);
        return ret;
    }

    /* a matching resolution is available */

    if (CGBeginDisplayConfiguration(&config) != kCGErrorSuccess)
    {
        CFRelease(allModes);
        fprintf(stderr,
                "error: %s: %s\n",
                gStrModeResolutionLong,
                gStrErrCantConfigure);
        return ret;
    }

    if (CGConfigureDisplayWithDisplayMode(config,
                                          (CGDirectDisplayID)display,
                                          mode,
                                          NULL) != kCGErrorSuccess)
    {
        CFRelease(allModes);
        fprintf(stderr,
                "error: %s: %s %lu to %lu x %lu\n",
                gStrModeResolutionLong,
                gStrErrCantConfigure,
                display,
                modeWidth,
                modeHeight);
        return ret;
    }

    if (CGCompleteDisplayConfiguration(config,
                                       kCGConfigurePermanently)
                                       != kCGErrorSuccess)
    {
        CFRelease(allModes);
        fprintf(stderr,
                "error: %s: %s",
                gStrModeResolutionLong,
                gStrErrCantComplete);
        return ret;
    }

    return true;
}

