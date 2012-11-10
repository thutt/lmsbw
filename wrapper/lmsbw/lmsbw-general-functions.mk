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

# lmsbw_expand_project_hash
#
#  This function produces a unique hash for the entire project.
#
#  It is used to ensure that the install directory is globally unique,
#  based on a set of global attributes.  If a global attribute
#  changes, for example:
#
#    o master configuration file
#    o adding a component
#    o removing a component
#    o changing the global toolchain
#
#  then the install directory should be different because the
#  generated product will be different.
#
#  Consider:
#
#    o Changing product SKU with a config file
#
#      If you have a product SKU that has the same set of components
#      as another SKU, but the individual components are compiled
#      differently, then just make sure each SKU has their own
#      configuration file, as the configuration file pathname is
#      included in the hash.
#
#    o Removing a component
#
#      It should not be in the 'install' directory, but can already be
#      present.  Using different install directory will ensure that
#      the removed component is not delivered.
#
#    o Changing global toolchain
#
#      This implies that different code will be generated, and a new
#      different install directory should be used.  The toolchain
#      chosen for each component affects their output directories,
#      too.
#
define lmsbw_expand_project_hash
$(call lmsbw_expand_md5sum_text,$(strip	\
	$(LMSBW_CONFIGURATION_FILE)	\
	$(LMSBW_components)		\
	$(LMSBW_TOOLCHAIN)		\
	$(call lmsbw_expand_global_settings)))
endef

# lmsbw_expand_global_settings
#
#  Expands the LMSBW_configuration{'global-settings'} array.  Expands
#  to nothing if the associative array exists.
#
#  This function does not quote the values of each key; if quoting is
#  necessary, it must be done when the key/value pair is set.
#
#  The keys are sorted so that the order will always be the same; this
#  is because the output is hashed.
#
define lmsbw_expand_global_settings
$(strip											\
	$(eval __gs:=$(call __gcv,global-settings))					\
	$(foreach key,$(sort $(call keys,$(__gs))),					\
		$(key)="$(call get,$(__gs),$(key))"))
endef

# lmsbw_expand_component_settings <component>
#
#  Expands the combination of LMSBW_cofiguration{'global-setttings'}
#  and <component>{'local-settings'} into 'key=value' expressions
#  suitable for including on the command line for a sub-invocation of
#  Make.
#
#  Keys in 'local-settings' override matching keys in
#  'global-settings'.
#
#  Expands to nothing if neither associative array exists.
#
#  This function does not quote the values of each key; if quoting is
#  necessary, it must be done when the key/value pair is set.
#
#  The keys are sorted so that the order will always be the same; this
#  is because the output is hashed.
#
define lmsbw_component_expand_settings
$(strip											\
	$(eval __ls:=$(call lmsbw_gcf,$(1),local-settings))				\
	$(eval __gs:=$(call __gcv,global-settings))					\
	$(foreach key,$(sort $(filter-out $(call keys,$(__ls)),$(call keys,$(__gs)))),	\
		$(key)="$(call get,$(__gs),$(key))")					\
	$(foreach key,$(sort $(call keys,$(__ls))),					\
		$(key)="$(call get,$(__ls),$(key))"))
endef

# lmsbw_expand_component_hash <component>
#
#   Expands to the md5sum value of a component.
#
#   This is used when creating directory names for the compoment.  The
#   hash should be a representation of attributes which should
#   manifest as a new directory.  For example, the toolchain for the
#   component, or the compiler options.
#
define lmsbw_expand_component_hash
$(call lmsbw_expand_md5sum_text,$(strip $(1))$(call lmsbw_gcf,$(strip $(1)),toolchain)$(call lmsbw_gcf,$(strip $(1)),build-output-download)$(call lmsbw_component_expand_settings,$(1)))
endef

# lmsbw_expand_install_directory <build | image>
#
#   Expands to the current 'install' directory.
#
#   This is a shared directory into which all components will install
#   shared resources such as executables, libraries and header files.
#
#   If a toolchain is not being used, this should just be considered
#   the 'install' directory -- a place where each component will
#   install deliverables so that other, depdenent, components can use
#   them.
#
#
# This can only be done AFTER all the components are configured.
#
define lmsbw_expand_install_directory
$(LMSBW_BUILD_DIR)/install/$(call lmsbw_expand_project_hash)
endef

# lmsbw_expand_mtree_guard <component label>,
#                     	   <mtree manifest pathname>
#                     	   <directory on which mtree is executed>
#                     	   <commands-to-execute>
#                          <optional configuration file>
#
#   This function expands into a conditional statement that guards the
#   '<commands-to-execute>' parameter.  The conditional guard does the
#   following:
#
#     o If the '<optional configuration file>' parameter is supplied,
#       and is newer than '<mtree manifest pathname>', execute
#       '<commands-to-execute>'.
#
#     o If there is a difference between the '<mtree manifest
#       pathname>' state and any files in '<directory on which mtree
#       is executed>', execute '<commands-to-execute>'.
#
#     o If '<commands-to-execute>' are executed, the '<mtree manifest
#       pathname>' will be updated to contain the current state of the
#       files in '<directory on which mtree is executed>'
#
#   This effectively makes guarding any sub-process based on file
#   attributes very simple: if the files in a subdirectory have not
#   changed since the last time the command was executed, do not
#   execute the commands.
#
define lmsbw_expand_mtree_command_guard
	set -e;									\
	if $(if $(5),[ $(2) -nt $(5) ] &&)					\
	    $(LMSBW_MTREE_CHECK_MANIFEST)					\
		$(if $(LMSBW_VERBOSE),--verbose)				\
		--component $(strip $(1))					\
		--mtree $(MTREE)						\
		--manifest "$(strip $(2))"					\
		--directory-tree "$(strip $(3))"; then				\
		$(PROGRESS) "$(strip $(1)): No files changed";			\
		exit 0;								\
	fi;									\
	$(4)									\
	if [ $$$$? -eq 0 ] ; then						\
		$(PROGRESS) "$(strip $(1)): Updating manifest";			\
		$(LMSBW_MTREE_GENERATE_MANIFEST)				\
			$(if $(LMSBW_VERBOSE),--verbose)			\
			--component $(strip $(1))				\
			--mtree $(MTREE)					\
			--manifest "$(strip $(2))"				\
			--directory-tree "$(strip $(3))";			\
	fi;
endef

# lmsbw_gcf <component-name>, <field-name>
#
#    Get Component Field
#
define lmsbw_gcf
$(call get,LMSBW_component_$(strip $(1)),$(strip $(2)))
endef


# lmsbw_scf <component-name>, <field-name>, <value>
#
#    Set Component Field
#
define lmsbw_scf
$(eval __scf:=$(call set,LMSBW_component_$(strip $(1)),$(strip $(2)),$(strip $(3))))
endef
