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

# lmsbw_assert_build_or_image <component build reason>
#
define lmsbw_assert_build_or_image
$(call lmsbw_assert,E1003,								\
	$(call or,$(call seq,$(strip $(1)),build),$(call seq,$(strip $(1)),image)),	\
	Reason '$(strip $(1))' is not 'build' nor 'image')
endef

# lmsbw_assert_source_directory_exists <source directory pathname>
#
define lmsbw_assert_source_directory_exists
$(call assert_exists,$(strip $(1)))
endef

# lmsbw_assert_not_self_prerequisite <component-name>
define lmsbw_assert_not_self_prerequisite
$(call lmsbw_assert,E1004,								\
	$(call not,$(filter $(1),$(call get,LMSBW_$(strip $(1)),prerequisite))),	\
	Component '$(strip $(1))' cannot have itself as a prerequisite)
endef

# lmsbw_assert_no_mutual_dependence <component>, <prerequisites>
define lmsbw_assert_no_mutual_dependence
$(foreach p,$(2),										\
	$(call lmsbw_assert,E1005,								\
		$(call not,$(filter $(1),$(call get,LMSBW_$(strip $(p)),prerequisite))),	\
		Components '$(strip $(1))' and '$(strip $(p))' are mutually dependent))
endef


# lmsbw_assert_source_or_download <component-name>
#
define lmsbw_assert_source_or_download
$(call lmsbw_assert,E1006,									\
	$(call or,										\
		$(call seq,$(call get,LMSBW_$(strip $(1)),kind),source),			\
		$(call seq,$(call get,LMSBW_$(strip $(1)),kind),download)),			\
	Module kind '$(call get,LMSBW_$(strip $(1)),kind)' is not 'source' nor 'download')
endef

