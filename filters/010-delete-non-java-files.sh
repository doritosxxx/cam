#!/usr/bin/env bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2023 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -e
set -o pipefail

home=$1
temp=$2

total=$(find "${home}" -type f | wc -l)
java=$(find "${home}" -type f -a -name '*.java' | wc -l | xargs)

list=${temp}/filter-lists/non-java-files.txt
if [ -e "${list}" ]; then
    exit
fi

mkdir -p "$(dirname "${list}")"
find "${home}" -type f -not -name '*.java' -print > "${list}"
while IFS= read -r f; do
    rm -f "${f}"
done < "${list}"

if [ -s "${list}" ]; then
    printf "There were %d files total, %d of them were \\\ff{.java} files; all other files, which were not \\\ff{.java}, have been deleted: %d total" \
        "${total}" "${java}" "$(wc -l < "${list}" | xargs)"
else
    printf "All %d files were \\\ff{.java} files, nothing to delete" \
        "${total}"
fi
