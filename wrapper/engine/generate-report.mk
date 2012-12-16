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

# generate_component_report_source <component>
#
#   Generates a report for a 'source' component.
#
#   This function is called only for component with 'kind' set to
#   'source'
#
define generate_component_report_source
__$(strip $(1)).report.$(call lmsbw_gcf,$(1),kind):
	@$(ECHO) "$(1)|Component   : $(call lmsbw_gcf,$(1),component)";
	@$(ECHO) "$(1)|  desc      : $(call lmsbw_gcf,$(1),description)";
	@$(ECHO) "$(1)|  POC       : $(call lmsbw_gcf,$(1),poc)";
	@$(ECHO) "$(1)|  config    : $(call lmsbw_gcf,$(1),configuration-file)";
	@$(ECHO) "$(1)|  kind      : $(call lmsbw_gcf,$(1),kind)";
	@$(ECHO) "$(1)|  reason    : $(call lmsbw_gcf,$(1),reason)";
	@$(ECHO) "$(1)|  source    : $(call lmsbw_gcf,$(1),source-directory)";
	@$(ECHO) "$(1)|  prereq    : $(call lmsbw_gcf,$(1),prerequisite)";
	@$(ECHO) "$(1)|  direct dep: $(call lmsbw_gcf,$(1),direct-dependent)";
	@$(ECHO) "$(1)|  toolchain : $(call lmsbw_gcf,$(1),toolchain)";
	@$(ECHO) "$(1)|  api       : $(call lmsbw_gcf,$(1),api)";
	@$(ECHO) "$(1)|  build / dl: $(if $(call lmsbw_gcf,$(1),build-output-download),download,build)";
	@$(ECHO) "$(1)|  settings  : $(call lmsbw_component_expand_settings,$(1))";
	@$(ECHO) "$(1)|Install Root: $(call lmsbw_gcf,$(1),install-directory)";
	@$(ECHO) "$(1)|Build Root  : $(call lmsbw_gcf,$(1),build-root-directory)";
	@$(ECHO) "$(1)|  build     : $(call lmsbw_gcf,$(1),build-directory)";
	@$(ECHO) "$(1)|  destdir   : $(call lmsbw_gcf,$(1),destdir-directory)";
	@$(ECHO) "$(1)|Targets     :";
	@$(ECHO) "$(1)|  install   : $(call lmsbw_gcf,$(1),install-target)";

endef

# generate_component_prerequisite_report <component>
#
#   This function generates a rule to dump the prerequisite components.
#
define generate_component_prerequisite_report
.PHONY:	prerequisite.$(strip $(1))

prerequisite-report::	prerequisite.$(strip $(1))

prerequisite.$(strip $(1)):
	$(ATSIGN)$(ECHO) "$(1): $(call lmsbw_gcf,$(1),prerequisite)";

endef

# generate_component_dependent_report <component>
#
#   This function generates a rule to dump the dependent components.
#
define generate_component_dependent_report
.PHONY:	dependent.$(strip $(1))

dependent-report::	dependent.$(strip $(1))

dependent.$(strip $(1)):
	$(ATSIGN)$(ECHO) "$(1): $(call lmsbw_gcf,$(1),direct-dependent)";

endef

# generate_component_report <component>
#
#   Generates a report for any component 'kind'.
#
define generate_component_report
$(call lmsbw_assert_known_function,$(1),				\
	generate_component_report_$(call lmsbw_gcf,$(1),kind))

report:: report-project-info report.$(strip $(1))
.PHONY:	report.$(strip $(1)) __$(strip $(1)).report.$(call lmsbw_gcf,$(1),kind)

$(call generate_component_report_$(call lmsbw_gcf,$(1),kind),$(1))

report.$(strip $(1)): __$(strip $(1)).report.$(call lmsbw_gcf,$(1),kind)

endef

report-project-info:
	$(ATSIGN)$(ECHO) "lmsbw-project|configuration: $(LMSBW_CONFIGURATION_FILE)";
