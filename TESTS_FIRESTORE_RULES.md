# قواعد Firestore للاختبارات - Tests Firestore Rules

## ملخص القواعد المضافة

تم إضافة قواعد الأمان للـ Collections التالية:

### 1. Collection: `tests`
**القراءة:** ✅ للجميع (الطلاب يحتاجون رؤية الاختبارات)

**الكتابة:**
- ✅ `create`: مع التحقق من صحة البيانات (`isValidTest`)
- ✅ `update`: مع التحقق من صحة البيانات + منع تغيير `createdAt` و `adminCode`
- ✅ `delete`: مسموح (يمكن تقييده لاحقاً)

### 2. Collection: `questions`
**القراءة:** ✅ للجميع (الطلاب يحتاجون رؤية الأسئلة)

**الكتابة:**
- ✅ `create`: مع التحقق من صحة البيانات (`isValidQuestion`) + التأكد من وجود الاختبار
- ✅ `update`: مع التحقق من صحة البيانات + منع تغيير `testId`
- ✅ `delete`: مسموح (يمكن تقييده لاحقاً)

### 3. Collection: `testResults`
**القراءة:** ✅ للجميع (يمكن تقييدها لاحقاً للطالب نفسه فقط)

**الكتابة:**
- ✅ `create`: مع التحقق من صحة البيانات (`isValidTestResult`) + التأكد من وجود الاختبار
- ✅ `update`: مع التحقق من صحة البيانات + منع تغيير `testId` و `studentCode` و `completedAt`
- ✅ `delete`: مسموح (يمكن تقييده لاحقاً)

---

## Helper Functions المضافة

### `isValidTest(data)`
التحقق من صحة بيانات الاختبار:
- ✅ `title` (string, غير فارغ)
- ✅ `description` (string, غير فارغ)
- ✅ `adminCode` (string, غير فارغ)
- ✅ `createdAt` (string)
- ✅ `questionsCount` (int, >= 0)

### `isValidQuestion(data)`
التحقق من صحة بيانات السؤال:
- ✅ `testId` (string, غير فارغ)
- ✅ `questionText` (string, غير فارغ)
- ✅ `options` (list, على الأقل خيارين)
- ✅ `correctAnswerIndex` (int, بين 0 وعدد الخيارات)
- ✅ `order` (int, >= 0)

### `isValidTestResult(data)`
التحقق من صحة بيانات نتيجة الاختبار:
- ✅ `testId` (string, غير فارغ)
- ✅ `studentCode` (string, غير فارغ)
- ✅ `totalQuestions` (int, > 0)
- ✅ `correctAnswers` (int, >= 0)
- ✅ `wrongAnswers` (int, >= 0)
- ✅ `score` (number, بين 0 و 100)
- ✅ `completedAt` (string)
- ✅ `answers` (map)

---

## كيفية نشر القواعد

### الطريقة 1: استخدام Firebase CLI

```bash
# تأكد من تسجيل الدخول
firebase login

# نشر القواعد
firebase deploy --only firestore:rules
```

### الطريقة 2: من Firebase Console

1. افتح [Firebase Console](https://console.firebase.google.com/)
2. اختر مشروعك
3. اذهب إلى **Firestore Database**
4. اضغط على تبويب **Rules**
5. انسخ محتوى ملف `firestore.rules`
6. الصق في محرر القواعد
7. اضغط **Publish**

---

## ملاحظات الأمان

### ✅ ما تم تطبيقه:
- التحقق من صحة جميع الحقول المطلوبة
- منع تغيير الحقول الحساسة (`createdAt`, `adminCode`, `testId`, `studentCode`)
- التأكد من وجود الاختبار قبل إضافة سؤال أو نتيجة
- التحقق من أن `correctAnswerIndex` صحيح (ضمن نطاق الخيارات)
- التحقق من أن `score` بين 0 و 100

### ⚠️ تحسينات مستقبلية محتملة:
1. **تقييد القراءة:**
   - `testResults`: تقييد القراءة للطالب نفسه فقط
   - `tests`: تقييد القراءة حسب `adminCode` (للأدمن فقط)

2. **تقييد الكتابة:**
   - `tests`: تقييد الإنشاء/التعديل/الحذف للأدمن فقط (بناءً على `adminCode`)
   - `questions`: تقييد الإنشاء/التعديل/الحذف للأدمن فقط
   - `testResults`: تقييد الإنشاء للطالب نفسه فقط

3. **إضافة Authentication:**
   - استخدام Firebase Authentication للتحقق من هوية المستخدم
   - ربط `adminCode` و `studentCode` بـ `uid` من Firebase Auth

---

## اختبار القواعد

يمكنك اختبار القواعد من Firebase Console:

1. اذهب إلى **Firestore Database** > **Rules**
2. اضغط على **Rules Playground**
3. اختر Collection و Operation
4. أدخل البيانات المطلوبة
5. اضغط **Run** لاختبار القاعدة

---

## أمثلة على البيانات الصحيحة

### Test:
```json
{
  "title": "اختبار القدرات الكمية",
  "description": "اختبار شامل",
  "adminCode": "ADMIN001",
  "createdAt": "2024-01-15T10:00:00Z",
  "questionsCount": 5
}
```

### Question:
```json
{
  "testId": "1234567890",
  "questionText": "ما هو ناتج: 15 + 27؟",
  "options": ["40", "42", "44", "46"],
  "correctAnswerIndex": 1,
  "order": 0
}
```

### Test Result:
```json
{
  "testId": "1234567890",
  "studentCode": "STUDENT001",
  "totalQuestions": 5,
  "correctAnswers": 4,
  "wrongAnswers": 1,
  "score": 80.0,
  "completedAt": "2024-01-15T11:00:00Z",
  "answers": {
    "questionId1": 1,
    "questionId2": 2
  }
}
```

---

## الدعم

إذا واجهت أي مشاكل في القواعد، تأكد من:
1. ✅ صحة تنسيق البيانات
2. ✅ وجود جميع الحقول المطلوبة
3. ✅ صحة أنواع البيانات
4. ✅ وجود الاختبار قبل إضافة سؤال أو نتيجة

