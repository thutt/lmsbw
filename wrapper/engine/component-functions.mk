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

# This file contains functions which operate upon components.


# lmsbw_component_mtree_command_guard <component>,
#                                     <commands-to-execute>
#
#   This expands to '<commands-to-execute>' guarded by a use of the
#   'mtree' utility to check if the source tree has changed.
#
#   If any file in the 'source-directory' has changed, or if the
#   component configuration file has changed, '<commands-to-execute>'
#   will be executed.
#
#   If no files in the 'source-directory' hav changed,
#   '<commands-to-execute>' will not be executed.
#
define lmsbw_component_mtree_command_guard
$(ATSIGN)$(call lmsbw_expand_mtree_command_guard,	\
	$(1),						\
	$(call lmsbw_gcf,$(1),source-mtree-manifest),	\
	$(call lmsbw_gcf,$(1),source-directory),	\
	$(2),						\
	$(call lmsbw_gcf,$(1),configuration-file))
endef

# lmsbw_direct_dependents <component>
#
#   Expands to a list of modules which are directly dependent upon the
#   input component.
#
define lmsbw_direct_dependents
$(strip $(foreach c,$(LMSBW_components),
	$(if $(filter $(strip $(1)),$(call lmsbw_gcf,$(c),prerequisite)),$(c))))
endef

# lmsbw_source_api_changed_failure <component>
#
#   This code is executed when it has been determined that the
#   exported API of a component has changed.  It prints a message,
#   provides instructions on how to proceed, and then causes the build
#   to fail.
#
#   The reasons to fail the build instead of attempting to cope & move
#   foward are:
#
#     o An API change has downstream ramifications beyond just
#       changing the API.  Any dependent component must be recompiled,
#       and perhaps further changed.  This has a cost in at least
#       development, and further testing.
#
#       This failure is intended to make people think about API
#       changes more carefully, and to force them to see the impact of
#       their actions before attempting to build them.
#
#     o Once Make is running with the entire product configuration,
#       it's difficult, if not impossible, to change the set of
#       targets to rebuild.  An API change is only detected during the
#       build phase, and automatically cleaning dependent components,
#       and then scheduling them to be rebuilt is not something that
#       Make does well.
#
#   So, the reason for failure is partially because it's hard to do it
#   with Make, but the more important reason is to force the developer
#   to know that their change has further ramifications.
#
define lmsbw_source_api_changed_failure
	if [ ! -z "$(call lmsbw_gcf,$(1),direct-dependents)" ] ; then				\
		$(MESSAGE) "The source API for '$(1)' has changed.  ";				\
		$(MESSAGE) "This can directly affect the build of the following modules: ";	\
		$(MESSAGE) "";									\
		$(foreach d,$(call lmsbw_gcf,$(1),direct-dependents),				\
			$(MESSAGE) "  $(d)";)							\
		$(MESSAGE) "";									\
		$(MESSAGE) "A 'clean' build of involved modules must be performed.";		\
		$(MESSAGE) "To clean all dependent modules, execute the following ";		\
		$(MESSAGE) "and then rebuild as you normally do:";				\
		$(MESSAGE) "";									\
		$(MESSAGE) "  lmsbw source-api-changed.$(strip $(1))";				\
		$(FALSE);									\
	else											\
		$(RM) "$(call lmsbw_gcf,$(1),source-api-changed)";				\
		$(TRUE);									\
	fi;
endef
