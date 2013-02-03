# Copyright (c) 2013 Taylor Hutt, Logic Magicians Software
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

# This file is the only public interface for adapting the output of an
# LMSBW-based build to an exsiting build process.
#
# An adapter would minimally copy the DESTDIR of components into the
# desired locations of the other build process.
#

# declare_adapter_script <pathname-to-adapter-script>
#
#
#
define declare_adapter_script
$(if $(call not,$(LMSBW_ADAPTER_SCRIPT)),					\
	$(eval LMSBW_ADAPTER_SCRIPT:=$(1)),					\
	$(call lmsbw_error,E1023,LMSBW_ADAPTER_SCRIPT already declared))
endef

# generate_adapter_rules_work
#
#   Generates the Make rules to invoke an adapter script.  The adapter
#   is invoked unconditionally for each build.
#
#   The script is passed a single argument: a filename containing
#   information about each component that has been built by LMSBW.
#   The lines in the file are of the form:
#
#       <component-name> ':' <component-build-root-directory>
#
# The component's build-root-directory will contain a directory named
# 'destdir', and that directory will contain the exported output of
# the build.
#
# The adapter script is free to write sentinel files into the
# build-root-directory.  Since the script is unconditionally executed,
# sentinel files can be used to determine if the exported build output
# is newer than the most recently adapted version.
#
define generate_adapter_rules_work
.PHONY:		lmsbw_adapter
install::	lmsbw_adapter
lmsbw_adapter:	$(foreach c,$(LMSBW_components),install.$(c))
	$(ATSIGN)$(PROGRESS) "Invoking adapter: $(LMSBW_ADAPTER_SCRIPT)";
	$(ATSIGN)component_file=$$$$(tempfile);								\
		$(foreach c,$(LMSBW_components),							\
		$(ECHO) "$(c):$(call lmsbw_gcf,$(c),build-root-directory)" >>$$$${component_file};)	\
		$(LMSBW_ADAPTER_SCRIPT) $$$${component_file};

endef

define generate_adapter_rules
$(if $(LMSBW_ADAPTER_SCRIPT),$(call generate_adapter_rules_work))
endef
