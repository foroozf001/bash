# Certificate matcher
A simple Bash-script that allows users to perform certificate matching.
## Usage statement
```bash
This script allows users to determine whether certificate files are matching.

Usage:
  ./certificate-matcher.sh [OPTIONS]...

Options:
  -h, --help
  -p, --public-key	public key
  -c, --csr         certificate signing request
  -k, --private-key	private key
```
## Usage instructions
In the certificate matcher directory you'll find two sets of dummy certificate files. The private key passphrase for these dummy certificates is: ```password```. These dummy files are there to test the certificate matcher script.

Test matching CSR and private key:
```bash
$ sudo ./certificate-matcher.sh --csr server.csr --private-key server.key
Enter pass phrase for server.key: 
match
```

Test matching public- and private key pairs:
```bash
$ sudo ./certificate-matcher.sh --private-key server2.key --public-key server2.crt
Enter pass phrase for server2.key: 
match
```

Mismatched certificate files:
```bash
$ sudo ./certificate-matcher.sh --private-key server2.key --csr server.csr
Enter pass phrase for server2.key: 
no match
```