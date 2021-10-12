#!/bin/bash 

usage() {
  echo "This script allows users to determine whether certificate files are matching."
  echo
  echo "Usage:"
  echo "  ${0} [OPTIONS]..."
  echo
  echo "Options:"
  echo "  -h, --help"
  echo "  -p, --public-key	public key"
  echo "  -c, --csr		certificate signing request"
  echo "  -k, --private-key	private key"
  echo
}

# Ensure the user executes this script with elevated user permissions.
if [[ $(id -u) -ne 0 ]];then 
	echo "Please run with sudo or as root." 1>&2
	exit 1
fi

# Ensure the user supplies at least four arguments.
if [[ "${#}" -lt 1 ]];then
	usage 1>&2
	exit 1
fi

# Loop over all positional parameters.
while [[ "${#}" -gt 0 ]];do
  case "${1}" in
    # Display usage.
    -h|--help)
      usage
      exit 0
      ;;
    # Input parameter public key.
    -p|--public-key)
      shift
      PUBLIC_KEY_FILE="${1}"
      shift
      ;;
    # Input parameter certificate signing request.
    -c|--csr)
      shift
      CSR_FILE="${1}"
      shift
      ;;
    # Input parameter private key.
    -k|--private-key)
      shift
      PRIVATE_KEY_FILE="${1}"
      shift
      ;;
    # Invalid input parameter. 
    *)
      echo "Invalid argument: ${1}." 1>&2
      echo
      "${0}" -h
      exit 1
      break
      ;;
  esac
done

# Array containing certificate checksums.
SUMS=()
if [[ -f "${PRIVATE_KEY_FILE}" ]];then  
  # User input passphrase.
  read -s -p "Enter pass phrase for ${PRIVATE_KEY_FILE}: " PASSPHRASE
  if [[ -z "${PASSPHRASE}" ]]; then
    echo 
    echo "empty passphrase" 1>&2
    exit 1
  fi
  echo  
  # Attempt to process private key, using passphrase, to confirm validity.
  openssl pkey -in "${PRIVATE_KEY_FILE}" -passin pass:"${PASSPHRASE}" -pubout -outform pem &> /dev/null 
  if [[ "${?}" -eq 1 ]];then
    echo "invalid passphrase" 1>&2
    exit 1
  fi
  # Get private key checksum and append to array.
  PRIVATE_SUM=$(openssl pkey -in "${PRIVATE_KEY_FILE}" -passin pass:"${PASSPHRASE}" -pubout -outform pem | sha256sum)
  SUMS+=("${PRIVATE_SUM}")
fi

if [[ -f "${PUBLIC_KEY_FILE}" ]];then
	# Attempt to process public key to confirm validity.
	openssl x509 -in "${PUBLIC_KEY_FILE}" -pubkey -noout -outform pem &> /dev/null
  if [[ "${?}" -eq 1 ]];then
    echo "invalid public key" 1>&2
    exit 1
  fi
  # Get public key checksum and append to array.
  PUBLIC_SUM=$(openssl x509 -in "${PUBLIC_KEY_FILE}" -pubkey -noout -outform pem | sha256sum)
  SUMS+=("${PUBLIC_SUM}")
fi 

if [[ -f "${CSR_FILE}" ]];then
	# Attempt to process CSR to confirm validity.
	openssl req -in "${CSR_FILE}" -pubkey -noout -outform pem &> /dev/null
  if [[ "${?}" -eq 1 ]];then
    echo "invalid csr" 1>&2
    exit 1
  fi
  # Get csr checksum and append to array.
  CSR_SUM=$(openssl req -in "${CSR_FILE}" -pubkey -noout -outform pem | sha256sum)
  SUMS+=("${CSR_SUM}")
fi

# Ensure there's at least two checksums present.
LENGTH="${#SUMS[@]}"
if [[ $LENGTH -lt 2 ]];then
  echo "invalid input arguments" 1>&2
  exit 1
fi

# Loop over checksums and exit if elements don't match.
for (( i=1; i<"${LENGTH}"; i++ ));do
  if [[ "${SUMS[0]}" != "${SUMS[$i]}" ]];then
    echo "no match"
    exit 1
  fi
done

echo "match"

exit 0