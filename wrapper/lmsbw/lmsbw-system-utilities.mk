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

export CAT	:= /bin/cat
export CD	:= cd
export CHMOD	:= /bin/chmod
export CP	:= /bin/cp
export CURL	:= /usr/bin/curl
export DEZIP	:= /usr/bin/unzip
export DIFF	:= /usr/bin/diff
export ECHO	:= /bin/echo
export FALSE	:= /bin/false
export FIND	:= /usr/bin/find
export LEX	:= /usr/bin/lex
export MD5SUM	:= /usr/bin/md5sum
export MESSAGE	:= $(ECHO) -e
export MKDIR	:= /bin/mkdir
export MKTEMP	:= /bin/mktemp
export MTREE	:= $(LMSBW_BUILD_SYSTEM_FILES)/utilities/bin/mtree
export MV	:= /bin/mv
export PATCH	:= /usr/bin/patch
export PRINTF	:= /usr/bin/printf
export PWD	:= /bin/pwd
export RM	:= /bin/rm
export RSYNC	:= /usr/bin/rsync
export SED	:= /bin/sed
export STAT	:= /usr/bin/stat
export TAR	:= /bin/tar
export TIME	:= /usr/bin/time
export TOUCH	:= /usr/bin/touch
export TRUE	:= /bin/true
export UNAME	:= /bin/uname
export WGET	:= /usr/bin/wget
export XARGS	:= /usr/bin/xargs
export YES	:= /usr/bin/yes

export VERBOSE	:= $(if $(LMSBW_VERBOSE),$(MESSAGE),$(TRUE))
export PROGRESS	:= $(if $(LMSBW_PROGRESS),$(MESSAGE),$(TRUE))
