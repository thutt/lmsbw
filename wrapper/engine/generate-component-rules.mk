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
#  Expands to a list of direct prerequisites which can be used in a
#  build target.
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
#   provided component sources using the component.makefile.
#
#   The component.makefile is a trampoline that very quickly invokes
#   the components buildprocess to satisfy 'LMSBW_C_INSTALL_TARGET'.
#
define lmsbw_expand_build_component
	$(MESSAGE) "$(1): Trampoline to '$(1)' build system";					\
	$(TIME)											\
	-f "$(1): elapsed time: %E"								\
	--output="$(call lmsbw_gcf,$(1),build-directory)/build-time.text"			\
	$(MAKE)											\
		-f $(LMSBW_DIR)/wrapper/component/component.makefile				\
		-C $(dir $(call lmsbw_gcf,$(1),configuration-file))				\
		LMSBW_VERBOSE=1									\
		LMSBW_DIR="$(LMSBW_DIR)"							\
		LMSBW_C_COMPONENT=$(1)								\
		LMSBW_C_KIND="$(call lmsbw_gcf,$(1),kind)"					\
		LMSBW_C_SOURCE_DIRECTORY="$(call lmsbw_gcf,$(1),source-directory)"		\
		LMSBW_C_BUILD_DIRECTORY="$(call lmsbw_gcf,$(1),build-directory)"		\
		LMSBW_C_DESTDIR_DIRECTORY="$(call lmsbw_gcf,$(1),destdir-directory)"		\
		LMSBW_C_INSTALL_DIRECTORY="$(call lmsbw_gcf,$(1),install-directory)"		\
		LMSBW_C_BUILD_INSTALL_DIRECTORY="$(call lmsbw_expand_install_directory,build)"	\
		LMSBW_C_CONFIGURATION_FILE="$(call lmsbw_gcf,$(1),configuration-file)"		\
		LMSBW_C_INSTALL_TARGET="$(call lmsbw_gcf,$(1),install-target)"			\
		LMSBW_C_NO_PARALLEL="$(call lmsbw_gcf,$(1),no-parallel)"			\
		$(call lmsbw_component_expand_settings,$(1))					\
		$(call lmsbw_expand_toolchain,$(1))						\
		>$(call lmsbw_gcf,$(1),build-directory)/lmsbw-build.log 2>&1;			\
	$(if $(LMSBW_VERBOSE)$(LMSBW_ELAPSED_TIME),$(CAT)					\
		$(call lmsbw_gcf,$(1),build-directory)/build-time.text;)
endef

# lmsbw_check_api <component>, <directly dependent component>
#
#   Check the source or binary API of <component> to see if it has
#   changed.  The manifest of the API for <component> is stored in the
#   <directly dependent component>.
#
#   The mtree manifest name is generated on-the-fly.  Pre-generating
#   the API manifest names (like 'source-mtree-manifest') doesn't work
#   out well (for documentation & maintainability) because the key for
#   each such manifest would be somehow based on the name of the
#   prerequisite component.
#
#   Result:
#
#      Sets 'api_changed' to "yes" if the API has changed.
#
define lmsbw_check_api
$(foreach api_dir,$(call lmsbw_gcf,$(1),api),							\
	$(LMSBW_MTREE_CHECK_API) 								\
		$(if $(LMSBW_VERBOSE),--verbose)						\
		--component $(strip $(1))							\
		--directory-tree "$(call lmsbw_gcf,$(strip $(1)),destdir-directory)$(api_dir)"	\
		--manifest "$(call lmsbw_gcf,$(strip $(2)),build-root-directory)/$(strip $(1))$(subst /,.,$(api_dir))-api.mtree"	\
		--mtree $(MTREE) || api_changed="yes";)
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
api_changed="no";					\
$(foreach p,$(call lmsbw_gcf,$(1),prerequisite),	\
	$(call lmsbw_check_api,$(p),$(1)))
endef

# expand_component_submake_kind <component>
#
define expand_component_submake_kind
$(if $(call lmsbw_gcf,$(1),build-output-download),build_output_download,submake)
endef

