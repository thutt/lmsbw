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
include $(LMSBW_DIR)/wrapper/engine/declare-source-module-functions.mk

# declare_component_no_parallel_build <component>
#
#   Ensures that a individual component will not be built in parallel.
#   It will always be built with '-j 1'.
#
define declare_component_no_parallel_build
lmsbw_dcnpb:=$(call set,LMSBW_$(strip $(1)),no-parallel,-j 1)
endef


# declare_component_build_target <component> <list of targets>
#
#  Sets the targets that will be passed to the module's Makefile as
#  the preliminary targets for the 'bulid' phase.
#
#  If not set, LMSBW will not use a specific set of targets for the
#  'build' phase.
#
define declare_component_build_target
lmsbw_dcbt:=$(call set,LMSBW_$(strip $(1)),build-target,$(2))
endef

# declare_component_install_target <component> <list of targets>
#
#  Sets the targets that will be passed to the module's Makefile as
#  the preliminary targets for the 'install' phase.
#
#  If not set, LMSBW will set it to 'install'.
#
define declare_component_install_target
lmsbw_dcbt:=$(call set,LMSBW_$(strip $(1)),install-target,$(2))
endef

# fixup_component_fields <component>
#
#   Sets the component fields which cannot be assigned until the full
#   set of components is known.
#
define fixup_component_fields
$(call __msk,$(1),install-directory,						\
	$(call lmsbw_expand_install_directory,					\
		$(call get,LMSBW_$(strip $(1)),reason)))			\
	$(if $(call seq,$(call get,LMSBW_$(strip $(1)),install-target),),	\
		$(call declare_component_install_target,$(strip $(1)),install))
endef
