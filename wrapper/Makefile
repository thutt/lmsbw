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

export LMSBW_DIR := $(realpath $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))/..)

include $(LMSBW_DIR)/wrapper/gmsl/gmsl
include $(LMSBW_DIR)/wrapper/engine/md5sum.mk
include $(LMSBW_DIR)/wrapper/engine/lmsbw-system.mk
include $(LMSBW_DIR)/wrapper/engine/declare-source-module-functions.mk
include $(LMSBW_DIR)/wrapper/engine/declare-targets.mk
include $(LMSBW_DIR)/wrapper/engine/load-configuration.mk
include $(LMSBW_DIR)/wrapper/engine/generate-report.mk
include $(LMSBW_DIR)/wrapper/engine/generate-rules.mk
include $(LMSBW_DIR)/wrapper/engine/mtree.mk
include $(LMSBW_DIR)/wrapper/engine/misc-rules.mk

all:	install

install::

clean::

log::

report::

prerequisite-report::

dependent-report::

.PHONY:		all install clean report prerequisite-report dependent-report

$(eval $(call declare_target,all,,Perform a full build))
$(eval $(call declare_target,targets,,Produce this report))
$(eval $(call declare_target,report,[.<component>],Generate component reports))
$(eval $(call declare_target,install,[.<component>],Build & install components))
$(eval $(call declare_target,clean,[.<component>],Clean build output for components))
$(eval $(call declare_target,log,[.<component>],Display component build logs))
$(eval $(call declare_target,prerequisite-report,,Show declared component prerequisites))
$(eval $(call declare_target,dependent-report,,Show computed component dependencies))

include $(LMSBW_DIR)/wrapper/engine/component-last-chance-rules.mk

