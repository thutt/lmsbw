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

# This file declares the 'lite' component.  It is the only component
# produced and delivered for the 'lite' product configuration.
#
# This file is included by the 'load-configuration' function, and as
# such '$(1)', as defined by LMSBW, is the name of the master
# configuration file.
#
# However, the fourth parameter of 'declare_source_component' needs to
# be the name of the actual file which declares the component.  This
# is because this file can contain rules which will be used by
# 'component.makefile' when actually building the compoment.
#
# This sample's 'load-configuration' function uses the convention that
# the loaded file pathname is present in the Makefile variable
# 'CURRENT_CONFIGURATION_FILE'.
#
#

$(call assert,$(CURRENT_CONFIGURATION_FILE),CURRENT_CONFIGURATION_FILE is not set)

$(call declare_source_component,		\
	consumer,				\
	Consumer Program,			\
	image,					\
	$(CURRENT_CONFIGURATION_FILE),		\
	$(subst product.cfg,src/consumer,$(1)))
