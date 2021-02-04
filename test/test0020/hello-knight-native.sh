#! /bin/sh
## Copyright (C) 2017 Jeremiah Orians
## Copyright (C) 2021 deesix <deesix@tuta.io>
## This file is part of M2-Planet.
##
## M2-Planet is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## M2-Planet is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with M2-Planet.  If not, see <http://www.gnu.org/licenses/>.

set -x

TMPDIR="test/test0020/tmp-knight-native"
mkdir -p ${TMPDIR}

# Build the test
bin/M2-Planet \
	--architecture knight-native \
	-f M2libc/knight/Native/unistd.h \
	-f M2libc/stdlib.c \
	-f M2libc/knight/Native/fcntl.h \
	-f M2libc/stdio.c \
	-f test/test0020/struct.c \
	-o ${TMPDIR}/struct.M1 \
	|| exit 1

# Macro assemble with libc written in M1-Macro
M1 \
	-f M2libc/knight/knight-native_defs.M1 \
	-f M2libc/knight/libc-native-file.M1 \
	-f ${TMPDIR}/struct.M1 \
	--big-endian \
	--architecture knight-native \
	-o ${TMPDIR}/struct.hex2 \
	|| exit 2

# Resolve all linkages
hex2 \
	-f ${TMPDIR}/struct.hex2 \
	--big-endian \
	--architecture knight-native \
	--base-address 0x00 \
	-o test/results/test0020-knight-native-binary \
	|| exit 3

# Ensure binary works if host machine supports test
if [ "$(get_machine ${GET_MACHINE_FLAGS})" = "knight-native" ]
then
	# Verify that the compiled program returns the correct result
	out=$(vm --rom ./test/results/test0020-knight-native-binary --tape_01 /dev/stdin --tape_02 /dev/stdout --memory 2M)
	[ 0 = $? ] || exit 4
	[ "$out" = "35419896642975313541989657891634" ] || exit 5
fi
exit 0
