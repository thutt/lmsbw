#!/bin/bash
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

# This test verifies that a non-existent custom toolchain include file
# will fail the build.

function execute_lmsbw ()       # additional arguments
{
    lmsbw                                       \
        ${LMSBW_VERBOSE}                        \
        --build-root "${LMSBW_TEST_BUILD_ROOT}" \
        --configuration "${cfg}" ${@}
}       

if [ ! -z "${LMSBW_TEST_COMMON}" ] ; then
    source "${LMSBW_TEST_COMMON}";
else
    echo "LMSBW_TEST_COMMON is not set; unable to proceed with test";
    exit -1;
fi;

execute_lmsbw >"${LMSBW_TEST_BUILD_ROOT}/lmsbw-build.log";
expect_command_success;

# This sample uses a custom toolchain and always set 'CC' to be
# '/bin/true'.  This can be verified by looking in the log file for
# the lmsbw-test component.
#
if ! execute_lmsbw log.lmsbw-test|grep --quiet "^Makefile Macro 'CC': '/bin/true'" ; then 
    echo "CC was not set properly; should have been set to /bin/true.";
    exit -1
fi;
exit 0;