# expand_component_submake <component>
#
#   This function expands to a value which can be used as a
#   prerequisite to the 'install' rule for a component.  In short, it
#   should expand to a target that will 'build' the component.  The
#   definition of 'build' is mutable: it could actually be building,
#   it could be downloading the destdir, or it could be some other
#   novel way of 'building' the software and installing it into the
#   destdir.
#
define expand_component_submake
install.$(strip $(1))_$(call expand_component_submake_kind,$(1))
endef

# generate_component_install_submake <stripped component name>
#
#   This function expands to rules which will recursively invoke Make
#   on component's build process.
#
#   This is only used on components which have not been marked to
#   download their build output.
#
define generate_component_install_submake
.PHONY:	install.$(1)_submake

install.$(1)_submake:	$(MTREE) $(call expand_prerequisites,$(1))
	+$(ATSIGN)set -e;							\
	$(call lmsbw_expand_api_checks,$(1))					\
	if [ "$$$${api_changed}" = "no" ] &&					\
	   [ $(call lmsbw_gcf,$(1),source-mtree-manifest) -nt			\
		$(call lmsbw_gcf,$(1),configuration-file) ] &&			\
	   $(LMSBW_MTREE_CHECK_MANIFEST)					\
		$(if $(LMSBW_VERBOSE),--verbose)				\
		--component $(1)						\
		--mtree $(MTREE)						\
		--manifest "$(call lmsbw_gcf,$(1),source-mtree-manifest)"	\
		--directory-tree "$(call lmsbw_gcf,$(1),source-directory)";	\
	then									\
		$(PROGRESS) "$(1): No files changed";				\
		exit 0;								\
	fi;									\
	$(call lmsbw_expand_build_component,$(1))				\
	$(PROGRESS) "$(1): Updating manifest";					\
	$(LMSBW_MTREE_GENERATE_MANIFEST)					\
		$(if $(LMSBW_VERBOSE),--verbose)				\
		--component $(1)						\
		--mtree $(MTREE)						\
		--manifest "$(call lmsbw_gcf,$(1),source-mtree-manifest)"	\
		--directory-tree "$(call lmsbw_gcf,$(1),source-directory)";
endef

# generate_component_install_build_output_download <stripped component name>
#
#  Generates the rule which is used to download the component's build
#  output into the components DESTDIR.  This is done for components
#  which are attributed with 'build-output-download'.
#
#  This function must download the component build output under the
#  same circumstances where 'generate_component_install_submake()'
#  will invoke the component's build process.  Although the conditions
#  remain the same, the checks are simpler; specifically, the
#  prerequisite component's APIs need not be checked.
#
#  Because the download script ensures that the source code exactly
#  matches an official build, the APIs of all prerequisites will
#  implicitly match with the build output downloaded for this
#  component.
#
define generate_component_install_build_output_download
.PHONY:	install.$(1)_build_output_download	\
	build_output_download_component_$(1)

install.$(1)_build_output_download:	$(MTREE) $(call expand_prerequisites,$(1))
	+$(ATSIGN)set -e;							\
	if [ $(call lmsbw_gcf,$(1),source-mtree-manifest) -nt			\
		$(call lmsbw_gcf,$(1),configuration-file) ] &&			\
	   $(LMSBW_MTREE_CHECK_MANIFEST)					\
		$(if $(LMSBW_VERBOSE),--verbose)				\
		--component $(1)						\
		--mtree $(MTREE)						\
		--manifest "$(call lmsbw_gcf,$(1),source-mtree-manifest)"	\
		--directory-tree "$(call lmsbw_gcf,$(1),source-directory)";	\
	then									\
		$(PROGRESS) "$(1): No files changed";				\
		exit 0;								\
	fi;									\
	set +e;									\
	$(call __gcv,component-build-output-download-script)			\
		$(if $(LMSBW_VERBOSE),--verbose)				\
		--component $(strip $(1))					\
		--build-root-directory $(call lmsbw_gcf,$(1),build-root-directory) \
		--destdir-directory $(call lmsbw_gcf,$(1),destdir-directory)	\
		--source-directory $(call lmsbw_gcf,$(1),source-directory);	\
	case $$$$? in								\
		"0")								\
			$(VERBOSE) "$(1): successful download" ;;		\
		"1")								\
			$(MESSAGE) "$(1): locally modified; download failed";	\
			exit 1 ;;						\
		"2")								\
			$(MESSAGE) "$(1): no corresponding build found"; 	\
			exit 2 ;;						\
		"3")								\
			$(MESSAGE) "$(1): missing command line parameter"; 	\
			exit 3 ;;						\
		*)								\
			$(MESSAGE) "$(1): Unknown build download failure ($?)";	\
			exit 100 ;;						\
	esac;									\
	set -e;									\
	$(PROGRESS) "$(1): Updating manifest";					\
	$(LMSBW_MTREE_GENERATE_MANIFEST)					\
		$(if $(LMSBW_VERBOSE),--verbose)				\
		--component $(1)						\
		--mtree $(MTREE)						\
		--manifest "$(call lmsbw_gcf,$(1),source-mtree-manifest)"	\
		--directory-tree "$(call lmsbw_gcf,$(1),source-directory)";

