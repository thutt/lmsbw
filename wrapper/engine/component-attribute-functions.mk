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
# component_attribute_no_parallel_build <component>
#
#   Ensures that the individual component bearing this attribute will
#   not be built in parallel.
#
#   This attribute, if present, is assigned to LMSBW_C_NO_PARALLEL
#   when invoking 'component.makefile'.  If not present,
#   LMSBW_C_NO_PARALLEL is defined, but will have no value.
#
define component_attribute_no_parallel_build
$(call lmsbw_assert_known_component,$(1))
lmsbw_dcnpb:=$(call lmsbw_scf,$(1),no-parallel,-j 1)
endef


# component_attribute_install_target <component> <list of targets>
#
#  Sets the targets that will be passed to the components's Makefile
#  as the preliminary targets for the 'install' phase.
#
#  If not set, LMSBW will set it to 'install'.
#
define component_attribute_install_target
$(call lmsbw_assert_known_component,$(1))
lmsbw_dcbt:=$(call lmsbw_scf,$(1),install-target,$(2))
endef


# component_attribute_api <component>, <list of directories>
#
#  This function declares a list of directories which contain the
#  public API of the component.  The directories can contain the
#  source API (header files) and/or the binary API (static libs).
#
#  This is be used to cause dependent components to be rebuilt *only*
#  when the API has been changed.
#
#  The files installed in $(DESTDIR) are used when checking if the API
#  has changed.
#
#  If you are using dynamic libraries, the directories in which they
#  are installed should not be included in the API directories; this
#  is because internal changes to dynamic libraries do not affect
#  components which are simply linked to them.
#
define component_attribute_api
$(call lmsbw_assert_known_component,$(1))
lmsbw_dca:=$(call lmsbw_scf,$(1),api,$(strip $(2)))
endef

# component_attribute_toolchain <component>,<toolchain-name>
#
#
define component_attribute_toolchain
$(call lmsbw_assert_known_component,$(1))	\
$(call lmsbw_scf,$(1),toolchain,$(2))
endef

# component_attribute_build_output_download <component>
#
#   Sets a component have its DESTDIR downloaded.
#
#   Using this API removes the 'build' step for a component; the build
#   output will be downloaded using a script declared using
#   'component-build-output-download-script'.
#
#   If downloading this component's build output has been disabled
#   with '--no-download', or downloading build output has been
#   disabled with --disable-build-output-download, the attribute is
#   never set; this causes the component to always build.
#
define component_attribute_build_output_download
$(call lmsbw_assert_known_component,$(1))
$(eval __cabod_filter:=$(filter $(1),$(LMSBW_BUILD_OUTPUT_NO_DOWNLOAD)))
$(eval __cabod_or:=$(call or,$(__cabod_filter),$(LMSBW_DISABLE_BUILD_OUTPUT_DOWNLOAD)))
$(if $(call not,$(__cabod_or)),$(call lmsbw_scf,$(1),build-output-download,$(true)))
endef


# component_attribute_local_settings <component>, <associative array name>
#
#   Sets the name of an associative array that contains Make-style
#   settings that will be passed to the component's build process.
#
#   It is through this associative array that component-specific
#   build-time settings (such as CFLAGS) should be set.
#
define component_attribute_local_settings
$(call lmsbw_assert_known_component,$(1))		\
$(call lmsbw_scf,$(1),local-settings,$(strip $(2)))
endef


# component_attribute_poc <component>, <poc>
#
#   Sets a 'point of contact' for the component.
#
#   The 'poc' value is output by the 'report' verb.
#
#   The <poc> parameter is a space separated list of contact names.
#
define component_attribute_poc
$(call lmsbw_assert_known_component,$(1))		\
$(call lmsbw_scf,$(1),poc,$(strip $(2)))
endef

# component_attribute_license <component>, <software license>
#
#   Sets a 'software license' for the component.
#
#   The value is output by the 'report' verb, and by the
#   'license[.<component>] verb.
#
#   The <software license> parameter is a space separated list of
#   contact names.
#
#   This information can be used to determine if components are
#   importing components in an incompatible manner -- for example, if
#   a GPL-licensed component is importing an API from a proprietary
#   component.
#
define component_attribute_license
$(call lmsbw_assert_known_component,$(1))		\
$(call lmsbw_scf,$(1),license,$(strip $(2)))
endef


# component_attribute_exports_api <component>
#
#  This function sets an internal attribute on the component to
#  indicate that an API is exported.  LMSBW will generate additional
#  rules to invoke the component's Makefile using the 'install-api'
#  target before any other rules are executed.
#
#  The component's Makefile must install the exported header files
#  into the DESTDIR, and LMSBW will finish the install to the global
#  install directory.
#
#  This can be used to ensure that all global header files are placed
#  into the global install directory, ready for use, before any
#  components are built.
#
define component_attribute_exports_api
$(call lmsbw_assert_known_component,$(1))	\
$(call lmsbw_scf,$(1),exports-api,$(true))	\
$(eval LMSBW_API_NEED_INSTALLING=$(true))
endef
