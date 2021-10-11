# Connectivity checker
A simple Bash-script that allows users to perform connectivity checks.
## Usage statement
```bash
This script allows users to check connectivity to targets either directly or via proxy.

Usage:
  sudo ./connectivity-checker/connectivity-checker.sh [-ux] -f FILENAME -p PORT

Examples:
  sudo ./connectivity-checker.sh --file my_hosts.txt --port 80 --proxy 198.19.18.21 --user awx
  sudo ./connectivity-checker.sh --file my_hosts.txt --port 80

Options:
  -h, --help
  -f, --file  Target hosts
  -p, --port  Target port
  -u, --user  Proxy user
  -x, --proxy Proxy host
```
## Usage instructions
### Hosts
The connectivity checker expects a file containing all target hosts as input. The hosts are simply seperated by newlines. Ensure the last line of the file is an empty line; it will skip the last host entry otherwise.
```bash
10.290.1.1
10.290.1.2
10.290.1.3
10.290.1.4
10.290.1.5

```
### Direct
To perform a regular connectivity check, provide only the required "--port" and "--file" flags.
```bash
 sudo ./connectivity-checker.sh --file my_hosts.txt --port 80
```
### Proxy
To perform connectivity checks via proxy, provide the optional "--user" and "--proxy" flags. The script will always execute the connectivity checks via SSH through the proxy.
```bash
sudo ./connectivity-checker.sh --file my_hosts.txt --port 80 --proxy 198.19.18.21 --user awx
```
