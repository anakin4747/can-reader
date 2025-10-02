#!/bin/bash

log() {
    echo -e "\e[34m$0: $*\e[0m" 1>&2
}

fatal() {
    echo -e "\e[31m$0: fatal: $*\e[0m" 1>&2
    exit 1
}

if ! [ -d "venv" ]; then
    log "creating virtual environment"
    python3 -m venv venv || fatal "failed venv creation"
fi

if [ -z "$VIRTUAL_ENV" ]; then
    # don't log to misslead users that it is sourced for them
    source venv/bin/activate || fatal "failed source venv"
fi

if ! which west > /dev/null; then
    log "installing west"
    pip install west || fatal "failed to install west"
fi

if ! [ -d ".west" ]; then
    log "initializing west"
    west init -l manifest || fatal "failed west init"
fi

if ! [ -d "zephyr" ]; then
    log "running west update"
    west update || fatal "failed west update"
fi

# patch zephyr on the fly
sed -i \
    -e 's:HOME}/.cmake/packages:CMAKE_USER_PACKAGE_REGISTRY}:' \
    -e 's:~/.cmake/packages:$ENV{CMAKE_USER_PACKAGE_REGISTRY}:' \
    ./zephyr/share/zephyr-package/cmake/zephyr_export.cmake \
    ./zephyr/share/zephyrunittest-package/cmake/zephyr_export.cmake

export CMAKE_USER_PACKAGE_REGISTRY="$PWD/.cmake/packages"
mkdir -p "$CMAKE_USER_PACKAGE_REGISTRY" || fatal "failed to make cmake dir"
if ! [ -d "$CMAKE_USER_PACKAGE_REGISTRY/Zephyr" ]; then
    log "running west zephyr-export"
    west zephyr-export || fatal "failed west zephyr-export"
fi

if ! [ -f "./venv/lib/python3.10/site-packages/hexdump.py" ]; then
    log "installing west packages"
    west packages pip --install || fatal "failed to install west packages"
fi

if ! [ -d ".sdk" ]; then
    cd zephyr || fatal "failed to cd zephyr"
    log "installing zephyr sdk"
    west sdk install --install-dir ../.sdk || fatal "failed to install sdk"
    cd - || true
fi

if ! [ -f "hal_espressif/zephyr/blobs/lib/esp32c6/libble_app.a" ]; then
    log "fetching RF blobs"
    west blobs fetch hal_espressif || fatal "failed to fetch RF blobs"
fi

log "building for esp32"
export CMAKE_PREFIX_PATH="$PWD/.sdk/cmake:$CMAKE_PREFIX_PATH"
west build \
    -b esp_wrover_kit/esp32/procpu \
    zephyr/samples/hello_world/ || {
        fatal "failed to build sample"
}

west flash || fatal "failed to flash sample"

# screen /dev/ttyUSB? 115200
