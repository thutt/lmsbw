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

# __msk <component>, <key>, <value>
#
#   __msk: Module Set Key
#
define __msk
__dsm:=$(call set,LMSBW_$(strip $(1)),$(strip $(2)),$(strip $(3)))
endef

# __mgk <component>, <key>
#
#   __mgk: Module Get Key
#
define __mgk
$(call get,LMSBW_$(strip $(1)),$(strip $(2)))
endef

# __expand_build_root <component>
#
#
define __expand_build_root
$(call lmsbw_expand_$(call get,LMSBW_$(strip $(1)),reason)_build_root)/$(strip $(1))/$(call lmsbw_expand_component_hash,$(1))
endef

# declare_source_module <module-name>,
#			<component-name>,
#                       <build | image>,
#                       <configuration-file>
#                       <full path to source directory>
#                       <optional list of prerequisite components>
#
define declare_source_module
$(call assert,$(call not,$(call defined,LMSBW_components,$(strip $(2)))),			\
	Component '$(strip $(2))' is already declared by module					\
	'$(call get,LMSBW_components,$(strip $(2)))')						\
$(call assert,$(call or,$(call seq,$(strip $(3)),build),$(call seq,$(strip $(3)),image)),	\
	Reason '$(strip $(3))' is not 'build' nor 'image')					\
$(call assert,$(call seq,$(wildcard $(strip $(5))),)						\
	Source directory '$(strip $(5))' does not exist)					\
$(call assert_exists,$(strip $(5)));								\
$(call set,LMSBW_components,$(strip $(2)),$(strip $(1)))					\
$(call __msk,$(2),kind,source)									\
$(call __msk,$(2),reason,$(3))									\
$(call __msk,$(2),module,$(1))									\
$(call __msk,$(2),component,$(2))								\
$(call __msk,$(2),prerequisite,$(6))								\
$(call __msk,$(2),source-directory,$(5))							\
$(call __msk,$(2),configuration-file,$(4))							\
$(call __msk,$(2),build-root-directory,$(call __expand_build_root,$(2)))			\
$(call __msk,$(2),build-directory,$(call __mgk,$(2),build-root-directory)/build)		\
$(call __msk,$(2),mtree-manifest,$(call __mgk,$(2),build-root-directory)/$(strip $(2)).mtree)	\
$(call __msk,$(2),destdir-directory,$(call __mgk,$(2),build-root-directory)/destdir)		\
$(call __msk,$(2),build-log,$(call __mgk,$(2),build-directory)/lmsbw-build.log)			\
$(call assert,$(call not,$(filter $(2),$(6))),							\
	Component '$(2)' cannot have itself as a prerequisite)					\
$(foreach p,$(6),$(call assert,$(call not,$(filter $(2),					\
	$(call get,LMSBW_$(strip $(p)),prerequisite))),						\
		Component '$(2)' and '$(p)' are mutually dependent))
endef

# fixup_component_fields <component>
#
#   Sets the component fields which cannot be assigned until the full
#   set of components is known.
#
define fixup_component_fields
$(call __msk,$(1),install-directory,				\
	$(call lmsbw_expand_install_directory,			\
		$(call get,LMSBW_$(strip $(1)),reason)))
endef
