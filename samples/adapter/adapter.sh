#!/bin/bash
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

#
# This script is intended to be an example of how an existing build
# system can be augmented or incrementally replaced with an
# LMSBW-based build.
#
# The adpater script allows the build output from LMSBW to be copied
# into the build tree of another build system.
#
# When adapting a build, the developers need to know the location of
# the build output from LMSBW (which is provided to this script) as
# well as the location the build output belongs in the old build
# process.
#
# The sole purpose of this script is to copy the build output for each
# component that has been converted to LMSBW into the old build
# system's build directory.
#
set -e;

declare -A adapters;
adapters=(                                      \
    [hello-world]="adapt_hello_world"           \
    [goodbye-world]="adapt_goodbye_world"       \
);

function adapt_hello_world ()
{
    local component=${1};
    local build_root=${2};
    local exe="${build_root}/destdir/usr/bin/executable";
    local sentinel="${build_root}/adapted";

    if [ "${exe}" -nt "${sentinel}" ] ; then
        echo "Copy '${exe}' to legacy build directory";
        touch ${sentinel};
    fi;        
}

function adapt_goodbye_world ()
{
    local component=${1};
    local build_root=${2};
    local exe="${build_root}/destdir/usr/bin/executable";
    local sentinel="${build_root}/adapted";

    if [ "${exe}" -nt "${sentinel}" ] ; then
        echo "Copy '${exe}' to legacy build directory";
        touch ${sentinel};
    fi;        
}

function adapt_components ()
{
    local file="${1}";

    while read line ; do
        local component=$(echo ${line}|cut -f 1 -d ':');
        local directory=$(echo ${line}|cut -f 2 -d ':');
        local function=${adapters[${component}]};

        if [ ! -z "${function}" ] ; then
            if declare -f ${function} >/dev/null ; then
                ${function} ${component} ${directory};
            else
                echo "Adapter '${function}' for '${component}' is not declared.";
                exit 1;
            fi;
        else
            echo "Component '${component}' has no adapter entry";
            exit 1;
        fi;
    done <${file};
}

function invoke_adapted_build_process ()
{
    # Invoke a legacy build process.
    return 0;
}

function main ()
{
    local file=${1};
    adapt_components ${file};
    invoke_adapted_build_process;
}

main $*;
