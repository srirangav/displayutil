README
------

displayutil v0.2.0
By Sriranga Veeraraghavan <ranga@calalum.org>

displayutil is a command line utility for retrieving information about,
enabling, or disabling darkmode, grayscale, nightshift, and truetone on 
MacOS X systems.  It can also list some information about active displays.

Usage:

    Darkmode:  
    
        displayutil [darkmode|dm] [on|enable|off|disable]

    Grayscale: 

        displayutil [grayscale|gs] [on|enable|off|disable]

    List Displays: 
    
        displayutil [list|ls [all|main]]

    Nightshift:
    
        displayutil [nightshift|ns] [on|enable|off|disable] 
        
        Schedule:
    
        displayutil [nightshift|ns] 
                    [schedule [disable|sunset|[h]h:mm [h]h:mm]]] 

        Strength:

        displayutil [nightshift|ns] [0.0 - 1.0]

    Truetone:
    
        displayutil [truetone|tt] [on|enable|off|disable]

Building:

    For Intel Macs running 10.12.3 or earlier:  make 10.11
    For Intel Macs running 10.12.4 or 10.13.x:  make 10.13
    For Intel Macs running 10.14 or later:      make 10.14
    For M1 Macs running 11.0 or later:          make 11.m1

Notes:

    Accessing the current nightshift setting and/or enabling/disabling
    nightshift is available on MacOS X 10.12.4 and newer.

    Accessing the current darkmode setting and/or enabling/disabling
    darkmode is available on MacOS X 10.14 and newer.

    Accessing the current truetone setting and/or enabling/disabling
    truetone is available on MacOS X 11.x and newer (M1).

Known Bugs and Issues:

    Sometimes there is a delay in turning darkmode on or off and/or
    it takes a few tries.
    
    Enabling nightshift's sunset to sunrise mode may require location
    services to be enabled.

History:

    v0.1.0 - initial release
    v0.2.0 - add support for truetone

License:

    See LICENSE.txt
