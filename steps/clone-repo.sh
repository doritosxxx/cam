#!/bin/bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2022 Yegor Bugayenko
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

repo=$1
pos=$2
total=$3

start=$(date +%s)

dir="${TARGET}/github/${repo}"

if [ -e "${dir}" ]; then
    echo "The repo directory #${pos}/${total} is already here: ${dir}"
    exit
fi

args="--quiet --depth 1"
if [ ! -z "${tag}" ]; then
    args="${args} --branch="${tag}""
fi

echo "${repo} (${pos}/${total}): trying to clone it..."
declare -i re=0
until timeout 1h git clone ${args} "https://github.com/${repo}" "${dir}"; do
    if [ "${re}" -gt 5 ]; then
        echo "Too many failures (${re}) for ${repo}"
        exit -1
    fi
    re=re+1
    rm -rf "${dir}"
    echo "Retry #${re} for ${repo}..."
    sleep "${re}"
done
printf "${repo},$(git --git-dir "${dir}/.git" rev-parse HEAD)\n" >> "${TARGET}/hashes.csv"

echo "${repo} cloned (${pos}/${total}) in $(echo "$(date +%s) - ${start}" | bc)s"
