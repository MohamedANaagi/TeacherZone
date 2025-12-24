# هيكل Collections في Firestore للاختبارات

## Collections المطلوبة

### 1. Collection: `tests`

يحتوي على بيانات الاختبارات التي ينشئها الأدمن.

**Structure:**

```json
{
  "title": "عنوان الاختبار",
  "description": "وصف الاختبار",
  "adminCode": "كود الأدمن",
  "createdAt": "2024-01-01T00:00:00Z",
  "questionsCount": 10
}
```

**Fields:**

- `title` (String): عنوان الاختبار
- `description` (String): وصف الاختبار
- `adminCode` (String): كود الأدمن الذي أنشأ الاختبار
- `createdAt` (String): تاريخ الإنشاء (ISO 8601 format)
- `questionsCount` (Number): عدد الأسئلة في الاختبار

---

### 2. Collection: `questions`

يحتوي على الأسئلة المرتبطة بالاختبارات.

**Structure:**

```json
{
  "testId": "معرف الاختبار",
  "questionText": "نص السؤال",
  "options": ["الخيار 1", "الخيار 2", "الخيار 3", "الخيار 4"],
  "correctAnswerIndex": 0,
  "order": 0
}
```

**Fields:**

- `testId` (String): معرف الاختبار المرتبط به
- `questionText` (String): نص السؤال
- `options` (Array of String): قائمة الخيارات (اختيار متعدد)
- `correctAnswerIndex` (Number): فهرس الإجابة الصحيحة (0-based)
- `order` (Number): ترتيب السؤال في الاختبار

---

### 3. Collection: `testResults`

يحتوي على نتائج الاختبارات التي حلها الطلاب.

**Structure:**

```json
{
  "testId": "معرف الاختبار",
  "studentCode": "كود الطالب",
  "totalQuestions": 10,
  "correctAnswers": 8,
  "wrongAnswers": 2,
  "score": 80.0,
  "completedAt": "2024-01-01T00:00:00Z",
  "answers": {
    "questionId1": 0,
    "questionId2": 2,
    "questionId3": 1
  }
}
```

**Fields:**

- `testId` (String): معرف الاختبار
- `studentCode` (String): كود الطالب
- `totalQuestions` (Number): إجمالي عدد الأسئلة
- `correctAnswers` (Number): عدد الإجابات الصحيحة
- `wrongAnswers` (Number): عدد الإجابات الخاطئة
- `score` (Number): النسبة المئوية (0-100)
- `completedAt` (String): تاريخ إتمام الاختبار (ISO 8601 format)
- `answers` (Map): Map<questionId, selectedAnswerIndex> - إجابات الطالب

---

## ملاحظات مهمة

1. **Document IDs:**

   - `tests`: يتم إنشاؤها تلقائياً (timestamp-based)
   - `questions`: يتم إنشاؤها تلقائياً (timestamp-based)
   - `testResults`: يتم إنشاؤها تلقائياً (timestamp-based)

2. **Indexes المطلوبة:**

   - `tests`: `adminCode` (لتصفية الاختبارات حسب الأدمن)
   - `questions`: `testId` (لجلب أسئلة اختبار معين)
   - `testResults`: `studentCode` و `testId` (لجلب نتائج طالب أو اختبار معين)

3. **Security Rules:**
   - يجب أن يسمح للأدمن بإنشاء وتعديل وحذف الاختبارات الخاصة به
   - يجب أن يسمح للطلاب بقراءة الاختبارات والأسئلة
   - يجب أن يسمح للطلاب بإنشاء نتائج الاختبارات الخاصة بهم فقط

---

## مثال على البيانات

### اختبار:

```json
{
  "id": "1234567890",
  "title": "اختبار القدرات الكمية",
  "description": "اختبار شامل على القدرات الكمية",
  "adminCode": "ADMIN001",
  "createdAt": "2024-01-15T10:00:00Z",
  "questionsCount": 5
}
```

### سؤال:

```json
{
  "id": "9876543210",
  "testId": "1234567890",
  "questionText": "ما هو ناتج: 15 + 27؟",
  "options": ["40", "42", "44", "46"],
  "correctAnswerIndex": 1,
  "order": 0
}
```

### نتيجة:

```json
{
  "id": "5555555555",
  "testId": "1234567890",
  "studentCode": "STUDENT001",
  "totalQuestions": 5,
  "correctAnswers": 4,
  "wrongAnswers": 1,
  "score": 80.0,
  "completedAt": "2024-01-15T11:00:00Z",
  "answers": {
    "9876543210": 1,
    "9876543211": 2,
    "9876543212": 0,
    "9876543213": 1,
    "9876543214": 3
  }
}
```
