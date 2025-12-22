# إعداد Firebase للويب - خطوات الإعداد

## ✅ ما تم إضافته تلقائياً:

1. ✅ إضافة Firebase Web configuration في `firebase_options.dart`
2. ✅ إضافة Firebase SDK scripts في `web/index.html`

## 📋 الخطوات المطلوبة منك:

### الخطوة 1: الحصول على Web App ID من Firebase Console

1. اذهب إلى [Firebase Console](https://console.firebase.google.com/)
2. اختر مشروعك: **teacherzone-eb4fb**
3. اضغط على أيقونة **⚙️ Settings** (الإعدادات) بجانب "Project Overview"
4. اختر **Project settings**
5. انتقل إلى تبويب **General**
6. ابحث عن قسم **Your apps** وابحث عن تطبيق الويب (Web app)
   - إذا لم يكن موجوداً، اضغط على **Add app** → اختر **Web** (</>) → سجل اسم التطبيق → اضغط **Register app**
7. انسخ **App ID** (يبدو مثل: `1:420503435906:web:abc123def456`)

### الخطوة 2: تحديث firebase_options.dart

افتح ملف `lib/firebase_options.dart` وابحث عن:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyAm3qGN3GWJ9aEPtE8UCW4iijnnfeUDr7g',
  appId: '1:420503435906:web:YOUR_WEB_APP_ID', // ← استبدل هذا
  ...
);
```

استبدل `YOUR_WEB_APP_ID` بـ **App ID** الذي نسخته من Firebase Console.

### الخطوة 3: (اختياري) الحصول على Measurement ID

إذا كنت تستخدم Firebase Analytics:

1. في Firebase Console → **Project settings** → **General**
2. ابحث عن **Measurement ID** في قسم **Your apps** → Web app
3. انسخ الـ ID (يبدو مثل: `G-XXXXXXXXXX`)
4. استبدل `G-YOUR_MEASUREMENT_ID` في `firebase_options.dart`

### الخطوة 4: اختبار التطبيق على الويب

```bash
# تشغيل التطبيق على الويب
flutter run -d chrome

# أو بناء التطبيق للويب
flutter build web
```

## 🔍 ملاحظات مهمة:

1. **API Key**: يمكنك استخدام نفس API Key من Android أو الحصول على واحد جديد للويب من Firebase Console
2. **Auth Domain**: تم إضافته تلقائياً بناءً على projectId
3. **Storage Bucket**: نفس الـ bucket المستخدم في Android/iOS

## ✅ بعد إكمال الخطوات:

- Firebase سيعمل على الويب بنفس الطريقة التي يعمل بها على Android/iOS
- جميع الميزات (Firestore, Storage) ستعمل على الويب
- لا حاجة لتغيير أي كود آخر في التطبيق

## 🐛 حل المشاكل:

إذا واجهت مشاكل:

1. تأكد من أن Web App ID صحيح
2. تأكد من أن Firebase SDK scripts تم تحميلها في `index.html`
3. افتح Developer Console في المتصفح (F12) للتحقق من الأخطاء
4. تأكد من أن Firebase services (Firestore, Storage) مفعلة في Firebase Console
