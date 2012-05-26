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
define lmsbw_component_mtree_command_guard
$(ATSIGN)$(call lmsbw_expand_mtree_command_guard,		\
	$(1),							\
	$(call get,LMSBW_$(strip $(1)),mtree-manifest),		\
	$(call get,LMSBW_$(strip $(1)),source-directory),	\
	$(2),							\
	$(call get,LMSBW_$(strip $(1)),configuration-file))
endef

