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

CAT		:= /bin/cat
CD		:= cd
CHMOD		:= /bin/chmod
CP		:= /bin/cp
CURL		:= /usr/bin/curl
DEZIP		:= /usr/bin/unzip
DIFF		:= /usr/bin/diff
ECHO		:= /bin/echo
FALSE		:= /bin/false
FIND		:= /usr/bin/find
LEX		:= /usr/bin/lex
MD5SUM		:= /usr/bin/md5sum
MESSAGE		:= $(ECHO) -e "$(foreach v,$(shell seq $(MAKELEVEL))," ") [$(MAKELEVEL)] "
MKDIR		:= /bin/mkdir
MKTEMP		:= /bin/mktemp
MTREE		:= $(LMSBW_BUILD_SYSTEM_FILES)/utilities/bin/mtree
MV		:= /bin/mv
PATCH		:= /usr/bin/patch
PROGRESS	:= $(if $(LMSBW_PROGRESS),$(MESSAGE) $(1))
PWD		:= /bin/pwd
RM		:= /bin/rm
RSYNC		:= /usr/bin/rsync
SED		:= /bin/sed
STAT		:= /usr/bin/stat
TAR		:= /bin/tar
TIME		:= /usr/bin/time
TOUCH		:= /usr/bin/touch
TRUE		:= /bin/true
UNAME		:= /bin/uname
VERBOSE		:= $(if $(LMSBW_VERBOSE),$(MESSAGE),$(TRUE))
WGET		:= /usr/bin/wget
XARGS		:= /usr/bin/xargs
YES		:= /usr/bin/yes
