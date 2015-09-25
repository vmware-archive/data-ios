#!/bin/bash

set -e
set -x

xcodebuild -destination platform='iOS Simulator',name="${XCODE_SIMULATOR_NAME}" -scheme PCFAuthTests clean build test
