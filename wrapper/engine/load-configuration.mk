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

# __gcv <LMSBW_configuration key>
#
#   Get Configuration Value
#
define __gcv
$(call get,LMSBW_configuration,$(1))
endef

define lmsbw_build_output_download_warning
bod_error:=T \
$(info E1016: Component '$(1)' marked 'build-output-download', but prerequisite '$(2)' is not.)
endef

# lmsbw_build_output_download_check <stripped component-name>
# If build-output downloading is enabled, check that the invariants
# for build-output download components are met:
#
#  1. All prerequisites must also be set to download the build.
#
#  The 'bod' prefix stands for 'build output download'.
#
#  'bod_unchecked' is a list of components which have not been checked
#   to see if they are set to have the build output downloaded.
#
#  This function checks
#
define lmsbw_build_output_download_check
$(if $(call lmsbw_gcf,$(1),build-output-download),				\
	$(eval bod_enabled:=$(true))						\
	$(foreach c,$(filter							\
		$(call lmsbw_gcf,$(1),prerequisite),$(bod_unchecked)),		\
		$(if $(call not,$(call lmsbw_gcf,$(c),build-output-download)),	\
			$(call lmsbw_build_output_download_warning,$(1),$(c))))	\
	bod_unchecked:=$(filter-out $(1)					\
		$(call lmsbw_gcf,$(1),prerequisite),$(bod_unchecked)))
endef

# lmsbw_load_component_support
#
#   Loads rules & functions for building different types of components.
#
#   If support for a component type is not found, then a fatal error occurs.
define lmsbw_load_component_support
$(if $(call seq,$(call __gcv,component-build-support),),	\
	$(call lmsbw_no_component_build_support)) \
$(foreach f,$(addsuffix -component.mk,$(addprefix $(LMSBW_DIR)/wrapper/engine/build-support-,$(call __gcv,component-build-support))),$(call lmsbw_assert_exists,E1019,$(f)) $(eval include $(f)))
endef

# check_components_form_dag_work <main component>,
#                                <checking component>,
#                                <prerequisites of checking component>
#
#  Ensures that the set of loaded components forms a DAG.  This is
#  accomplished by keeping a set of components that have been visited,
#  and a path from the original components to the current component in
#  a list.
#
#  Upon each recursion, if the new '<checking component>' has not been
#  visited, its prerequisites are checked.  If any of the
#  prerequisites match '<main component>', a cycle has been found and
#  an error is reported.
#
#  After all the prerequisites are processed, the current '<checking
#  component>' is removed from the list of compnents.  This ensures
#  that if an error is reported, it will show only the prerequisite
#  path that is a cycle.
#
#  This process is repeated for each component that is loaded.
#
define check_components_form_dag_work
$(if $(call not,$(call set_is_member,$(2),$(lmsbw_dag_set))),				\
	$(eval lmsbw_dag_set:=$(call set_insert,$(2),$(lmsbw_dag_set)))			\
	$(if $(filter $(1),$(3)),$(call lmsbw_componentss_not_dag,$(1),$(lmsbw_dag_list)))	\
	$(foreach p,$(3),								\
		$(eval lmsbw_dag_list:=$(lmsbw_dag_list) $(p))				\
		$(call check_components_form_dag_work,$(1),$(p),			\
			$(call lmsbw_gcf,$(p),prerequisite))				\
		$(eval lmsbw_dag_list:=$(call reverse,$(call rest,$(call reverse,$(lmsbw_dag_list)))))	\
	)										\
)
endef

# check_components_form_dag <main component>,
#                        <checking component>,
#                        <prerequisites of checking component>
#
#  Checks that the set of loaded components has a dependency graph
#  that forms a DAG.
#
define check_components_form_dag
$(eval lmsbw_dag_list:=$(1))
$(eval lmsbw_dag_set:=$(empty_set))
$(call check_components_form_dag_work,$(1),$(2),$(3))
$(eval lmsbw_dag_list:=)
$(eval lmsbw_dag_set:=$(empty_set))
endef

# Include configuration information for wrapped build system:
#
#  o Top-level targets
#  o Function to load configuration files
#
#  The value must be the absolute pathname of the configuration file.
#  This is enforced by the lmsbw script.
#
ifndef LMSBW_CONFIGURATION_FILE
$(call lmsbw_error,E1006,LMSBW_CONFIGURATION_FILE is not defined; no wrapped build system)
endif

$(call lmsbw_assert_exists,E1018,$(LMSBW_CONFIGURATION_FILE))

include $(LMSBW_CONFIGURATION_FILE)

# Validate the declared 'load-configuration-function'
#
#   o Associative array element set
#   o The value references a symbol which was defined in a Makefile
#
# The referenced function must load all configuration files.
#
# The name of each loaded component must be placed onto the
# 'LMSBW_components' list using GMSL functions.
#
# The 'load-configuration-function' can use the
# 'LMSBW_CONFIGURATION_FILE' variable to determine where it resides on
# disk.  This facilitates loading the definition files relative to the
# configuration file.
#
# If the function returns (rather than exiting with an error), all
# 'component' declarations have been processed.  The build wrapper
# will proceed to validate them.
#
$(call lmsbw_check_load_configuration_function)
$(call lmsbw_load_component_support)

# When downloading build-output has been disabled with
# '--disable-build-output-download', all checking of the script
# semantics is disabled by just unsetting the download script name.
#
# Disabling the build-output-download component attribute is handled
# on a per-component basis.
#
$(if $(LMSBW_DISABLE_BUILD_OUTPUT_DOWNLOAD),	\
	vv:=$(call set,LMSBW_configuration,component-build-output-download-script,))

# If a 'build-output' download script is declared, it must exist.
#
$(if $(call __gcv,component-build-output-download-script),		\
	$(call lmsbw_assert_exists,E1015,				\
		$(call __gcv,component-build-output-download-script)))

# Load component configuration files.
#
$(eval $(call $(call __gcv,load-configuration-function),$(LMSBW_CONFIGURATION_FILE)))
$(call preqrequisite_test)

$(call lmsbw_assert_components)

# At this point, all components are configured.  LMSBW_components
# contains the list of all components that are included in this
# wrapped build.
#
# This loop finalizes the components by checking invariants that could
# not be checked while they were being configured.
#
bod_unchecked:=$(LMSBW_components)
bod_enabled:=$(false)
$(foreach c,$(LMSBW_components),				\
	$(call lmsbw_assert_not_self_prerequisite,$(c))		\
	$(eval $(call check_components_form_dag,$(c),$(c),	\
		$(call lmsbw_gcf,$(c),prerequisite)))		\
	$(eval $(call fixup_component_fields,$(c)))		\
	$(eval $(call lmsbw_build_output_download_check,$(c)))	\
)

# Produce an error if any prerequisite of a
# 'build-output-download'-marked component is not also marked the
# same.
$(if $(bod_error),$(call lmsbw_assert,E1017,$(false),build-output-download configuration failure))

# If packages are marked to have their build-output downloaded, there
# must be a download script defined.
#
# This check can only be performed after all components are loaded.
#
# Do not add whitespace: the GMSL boolean operators treat whitespace
# as 'T'
#
$(if $(call and,$(bod_enabled),$(call not,$(call __gcv,component-build-output-download-script))),$(call lmsbw_no_build_output_download_script))
