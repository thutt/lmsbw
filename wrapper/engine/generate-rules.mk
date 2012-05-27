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
$(BW_TARBALL_REPOSITORY)						\
$(LMSBW_DIRECTORIES)							\
$(call get,LMSBW_$(strip $(1)),build-directory)				\
$(call get,LMSBW_$(strip $(1)),destdir-directory)			\
$(call get,LMSBW_$(strip $(1)),install-directory)			\
$(patsubst %,install.%,$(call get,LMSBW_$(strip $(1)),prerequisite))
endef

# generate_component_directory_rules <component>
#
define generate_component_directory_rules
$(call get,LMSBW_$(strip $(1)),build-directory)			\
	$(call get,LMSBW_$(strip $(1)),destdir-directory):
	$(ATSIGN)$(PROGRESS) "$(1): Creating directory: '$$@'";
	$(ATSIGN)$(MKDIR) --parents $$@;

endef

# lmsbw_expand_build_module <component>
#
#   Expands to the commands which invoke a subordinate make on the
#   provided module sources.
#
define lmsbw_expand_build_module
	$(MESSAGE) "$(1): Invoking '$(1)' build system"; \
	$(TIME)											\
	-f "$(foreach v,$(shell seq $(MAKELEVEL))," ") [$(MAKELEVEL)]  $(1): elapsed time: %E"	\
	--output="$(call get,LMSBW_$(strip $(1)),build-directory)/build-time.text"		\
	$(MAKE)											\
		-f $(LMSBW_DIR)/wrapper/module/module.makefile					\
		-C $(dir $(call get,LMSBW_$(strip $(1)),configuration-file))			\
		$(call lmsbw_makeflags)								\
		LMSBW_VERBOSE=1									\
		LMSBW_DIR="$(LMSBW_DIR)"							\
		LMSBW_COMPONENT=$(1)								\
		LMSBW_KIND="$(call get,LMSBW_$(strip $(1)),kind)"				\
		LMSBW_SOURCE_DIRECTORY="$(call get,LMSBW_$(strip $(1)),source-directory)"	\
		LMSBW_BUILD_DIRECTORY="$(call get,LMSBW_$(strip $(1)),build-directory)"		\
		LMSBW_DESDIR_DIRECTORY="$(call get,LMSBW_$(strip $(1)),destdir-directory)"	\
		LMSBW_CONFIGURATION_FILE="$(call get,LMSBW_$(strip $(1)),configuration-file)"	\
		install										\
		>$(call get,LMSBW_$(strip $(1)),build-directory)/lmsbw-build.log 2>&1;		\
	$(if $(LMSBW_VERBOSE)$(LMSBW_ELAPSED_TIME),$(CAT)					\
		$(call get,LMSBW_$(strip $(1)),build-directory)/build-time.text;)
endef

# generate_component_install <component>
#
#   Generates an 'install.<component>' target.  This is used to invoke
#   a subordinate make on the module's sources.
#
define generate_component_install
.PHONY:	install.$(strip $(1))

install:: install.$(strip $(1))

install.$(strip $(1)):	$(MTREE) $(call expand_prerequisites,$(1))
	$(call lmsbw_component_mtree_command_guard,$(1),	\
		$(call lmsbw_expand_build_module,$(1)))

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
	$(ATSIGN)$(RM) -rf						\
		$(call get,LMSBW_$(strip $(1)),build-directory)		\
		$(call get,LMSBW_$(strip $(1)),destdir-directory)

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
	$(ATSIGN)$(if $(wildcard $(call get,LMSBW_$(strip $(1)),build-log)),			\
		$(CAT) $(call get,LMSBW_$(strip $(1)),build-log),				\
		$(MESSAGE) "'$(1): $(call get,LMSBW_$(strip $(1)),build-log)' does not exist")

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
	$(ATSIGN)$(PRINTF) "%25s : %s\n" "$(1)" "$(call get,LMSBW_$(strip $(1)),description)";

endef

# generate_component_rules_source <component>
#
#   Generate build rules for a 'source' module.
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
endef

$(foreach c,$(call keys,LMSBW_components),							   \
	$(call assert,										   \
		$(call or,									   \
			$(call seq,$(call get,LMSBW_$(strip $(c)),kind),source),		   \
			$(call seq,$(call get,LMSBW_$(strip $(c)),kind),download)),		   \
		Module kind '$(call get,LMSBW_$(strip $(c)),kind)' is not 'source' nor 'download') \
	$(eval $(call generate_component_rules_$(call get,LMSBW_$(strip $(c)),kind),$(c)))	   \
)
