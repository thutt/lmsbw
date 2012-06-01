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

# __gcv <LMSBW_configuration key>
#
#   Get Configuration Value
#
define __gcv
$(call get,LMSBW_configuration,$(1))
endef

# Include configuration information for wrapped build system:
#
#  o Top-level targets
#  o Function to load configuration files
#
ifndef LMSBW_CONFIGURATION_FILE
$(call lmsbw_error,E1006,LMSBW_CONFIGURATION_FILE is not defined; no wrapped build system)
endif

$(call assert_exists,$(LMSBW_CONFIGURATION_FILE))

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
# If the function returns, all 'packages' declarations have been
# processed.  The build wrapper will proceed to validate them.
#
$(call lmsbw_check_load_configuration_function)

# Load component configuration files.
#
$(eval $(call $(call __gcv,load-configuration-function),$(LMSBW_CONFIGURATION_FILE)))

$(foreach c,$(call keys,LMSBW_components),		\
	$(eval $(call fixup_component_fields,$(c)))	\
)
