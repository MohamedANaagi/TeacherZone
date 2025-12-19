# قواعد Firestore - نسخ مباشر | Firestore Rules - Direct Copy

## 📋 القواعد الكاملة (انسخها كما هي):

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // Helper function to validate required fields
    function isValidCode(data) {
      return data.keys().hasAll(['code', 'createdAt']) &&
             data.code is string &&
             data.code.size() > 0 &&
             data.createdAt is string;
    }

    function isValidCourse(data) {
      return data.keys().hasAll(['title', 'description', 'instructor', 'duration', 'createdAt']) &&
             data.title is string &&
             data.description is string &&
             data.instructor is string &&
             data.duration is string &&
             data.createdAt is string &&
             data.lessonsCount is int;
    }

    function isValidVideo(data) {
      return data.keys().hasAll(['courseId', 'title', 'url', 'createdAt']) &&
             data.courseId is string &&
             data.title is string &&
             data.url is string &&
             data.createdAt is string;
    }

    // ==================== Codes Collection ====================
    match /codes/{codeId} {
      // القراءة للجميع (لأن الكود يحتاج التحقق منه)
      allow read: if true;

      // الكتابة مقيدة - فقط من التطبيق (يمكن إضافة authentication لاحقاً)
      allow create: if isValidCode(request.resource.data);
      allow update: if isValidCode(request.resource.data);
      allow delete: if true; // يمكن تقييد الحذف لاحقاً
    }

    // ==================== Courses Collection ====================
    match /courses/{courseId} {
      // القراءة للجميع (المستخدمون يحتاجون رؤية الكورسات)
      allow read: if true;

      // الكتابة - فقط مع البيانات الصحيحة
      allow create: if isValidCourse(request.resource.data);
      allow update: if isValidCourse(request.resource.data) &&
                       // منع تغيير createdAt
                       request.resource.data.createdAt == resource.data.createdAt;
      allow delete: if true; // يمكن تقييد الحذف لاحقاً
    }

    // ==================== Videos Collection ====================
    match /videos/{videoId} {
      // القراءة للجميع (المستخدمون يحتاجون رؤية الفيديوهات)
      allow read: if true;

      // الكتابة - فقط مع البيانات الصحيحة
      allow create: if isValidVideo(request.resource.data) &&
                       // التأكد من وجود الكورس
                       exists(/databases/$(database)/documents/courses/$(request.resource.data.courseId));
      allow update: if isValidVideo(request.resource.data) &&
                       // منع تغيير createdAt
                       request.resource.data.createdAt == resource.data.createdAt &&
                       // منع تغيير courseId
                       request.resource.data.courseId == resource.data.courseId;
      allow delete: if true; // يمكن تقييد الحذف لاحقاً
    }

    // ==================== Default Deny ====================
    // رفض أي شيء آخر
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

## 🚀 طريقة التطبيق:

### الطريقة 1: من Firebase Console (الأسهل)

1. افتح [Firebase Console](https://console.firebase.google.com/)
2. اختر مشروعك (TeacherZone)
3. من القائمة الجانبية، اختر **Firestore Database**
4. اضغط على تبويب **Rules** (في الأعلى)
5. **احذف** كل القواعد الموجودة حالياً
6. **انسخ** القواعد الكاملة من الأعلى (من `rules_version` إلى `}` الأخيرة)
7. **الصق** في المربع
8. اضغط **Publish** (نشر)

### الطريقة 2: من Terminal (للأكثر احترافية)

```bash
# تأكد أنك في مجلد المشروع
cd /Users/mohamednagi/Documents/projects/TeacherZone

# تأكد أن Firebase CLI مثبت
firebase login

# نشر القواعد
firebase deploy --only firestore:rules
```

## ✅ ما تفعله هذه القواعد:

1. **codes (الأكواد)**:

   - ✅ الجميع يمكنه القراءة
   - ✅ فقط البيانات الصحيحة يمكن إضافتها/تحديثها
   - ✅ يمكن حذف أي كود

2. **courses (الكورسات)**:

   - ✅ الجميع يمكنه القراءة
   - ✅ فقط البيانات الصحيحة يمكن إضافتها/تحديثها
   - ✅ لا يمكن تغيير `createdAt` عند التحديث
   - ✅ يمكن حذف أي كورس

3. **videos (الفيديوهات)**:

   - ✅ الجميع يمكنه القراءة
   - ✅ فقط البيانات الصحيحة يمكن إضافتها/تحديثها
   - ✅ يجب أن يكون الكورس موجوداً قبل إضافة فيديو
   - ✅ لا يمكن تغيير `createdAt` أو `courseId` عند التحديث
   - ✅ يمكن حذف أي فيديو

4. **Default Deny**:
   - ❌ أي collection آخر محظور تماماً

## ⚠️ ملاحظات مهمة:

- هذه القواعد **آمنة للتطوير** ولكنها **ليست آمنة للإنتاج**
- في الإنتاج، يجب إضافة authentication (مثل Firebase Auth) لتقييد الوصول
- حالياً، أي شخص لديه رابط التطبيق يمكنه الكتابة في Firestore (لكن فقط ببيانات صحيحة)

## 🔍 التحقق من القواعد:

بعد تطبيق القواعد، جرب:

1. إضافة كود من Admin Panel
2. إضافة كورس
3. إضافة فيديو لكورس

إذا عملت جميع العمليات بدون أخطاء، فالقواعد صحيحة! ✅
