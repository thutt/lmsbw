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

# This file contains 'last chance' rules for verb actions on
# components.  If a component does not have a rule generated for the
# verb, then the last chance rule will be used, and a comprehensible
# diagnostic message will be output.

# lmsbw_generate_component_last_chance_rule <verb>, <optional message>
#
#   This function generates a last change rule for each 'verb'
#   (install, report, etc.) that should be executable on a component.
#
#   If LMSBW has not generated rules for such 'verbs', it means one of 
#   three things:
#
#      o There is an unknown internal error in LMSBW
#
#        This is possible, but unlikely.  If you suspect this, contact
#        the author and let him decipher the problem.
#
#      o The component does not exist
#
#        Run the global 'report' target.  If you cannot find the
#        component named in the error, then it's missing.  To resolve
#        the error, you must supply a definition of the component.
#
#      o A new component 'kind' has been created and all the proper
#        rules have not been generated.
#        
#        If you add a new component 'kind' to LMSBW, it's your
#        responsibility to ensure that all existing 'verbs' are
#        handled when generating the rules.
#
#        If you add new verbs, then you must also update the rest of
#        the component 'kind' code to handle those new verbs, and you
#        should also create last chance rules for them here.
#
define lmsbw_generate_component_last_chance_rule
$(1).%:
	$(ATSIGN)$(MESSAGE) "$$(patsubst $(1).%,%,$$@): " \
		"E1005: No verb '$(1)' for component '$$(patsubst $(1).%,%,$$@)'.";
	$(ATSIGN)$(MESSAGE) "$$(patsubst $(1).%,%,$$@): " \
		"E1005: Does this component exist?  Use 'lmsbw report'.";
	$(if $(2),$(ATSIGN)$(MESSAGE) "$$(patsubst $(1).%,%,$$@): " $(2);)
	$(FALSE);
endef


# The following last change rules are likely internal errors.  They
# should only be encountered if LMSBW does not generate the target
# rules for the component.  This is most likely to occur if a new
# component 'kind' is created.
#
$(eval $(call lmsbw_generate_component_last_chance_rule,install))
$(eval $(call lmsbw_generate_component_last_chance_rule,report))
$(eval $(call lmsbw_generate_component_last_chance_rule,clean))
$(eval $(call lmsbw_generate_component_last_chance_rule,log))

