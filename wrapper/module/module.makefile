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
include $(LMSBW_DIR)/wrapper/gmsl/gmsl
include $(LMSBW_DIR)/wrapper/lmsbw/lmsbw-system.mk

.PHONY:	install
install:
	$(ATSIGN)$(MESSAGE) "$(LMSBW_COMPONENT)";
	$(ATSIGN)$(MESSAGE) "$(LMSBW_KIND)";
	$(ATSIGN)$(MESSAGE) "$(LMSBW_SOURCE_DIRECTORY)";
	$(ATSIGN)$(MESSAGE) "$(LMSBW_BUILD_DIRECTORY)";
	$(ATSIGN)$(MESSAGE) "$(LMSBW_DESDIR_DIRECTORY)";
	$(ATSIGN)$(MESSAGE) "$(LMSBW_CONFIGURATION_FILE)";
	$(ATSIGN)$(TRUE);


