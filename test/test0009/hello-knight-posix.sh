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

TMPDIR="test/test0009/tmp-knight-posix"
mkdir -p ${TMPDIR}

# Build the test
bin/M2-Planet \
	--architecture knight-posix \
	-f M2libc/knight/Linux/unistd.h \
	-f M2libc/stdlib.c \
	-f M2libc/knight/Linux/fcntl.h \
	-f M2libc/stdio.c \
	-f test/test0009/goto.c \
	-o ${TMPDIR}/goto.M1 \
	|| exit 1

# Macro assemble with libc written in M1-Macro
M1 \
	-f M2libc/knight/knight_defs.M1 \
	-f M2libc/knight/libc-full.M1 \
	-f ${TMPDIR}/goto.M1 \
	--big-endian \
	--architecture knight-posix \
	-o ${TMPDIR}/goto.hex2 \
	|| exit 2

# Resolve all linkages
hex2 \
	-f M2libc/knight/ELF-knight.hex2 \
	-f ${TMPDIR}/goto.hex2 \
	--big-endian \
	--architecture knight-posix \
	--base-address 0x00 \
	-o test/results/test0009-knight-posix-binary \
	|| exit 3

# Ensure binary works if host machine supports test
if [ "$(get_machine ${GET_MACHINE_FLAGS})" = "knight" ] && [ ! -z "${KNIGHT_EMULATION}" ]
then
	out=$(vm --POSIX-MODE --rom test/results/test0009-knight-posix-binary --memory 2M)
	[ 42 = $? ] || exit 4
	[ "$out" = "Hello mes" ] || exit 5

elif [ "$(get_machine ${GET_MACHINE_FLAGS})" = "knight" ]
then
	# Verify that the compiled program returns the correct result
	out=$(./test/results/test0009-knight-posix-binary 2>&1 )
	[ 42 = $? ] || exit 4
	[ "$out" = "Hello mes" ] || exit 5
fi
exit 0
