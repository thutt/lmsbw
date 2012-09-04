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


# component_attribute_build_target <component> <list of targets>
#
#  Sets the targets that will be passed to the component's Makefile as
#  the preliminary targets for the 'bulid' phase.
#
#  If not set, LMSBW will not use a specific set of targets for the
#  'build' phase, and will end up using the default (or first) rule in
#  the component's Makefile.
#
define component_attribute_build_target
$(call lmsbw_assert_known_component,$(1))
lmsbw_dcbt:=$(call lmsbw_scf,$(1),build-target,$(2))
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

# component_attribute_cflags <component>,<cflags value>
#
#
define component_attribute_cflags
$(call lmsbw_assert_known_component,$(1))	\
$(call lmsbw_scf,$(1),cflags,$(2))
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
