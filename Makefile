# Makefile for displayutil

PGM_SRCS      = displayutil_listDisplays.m \
                displayutil_grayscale.m \
                displayutil_argutils.m \
                displayutil.m
PGM_SRCS_1013 = displayutil_nightshift.m
PGM_SRCS_1014 = $(PGM_SRCS_1013) displayutil_darkmode.m
PGM_SRCS_M1   = $(PGM_SRCS_1014)
PGM           = displayutil
PGM_REL       = 0.1.0
PGM_FILES     = $(PGM_SRCS) $(PGM_SRCs_1014) \
                $(PGM).1 Makefile README.txt LICENSE.txt

CC = cc

# complier flags, based on:
# https://developers.redhat.com/blog/2018/03/21/compiler-and-linker-flags-gcc/

CFLAGS      = -W -Wall -Wextra -Wshadow -Wcast-qual -Wmissing-declarations \
              -Wmissing-prototypes -Werror=format-security \
              -Werror=implicit-function-declaration \
              -D_FORTIFY_SOURCE=2 -D_GLIBCXX_ASSERTIONS \
              -fasynchronous-unwind-tables  -fpic \
              -fstack-protector-all -fstack-protector-strong -fwrapv \
              -fcf-protection
CFLAGS_1011 = -DNO_DM -DNO_NS
CFLAGS_1013 = -DNO_DM
CFLAGS_1014 =
CFLAGS_M1   =  -DUSE_UA
LDFLAGS     =  -F /System/Library/PrivateFrameworks \
               -framework ApplicationServices \
               -framework Foundation \
               -framework CoreBrightness
LDFLAGS_M1   = -framework UniversalAccess
LDFLAGS_1011 =
LDFLAGS_1013 =
LDFLAGS_1014 = -framework SkyLight

all:
	@echo "To build, use one of the following:"
	@echo
	@echo "For Intel Macs on 10.12.3 or earlier: make 10.11"
	@echo "For Intel Macs on 10.12.4 or 10.13.x: make 10.13"
	@echo "For Intel Macs on 10.14 or later:     make 10.14"
	@echo "For M1 Macs:                          make m1"
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

m1:
	$(CC) $(CFLAGS) $(CFLAGS_M1) -o $(PGM) $(PGM_SRCS) $(PGM_SRCS_M1) \
	      $(LDFLAGS) $(LDFLAGS_M1)

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
