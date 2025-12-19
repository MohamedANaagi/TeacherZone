# حل مشاكل Build في iOS

## الخطوات التالية لمعرفة سبب فشل Build:

### 1. محاولة Build مع تفاصيل الأخطاء:

شغل هذا الأمر في Terminal:

```bash
flutter build ios --verbose 2>&1 | tee build_errors.txt
```

ثم افتح ملف `build_errors.txt` لرؤية الأخطاء بالتفصيل.

### 2. محاولة Run مع تفاصيل:

```bash
flutter run -v 2>&1 | tee run_errors.txt
```

### 3. فحص iOS Build بشكل مباشر:

```bash
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' clean build 2>&1 | tee xcode_build_errors.txt
cd ..
```

### 4. التحقق من Pods:

```bash
cd ios
pod install --repo-update
pod deintegrate
pod install
cd ..
```

### 5. التحقق من Firebase Configuration:

تأكد من:

- ✅ وجود `GoogleService-Info.plist` في `ios/Runner/`
- ✅ Bundle ID صحيح في `GoogleService-Info.plist`
- ✅ `firebase_options.dart` موجود ويستخدم في `main.dart`

### 6. تنظيف شامل:

```bash
# تنظيف Flutter
flutter clean

# تنظيف iOS
cd ios
rm -rf Pods Podfile.lock .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
rm -rf build
cd ..

# تنظيف build folders
rm -rf build

# إعادة التثبيت
flutter pub get
cd ios
pod install
cd ..
```

## إذا كان Build يفشل:

### أرسل:

1. آخر سطور من `build_errors.txt` (الأخطاء الحمراء)
2. أو آخر 50 سطر من Terminal عند تشغيل `flutter run -v`

### الأخطاء الشائعة:

#### "No such module 'FirebaseCore'"

```bash
cd ios
pod install
cd ..
```

#### "GoogleService-Info.plist not found"

- تأكد من وجود الملف في `ios/Runner/GoogleService-Info.plist`
- تأكد من أنه مضاف في Xcode Build Phases

#### "Bundle ID mismatch"

- تأكد من تطابق Bundle ID في:
  - `ios/Runner.xcodeproj/project.pbxproj` (PRODUCT_BUNDLE_IDENTIFIER)
  - `ios/Runner/GoogleService-Info.plist` (BUNDLE_ID)
  - `lib/firebase_options.dart` (iosBundleId)
