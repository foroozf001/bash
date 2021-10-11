#!/bin/bash
#
# This script allows users to check connectivity to targets either directly or via proxy.
#

# Usage statement
usage() {
  echo "This script allows users to check connectivity to targets either directly or via proxy."
  echo
  echo "Usage:"
  echo "  sudo ${0} [-ux] -f FILENAME -p PORT"
  echo
  echo "Examples:"
  echo "  sudo ${0} --file my_hosts.txt --port 80 --proxy 198.19.18.21 --user awx"
  echo "  sudo ${0} --file my_hosts.txt --port 80"
  echo
  echo "Options:"
  echo "  -h, --help"
  echo "  -f, --file  Target hosts"
  echo "  -p, --port  Target port"
  echo "  -u, --user  Proxy user"
  echo "  -x, --proxy Proxy host"
  echo
}

# Ensure the user executes this script with elevated user permissions.
if [[ $(id -u) -ne 0 ]];then 
	echo "Please run with sudo or as root." 1>&2
	exit 1
fi

# Ensure the user supplies at least one argument.
if [[ "${#}" -lt 1 ]];then
	usage 1>&2
	exit 1
fi

# Loop over all positional parameters.
while [[ "${#}" -gt 0 ]];do
  case "${1}" in
    # Input parameter file.
    -f|--file)
      shift
      FILE="${1}"
      shift
      ;;
    # Display usage statement.
    -h|--help)
			usage
      exit 0
      ;;
    # Input parameter target port.
    -p|--port)
      shift
      PORT="${1}"
      shift
      ;;
    # Input parameter proxy user.
    -u|--user)
      shift
      USER="${1}"
      shift
      ;;
    # Input parameter proxy.
    -x|--proxy)
      shift
      PROXY="${1}"
      shift
      ;;
    # Invalid input parameter. 
    *)
      echo "Invalid argument: ${1}." 1>&2
      echo
      "${0}" -h
			exit 1
      ;;
  esac
done

# Ensure file exists.
if [[ ! -f "${FILE}" ]];then
  echo "File ${FILE} does not exist." 1>&2
  exit 1
# Ensure port isn't empty or less than one.
elif [[ -z "${PORT}" ]] || [[ "${PORT}" -lt 1 ]];then
  echo "Port is invalid." 1>&2
fi

# Read hosts file, line-by-line. Default tcp timeout is set to one seconds
TIMEOUT=1
while IFS= read -r HOST;do
  if [[ ! -z "${PROXY}" ]] && [[ ! -z "${USER}" ]];then
    ssh -n "${USER}"@"${PROXY}" timeout $TIMEOUT bash -c "cat < /dev/null > /dev/tcp/${HOST}/${PORT}" &> /dev/null
    if [[ "${?}" -eq 0 ]];then
      echo "Connection to ${HOST}:${PORT} succeeded."
    else
      echo "Connection to ${HOST}:${PORT} timed out."
    fi
  else
    timeout $TIMEOUT bash -c "cat < /dev/null > /dev/tcp/${HOST}/${PORT}" &> /dev/null
    if [[ "${?}" -eq 0 ]];then
      echo "Connection to ${HOST}:${PORT} succeeded."
    else
      echo "Connection to ${HOST}:${PORT} timed out."
    fi
  fi
done < "${FILE}"