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

define lmsbw_expand_modules_hash
$(call lmsbw_expand_md5sum_text,$(call keys,LMSBW_components))
endef

define lmsbw_expand_component_hash
$(call lmsbw_expand_md5sum_text,$(strip $(1)))
endef

define lmsbw_expand_build_root
$(BW_BUILD_ROOT)
endef

# lmsbw_expand_sysroot_directory
#
#   Expands to the current 'sysroot' directory.
#
#   If a toolchain is not being used, this should just be considered
#   the 'install' directory -- a place where each module will install
#   deliverables so that other, depdenent, modules can use them.
#

# This can only be done AFTER all the modules are configured.

define lmsbw_expand_sysroot_directory
$(call lmsbw_expand_build_root)/sysroot/$(call lmsbw_expand_modules_hash)
endef
