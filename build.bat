@echo off

setlocal EnableDelayedExpansion

if not exist libxev (
    git clone --recurse-submodules --revision 9b6634b6229be5f2c8fb22db1f6f652bac5c5040 https://github.com/mitchellh/libxev --depth=1
    if errorlevel 1 exit /b 1
)

pushd libxev
if errorlevel 1 exit /b 1

echo Building project...
rem DUMBAI: Use zvm when available so libxev builds against its pinned Zig version.
where /q zvm
if %ERRORLEVEL% EQU 0 (
    zvm use 0.15.1
    if errorlevel 1 (
        popd
        exit /b 1
    )
)

rem DUMBAI: Fail fast when Zig is missing so the orchestrator sees a real build failure.
where /q zig
if errorlevel 1 (
    echo zig was not found on PATH. Install zig 0.15.1 or run zvm setup first.
    popd
    exit /b 1
)

zig build --release=fast
if errorlevel 1 (
    popd
    exit /b 1
)

rem DUMBAI: Copy output next to xev.odin because Odin links against vendor/xev/libxev.lib.
copy /y zig-out\lib\libxev.lib ..\libxev.lib
if errorlevel 1 (
    popd
    exit /b 1
)

popd

echo Build completed successfully!
