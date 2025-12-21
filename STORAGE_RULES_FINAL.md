# قواعد Firebase Storage - النسخة النهائية

## ⚠️ مهم جداً:
**قواعد Storage مختلفة تماماً عن قواعد Firestore!**

- **Firestore Rules** → في Firebase Console > Firestore Database > Rules
- **Storage Rules** → في Firebase Console > Storage > Rules ← **هنا المشكلة!**

---

## القواعد المطلوبة لـ Storage:

### افتح Firebase Console:
1. https://console.firebase.google.com/
2. اختر مشروع: **teacherzone-eb4fb**
3. **Storage** (من القائمة الجانبية - ليس Firestore!)
4. تبويب **Rules** (في الأعلى)

### انسخ هذا الكود بالكامل:

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

### خطوات التطبيق:
1. **احذف كل القواعد الموجودة** في Storage Rules
2. **الصق القواعد أعلاه**
3. **اضغط Publish** (أزرق في الأعلى)
4. **انتظر 60 ثانية**
5. **أعد تشغيل التطبيق**

---

## الفرق بين Firestore و Storage:

### Firestore Rules (موجودة وصحيحة ✅):
```
Firebase Console > Firestore Database > Rules
```
- هذه للبيانات (codes, courses, videos)
- موجودة وصحيحة

### Storage Rules (هذه المشكلة ❌):
```
Firebase Console > Storage > Rules
```
- هذه للملفات (الصور، الفيديوهات)
- **يجب تحديثها!**

---

## التحقق من التطبيق:

بعد تطبيق القواعد:
1. انتظر 60 ثانية
2. Hot Restart للتطبيق
3. جرّب رفع صورة
4. يجب أن ترى: "تم رفع الصورة بنجاح" ✅

---

## إذا استمرت المشكلة:

### قواعد مؤقتة للاختبار (تسمح بكل شيء):

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

⚠️ **استخدمها فقط للاختبار!**

---

## ملاحظات:

1. **Storage Rules ≠ Firestore Rules**
2. يجب تطبيق القواعد في **Storage > Rules** وليس Firestore
3. يجب الضغط على **Publish**
4. انتظر 60 ثانية بعد Publish

