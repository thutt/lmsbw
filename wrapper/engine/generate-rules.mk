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

# expand_prerequisites <component>
#
#  Expands to a list of prerequisites which can be used in a build
#  target.
#
define expand_prerequisites
$(BW_TARBALL_REPOSITORY)				\
$(LMSBW_DIRECTORIES)					\
$(call get,LMSBW_$(strip $(1)),build-directory)		\
$(call get,LMSBW_$(strip $(1)),destdir-directory)	\
$(call get,LMSBW_$(strip $(1)),prerequisite)
endef

# generate_component_directory_rules <component>
#
define generate_component_directory_rules
$(call get,LMSBW_$(strip $(1)),build-directory) \
	$(call get,LMSBW_$(strip $(1)),destdir-directory):
	$(ATSIGN)$(PROGRESS) "Creating directory: '$$@'";
	$(ATSIGN)$(MKDIR) --parents $$@;

endef

# generate_component_build <component>
#
define generate_component_build
.PHONY:	$(strip $(1)).build

$(strip $(1)).build:	$(call expand_prerequisites,$(1))
	$(ATSIGN)$(MESSAGE) "building $$@";

endef

# generate_component_install <component>
#
define generate_component_install
.PHONY:	$(strip $(1)).install

install-all-components:: $(strip $(1)).install

$(strip $(1)).install:	$(strip $(1)).build		\
	$(call expand_prerequisites,$(1))
	$(ATSIGN)$(MESSAGE) "installing $$@";

endef


define generate_component_rules
$(call generate_component_directory_rules,$(1))
$(call generate_component_build,$(1))
$(call generate_component_install,$(1))
$(call generate_component_report,$(1))
endef

$(foreach c,$(call keys,LMSBW_components),	\
	$(eval $(call generate_component_rules,$(c)))	\
)
