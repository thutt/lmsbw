# Derived from FreeBSD mtree
#
# Pulls in parts of FreeBSD libc, crc code to make stand alone; Additional
# Linux portability hacks and a simple Makefile.
# 


PROG=	mtree
ARCH=	-m64

CFLAGS+= -I. $(ARCH)
CFLAGS+= -Wall -Werror
SRCS=	compare.c crc.c create.c excludes.c misc.c mtree.c \
	spec.c verify.c setmode.c specspec.c \
	vis.c unvis.c
OBJS=	$(SRCS:.c=.o)
TEST=	/tmp/test.dist
DDIR=	diff_dir
DFILE=	diff_file

all:
	@echo "Available targets:"
	@echo "     To build the program        : $(PROG)"
	@echo "     To show the man page        :  man"
	@echo "     To visually verify operation:  check"
	@echo "     To clean for distribution   :  clean"

$(PROG): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS)

man:	mtree.8
	nroff -mandoc mtree.8 | less

#
# (1) Create a simple manifest file from the current directory
# (2) Introduce a test dir with a test file
#
check: make_manifest make_diff check_manifest clean_diff clean_manifest done

make_manifest: $(PROG)
	@echo "Make manifest..."
	./$(PROG) -c -i -k uname,gname,mode,size | tee $(TEST)

make_diff:
	@echo "Making the directory different..."
	mkdir $(DDIR)
	echo "This is a non-empty file" > $(DDIR)/$(DFILE)

check_manifest: $(TEST)
	@echo "Checking vs. the manifest...."
	./$(PROG) -f $(TEST)

clean_diff:
	@echo "Cleaning up after differences..."
	rm -rf $(DDIR)

clean_manifest:
	@echo "Cleaning up after manifest..."
	rm -rf $(TEST)

done:
	@echo "Done."

clean: clean_diff clean_manifest
	rm -f $(PROG) $(OBJS)
