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

$(if $(filter $(BALL_CLASSIFICATION),small hard round),			\
$(call declare_source_component,					\
       baseball,							\
       $(BALL_CLASSIFICATION) baseball example,				\
       image,								\
       $(lastword $(MAKEFILE_LIST)),					\
       $(dir $(lastword $(MAKEFILE_LIST)))../src))

component.install.baseball:
	$(MKDIR) --parents $(LMSBW_C_DESTDIR_DIRECTORY)/$(BALL_CLASSIFICATION);
	$(ECHO) baseball >$(LMSBW_C_DESTDIR_DIRECTORY)/$(BALL_CLASSIFICATION)/baseball;
