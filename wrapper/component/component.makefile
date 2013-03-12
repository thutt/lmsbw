# Copyright (c) 2012, 2013 Taylor Hutt, Logic Magicians Software
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
# The working directory when this Makefile is entered is the same as
# the directory containing the configuration file for the component
# being built.
#
.DEFAULT_GOAL := install

include $(LMSBW_DIR)/wrapper/gmsl/gmsl
include $(LMSBW_DIR)/wrapper/lmsbw/lmsbw-system.mk
include $(LMSBW_DIR)/wrapper/component/toolchain.mk

.PHONY:	install build sync presync

# presync: Avoid corner case with deleted files
#
# The corner case is as follows
#
#  Component has a set of source files: { a.c b,c c.c }
#  Component has been built.
#  Component Makefile uses 'SOURCES := $(wildcard *.c)'
#  Developer deletes 'b.c' from the source tree.
#  LMSBW syncs the source directory to build directory.
#    b.c is not deleted, and is picked up by the Makefile
#    Build output is wrong because it contains b.o.
#
# Adding '--delete' to the use of 'rsync' is wrong because it will
# delete any build-generated files in the build directory, removing
# the ability to do incremental builds.
#
# Handling this case marginally pessimizes the system for syncing
# files from the source directory to the build directory, resulting in
# full builds for a component when files have been deleted.
#
# The invoked script will delete the contents of the build directory
# if there are source files that existed on the last build, but do not
# exist on this build (i.e., files in the source directory were
# deleted).
#
# This ensures that when files are deleted from the source tree, they
# are removed from the build directory and will not linger after they
# are removed from the system.
#
# Unfortunately, this results in a full build of the component when
# source files are deleted.  It is considered that deleting source
# files is rare, and this is an acceptable compromise to ensure
# correct builds.
#
presync:
	$(LMSBW_PRE_COMPONENT_SYNC)					\
		--component $(LMSBW_C_COMPONENT)			\
		--build-directory $(LMSBW_C_BUILD_DIRECTORY)		\
		--destdir-directory $(LMSBW_C_DESTDIR_DIRECTORY)	\
		--install-directory $(LMSBW_C_INSTALL_DIRECTORY)	\
		--source-directory $(LMSBW_C_SOURCE_DIRECTORY)		\
		--verbose						\
		--mtree	$(MTREE)

# Sync source code into build directory.
#
sync:	presync
	$(MESSAGE) "Syncing '$(LMSBW_C_SOURCE_DIRECTORY)' to '$(LMSBW_C_BUILD_DIRECTORY)'";
	$(RSYNC)							\
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
