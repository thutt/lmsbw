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
CFLAGS	=	-g
CSRC	=	$(wildcard *.c)
OBJS	=	$(CSRC:.c=.o)
DEPS	=	$(CSRC:.c=.d)
EXEC	=	generate


all:		$(EXEC)

$(EXEC):	$(OBJS) $(STATIC_C_AR)
	$(CC) -o $@ $< -L$(STATIC_C_LIB_DIR) -l$(STATIC_C_LIB)

$(OBJS):	$(CSRC)


clean:
	rm -f $(OBJS) $(EXEC)

-include $(DEPS)