build-output-download-components:: build_output_download_component_$(1)

build_output_download_component_$(1):
	$(ATSIGN)$(ECHO) "$(1)";
endef

# generate_component_install <component>
#
#   Generates an 'install.<component>' target.  This is used to invoke
#   a subordinate make on the components's sources.
#
define generate_component_install
.PHONY:	install.$(strip $(1))				\
	install.$(strip $(1))_create_binary_api		\
	install.$(strip $(1))_update-install-directory

install:: install.$(strip $(1))

# Generates the rules which are used to 'build & install' the
# component; these may not actually build the component.  They must,
# however, fill in the component's DESTDIR with build output.
#
$(call lmsbw_assert_known_function,$(1),generate_component_install_$(call expand_component_submake_kind,$(strip $(1))))
$(call generate_component_install_$(call expand_component_submake_kind,$(strip $(1))),$(strip $(1)))

# install.$(strip $(1))_update-install-directory: Install from DESTDIR to sysroot
#
#  This command is a separate target because build output can be
#  shared between different build types.  It will be executed each
#  time lmsbw is executed, as this ensures that the sysroot for the
#  current build product will be up-to-date with the latest build.
#
#  When switching between different build directories, the current
#  directory must be copied into the install directory.  This is
#  ensured with the '--checksum' option.  Do not use '--update'.
#
#  If this were, instead, done as part of the submake, or guarded by
#  mtree, the sysroot would not always be up-to-date with the latest
#  build images.

install.$(strip $(1))_update-install-directory:		\
	$(call expand_component_submake,$(1))
	$(ATSIGN)$(PROGRESS) "$(1): Install";
	$(ATSIGN)$(RSYNC)						\
		--quiet							\
		--executability						\
		--group							\
		--links							\
		--owner							\
		--perms							\
		--recursive						\
		--times							\
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
	$(ATSIGN)$(PRINTF) "%35s : %s\n" "$(1)" "$(call lmsbw_gcf,$(1),description)";

endef

# generate_component_destdir <component>
#
#   This generates a rule which will cause the component's DESTDIR to
#   be displayed.
#
define generate_component_destdir
.PHONY:	destdir.$(strip $(1))
destdir::	destdir.$(strip $(1))

destdir.$(strip $(1)):
	$(ATSIGN)$(MESSAGE) "$(1):$(call lmsbw_gcf,$(1),destdir-directory)";

endef

# generate_component_builddir <component>
#
#   This generates a rule which will cause the component's build
#   directory to be displayed.
#
define generate_component_builddir
.PHONY:	builddir.$(strip $(1))
builddir::	builddir.$(strip $(1))

builddir.$(strip $(1)):
	$(ATSIGN)$(MESSAGE) "$(1):$(call lmsbw_gcf,$(1),build-directory)";

endef

# generate_component_sourcedir <component>
#
#   This generates a rule which will cause the component's source
#   directory to be displayed.
#
define generate_component_sourcedir
.PHONY:	sourcedir.$(strip $(1))
sourcedir::	sourcedir.$(strip $(1))

sourcedir.$(strip $(1)):
	$(ATSIGN)$(MESSAGE) "$(1):$(call lmsbw_gcf,$(1),source-directory)";

endef

# generate_component_installdir <component>
#
#   This generates a rule which will cause the component's install
#   directory to be displayed.
#
define generate_component_installdir
.PHONY:	installdir.$(strip $(1))
installdir::	installdir.$(strip $(1))

installdir.$(strip $(1)):
	$(ATSIGN)$(MESSAGE) "$(1):$(call lmsbw_gcf,$(1),install-directory)";

endef
