# Copyright (c) 2012, 2013 Taylor Hutt, Logic Magicians Software
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

LMSBW_CTNG_TOOLCHAIN	:= $(LMSBW_DIR)/wrapper/component/ctng-toolchain.mk
LMSBW_CUSTOM_TOOLCHAIN	:= $(LMSBW_C_CUSTOM_TOOLCHAIN)

# __lmsbw_expand_ctng_exists
#
#   Produces a non-empty string if the toolchain exists.
#   Produces an empty string if the toolchain does not exist.
#
define __lmsbw_expand_ctng_exists
$(wildcard $(LMSBW_TOOLCHAINS_ROOT)/$(LMSBW_C_TOOLCHAIN))
endef

# __lmsbw_ctng_valid
#
#   Produces $(true) if toolchain root is set and <toolchain-name>
#   is present in the toolchain root.
#
#   Produces $(false) otherwise.
#
define __lmsbw_ctng_valid
$(if $(LMSBW_TOOLCHAINS_ROOT),$(call __lmsbw_expand_ctng_exists),$(false))
endef

# __lmsbw_custom_toolchain_valid
#
#   Produces $(true) if custom toolchain has been declared.
#
#   Produces $(false) otherwise.
#
#   The file for implementing custom toolchains has been guaranteed to
#   exist.
#
#   If will not be known until the custom toolchain file is loaded if
#   'LMSBW_C_TOOLCHAIN' is a valid custom toolchain.  If it is not a
#   valid toolchain, none of the standard macros will be set, and the
#   build process will deliberately fail.
#
define __lmsbw_custom_toolchain_valid
$(LMSBW_C_CUSTOM_TOOLCHAIN)
endef

# __lmsbw_use_ctng
#
#  Produces $(true) is a ctng toolchain file should be included.
#  Produces $(false) otherwise.
#
#  This does not check if LMSBW_C_TOOLCHAIN is valid.
#
define __lmsbw_use_ctng
$(if $(LMSBW_TOOLCHAINS_ROOT)$(LMSBW_C_TOOLCHAIN),$(true),$(false))
endef

# __lmsbw_use_custom
#
#  Produces $(true) is the custom toolchain file should be included.
#  Produces $(false) otherwise.
#
#  A custom toolchain will be used for each component when a ctng
#  toolchain has not been used.  This allows a custom toolchain to
#  override the host toolchain.
#
#  A custom toolchain will be used when a ctng toolchain is used, but
#  the named toolchain is not present in the ctng toolchains.  This
#  allows both ctng and custom toolchains to be used together (albiet
#  without common names).
#
define __lmsbw_use_custom
$(call and,$(call not,$(call __lmsbw_ctng_valid),$(LMSBW_C_CUSTOM_TOOLCHAIN)))
endef

# __lmsbw_using_toolchain
#
#  Produces $(true) if either ctng or custom toolchain used.
#  Produces $(false) otherwise.
#
define __lmsbw_using_toolchain
$(call or,$(call __lmsbw_use_ctng),$(call __lmsbw_use_custom))
endef

# __lmsbw_include_toolchain <pathname>
#
#  Include a file which sets up a toolchain.
#
define __lmsbw_include_toolchain
$(info LMSBW_C_TOOLCHAIN: '$(LMSBW_C_TOOLCHAIN)')	\
$(info Include toolchain: '$(1)')			\
$(eval include $(1))
endef

# __lmsbw_check_e1021
#
#  Produce E1021 if needed.
#  This error is produced when:
#
#    o a custom toolchain is not being used
#    o a toolchain name has been specified on the command line
#    o the specified toolchain cannot be found in the ctng toolchains
#
#  If custom toolchains are being used, the custom toolchain include
#  file must produce an error when an unknown toolchain is used.
#
define __lmsbw_check_e1021
$(if $(call and,$(LMSBW_C_TOOLCHAIN),						\
		$(call not,$(call __lmsbw_custom_toolchain_valid))),		\
	$(call lmsbw_error,E1021,'$(LMSBW_C_TOOLCHAIN)' not found))
