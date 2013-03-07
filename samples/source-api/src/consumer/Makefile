# Copyright (c) 2012, 2013 Taylor Hutt, Logic Magicians Software
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
LIBDIR		:= $(LMSBW_C_INSTALL_DIRECTORY)/usr/lib/
IMPORTED_LIBS	:= producer
C_SOURCES	:= consumer.c

LIB_SEARCH_DIRS	:= $(addprefix $(LIBDIR),$(IMPORTED_LIBS))

CFLAGS		+= -I$(LMSBW_C_INSTALL_DIRECTORY)/usr/include

all:		consumer

consumer.o:	consumer.c

consumer:	consumer.o
	$(CC) $(addprefix -L,$(LIB_SEARCH_DIRS)) -o $@ $< -lproducer

install:	all
	$(INSTALL) -D --mode=555 consumer $(DESTDIR)/usr/bin/consumer.elf
	$(INSTALL) -D --mode=555 consumer.sh $(DESTDIR)/usr/bin/consumer

-include $(C_SOURCES:.c=.d)
