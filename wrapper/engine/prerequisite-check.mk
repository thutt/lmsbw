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
#   perform a build of only the component named with
#   '--prerequisite-check'.  It does this by setting
#   'LMSBW_components' to just the named component and all of it
#   prerequistes (direct, and indirect).
#
#   To ensure that the build system will not use the same build output
#   directory, the 'CFLAGS' for each component are altered with a
#   LMSBW-specific preprocessor define; this changes the hash of the
#   build output directory and ensures that all the components will be
#   built.
#
#   Also, because the list of is going to be different, the install
#   directory will be hashed differently, too.  This ensures that any
#   missing prerequisites will be found because their 'install' will
#   not be present in the install directory.
#
define perform_prerequisite_check
$(eval LMSBW_components:=$(sort $(call expand_all_prerequisites,$(LMSBW_PREREQUISITE_CHECK_COMPONENT))))
$(foreach c,$(LMSBW_components),$(call lmsbw_scf,$(c),cflags,$(call lmsbw_gcf,$(c),cflags) -DLMSBW_PREREQUISITE_CHECK))
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
