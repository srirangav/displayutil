/*
    displayutil - displayutil_nightshift.h

    History:

    v. 1.0.0 (04/01/2021) - Initial version
    v. 1.0.1 (04/15/2021) - Add support for nightshift schedules

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

#ifndef displayutil_nightshift_h
#define displayutil_nightshift_h

#import <ApplicationServices/ApplicationServices.h>

/* modes for printing out nightshift information */

typedef enum
{
    nightShiftStatusAll          = 1,
    nightShiftStatusScheduleOnly = 2,
    nightShiftStatusStrengthOnly = 3,
} nightShiftStatus_t;

/* strings to select nightshift mode */

extern const char *gStrModeNightShiftLong;
extern const char *gStrModeNightShiftShort;
extern const char *gStrModeNightShiftSchedule;
extern const char *gStrModeNightShiftScheduleSunset;

/* prototypes */

void  printNightShiftUsage(void);
bool  printNightShiftStatus(nightShiftStatus_t status);
bool  nightShiftEnable(void);
bool  nightShiftDisable(void);
bool  nightShiftScheduleDisable(void);
bool  nightShiftScheduleSunsetSunrise(void);
bool  nightShiftSchedule(int startHr, int startMin, int endHr, int endMin);
bool  setNightShiftStrength(float strength);
bool  strToTimeComponents(const char *arg, int *hour, int *min);

#endif /* displayutil_nightshift_h */
