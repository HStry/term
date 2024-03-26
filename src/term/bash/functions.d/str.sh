if [[ "${0}" == "${BASH_SOURCE[0]}" ]]; then
  echo "This script is intended to be sourced, not run." >&2
  exit 255
fi

str.repeat() {
  local n="${1:-3}"
  local c="${2:- }"
  if [[ ! "${n}" =~ ^(0|-?[1-9][0-9]*)$ ]]; then
    echo "argument 1 must be numeric" >&2
    return 1
  fi
  while (( n>0, n-- )); do
    echo -en "${c}"
  done
}

str.ljust() {
  local pad="$(str.repeat $(( ${1} - ${#2} )) "${3:- }")" || return 1
  echo -en "${2}${pad}"
}

str.rjust() {
  local pad="$(str.repeat $(( ${1} - ${#2} )) "${3:- }")" || return 1
  echo -en "${pad}${2}"
}

str.cjust() {
  local lpad="$(str.repeat $(( (${1} - ${#2}) / 2 )) "${3:- }")" || return 1
  local rpad="$(str.repeat $(( ${1} - ${#2} - ${#lpad} )) "${3:- }")"
  echo -en "${lpad}${2}${rpad}"
}

str.isint() {
  [[ "${1}" =~ ^(0|-?[1-9][0-9]*)$ ]]
}

str.isfloat() {
  [[ "${1}" =~ ^(\.0+|0\.0*|-?0?\.[0-9]*[1-9][0-9]*|-?[1-9][0-9]*\.[0-9]*)$ ]]
}

str.isnumeric() {
  str.isint "${1}" or str.isfloat "${1}"
}

str.isupper() {
  [[ "${1}" =~ ^[A-Z]+$ ]]
}

str.islower() {
  [[ "${1}" =~ ^[a-z]+$ ]]
}

str.isalpha() {
  [[ "${1}" =~ ^[A-Za-z]+$ ]]
}

str.isalphanumeric() {
  [[ "${1}" =~ ^[A-Za-z0-9]+$ ]]
}

str.ishex() {
  [[ "${1}" =~ ^(0x)?([0-9A-F]+|[0-9a-f]+)$ ]]
}

str.isoct() {
  [[ "${1}" =~ ^(0o)?[0-8]+$ ]]
}

str.isbin() {
  [[ "${1}" =~ ^(0b)?[01]+$ ]]
}

#str.count() {
#  local n=0 i=0 j=${#2}
#  if [[ -z "${1}" ]]; then
#    echo "Missing match string" >&2
#    return 1
#  fi
#  echo "$n $i $j"
#  while (( i<"${#2}", i++ )); do
#    echo "$(str.rjust 3 "${i}"): '${2:i}'" >&2
#    if [[ "${2:i}" == "${1}"* ]]; then
#      (( n++ ))
#      (( i+=(${#1}-1) ))
#    fi
#  done
#  echo "$n"
#}

#str.index() {
#}

export -f str.{repeat,ljust,rjust,cjust} \
          str.is{int,float,numeric,upper,lower,alpha,alphanumeric,hex,oct,bin}
