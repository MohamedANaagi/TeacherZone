# دليل إعداد Firebase للمشروع

## الخطوات المطلوبة

### 1. إنشاء مشروع Firebase

1. اذهب إلى [Firebase Console](https://console.firebase.google.com/)
2. انقر على "إضافة مشروع" (Add Project)
3. أدخل اسم المشروع: `TeacherZone` (أو أي اسم تفضله)
4. اختر/أنشئ حساب Google Analytics (اختياري)
5. انقر على "إنشاء المشروع" (Create Project)
6. انتظر حتى يكتمل الإنشاء ثم انقر "متابعة" (Continue)

### 2. إضافة تطبيق Android

1. في صفحة المشروع، انقر على أيقونة Android
2. أدخل اسم الحزمة (Package name): ابحث في ملف `android/app/build.gradle.kts` عن `applicationId`
   - يجب أن يكون: `com.example.teacherzone` (مطابق لما في ملف `google-services.json`)
3. أدخل اسم التطبيق (App nickname): `TeacherZone` (اختياري)
4. انقر "تسجيل التطبيق" (Register app)
5. **حمل ملف `google-services.json`**
6. ضع الملف في المسار: `android/app/google-services.json`
7. في ملف `android/settings.gradle.kts`، أضف في قسم `plugins`:
   ```kotlin
   plugins {
       // ... plugins الأخرى
       id("com.google.gms.google-services") version "4.4.0" apply false
   }
   ```
8. في ملف `android/app/build.gradle.kts`، أضف في قسم `plugins`:
   ```kotlin
   plugins {
       id("com.android.application")
       id("kotlin-android")
       id("dev.flutter.flutter-gradle-plugin")
       id("com.google.gms.google-services")  // أضف هذا السطر
   }
   ```

### 3. إضافة تطبيق iOS (إذا كنت تستخدم iOS)

1. في صفحة المشروع، انقر على أيقونة iOS
2. أدخل Bundle ID: ابحث في Xcode أو في `ios/Runner.xcodeproj/project.pbxproj` عن `PRODUCT_BUNDLE_IDENTIFIER`
   - يجب أن يكون: `com.example.classCode` (مطابق لما في ملف `GoogleService-Info.plist`)
3. أدخل اسم التطبيق (App nickname): `TeacherZone` (اختياري)
4. انقر "تسجيل التطبيق" (Register app)
5. **حمل ملف `GoogleService-Info.plist`**
6. ضع الملف في المسار: `ios/Runner/GoogleService-Info.plist`
7. في Xcode، تأكد من إضافة الملف إلى المشروع

**مهم**: في Flutter، Firebase يتم تهيئته فقط في `main.dart` وليس في `AppDelegate.swift`. تأكد من عدم وجود `FirebaseApp.configure()` في AppDelegate.

### 4. تفعيل Cloud Firestore

1. في Firebase Console، من القائمة الجانبية، انقر "Firestore Database"
2. انقر "إنشاء قاعدة البيانات" (Create Database)
3. اختر "ابدأ في وضع الاختبار" (Start in test mode) - يمكنك تعديل القواعد لاحقاً
4. اختر موقع قاعدة البيانات (Location) - اختر الأقرب لمنطقتك
5. انقر "تمكين" (Enable)

**مهم**: بعد تفعيل Firestore، يجب تطبيق Security Rules. راجع ملف `FIRESTORE_RULES_GUIDE.md` للتعليمات.

### 5. إنشاء Collections في Firestore

بعد تفعيل Firestore، ستحتاج لإنشاء Collections التالية:

#### Collection: `codes`

يحتوي على أكواد الوصول:

- `code` (string) - الكود
- `description` (string) - الوصف (اختياري)
- `createdAt` (string) - تاريخ الإنشاء

#### Collection: `courses`

يحتوي على الكورسات:

- `title` (string) - عنوان الكورس
- `description` (string) - الوصف
- `instructor` (string) - اسم المدرب
- `duration` (string) - المدة
- `lessonsCount` (number) - عدد الدروس (يتم تحديثه تلقائياً)
- `createdAt` (string) - تاريخ الإنشاء

#### Collection: `videos`

يحتوي على الفيديوهات:

- `courseId` (string) - معرف الكورس
- `title` (string) - عنوان الفيديو
- `url` (string) - رابط الفيديو
- `description` (string) - الوصف (اختياري)
- `duration` (string) - مدة الفيديو
- `createdAt` (string) - تاريخ الإنشاء

### 6. تثبيت Dependencies

قم بتشغيل الأمر:

```bash
flutter pub get
```

### 7. تثبيت Pods لـ iOS

بعد إضافة Firebase dependencies، قم بتشغيل:

```bash
cd ios
pod install
cd ..
```

**مهم جداً**: بعد أي تعديل على Podfile أو إضافة Firebase، يجب تشغيل `pod install`

### 8. إنشاء ملف firebase_options.dart (اختياري)

إذا كنت تريد استخدام Firebase CLI:

```bash
flutterfire configure
```

أو يمكنك استخدام الإعداد اليدوي كما هو موضح أعلاه.

## ملاحظات مهمة

1. **Security Rules**: تأكد من تعديل Firestore Security Rules لاحقاً لتأمين البيانات
2. **Testing**: يمكنك البدء بوضع الاختبار (Test Mode) للتطوير، ثم تعديل القواعد لاحقاً
3. **Backup**: احتفظ بنسخة احتياطية من ملفات `google-services.json` و `GoogleService-Info.plist`

## بعد الإعداد

بعد إكمال جميع الخطوات:

1. قم بتشغيل التطبيق
2. تأكد من عدم وجود أخطاء في Console
3. جرّب إضافة كود أو كورس من لوحة الإدارة
4. تحقق من Firestore Console لرؤية البيانات المضافة

## Troubleshooting

إذا واجهت مشاكل:

### مشاكل iOS:

- **التطبيق يتوقف أو يطول في البداية**: تأكد من وجود `FirebaseApp.configure()` في `AppDelegate.swift`
- **Build errors**: قم بتشغيل `cd ios && pod install && cd ..`
- **Bundle ID mismatch**: تأكد من تطابق Bundle ID في `project.pbxproj` مع `GoogleService-Info.plist`
- **Pods errors**: احذف `ios/Pods` و `ios/Podfile.lock` ثم شغل `pod install` مرة أخرى

### مشاكل عامة:

- تأكد من وضع ملفات الإعداد في المسارات الصحيحة
- تأكد من تطابق Package Name / Bundle ID
- تأكد من تثبيت جميع Dependencies (`flutter pub get`)
- راجع الأخطاء في Console
- جرب `flutter clean` ثم `flutter pub get`
