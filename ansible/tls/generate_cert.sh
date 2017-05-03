#!/bin/bash
set -e
set -o pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

if [ $# -lt 3 ]; then
    echo 'Usage: generate_cert.sh CA PROFILE NAME [ALTNAMES...]' >&2
    exit 1
fi
CA="$1"; shift
PROFILE="$1"; shift
NAME="$1" # No shift here, because we are going to use $@ to get all names later

if [ -n "$CERT_ORG" ]; then
    ORGBLOCK=', "names": [ { "O": "'"$CERT_ORG"'" } ]'
else
    ORGBLOCK=''
fi

# From http://stackoverflow.com/a/17841619
function join_by {
    local IFS="$1"
    shift
    echo "$*"
}
NAMES="$(join_by ',' $@)"

if [ ! -f "${CA}-ca.json" ]; then
    echo "Invalid CA: ${CA}" >&2
    exit 1
fi


if [ -f "${CA}/${NAME}.names" ]; then
    if [ "$(<"${CA}/${NAME}.names")" = "${NAMES}" ]; then
	echo "Certificate for ${NAME} already exists -- skipping" >&2
	exit 2
    fi
fi

# From http://stackoverflow.com/a/8088167/1954565
define(){
    IFS='\n'
    read -r -d '' ${1} || true
}

define REQUEST <<EOF
{
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "CN": "${NAME}"
  $ORGBLOCK
}
EOF

echo "$REQUEST" | ./bin/cfssl gencert -ca="${CA}/ca.pem" -ca-key="${CA}/ca-key.pem" -config=ca-config.json -profile="${PROFILE}" -hostname="${NAMES}" - | ./bin/cfssljson -bare "${CA}/${NAME}"
echo "${NAMES}" >"${CA}/${NAME}.names"
