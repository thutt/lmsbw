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
.DEFAULT_GOAL := install

include $(LMSBW_DIR)/wrapper/gmsl/gmsl
include $(LMSBW_DIR)/wrapper/lmsbw/lmsbw-system.mk
include $(LMSBW_DIR)/wrapper/component/toolchain.mk

.PHONY:	install build sync

# Sync source code into build directory.
sync:
	$(MESSAGE) "Syncing '$(LMSBW_C_SOURCE_DIRECTORY)' to '$(LMSBW_C_BUILD_DIRECTORY)'";
	$(RSYNC)							\
		--compress						\
		--executability						\
		--group							\
		--links							\
		--owner							\
		--perms							\
		--recursive						\
		--times							\
		--update						\
		--verbose						\
		$(LMSBW_C_SOURCE_DIRECTORY) $(LMSBW_C_BUILD_DIRECTORY);

build:	component.build.$(LMSBW_C_COMPONENT)


# The install rule is the only rule invoked by the LMSBW.  It then
# drives the other aspects of building a component.
#
# component.makefile drives the building of the component, and the
# installation into $(DESTDIR).  Copying from $(DESTDIR) to the actual
# install directory is handled by LMSBW proper.
#
# Consider, for example, the 'lite-consumer-pro' sample provided with
# LMSBW.  This sample has three different deliverable 'products':
# 'lite', 'consumer' and 'pro'.  The lite version only delivers the
# 'lite' executable, but consumer delivers 'lite' & 'consumer' and the
# pro version delivers 'lite', 'consumer', and 'pro'.  Each product
# has a different install directory, but shares the build directories
# since the individual components are built the same regardless the
# product being built.  Since the copying of the build happens at a
# higher level, the data will always be copied, even if the component
# does not actually need to be built & installed into the DESTDIR.
#
install:	component.install.$(LMSBW_C_COMPONENT)

include $(LMSBW_DIR)/wrapper/component/last-resort-rules-$(LMSBW_C_KIND)-component.mk

# Check that variable containing the options passed to make for the
# default 'build' and 'install' rules has been written for the
# component's 'kind'.
#
# If you have written a new 'kind' of component, you will need to
# provide this variable.
#
$(call assert,$(call sne,undefined,$(origin DEFAULT_$(call uc,$(LMSBW_C_KIND))_COMPONENT_MAKE_OPTIONS)),DEFAULT_$(call uc,$(LMSBW_C_KIND))_COMPONENT_MAKE_OPTIONS does not exist)
