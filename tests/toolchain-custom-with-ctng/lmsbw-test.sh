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

# This test verifies that the custom toolchain system is invoked when
# a ctng toolchain is used and a non-existent ctng toolchain is named.
#
# It is the responsibility of the custom toolchain system to signal an
# error if the toolchain is not recognized.


if [ ! -z "${LMSBW_TEST_COMMON}" ] ; then
    source "${LMSBW_TEST_COMMON}";
else
    echo "LMSBW_TEST_COMMON is not set; unable to proceed with test";
    exit -1;
fi;

TOOLCHAINS_ROOT="/tmp/toolchains.${BASHPID}";
mkdir --parents ${TOOLCHAINS_ROOT};
trap "rm -rf ${TOOLCHAINS_ROOT}" EXIT # Remove toolchains root on exit.

echo lmsbw                                                                           \
    ${LMSBW_VERBOSE}                                                            \
    --build-root "${LMSBW_TEST_BUILD_ROOT}"                                     \
    --toolchains-root "${TOOLCHAINS_ROOT}"                                      \
    --toolchain       this-does-not-exist                                       \
    --configuration "${cfg}" >"${LMSBW_TEST_BUILD_ROOT}/lmsbw-build.log";
expect_command_success;


