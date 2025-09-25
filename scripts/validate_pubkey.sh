#!/bin/bash
set -euo pipefail

KEY_FILE="$1"

if [ ! -f "$KEY_FILE" ]; then
    echo "Error: Public key file not found" >&2
    exit 1
fi

# Validate key type and size
KEY_INFO=$(ssh-keygen -l -f "$KEY_FILE")
if ! echo "$KEY_INFO" | grep -qE '(ED25519|4096 SHA256)'; then
    echo "Error: Key must be ED25519 or RSA-4096" >&2
    exit 1
fi

# Validate filename matches username pattern
# Derivar username desde el nombre del archivo, soportando sufijos .ed25519.pub y .rsa.pub
FILENAME=$(basename "$KEY_FILE")
USERNAME="$FILENAME"
if [[ "$USERNAME" == *.ed25519.pub ]]; then
  USERNAME=${USERNAME%.ed25519.pub}
elif [[ "$USERNAME" == *.rsa.pub ]]; then
  USERNAME=${USERNAME%.rsa.pub}
elif [[ "$USERNAME" == *.pub ]]; then
  USERNAME=${USERNAME%.pub}
fi
if ! echo "$USERNAME" | grep -qE '^[a-z]+\.[a-z]+(-[0-9]+)?$|^svc-[a-z]+-[a-z]+$'; then
    echo "Error: Invalid username format in filename" >&2
    exit 1
fi

echo "Public key validation successful"
exit 0
