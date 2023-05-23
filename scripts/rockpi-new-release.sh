#!/bin/bash

set -ex

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "need to supply old and new upstream version, e.g. ./scripts/rockpi-new-release.sh 10.3 10.4"
    exit 1
fi

repo=$(dirname -- "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )" )
br_repo="$repo/buildroot"

old_branch_name="rockpi_$1"
new_branch_name="rockpi_$2"

git -C "$repo" fetch
git -C "$repo" fetch upstream

git -C "$repo" diff
echo "will stash local changes. ok?"
read
git -C "$repo" stash

git -C "$repo" checkout $old_branch_name
git -C "$repo" checkout -b $new_branch_name
res=""
git -C "$repo" rebase -i $1 --onto $2 || res="1"

if [ -z "$res" ]; then
    echo "expected rebase to fail, but didn't. stopping."
    exit 1
fi

echo "check that the buildroot commit failed"
read 

git -C "$repo" reset buildroot
git -C "$repo" submodule deinit -f buildroot
git -C "$repo" submodule update --init
git -C "$br_repo" revert 609a390e3391abf533ee9dfe03b3e3d738921246
git -C "$br_repo" checkout -b "buildroot_$new_branch_name"
git -C "$br_repo" push --set-upstream origin "buildroot_$new_branch_name"
git -C "$repo" add buildroot
git -C "$repo" rebase --continue
git -C "$repo" push --set-upstream origin $new_branch_name

echo "Apply local patches?"
read resp
if [ "$resp" == "y" ]; then
    git -C "$repo" apply "$repo/"000*.patch
    git -C "$br_repo" apply "$repo/"buildroot-000*.patch
fi

echo "Done. Don't forget to check the defconfigs of other boards for changes that need to be applied to rockpi configs."
