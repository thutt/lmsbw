#!/bin/bash
directory=$(dirname "${0}");
cfg="${directory}/lmsbw-test.cfg";

if [ -z "${LMSBW_TEST_BUILD_ROOT}" ] ; then
    echo "'LMSBW_TEST_BUILD_ROOT' is not set";
    exit -1;
fi;

lmsbw                                                           \
    ${LMSBW_VERBOSE}                                            \
    --build-root "${LMSBW_TEST_BUILD_ROOT}"                     \
    --tarball-repository "${LMSBW_TEST_BUILD_ROOT}/tarballs"    \
    --configuration "${cfg}";
