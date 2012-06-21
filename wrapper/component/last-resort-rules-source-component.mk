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

.PHONY:	default.component.install.$(LMSBW_COMPONENT)	\
	default.component.build.$(LMSBW_COMPONENT)		\
	default.component.sync.$(LMSBW_COMPONENT)

default.component.build.$(LMSBW_COMPONENT):	sync
	$(MESSAGE) "[default] Building source component";
	$(MAKE)											\
		-C $(LMSBW_BUILD_DIRECTORY)/$(notdir $(LMSBW_SOURCE_DIRECTORY))			\
		-f $(LMSBW_BUILD_DIRECTORY)/$(notdir $(LMSBW_SOURCE_DIRECTORY))/Makefile	\
		$(LMSBW_NO_PARALLEL)								\
		DESTDIR=$(LMSBW_DESDIR_DIRECTORY)						\
		LMSBW_BUILD_DIRECTORY=$(LMSBW_BUILD_DIRECTORY)					\
		LMSBW_SOURCE_DIRECTORY=$(LMSBW_BUILD_DIRECTORY)					\
		$(LMSBW_BUILD_TARGET)

default.component.install.$(LMSBW_COMPONENT):	build
	$(MESSAGE) "[default] Installing component";
	$(MAKE)											\
		-C $(LMSBW_BUILD_DIRECTORY)/$(notdir $(LMSBW_SOURCE_DIRECTORY))			\
		-f $(LMSBW_BUILD_DIRECTORY)/$(notdir $(LMSBW_SOURCE_DIRECTORY))/Makefile	\
		$(LMSBW_NO_PARALLEL)								\
		DESTDIR=$(LMSBW_DESDIR_DIRECTORY)						\
		LMSBW_BUILD_DIRECTORY=$(LMSBW_BUILD_DIRECTORY)					\
		LMSBW_SOURCE_DIRECTORY=$(LMSBW_BUILD_DIRECTORY)					\
		$(LMSBW_INSTALL_TARGET);

%::	default.%
	$(MESSAGE) "$@:";
	@$(TRUE)