endef


# When including toolchain configurations, the ctng configuration is
# always checked first.  If the ctng configuration is not found, and a
# custom configuration has been declared, the the custom configuration
# is included.
#
# If a custom toolchain is being used:
#
#    If 'LMSBW_C_TOOLCHAIN' is not recognized by the included custom
#    toolchain file, it should use $(error) to signal an appropriate
#    error.
#
# If custom toolchain has is not being used:
#
#    If LMSBW_C_TOOLCHAIN can not be found in the toolchains
#    directory, then E1021 is produced.
#
$(if $(call __lmsbw_ctng_valid),					\
	$(call __lmsbw_include_toolchain,$(LMSBW_CTNG_TOOLCHAIN)),	\
	$(call __lmsbw_check_e1021))

# The custom toolchain handler will only be invoked if a ctng
# toolchain cannot be found.

$(if $(call __lmsbw_use_custom),					\
	$(call __lmsbw_include_toolchain,$(LMSBW_CUSTOM_TOOLCHAIN)))


# __lmsbw_validate_toolchain_variable <Make standard variable name>
#
#  If any type of toolchain used and macro is not defined, issue
#  warning and set to /bin/false.
#
#  Always print value of macro
#
define __lmsbw_validate_toolchain_variable
$(if $(call and,$(call __lmsbw_using_toolchain),$(call not,$($(1)))),	\
	$(warning '$(1)' unassigned; set to /bin/false)			\
	$(eval $(1):=/bin/false)					\
)									\
$(info  Makefile Macro '$(1)': '$($(1))')
endef

$(call __lmsbw_validate_toolchain_variable,ADDR2LINE)
$(call __lmsbw_validate_toolchain_variable,AR)
$(call __lmsbw_validate_toolchain_variable,AS)
$(call __lmsbw_validate_toolchain_variable,CC)
$(call __lmsbw_validate_toolchain_variable,CO)
$(call __lmsbw_validate_toolchain_variable,CO)
$(call __lmsbw_validate_toolchain_variable,CPP)
$(call __lmsbw_validate_toolchain_variable,CTANGLE)
$(call __lmsbw_validate_toolchain_variable,CWEAVE)
$(call __lmsbw_validate_toolchain_variable,CXX)
$(call __lmsbw_validate_toolchain_variable,FC)
$(call __lmsbw_validate_toolchain_variable,GCOV)
$(call __lmsbw_validate_toolchain_variable,GET)
$(call __lmsbw_validate_toolchain_variable,GXX)
$(call __lmsbw_validate_toolchain_variable,INSTALL)
$(call __lmsbw_validate_toolchain_variable,LD)
$(call __lmsbw_validate_toolchain_variable,LEX)
$(call __lmsbw_validate_toolchain_variable,LINT)
$(call __lmsbw_validate_toolchain_variable,M2C)
$(call __lmsbw_validate_toolchain_variable,MAKEINFO)
$(call __lmsbw_validate_toolchain_variable,NM)
$(call __lmsbw_validate_toolchain_variable,OBJCOPY)
$(call __lmsbw_validate_toolchain_variable,OBJDUMP)
$(call __lmsbw_validate_toolchain_variable,PC)
$(call __lmsbw_validate_toolchain_variable,POPULATE)
$(call __lmsbw_validate_toolchain_variable,RANLIB)
$(call __lmsbw_validate_toolchain_variable,READELF)
$(call __lmsbw_validate_toolchain_variable,RM)
$(call __lmsbw_validate_toolchain_variable,SIZE)
$(call __lmsbw_validate_toolchain_variable,STRINGS)
$(call __lmsbw_validate_toolchain_variable,STRIP)
$(call __lmsbw_validate_toolchain_variable,TANGLE)
$(call __lmsbw_validate_toolchain_variable,TEX)
$(call __lmsbw_validate_toolchain_variable,TEXI2DVI)
$(call __lmsbw_validate_toolchain_variable,WEAVE)
$(call __lmsbw_validate_toolchain_variable,YACC)

