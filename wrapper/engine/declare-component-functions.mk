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

# __expand_build_root <component>
#
#  Expands to the root of the build directory for the provided
#  component.  The root will contain an md5sum hash to ensure that
#  every type of build will receive a unique directory: change an
#  option, or the toolchain being used, and the build system will
#  generate a different build directory.
#
define __expand_build_root
$(call lmsbw_assert_known_component,$(1))
$(call lmsbw_assert_known_function,$(1),lmsbw_expand_$(call lmsbw_gcf,$(1),reason)_build_root)
$(call lmsbw_expand_$(call lmsbw_gcf,$(1),reason)_build_root)/$(strip $(1))/$(call lmsbw_expand_component_hash,$(1))
endef

# declare_component_kind <component>, <kind>
#
#   Declares the type of the component.  This value is used to
#   determine how rules are generated, and how other 'kind'-specific
#   features are implemented.  Adding a new component 'kind', beyond
#   the original 'source', will require additional work to ensure that
#   all the proper targets are generated.
#
#   LMSBW has been written to produce errors when the 'kind' is not
#   yet supported.
#
define declare_component_kind
$(call lmsbw_assert_known_component,$(1))
$(call lmsbw_scf,$(1),kind,$(2))
endef

# declare_component_description <component>, <description>
#
#   Sets the optional description of the component.
#
define declare_component_description
$(call lmsbw_assert_known_component,$(1))
$(call lmsbw_scf,$(1),description,$(2))
endef

# declare_component_reason <component>, <reason>
#
#  Sets the 'reason' the component is being built.  It can be one of the following:
#
#    o build
#
#      This component is being built because it needs to be used by
#      the build.  It is not part of the delivered product.
#
#    o image
#
#      This component is being built because it needs to be delivered
#      with the product.  It is delivered in the 'iso image'.
#
define declare_component_reason
$(call lmsbw_assert_known_component,$(1))
$(call lmsbw_scf,$(1),reason,$(2))
endef

# declare_component_component <component>, <component>
#
#   Sets the component name.
#
define declare_component_component
$(call lmsbw_assert_known_component,$(1))
$(call lmsbw_scf,$(1),component,$(2))
endef

# declare_component_prerequisite <component>, <prerequisites>
#
#   Sets the list of components which must be built prior to this
#   component.
#
#   The second argument is a space separated list of component names.
#
#   LMSBW will ensure that the prerequisites are built & installed
#   prior to building this component.
#
define declare_component_prerequisite
$(call lmsbw_assert_known_component,$(1))
$(call lmsbw_scf,$(1),prerequisite,$(2))
endef

# declare_component_source_directory <component>, <absolute directory>
#
#   Associates a source directory with the component.
#
#   The second argument must be an absolute path of the directory
#   containing the sources.  Most importantly, the named directory
#   must contain a 'Makefile' to build the source.
#
define declare_component_source_directory
$(call lmsbw_assert_known_component,$(1))
$(call lmsbw_scf,$(1),source-directory,$(2))
endef

# declare_component_configuration_file <component>, <configuration file path>
#
#  This file associates the configuration file which declared the
#  component to the component.  This is done for dependency checking
#  and knowing when to rebuild the component; since the configuration
#  file is a Makefile, it can be used to alter the behavior of the
#  component build, and therefore changes to the configuration file
#  must induce a rebuild of the component.
#
define declare_component_configuration_file
$(call lmsbw_assert_known_component,$(1))
$(call lmsbw_scf,$(1),configuration-file,$(2))
endef

# set_component_internal_data <component>
#
#   Sets up build directories, mtree manifest fields, the location of
#   the build log and the dummy file which indicates the source API
#   has changed.
#
define set_component_internal_data
$(call lmsbw_assert_known_component,$(1))
endef

define check_build_prerequisites
$(foreach p,$(call lmsbw_gcf,$(1),prerequisite), \
	$(if $(call seq,$(call lmsbw_gcf,$(p),reason),image), \
		$(call lmsbw_build_needs_image,$(1),$(p))))
endef


# fixup_component_fields <component>
#
#   Sets the component fields which cannot be assigned until the full
#   set of components is known.
#
#$(call lmsbw_scf,$(1),build-root-directory,$(call __expand_build_root,$(1)))
define fixup_component_fields
$(eval __brd:=$(call set,LMSBW_component_$(strip $(1)),build-root-directory,$(strip $(call __expand_build_root,$(1)))))
$(call lmsbw_scf,$(1),build-directory,$(__brd)/build)
$(call lmsbw_scf,$(1),destdir-directory,$(__brd)/destdir)
$(call lmsbw_scf,$(1),source-mtree-manifest,$(__brd)/source.mtree)
$(call lmsbw_scf,$(1),build-log,$(call lmsbw_gcf,$(1),build-directory)/lmsbw-build.log)
$(call lmsbw_scf,$(1),install-directory,					\
	$(call lmsbw_expand_install_directory,$(call lmsbw_gcf,$(1),reason)))
$(if $(call seq,$(call lmsbw_gcf,$(1),install-target),),			\
	$(call component_attribute_install_target,$(strip $(1)),install))
$(if $(call seq,$(call lmsbw_gcf,$(1),reason),build), 	\
	$(call check_build_prerequisites,$(1)))
endef
