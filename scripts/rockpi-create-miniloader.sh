#!/bin/bash -e

if [ -z "$1" ]; then
    echo "need to provide input image"
    exit 1
fi

input=$(realpath "$1")
output="$(dirname "$input")/miniloader.img"

if [ -f "$output" ]; then
    echo "$output already exists"
    exit 1
fi

dd if="$input" of="$output" bs=1M count=8
dd if=/dev/zero of="$output" bs=1024 count=32 conv=notrunc
echo "$output"
