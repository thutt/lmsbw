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

define default_source_component_build
$(MAKE)											\
	-f $(LMSBW_C_BUILD_DIRECTORY)/$(notdir $(LMSBW_C_SOURCE_DIRECTORY))/Makefile	\
	-C $(LMSBW_C_BUILD_DIRECTORY)/$(notdir $(LMSBW_C_SOURCE_DIRECTORY))		\
	$(LMSBW_C_NO_PARALLEL)								\
	DESTDIR=$(LMSBW_C_DESTDIR_DIRECTORY)						\
	LMSBW_C_BUILD_DIRECTORY=$(LMSBW_C_BUILD_DIRECTORY)				\
	LMSBW_C_SOURCE_DIRECTORY=$(LMSBW_C_BUILD_DIRECTORY)				\
	$(LMSBW_C_BUILD_TARGET)
endef

default.component.build.$(LMSBW_C_COMPONENT):	sync.$(LMSBW_C_COMPONENT)
	$(MESSAGE) "[default] Building source component";
	$(call default_source_component_build)

define default_source_component_install
$(MAKE)											\
	-f $(LMSBW_C_BUILD_DIRECTORY)/$(notdir $(LMSBW_C_SOURCE_DIRECTORY))/Makefile	\
	-C $(LMSBW_C_BUILD_DIRECTORY)/$(notdir $(LMSBW_C_SOURCE_DIRECTORY))		\
	$(LMSBW_C_NO_PARALLEL)								\
	DESTDIR=$(LMSBW_C_DESTDIR_DIRECTORY)						\
	LMSBW_C_BUILD_DIRECTORY=$(LMSBW_C_BUILD_DIRECTORY)				\
	LMSBW_C_SOURCE_DIRECTORY=$(LMSBW_C_BUILD_DIRECTORY)				\
	$(LMSBW_C_INSTALL_TARGET);
endef

default.component.install.$(LMSBW_C_COMPONENT):	build.$(LMSBW_C_COMPONENT)
	$(MESSAGE) "[default] Installing component";
	$(call default_source_component_install)

%::	default.%
	$(MESSAGE) "$@:";
	@$(TRUE)

