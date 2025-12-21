#!/bin/bash

# Script to launch the app from Xcode instead of Flutter CLI
# This can help avoid timeout issues

echo "🚀 Preparing to launch from Xcode..."

cd "$(dirname "$0")"

# Make sure Xcode is closed
killall Xcode 2>/dev/null || true
sleep 2

# Open the workspace
echo "📱 Opening Xcode workspace..."
open ios/Runner.xcworkspace

echo ""
echo "✅ Xcode should now be opening."
echo ""
echo "📝 In Xcode:"
echo "1. Select your device from the device dropdown (top toolbar)"
echo "2. Click the Play button (▶️) or press Cmd+R"
echo "3. Wait for the app to build and launch"
echo ""
echo "💡 This method often works better when Flutter CLI has timeout issues."

