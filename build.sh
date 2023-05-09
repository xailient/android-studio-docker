#!/bin/bash
set -euxo pipefail

mkdir -p binaries
aws s3 sync --exclude='*' --include='commandlinetools-linux-9477386_latest.zip' s3://xailient-build-input-artifacts/android ./binaries/

mkdir -p studio-data/profile/AndroidStudio2022.1.1.21 || exit
mkdir -p studio-data/Android || exit
mkdir -p studio-data/profile/.android || exit
mkdir -p studio-data/profile/.java || exit
mkdir -p studio-data/profile/.gradle || exit
docker build -t deadolus/android-studio . || exit
