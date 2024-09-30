#!/bin/bash

# Name: Dan Fedick && Cam Banowsky
# Purpose: Generate a wildcard private key and CSR with improved functionality and security.

set -euo pipefail

#############
# Functions #
#############

print_usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  -d, --domain DOMAIN         Domain name (e.g., example.com)
  -c, --country COUNTRY       Country code (e.g., US)
  -s, --state STATE           State or province (e.g., California)
  -l, --city CITY             City or locality (e.g., San Francisco)
  -o, --organization ORG      Organization name (e.g., My Company)
  -e, --email EMAIL           Email address (e.g., admin@example.com)
  -n, --dns DNS_NAMES         Comma-separated DNS names for SAN (optional)
  -w, --wildcard              Generate a wildcard certificate for the domain
  -h, --help                  Display this help message

Examples:
  $0 -d example.com -c US -s California -l "San Francisco" -o "My Company" -e admin@example.com -w
EOF
}

error_exit() {
  echo "Error: $1" >&2
  exit 1
}

check_dependencies() {
  command -v openssl >/dev/null 2>&1 || error_exit "OpenSSL is not installed."
}

set_permissions() {
  chmod 600 "$1"
}

cleanup() {
  rm -f "$CONF_FILE"
}

trap cleanup EXIT

#############
# Variables #
#############

# Default values
DOMAIN=""
COUNTRY="US"
STATE=""
CITY=""
ORG=""
EMAIL=""
DNS_NAMES=()
WILDCARD=false

###############
# Parse Args  #
###############

if [[ $# -eq 0 ]]; then
  print_usage
  exit 1
fi

# Use getopts for argument parsing
while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--domain)
      DOMAIN="$2"
      shift 2
      ;;
    -c|--country)
      COUNTRY="$2"
      shift 2
      ;;
    -s|--state)
      STATE="$2"
      shift 2
      ;;
    -l|--city)
      CITY="$2"
      shift 2
      ;;
    -o|--organization)
      ORG="$2"
      shift 2
      ;;
    -e|--email)
      EMAIL="$2"
      shift 2
      ;;
    -n|--dns)
      IFS=',' read -r -a DNS_NAMES <<< "$2"
      shift 2
      ;;
    -w|--wildcard)
      WILDCARD=true
      shift
      ;;
    -h|--help)
      print_usage
      exit
      ;;
    *)
      error_exit "Unknown option: $1"
      ;;
  esac
done

# Validate required arguments
[[ -z "$DOMAIN" ]] && error_exit "Domain is required."
[[ -z "$STATE" ]] && error_exit "State is required."
[[ -z "$CITY" ]] && error_exit "City is required."
[[ -z "$ORG" ]] && error_exit "Organization is required."
[[ -z "$EMAIL" ]] && error_exit "Email is required."

#############
# Main Body #
#############

check_dependencies

CERTS_DIR="./certs"
mkdir -p "$CERTS_DIR"

CONF_FILE=$(mktemp)

# Set Common Name
if $WILDCARD; then
  CN="*.$DOMAIN"
else
  CN="$DOMAIN"
fi

cat > "$CONF_FILE" << EOF
[req]
distinguished_name = req_distinguished_name
req_extensions     = req_ext
prompt             = no

[req_distinguished_name]
C  = $COUNTRY
ST = $STATE
L  = $CITY
O  = $ORG
CN = $CN
emailAddress = $EMAIL

[req_ext]
subjectAltName = @alt_names

[alt_names]
EOF

# Add DNS entries
DNS_INDEX=1

# If wildcard, ensure that the wildcard domain is included in SANs
if $WILDCARD; then
  echo "DNS.$DNS_INDEX = *.$DOMAIN" >> "$CONF_FILE"
  ((DNS_INDEX++))
fi

# Include base domain in SANs
echo "DNS.$DNS_INDEX = $DOMAIN" >> "$CONF_FILE"
((DNS_INDEX++))

# Add additional DNS names if provided
for DNS in "${DNS_NAMES[@]}"; do
  echo "DNS.$DNS_INDEX = $DNS" >> "$CONF_FILE"
  ((DNS_INDEX++))
done

echo "Generating private key and CSR for $CN..."

# Generate private key and CSR
openssl req -new -newkey rsa:4096 -nodes \
  -keyout "$CERTS_DIR/$DOMAIN-key.pem" \
  -out "$CERTS_DIR/$DOMAIN.csr" \
  -config "$CONF_FILE" || error_exit "OpenSSL command failed."

set_permissions "$CERTS_DIR/$DOMAIN-key.pem"

echo "Private key and CSR have been generated in the $CERTS_DIR directory."

# Optionally display the CSR
echo "CSR Details:"
openssl req -noout -text -in "$CERTS_DIR/$DOMAIN.csr"
