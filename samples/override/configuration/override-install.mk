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

# This configuration file creates a component called
# 'override-install'.
#
# It overrides the default 'install' target with one dependent upon
# the default 'build' target.  This causes the normal build to be
# invoked, and this build will create a C-based executable program.
# However, since the install target has been overridden, and it
# specifically does not install the executable.
#
# You can see that this overridden rule is executed by executing the
# verb 'log.override-install'.
#

$(call declare_source_component,					\
       override-install,						\
       override install example,					\
       image,								\
       $(CURRENT_CONFIGURATION_FILE),					\
       $(realpath $(dir $(CURRENT_CONFIGURATION_FILE))..)/src/override-install))


component.install.override-install:	build.override-install
	$(ECHO) "Nothing was installed; it was overridden."
