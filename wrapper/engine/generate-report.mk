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
#   Generates a report for a 'source' module.
#
define generate_component_report_source
__$(strip $(1)).report.$(call get,LMSBW_$(strip $(1)),kind):
	@$(ECHO) "$(1)|Module      : $(call get,LMSBW_$(strip $(1)),module)";
	@$(ECHO) "$(1)|  Component : $(call get,LMSBW_$(strip $(1)),component)";
	@$(ECHO) "$(1)|  Kind      : $(call get,LMSBW_$(strip $(1)),kind)";
	@$(ECHO) "$(1)|  Reason    : $(call get,LMSBW_$(strip $(1)),reason)";
	@$(ECHO) "$(1)|  Source    : $(call get,LMSBW_$(strip $(1)),source-directory)";
	@$(ECHO) "$(1)|  Prereq    : $(call get,LMSBW_$(strip $(1)),prerequisite)";
	@$(ECHO) "$(1)|  config    : $(call get,LMSBW_$(strip $(1)),configuration-file)";
	@$(ECHO) "$(1)|Build Root  : $(call get,LMSBW_$(strip $(1)),build-root-directory)";
	@$(ECHO) "$(1)|  mtree     : $(call get,LMSBW_$(strip $(1)),mtree-manifest)";
	@$(ECHO) "$(1)|  build     : $(call get,LMSBW_$(strip $(1)),build-directory)";
	@$(ECHO) "$(1)|  destdir   : $(call get,LMSBW_$(strip $(1)),destdir-directory)";
	@$(ECHO) "$(1)|  install   : $(call get,LMSBW_$(strip $(1)),install-directory)";
endef

# generate_component_prerequisite_report <component>
#
#   This function generates a rule to dump the prerequisite modules.
#
define generate_component_prerequisite_report
.PHONY:	prerequisite.$(strip $(1))

prerequisite-report::	prerequisite.$(strip $(1))

prerequisite.$(strip $(1)):
	$(ATSIGN)$(ECHO) "$(1): $(call get,LMSBW_$(strip $(1)),prerequisite)";

endef

# generate_component_dependent_report <component>
#
#   This function generates a rule to dump the dependent modules.
#
define generate_component_dependent_report
.PHONY:	dependent.$(strip $(1))

dependent-report::	dependent.$(strip $(1))

dependent.$(strip $(1)):
	$(ATSIGN)$(ECHO) "$(1): $(strip $(foreach c,$(call keys,LMSBW_components),		\
	$(if $(filter $(1),$(call get,LMSBW_$(c),prerequisite)),$(c))))";

endef

# generate_component_report <component>
#
#   Generates a report for any type of module.
#
define generate_component_report
$(call assert,											\
	$(call or,										\
		$(call seq,$(call get,LMSBW_$(strip $(1)),kind),source),			\
		$(call seq,$(call get,LMSBW_$(strip $(1)),kind),download)),			\
	Module kind '$(call get,LMSBW_$(strip $(1)),kind)' is not 'source' nor 'download')

report:: report.$(strip $(1))
.PHONY:	report.$(strip $(1)) __$(strip $(1)).report.$(call get,LMSBW_$(strip $(1)),kind)

$(call generate_component_report_$(call get,LMSBW_$(strip $(1)),kind),$(1))

report.$(strip $(1)): __$(strip $(1)).report.$(call get,LMSBW_$(strip $(1)),kind)

endef

