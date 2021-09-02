# Makefile for displayutil

PGM_SRCS      = displayutil_listDisplays.m \
                displayutil_grayscale.m \
                displayutil_brightness.m \
                displayutil_argutils.m \
                displayutil.m
PGM_SRCS_1013 = displayutil_nightshift.m
PGM_SRCS_1014 = $(PGM_SRCS_1013) \
                displayutil_darkmode.m \
                displayutil_truetone.m
PGM_SRCS_11M1 = $(PGM_SRCS_1014)
PGM_HEADERS   = CBBlueLightClient.h \
                CBTrueToneClient.h \
                displayutil_argutils.h \
                displayutil_darkmode.h \
                displayutil_grayscale.h \
                displayutil_listDisplays.h \
                displayutil_nightshift.h \
                displayutil_brightness.h
PGM           = displayutil
PGM_REL       = 0.3.0
PGM_FILES     = $(PGM_SRCS) $(PGM_SRCS_1014) $(PGM_HEADERS) \
                $(PGM).1 Makefile README.txt LICENSE.txt

CC = cc

# complier flags, based on:
# https://developers.redhat.com/blog/2018/03/21/compiler-and-linker-flags-gcc/
# https://caiorss.github.io/C-Cpp-Notes/compiler-flags-options.html
# https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html
# https://airbus-seclab.github.io/c-compiler-security/clang_compilation.html

CFLAGS      = -O2 -W -Wall -Wextra -Wpedantic -Werror -Walloca \
              -Wcast-qual -Wconversion -Wformat=2 -Wformat-security \
              -Wnull-dereference -Wstack-protector -Wstrict-overflow=3 \
              -Wvla -Warray-bounds-pointer-arithmetic \
              -Wimplicit-fallthrough -Wconditional-uninitialized \
              -Wloop-analysis -Wshift-sign-overflow -Wswitch-enum \
              -Wtautological-constant-in-range-compare \
              -Wassign-enum -Wbad-function-cast -Wfloat-equal \
              -Wformat-type-confusion -Wpointer-arith \
              -Widiomatic-parentheses -Wunreachable-code-aggressive \
              -Wmissing-declarations \
              -Wshadow -Wmissing-prototypes -Wcast-align -Wunused \
              -Wold-style-cast -Wpointer-arith -Wno-missing-braces \
              -Wformat-nonliteral -Wformat-y2k \
              -Werror=implicit-function-declaration \
              -pedantic -pedantic-errors \
              -D_FORTIFY_SOURCE=2 -D_GLIBCXX_ASSERTIONS \
              -fasynchronous-unwind-tables -fpic -fPIE \
              -fstack-protector-all -fstack-protector-strong \
              -fstack-clash-protection -fno-sanitize-recover -fwrapv
CFLAGS_x64  = -fcf-protection=full -fsanitize=memory -fsanitize=cfi \
              -fsanitize=safe-stack
# for 10.12.3 or earlier, disable darkmode, nightshift, and truetone
CFLAGS_1011 = $(CFLAGS_x64) -DNO_DM -DNO_NS
# for 10.12.4 and 10.13.x, disable darkmode and truetone
CFLAGS_1013 = $(CFLAGS_x64) -DNO_DM -NO_TT
CFLAGS_1014 = $(CFLAGS_x64)
# for M1, use UniversalAccess for grayscale
CFLAGS_11M1 =  -DUSE_UA -DUSE_DS

# linker flags

LDFLAGS     =  -lm -F /System/Library/PrivateFrameworks \
               -framework ApplicationServices
LDFLAGS_1011 =
# for 10.12.4 and 10.13.x, link with Foundation and CoreBrightness
# for nightshift (and truetone for 10.14)
# see: https://saagarjha.com/blog/2018/12/01/scheduling-dark-mode/
LDFLAGS_1013 = -framework Foundation \
               -framework CoreBrightness
# for 10.14 or later, link with Skylight for darkmode
# see: https://saagarjha.com/blog/2018/12/01/scheduling-dark-mode/
LDFLAGS_1014 = $(LDFLAGS_1013) \
               -framework SkyLight
# for M1, link with UniversalAccess for grayscale
LDFLAGS_11M1 = $(LDFLAGS_1014) \
               -framework UniversalAccess \
               -framework DisplayServices

# rules

all:
	@echo "To build, use one of the following:"
	@echo
	@echo "For Intel Macs on 10.12.3 or earlier: make 10.11"
	@echo "For Intel Macs on 10.12.4 or 10.13.x: make 10.13"
	@echo "For Intel Macs on 10.14 or later:     make 10.14"
	@echo "For M1 Macs:                          make 11.m1"
	@echo

10.11:
	$(CC) $(CFLAGS) $(CFLAGS_1011) -o $(PGM) $(PGM_SRCS) \
	      $(LDFLAGS) $(LDFLAGS_1011)

10.13:
	$(CC) $(CFLAGS) $(CFLAGS_1013) -o $(PGM) $(PGM_SRCS) $(PGM_SRCS_1013) \
	      $(LDFLAGS) $(LDFLAGS_1013)

10.14: $(PGM_OBJS_WITH_DM)
	$(CC) $(CFLAGS) $(CFLAGS_1014) -o $(PGM) $(PGM_SRCS) $(PGM_SRCS_1014) \
	      $(LDFLAGS) $(LDFLAGS_1014)

11.m1:
	$(CC) $(CFLAGS) $(CFLAGS_11M1) -o $(PGM) $(PGM_SRCS) $(PGM_SRCS_11M1) \
	      $(LDFLAGS) $(LDFLAGS_11M1)

clean:
	/bin/rm -f *.o *~ core .DS_Store $(PGM) $(PGM).1.txt *.tgz

tgz: clean
	[ ! -d $(PGM)-$(PGM_REL) ] && mkdir $(PGM)-$(PGM_REL)
	cp $(PGM_FILES) $(PGM)-$(PGM_REL)
	tar -cvf $(PGM)-$(PGM_REL).tar $(PGM)-$(PGM_REL)
	gzip $(PGM)-$(PGM_REL).tar
	mv -f $(PGM)-$(PGM_REL).tar.gz $(PGM)-$(PGM_REL).tgz
	/bin/rm -rf $(PGM)-$(PGM_REL)

$(PGM).1.txt:
	nroff -man $(PGM).1 | col -b > $(PGM).1.txt

install:
	@echo "Please do the following:"
	@echo
	@echo "mkdir -p ~/bin ~/man/man1"
	@echo "cp $(PGM) ~/bin"
	@echo "cp $(PGM).1 ~/man/man1"
	@echo
	@echo "Add ~/bin to PATH and ~/man to MANPATH"

