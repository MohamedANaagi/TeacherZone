# إعداد Firebase للمشروع | Firebase Setup Guide

## الخطوات المطلوبة لإعداد Firebase

### 1. إنشاء مشروع Firebase

1. اذهب إلى [Firebase Console](https://console.firebase.google.com/)
2. اضغط على "Add project" أو "إضافة مشروع"
3. أدخل اسم المشروع (مثلاً: TeacherZone)
4. اتبع الخطوات لإكمال إنشاء المشروع

### 2. إضافة تطبيق Android

1. في Firebase Console، اضغط على أيقونة Android
2. أدخل Package name من `android/app/build.gradle` (مثلاً: `com.example.class_code`)
3. قم بتحميل ملف `google-services.json`
4. ضع الملف في `android/app/google-services.json`

### 3. إضافة تطبيق iOS

1. في Firebase Console، اضغط على أيقونة iOS
2. أدخل Bundle ID من `ios/Runner.xcodeproj` (مثلاً: `com.example.classCode`)
3. قم بتحميل ملف `GoogleService-Info.plist`
4. ضع الملف في `ios/Runner/GoogleService-Info.plist`

### 4. تفعيل Authentication في Firebase

1. في Firebase Console، اذهب إلى **Authentication**
2. اضغط على **Get Started**
3. في **Sign-in method**، فعّل:
   - **Email/Password** (للتسجيل باستخدام البريد الإلكتروني)

### 5. إنشاء Firestore Database

1. في Firebase Console، اذهب إلى **Firestore Database**
2. اضغط على **Create database**
3. اختر **Start in test mode** (للاختبار)
4. اختر موقع قاعدة البيانات (مثلاً: `us-central1`)

### 6. إعداد Firestore Collections

أنشئ collection باسم `access_codes` مع الوثائق التالية:

```javascript
// مثال على وثيقة في collection access_codes
{
  code: "ABC123",  // الكود
  isUsed: false,   // هل تم استخدامه
  expiresAt: Timestamp,  // تاريخ انتهاء الصلاحية (اختياري)
  subscriptionEndDate: Timestamp,  // تاريخ انتهاء الاشتراك
  createdAt: Timestamp,  // تاريخ الإنشاء
  usedBy: null,  // ID المستخدم الذي استخدمه (اختياري)
  usedAt: null   // تاريخ الاستخدام (اختياري)
}
```

### 7. تثبيت Dependencies

```bash
flutter pub get
```

### 8. إنشاء Firebase Options (اختياري)

إذا كنت تريد استخدام `flutterfire_cli`:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

هذا سينشئ ملف `lib/firebase_options.dart` تلقائياً.

### 9. تحديث FirebaseService

ملاحظة: في `FirebaseService.signInWithCode`، يتم استخدام الكود ككلمة مرور مؤقتة.
في الإنتاج، يجب استخدام طريقة أفضل مثل:

- Custom Token Authentication
- Phone Authentication
- أو التحقق من الكود في Firestore ثم إنشاء حساب

### 10. اختبار التطبيق

1. شغّل التطبيق
2. أدخل كود صحيح من Firestore
3. تأكد من تسجيل الدخول بنجاح

## هيكل Firestore

```
Firestore
├── access_codes/
│   └── {code}/
│       ├── isUsed: boolean
│       ├── expiresAt: Timestamp (optional)
│       ├── subscriptionEndDate: Timestamp
│       ├── createdAt: Timestamp
│       ├── usedBy: string (optional)
│       └── usedAt: Timestamp (optional)
│
└── users/
    └── {userId}/
        ├── name: string
        ├── email: string
        ├── code: string
        ├── createdAt: Timestamp
        └── subscriptionEndDate: Timestamp
```

## ملاحظات أمنية

⚠️ **مهم**: في الإنتاج، يجب:

1. استخدام Firestore Security Rules لحماية البيانات
2. عدم استخدام الكود ككلمة مرور
3. إضافة rate limiting لمنع الهجمات
4. استخدام Custom Token Authentication أو Phone Auth

## Security Rules مثال

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Access codes collection
    match /access_codes/{codeId} {
      allow read: if request.auth != null;
      allow write: if false; // فقط من خلال Cloud Functions
    }
  }
}
```
