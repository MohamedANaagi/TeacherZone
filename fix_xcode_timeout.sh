#!/bin/bash

# Script to fix Xcode debug session timeout issues

echo "🔧 Fixing Xcode debug session timeout..."

# Kill all Xcode and related processes
echo "📱 Stopping all Xcode processes..."
killall Xcode 2>/dev/null || true
killall xcodebuild 2>/dev/null || true
killall com.apple.CoreSimulator.CoreSimulatorService 2>/dev/null || true
killall Simulator 2>/dev/null || true

# Wait for processes to terminate
sleep 3

# Navigate to project directory
cd "$(dirname "$0")"

# Clean Flutter build
echo "🧹 Cleaning Flutter build..."
flutter clean

# Clean iOS build folder
echo "🗑️  Cleaning iOS build artifacts..."
rm -rf ios/build
rm -rf build/ios

# Clean Xcode derived data more forcefully
echo "🗑️  Cleaning Xcode derived data..."
if [ -d ~/Library/Developer/Xcode/DerivedData ]; then
    find ~/Library/Developer/Xcode/DerivedData -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} + 2>/dev/null || true
fi

# Clean CocoaPods cache
echo "🧹 Cleaning CocoaPods..."
cd ios
rm -rf Pods Podfile.lock .symlinks
cd ..

# Reinstall dependencies
echo "📦 Reinstalling dependencies..."
flutter pub get
cd ios && pod install && cd ..

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Make sure Xcode is completely closed"
echo "2. Unlock your iOS device if it's locked"
echo "3. Trust the computer on your device if prompted"
echo "4. Run: flutter run"
echo ""
echo "💡 If the issue persists, try:"
echo "   - Restarting your Mac"
echo "   - Disconnecting and reconnecting your device"
echo "   - Running from Xcode: open ios/Runner.xcworkspace"

