#!/bin/bash

sha1() { sha1sum | head -c40; }

sha1_hmac() {
  chr() { printf -v v '%03o' $1 ; printf \\${v}; }
  ord() { printf '%d' "'${1}"; }
  K=${1}
  L=64
  [ ${#K} -gt ${L} ] && K=$(echo -En ${K} | sha1)
  I=''
  O=''
  for ((n=0;n<L;n++)); do
    d=0
    [ ${n} -ge ${#K} ] || d=$(ord "${K:${n}:1}")
    I+=$(chr $((d ^ 0x36)))
    O+=$(chr $((d ^ 0x5C)))
  done
  data="$(cat)"
  echo -En "${O}$(echo -En "${I}${data}" | sha1 | while read -n2 v; do echo -ne "\x${v}"; done)" | sha1
  echo
}

if [ "${0}" = "${BASH_SOURCE}" ]; then
  sha1_hmac $@
fi
