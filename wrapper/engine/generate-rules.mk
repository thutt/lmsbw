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

# expand_prerequisites <component>
#
#  Expands to a list of prerequisites which can be used in a build
#  target.
#
#  Each of the items on the 'prerequisite' list must be built &
#  installed prior to <component> being built, thus each will be
#  transformed into the 'install.' target name.
#
define expand_prerequisites
$(LMSBW_TARBALL_REPOSITORY)				\
$(LMSBW_DIRECTORIES)					\
$(call lmsbw_gcf,$(1),build-directory)			\
$(call lmsbw_gcf,$(1),destdir-directory)			\
$(call lmsbw_gcf,$(1),install-directory)			\
$(patsubst %,install.%,$(call lmsbw_gcf,$(1),prerequisite))
endef

# generate_component_directory_rules <component>
#
#   Generate rules to ensure that the necessary component directories
#   are created.
#
define generate_component_directory_rules
$(call lmsbw_gcf,$(1),build-directory) $(call lmsbw_gcf,$(1),destdir-directory):
	$(ATSIGN)$(PROGRESS) "$(1): Creating directory: '$$@'";
	$(ATSIGN)$(MKDIR) --parents $$@;

endef

# lmsbw_expand_toolchain <component>
#
#  LMSBW guarantees that when a toolchain is associated with a
#  component, LMSBW_TOOLCHAINS_ROOT will be a valid root directory
#  containing the specified toolchains.  If the component has a
#  toolchain specified, then set the variables for the recursive Make
#  invocation; otherwise do not set them at all.
#
define lmsbw_expand_toolchain
$(if $(call lmsbw_gcf,$(1),toolchain),				\
	LMSBW_C_TOOLCHAINS_ROOT=$(LMSBW_TOOLCHAINS_ROOT)	\
	LMSBW_C_TOOLCHAIN="$(call lmsbw_gcf,$(1),toolchain)")
endef

# lmsbw_expand_build_component <component>
#
#   Expands to the commands which invoke a subordinate make on the
#   provided component sources.
#
define lmsbw_expand_build_component
	$(MESSAGE) "$(1): Trampoline to '$(1)' build system";					\
	$(TIME)											\
	-f "$(foreach v,$(shell seq $(MAKELEVEL))," ") [$(MAKELEVEL)]  $(1): elapsed time: %E"	\
	--output="$(call lmsbw_gcf,$(1),build-directory)/build-time.text"			\
	$(MAKE)											\
		-f $(LMSBW_DIR)/wrapper/component/component.makefile				\
		-C $(dir $(call lmsbw_gcf,$(1),configuration-file))				\
		$(call lmsbw_makeflags)								\
		LMSBW_VERBOSE=1									\
		LMSBW_DIR="$(LMSBW_DIR)"							\
		LMSBW_C_COMPONENT=$(1)								\
		LMSBW_C_KIND="$(call lmsbw_gcf,$(1),kind)"					\
		LMSBW_C_SOURCE_DIRECTORY="$(call lmsbw_gcf,$(1),source-directory)"		\
		LMSBW_C_BUILD_DIRECTORY="$(call lmsbw_gcf,$(1),build-directory)"		\
		LMSBW_C_DESTDIR_DIRECTORY="$(call lmsbw_gcf,$(1),destdir-directory)"		\
		LMSBW_C_INSTALL_DIRECTORY="$(call lmsbw_gcf,$(1),install-directory)"		\
		LMSBW_C_CONFIGURATION_FILE="$(call lmsbw_gcf,$(1),configuration-file)"		\
		LMSBW_C_BUILD_TARGET="$(call lmsbw_gcf,$(1),build-target)"			\
		LMSBW_C_INSTALL_TARGET="$(call lmsbw_gcf,$(1),install-target)"			\
		LMSBW_C_NO_PARALLEL="$(call lmsbw_gcf,$(1),no-parallel)"			\
		CFLAGS="-MMD $(call lmsbw_gcf,$(1),cflags)"					\
		$(call lmsbw_expand_toolchain,$(1))						\
		>$(call lmsbw_gcf,$(1),build-directory)/lmsbw-build.log 2>&1;			\
	$(if $(LMSBW_VERBOSE)$(LMSBW_ELAPSED_TIME),$(CAT)					\
		$(call lmsbw_gcf,$(1),build-directory)/build-time.text;)
endef

# lmsbw_check_api <component>, <binary | source>, <directly dependent component>
#
#   Check the source or binary API of <component> to see if it has
#   changed.  The manifest of the API for <component> is stored in the
#   <directly dependent component>.
#
#   Result:
#
#      Sets $(2)_api_changed to "yes" if the API has changed.
#
define lmsbw_check_api
$(LMSBW_MTREE_CHECK_API) 						\
	$(if $(LMSBW_VERBOSE),--verbose)				\
	--component $(strip $(1))					\
	--directory-tree "$(call lmsbw_gcf,$(strip $(1)),destdir-directory)$(call lmsbw_gcf,$(strip $(1)),$(2)-api)" \
	--manifest "$(call lmsbw_gcf,$(strip $(3)),build-root-directory)/$(strip $(1)).$(2)-api-mtree-manifest"	\
	--mtree $(MTREE) || $(2)_api_changed="yes";
endef

