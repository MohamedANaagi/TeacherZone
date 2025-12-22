# تحديث iOS Firebase Configuration

## ⚠️ ملاحظة مهمة:

بعد تغيير iOS App ID من "class_code" إلى "TeacherZone"، يجب تحديث ملف `GoogleService-Info.plist` أيضاً.

## 📋 الخطوات المطلوبة:

### الخطوة 1: تحميل GoogleService-Info.plist الجديد

1. اذهب إلى [Firebase Console](https://console.firebase.google.com/)
2. اختر مشروعك: **teacherzone-eb4fb**
3. Settings → Project settings
4. في قسم **Your apps** → اختر **TeacherZone** (iOS app)
5. اضغط على زر **GoogleService-Info.plist** (زر التحميل)
6. استبدل الملف القديم في: `ios/Runner/GoogleService-Info.plist`

### الخطوة 2: التحقق من Bundle ID في Xcode

تأكد من أن Bundle ID في Xcode project يطابق `com.example.teacherzone`:

1. افتح `ios/Runner.xcworkspace` في Xcode
2. اختر **Runner** في Project Navigator
3. اختر **Runner** target
4. في تبويب **General** → **Identity**
5. تأكد من أن **Bundle Identifier** = `com.example.teacherzone`

## ✅ التأثيرات:

### ✅ لن يتأثر:
- **Firebase Data**: جميع البيانات في Firestore و Storage لن تتأثر (نفس Project ID)
- **Android**: لن يتأثر
- **Web**: لن يتأثر
- **الكود**: لا حاجة لتغيير أي كود

### ⚠️ قد يحتاج:
- **إعادة بناء التطبيق**: قد تحتاج إلى `flutter clean` ثم `flutter build ios`
- **إعادة تثبيت**: إذا كان التطبيق مثبت على جهاز، قد تحتاج إعادة تثبيت
- **تحديث GoogleService-Info.plist**: **مهم جداً** - يجب تحديثه

## 🔍 التحقق:

بعد التحديث، تأكد من:
- ✅ `firebase_options.dart` يحتوي على App ID الجديد
- ✅ `GoogleService-Info.plist` يحتوي على GOOGLE_APP_ID الجديد
- ✅ Bundle ID في Xcode = `com.example.teacherzone`

