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

# lmsbw_direct_dependents <component>
#
#   Returns a list of modules which are directly dependent upon the
#   input component.
#
define lmsbw_direct_dependents
$(strip $(foreach c,$(call keys,LMSBW_components),
	$(if $(filter $(strip $(1)),$(call get,LMSBW_$(c),prerequisite)),$(c))))
endef

# lmsbw_api_changed_failure <component>
#
#   This rule is executed when it has been determined that the
#   exported API of a module has chagned.  It prints a message,
#   provides instructions on how to proceed, and then fails the build.
#
define lmsbw_api_changed_failure
	if [ ! -z "$(call lmsbw_direct_dependents,$(1))" ] ; then				\
		$(MESSAGE) "The public API for '$(1)' has changed.  ";				\
		$(MESSAGE) "This can directly affect the build of the following modules: ";	\
		$(MESSAGE) "";									\
		$(foreach d,$(call lmsbw_direct_dependents,$(1)),$(MESSAGE) "  $(d)";)		\
		$(MESSAGE) "";									\
		$(MESSAGE) "A 'clean' build of involved modules must be performed.";		\
		$(MESSAGE) "To clean all dependent modules, execute the following ";		\
		$(MESSAGE) "and then rebuild:";							\
		$(MESSAGE) "";									\
		$(MESSAGE) "  lmsbw api-changed.$(strip $(1))";					\
		$(FALSE);									\
	else											\
		$(RM) "$(call get,LMSBW_$(strip $(1)),api-changed)";				\
		$(TRUE);									\
	fi;
endef