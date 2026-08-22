#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "============================================="
echo "Running Unit Tests CI Validator"
echo "============================================="

# Check if xcodebuild is available (to support non-Mac demo environments)
if ! command -v xcodebuild &> /dev/null; then
    echo "WARNING: 'xcodebuild' command not found. This runner is not a macOS runner."
    echo "Skipping iOS unit tests validation gracefully for demo purposes."
    echo "============================================="
    echo "Unit Tests Skipped (Demo Mode)!"
    echo "============================================="
    exit 0
fi

# 1. Quietly extract XCConfig if zip is present and folder is missing
XCCONFIG_DIR="$PROJECT_DIR/XCConfig"
XCCONFIG_ZIP="$PROJECT_DIR/XCConfig.zip"

if [ ! -d "$XCCONFIG_DIR" ]; then
    if [ -f "$XCCONFIG_ZIP" ]; then
        echo "XCConfig folder not found. Unzipping XCConfig.zip..."
        unzip -o -q "$XCCONFIG_ZIP" -d "$PROJECT_DIR"
    else
        echo "WARNING: XCConfig folder and XCConfig.zip are both missing."
        echo "Make sure build configurations are available or injected by CI."
    fi
fi

# 2. Resolve package dependencies
echo "Resolving Package Dependencies..."
xcodebuild -project "$PROJECT_DIR/TapCash.xcodeproj" -resolvePackageDependencies -quiet

# 3. Find available simulator compatible with our scheme's deployment target
echo "Detecting available iOS Simulator..."
# We try to get an eligible iPhone simulator ID from xcodebuild destinations
SIMULATOR_ID=$(xcodebuild -showdestinations -project "$PROJECT_DIR/TapCash.xcodeproj" -scheme TapCashPresentationTest | \
  grep "platform:iOS Simulator" | \
  grep "name:" | \
  grep "iPhone" | \
  head -n 1 | \
  sed -E 's/.*id:([^, ]+).*/\1/')

if [ -z "$SIMULATOR_ID" ]; then
    # Fallback to any eligible simulator (e.g. iPad)
    SIMULATOR_ID=$(xcodebuild -showdestinations -project "$PROJECT_DIR/TapCash.xcodeproj" -scheme TapCashPresentationTest | \
      grep "platform:iOS Simulator" | \
      grep "name:" | \
      head -n 1 | \
      sed -E 's/.*id:([^, ]+).*/\1/')
fi

if [ -z "$SIMULATOR_ID" ]; then
    echo "Error: No eligible iOS Simulator found for deployment target."
    exit 1
fi

echo "Selected Simulator ID: $SIMULATOR_ID"

# 4. Run tests
echo "Executing xcodebuild test..."
xcodebuild test \
  -project "$PROJECT_DIR/TapCash.xcodeproj" \
  -scheme TapCashPresentationTest \
  -configuration Debug-Development \
  -destination "id=$SIMULATOR_ID" \
  -disable-concurrent-testing

echo "============================================="
echo "Unit Tests Executed Successfully!"
echo "============================================="
