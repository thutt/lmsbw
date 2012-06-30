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
#   Expands to a list of components which are directly dependent upon the
#   input component.
#
define lmsbw_direct_dependents
$(strip $(foreach c,$(LMSBW_components),
	$(if $(filter $(strip $(1)),$(call lmsbw_gcf,$(c),prerequisite)),$(c))))
endef
