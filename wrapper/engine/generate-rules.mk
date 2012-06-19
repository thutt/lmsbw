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
$(BW_TARBALL_REPOSITORY)				\
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

# lmsbw_expand_build_module <component>
#
#   Expands to the commands which invoke a subordinate make on the
#   provided component sources.
#
define lmsbw_expand_build_module
	$(MESSAGE) "$(1): Invoking '$(1)' build system";					\
	$(TIME)											\
	-f "$(foreach v,$(shell seq $(MAKELEVEL))," ") [$(MAKELEVEL)]  $(1): elapsed time: %E"	\
	--output="$(call lmsbw_gcf,$(1),build-directory)/build-time.text"			\
	$(MAKE)											\
		-f $(LMSBW_DIR)/wrapper/module/module.makefile					\
		-C $(dir $(call lmsbw_gcf,$(1),configuration-file))				\
		$(call lmsbw_makeflags)								\
		LMSBW_VERBOSE=1									\
		LMSBW_DIR="$(LMSBW_DIR)"							\
		LMSBW_COMPONENT=$(1)								\
		LMSBW_KIND="$(call lmsbw_gcf,$(1),kind)"					\
		LMSBW_SOURCE_DIRECTORY="$(call lmsbw_gcf,$(1),source-directory)"		\
		LMSBW_BUILD_DIRECTORY="$(call lmsbw_gcf,$(1),build-directory)"			\
		LMSBW_DESDIR_DIRECTORY="$(call lmsbw_gcf,$(1),destdir-directory)"		\
		LMSBW_INSTALL_DIRECTORY="$(call lmsbw_gcf,$(1),install-directory)"		\
		LMSBW_CONFIGURATION_FILE="$(call lmsbw_gcf,$(1),configuration-file)"		\
		LMSBW_BUILD_TARGET="$(call lmsbw_gcf,$(1),build-target)"			\
		LMSBW_INSTALL_TARGET="$(call lmsbw_gcf,$(1),install-target)"			\
		LMSBW_NO_PARALLEL="$(call lmsbw_gcf,$(1),no-parallel)"				\
		>$(call lmsbw_gcf,$(1),build-directory)/lmsbw-build.log 2>&1;			\
	$(if $(LMSBW_VERBOSE)$(LMSBW_ELAPSED_TIME),$(CAT)					\
		$(call lmsbw_gcf,$(1),build-directory)/build-time.text;)
endef

# generate_component_install <component>
#
#   Generates an 'install.<component>' target.  This is used to invoke
#   a subordinate make on the components's sources.
#
define generate_component_install
.PHONY:	install.$(strip $(1)) install.$(strip $(1))_api_check

install:: install.$(strip $(1)) install.$(strip $(1))_api_check

install.$(strip $(1)):	$(MTREE) $(call expand_prerequisites,$(1))
	$(call lmsbw_component_mtree_command_guard,$(1),	\
		$(call lmsbw_expand_build_module,$(1)))

install.$(strip $(1))_api_check:
	$(ATSIGN)if [ -e "$(call lmsbw_gcf,$(1),source-api-changed)" ] ; then	\
		$(call lmsbw_source_api_changed_failure,$(1))			\
	fi;
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

# lmsbw_generate_api_changed <component>
#
#   Generates a rule which can be used to clean all modules directly
#   dependent upon the provided component.
define lmsbw_generate_api_changed
.PHONY:	source-api-changed.$(strip $(1))

source-api-changed.$(strip $(1)):					\
	clean.$(strip $(1))						\
	$(addprefix clean.,$(call lmsbw_gcf,$(1),direct-dependents))
	$(ATSIGN)$(TRUE);
endef


# generate_component_rules_source <component>
#
#   Generate build rules for a 'source' component.
#
define generate_component_rules_source
$(call generate_component_directory_rules,$(1))
$(call generate_component_install,$(1))
$(call generate_component_component,$(1))
$(call generate_component_clean,$(1))
$(call generate_component_report,$(1))
$(call generate_component_build_log,$(1))
$(call generate_component_prerequisite_report,$(1))
$(call generate_component_dependent_report,$(1))
$(call lmsbw_generate_api_changed,$(1))
endef

$(foreach c,$(call keys,LMSBW_components),						\
	$(call lmsbw_assert_known_function,$(c),					\
		generate_component_rules_$(call lmsbw_gcf,$(c),kind))			\
	$(eval $(call generate_component_rules_$(call lmsbw_gcf,$(c),kind),$(c)))	\
)
