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
.DEFAULT_GOAL := all
.SUFFIXES:

export LMSBW_DIR := $(realpath $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))/..)

include $(LMSBW_DIR)/wrapper/lmsbw/lmsbw-system.mk
include $(LMSBW_DIR)/wrapper/engine/generate-rules.mk

all:	install

mtree:	$(MTREE)
	$(ATSIGN)$(MESSAGE) "mtree is installed at '$(MTREE)'";

install::

clean::
	$(ATSIGN)$(MESSAGE) "Cleaning 'for build' install directory";
	$(ATSIGN)$(RM) -rf $(call lmsbw_expand_install_directory,build);
	$(ATSIGN)$(MESSAGE) "Cleaning 'for image' install directory";
	$(ATSIGN)$(RM) -rf $(call lmsbw_expand_install_directory,image);

log::

report::

components::

destdir::
installdir::
builddir::

prerequisite-report::

dependent-report::

measure-startup-time:
	$(ATSIGN) $(MESSAGE) "Loaded $(words $(LMSBW_components)) configuration files"


measure-memory-footprint:
	$(ATSIGN) $(MESSAGE) "Measure memory footprint.  Press Ctrl-C to quit."
	@while true ; do true; done;

.PHONY:		all install clean report prerequisite-report dependent-report

$(eval $(call declare_target,all,,Perform a full build))
$(eval $(call declare_target,targets,,Produce this report))
$(eval $(call declare_target,report,[.<component>],Generate component reports))
$(eval $(call declare_target,install,[.<component>],Build & install components))
$(eval $(call declare_target,clean,[.<component>],Clean build output for components))
$(eval $(call declare_target,log,[.<component>],Display component build logs))
$(eval $(call declare_target,destdir,[.<component>],Shows the intermediate install directory))
$(eval $(call declare_target,builddir,[.<component>],Shows the build directory))
$(eval $(call declare_target,installdir,[.<component>],Shows the install directory))
$(eval $(call declare_target,prerequisite-report,,Show declared component prerequisites))
$(eval $(call declare_target,dependent-report,,Show computed component dependencies))
$(eval $(call declare_target,measure-startup-time,,Measure time to load configruation files))
$(eval $(call declare_target,measure-memory-footprint,,Measure amount of memory needed))

include $(LMSBW_DIR)/wrapper/engine/component-last-chance-rules.mk

