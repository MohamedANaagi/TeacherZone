#!/bin/bash

# Script to fix Xcode concurrent build issues

echo "🔧 Fixing Xcode concurrent build issues..."

# Kill Xcode processes
echo "📱 Stopping Xcode processes..."
killall Xcode 2>/dev/null || true
killall xcodebuild 2>/dev/null || true
killall com.apple.CoreSimulator.CoreSimulatorService 2>/dev/null || true

# Wait a moment for processes to terminate
sleep 2

# Clean Flutter build
echo "🧹 Cleaning Flutter build..."
cd "$(dirname "$0")"
flutter clean

# Clean Xcode derived data
echo "🗑️  Cleaning Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*

echo "✅ Cleanup complete! You can now run 'flutter run' again."

