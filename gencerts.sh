#!/bin/bash
#
# Name: Dan Fedick
# Purpose: To generate Priv/CSR
#
#######################
#set -x # Uncomment to debug

#############
# Variables #
#############
DOMAIN=cinderandstone.land

country="US"
state="Virginia"
city="Norfolk"
org="CinderandStone"
cn="*.${DOMAIN}"
emailAddress="offers@csland.co"
dns1=*.${DOMAIN}
dns2=sell.${DOMAIN}
dns3=buy.${DOMAIN}

##########
# CHECKS #
##########
if [[ $1 == "-h" ]]; then
  echo "./gencerts -cert|-csr"
  exit
fi

# Check CSR 
if [[ $1 == "-csr" ]];then
  openssl req -text -in ./certs/${DOMAIN}.csr
  exit
fi

# Check Cert
if [[ $1 == "-cert" ]]; then
  openssl rsa -in ./certs/${DOMAIN}-key.pem -text -noout
  exit
fi

# Check for Certs Directory
if [[ ! -d ./certs ]] ; then mkdir -p ./certs ; fi

########
# BODY #
########
# Generate Configuration File:
CONF=${DOMAIN}.cnf

tee ./certs/${CONF} << EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = req_ext
prompt = no

[req_distinguished_name]
C = ${country}
ST = ${state}
L = ${city}
O = ${org}
CN = ${cn}

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${dns1}
DNS.2 = ${dns2}
DNS.3 = ${dns3}
EOF

# Generate  CSR and Private Keys
echo "Generating CSR and Private Key"
openssl req -new -newkey rsa:4096 \
  -nodes \
  -keyout ./certs/${DOMAIN}-key.pem \
  -out ./certs/${DOMAIN}.csr \
  -config ./certs/${CONF}
