# كيفية نشر Firestore Rules

## المشكلة

إذا ظهرت رسالة خطأ:
```
Missing or insufficient permissions
```

هذا يعني أن Firestore Rules لم يتم نشرها بعد في Firebase Console.

## الحل: نشر Firestore Rules

### الطريقة الأولى: من Firebase Console (أسهل)

1. **افتح Firebase Console**
   - اذهب إلى [Firebase Console](https://console.firebase.google.com/)
   - اختر مشروعك

2. **اذهب إلى Firestore Database**
   - من القائمة الجانبية، اختر **Firestore Database**

3. **اذهب إلى Rules**
   - اضغط على تبويب **Rules** في الأعلى

4. **انسخ محتوى ملف `firestore.rules`**
   - افتح ملف `firestore.rules` من المشروع
   - انسخ كل المحتوى

5. **الصق في Firebase Console**
   - الصق المحتوى في محرر Rules في Firebase Console

6. **نشر Rules**
   - اضغط على **Publish** في الأعلى
   - انتظر حتى تظهر رسالة "Rules published successfully"

---

### الطريقة الثانية: من Terminal (للمحترفين)

1. **تثبيت Firebase CLI** (إذا لم يكن مثبتاً):
   ```bash
   npm install -g firebase-tools
   ```

2. **تسجيل الدخول**:
   ```bash
   firebase login
   ```

3. **الانتقال لمجلد المشروع**:
   ```bash
   cd /Users/mohamednagi/Documents/projects/TeacherZone
   ```

4. **نشر Rules**:
   ```bash
   firebase deploy --only firestore:rules
   ```

---

## التحقق من Rules المنشورة

1. **افتح Firebase Console**
2. **اذهب إلى Firestore Database → Rules**
3. **تأكد من أن Rules المحدثة موجودة**

---

## Rules المحدثة

تم تحديث Rules لتشمل:

### 1. Collection `adminCodes`:
- ✅ القراءة: مسموحة للجميع (لأن التحقق يحدث قبل تسجيل الدخول)
- ❌ الكتابة: محظورة (فقط من Firebase Console)

### 2. Collection `codes`:
- ✅ القراءة: مسموحة للجميع (لأن التحقق يحدث قبل تسجيل الدخول)
- ✅ الكتابة: مسموحة مع التحقق من `adminCode`

### 3. Collection `courses`:
- ✅ القراءة: مسموحة للجميع
- ✅ الكتابة: مسموحة مع التحقق من `adminCode`

### 4. Collection `videos`:
- ✅ القراءة: مسموحة للجميع
- ✅ الكتابة: مسموحة مع التحقق من `adminCode`

---

## ملاحظات مهمة

1. **بعد نشر Rules:**
   - قد يستغرق الأمر بضع دقائق حتى تصبح Rules فعالة
   - جرب التطبيق مرة أخرى بعد دقيقة أو دقيقتين

2. **إذا استمر الخطأ:**
   - تأكد من أن Rules تم نشرها بنجاح
   - تحقق من أن Collection `adminCodes` موجود في Firestore
   - تحقق من أن Collection `codes` يحتوي على Documents

3. **للأمان:**
   - Rules الحالية تسمح بالقراءة للجميع (لأن التحقق يحدث قبل تسجيل الدخول)
   - يمكنك تقييد القراءة لاحقاً إذا أردت

---

## الخلاصة

1. ✅ افتح Firebase Console
2. ✅ اذهب إلى Firestore Database → Rules
3. ✅ انسخ محتوى `firestore.rules`
4. ✅ الصق في Firebase Console
5. ✅ اضغط Publish
6. ✅ انتظر دقيقة وجرب التطبيق مرة أخرى

