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

.PHONY:	default.component.install.$(LMSBW_C_COMPONENT)	\
	default.component.build.$(LMSBW_C_COMPONENT)

# Make variables passed on the command line to the make evaluating
# this file are exported to recursive invocations of Make by default.
DEFAULT_SOURCE_COMPONENT_MAKE_OPTIONS :=									\
	-f $(LMSBW_C_BUILD_DIRECTORY)/$(notdir $(LMSBW_C_SOURCE_DIRECTORY))/Makefile				\
	-C $(LMSBW_C_BUILD_DIRECTORY)/$(notdir $(LMSBW_C_SOURCE_DIRECTORY))					\
	$(LMSBW_C_NO_PARALLEL)											\
	DESTDIR=$(LMSBW_C_DESTDIR_DIRECTORY)									\
	LMSBW_C_BUILD_WORKING_DIRECTORY=$(LMSBW_C_BUILD_DIRECTORY)/$(notdir $(LMSBW_C_SOURCE_DIRECTORY))	\
	GMSL=$(LMSBW_DIR)/wrapper/gmsl

default.component.install.$(LMSBW_C_COMPONENT):	sync
	$(MESSAGE) "[default] Installing component";
	$(MAKE) $(DEFAULT_SOURCE_COMPONENT_MAKE_OPTIONS)  $(LMSBW_C_INSTALL_TARGET);

%::	default.%
	$(MESSAGE) "$@:";
