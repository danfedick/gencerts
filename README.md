# gencerts
Script for Generating wildcard Certs

## Usage

the `./gencerts` script will generate a `./certs` directory that is not committed to github.

```bash
./gencerts.sh
```

## Check the configuration of a CERT

```bash
./gencerts.sh -cert
```

```
Private-Key: (4096 bit, 2 primes)
modulus:
    00:e4:1e:81:52:cb:7e:d1:47:49:3e:cb:0e:e5:c7:
    71:75:73:9a:39:06:31:33:b4:1d:02:38:b8:22:85:
<TRUNCATED>
```

## Check the configuration of a CSR

```bash
./gencerts.sh -csr
```

```
Certificate Request:
    Data:
        Version: 1 (0x0)
        Subject: C = US, ST = Virginia, L = Norfolk, O = CinderandStone, CN = *.cinderandstone.land
<TRUNCATED>
```


## Get help with the `gencerts.sh` script

```bash
./gencerts.sh -h
```
