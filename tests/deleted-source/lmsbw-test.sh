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

function create_sources ()
{
    # The source files are created on-the-fly in a directory that is
    # removed at the end of the test.
    #
    # Create all the source files that will be compiled.
    #
    for f in ${FILES} ; do
        cat >"${SOURCES}/${f}.c" <<EOF
#include <stdio.h>

void ${f}(void)
{
    printf("function: %s\n", __FUNCTION__);
}

EOF
    done;
}

function create_makefile ()
{

    # Create the Makefile for the component
    cat >${SOURCES}/Makefile <<EOF
SRC	:= \$(wildcard *.c)
OBJ	:= \$(SRC:.c=.o)

install:	\$(OBJ) | /opt/object-files
	cp \$(OBJ) \$(DESTDIR)/opt/object-files

/opt/object-files:
	mkdir --parents \$(DESTDIR)/\$@

EOF
}

function create_configuration ()
{
    cat >${CFG} <<EOF
define load_configuration
\$(call declare_source_component,		\\
       deleted-source,				\\
       Test of Deleted Source Files,		\\
       image,					\\
       \$(1),					\\
       \$(subst lmsbw-test.cfg,src,\$(1)))

\$(call component_attribute_api,deleted-source,/opt/object-files)
endef

vv:=\$(call set,LMSBW_configuration,load-configuration-function,load_configuration)
vv:=\$(call set,LMSBW_configuration,component-build-support,source)
EOF
}

function must_exist ()
{
    local path=${1};
    if [ ! -e "${path}" ] ; then
        echo "'${path} does not exist, but must";
        exit 1;
    fi;

}
function must_not_exist ()
{
    local path=${1};

    if [ -e "${path}" ] ; then
        echo "'${path}' exists, but must not";
        exit 1;
    fi;

}


#
# This test exercises a corner case of the syncing of source
# directories into build directories.  Consider:
#
#  o Component has several source files.
#  o Component Makefile uses 'SOURCES := $(wildcard *.c)'
#  o Component has been built
#  o Source file is deleted from component source directory
#  o Component is rebuilt.
#
# Without special handling, the build directory will still contain a
# copy of the deleted source file, and it will still be picked up by
# the component's Makefile, resulting in a bad build.
#
# This test validates that LMSBW properly deletes & recreates the
# build directory before syncing the source files to the build
# directory.
#
if [ ! -z "${LMSBW_TEST_COMMON}" ] ; then
    source "${LMSBW_TEST_COMMON}";
else
    echo "LMSBW_TEST_COMMON is not set; unable to proceed with test";
    exit -1;
fi;

TEST_DIR="/tmp/lmsbw-test-deleted-source.${BASHPID}"
SOURCES="${TEST_DIR}/src";
FILES="a b c d";
CFG="${TEST_DIR}/lmsbw-test.cfg"

if [ ! -d "${SOURCES}" ] ; then
    mkdir --parents "${SOURCES}";

    #trap "rm -rf ${TEST_DIR}" EXIT  # Remove source directory on exit.
else
    echo "Directory '${SOURCES}' exists, cannot proceed";
    exit 1;
fi;

create_sources;
create_makefile;
create_configuration;

# The 'builddir' of the component is where the object files are
# stored; query LMSBW for the location.
#
builddir=$(unset LMSBW_VERBOSE; lmsbw ${LMSBW_VERBOSE}  \
    --build-root "${LMSBW_TEST_BUILD_ROOT}"             \
    --configuration "${CFG}" builddir|cut -d ':' -f 2)
installdir=$(unset LMSBW_VERBOSE; lmsbw ${LMSBW_VERBOSE}        \
    --build-root "${LMSBW_TEST_BUILD_ROOT}"                     \
    --configuration "${CFG}" installdir|cut -d ':' -f 2)

lmsbw                                                                           \
    ${LMSBW_VERBOSE}                                                            \
    --build-root "${LMSBW_TEST_BUILD_ROOT}"                                     \
    --configuration "${CFG}" >"${LMSBW_TEST_BUILD_ROOT}/lmsbw-build-1.log";

# All the source's object files must exist after the first run.
#
for f in ${FILES}; do
    must_exist "${builddir}/src/${f}.o";
    must_exist "${installdir}/opt/object-files/${f}.o";
done;

# Delete two source files.
#
# This is the most important part of this test.
#
rm ${SOURCES}/{b,d}.c;

# Execute again & test that some object files do not exist.
#
lmsbw                                                                           \
    ${LMSBW_VERBOSE}                                                            \
    --build-root "${LMSBW_TEST_BUILD_ROOT}"                                     \
    --configuration "${CFG}" >"${LMSBW_TEST_BUILD_ROOT}/lmsbw-build-2.log";

must_exist     "${builddir}/src/a.o"
must_not_exist "${builddir}/src/b.o"
must_exist     "${builddir}/src/c.o"
must_not_exist "${builddir}/src/d.o"

must_exist     "${installdir}/opt/object-files/a.o"
must_not_exist "${installdir}/opt/object-files/b.o"
must_exist     "${installdir}/opt/object-files/c.o"
must_not_exist "${installdir}/opt/object-files/d.o"

exit 0;

