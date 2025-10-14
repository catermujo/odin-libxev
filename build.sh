#!/usr/bin/env sh

set -e

[ -d libxev ] || git clone https://github.com/mitchellh/libxev --depth 1

cd libxev
zvm use 0.15.1
# FIXME: building without the release flag causes linker errors because of an undefined symbol "__zig_probe_stack"
zig build --release=fast
if [ $(uname -s) = 'Darwin' ]; then
    LIB_EXT=darwin
else
    LIB_EXT=linux
fi

echo "done!"
cp zig-out/lib/libxev.a ../libxev.$LIB_EXT.a