# lmsbw_expand_api_checks <component>
#
#  Checks that if source API & binary API directories of prerequisite
#  components have changed.
#
#  This function generates bash code which is part of an 'if' guard.
#  The generated code should produce TRUE when <component> should NOT
#  be built, and it should generate FALSE when <component> should be
#  built.
#
define lmsbw_expand_api_checks
binary_api_changed="no";						\
source_api_changed="no";						\
$(if $(call lmsbw_gcf,$(1),prerequisite),				\
	$(foreach p,$(call lmsbw_gcf,$(1),prerequisite),		\
		$(if $(call lmsbw_gcf,$(p),binary-api),			\
			$(call lmsbw_check_api,$(p),binary,$(1)))	\
		$(if $(call lmsbw_gcf,$(p),source-api),			\
			$(call lmsbw_check_api,$(p),source,$(1)))	\
))
endef

# generate_component_install <component>
#
#   Generates an 'install.<component>' target.  This is used to invoke
#   a subordinate make on the components's sources.
#
define generate_component_install
.PHONY:	install.$(strip $(1))				\
	install.$(strip $(1))_submake			\
	install.$(strip $(1))_create_binary_api		\
	install.$(strip $(1))_update-install-directory

install:: install.$(strip $(1))

install.$(strip $(1))_submake:	$(MTREE) $(call expand_prerequisites,$(1))
	$(ATSIGN)set -e;							\
	$(call lmsbw_expand_api_checks,$(1))					\
	if [ "$$$${binary_api_changed}" = "no" ] &&				\
	   [ "$$$${source_api_changed}" = "no" ] &&				\
	   [ $(call lmsbw_gcf,$(1),source-mtree-manifest) -nt			\
		$(call lmsbw_gcf,$(1),configuration-file) ] &&			\
	   $(LMSBW_MTREE_CHECK_MANIFEST)					\
		$(if $(LMSBW_VERBOSE),--verbose)				\
		--component $(strip $(1))					\
		--mtree $(MTREE)						\
		--manifest "$(call lmsbw_gcf,$(1),source-mtree-manifest)"	\
		--directory-tree "$(call lmsbw_gcf,$(1),source-directory)";	\
	then									\
		$(PROGRESS) "$(strip $(1)): No files changed";			\
		exit 0;								\
	fi;									\
	$(call lmsbw_expand_build_component,$(1))				\
	$(PROGRESS) "$(strip $(1)): Updating manifest";				\
	$(LMSBW_MTREE_GENERATE_MANIFEST)					\
		$(if $(LMSBW_VERBOSE),--verbose)				\
		--component $(strip $(1))					\
		--mtree $(MTREE)						\
		--manifest "$(call lmsbw_gcf,$(1),source-mtree-manifest)"	\
		--directory-tree "$(call lmsbw_gcf,$(1),source-directory)";	\


install.$(strip $(1))_update-install-directory:	install.$(strip $(1))_submake
	$(ATSIGN)$(PROGRESS) "$(1): Install";
	$(ATSIGN)$(RSYNC)						\
		--quiet							\
		--compress						\
		--executability						\
		--group							\
		--links							\
		--owner							\
		--perms							\
		--recursive						\
		--times							\
		--update						\
		$(call lmsbw_gcf,$(strip $(1)),destdir-directory)/	\
		$(call lmsbw_gcf,$(strip $(1)),install-directory);

install.$(strip $(1)):	install.$(strip $(1))_update-install-directory
endef

# generate_component_clean <component>
#
#   This rule will delete the 'build-directory' and
#   'destdir-directory' array entries.  It does not remove any files
#   installed in the 'install' directory.
#
define generate_component_clean
.PHONY:	clean.$(strip $(1))

clean:: clean.$(strip $(1))

clean.$(strip $(1)):
	$(ATSIGN)$(MESSAGE) "$(1): Cleaning $(1)";
	$(ATSIGN)$(RM) -rf $(call lmsbw_gcf,$(1),build-root-directory);

endef

# generate_component_build_log <component>
#
#   This function generates a rule to dump the build log of the
#   specified component to stdout.
#
define generate_component_build_log
.PHONY:	log.$(strip $(1))

log::	log.$(strip $(1))

log.$(strip $(1)):
	$(ATSIGN)$(if $(wildcard $(call lmsbw_gcf,$(1),build-log)),			\
		$(CAT) $(call lmsbw_gcf,$(1),build-log),				\
		$(MESSAGE) "'$(1): $(call lmsbw_gcf,$(1),build-log)' does not exist")

endef

# generate_component_component <component>
#
#   This generates a rule which will cause the component name to be
#   displayed.
#
define generate_component_component
.PHONY:	component.$(strip $(1))

components:: component.$(strip $(1))

component.$(strip $(1)):
	$(ATSIGN)$(PRINTF) "%25s : %s\n" "$(1)" "$(call lmsbw_gcf,$(1),description)";

endef

# Generate the rules necessary to build each 'kind' of component.  The
# function to call for each kind is generated by the value of the
# 'kind' component key.
#
$(foreach c,$(LMSBW_components),							\
	$(call lmsbw_assert_known_function,$(c),					\
		generate_component_rules_$(call lmsbw_gcf,$(c),kind))			\
	$(eval $(call generate_component_rules_$(call lmsbw_gcf,$(c),kind),$(c)))	\
)
