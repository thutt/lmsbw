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

ifndef LMSBW_VERBOSE
export LMSBW_SILENT		:= --silent
export ATSIGN			:= @
else
export ATSIGN			:=
endif

export BW_SOURCE_ROOT
export BW_BUILD_ROOT
export BW_TARBALL_REPOSITORY
export LMSBW_VERBOSE

export LMSBW_SCRIPTS			:=		\
	$(LMSBW_DIR)/scripts

export LMSBW_BUILD_DIR			:=		\
	$(BW_BUILD_ROOT)

export LMSBW_TARGET_BUILD_ROOT		:=		\
	$(LMSBW_BUILD_DIR)/target

export LMSBW_HOST_BUILD_ROOT		:=		\
	$(LMSBW_BUILD_DIR)/host

# Stores build-system files.
#
# Files in $(LMSBW_BUILD_SYSTEM_FILES) are created by the build
# process for its own internal purposes.
#
export LMSBW_BUILD_SYSTEM_FILES		:=		\
	$(LMSBW_BUILD_DIR)/lmsbw

# Stores files which are common across all different types of build
# for the current source tree.
#
# One such use is the flag that is used to denote that patches have
# been applies to downloaded package sources.
#
# As the build root directory has a 1:1 correspondence to a source
# tree, there is no danger of these files leaking to other source
# trees.
#
export LMSBW_COMMON_BUILD_SYSTEM_FILES 	:=		\
	$(LMSBW_BUILD_SYSTEM_FILES)/common-build-system-files

export LMSBW_DIRECTORIES		:=		\
	$(LMSBW_BUILD_SYSTEM_FILES)			\
	$(LMSBW_COMMON_BUILD_SYSTEM_FILES)

export LMSBW_TARBALL_SOURCE_ROOT	:=		\
	$(BW_BUILD_ROOT)

include $(LMSBW_DIR)/wrapper/lmsbw/lmsbw-general-functions.mk
include $(LMSBW_DIR)/wrapper/lmsbw/lmsbw-errors.mk
include $(LMSBW_DIR)/wrapper/lmsbw/lmsbw-system-utilities.mk
include $(LMSBW_DIR)/wrapper/lmsbw/lmsbw-scripts.mk
