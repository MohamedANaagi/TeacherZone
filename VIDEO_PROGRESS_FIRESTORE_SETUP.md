# إعداد Video Progress في Firestore

## المشكلة
عند الضغط على checkbox للفيديو، لا يتم حفظ التقدم في Firestore.

## الحل
تم إضافة قواعد أمان لـ collection `videoProgress` في ملف `firestore.rules`.

## خطوات النشر

### 1. نشر قواعد Firestore

#### الطريقة الأولى: من Firebase Console (أسهل)

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

#### الطريقة الثانية: من Terminal

```bash
# الانتقال لمجلد المشروع
cd /Users/mohamednagi/Documents/projects/TeacherZone

# نشر Rules
firebase deploy --only firestore:rules
```

---

## Collection `videoProgress`

### البنية (Structure)

```
videoProgress/
  └── {code}_{courseId}_{videoId}/
      ├── code: string          # كود المستخدم
      ├── courseId: string      # معرف الكورس
      ├── videoId: string       # معرف الفيديو
      ├── isWatched: boolean    # حالة المشاهدة (true/false)
      └── watchedAt: timestamp # وقت المشاهدة
```

### مثال Document ID
```
ABC123_course1_video1
```

حيث:
- `ABC123` = كود المستخدم
- `course1` = معرف الكورس
- `video1` = معرف الفيديو

---

## قواعد الأمان (Security Rules)

تم إضافة القواعد التالية لـ `videoProgress`:

### القراءة (Read)
- ✅ **مسموحة للجميع** - المستخدمون يحتاجون قراءة تقدمهم

### الكتابة (Write)
- ✅ **Create**: مسموح مع التحقق من وجود الحقول المطلوبة:
  - `code` (string)
  - `courseId` (string)
  - `videoId` (string)
  - `isWatched` (boolean)

- ✅ **Update**: مسموح مع التحقق من:
  - وجود جميع الحقول المطلوبة
  - عدم تغيير `code`, `courseId`, `videoId`

- ✅ **Delete**: مسموح (عند إلغاء حالة المشاهدة)

---

## التحقق من النشر

### 1. التحقق من Rules
- افتح Firebase Console
- اذهب إلى Firestore Database → Rules
- تأكد من وجود قواعد `videoProgress`

### 2. اختبار الحفظ
- افتح التطبيق
- اضغط على checkbox لأي فيديو
- اذهب إلى Firebase Console → Firestore Database
- ابحث عن collection `videoProgress`
- يجب أن ترى document جديد

### 3. اختبار المزامنة
- سجل خروج من الجهاز الأول
- سجل دخول من جهاز ثاني بنفس الكود
- يجب أن يظهر التقدم المحفوظ

---

## ملاحظات مهمة

1. **بعد نشر Rules:**
   - قد يستغرق الأمر بضع دقائق حتى تصبح Rules فعالة
   - جرب التطبيق مرة أخرى بعد دقيقة أو دقيقتين

2. **إذا استمر الخطأ:**
   - تأكد من أن Rules تم نشرها بنجاح
   - تحقق من Console في التطبيق لرؤية أي أخطاء
   - تأكد من وجود اتصال بالإنترنت

3. **للأمان:**
   - Rules الحالية تسمح بالقراءة والكتابة للجميع
   - يمكنك تقييد الوصول لاحقاً إذا أردت (مثلاً: فقط للمستخدمين المسجلين)

---

## الخلاصة

1. ✅ تم إضافة قواعد `videoProgress` في `firestore.rules`
2. ✅ يجب نشر Rules في Firebase Console
3. ✅ Collection `videoProgress` سيتم إنشاؤه تلقائياً عند أول حفظ
4. ✅ لا حاجة لإنشاء Collection يدوياً

---

## استكشاف الأخطاء

### الخطأ: "Missing or insufficient permissions"
- **السبب**: Rules لم يتم نشرها بعد
- **الحل**: انشر Rules من Firebase Console

### الخطأ: "Collection not found"
- **السبب**: Collection سيتم إنشاؤه تلقائياً عند أول حفظ
- **الحل**: لا حاجة لفعل شيء، فقط اضغط على checkbox

### الخطأ: "Failed to save video progress"
- **السبب**: مشكلة في الاتصال أو Rules
- **الحل**: 
  1. تحقق من اتصال الإنترنت
  2. تأكد من نشر Rules
  3. تحقق من Console للأخطاء

