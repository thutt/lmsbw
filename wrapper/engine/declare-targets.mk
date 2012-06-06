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

.PHONY:		targets

# declare_target <target-name>, <[.<component> text>, <target-description>
#
#   This is a convenient way to include top-level targets in the
#   output of the top-level target called 'targets'.
#
#
#   The 'targets' target will show all top-level targets with a brief
#   description of its purpose.
#
define declare_target
targets::	lmbw_target_description_$(strip $(1))

.PHONY:		target_description_$(strip $(1))
lmbw_target_description_$(strip $(1)):
	@$(PRINTF) "%25s : %s\n" "$(1)$(2)" "$(3)";

endef
