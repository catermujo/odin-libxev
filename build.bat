@echo off

setlocal EnableDelayedExpansion

if not exist libxev (
    git clone --recurse-submodules --revision 9b6634b6229be5f2c8fb22db1f6f652bac5c5040 https://github.com/mitchellh/libxev --depth=1
)

pushd libxev

echo Building project...
zvm use 0.15.1
zig build --release=fast

copy /y zig-out\lib\libxev.lib .\

echo Build completed successfully!
