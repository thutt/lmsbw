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

define __expand_md5sum_value
$(strip $(word 1,$(shell $(ECHO) $(1)|$(MD5SUM))))
endef

# _expand_md5sum_text <text>
#
#   This function expands to the md5sum value of the provided '<text>'
#   argument.
#
define _expand_md5sum_text
$(strip $(call memoize,__expand_md5sum_value,$(1)))
endef

