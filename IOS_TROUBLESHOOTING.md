# حل مشاكل iOS مع Firebase

## المشكلة: التطبيق يطول أو لا يعمل على iOS Simulator

### الحلول المطبقة:

1. ✅ **إزالة التهيئة المزدوجة لـ Firebase**

   - تم إزالة `FirebaseApp.configure()` من `AppDelegate.swift`
   - Firebase يتم تهيئته فقط في `main.dart` (كما يجب في Flutter)

2. ✅ **تحديث Podfile**
   - تم تفعيل `platform :ios, '13.0'`
   - تم إضافة إعدادات iOS deployment target في post_install

## خطوات الحل:

### 1. تنظيف المشروع بالكامل:

```bash
# تنظيف Flutter
flutter clean

# تنظيف iOS pods
cd ios
rm -rf Pods Podfile.lock .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
cd ..

# تنظيف build folders
rm -rf build ios/build
```

### 2. إعادة التثبيت:

```bash
# تثبيت Flutter dependencies
flutter pub get

# إعادة تثبيت iOS pods
cd ios
pod deintegrate
pod install
cd ..
```

### 3. تشغيل التطبيق:

```bash
flutter run
```

## إذا استمرت المشكلة:

### حل 1: حذف Derived Data

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
```

ثم أعد تشغيل Xcode و Flutter.

### حل 2: التحقق من Firebase Configuration

1. تأكد من وجود `GoogleService-Info.plist` في `ios/Runner/`
2. تأكد من أن Bundle ID في `GoogleService-Info.plist` يطابق `PRODUCT_BUNDLE_IDENTIFIER` في Xcode
3. افتح Xcode: `open ios/Runner.xcworkspace`
4. تأكد من أن `GoogleService-Info.plist` موجود في Build Phases > Copy Bundle Resources

### حل 3: التحقق من Firestore Rules

تأكد من أن Firestore Rules تسمح بالقراءة والكتابة (على الأقل للاختبار):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // للاختبار فقط
    }
  }
}
```

### حل 4: فحص Console Logs

شغل التطبيق من Xcode لرؤية الأخطاء بالتفصيل:

```bash
open ios/Runner.xcworkspace
```

ثم اضغط Run من Xcode وافحص Console للأخطاء.

### حل 5: إعادة بناء كامل

```bash
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod install
cd ..
flutter pub get
flutter run --verbose
```

## ملاحظات مهمة:

1. ⚠️ **لا تهيئ Firebase مرتين**: فقط في `main.dart`، وليس في `AppDelegate.swift`
2. ✅ **استخدم `.xcworkspace`**: افتح `Runner.xcworkspace` وليس `Runner.xcodeproj`
3. 🔄 **بعد أي تعديل على Podfile**: دائماً شغل `pod install`
4. 📱 **iOS Simulator**: تأكد من أن Simulator يعمل بشكل صحيح قبل تشغيل التطبيق

## المشاكل الشائعة:

### "Firebase initialization error"

- تأكد من وجود `GoogleService-Info.plist`
- تأكد من صحة Bundle ID

### "Module 'FirebaseCore' not found"

- شغل `pod install` مرة أخرى
- تأكد من فتح `.xcworkspace` وليس `.xcodeproj`

### "App hangs on launch"

- تأكد من إزالة `FirebaseApp.configure()` من AppDelegate.swift
- تحقق من Firestore Rules
