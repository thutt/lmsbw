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

export LMSBW_DIR := $(realpath $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))/..)

all:
	$(error all target has not bee completed)

include $(LMSBW_DIR)/wrapper/gmsl/gmsl
include $(LMSBW_DIR)/wrapper/engine/lmsbw-system.mk
include $(LMSBW_DIR)/wrapper/engine/module-declaration-functions.mk
include $(LMSBW_DIR)/wrapper/engine/load-configuration.mk
include $(LMSBW_DIR)/wrapper/engine/generate-rules.mk


environment-report:
	$(call _environment_variable_report)

loaded-configuration-report:
	$(call _loaded_configuration_file_report)

dependency-report:
	$(call dependency_report)
	$(ATSIGN)$(TRUE);

packages-report::	environment-report loaded-configuration-report
	@$(TRUE);

build-report:		packages-report environment-report loaded-configuration-report

reverse-dependency-report:
	$(call reverse_dependency_report)
	$(ATSIGN)$(TRUE);

$(MTREE): $(LMSBW_DIR)/utilities/mtree/mtree
	@$(MESSAGE) "Installing mtree";
	@$(MKDIR) --parents $(dir $@)
	@$(CP) $< $@

$(LMSBW_DIR)/utilities/mtree/mtree:
	@$(MESSAGE) "Building mtree";
	@$(MAKE) $(CB_VERBOSE)							\
		-C $(LMSBW_DIR)/utilities/mtree			\
		-f $(LMSBW_DIR)/utilities/mtree/Makefile mtree;


.PHONY:		environment-report loaded-configuration-report		\
		packages-report build-report				\
		dependency-report reverse_dependency_report
