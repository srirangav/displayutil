README
------

displayutil v0.3.4
By Sriranga Veeraraghavan <ranga@calalum.org>

Homepage:

    https://github.com/srirangav/displayutil

About:

    displayutil is a command line utility for retrieving information
    about, enabling, or disabling, darkmode, grayscale, nightshift, 
    and truetone on MacOS X systems.  It can also retrieve and set 
    the brightness level for some active displays along with listing 
    information about active displays.

Usage:

    Brightness:
    
        displayutil [brightness|br [all|main|display id [0.0 - 1.0]]]

    Darkmode:  
    
        displayutil [darkmode|dm] [on|enable|off|disable]

    Grayscale: 

        displayutil [grayscale|gs] [on|enable|off|disable]

    List Display Information: 
    
        displayutil [list|ls] [-a|-l] [all|main|display id]

    Nightshift:
    
        Status:
        
            displayutil [nightshift|ns] [on|enable|off|disable] 
        
        Schedule:
    
            displayutil [nightshift|ns] schedule 
                        [disable|sunset|[h]h:mm [h]h:mm]]

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
    nightshift is only available on MacOSX 10.12.4 and newer.

    Accessing the current darkmode setting and/or enabling/disabling
    darkmode is only available on MacOSX 10.14 and newer.

    Accessing the current truetone setting and/or enabling/disabling
    truetone has only been tested on MacOSX 11.x and newer (M1).

    Accessing / setting the current brightness setting has only been 
    tested on MacOSX 11.x and newer (M1).

Known Bugs and Issues:

    Sometimes there is a delay in turning darkmode on or off and/or
    it takes a few tries.
    
    Enabling nightshift's sunset to sunrise mode may require location
    services to be enabled.

History:

    v0.1.0 - initial release
    v0.2.0 - add support for truetone
    v0.3.0 - add support for brightness
    v0.3.1 - add support for listing all available resolutions for
             a display
    v0.3.2 - fixes for grayscale on MacOS X 11.x (M1)
    v0.3.3 - default verbose listing to show only supported 
             resolutions for a display and add an extended mode to
             show all available resolutions for a display
    v0.3.4 - change verbose and extended modes for display listing
             to -l (long) and -a (all), respectively

License:

    See LICENSE.txt
