#!/bin/bash

sha1() {
  rotl1() {
    local ls=$((${1} << 1))
    local rs
    [ ${ls} -ge $((2**31)) ] && ls=$(((2**31 - (ls - 2**31)) * -1))
    [ ${ls} -lt $((-1 * 2**31)) ] && ls=$((2**32 + ls))
    rs=$((${1} >> 31))
    [ ${rs} -lt 0 ] && rs=$((rs * -1))
    rotl1v=$((${ls} | ${rs}))
  }
  rotl() {
    rotlv=${1}
    local i
    for ((i=${2};i>0;i--)); do
      rotl1 ${rotlv}
      rotlv=${rotl1v}
    done
  }
  sha1f() {
    case ${1} in
      0) sha1fv=$(((${2} & ${3}) ^ (~${2} & ${4}))); return;;
      1) sha1fv=$((${2} ^ ${3} ^ ${4})); return;;
      2) sha1fv=$(((${2} & ${3}) ^ (${2} & ${4}) ^ (${3} & ${4}))); return;;
      3) sha1fv=$((${2} ^ ${3} ^ ${4})); return;;
    esac
  }
  add2() {
    add2v=$((${1} + ${2}))
    [ ${add2v} -ge $((2**31)) ] && add2v=$(((2**31 - (add2v - 2**31)) * -1))
    [ ${add2v} -lt $((-1 * 2**31)) ] && add2v=$((2**32 + add2v))
  }
  K=( 1518500249 1859775393 2400959708 3395469782 )
  while IFS=;read -d '' -n1 y; do
    ((m++))
    msg+=($(printf '%d' \'${y}))
  done
  msg[((m++))]=128
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
      rotl ${x} 1
      v=${rotlv}
      eval "W[\${t}]=\${v}"
    done
    ((a=H0,b=H1,c=H2,d=H3,e=H4))
    for ((t=0;t<80;t++)); do
      s=$((t / 20))
      rotl ${a} 5
      ra=${rotlv}
      sha1f ${s} ${b} ${c} ${d}
      add2 ${ra} ${sha1fv}
      T1=${add2v}
      add2 ${T1} ${e}
      T2=${add2v}
      add2 ${T2} ${K[s]}
      T3=${add2v}
      add2 ${T3} ${W[t]}
      T=${add2v}
      e=${d}
      d=${c}
      rotl ${b} 30
      c=${rotlv}
      b=${a}
      a=${T}
    done
    add2 ${H0} ${a}
    H0=${add2v}
    add2 ${H1} ${b}
    H1=${add2v}
    add2 ${H2} ${c}
    H2=${add2v}
    add2 ${H3} ${d}
    H3=${add2v}
    add2 ${H4} ${e}
    H4=${add2v}
  done
  printf "%08x%08x%08x%08x%08x\n" ${H0} ${H1} ${H2} ${H3} ${H4}
}

if [ "${0}" = "${BASH_SOURCE}" ]; then
  if [ -n "${1}" ]; then
    sha1 <"${1}"
  else
    sha1
  fi
fi
