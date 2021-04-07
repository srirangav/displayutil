/*
    displayutil - displayutil_listDisplays.m

    lists online display

    History:

    v. 1.0.0 (04/01/2021) - Initial version

    Based on: https://gist.github.com/markandrewj/5a465e91bd29d9f9c9e0f84cedb2ca49
              https://developer.apple.com/documentation/coregraphics/quartz_display_services#1655882
              https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/QuartzDisplayServicesConceptual/Articles/DisplayInfo.html

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
#import "displayutil_listDisplays.h"

/* strings to select list mode */

const char *gStrModeListDisplaysLong  = "list";
const char *gStrModeListDisplaysShort = "ls";
const char *gStrModeListDisplaysAll   = "all";
const char *gStrModeListDisplaysMain  = "main";

/* maximum number of supported displays */

static const UInt32 gMaxDisplays = 8;

/* constants for listing displays */

static const char *gStrDisplayMain     = "main";
static const char *gStrDisplayInactive = "inactive";
static const char *gStrDisplayBuiltin  = "builtin";

/* error messages */

static const char *gStrErrListDisplays = "cannot get display information";

/* prototypes */

static bool getDisplayProperties(CGDirectDisplayID displayId,
                                 displayProperties_t *props);

/* getDisplayProperties - get the properties for the specified display */

static bool getDisplayProperties(CGDirectDisplayID displayId,
                                 displayProperties_t *props)
{
    if (props == NULL)
    {
        return false;
    }

    props->height = CGDisplayPixelsHigh(displayId);
    props->width = CGDisplayPixelsWide(displayId);
    props->angle = CGDisplayRotation(displayId);

    props->active = false;
    if (CGDisplayIsActive(displayId) == true &&
        CGDisplayIsOnline(displayId) == true &&
        CGDisplayIsAsleep(displayId) != true)
    {
        props->active = true;
    }

    props->builtin = CGDisplayIsBuiltin(displayId);
    props->main = CGDisplayIsMain(displayId);

    return true;
}

/* printListDisplaysUsage - print usage message list mode */

void printListDisplaysUsage(void)
{
    fprintf(stderr,
            "%s [%s|%s [%s|%s]]\n",
            gPgmName,
            gStrModeListDisplaysLong,
            gStrModeListDisplaysShort,
            gStrModeListDisplaysAll,
            gStrModeListDisplaysMain);

}

/* listMainDisplay - list information about the main display */

bool listMainDisplay(void)
{
    CGDirectDisplayID mainDisplay;
    displayProperties_t displayProps;
    bool haveOpenBracket = false;

    mainDisplay = CGMainDisplayID();

    if (getDisplayProperties(mainDisplay, &displayProps) != true)
    {
        fprintf(stderr,
                "error: %s: %s\n",
                gStrModeListDisplaysLong,
                gStrErrListDisplays);
        return false;
    }

    /* print out the dimensions of the display */

    fprintf(stdout,
            "0x%-8X: %-4dx%-4d",
            mainDisplay,
            displayProps.width,
            displayProps.height);

    /* if the display is rotated, print out the rotation angle */

    if (displayProps.angle != 0)
    {
        fprintf(stdout, " (%f deg)", displayProps.angle);
    }

    /* print out whether the display inactive */

    if (displayProps.active == false)
    {
        fprintf(stdout, " [%s", gStrDisplayInactive);
        haveOpenBracket = true;
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

    if (haveOpenBracket)
    {
        fprintf(stdout,"]");
        haveOpenBracket = false;
    }

    fprintf(stdout,"\n");

    return true;
}

/* listAllDisplays - list information about all display */

bool listAllDisplays(void)
{
    CGDisplayErr err;
    CGDisplayCount onlineDisplayCnt, i;
    CGDirectDisplayID displays[gMaxDisplays];
    displayProperties_t displayProps;
    bool haveOpenBracket = false;

    err = CGGetOnlineDisplayList(gMaxDisplays,
                                 displays,
                                 &onlineDisplayCnt);
    if (err != kCGErrorSuccess)
    {
        fprintf(stderr,
                "error: %s: %s\n",
                gStrModeListDisplaysLong,
                gStrErrListDisplays);
        return false;
    }

    for (i = 0; i < onlineDisplayCnt; i++)
    {

        /* skip displays we can't get display properties for */

        if (getDisplayProperties(displays[i], &displayProps) != true)
        {
            continue;
        }

        /* print out the dimensions of the display */

        fprintf(stdout,
                "0x%-8X: %-4dx%-4d",
                displays[i],
                displayProps.width,
                displayProps.height);

        /* if the display is rotated, print out the rotation angle */

        if (displayProps.angle != 0)
        {
            fprintf(stdout, " (%f deg)", displayProps.angle);
        }

        /* print out whether the display inactive */

        if (displayProps.active == false)
        {
            fprintf(stdout, " [%s", gStrDisplayInactive);
            haveOpenBracket = true;
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

        /* print out whether the display is the main display */

        if (displayProps.main == true)
        {
            if (haveOpenBracket == true)
            {
                fprintf(stdout, ", %s", gStrDisplayMain);
            }
            else
            {
                fprintf(stdout, " [%s", gStrDisplayMain);
                haveOpenBracket = true;
            }
        }

        if (haveOpenBracket)
        {
            fprintf(stdout,"]");
            haveOpenBracket = false;
        }

        fprintf(stdout,"\n");
    }

    return true;
}
