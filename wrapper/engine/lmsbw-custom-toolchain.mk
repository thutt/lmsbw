# Copyright (c) 2013 Taylor Hutt, Logic Magicians Software
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

# This file is the interface to declaring custom (non-ctng)
# toolchains.


define lmsbw_expand_custom_toolchain
$(call get,LMSBW_configuration,custom-toolchain)
endef

# lmsbw_expand_custom_toolchain_assignment <pathname>
#
#   Assigns to the custom toolchain and checks for errors.
#
define lmsbw_expand_custom_toolchain_assignment
$(eval __lmsbw_v:=$(call set,LMSBW_configuration,custom-toolchain,$(1)))	\
$(if $(call not,$(wildcard $(call lmsbw_expand_custom_toolchain))),		\
	$(call lmsbw_error,E1025,File '$(call lmsbw_expand_custom_toolchain)' not found))
endef


# declare_custom_toolchain <pathname-to-custom-toolchain-include-file>
#
#   Assigns to LMSBW_configuration[custom-toolchain] if not already assigned.
#
define declare_custom_toolchain
$(if $(call not,$(call lmsbw_expand_custom_toolchain)),				\
	$(call lmsbw_expand_custom_toolchain_assignment,$(1)),			\
	$(call lmsbw_error,E1026,Custom toolchain already declared))
endef
