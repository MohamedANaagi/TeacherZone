# التحقق من قواعد Firebase Storage

## المشكلة:
```
[firebase_storage/unauthenticated] User is unauthenticated
```

## الحل خطوة بخطوة:

### الخطوة 1: افتح Firebase Console
1. اذهب إلى: https://console.firebase.google.com/
2. اختر مشروع: **teacherzone-eb4fb**

### الخطوة 2: افتح Storage Rules
1. من القائمة الجانبية: **Storage**
2. اضغط على تبويب **Rules** (في الأعلى بجانب Files)

### الخطوة 3: تحقق من القواعد الحالية
- **يجب أن ترى هذا الكود بالضبط:**

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

### الخطوة 4: إذا كانت القواعد مختلفة
1. **احذف كل القواعد الموجودة**
2. **انسخ القواعد أعلاه بالكامل**
3. **الصقها في Firebase Console**
4. **اضغط على زر Publish** (أزرق في الأعلى)
5. **انتظر رسالة "Rules published successfully"**

### الخطوة 5: التحقق من التطبيق
1. انتظر **60 ثانية** بعد Publish
2. أعد تشغيل التطبيق بالكامل (Hot Restart)
3. جرّب رفع صورة مرة أخرى

---

## إذا استمرت المشكلة:

### 1. تحقق من أنك في المشروع الصحيح
- يجب أن يكون: **teacherzone-eb4fb**
- تحقق من الـ URL في المتصفح

### 2. تحقق من أن Storage مفعّل
- Firebase Console > Storage
- يجب أن ترى "Storage is enabled"

### 3. جرّب قواعد مختلفة (اختبار)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```
⚠️ **تحذير:** هذه القواعد تسمح بالوصول الكامل - استخدمها فقط للاختبار!

### 4. تحقق من Console Logs
- افتح Console في Xcode
- ابحث عن "Rules published" أو أي رسائل خطأ

---

## صورة توضيحية:

```
Firebase Console
  └─ Storage (القائمة الجانبية)
      └─ Rules (تبويب في الأعلى)
          └─ [يجب أن ترى القواعد هنا]
          └─ [Publish] ← اضغط هنا!
```

---

## ملاحظات مهمة:

1. **يجب الضغط على Publish** - مجرد التعديل لا يكفي!
2. **انتظر 60 ثانية** بعد Publish
3. **أعد تشغيل التطبيق** بعد التحديث
4. **تأكد من أنك في المشروع الصحيح**

