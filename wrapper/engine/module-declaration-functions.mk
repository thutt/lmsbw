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

# declare_source_module <module-name>,
#			<component-name>,
#                       <build | image>,
#                       <full path to source directory>
#                       <optional list of prerequisite components>
#
define declare_source_module
$(call assert,$(call not,$(call defined,LMSBW_components,$(strip $(2)))),			\
	Component '$(strip $(2))' is already declared by module					\
	'$(call get,LMSBW_components,$(strip $(2)))')						\
$(call assert,$(call or,$(call seq,$(strip $(3)),build),$(call seq,$(strip $(3)),image)),	\
	Reason '$(strip $(3))' is not 'build' nor 'image')					\
$(call assert,$(call seq,$(wildcard $(strip $(4))),)						\
	Source directory '$(strip $(4))' does not exist)					\
$(call assert_exists,$(strip $(4)));								\
$(call set,LMSBW_components,$(strip $(2)),$(strip $(1)))					\
__lmsbw_dsm:=$(call set,LMSBW_$(strip $(2)),kind,source)					\
__lmsbw_dsm:=$(call set,LMSBW_$(strip $(2)),reason,$(strip $(3)))				\
__lmsbw_dsm:=$(call set,LMSBW_$(strip $(2)),module,$(strip $(1)))				\
__lmsbw_dsm:=$(call set,LMSBW_$(strip $(2)),component,$(strip $(2)))				\
__lmsbw_dsm:=$(call set,LMSBW_$(strip $(2)),prerequisite,$(strip $(5)))				\
__lmsbw_dsm:=$(call set,LMSBW_$(strip $(2)),source-directory,$(strip $(4)))			\
__lmsbw_dsm:=$(call set,LMSBW_$(strip $(2)),build-directory,$(BW_BUILD_ROOT)/build/$(strip $(2)))	\
__lmsbw_dsm:=$(call set,LMSBW_$(strip $(2)),destdir-directory,$(BW_BUILD_ROOT)/destdir/$(strip $(2)))	\
__lmsbw_dsm:=$(call set,LMSBW_$(strip $(2)),sysroot-directory,$(BW_BUILD_ROOT)/sysroot)
endef
