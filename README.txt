README
------

displayutil v0.4.6

Homepage:

    https://github.com/srirangav/displayutil

About:

    displayutil is a command line utility for retrieving
    information about, enabling, or disabling, darkmode,
    grayscale, nightshift, and truetone on MacOS X systems.
    It can also retrieve and set the brightness level and
    resolution for some active displays, along with listing
    information about active displays.

Usage:

    Brightness:

        displayutil [brightness|br [[all|main|dispaly id]
                    [0.0 - 1.0]]]

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

    Resolution:

        displayutil [resolution|rs] [main|display id]
                    [[width] [height] [yes]]

    Truetone:

        displayutil [truetone|tt] [on|enable|off|disable]

Build:

    $ ./configure
    $ make

Install:

    $ ./configure
    $ make
    $ make install

    By default, displayutil is installed in /usr/local/bin.

    To install it in a different location, the alternate
    installation prefix can be supplied to configure as
    follows:

        $ ./configure --prefix="<prefix>"

    or, alternately to make as follows:

        $ make install PREFIX="<prefix>"

    For example, the following will install displayutil in
    /opt/local:

        $ make PREFIX=/opt/local install

    A DESTDIR can also be specified for staging purposes
    (with or without an alternate prefix):

        $ make DESTDIR="<destdir>" [PREFIX="<prefix>"] install

Notes:

    Accessing the current nightshift setting and/or enabling or
    disabling nightshift is only available on MacOSX 10.12.4 and
    newer.

    Accessing the current darkmode setting and/or enabling or
    disabling darkmode is only available on MacOSX 10.14 and
    newer.

    Accessing the current truetone setting and/or enabling or
    disabling truetone has only been tested on MacOSX 11.x and
    newer on M1-based macs.

    Accessing / setting the current brightness setting has only
    been tested on MacOSX 11.x and newer on M1-based macs and
    on MacOSX 12.x on x86_64/intel.

    displayutil can only set the display to a resolution that
    the system reports as "supported".

Known Bugs and Issues:

    Sometimes there is a delay in turning darkmode on or off
    and/or it takes a few tries.

    Enabling nightshift's sunset to sunrise mode may require
    location services to be enabled.

History:

    v. 0.4.6 - add support for brightness on x86_64/intel on
               MacOSX 12.x (Monterey)
    v. 0.4.5 - list display resolution when no arguments or
               just a display is specified to resolution mode
    v. 0.4.4 - fix manpage formatting
    v. 0.4.3 - update Makefile to compile each source file
               separately, minor input validation fixes
    v. 0.4.2 - add extra security related compiler options, fix
               detection of CoreBrightness framework
    v. 0.4.1 - try to adopt #include/#import discipline for
               header files
               (see https://doc.cat-v.org/bell_labs/pikestyle)
    v. 0.4.0 - add support for setting resolutions
    v. 0.3.5 - switch to autoconf for configuration / build
    v. 0.3.4 - change verbose and extended modes for display
               listing to -l (long) and -a (all), respectively
    v. 0.3.3 - default verbose listing to show only supported
               resolutions for a display and add an extended mode
               to show all available resolutions for a display
    v. 0.3.2 - fixes for grayscale on MacOS X 11.x (M1)
    v. 0.3.1 - add support for listing all available resolutions
               for a display
    v. 0.3.0 - add support for brightness
    v. 0.2.0 - add support for truetone
    v. 0.1.0 - initial release

License:

    See LICENSE.txt

