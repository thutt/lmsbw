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

# lmsbw_internal_error <string>
#
#   Produces an 'internal error' message.
#
define lmsbw_internal_error
$(error internal error: $(1))
endef

# lmsbw_error <error number>, <string>
#
#   Produces an error message from LMSBW.
#
define lmsbw_error
$(error $(1): $(2))
endef

# lmsbw_assert <error number>, <expression>, <message>
#
define lmsbw_assert
$(call assert,$(strip $(2)),$(strip $(1)): $(strip $(3)))
endef

# Note: E1001 is not tested because it relies upon the encoding of the
#       associative array variable names created by 'gmsl'.  The test
#       would be fragile and fail is the internal encoding by 'gmsl'
#       changed.
define lmsbw_check_load_configuration_function
$(call lmsbw_assert,E1000,								\
	$(call sne,$(origin $(call __gcv,load-configuration-function)),undefined),	\
	Invalid configuration: 'load-configuration-function' not set)			\
$(call lmsbw_assert,E1001,								\
	$(call seq,$(origin $(call __gcv,load-configuration-function)),file),		\
	Invalid configuration: 'load-configuration-function' must be defined in an included Makefile)
endef

# lmsbw_assert_component_undefined <component-name>
#
define lmsbw_assert_component_undefined
$(call lmsbw_assert,E1002,						\
	$(call not,$(call defined,LMSBW_components,$(strip $(1)))),	\
	Component '$(strip $(1))' is already declared by module		\
	'$(call get,LMSBW_components,$(strip $(1)))')
endef

# lmsbw_assert_build_or_image <component>
#
define lmsbw_assert_build_or_image
$(call lmsbw_assert,E1003,							\
	$(call or,$(call seq,$(call lmsbw_gcf,$(1),reason),build),		\
		  $(call seq,$(call lmsbw_gcf,$(1),reason),image)),		\
	Reason '$(call lmsbw_gcf,$(1),reason)' is not 'build' nor 'image')
endef

# lmsbw_assert_source_directory_exists <source directory pathname>
#
define lmsbw_assert_source_directory_exists
$(call assert_exists,$(strip $(1)))
endef

# lmsbw_assert_not_self_prerequisite <component-name>
define lmsbw_assert_not_self_prerequisite
$(call lmsbw_assert,E1004,						\
	$(call not,$(filter $(1),$(call lmsbw_gcf,$(1),prerequisite))),	\
	Component '$(strip $(1))' cannot have itself as a prerequisite)
endef

#
# E1006 is unused
#

# lmsbw_components_not_dag <main component>,
#                          <component cycle path>
define lmsbw_modules_not_dag
$(call lmsbw_assert,E1007,$(false),				\
	Component prerequisite path '$(strip $(subst $(lmsbw_space), -> ,$(2)) -> $(1))' produces a cycle)
endef


# lmsbw_assert_known_component <component>
#
#    Asserts that the named component is already known to the system.
#
define lmsbw_assert_known_component
$(call lmsbw_assert,E1008,$(filter $(strip $(1)),$(call keys,LMSBW_components)), \
	Unknown component '$(strip $(1))')
endef


# lmsbw_assert_known_function <component>,
#                             <expected function name>
#
#    Produces error if the specified function is not defind by LMSBW.
#    This error will be produced when each new component 'kind' is
#    created (until the function is written).
#
define lmsbw_assert_known_function
$(call lmsbw_assert,E1009,$(call sne,undefined,$(origin $(strip $(2)))),		\
		Function '$(strip $(2))' for component '$(strip $(1))' not written)
endef


# lmsbw_no_component_build_support
#
#  Produces an error when no component build support has been
#  configured.

define lmsbw_no_component_build_support
$(call lmsbw_assert,E1010,$(false),No 'component-build-support' configured)
endef


# lmsbw_invalid_component_build_support <invalid-support>
#
# Produces an error when an unsupported component build type is
# specified.
#
define lmsbw_invalid_component_build_support
$(call lmsbw_assert,E1011,$(false),Component build type '$(1)' is not valid)
endef

