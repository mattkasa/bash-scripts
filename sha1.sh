#!/bin/bash

sha1() {
  pos() {
    [ ${1} -lt 0 ] && echo $((${1} * -1)) || echo ${1}
  }
  rotl1() {
    lss=$((${1} << 1))
    if [ ${lss} -ge $((2**31)) ]; then
      ls=$((-1 * (2**32 - lss)))
    elif [ ${lss} -lt $((-(2**31))) ]; then
      ls=$((lss + 2**32))
    else
      ls=${lss}
    fi
    rs=$(pos $((${1} >> 31)))
    echo $((${ls} | ${rs}))
  }
  rotl() {
    retval=${1}
    for ((i=${2};i>0;i--)); do
      retval=$(rotl1 ${retval})
    done
    echo ${retval}
  }
  sha1f() {
    case ${1} in
      0) echo $(((${2} & ${3}) ^ (~${2} & ${4}))); return;;
      1) echo $((${2} ^ ${3} ^ ${4})); return;;
      2) echo $(((${2} & ${3}) ^ (${2} & ${4}) ^ (${3} & ${4}))); return;;
      3) echo $((${2} ^ ${3} ^ ${4})); return;;
    esac
  }
  K=( 1518500249 1859775393 2400959708 3395469782 )
  while IFS=;read -d '' -n1 y; do
    ((m++))
    msg+=($(printf '%d' \'${y}))
  done
  msg[m]=128
  ((m++))
  l=$((m / 4 + 2))
  N=$(((l + 16 - 1) / 16))
  for ((i=0;i<N;i++)); do
    eval "M${i}=( )"
    for ((j=0;j<16;j++)); do
      ij=$((i * 64 + j * 4))
      m1=${msg[${ij}]}
      m2=${msg[$((ij + 1))]}
      m3=${msg[$((ij + 2))]}
      m4=${msg[$((ij + 3))]}
      mo=$(((${m1:-0} << 24) | (${m2:-0} << 16) | (${m3:-0} << 8) | ${m4:-0}))
      eval "M${i}+=(${mo})"
    done
  done
  lb=$(((m - 1) * 8))
  eval "M$((N - 1))[14]=$((lb / 4294967296))"
  eval "M$((N - 1))[15]=$((lb & 0xffffffff))"
  ((H0=1732584193,H1=4023233417,H2=2562383102,H3=271733878,H4=3285377520))
  W=( )
  for ((i=0;i<N;i++)); do
    for ((t=0;t<16;t++)); do
      eval "W[t]=\${M${i}[\${t}]}"
    done
    for ((t=16;t<80;t++)); do
      x=$((W[t-3] ^ W[t-8] ^ W[t-14] ^ W[t-16]))
      v=$(rotl ${x} 1)
      eval "W[\${t}]=\${v}"
      echo "W[${t}]=${W[t]}"
    done
    ((a=H0,b=H1,c=H2,d=H3,e=H4))
    for ((t=0;t<80;t++)); do
      s=$((t / 20))
      T=$((($(rotl ${a} 5) + $(sha1f ${s} ${b} ${c} ${d}) + e + K[s] + W[t]) & 0xffffffff))
      e=${d}
      d=${c}
      c=$(rotl ${b} 30)
      b=${a}
      a=${T}
    done
    H0=$(((H0 + a) & 0xffffffff))
    H1=$(((H1 + b) & 0xffffffff))
    H2=$(((H2 + c) & 0xffffffff))
    H3=$(((H3 + d) & 0xffffffff))
    H4=$(((H4 + e) & 0xffffffff))
  done
  printf "%8x%8x%8x%8x%8x\n" ${H0} ${H1} ${H2} ${H3} ${H4}
}

if [ "${0}" = "${BASH_SOURCE}" ]; then
  if [ -n "${1}" ]; then
    sha1 <"${1}"
  else
    sha1
  fi
fi
