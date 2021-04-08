README
------

displayutil v0.1.0
By Sriranga Veeraraghavan <ranga@calalum.org>

displayutil is a command line utility for retrieving information about,
enabling, or disabling darkmode, grayscale, and night shift on MacOS X
systems.  It can also list some information about active displays.

Usage:

    displayutil [darkmode|dm] [on|enable|off|disable]
    displayutil [grayscale|gs] [on|enable|off|disable]
    displayutil [list|ls [all|main]]
    displayutil [nightshift|ns] [[on|enable|off|disable] | 0.0 - 1.0]

Building:

    For Intel Macs running 10.12.3 or earlier:  make 10.11
    For Intel Macs running 10.12.4 or 10.13.x:  make 10.13
    For Intel Macs running 10.14 or later:      make 10.14
    For M1 Macs:                                make m1

Notes:

    Accessing the current nightshift setting and/or enabling/disabling
    nightshift is available on 10.12.4 and newer.

    Accessing the current darkmode setting and/or enabling/disabling
    darkmode is available on 10.14 and newer.

Known Bugs and Issues:

    Sometimes there is a delay in turning darkmode on or off and/or
    it takes a few tries.

History:

    v0.1.0 - initial release

License:

    See LICENSE.txt
