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


# This file contains rules that must appear after all components have
# been loaded and configured.
#
# In particular the rule to make the 'install' directory because the
# full pathname is based on the set of components that are loaded.  If
# this rule is executed before all components have been loaded, the hash
# in the pathname used in this rule will not match the hash used when
# all components are loaded.
#
$(LMSBW_TARBALL_REPOSITORY)			\
$(call lmsbw_expand_install_directory,build)	\
$(LMSBW_DIRECTORIES):
	$(ATSIGN)$(MESSAGE) "Creating directory: '$@'";
	$(ATSIGN)$(MKDIR) --parents $@


