#!/bin/bash
set -e

########## CONFIG ##############
CHALLENGE= #PUT YOUR CHALLENGE IN QUOTES
MOUNTPOINT="/run/media/$USER/priv"
CONT_DIR=$HOME/.local/share/verayubi
########## CONFIG ##############

if [ ! -d "$CONT_DIR" ]; then
    mkdir -p $CONT_DIR
fi

create() {
    read -p "Container Name: " CONT_NAME 
    read -p "Size (format: 2K, 2M, 2G): " CONT_SIZE 

    KEYFILE=$(mktemp -p /dev/shm)
    trap 'shred -u "$KEYFILE" 2>/dev/null' EXIT #cleanup for keyfile in-case script fails 
    
    #derive temp keyfile
    ykman otp calculate 2 "$CHALLENGE" > "$KEYFILE"

    veracrypt --text --create "$CONT_DIR/$CONT_NAME" \
      --size="$CONT_SIZE" \
      --keyfiles="$KEYFILE" \
      --encryption=AES-Twofish \
      --hash=SHA-512 \
      --filesystem=ext4 \
      --volume-type=normal \
      --random-source=/dev/urandom
}

mount_vol() {
    select CONTAINER in "$CONT_DIR"/*; do
        break
    done

    MOUNTPOINT="/run/media/$USER/priv"
    KEYFILE=$(mktemp -p /dev/shm)
    trap 'shred -u "$KEYFILE" 2>/dev/null' EXIT


    if [ ! -d "$MOUNTPOINT" ]; then
        sudo mkdir -p "$MOUNTPOINT"
    fi

    # Derive keyfile from YubiKey
    ykman otp calculate 2 "$CHALLENGE" > "$KEYFILE"

    veracrypt --text --keyfiles="$KEYFILE" --protect-hidden=no "$CONTAINER" "$MOUNTPOINT"

    echo "Mounted at $MOUNTPOINT"
    #nautilus -w $MOUNTPOINT or whatever file manager u use
}

unmount_vol() {
    veracrypt --text -d $MOUNTPOINT
    echo "Unmounted"
}

list() {
    ls $CONT_DIR
}


case "$1" in
    create)   create ;;
    mount)    mount_vol ;;
    unmount)  unmount_vol ;;
    list)     list ;;
    *)        echo "Usage: verayubi {create|mount|unmount|list}" ;;
esac
