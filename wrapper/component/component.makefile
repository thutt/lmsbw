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

.PHONY:	install build configure sync

# Sync source code into build directory.
sync:
	$(MESSAGE) "Syncing '$(LMSBW_C_SOURCE_DIRECTORY)' to '$(LMSBW_C_BUILD_DIRECTORY)'";
	$(RSYNC)							\
		--compress						\
		--executability						\
		--group							\
		--owner							\
		--perms							\
		--recursive						\
		--times							\
		--update						\
		--verbose						\
		$(LMSBW_C_SOURCE_DIRECTORY) $(LMSBW_C_BUILD_DIRECTORY);

configure:	component.configure.$(LMSBW_C_COMPONENT)

build:		component.build.$(LMSBW_C_COMPONENT)


# The install rule is the only rule invoked by the LMSBW.  It then
# drives the other aspects of building a component.
#
install:	component.install.$(LMSBW_C_COMPONENT)
	$(MESSAGE) "Installing '$(LMSBW_C_COMPONENT)' to '$(LMSBW_C_INSTALL_DIRECTORY)'";
	$(RSYNC)							\
		--compress						\
		--executability						\
		--group							\
		--owner							\
		--perms							\
		--recursive						\
		--times							\
		--update						\
		--verbose						\
		$(LMSBW_C_DESTDIR_DIRECTORY)/ $(LMSBW_C_INSTALL_DIRECTORY);

include $(LMSBW_DIR)/wrapper/component/last-resort-rules-$(LMSBW_C_KIND)-component.mk
