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

# This file is the only public interface for building source-based
# components.
#

# declare_source_component <component-name>,
#                          <description>,
#                          <build | image>,
#                          <configuration-file>,
#                          <full path to source directory>,
#                          <optional list of prerequisite components>
#
define declare_source_component
__dsm:="without this assignment, missing separator error"
$(call lmsbw_assert_component_undefined,$(1),$(4))
$(call lmsbw_assert_source_directory_exists,$(5))
$(eval LMSBW_components:=$(LMSBW_components) $(strip $(1)))
$(call declare_component_kind,$(1),source)
$(call declare_component_description,$(1),$(strip $(2)))
$(call declare_component_reason,$(1),$(3))
$(call lmsbw_assert_build_or_image,$(1))
$(call declare_component_component,$(1),$(1))
$(call declare_component_prerequisite,$(1),$(6))
$(call declare_component_source_directory,$(1),$(5))
$(call declare_component_configuration_file,$(1),$(4))
$(if $(LMSBW_TOOLCHAIN),						\
	$(if $(call not,$(call lmsbw_gcf,$(1),toolchain)),		\
	$(call lmsbw_scf,$(1),toolchain,$(LMSBW_TOOLCHAIN))))
$(call lmsbw_assert_toolchain_exists,$(call lmsbw_gcf,$(1),toolchain))
$(call set_component_internal_data,$(1))
endef


# generate_component_rules_source <component>
#
#   Generate build rules for a 'source' component.
#
define generate_component_rules_source
$(call generate_component_directory_rules,$(1))
$(call generate_component_install,$(1))
$(call generate_component_component,$(1))
$(call generate_component_clean,$(1))
$(call generate_component_report,$(1))
$(call generate_component_build_log,$(1))
$(call generate_component_prerequisite_report,$(1))
$(call generate_component_dependent_report,$(1))
$(call lmsbw_generate_api_changed,$(1))
endef

