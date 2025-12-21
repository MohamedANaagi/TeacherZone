# حل مشكلة "unauthenticated" في Firebase Storage

## المشكلة:
```
خطأ في Firebase Storage: unauthenticated - User is unauthenticated
```

## الحل السريع (5 دقائق):

### الخطوة 1: افتح Firebase Console
1. اذهب إلى: https://console.firebase.google.com/
2. اختر مشروعك

### الخطوة 2: افتح Storage Rules
1. من القائمة الجانبية، اضغط على **Storage**
2. اضغط على تبويب **Rules** (في الأعلى)

### الخطوة 3: انسخ القواعد التالية

**انسخ هذا الكود بالكامل:**

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{imageId} {
      allow read: if true;
      allow write: if true;
    }
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

### الخطوة 4: الصق القواعد
1. احذف كل القواعد الموجودة
2. الصق القواعد الجديدة التي نسختها
3. اضغط على زر **Publish** (أزرق في الأعلى)

### الخطوة 5: انتظر قليلاً
- انتظر 10-30 ثانية حتى يتم تطبيق القواعد

### الخطوة 6: جرّب التطبيق
1. أعد تشغيل التطبيق (Hot Restart)
2. جرّب رفع صورة بروفايل مرة أخرى

---

## التحقق من نجاح الحل:

بعد تطبيق القواعد، يجب أن ترى:
- ✅ رسالة "تم رفع الصورة بنجاح"
- ✅ الصورة تظهر في Firebase Console > Storage > Files
- ✅ رابط الصورة يظهر في Firestore > codes collection

---

## إذا استمرت المشكلة:

### 1. تحقق من أن Storage مفعّل
- Firebase Console > Storage
- يجب أن ترى "Storage is enabled"

### 2. تحقق من القواعد
- تأكد من أن القواعد مطبقة (يجب أن ترى القواعد الجديدة)
- تأكد من الضغط على **Publish**

### 3. تحقق من المشروع
- تأكد من أنك في المشروع الصحيح
- تأكد من أن التطبيق متصل بنفس المشروع

---

## صورة توضيحية للخطوات:

```
Firebase Console
  └─ Storage (من القائمة الجانبية)
      └─ Rules (تبويب في الأعلى)
          └─ [الصق القواعد هنا]
          └─ [اضغط Publish]
```

---

## ملفات مساعدة:

- `storage.rules` - ملف القواعد الجاهز للنسخ
- `FIREBASE_STORAGE_SETUP.md` - دليل شامل

---

**ملاحظة مهمة:** القواعد الجديدة تسمح للجميع برفع الصور بدون authentication. هذا مناسب للتطبيق الحالي الذي لا يستخدم Firebase Authentication.

