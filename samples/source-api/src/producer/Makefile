# Copyright (c) 2012 Taylor Hutt, Logic Magicians Software
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
C_SOURCES	:= source.c
CFLAGS		+= -fPIC

all:	libproducer.so.1 libproducer.a
	echo "everything built";

install:	libproducer.so.1 libproducer.a
	$(INSTALL) -D --mode=555 api.h $(DESTDIR)/usr/include/producer/api.h;
	$(INSTALL) -D --mode=555 libproducer.so.1 $(DESTDIR)/usr/lib/producer/libproducer.so.1;
	cd $(DESTDIR)/usr/lib/producer && ln -fs libproducer.so.1 libproducer.so && ln -fs libproducer.so.1 libproducer.so.1.0;


source.o:	source.c

libproducer.a:	source.o
	ar r $@ $<

libproducer.so.1:	source.o
	gcc -shared -Wl,-soname,libproducer.so.1 -o $@ $<

-include $(C_SOURCES:.c=.d)
