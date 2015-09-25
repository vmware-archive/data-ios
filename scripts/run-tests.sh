#!/bin/bash

set -e
set -x

xcodebuild -destination platform='iOS Simulator',name="${XCODE_SIMULATOR_NAME}" -scheme PCFDataTests clean build test
