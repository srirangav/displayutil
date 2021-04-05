README
------

displayutil v0.1.0
By Sriranga Veeraraghavan <ranga@calalum.org>

displayutil is a command line utility for retrieving information about,
enabling, or disabling darkmode, grayscale, and night shift on MacOS X
systems.  It can also list information about active displays.

Usage:

    displayutil [darkmode|dm] [on|enable|off|disable]
    displayutil [grayscale|gs] [on|enable|off|disable]
    displayutil [list|ls [all|main]]
    displayutil [nightshift|ns] [[on|enable|off|disable] | 0.0 - 1.0]

Notes:

    Accessing the current nightshift setting and/or enabling/disabling
    nightshift is available on 10.12.4 and newer.

    Accessing the current darkmode setting and/or enabling/disabling
    darkmode is available on 10.14 and newer.

History:

    v0.1.0 - initial release

License:

    See LICENSE.txt
