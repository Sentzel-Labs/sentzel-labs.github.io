#!/bin/bash
set -e

echo "Reading versions.json..."
ACTIVE_VERSION=$(node -pe "JSON.parse(require('fs').readFileSync('versions.json')).active")
VERSION_PATH=$(node -pe "JSON.parse(require('fs').readFileSync('versions.json')).versions['$ACTIVE_VERSION'].path")
BUILD_CMD=$(node -pe "JSON.parse(require('fs').readFileSync('versions.json')).versions['$ACTIVE_VERSION'].buildCommand")
OUTPUT_DIR=$(node -pe "JSON.parse(require('fs').readFileSync('versions.json')).versions['$ACTIVE_VERSION'].outputDir")

echo "Active version: $ACTIVE_VERSION"
echo "Version path: $VERSION_PATH"
echo "Build command: $BUILD_CMD"
echo "Output directory: $OUTPUT_DIR"

# Navigate to version directory
cd "$VERSION_PATH"

# Clean install to fix rollup optional dependencies
echo "Cleaning npm cache and dependencies..."
rm -rf node_modules package-lock.json

# Run build command
echo "Building version $ACTIVE_VERSION..."
eval "$BUILD_CMD"

# Go back to root
cd ../..

# Create dist directory
rm -rf dist
mkdir -p dist

# Copy built files to dist
echo "Copying built files to dist..."
cp -r "$VERSION_PATH/$OUTPUT_DIR"/* dist/

# Create version info file
echo "{\"version\": \"$ACTIVE_VERSION\", \"buildDate\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" > dist/version.json

echo "Build complete! Files are in ./dist"
