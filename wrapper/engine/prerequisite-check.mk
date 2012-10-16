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

# expand_all_prerequisites <component>
#
#  This function expands to all direct and indirect prerequisites of
#  the component provided as the argument.
#
define expand_all_prerequisites
$(1) $(foreach p,$(call lmsbw_gcf,$(1),prerequisite), \
	$(call expand_all_prerequisites,$(p)))
endef

# perform_prerequisite_check
#
#   This function alters the internal structure of the build to
#   perform a build of just the component named by the
#   '--prerequisite-check' command line option.  It does this by
#   setting 'LMSBW_components' to just the named component and all of
#   it prerequistes (direct, and indirect).
#
#   To ensure that the build system will not use the same build output
#   directory, each of the components will have a LMSBW-specific
#   setting declared into their 'local-settings' associative array.
#   (This forces a different directory because each of the
#   'local-settings' members is included in the component hash.)
#
#   Also, because the list of components is going to be different, the
#   install directory will be hashed differently, too.  This ensures
#   that any missing prerequisites will be found because their
#   'install' will not be present in the install directory.
#
#   It is entirely possible that the copmonents do not have an
#   'local-settings' array declared; if that is the case, then an
#   array must be created.
#
#   A LMSBW-specific element is added to the 'local-settings' array.
#
define perform_prerequisite_check
$(eval LMSBW_components:=$(sort $(call expand_all_prerequisites,$(LMSBW_PREREQUISITE_CHECK_COMPONENT))))
$(foreach c,$(LMSBW_components),								\
	$(if $(call not,$(call lmsbw_gcf,$(c),local-settings)),					\
		$(call lmsbw_scf,$(c),local-settings,__lmsbw_settings))				\
	$(call set,$(call lmsbw_gcf,$(c),local-settings),LMSBW_PREREQUISITE_CHECK,$(true)))
endef

# perform_prerequisite_check_guard
#
#  If the component named with '--prerequisite-check' does not exist,
#  produce an error and exit.
#
#  Otherwise, perform the prerequisite check.
#
define perform_prerequisite_check_guard
$(if $(call not,$(filter $(LMSBW_PREREQUISITE_CHECK_COMPONENT),$(LMSBW_components))),
	$(call lmsbw_prerequisite_check_no_component,$(LMSBW_PREREQUISITE_CHECK_COMPONENT)))
$(call perform_prerequisite_check_check)
endef

#  preqrequisite_test:
#
#    Test that a single component's prerequisites are correct.  If
#    'LMSBW_PREREQUISITE_CHECK_COMPONENT' is set, then the value of
#    LMSBW_components is set to the named component, and all of its
#    direct and indirect prerequisites.
#
#    This will detect missing prerequisites (through build failure),
#    but it cannot detect unnecessary prerequisites.
#
#    This mode is invoked by using the '--prerequisite-test' parameter
#    on the lmsbw command line.
#
define preqrequisite_test
$(if $(LMSBW_PREREQUISITE_CHECK_COMPONENT),			\
	$(eval $(call perform_prerequisite_check_guard)))
endef
