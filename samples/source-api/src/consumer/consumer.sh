#!/bin/bash
#
# This program is installed in a $(sysroot)/usr/bin, and the
# associated dynamic library is in the sysroot '/usr/lib/producer'.
#
set -e;
export LD_LIBRARY_PATH=$(readlink -f $(dirname ${0})/../lib/producer);
$(dirname ${0})/consumer.elf
