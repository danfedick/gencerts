# `gencerts.sh` - Generate Wildcard SSL Certificate and CSR

## Overview

`gencerts.sh` is a Bash script designed to generate a private key and Certificate Signing Request (CSR) for SSL/TLS certificates, with support for wildcard certificates. The script allows you to specify various certificate fields via command-line options, making it flexible and easy to use for generating certificates for your domains.

## Prerequisites

- **OpenSSL**: Ensure that OpenSSL is installed on your system.

  ```bash
  openssl version
  ```

  If OpenSSL is not installed, you can install it using your package manager. For example, on Ubuntu/Debian:

  ```bash
  sudo apt-get update
  sudo apt-get install openssl
  ```

## Installation

1. **Download the Script**

   Save the `gencerts.sh` script to your local machine.

2. **Make the Script Executable**

   ```bash
   chmod +x gencerts.sh
   ```

## Usage

The script accepts various command-line options to specify the details of the certificate.

```bash
Usage: ./gencerts.sh [options]

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
  ./gencerts.sh -d example.com -c US -s California -l "San Francisco" -o "My Company" -e admin@example.com -w
```

## Options

- `-d, --domain DOMAIN`:

  Specifies the primary domain name for the certificate.

- `-c, --country COUNTRY`:

  Specifies the country code (2-letter ISO format).

- `-s, --state STATE`:

  Specifies the state or province.

- `-l, --city CITY`:

  Specifies the city or locality.

- `-o, --organization ORG`:

  Specifies the organization name.

- `-e, --email EMAIL`:

  Specifies the email address associated with the certificate.

- `-n, --dns DNS_NAMES`:

  Specifies additional DNS names for the Subject Alternative Name (SAN) field. Provide multiple DNS names as a comma-separated list.

- `-w, --wildcard`:

  Indicates that a wildcard certificate should be generated. The Common Name (CN) will be set to `*.<domain>`, and `*.<domain>` will be included in the SANs.

- `-h, --help`:

  Displays the help message.

## Examples

### Generate a Wildcard Certificate

To generate a wildcard certificate for `example.com`:

```bash
./gencerts.sh \
  --domain example.com \
  --country US \
  --state California \
  --city "San Francisco" \
  --organization "My Company" \
  --email admin@example.com \
  --wildcard
```

This command generates a private key and CSR for `*.example.com`, including both `example.com` and `*.example.com` in the SANs.

### Generate a Certificate with Additional DNS Names

To include additional DNS names in the SAN:

```bash
./gencerts.sh \
  --domain example.com \
  --country US \
  --state California \
  --city "San Francisco" \
  --organization "My Company" \
  --email admin@example.com \
  --dns "api.example.com,mail.example.com"
```

This command generates a CSR with `example.com`, `api.example.com`, and `mail.example.com` in the SANs.

### Generate a Wildcard Certificate with Additional SANs

To generate a wildcard certificate and include extra SANs:

```bash
./gencerts.sh \
  --domain example.com \
  --country US \
  --state California \
  --city "San Francisco" \
  --organization "My Company" \
  --email admin@example.com \
  --wildcard \
  --dns "api.example.com,mail.example.com"
```

## Output Files

The script generates the following files in the `./certs` directory:

- **Private Key**: `./certs/<domain>-key.pem`
- **CSR**: `./certs/<domain>.csr`

For example, if your domain is `example.com`, the files will be:

- `./certs/example.com-key.pem`
- `./certs/example.com.csr`

## Viewing the CSR Details

The script displays the CSR details automatically. You can also view them manually:

```bash
openssl req -noout -text -in ./certs/<domain>.csr
```

## Security Considerations

- **Private Key Protection**: The script sets the private key permissions to `600` to restrict access. Ensure that the `./certs` directory is secure and accessible only to authorized users.
- **Certificate Authority Requirements**: Check with your Certificate Authority (CA) for any specific requirements when submitting the CSR, especially for wildcard certificates.

## Troubleshooting

- **OpenSSL Not Found**: If you receive an error that OpenSSL is not installed, install it using your system's package manager.
- **Permission Denied**: Ensure you have execute permissions for the script and write permissions for the `./certs` directory.

## Dependencies

- **Bash**: The script is written for the Bash shell.
- **OpenSSL**: Required for generating keys and CSRs.

## Cleanup

The script creates a temporary OpenSSL configuration file, which is automatically deleted after execution.

