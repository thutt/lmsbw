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
#   Ensures that the individual component bearing this attribute will
#   not be built in parallel.
#
#   This attribute, if present, is assigned to LMSBW_NO_PARALLEL when
#   invoking 'module.makefile'.  If not present, LMSBW_NO_PARALLEL is
#   defined, but will have no value.
#
define declare_component_no_parallel_build
$(call lmsbw_assert_known_component,$(1))
lmsbw_dcnpb:=$(call set,LMSBW_$(strip $(1)),no-parallel,-j 1)
endef


# declare_component_build_target <component> <list of targets>
#
#  Sets the targets that will be passed to the module's Makefile as
#  the preliminary targets for the 'bulid' phase.
#
#  If not set, LMSBW will not use a specific set of targets for the
#  'build' phase, and will end up using the default (or first) rule in
#  the component's Makefile.
#
define declare_component_build_target
$(call lmsbw_assert_known_component,$(1))
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
$(call lmsbw_assert_known_component,$(1))
lmsbw_dcbt:=$(call set,LMSBW_$(strip $(1)),install-target,$(2))
endef


# declare_component_source_api <component>, <list of directories>
#
#  This function declares a list of directories which contain the
#  public API, at the source level, of the component.
#
#  This is be used to cause dependent modules to be rebuilt *only*
#  when the source API has been changed.  In other words, changes
#  internal to a component normally do not cause a recompile of
#  dependent components.
#
#  API changes must recompile all directly dependent components; this
#  is strictly enforced by LMSBW.
#
#  The files installed in $(DESTDIR) are used when checking if the API
#  has changed.
#
#  See 'declare_component_binary_api' if you want to recompile
#  dependent components when a produced binary is changed.
#
define declare_component_source_api
$(call lmsbw_assert_known_component,$(1))
lmsbw_dca:=$(call set,LMSBW_$(strip $(1)),source-api,$(strip $(2)))
endef


# declare_component_binary_api <component>, <list of directories>
#
#  This function declares a list of directories which contain the
#  public API, at the binary level, of the component.
#
#  This is be used to cause dependent modules to be rebuilt *only*
#  when the a binary has been changed.  If your component produces a
#  library which is linked statically, or which is otherwise included
#  into another component, then you want to declare them with this function.
#
#  The files installed in $(DESTDIR) are used when checking if the API
#  has changed.
#
#  See 'declare_component_source_api' if you want to recompile
#  dependent components when the public source API is changed.
#
define declare_component_binary_api
$(call lmsbw_assert_known_component,$(1))
lmsbw_dca:=$(call set,LMSBW_$(strip $(1)),source-api,$(strip $(2)))
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
	$(call set,LMSBW_$(strip $(1)),direct-dependents,			\
		$(call lmsbw_direct_dependents,$(1)))				\
	$(if $(call seq,$(call get,LMSBW_$(strip $(1)),install-target),),	\
		$(call declare_component_install_target,$(strip $(1)),install))
endef
