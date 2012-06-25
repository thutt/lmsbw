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

# LMSBW guarantees that either both LMSBW_TOOLCHAINS_ROOT and
# LMSBW_C_TOOLCHAIN will be set, or neither will be set.
ifdef LMSBW_C_TOOLCHAINS_ROOT
LMSBW_TOOL_PREFIX	:= $(LMSBW_TOOLCHAINS_ROOT)/$(LMSBW_C_TOOLCHAIN)/bin/$(LMSBW_C_TOOLCHAIN)-
endif
export ADDR2LINE	:= $(LMSBW_TOOL_PREFIX)addr2line
export AR		:= $(LMSBW_TOOL_PREFIX)ar
export AS		:= $(LMSBW_TOOL_PREFIX)as
export CC		:= $(LMSBW_TOOL_PREFIX)gcc
export CPP		:= $(LMSBW_TOOL_PREFIX)cpp
export CXX		:= $(LMSBW_TOOL_PREFIX)c++
export GCOV		:= $(LMSBW_TOOL_PREFIX)gcov
export GXX		:= $(LMSBW_TOOL_PREFIX)g++
export LD		:= $(LMSBW_TOOL_PREFIX)ld
export NM		:= $(LMSBW_TOOL_PREFIX)nm
export OBJCOPY		:= $(LMSBW_TOOL_PREFIX)objcopy
export OBJDUMP		:= $(LMSBW_TOOL_PREFIX)objdump
export POPULATE		:= $(LMSBW_TOOL_PREFIX)populate
export RANLIB		:= $(LMSBW_TOOL_PREFIX)ranlib
export READELF		:= $(LMSBW_TOOL_PREFIX)readelf
export SIZE		:= $(LMSBW_TOOL_PREFIX)size
export SIZE		:= $(LMSBW_TOOL_PREFIX)strings
export STRIP		:= $(LMSBW_TOOL_PREFIX)strip

export INSTALL		:= /usr/bin/install
