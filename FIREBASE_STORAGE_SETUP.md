# إعداد Firebase Storage لرفع صور البروفايل

## الخطوات المطلوبة:

### 1. تفعيل Firebase Storage في Firebase Console

1. افتح [Firebase Console](https://console.firebase.google.com/)
2. اختر مشروعك
3. اذهب إلى **Storage** من القائمة الجانبية
4. اضغط على **Get Started** إذا لم يكن مفعلاً
5. اختر **Start in test mode** (يمكنك تغيير القواعد لاحقاً)

### 2. إعداد قواعد الأمان لـ Firebase Storage

**مهم جداً:** يجب تحديث قواعد Firebase Storage للسماح بالرفع بدون authentication.

افتح Firebase Console > Storage > Rules وأضف القواعد التالية:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // السماح بقراءة وكتابة صور البروفايل بدون authentication
    match /profile_images/{imageId} {
      // السماح للجميع بقراءة الصور
      allow read: if true;
      // السماح للجميع بكتابة الصور بدون authentication
      allow write: if true;
    }

    // منع الوصول لجميع الملفات الأخرى
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

**خطوات التطبيق:**

1. افتح Firebase Console
2. اختر مشروعك
3. اذهب إلى **Storage** > **Rules**
4. انسخ القواعد أعلاه
5. اضغط **Publish** لحفظ القواعد

**ملاحظة:** القواعد أعلاه تسمح للجميع برفع الصور بدون authentication. للإنتاج، يمكنك تقييد الصلاحيات بناءً على الكود أو معايير أخرى.

### 3. قواعد الأمان المقترحة للإنتاج (اختياري)

إذا أردت تقييد الصلاحيات لاحقاً، يمكنك استخدام:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{imageId} {
      // السماح بقراءة الصور للجميع
      allow read: if true;
      // السماح بكتابة الصور للجميع (لأننا لا نستخدم Firebase Auth)
      allow write: if true;

      // أو يمكنك التحقق من الكود في metadata
      // allow write: if request.resource.metadata.code != null;
    }
  }
}
```

**ملاحظة:** بما أن التطبيق لا يستخدم Firebase Authentication، يجب السماح بالكتابة بدون auth.

### 4. التحقق من التثبيت

بعد إعداد Firebase Storage:

1. تأكد من تثبيت الحزم:

   ```bash
   flutter pub get
   ```

2. أعد تشغيل التطبيق

3. جرب رفع صورة بروفايل

### 5. حل المشاكل الشائعة

#### خطأ "Permission denied"

- تحقق من قواعد Firebase Storage
- تأكد من تفعيل Storage في Firebase Console

#### خطأ "Unauthorized"

- تحقق من إعدادات Firebase في التطبيق
- تأكد من وجود `google-services.json` (Android) و `GoogleService-Info.plist` (iOS)

#### الصورة لا تظهر بعد الرفع

- تحقق من رابط الصورة في Firestore
- تأكد من أن الصورة رُفعت بنجاح في Firebase Console > Storage

### 6. مراقبة الاستخدام

يمكنك مراقبة استخدام Storage من:

- Firebase Console > Storage > Files
- Firebase Console > Storage > Usage
